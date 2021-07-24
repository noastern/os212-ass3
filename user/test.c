#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"
#include "kernel/syscall.h"
#include "kernel/memlayout.h"
#include "kernel/riscv.h"

#define PRINT_START(NAME)   printf("\n     ~~~~     \n%s started\n\n",NAME);
#define PRINT_END(NAME, PGF) printf("\n%s finished with score of %d pagefaults\n     ~~~~     \n",NAME, PGF);

char* test_name_array[20];
int pgf_array[20];
int sum_value;

void basic_fork_test(char* test_name);
void malloc_test_simple(char* test_name);
void malloc_test_complicated(char* test_name);
void sbrk_test_son(char* test_name);
void sbrk_test_father(char* test_name);
void double_sbrk_test_son(char* test_name);
void complicated_sbrk(char* test_name);
void test_goto_bad(char* test_name);
void exec_test(char* test_name);
void maxpages_switch(char* test_name);
void malloc_test_not_multiply_of_PGSIZE(char* test_name);
void sbrk_not_multiply_of_PGSIZE(char* test_name);

void ALGO_test(char* test_name);




void basic_fork_test(char* test_name){ 
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
    PRINT_START(test_name);
    int cpid = fork();
    if (cpid){ // father
        printf("i am the father!\n");
        wait(0);
    }
    else{
        int cpid2 = fork();
        if(cpid2){//first son
            printf("i am the first son!\n");
            wait(0);
        }
        else{
            printf("i am the son's son!\n");
        }
        exit(0);
    }
    PRINT_END(test_name, -1);
}

void sbrk_test_son(char* test_name){ 
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
    PRINT_START(test_name);
    int pgf;
    int i=0;
    int num=16; 
    int cpid = fork();
    if (cpid){//father
        wait(&pgf);
    }
    else{//son
        printf("~~~~~~~~~~~~~~son gonna sbrk!!!!!\n");
        int * memory_pointer = (int*)(sbrk(PGSIZE*num));
        printf("~~~~~~~~~~~~~~son finish sbrk!!!!!\n");

        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
            memory_pointer[i]=0;
        }
        printf("finished alloc with sbrk and set values\n");
        sbrk(-PGSIZE*num);
        printf("finished free\n");
        pgf = setAndGetPageFaultsNum(-1);
        exit(pgf);
    }

    test_name_array[0] = test_name;
    pgf_array[0] = pgf;
    sum_value= sum_value+pgf;

    PRINT_END(test_name, pgf);
}

void sbrk_not_multiply_of_PGSIZE(char* test_name){
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
    PRINT_START(test_name);
    int pgf;
    int i=0;
    int num=25; 
    int cpid = fork();
    if (cpid){//father
        wait(&pgf);
    }
    else{//son
        int * memory_pointer = (int*)(sbrk(PGSIZE*num+8));
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
            memory_pointer[i]=i;
        }
        memory_pointer[i+40]= 40;
        printf("finished alloc with sbrk and set values\n");

        printf("memory_pointer[sbrk(PGSIZE*num)+7]=%d    \n",memory_pointer[i-1]);
        printf("memory_pointer[sbrk(PGSIZE*num)+3]=%d    \n",memory_pointer[i-2]);
        printf("memory_pointer[sbrk(PGSIZE*num)+13]=%d    \n",memory_pointer[i+1]);

        sbrk(-PGSIZE*num);
        printf("finished free\n");
        pgf = setAndGetPageFaultsNum(-1);
        exit(pgf);
    }
    test_name_array[1] = test_name;
    pgf_array[1] = pgf;
    sum_value= sum_value+pgf;
    PRINT_END(test_name, pgf);
}


void sbrk_test_father(char* test_name){
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
    PRINT_START(test_name);
    int i=0;
    int pgf =0;
    int num = 25;
    int * memory_pointer = (int*)(sbrk(PGSIZE*num));
    for (i=0; i<PGSIZE*num/sizeof(int); ++i){
        memory_pointer[i]=0;
    }
    printf("finished alloc with sbrk and set values\n");
    sbrk(-PGSIZE*num);
    printf("finished free\n");
    pgf= setAndGetPageFaultsNum(0);
    test_name_array[2] = test_name;
    pgf_array[2] = pgf;
    sum_value= sum_value+pgf;
    PRINT_END(test_name, pgf);
}

