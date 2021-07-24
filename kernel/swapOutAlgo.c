#ifndef NONE

    #include "param.h"
    #include "types.h"
    #include "memlayout.h"
    #include "elf.h"
    #include "riscv.h"
    #include "defs.h"
    #include "fs.h"
    #include "spinlock.h"
    #include "proc.h"

    #if defined(NFUA) || defined(LAPA)
        static int lapaIndex = 0;
    #endif


    int
    findPagetableIndexToSwap(struct proc* p){
        #ifdef NFUA
        return NFUAAlgo(p);
        #endif
        #ifdef LAPA
            return LAPAAlgo(p);
        #endif
        #ifdef SCFIFO
            return SCFIFOAlgo(p);
        #endif

    }
    #if defined(NFUA) || defined(LAPA)

        void
        counterUpdating(struct proc* p){
            for (int i = 0; i < MAX_PSYC_PAGES; i++){
                if (p->physPagesArray[i].inUse == 1){
                    pte_t* pte = walk(p->pagetable, p->physPagesArray[i].va, 0);     
                    
                    p->physPagesArray[i].counter =  p->physPagesArray[i].counter >> 1;
                    if (*pte & PTE_A){ // accessed flag is on
                        //printf("PTE_A is on! i: %d with process %d\n", i, p->pid);
                        //p->physPagesArray[i].counter =  p->physPagesArray[i].counter | (1 << ((sizeof(uint)*8)-1));
                        p->physPagesArray[i].counter =  p->physPagesArray[i].counter | (1 << 31);
                        *pte = *pte & ~PTE_A; // turning off PTE_A flag
                    }
                }
            }
        }

        int
        NFUAAlgo(struct proc* p){
            lapaIndex=1;//just for easiing the compilation..
            int minCounterIndex = -1;
            uint minCounter = 0xFFFFFFFF;
            for (int i = 0; i < MAX_PSYC_PAGES; i++){
                if (p->physPagesArray[i].inUse == 1){
                    pte_t* pte = walk(p->pagetable, p->physPagesArray[i].va, 0);

                    if (*pte & PTE_U){
                        if (p->physPagesArray[i].counter <= minCounter){
                            minCounter = p->physPagesArray[i].counter;
                            minCounterIndex = i;
                        }
                    }
                }
            }
            if (minCounterIndex != -1)
                return minCounterIndex;
            
            panic("NFUAAlgo FAILED! didnt find any isUsed physical pages\n");
            return -1;
        }

        int
        numOfOnes(uint num){
            int counter = 0;
            for(int i = 0; i < (sizeof(uint)*8); i++){
                if (num & (1 << i)){
                    counter++;
                }
            }
            //printf("counter is: %d\n", counter);
            return counter;
        }

        int
        LAPAAlgo(struct proc* p){
            //printf("entered lapa algo with lapa index:%d\n", lapaIndex);
            int minCounterIndex = -1;
            uint minNumOfOnes = 100;
            uint minCounter = 0xFFFFFFFF;
            int i = lapaIndex%16;
            //printf("in lapa algo - starting from index %d\n", i);
            int loop_counter=0;
            while (loop_counter<MAX_PSYC_PAGES){
                if ((p->physPagesArray[i].inUse == 1)){
                    pte_t* pte = walk(p->pagetable, p->physPagesArray[i].va, 0);

                    if (*pte & PTE_U){
                        
                        int inumOfOnes = numOfOnes(p->physPagesArray[i].counter);
                        //printf("p->physPagesArray[%d] num of ones is %d\n", i, inumOfOnes);
                        if (inumOfOnes < minNumOfOnes){
                            
                            minNumOfOnes = inumOfOnes;
                            minCounter = p->physPagesArray[i].counter;
                            minCounterIndex = i;
                        }
                        else if (inumOfOnes == minNumOfOnes){
                           
                            if (p->physPagesArray[i].counter <= minCounter){
                                minCounter = p->physPagesArray[i].counter;
                                minCounterIndex = i;
                            }
                        }
                    }
                }
                i++;
                i=i%16;
                loop_counter++;
            }
            lapaIndex++;
            if (minCounterIndex != -1){
                //printf("minCounterIndex: %d\n", minCounterIndex);
                return minCounterIndex;
            }
            
            panic("LAPAAlgo FAILED! didnt find any isUsed physical pages\n");
            return -1;
        }
    #endif


    #ifdef SCFIFO
        int
        findNextMin(struct proc * p){
            uint min = 0xFFFFFFFF;
            int minindex = -1;
            for(int i = 0; i < 16; i++){
                if ((p->physPagesArray[i].inUse == 1) & (p->physPagesArray[i].placeInQueue < min)){
                    min = p->physPagesArray[i].placeInQueue;
                    minindex = i;
                }
            }
            if(minindex == -1){
                panic("in findNextMin\n");
            }
            return minindex;
        }


        void
        sortArry(struct proc * p){
            struct page pages[16];
            for(int i = 0; i < 16; i++){
                int curr = findNextMin(p);
                pages[i] = p->physPagesArray[curr]; // maybe we need deep copy here!
                p->physPagesArray[curr].inUse = 0;

            }
            for(int j = 0; j < 16; j++){
                p->physPagesArray[j] = pages[j];
            }
        }

        int
        SCFIFOAlgo(struct proc* p){
            sortArry(p);

            /* for debugging reasons
            printf("sorted array:  ");
            for(int i = 0; i < 16; i++){
                printf("%d, ",p->physPagesArray[i].placeInQueue);
            }
            printf("\n");
            */

            int i = 0;
            for (int j = 0; j < MAX_PSYC_PAGES*2; j++){
                i = j%16;
                if (p->physPagesArray[i].inUse == 1){

                    pte_t* pte = walk(p->pagetable, p->physPagesArray[i].va, 0);       
                        
                    if (*pte & PTE_U){ //check that this page is private to the user
                        if (*pte & PTE_A){ // accessed flag is on
                            //printf("page %d with place in que %d has pte_a on\n", i, p->physPagesArray[i].placeInQueue); //for debugging reasons
                            *pte = *pte & ~PTE_A; // turning off PTE_A flag
                        }
                        else{
                            return i;
                        }
                    }
                }
            }
            panic("SCFIFOAlgo  FAILED! didnt find any isUsed physical pages");
            return -1;
        }
    #endif
#endif