#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "elf.h"

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
  //printf("\n----entered exec\n");
  char *s, *last;
  int i, off;
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();

  #ifndef NONE
    //struct file *swapFile_backup;
    int numOfPhyPages_backup = p->numOfPhyPages;
    int numOfTotalPages_backup = p->numOfTotalPages;
    int numOfPageFaults_backup = p->numOfPageFault; 
    int swapOffset_backup = p->swapOffset;
    struct page swapPagesArray_backup[(MAX_TOTAL_PAGES/2)+1]; //disc, secondary memory
    memmove(&swapPagesArray_backup, &p->swapPagesArray, sizeof(p->swapPagesArray));
    struct page physPagesArray_backup[MAX_TOTAL_PAGES/2];
    memmove(&physPagesArray_backup, &p->physPagesArray, sizeof(p->physPagesArray));
  #endif

  begin_op();

  if((ip = namei(path)) == 0){
    end_op();
    return -1;
  }
  ilock(ip);

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    goto bad;
  if(elf.magic != ELF_MAGIC)
    goto bad;

  #ifndef NONE
    if (p->pid>2){
      // our code: clearing the SwapFile

      p->numOfPhyPages = 0;
      p->numOfTotalPages = 0;
      p->numOfPageFault = 0;
      p->swapOffset = 0;

      #ifdef SCFIFO
        p->nextPlaceInQueue = 1;
      #endif
      for(int k = 0; k < MAX_PSYC_PAGES; k++){
        p->swapPagesArray[k].inUse = 0;
        p->swapPagesArray[k].va = -1;
        p->physPagesArray[k].inUse = 0;
        p->physPagesArray[k].va = -1;
        #ifdef NFUA
          p->swapPagesArray[k].counter = 0;
          p->physPagesArray[k].counter = 0;
        #endif

        #ifdef LAPA
          p->swapPagesArray[k].counter = 0xFFFFFFFF;
          p->physPagesArray[k].counter = 0xFFFFFFFF;
        #endif

        #ifdef SCFIFO
          p->swapPagesArray[k].placeInQueue = 0;
          p->physPagesArray[k].placeInQueue = 0;
        #endif
      }
      p->swapPagesArray[16].inUse = 0;
      p->swapPagesArray[16].va = -1;
      #ifdef NFUA
        p->swapPagesArray[16].counter = 0;
      #endif

      #ifdef LAPA
        p->swapPagesArray[16].counter = 0xFFFFFFFF;
      #endif

      #ifdef SCFIFO
        p->swapPagesArray[16].placeInQueue = 0;
      #endif
    } 
  #endif 
  

  if((pagetable = proc_pagetable(p)) == 0)
    goto bad;

  // Load program into memory.
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
      goto bad;
    uint64 sz1;
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    sz = sz1;
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
  end_op();
  ip = 0;

  p = myproc();
  uint64 oldsz = p->sz;
/* for test test_goto_bad uncomment
  printf("p with pid: %d is in exec\n", p->pid);
  if (p->pid == 4)
        goto bad;
*/

  // Allocate two pages at the next page boundary.
  // Use the second as the user stack.
  sz = PGROUNDUP(sz);
  uint64 sz1;
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
  sz = sz1;
  uvmclear(pagetable, sz-2*PGSIZE);
  sp = sz;
  stackbase = sp - PGSIZE;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    if(sp < stackbase)
      goto bad;
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[argc] = sp;
  }
  ustack[argc] = 0;

  // push the array of argv[] pointers.
  sp -= (argc+1) * sizeof(uint64);
  sp -= sp % 16;
  if(sp < stackbase)
    goto bad;
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    goto bad;


/*
  #ifndef NONE
    //for(uint64 va = (uint64)pagetable; va < PGROUNDUP(sz); va+=PGSIZE){ // need to check
    for(int va = 0; va < PGROUNDUP(sz); va+=PGSIZE){ // need to check
     // p->numOfTotalPages++;
     // p->numOfPhyPages++;
      //printf("p->numOfPhyPages: %d , pid: %d \n", p->numOfPhyPages, p->pid);
      // our code
      for (int i = 0; i < MAX_PSYC_PAGES; i++){
        if (p->physPagesArray[i].inUse == 0){
          p->physPagesArray[i].inUse = 1;
          p->physPagesArray[i].va = va; // to do check this!! we think a is the va, and mem is the pa
          #ifdef SCFIFO
            p->physPagesArray[i].placeInQueue = p->nextPlaceInQueue;
            p->nextPlaceInQueue++;
          #endif
          break;
        }
      }
    }
    printf("In exe with pid with num %d \n", p->pid);
    printf("current num of pages in physical is: %d and in total is: %d\n", p->numOfPhyPages, p->numOfTotalPages);  
  #endif
  */
  #ifndef NONE
    if(p->pid > 2){
      removeSwapFile(p);
      createSwapFile(p);
    }
  #endif

  

  // arguments to user main(argc, argv)
  // argc is returned via the system call return
  // value, which goes in a0.
  p->trapframe->a1 = sp;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
    if(*s == '/')
      last = s+1;
  safestrcpy(p->name, last, sizeof(p->name));
    
  // Commit to the user image.
  oldpagetable = p->pagetable;
  p->pagetable = pagetable;
  p->sz = sz;
  p->trapframe->epc = elf.entry;  // initial program counter = main
  p->trapframe->sp = sp; // initial stack pointer
  proc_freepagetable(oldpagetable, oldsz);

  return argc; // this ends up in a0, the first argument to main(argc, argv)

 bad:
  #ifndef NONE
    p->numOfPhyPages = numOfPhyPages_backup;
    p->numOfTotalPages = numOfTotalPages_backup;
    p->numOfPageFault = numOfPageFaults_backup; 
    p->swapOffset = swapOffset_backup;
    memmove(&p->swapPagesArray, &swapPagesArray_backup, sizeof(p->swapPagesArray));
    memmove(&p->physPagesArray, &physPagesArray_backup, sizeof(p->physPagesArray));
  #endif
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    end_op();
  }
  return -1;
}

// Load a program segment into pagetable at virtual address va.
// va must be page-aligned
// and the pages from va to va+sz must already be mapped.
// Returns 0 on success, -1 on failure.
static int
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
      return -1;
  }
  
  return 0;
}