void double_sbrk_test_son(char* test_name){
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
    PRINT_START(test_name);
    int pgf;
    int i=0;
    int num = 25;
    int cpid = fork();
    if (cpid){//father
        wait(&pgf);
    }
    else{//son
        int * memory_pointer = (int*)(sbrk(PGSIZE*num));
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
            memory_pointer[i]=0;
        }
        printf("finished first alloc and giving value\n");
        sbrk(-PGSIZE*num);
        printf("finished first dealloc\n");
        memory_pointer = (int*)(sbrk(PGSIZE*num));
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
            memory_pointer[i]=i;
        }
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
            if(i % PGSIZE == 0){
                printf("var in palce %d value is: %d\n",i, memory_pointer[i]);
            }
        }
        printf("finished second  alloc, giving values, and printing\n");
        sbrk(-PGSIZE*num);
        pgf = setAndGetPageFaultsNum(-1);
        printf("finished second dealloc\n");
        exit(pgf);
    }
    test_name_array[3] = test_name;
    pgf_array[3] = pgf;
    sum_value= sum_value+pgf;
    PRINT_END(test_name, pgf);
}

void complicated_sbrk(char* test_name){
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
    PRINT_START(test_name);
    int pgf;
    int i=0;
    int num = 20;
    int cpid = fork();
    if (cpid){//father
        wait(&pgf);
    }
    else{//son
        int sonAndGrandPgf=0;
        int * memory_pointer = (int*)(sbrk(PGSIZE*num));
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
            //memory_pointer[i]=i;
            memory_pointer[i]=30;
        }
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
            if(i%(PGSIZE/sizeof(int)) == 0)
                printf("num %d: memory_pointer[i]=%d\n", i*4/PGSIZE, memory_pointer[i]);
        }
        printf("finished first alloc and giving value\n");
        int cpid2 = fork();
        printf("finished second fork\n");
        if (!cpid2){//grandchild
            printf("grandchild prints values got from son:\n");
            //for (i=0; i<num; ++i){
            //   printf("num %d: memory_pointer[i*PGSIZE/num]=%d\n", i, memory_pointer[i*(PGSIZE*num/sizeof(int))]);
            //}
            for (i=0; i<PGSIZE*num/sizeof(int); ++i){
                if(i%(PGSIZE/sizeof(int)) == 0)
                    printf("num %d: memory_pointer[i]=%d\n", i*4/PGSIZE, memory_pointer[i]);
            }

            printf("grandchild about to reassign values\n");
            for (i=0; i<PGSIZE*num/sizeof(int); ++i){
                memory_pointer[i]=12;
            }

            for (i=0; i<PGSIZE*num/sizeof(int); ++i){
                if(i%(PGSIZE/sizeof(int)) == 0)
                    printf("num %d: memory_pointer[i]=%d\n", i*4/PGSIZE, memory_pointer[i]);
            }

            printf("\ngrandchild about to deallocate the %d pages that were allocated by his parent and inherited to child\n", num);
            sbrk(-PGSIZE*num);
            printf("granchiled deallocated successfully => inheritance works fine\n");

            
            //uncomment these lines later
            printf("about to access memory we deallocated and therefore results in segmentation fault\n");
            for (i=0; i<PGSIZE*num/sizeof(int); i++){
                memory_pointer[i]=1;
            }
            printf("if we print this its bad! -> means we didn't really dealloc the pages\n");
            
            int pgf2 = setAndGetPageFaultsNum(-1);
            exit(pgf2); //to keep track of total num of page faults
        }
        else{// son
            wait(&sonAndGrandPgf);
            printf("child about to print values and make sure grandchild did not change them, \nwhich means it should not be 12\n");
            for (i=0; i<PGSIZE*num/sizeof(int); ++i){
                if(i%(PGSIZE/sizeof(int)) == 0)
                    printf("num %d: memory_pointer[i]=%d\n", i*4/PGSIZE, memory_pointer[i]);
            }
            sbrk(-PGSIZE*num);
            printf("chiled deallocated\n");
            sonAndGrandPgf = sonAndGrandPgf + setAndGetPageFaultsNum(-1);
            exit(sonAndGrandPgf);
        } 
    }
    test_name_array[4] = test_name;
    pgf_array[4] = pgf;
    sum_value= sum_value+pgf;
    PRINT_END(test_name, pgf);
}

void maxpages_switch(char* test_name){ 
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
    PRINT_START(test_name);
    int pgf;
    int i=0;
    int num=28; 
    int cpid = fork();
    if (cpid){//father
        wait(&pgf);
    }
    else{//son
        int * memory_pointer = (int*)(sbrk(PGSIZE*num));
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
            memory_pointer[i]=0;
        }
        printf("finished alloc with sbrk and set values\n");
        sbrk(-PGSIZE*num);
        printf("finished free\n");
        pgf = setAndGetPageFaultsNum(-1);
        exit(pgf);
    }
    test_name_array[5] = test_name;
    pgf_array[5] = pgf;
    sum_value= sum_value+pgf;
    PRINT_END(test_name, pgf);
}

void malloc_test_simple(char* test_name){ 
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
    PRINT_START(test_name);
    int pgf;
    int i=0;
    int num=20;
    int cpid = fork();
    if (cpid){//father
        wait(&pgf);
    }
    else{//son
        int * memory_pointer = (int*)(malloc(PGSIZE*num));
        printf("finished alloc with malloc\n");
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
            memory_pointer[i]=3;
            //printf("memory_pointer[i]=%d    ",memory_pointer[i]);
        }
        printf("\nfinished set values\n");
        free(memory_pointer);
        printf("finished free\n");
        pgf = setAndGetPageFaultsNum(-1);
        exit(pgf);
    }
    test_name_array[6] = test_name;
    pgf_array[6] = pgf;
    sum_value= sum_value+pgf;
    PRINT_END(test_name, pgf);
}

void malloc_test_not_multiply_of_PGSIZE(char* test_name){ 
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
    PRINT_START(test_name);
    int pgf;
    int i=0;
    int num=20;
    int cpid = fork();
    if (cpid){//father
        wait(&pgf);
    }
    else{//son
        int * memory_pointer = (int*)(malloc(PGSIZE*num)+8);
        printf("finished alloc with malloc\n");
        for (i=0; i<PGSIZE*num/sizeof(int) +2; ++i){
            memory_pointer[i]=3;
            //printf("memory_pointer[i]=%d    ",memory_pointer[i]);
        }
        printf("memory_pointer[malloc(PGSIZE*num)+7]=%d    ",memory_pointer[i-1]);
        printf("memory_pointer[malloc(PGSIZE*num)+3]=%d    ",memory_pointer[i-2]);

        printf("\nfinished set values\n");
        free(memory_pointer);
        printf("finished free\n");
        pgf = setAndGetPageFaultsNum(-1);
        exit(pgf);
    }
    test_name_array[7] = test_name;
    pgf_array[7] = pgf;
    sum_value= sum_value+pgf;
    PRINT_END(test_name, pgf);
}

void malloc_test_complicated(char* test_name){ 
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
    PRINT_START(test_name);
    int pgf;
    int i=0;
    int num = 25;
    int cpid = fork();
    if (cpid){//father
        wait(&pgf);
    }
    else{//son
        int sonAndGrandPgf=0;
        int * memory_pointer = (int*)(malloc(PGSIZE*num));
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
            memory_pointer[i]=i;
        }
        printf("finished first alloc and giving value\n");
        int cpid2 = fork();
        printf("finished second fork\n");
        if (!cpid2){//grandchild
            
            printf("grandchild about to deallocatre the %d pages that were allocated by his parent and inherited to child\n", num);
            free(memory_pointer);
            printf("granchiled deallocated successfully => inheritance works fine\n");

            int pgf2 = setAndGetPageFaultsNum(-1);
            exit(pgf2); //to keep track of total num of page faults
        }
        else{// son
            wait(&sonAndGrandPgf);
            free(memory_pointer);
            //printf("chiled deallocated\n");
            sonAndGrandPgf = sonAndGrandPgf + setAndGetPageFaultsNum(-1);
            exit(sonAndGrandPgf);
        } 
    }
    test_name_array[8] = test_name;
    pgf_array[8] = pgf;
    sum_value= sum_value+pgf;
    PRINT_END(test_name, pgf);
}

void test_goto_bad(char* test_name){
    PRINT_START(test_name);
    int pgf;
    int i=0;
    int num=25; 
    int cpid = fork();
    if (cpid){//father
        wait(&pgf);
    }
    else{//son
        int * memory_pointer = (int*)(sbrk(PGSIZE*num));
        printf("finished alloc with sbrk and set values\n");
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
            memory_pointer[i]=5;
        }
        char* argv[] = {"test",0};
        printf("going to exec\n");
		exec(argv[0],argv);
        printf("returned from exec and gonna fill memory :))))\n");
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
            printf("memory_pointer[i]=%d\n", memory_pointer[i]);
        }
        sbrk(-PGSIZE*num);
        printf("finished free\n");
        pgf = setAndGetPageFaultsNum(-1);
        exit(pgf);
    }
    test_name_array[9] = test_name;
    pgf_array[9] = pgf;
    sum_value= sum_value+pgf;
    PRINT_END(test_name, pgf);
}

void ALGO_test(char* test_name){ 
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
    PRINT_START(test_name);
    int pgf;
    int i=0;
    int num=13; 
    int cpid = fork();
    if (cpid){//father
        wait(&pgf);
    }
    else{//son
        printf("~~~~~~~~~~~~~~son gonna sbrk!!!!!\n");
        int * memory_pointer = (int*)(sbrk(PGSIZE*num));
        printf("~~~~~~~~~~~~~~son finish sbrk!!!!!\n");
        printf("~~~~~~~~~~~~~~son gonna change value of last page!!!!!\n");
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
            if(i > PGSIZE*12/sizeof(int))
            memory_pointer[i]=1;
        }
        sleep(2);
        memory_pointer[12*PGSIZE/sizeof(int)+1]=1;
        printf("~~~~~~~~~~~~~~son gonna change all values!!!!!\n");


        
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
            memory_pointer[i]=0;
            if(i%(PGSIZE/sizeof(int)) == 0)
                printf("num %d: memory_pointer[i]=%d\n", i*4/PGSIZE, memory_pointer[i]);
        }
        sleep(1);
        memory_pointer[10*PGSIZE/sizeof(int)+1]=1;
        printf("\nfinished alloc with sbrk and set values\n");


        sbrk(-PGSIZE*num);
        printf("finished free\n");
        pgf = setAndGetPageFaultsNum(-1);
        exit(pgf);
    }
    test_name_array[10] = test_name;
    pgf_array[10] = pgf;
    sum_value= sum_value+pgf;
    PRINT_END(test_name, pgf);
}


int
main(int argc, char *argv[])
{
    //test_goto_bad("test_goto_bad");
    for(int i=0; i<20; i++){test_name_array[i]=0;}


    basic_fork_test("basic_fork_test");
    
    sbrk_test_son("sbrk_test_son");
    sbrk_test_father("sbrk_test_father");
    double_sbrk_test_son("double_sbrk_test_son");
    sbrk_not_multiply_of_PGSIZE("sbrk_not_multiply_of_PGSIZE");
    
    complicated_sbrk("complicated_sbrk");
    
    //maxpages_switch("maxpages_switch");

    malloc_test_simple("malloc_test_simple");
    malloc_test_not_multiply_of_PGSIZE("malloc_test_not_multiply_of_PGSIZE");
    
    malloc_test_complicated("malloc_test_complicated");
    
    ALGO_test("ALGO_test");
    


    //sum up 
    
    printf("\n         ~~~~~~~~~~~\n~~~~~~~~~~~      ~~~~~~~~~~~\n");
    printf("\n              SUMMARY\n");
    for(int i=0; i<20; i++){
        if(test_name_array[i]!=0){
            printf("%s:  %d\n", test_name_array[i], pgf_array[i]);
        }
    }

    printf("\n SUM: %d\n", sum_value);
    printf("\n~~~~~~~~~~~      ~~~~~~~~~~~\n         ~~~~~~~~~~~\n");
    exit(0);

}