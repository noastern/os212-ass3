
user/_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <basic_fork_test>:
void ALGO_test(char* test_name);




void basic_fork_test(char* test_name){ 
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	e426                	sd	s1,8(sp)
       8:	1000                	addi	s0,sp,32
       a:	84aa                	mv	s1,a0
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
       c:	4501                	li	a0,0
       e:	00001097          	auipc	ra,0x1
      12:	2d2080e7          	jalr	722(ra) # 12e0 <setAndGetPageFaultsNum>
    PRINT_START(test_name);
      16:	85a6                	mv	a1,s1
      18:	00001517          	auipc	a0,0x1
      1c:	75050513          	addi	a0,a0,1872 # 1768 <malloc+0xea>
      20:	00001097          	auipc	ra,0x1
      24:	5a0080e7          	jalr	1440(ra) # 15c0 <printf>
    int cpid = fork();
      28:	00001097          	auipc	ra,0x1
      2c:	210080e7          	jalr	528(ra) # 1238 <fork>
    if (cpid){ // father
      30:	cd0d                	beqz	a0,6a <basic_fork_test+0x6a>
        printf("i am the father!\n");
      32:	00001517          	auipc	a0,0x1
      36:	75650513          	addi	a0,a0,1878 # 1788 <malloc+0x10a>
      3a:	00001097          	auipc	ra,0x1
      3e:	586080e7          	jalr	1414(ra) # 15c0 <printf>
        wait(0);
      42:	4501                	li	a0,0
      44:	00001097          	auipc	ra,0x1
      48:	204080e7          	jalr	516(ra) # 1248 <wait>
        else{
            printf("i am the son's son!\n");
        }
        exit(0);
    }
    PRINT_END(test_name, -1);
      4c:	567d                	li	a2,-1
      4e:	85a6                	mv	a1,s1
      50:	00001517          	auipc	a0,0x1
      54:	75050513          	addi	a0,a0,1872 # 17a0 <malloc+0x122>
      58:	00001097          	auipc	ra,0x1
      5c:	568080e7          	jalr	1384(ra) # 15c0 <printf>
}
      60:	60e2                	ld	ra,24(sp)
      62:	6442                	ld	s0,16(sp)
      64:	64a2                	ld	s1,8(sp)
      66:	6105                	addi	sp,sp,32
      68:	8082                	ret
        int cpid2 = fork();
      6a:	00001097          	auipc	ra,0x1
      6e:	1ce080e7          	jalr	462(ra) # 1238 <fork>
        if(cpid2){//first son
      72:	c11d                	beqz	a0,98 <basic_fork_test+0x98>
            printf("i am the first son!\n");
      74:	00001517          	auipc	a0,0x1
      78:	76c50513          	addi	a0,a0,1900 # 17e0 <malloc+0x162>
      7c:	00001097          	auipc	ra,0x1
      80:	544080e7          	jalr	1348(ra) # 15c0 <printf>
            wait(0);
      84:	4501                	li	a0,0
      86:	00001097          	auipc	ra,0x1
      8a:	1c2080e7          	jalr	450(ra) # 1248 <wait>
        exit(0);
      8e:	4501                	li	a0,0
      90:	00001097          	auipc	ra,0x1
      94:	1b0080e7          	jalr	432(ra) # 1240 <exit>
            printf("i am the son's son!\n");
      98:	00001517          	auipc	a0,0x1
      9c:	76050513          	addi	a0,a0,1888 # 17f8 <malloc+0x17a>
      a0:	00001097          	auipc	ra,0x1
      a4:	520080e7          	jalr	1312(ra) # 15c0 <printf>
      a8:	b7dd                	j	8e <basic_fork_test+0x8e>

00000000000000aa <sbrk_test_son>:

void sbrk_test_son(char* test_name){ 
      aa:	7179                	addi	sp,sp,-48
      ac:	f406                	sd	ra,40(sp)
      ae:	f022                	sd	s0,32(sp)
      b0:	ec26                	sd	s1,24(sp)
      b2:	1800                	addi	s0,sp,48
      b4:	84aa                	mv	s1,a0
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
      b6:	4501                	li	a0,0
      b8:	00001097          	auipc	ra,0x1
      bc:	228080e7          	jalr	552(ra) # 12e0 <setAndGetPageFaultsNum>
    PRINT_START(test_name);
      c0:	85a6                	mv	a1,s1
      c2:	00001517          	auipc	a0,0x1
      c6:	6a650513          	addi	a0,a0,1702 # 1768 <malloc+0xea>
      ca:	00001097          	auipc	ra,0x1
      ce:	4f6080e7          	jalr	1270(ra) # 15c0 <printf>
    int pgf;
    int i=0;
    int num=16; 
    int cpid = fork();
      d2:	00001097          	auipc	ra,0x1
      d6:	166080e7          	jalr	358(ra) # 1238 <fork>
    if (cpid){//father
      da:	c529                	beqz	a0,124 <sbrk_test_son+0x7a>
        wait(&pgf);
      dc:	fdc40513          	addi	a0,s0,-36
      e0:	00001097          	auipc	ra,0x1
      e4:	168080e7          	jalr	360(ra) # 1248 <wait>
        printf("finished free\n");
        pgf = setAndGetPageFaultsNum(-1);
        exit(pgf);
    }

    test_name_array[0] = test_name;
      e8:	00002797          	auipc	a5,0x2
      ec:	f0078793          	addi	a5,a5,-256 # 1fe8 <test_name_array>
      f0:	e384                	sd	s1,0(a5)
    pgf_array[0] = pgf;
      f2:	fdc42603          	lw	a2,-36(s0)
      f6:	0ac7a023          	sw	a2,160(a5)
    sum_value= sum_value+pgf;
      fa:	00002717          	auipc	a4,0x2
      fe:	ede70713          	addi	a4,a4,-290 # 1fd8 <sum_value>
     102:	431c                	lw	a5,0(a4)
     104:	9fb1                	addw	a5,a5,a2
     106:	c31c                	sw	a5,0(a4)

    PRINT_END(test_name, pgf);
     108:	85a6                	mv	a1,s1
     10a:	00001517          	auipc	a0,0x1
     10e:	69650513          	addi	a0,a0,1686 # 17a0 <malloc+0x122>
     112:	00001097          	auipc	ra,0x1
     116:	4ae080e7          	jalr	1198(ra) # 15c0 <printf>
}
     11a:	70a2                	ld	ra,40(sp)
     11c:	7402                	ld	s0,32(sp)
     11e:	64e2                	ld	s1,24(sp)
     120:	6145                	addi	sp,sp,48
     122:	8082                	ret
        printf("~~~~~~~~~~~~~~son gonna sbrk!!!!!\n");
     124:	00001517          	auipc	a0,0x1
     128:	6ec50513          	addi	a0,a0,1772 # 1810 <malloc+0x192>
     12c:	00001097          	auipc	ra,0x1
     130:	494080e7          	jalr	1172(ra) # 15c0 <printf>
        int * memory_pointer = (int*)(sbrk(PGSIZE*num));
     134:	6541                	lui	a0,0x10
     136:	00001097          	auipc	ra,0x1
     13a:	192080e7          	jalr	402(ra) # 12c8 <sbrk>
     13e:	84aa                	mv	s1,a0
        printf("~~~~~~~~~~~~~~son finish sbrk!!!!!\n");
     140:	00001517          	auipc	a0,0x1
     144:	6f850513          	addi	a0,a0,1784 # 1838 <malloc+0x1ba>
     148:	00001097          	auipc	ra,0x1
     14c:	478080e7          	jalr	1144(ra) # 15c0 <printf>
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     150:	87a6                	mv	a5,s1
     152:	6741                	lui	a4,0x10
     154:	9726                	add	a4,a4,s1
            memory_pointer[i]=0;
     156:	0007a023          	sw	zero,0(a5)
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     15a:	0791                	addi	a5,a5,4
     15c:	fee79de3          	bne	a5,a4,156 <sbrk_test_son+0xac>
        printf("finished alloc with sbrk and set values\n");
     160:	00001517          	auipc	a0,0x1
     164:	70050513          	addi	a0,a0,1792 # 1860 <malloc+0x1e2>
     168:	00001097          	auipc	ra,0x1
     16c:	458080e7          	jalr	1112(ra) # 15c0 <printf>
        sbrk(-PGSIZE*num);
     170:	7541                	lui	a0,0xffff0
     172:	00001097          	auipc	ra,0x1
     176:	156080e7          	jalr	342(ra) # 12c8 <sbrk>
        printf("finished free\n");
     17a:	00001517          	auipc	a0,0x1
     17e:	71650513          	addi	a0,a0,1814 # 1890 <malloc+0x212>
     182:	00001097          	auipc	ra,0x1
     186:	43e080e7          	jalr	1086(ra) # 15c0 <printf>
        pgf = setAndGetPageFaultsNum(-1);
     18a:	557d                	li	a0,-1
     18c:	00001097          	auipc	ra,0x1
     190:	154080e7          	jalr	340(ra) # 12e0 <setAndGetPageFaultsNum>
     194:	fca42e23          	sw	a0,-36(s0)
        exit(pgf);
     198:	00001097          	auipc	ra,0x1
     19c:	0a8080e7          	jalr	168(ra) # 1240 <exit>

00000000000001a0 <sbrk_not_multiply_of_PGSIZE>:

void sbrk_not_multiply_of_PGSIZE(char* test_name){
     1a0:	7179                	addi	sp,sp,-48
     1a2:	f406                	sd	ra,40(sp)
     1a4:	f022                	sd	s0,32(sp)
     1a6:	ec26                	sd	s1,24(sp)
     1a8:	e84a                	sd	s2,16(sp)
     1aa:	1800                	addi	s0,sp,48
     1ac:	84aa                	mv	s1,a0
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
     1ae:	4501                	li	a0,0
     1b0:	00001097          	auipc	ra,0x1
     1b4:	130080e7          	jalr	304(ra) # 12e0 <setAndGetPageFaultsNum>
    PRINT_START(test_name);
     1b8:	85a6                	mv	a1,s1
     1ba:	00001517          	auipc	a0,0x1
     1be:	5ae50513          	addi	a0,a0,1454 # 1768 <malloc+0xea>
     1c2:	00001097          	auipc	ra,0x1
     1c6:	3fe080e7          	jalr	1022(ra) # 15c0 <printf>
    int pgf;
    int i=0;
    int num=25; 
    int cpid = fork();
     1ca:	00001097          	auipc	ra,0x1
     1ce:	06e080e7          	jalr	110(ra) # 1238 <fork>
    if (cpid){//father
     1d2:	c531                	beqz	a0,21e <sbrk_not_multiply_of_PGSIZE+0x7e>
        wait(&pgf);
     1d4:	fdc40513          	addi	a0,s0,-36
     1d8:	00001097          	auipc	ra,0x1
     1dc:	070080e7          	jalr	112(ra) # 1248 <wait>
        sbrk(-PGSIZE*num);
        printf("finished free\n");
        pgf = setAndGetPageFaultsNum(-1);
        exit(pgf);
    }
    test_name_array[1] = test_name;
     1e0:	00002797          	auipc	a5,0x2
     1e4:	e0878793          	addi	a5,a5,-504 # 1fe8 <test_name_array>
     1e8:	e784                	sd	s1,8(a5)
    pgf_array[1] = pgf;
     1ea:	fdc42603          	lw	a2,-36(s0)
     1ee:	0ac7a223          	sw	a2,164(a5)
    sum_value= sum_value+pgf;
     1f2:	00002717          	auipc	a4,0x2
     1f6:	de670713          	addi	a4,a4,-538 # 1fd8 <sum_value>
     1fa:	431c                	lw	a5,0(a4)
     1fc:	9fb1                	addw	a5,a5,a2
     1fe:	c31c                	sw	a5,0(a4)
    PRINT_END(test_name, pgf);
     200:	85a6                	mv	a1,s1
     202:	00001517          	auipc	a0,0x1
     206:	59e50513          	addi	a0,a0,1438 # 17a0 <malloc+0x122>
     20a:	00001097          	auipc	ra,0x1
     20e:	3b6080e7          	jalr	950(ra) # 15c0 <printf>
}
     212:	70a2                	ld	ra,40(sp)
     214:	7402                	ld	s0,32(sp)
     216:	64e2                	ld	s1,24(sp)
     218:	6942                	ld	s2,16(sp)
     21a:	6145                	addi	sp,sp,48
     21c:	8082                	ret
     21e:	892a                	mv	s2,a0
        int * memory_pointer = (int*)(sbrk(PGSIZE*num+8));
     220:	6565                	lui	a0,0x19
     222:	0521                	addi	a0,a0,8
     224:	00001097          	auipc	ra,0x1
     228:	0a4080e7          	jalr	164(ra) # 12c8 <sbrk>
     22c:	84aa                	mv	s1,a0
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     22e:	87aa                	mv	a5,a0
     230:	6719                	lui	a4,0x6
     232:	40070713          	addi	a4,a4,1024 # 6400 <__global_pointer$+0x3c2f>
            memory_pointer[i]=i;
     236:	0127a023          	sw	s2,0(a5)
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     23a:	2905                	addiw	s2,s2,1
     23c:	0791                	addi	a5,a5,4
     23e:	fee91ce3          	bne	s2,a4,236 <sbrk_not_multiply_of_PGSIZE+0x96>
        memory_pointer[i+40]= 40;
     242:	67e5                	lui	a5,0x19
     244:	94be                	add	s1,s1,a5
     246:	02800793          	li	a5,40
     24a:	0af4a023          	sw	a5,160(s1)
        printf("finished alloc with sbrk and set values\n");
     24e:	00001517          	auipc	a0,0x1
     252:	61250513          	addi	a0,a0,1554 # 1860 <malloc+0x1e2>
     256:	00001097          	auipc	ra,0x1
     25a:	36a080e7          	jalr	874(ra) # 15c0 <printf>
        printf("memory_pointer[sbrk(PGSIZE*num)+7]=%d    \n",memory_pointer[i-1]);
     25e:	ffc4a583          	lw	a1,-4(s1)
     262:	00001517          	auipc	a0,0x1
     266:	63e50513          	addi	a0,a0,1598 # 18a0 <malloc+0x222>
     26a:	00001097          	auipc	ra,0x1
     26e:	356080e7          	jalr	854(ra) # 15c0 <printf>
        printf("memory_pointer[sbrk(PGSIZE*num)+3]=%d    \n",memory_pointer[i-2]);
     272:	ff84a583          	lw	a1,-8(s1)
     276:	00001517          	auipc	a0,0x1
     27a:	65a50513          	addi	a0,a0,1626 # 18d0 <malloc+0x252>
     27e:	00001097          	auipc	ra,0x1
     282:	342080e7          	jalr	834(ra) # 15c0 <printf>
        printf("memory_pointer[sbrk(PGSIZE*num)+13]=%d    \n",memory_pointer[i+1]);
     286:	40cc                	lw	a1,4(s1)
     288:	00001517          	auipc	a0,0x1
     28c:	67850513          	addi	a0,a0,1656 # 1900 <malloc+0x282>
     290:	00001097          	auipc	ra,0x1
     294:	330080e7          	jalr	816(ra) # 15c0 <printf>
        sbrk(-PGSIZE*num);
     298:	751d                	lui	a0,0xfffe7
     29a:	00001097          	auipc	ra,0x1
     29e:	02e080e7          	jalr	46(ra) # 12c8 <sbrk>
        printf("finished free\n");
     2a2:	00001517          	auipc	a0,0x1
     2a6:	5ee50513          	addi	a0,a0,1518 # 1890 <malloc+0x212>
     2aa:	00001097          	auipc	ra,0x1
     2ae:	316080e7          	jalr	790(ra) # 15c0 <printf>
        pgf = setAndGetPageFaultsNum(-1);
     2b2:	557d                	li	a0,-1
     2b4:	00001097          	auipc	ra,0x1
     2b8:	02c080e7          	jalr	44(ra) # 12e0 <setAndGetPageFaultsNum>
     2bc:	fca42e23          	sw	a0,-36(s0)
        exit(pgf);
     2c0:	00001097          	auipc	ra,0x1
     2c4:	f80080e7          	jalr	-128(ra) # 1240 <exit>

00000000000002c8 <sbrk_test_father>:


void sbrk_test_father(char* test_name){
     2c8:	1101                	addi	sp,sp,-32
     2ca:	ec06                	sd	ra,24(sp)
     2cc:	e822                	sd	s0,16(sp)
     2ce:	e426                	sd	s1,8(sp)
     2d0:	1000                	addi	s0,sp,32
     2d2:	84aa                	mv	s1,a0
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
     2d4:	4501                	li	a0,0
     2d6:	00001097          	auipc	ra,0x1
     2da:	00a080e7          	jalr	10(ra) # 12e0 <setAndGetPageFaultsNum>
    PRINT_START(test_name);
     2de:	85a6                	mv	a1,s1
     2e0:	00001517          	auipc	a0,0x1
     2e4:	48850513          	addi	a0,a0,1160 # 1768 <malloc+0xea>
     2e8:	00001097          	auipc	ra,0x1
     2ec:	2d8080e7          	jalr	728(ra) # 15c0 <printf>
    int i=0;
    int pgf =0;
    int num = 25;
    int * memory_pointer = (int*)(sbrk(PGSIZE*num));
     2f0:	6565                	lui	a0,0x19
     2f2:	00001097          	auipc	ra,0x1
     2f6:	fd6080e7          	jalr	-42(ra) # 12c8 <sbrk>
    for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     2fa:	67e5                	lui	a5,0x19
     2fc:	97aa                	add	a5,a5,a0
        memory_pointer[i]=0;
     2fe:	00052023          	sw	zero,0(a0) # 19000 <__global_pointer$+0x1682f>
    for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     302:	0511                	addi	a0,a0,4
     304:	fef51de3          	bne	a0,a5,2fe <sbrk_test_father+0x36>
    }
    printf("finished alloc with sbrk and set values\n");
     308:	00001517          	auipc	a0,0x1
     30c:	55850513          	addi	a0,a0,1368 # 1860 <malloc+0x1e2>
     310:	00001097          	auipc	ra,0x1
     314:	2b0080e7          	jalr	688(ra) # 15c0 <printf>
    sbrk(-PGSIZE*num);
     318:	751d                	lui	a0,0xfffe7
     31a:	00001097          	auipc	ra,0x1
     31e:	fae080e7          	jalr	-82(ra) # 12c8 <sbrk>
    printf("finished free\n");
     322:	00001517          	auipc	a0,0x1
     326:	56e50513          	addi	a0,a0,1390 # 1890 <malloc+0x212>
     32a:	00001097          	auipc	ra,0x1
     32e:	296080e7          	jalr	662(ra) # 15c0 <printf>
    pgf= setAndGetPageFaultsNum(0);
     332:	4501                	li	a0,0
     334:	00001097          	auipc	ra,0x1
     338:	fac080e7          	jalr	-84(ra) # 12e0 <setAndGetPageFaultsNum>
     33c:	862a                	mv	a2,a0
    test_name_array[2] = test_name;
     33e:	00002797          	auipc	a5,0x2
     342:	caa78793          	addi	a5,a5,-854 # 1fe8 <test_name_array>
     346:	eb84                	sd	s1,16(a5)
    pgf_array[2] = pgf;
     348:	0aa7a423          	sw	a0,168(a5)
    sum_value= sum_value+pgf;
     34c:	00002717          	auipc	a4,0x2
     350:	c8c70713          	addi	a4,a4,-884 # 1fd8 <sum_value>
     354:	431c                	lw	a5,0(a4)
     356:	9fa9                	addw	a5,a5,a0
     358:	c31c                	sw	a5,0(a4)
    PRINT_END(test_name, pgf);
     35a:	85a6                	mv	a1,s1
     35c:	00001517          	auipc	a0,0x1
     360:	44450513          	addi	a0,a0,1092 # 17a0 <malloc+0x122>
     364:	00001097          	auipc	ra,0x1
     368:	25c080e7          	jalr	604(ra) # 15c0 <printf>
}
     36c:	60e2                	ld	ra,24(sp)
     36e:	6442                	ld	s0,16(sp)
     370:	64a2                	ld	s1,8(sp)
     372:	6105                	addi	sp,sp,32
     374:	8082                	ret

0000000000000376 <double_sbrk_test_son>:

void double_sbrk_test_son(char* test_name){
     376:	715d                	addi	sp,sp,-80
     378:	e486                	sd	ra,72(sp)
     37a:	e0a2                	sd	s0,64(sp)
     37c:	fc26                	sd	s1,56(sp)
     37e:	f84a                	sd	s2,48(sp)
     380:	f44e                	sd	s3,40(sp)
     382:	f052                	sd	s4,32(sp)
     384:	ec56                	sd	s5,24(sp)
     386:	0880                	addi	s0,sp,80
     388:	84aa                	mv	s1,a0
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
     38a:	4501                	li	a0,0
     38c:	00001097          	auipc	ra,0x1
     390:	f54080e7          	jalr	-172(ra) # 12e0 <setAndGetPageFaultsNum>
    PRINT_START(test_name);
     394:	85a6                	mv	a1,s1
     396:	00001517          	auipc	a0,0x1
     39a:	3d250513          	addi	a0,a0,978 # 1768 <malloc+0xea>
     39e:	00001097          	auipc	ra,0x1
     3a2:	222080e7          	jalr	546(ra) # 15c0 <printf>
    int pgf;
    int i=0;
    int num = 25;
    int cpid = fork();
     3a6:	00001097          	auipc	ra,0x1
     3aa:	e92080e7          	jalr	-366(ra) # 1238 <fork>
    if (cpid){//father
     3ae:	c929                	beqz	a0,400 <double_sbrk_test_son+0x8a>
        wait(&pgf);
     3b0:	fbc40513          	addi	a0,s0,-68
     3b4:	00001097          	auipc	ra,0x1
     3b8:	e94080e7          	jalr	-364(ra) # 1248 <wait>
        sbrk(-PGSIZE*num);
        pgf = setAndGetPageFaultsNum(-1);
        printf("finished second dealloc\n");
        exit(pgf);
    }
    test_name_array[3] = test_name;
     3bc:	00002797          	auipc	a5,0x2
     3c0:	c2c78793          	addi	a5,a5,-980 # 1fe8 <test_name_array>
     3c4:	ef84                	sd	s1,24(a5)
    pgf_array[3] = pgf;
     3c6:	fbc42603          	lw	a2,-68(s0)
     3ca:	0ac7a623          	sw	a2,172(a5)
    sum_value= sum_value+pgf;
     3ce:	00002717          	auipc	a4,0x2
     3d2:	c0a70713          	addi	a4,a4,-1014 # 1fd8 <sum_value>
     3d6:	431c                	lw	a5,0(a4)
     3d8:	9fb1                	addw	a5,a5,a2
     3da:	c31c                	sw	a5,0(a4)
    PRINT_END(test_name, pgf);
     3dc:	85a6                	mv	a1,s1
     3de:	00001517          	auipc	a0,0x1
     3e2:	3c250513          	addi	a0,a0,962 # 17a0 <malloc+0x122>
     3e6:	00001097          	auipc	ra,0x1
     3ea:	1da080e7          	jalr	474(ra) # 15c0 <printf>
}
     3ee:	60a6                	ld	ra,72(sp)
     3f0:	6406                	ld	s0,64(sp)
     3f2:	74e2                	ld	s1,56(sp)
     3f4:	7942                	ld	s2,48(sp)
     3f6:	79a2                	ld	s3,40(sp)
     3f8:	7a02                	ld	s4,32(sp)
     3fa:	6ae2                	ld	s5,24(sp)
     3fc:	6161                	addi	sp,sp,80
     3fe:	8082                	ret
     400:	892a                	mv	s2,a0
        int * memory_pointer = (int*)(sbrk(PGSIZE*num));
     402:	6565                	lui	a0,0x19
     404:	00001097          	auipc	ra,0x1
     408:	ec4080e7          	jalr	-316(ra) # 12c8 <sbrk>
     40c:	87aa                	mv	a5,a0
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     40e:	6765                	lui	a4,0x19
     410:	972a                	add	a4,a4,a0
            memory_pointer[i]=0;
     412:	0007a023          	sw	zero,0(a5)
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     416:	0791                	addi	a5,a5,4
     418:	fee79de3          	bne	a5,a4,412 <double_sbrk_test_son+0x9c>
        printf("finished first alloc and giving value\n");
     41c:	00001517          	auipc	a0,0x1
     420:	51450513          	addi	a0,a0,1300 # 1930 <malloc+0x2b2>
     424:	00001097          	auipc	ra,0x1
     428:	19c080e7          	jalr	412(ra) # 15c0 <printf>
        sbrk(-PGSIZE*num);
     42c:	751d                	lui	a0,0xfffe7
     42e:	00001097          	auipc	ra,0x1
     432:	e9a080e7          	jalr	-358(ra) # 12c8 <sbrk>
        printf("finished first dealloc\n");
     436:	00001517          	auipc	a0,0x1
     43a:	52250513          	addi	a0,a0,1314 # 1958 <malloc+0x2da>
     43e:	00001097          	auipc	ra,0x1
     442:	182080e7          	jalr	386(ra) # 15c0 <printf>
        memory_pointer = (int*)(sbrk(PGSIZE*num));
     446:	6565                	lui	a0,0x19
     448:	00001097          	auipc	ra,0x1
     44c:	e80080e7          	jalr	-384(ra) # 12c8 <sbrk>
     450:	84aa                	mv	s1,a0
     452:	872a                	mv	a4,a0
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     454:	87ca                	mv	a5,s2
     456:	6699                	lui	a3,0x6
     458:	40068693          	addi	a3,a3,1024 # 6400 <__global_pointer$+0x3c2f>
            memory_pointer[i]=i;
     45c:	c31c                	sw	a5,0(a4)
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     45e:	2785                	addiw	a5,a5,1
     460:	0711                	addi	a4,a4,4
     462:	fed79de3          	bne	a5,a3,45c <double_sbrk_test_son+0xe6>
            if(i % PGSIZE == 0){
     466:	6a05                	lui	s4,0x1
     468:	1a7d                	addi	s4,s4,-1
                printf("var in palce %d value is: %d\n",i, memory_pointer[i]);
     46a:	00001a97          	auipc	s5,0x1
     46e:	506a8a93          	addi	s5,s5,1286 # 1970 <malloc+0x2f2>
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     472:	6999                	lui	s3,0x6
     474:	40098993          	addi	s3,s3,1024 # 6400 <__global_pointer$+0x3c2f>
     478:	a029                	j	482 <double_sbrk_test_son+0x10c>
     47a:	2905                	addiw	s2,s2,1
     47c:	0491                	addi	s1,s1,4
     47e:	01390e63          	beq	s2,s3,49a <double_sbrk_test_son+0x124>
            if(i % PGSIZE == 0){
     482:	014977b3          	and	a5,s2,s4
     486:	2781                	sext.w	a5,a5
     488:	fbed                	bnez	a5,47a <double_sbrk_test_son+0x104>
                printf("var in palce %d value is: %d\n",i, memory_pointer[i]);
     48a:	4090                	lw	a2,0(s1)
     48c:	85ca                	mv	a1,s2
     48e:	8556                	mv	a0,s5
     490:	00001097          	auipc	ra,0x1
     494:	130080e7          	jalr	304(ra) # 15c0 <printf>
     498:	b7cd                	j	47a <double_sbrk_test_son+0x104>
        printf("finished second  alloc, giving values, and printing\n");
     49a:	00001517          	auipc	a0,0x1
     49e:	4f650513          	addi	a0,a0,1270 # 1990 <malloc+0x312>
     4a2:	00001097          	auipc	ra,0x1
     4a6:	11e080e7          	jalr	286(ra) # 15c0 <printf>
        sbrk(-PGSIZE*num);
     4aa:	751d                	lui	a0,0xfffe7
     4ac:	00001097          	auipc	ra,0x1
     4b0:	e1c080e7          	jalr	-484(ra) # 12c8 <sbrk>
        pgf = setAndGetPageFaultsNum(-1);
     4b4:	557d                	li	a0,-1
     4b6:	00001097          	auipc	ra,0x1
     4ba:	e2a080e7          	jalr	-470(ra) # 12e0 <setAndGetPageFaultsNum>
     4be:	faa42e23          	sw	a0,-68(s0)
        printf("finished second dealloc\n");
     4c2:	00001517          	auipc	a0,0x1
     4c6:	50650513          	addi	a0,a0,1286 # 19c8 <malloc+0x34a>
     4ca:	00001097          	auipc	ra,0x1
     4ce:	0f6080e7          	jalr	246(ra) # 15c0 <printf>
        exit(pgf);
     4d2:	fbc42503          	lw	a0,-68(s0)
     4d6:	00001097          	auipc	ra,0x1
     4da:	d6a080e7          	jalr	-662(ra) # 1240 <exit>

00000000000004de <complicated_sbrk>:

void complicated_sbrk(char* test_name){
     4de:	711d                	addi	sp,sp,-96
     4e0:	ec86                	sd	ra,88(sp)
     4e2:	e8a2                	sd	s0,80(sp)
     4e4:	e4a6                	sd	s1,72(sp)
     4e6:	e0ca                	sd	s2,64(sp)
     4e8:	fc4e                	sd	s3,56(sp)
     4ea:	f852                	sd	s4,48(sp)
     4ec:	f456                	sd	s5,40(sp)
     4ee:	f05a                	sd	s6,32(sp)
     4f0:	ec5e                	sd	s7,24(sp)
     4f2:	1080                	addi	s0,sp,96
     4f4:	84aa                	mv	s1,a0
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
     4f6:	4501                	li	a0,0
     4f8:	00001097          	auipc	ra,0x1
     4fc:	de8080e7          	jalr	-536(ra) # 12e0 <setAndGetPageFaultsNum>
    PRINT_START(test_name);
     500:	85a6                	mv	a1,s1
     502:	00001517          	auipc	a0,0x1
     506:	26650513          	addi	a0,a0,614 # 1768 <malloc+0xea>
     50a:	00001097          	auipc	ra,0x1
     50e:	0b6080e7          	jalr	182(ra) # 15c0 <printf>
    int pgf;
    int i=0;
    int num = 20;
    int cpid = fork();
     512:	00001097          	auipc	ra,0x1
     516:	d26080e7          	jalr	-730(ra) # 1238 <fork>
    if (cpid){//father
     51a:	c939                	beqz	a0,570 <complicated_sbrk+0x92>
        wait(&pgf);
     51c:	fac40513          	addi	a0,s0,-84
     520:	00001097          	auipc	ra,0x1
     524:	d28080e7          	jalr	-728(ra) # 1248 <wait>
            printf("chiled deallocated\n");
            sonAndGrandPgf = sonAndGrandPgf + setAndGetPageFaultsNum(-1);
            exit(sonAndGrandPgf);
        } 
    }
    test_name_array[4] = test_name;
     528:	00002797          	auipc	a5,0x2
     52c:	ac078793          	addi	a5,a5,-1344 # 1fe8 <test_name_array>
     530:	f384                	sd	s1,32(a5)
    pgf_array[4] = pgf;
     532:	fac42603          	lw	a2,-84(s0)
     536:	0ac7a823          	sw	a2,176(a5)
    sum_value= sum_value+pgf;
     53a:	00002717          	auipc	a4,0x2
     53e:	a9e70713          	addi	a4,a4,-1378 # 1fd8 <sum_value>
     542:	431c                	lw	a5,0(a4)
     544:	9fb1                	addw	a5,a5,a2
     546:	c31c                	sw	a5,0(a4)
    PRINT_END(test_name, pgf);
     548:	85a6                	mv	a1,s1
     54a:	00001517          	auipc	a0,0x1
     54e:	25650513          	addi	a0,a0,598 # 17a0 <malloc+0x122>
     552:	00001097          	auipc	ra,0x1
     556:	06e080e7          	jalr	110(ra) # 15c0 <printf>
}
     55a:	60e6                	ld	ra,88(sp)
     55c:	6446                	ld	s0,80(sp)
     55e:	64a6                	ld	s1,72(sp)
     560:	6906                	ld	s2,64(sp)
     562:	79e2                	ld	s3,56(sp)
     564:	7a42                	ld	s4,48(sp)
     566:	7aa2                	ld	s5,40(sp)
     568:	7b02                	ld	s6,32(sp)
     56a:	6be2                	ld	s7,24(sp)
     56c:	6125                	addi	sp,sp,96
     56e:	8082                	ret
     570:	89aa                	mv	s3,a0
        int sonAndGrandPgf=0;
     572:	fa042423          	sw	zero,-88(s0)
        int * memory_pointer = (int*)(sbrk(PGSIZE*num));
     576:	6551                	lui	a0,0x14
     578:	00001097          	auipc	ra,0x1
     57c:	d50080e7          	jalr	-688(ra) # 12c8 <sbrk>
     580:	892a                	mv	s2,a0
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     582:	6ad1                	lui	s5,0x14
     584:	9aaa                	add	s5,s5,a0
        int * memory_pointer = (int*)(sbrk(PGSIZE*num));
     586:	87aa                	mv	a5,a0
            memory_pointer[i]=30;
     588:	4779                	li	a4,30
     58a:	c398                	sw	a4,0(a5)
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     58c:	0791                	addi	a5,a5,4
     58e:	ff579ee3          	bne	a5,s5,58a <complicated_sbrk+0xac>
     592:	8a4a                	mv	s4,s2
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     594:	84ce                	mv	s1,s3
                printf("num %d: memory_pointer[i]=%d\n", i*4/PGSIZE, memory_pointer[i]);
     596:	00001b97          	auipc	s7,0x1
     59a:	452b8b93          	addi	s7,s7,1106 # 19e8 <malloc+0x36a>
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     59e:	6b15                	lui	s6,0x5
     5a0:	a029                	j	5aa <complicated_sbrk+0xcc>
     5a2:	2485                	addiw	s1,s1,1
     5a4:	0a11                	addi	s4,s4,4
     5a6:	03648463          	beq	s1,s6,5ce <complicated_sbrk+0xf0>
            if(i%(PGSIZE/sizeof(int)) == 0)
     5aa:	3ff4f793          	andi	a5,s1,1023
     5ae:	fbf5                	bnez	a5,5a2 <complicated_sbrk+0xc4>
                printf("num %d: memory_pointer[i]=%d\n", i*4/PGSIZE, memory_pointer[i]);
     5b0:	41f4d59b          	sraiw	a1,s1,0x1f
     5b4:	0165d59b          	srliw	a1,a1,0x16
     5b8:	9da5                	addw	a1,a1,s1
     5ba:	000a2603          	lw	a2,0(s4) # 1000 <strcmp+0x12>
     5be:	40a5d59b          	sraiw	a1,a1,0xa
     5c2:	855e                	mv	a0,s7
     5c4:	00001097          	auipc	ra,0x1
     5c8:	ffc080e7          	jalr	-4(ra) # 15c0 <printf>
     5cc:	bfd9                	j	5a2 <complicated_sbrk+0xc4>
        printf("finished first alloc and giving value\n");
     5ce:	00001517          	auipc	a0,0x1
     5d2:	36250513          	addi	a0,a0,866 # 1930 <malloc+0x2b2>
     5d6:	00001097          	auipc	ra,0x1
     5da:	fea080e7          	jalr	-22(ra) # 15c0 <printf>
        int cpid2 = fork();
     5de:	00001097          	auipc	ra,0x1
     5e2:	c5a080e7          	jalr	-934(ra) # 1238 <fork>
     5e6:	84aa                	mv	s1,a0
        printf("finished second fork\n");
     5e8:	00001517          	auipc	a0,0x1
     5ec:	42050513          	addi	a0,a0,1056 # 1a08 <malloc+0x38a>
     5f0:	00001097          	auipc	ra,0x1
     5f4:	fd0080e7          	jalr	-48(ra) # 15c0 <printf>
        if (!cpid2){//grandchild
     5f8:	10049963          	bnez	s1,70a <complicated_sbrk+0x22c>
            printf("grandchild prints values got from son:\n");
     5fc:	00001517          	auipc	a0,0x1
     600:	42450513          	addi	a0,a0,1060 # 1a20 <malloc+0x3a2>
     604:	00001097          	auipc	ra,0x1
     608:	fbc080e7          	jalr	-68(ra) # 15c0 <printf>
     60c:	8a4a                	mv	s4,s2
            for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     60e:	89a6                	mv	s3,s1
                    printf("num %d: memory_pointer[i]=%d\n", i*4/PGSIZE, memory_pointer[i]);
     610:	00001b97          	auipc	s7,0x1
     614:	3d8b8b93          	addi	s7,s7,984 # 19e8 <malloc+0x36a>
            for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     618:	6b15                	lui	s6,0x5
     61a:	a029                	j	624 <complicated_sbrk+0x146>
     61c:	2985                	addiw	s3,s3,1
     61e:	0a11                	addi	s4,s4,4
     620:	03698563          	beq	s3,s6,64a <complicated_sbrk+0x16c>
                if(i%(PGSIZE/sizeof(int)) == 0)
     624:	3ff9f793          	andi	a5,s3,1023
     628:	fbf5                	bnez	a5,61c <complicated_sbrk+0x13e>
                    printf("num %d: memory_pointer[i]=%d\n", i*4/PGSIZE, memory_pointer[i]);
     62a:	41f9d59b          	sraiw	a1,s3,0x1f
     62e:	0165d59b          	srliw	a1,a1,0x16
     632:	013585bb          	addw	a1,a1,s3
     636:	000a2603          	lw	a2,0(s4)
     63a:	40a5d59b          	sraiw	a1,a1,0xa
     63e:	855e                	mv	a0,s7
     640:	00001097          	auipc	ra,0x1
     644:	f80080e7          	jalr	-128(ra) # 15c0 <printf>
     648:	bfd1                	j	61c <complicated_sbrk+0x13e>
            printf("grandchild about to reassign values\n");
     64a:	00001517          	auipc	a0,0x1
     64e:	3fe50513          	addi	a0,a0,1022 # 1a48 <malloc+0x3ca>
     652:	00001097          	auipc	ra,0x1
     656:	f6e080e7          	jalr	-146(ra) # 15c0 <printf>
     65a:	87ca                	mv	a5,s2
                memory_pointer[i]=12;
     65c:	4731                	li	a4,12
     65e:	c398                	sw	a4,0(a5)
            for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     660:	0791                	addi	a5,a5,4
     662:	ff579ee3          	bne	a5,s5,65e <complicated_sbrk+0x180>
     666:	89ca                	mv	s3,s2
                    printf("num %d: memory_pointer[i]=%d\n", i*4/PGSIZE, memory_pointer[i]);
     668:	00001b17          	auipc	s6,0x1
     66c:	380b0b13          	addi	s6,s6,896 # 19e8 <malloc+0x36a>
            for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     670:	6a15                	lui	s4,0x5
     672:	a029                	j	67c <complicated_sbrk+0x19e>
     674:	2485                	addiw	s1,s1,1
     676:	0991                	addi	s3,s3,4
     678:	03448463          	beq	s1,s4,6a0 <complicated_sbrk+0x1c2>
                if(i%(PGSIZE/sizeof(int)) == 0)
     67c:	3ff4f793          	andi	a5,s1,1023
     680:	fbf5                	bnez	a5,674 <complicated_sbrk+0x196>
                    printf("num %d: memory_pointer[i]=%d\n", i*4/PGSIZE, memory_pointer[i]);
     682:	41f4d59b          	sraiw	a1,s1,0x1f
     686:	0165d59b          	srliw	a1,a1,0x16
     68a:	9da5                	addw	a1,a1,s1
     68c:	0009a603          	lw	a2,0(s3)
     690:	40a5d59b          	sraiw	a1,a1,0xa
     694:	855a                	mv	a0,s6
     696:	00001097          	auipc	ra,0x1
     69a:	f2a080e7          	jalr	-214(ra) # 15c0 <printf>
     69e:	bfd9                	j	674 <complicated_sbrk+0x196>
            printf("\ngrandchild about to deallocate the %d pages that were allocated by his parent and inherited to child\n", num);
     6a0:	45d1                	li	a1,20
     6a2:	00001517          	auipc	a0,0x1
     6a6:	3ce50513          	addi	a0,a0,974 # 1a70 <malloc+0x3f2>
     6aa:	00001097          	auipc	ra,0x1
     6ae:	f16080e7          	jalr	-234(ra) # 15c0 <printf>
            sbrk(-PGSIZE*num);
     6b2:	7531                	lui	a0,0xfffec
     6b4:	00001097          	auipc	ra,0x1
     6b8:	c14080e7          	jalr	-1004(ra) # 12c8 <sbrk>
            printf("granchiled deallocated successfully => inheritance works fine\n");
     6bc:	00001517          	auipc	a0,0x1
     6c0:	41c50513          	addi	a0,a0,1052 # 1ad8 <malloc+0x45a>
     6c4:	00001097          	auipc	ra,0x1
     6c8:	efc080e7          	jalr	-260(ra) # 15c0 <printf>
            printf("about to access memory we deallocated and therefore results in segmentation fault\n");
     6cc:	00001517          	auipc	a0,0x1
     6d0:	44c50513          	addi	a0,a0,1100 # 1b18 <malloc+0x49a>
     6d4:	00001097          	auipc	ra,0x1
     6d8:	eec080e7          	jalr	-276(ra) # 15c0 <printf>
                memory_pointer[i]=1;
     6dc:	4785                	li	a5,1
     6de:	00f92023          	sw	a5,0(s2)
            for (i=0; i<PGSIZE*num/sizeof(int); i++){
     6e2:	0911                	addi	s2,s2,4
     6e4:	ff591de3          	bne	s2,s5,6de <complicated_sbrk+0x200>
            printf("if we print this its bad! -> means we didn't really dealloc the pages\n");
     6e8:	00001517          	auipc	a0,0x1
     6ec:	48850513          	addi	a0,a0,1160 # 1b70 <malloc+0x4f2>
     6f0:	00001097          	auipc	ra,0x1
     6f4:	ed0080e7          	jalr	-304(ra) # 15c0 <printf>
            int pgf2 = setAndGetPageFaultsNum(-1);
     6f8:	557d                	li	a0,-1
     6fa:	00001097          	auipc	ra,0x1
     6fe:	be6080e7          	jalr	-1050(ra) # 12e0 <setAndGetPageFaultsNum>
            exit(pgf2); //to keep track of total num of page faults
     702:	00001097          	auipc	ra,0x1
     706:	b3e080e7          	jalr	-1218(ra) # 1240 <exit>
            wait(&sonAndGrandPgf);
     70a:	fa840513          	addi	a0,s0,-88
     70e:	00001097          	auipc	ra,0x1
     712:	b3a080e7          	jalr	-1222(ra) # 1248 <wait>
            printf("child about to print values and make sure grandchild did not change them, \nwhich means it should not be 12\n");
     716:	00001517          	auipc	a0,0x1
     71a:	4a250513          	addi	a0,a0,1186 # 1bb8 <malloc+0x53a>
     71e:	00001097          	auipc	ra,0x1
     722:	ea2080e7          	jalr	-350(ra) # 15c0 <printf>
                    printf("num %d: memory_pointer[i]=%d\n", i*4/PGSIZE, memory_pointer[i]);
     726:	00001a17          	auipc	s4,0x1
     72a:	2c2a0a13          	addi	s4,s4,706 # 19e8 <malloc+0x36a>
            for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     72e:	6495                	lui	s1,0x5
     730:	a029                	j	73a <complicated_sbrk+0x25c>
     732:	2985                	addiw	s3,s3,1
     734:	0911                	addi	s2,s2,4
     736:	02998563          	beq	s3,s1,760 <complicated_sbrk+0x282>
                if(i%(PGSIZE/sizeof(int)) == 0)
     73a:	3ff9f793          	andi	a5,s3,1023
     73e:	fbf5                	bnez	a5,732 <complicated_sbrk+0x254>
                    printf("num %d: memory_pointer[i]=%d\n", i*4/PGSIZE, memory_pointer[i]);
     740:	41f9d59b          	sraiw	a1,s3,0x1f
     744:	0165d59b          	srliw	a1,a1,0x16
     748:	013585bb          	addw	a1,a1,s3
     74c:	00092603          	lw	a2,0(s2)
     750:	40a5d59b          	sraiw	a1,a1,0xa
     754:	8552                	mv	a0,s4
     756:	00001097          	auipc	ra,0x1
     75a:	e6a080e7          	jalr	-406(ra) # 15c0 <printf>
     75e:	bfd1                	j	732 <complicated_sbrk+0x254>
            sbrk(-PGSIZE*num);
     760:	7531                	lui	a0,0xfffec
     762:	00001097          	auipc	ra,0x1
     766:	b66080e7          	jalr	-1178(ra) # 12c8 <sbrk>
            printf("chiled deallocated\n");
     76a:	00001517          	auipc	a0,0x1
     76e:	4be50513          	addi	a0,a0,1214 # 1c28 <malloc+0x5aa>
     772:	00001097          	auipc	ra,0x1
     776:	e4e080e7          	jalr	-434(ra) # 15c0 <printf>
            sonAndGrandPgf = sonAndGrandPgf + setAndGetPageFaultsNum(-1);
     77a:	557d                	li	a0,-1
     77c:	00001097          	auipc	ra,0x1
     780:	b64080e7          	jalr	-1180(ra) # 12e0 <setAndGetPageFaultsNum>
     784:	fa842783          	lw	a5,-88(s0)
     788:	9d3d                	addw	a0,a0,a5
     78a:	faa42423          	sw	a0,-88(s0)
            exit(sonAndGrandPgf);
     78e:	2501                	sext.w	a0,a0
     790:	00001097          	auipc	ra,0x1
     794:	ab0080e7          	jalr	-1360(ra) # 1240 <exit>

0000000000000798 <maxpages_switch>:

void maxpages_switch(char* test_name){ 
     798:	7179                	addi	sp,sp,-48
     79a:	f406                	sd	ra,40(sp)
     79c:	f022                	sd	s0,32(sp)
     79e:	ec26                	sd	s1,24(sp)
     7a0:	1800                	addi	s0,sp,48
     7a2:	84aa                	mv	s1,a0
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
     7a4:	4501                	li	a0,0
     7a6:	00001097          	auipc	ra,0x1
     7aa:	b3a080e7          	jalr	-1222(ra) # 12e0 <setAndGetPageFaultsNum>
    PRINT_START(test_name);
     7ae:	85a6                	mv	a1,s1
     7b0:	00001517          	auipc	a0,0x1
     7b4:	fb850513          	addi	a0,a0,-72 # 1768 <malloc+0xea>
     7b8:	00001097          	auipc	ra,0x1
     7bc:	e08080e7          	jalr	-504(ra) # 15c0 <printf>
    int pgf;
    int i=0;
    int num=28; 
    int cpid = fork();
     7c0:	00001097          	auipc	ra,0x1
     7c4:	a78080e7          	jalr	-1416(ra) # 1238 <fork>
    if (cpid){//father
     7c8:	c529                	beqz	a0,812 <maxpages_switch+0x7a>
        wait(&pgf);
     7ca:	fdc40513          	addi	a0,s0,-36
     7ce:	00001097          	auipc	ra,0x1
     7d2:	a7a080e7          	jalr	-1414(ra) # 1248 <wait>
        sbrk(-PGSIZE*num);
        printf("finished free\n");
        pgf = setAndGetPageFaultsNum(-1);
        exit(pgf);
    }
    test_name_array[5] = test_name;
     7d6:	00002797          	auipc	a5,0x2
     7da:	81278793          	addi	a5,a5,-2030 # 1fe8 <test_name_array>
     7de:	f784                	sd	s1,40(a5)
    pgf_array[5] = pgf;
     7e0:	fdc42603          	lw	a2,-36(s0)
     7e4:	0ac7aa23          	sw	a2,180(a5)
    sum_value= sum_value+pgf;
     7e8:	00001717          	auipc	a4,0x1
     7ec:	7f070713          	addi	a4,a4,2032 # 1fd8 <sum_value>
     7f0:	431c                	lw	a5,0(a4)
     7f2:	9fb1                	addw	a5,a5,a2
     7f4:	c31c                	sw	a5,0(a4)
    PRINT_END(test_name, pgf);
     7f6:	85a6                	mv	a1,s1
     7f8:	00001517          	auipc	a0,0x1
     7fc:	fa850513          	addi	a0,a0,-88 # 17a0 <malloc+0x122>
     800:	00001097          	auipc	ra,0x1
     804:	dc0080e7          	jalr	-576(ra) # 15c0 <printf>
}
     808:	70a2                	ld	ra,40(sp)
     80a:	7402                	ld	s0,32(sp)
     80c:	64e2                	ld	s1,24(sp)
     80e:	6145                	addi	sp,sp,48
     810:	8082                	ret
        int * memory_pointer = (int*)(sbrk(PGSIZE*num));
     812:	6571                	lui	a0,0x1c
     814:	00001097          	auipc	ra,0x1
     818:	ab4080e7          	jalr	-1356(ra) # 12c8 <sbrk>
     81c:	87aa                	mv	a5,a0
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     81e:	6771                	lui	a4,0x1c
     820:	972a                	add	a4,a4,a0
            memory_pointer[i]=0;
     822:	0007a023          	sw	zero,0(a5)
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     826:	0791                	addi	a5,a5,4
     828:	fee79de3          	bne	a5,a4,822 <maxpages_switch+0x8a>
        printf("finished alloc with sbrk and set values\n");
     82c:	00001517          	auipc	a0,0x1
     830:	03450513          	addi	a0,a0,52 # 1860 <malloc+0x1e2>
     834:	00001097          	auipc	ra,0x1
     838:	d8c080e7          	jalr	-628(ra) # 15c0 <printf>
        sbrk(-PGSIZE*num);
     83c:	7511                	lui	a0,0xfffe4
     83e:	00001097          	auipc	ra,0x1
     842:	a8a080e7          	jalr	-1398(ra) # 12c8 <sbrk>
        printf("finished free\n");
     846:	00001517          	auipc	a0,0x1
     84a:	04a50513          	addi	a0,a0,74 # 1890 <malloc+0x212>
     84e:	00001097          	auipc	ra,0x1
     852:	d72080e7          	jalr	-654(ra) # 15c0 <printf>
        pgf = setAndGetPageFaultsNum(-1);
     856:	557d                	li	a0,-1
     858:	00001097          	auipc	ra,0x1
     85c:	a88080e7          	jalr	-1400(ra) # 12e0 <setAndGetPageFaultsNum>
     860:	fca42e23          	sw	a0,-36(s0)
        exit(pgf);
     864:	00001097          	auipc	ra,0x1
     868:	9dc080e7          	jalr	-1572(ra) # 1240 <exit>

000000000000086c <malloc_test_simple>:

void malloc_test_simple(char* test_name){ 
     86c:	7179                	addi	sp,sp,-48
     86e:	f406                	sd	ra,40(sp)
     870:	f022                	sd	s0,32(sp)
     872:	ec26                	sd	s1,24(sp)
     874:	1800                	addi	s0,sp,48
     876:	84aa                	mv	s1,a0
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
     878:	4501                	li	a0,0
     87a:	00001097          	auipc	ra,0x1
     87e:	a66080e7          	jalr	-1434(ra) # 12e0 <setAndGetPageFaultsNum>
    PRINT_START(test_name);
     882:	85a6                	mv	a1,s1
     884:	00001517          	auipc	a0,0x1
     888:	ee450513          	addi	a0,a0,-284 # 1768 <malloc+0xea>
     88c:	00001097          	auipc	ra,0x1
     890:	d34080e7          	jalr	-716(ra) # 15c0 <printf>
    int pgf;
    int i=0;
    int num=20;
    int cpid = fork();
     894:	00001097          	auipc	ra,0x1
     898:	9a4080e7          	jalr	-1628(ra) # 1238 <fork>
    if (cpid){//father
     89c:	c529                	beqz	a0,8e6 <malloc_test_simple+0x7a>
        wait(&pgf);
     89e:	fdc40513          	addi	a0,s0,-36
     8a2:	00001097          	auipc	ra,0x1
     8a6:	9a6080e7          	jalr	-1626(ra) # 1248 <wait>
        free(memory_pointer);
        printf("finished free\n");
        pgf = setAndGetPageFaultsNum(-1);
        exit(pgf);
    }
    test_name_array[6] = test_name;
     8aa:	00001797          	auipc	a5,0x1
     8ae:	73e78793          	addi	a5,a5,1854 # 1fe8 <test_name_array>
     8b2:	fb84                	sd	s1,48(a5)
    pgf_array[6] = pgf;
     8b4:	fdc42603          	lw	a2,-36(s0)
     8b8:	0ac7ac23          	sw	a2,184(a5)
    sum_value= sum_value+pgf;
     8bc:	00001717          	auipc	a4,0x1
     8c0:	71c70713          	addi	a4,a4,1820 # 1fd8 <sum_value>
     8c4:	431c                	lw	a5,0(a4)
     8c6:	9fb1                	addw	a5,a5,a2
     8c8:	c31c                	sw	a5,0(a4)
    PRINT_END(test_name, pgf);
     8ca:	85a6                	mv	a1,s1
     8cc:	00001517          	auipc	a0,0x1
     8d0:	ed450513          	addi	a0,a0,-300 # 17a0 <malloc+0x122>
     8d4:	00001097          	auipc	ra,0x1
     8d8:	cec080e7          	jalr	-788(ra) # 15c0 <printf>
}
     8dc:	70a2                	ld	ra,40(sp)
     8de:	7402                	ld	s0,32(sp)
     8e0:	64e2                	ld	s1,24(sp)
     8e2:	6145                	addi	sp,sp,48
     8e4:	8082                	ret
        int * memory_pointer = (int*)(malloc(PGSIZE*num));
     8e6:	6551                	lui	a0,0x14
     8e8:	00001097          	auipc	ra,0x1
     8ec:	d96080e7          	jalr	-618(ra) # 167e <malloc>
     8f0:	84aa                	mv	s1,a0
        printf("finished alloc with malloc\n");
     8f2:	00001517          	auipc	a0,0x1
     8f6:	34e50513          	addi	a0,a0,846 # 1c40 <malloc+0x5c2>
     8fa:	00001097          	auipc	ra,0x1
     8fe:	cc6080e7          	jalr	-826(ra) # 15c0 <printf>
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     902:	87a6                	mv	a5,s1
     904:	6751                	lui	a4,0x14
     906:	9726                	add	a4,a4,s1
            memory_pointer[i]=3;
     908:	468d                	li	a3,3
     90a:	c394                	sw	a3,0(a5)
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     90c:	0791                	addi	a5,a5,4
     90e:	fee79ee3          	bne	a5,a4,90a <malloc_test_simple+0x9e>
        printf("\nfinished set values\n");
     912:	00001517          	auipc	a0,0x1
     916:	34e50513          	addi	a0,a0,846 # 1c60 <malloc+0x5e2>
     91a:	00001097          	auipc	ra,0x1
     91e:	ca6080e7          	jalr	-858(ra) # 15c0 <printf>
        free(memory_pointer);
     922:	8526                	mv	a0,s1
     924:	00001097          	auipc	ra,0x1
     928:	cd2080e7          	jalr	-814(ra) # 15f6 <free>
        printf("finished free\n");
     92c:	00001517          	auipc	a0,0x1
     930:	f6450513          	addi	a0,a0,-156 # 1890 <malloc+0x212>
     934:	00001097          	auipc	ra,0x1
     938:	c8c080e7          	jalr	-884(ra) # 15c0 <printf>
        pgf = setAndGetPageFaultsNum(-1);
     93c:	557d                	li	a0,-1
     93e:	00001097          	auipc	ra,0x1
     942:	9a2080e7          	jalr	-1630(ra) # 12e0 <setAndGetPageFaultsNum>
     946:	fca42e23          	sw	a0,-36(s0)
        exit(pgf);
     94a:	00001097          	auipc	ra,0x1
     94e:	8f6080e7          	jalr	-1802(ra) # 1240 <exit>

0000000000000952 <malloc_test_not_multiply_of_PGSIZE>:

void malloc_test_not_multiply_of_PGSIZE(char* test_name){ 
     952:	7179                	addi	sp,sp,-48
     954:	f406                	sd	ra,40(sp)
     956:	f022                	sd	s0,32(sp)
     958:	ec26                	sd	s1,24(sp)
     95a:	e84a                	sd	s2,16(sp)
     95c:	1800                	addi	s0,sp,48
     95e:	84aa                	mv	s1,a0
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
     960:	4501                	li	a0,0
     962:	00001097          	auipc	ra,0x1
     966:	97e080e7          	jalr	-1666(ra) # 12e0 <setAndGetPageFaultsNum>
    PRINT_START(test_name);
     96a:	85a6                	mv	a1,s1
     96c:	00001517          	auipc	a0,0x1
     970:	dfc50513          	addi	a0,a0,-516 # 1768 <malloc+0xea>
     974:	00001097          	auipc	ra,0x1
     978:	c4c080e7          	jalr	-948(ra) # 15c0 <printf>
    int pgf;
    int i=0;
    int num=20;
    int cpid = fork();
     97c:	00001097          	auipc	ra,0x1
     980:	8bc080e7          	jalr	-1860(ra) # 1238 <fork>
    if (cpid){//father
     984:	c531                	beqz	a0,9d0 <malloc_test_not_multiply_of_PGSIZE+0x7e>
        wait(&pgf);
     986:	fdc40513          	addi	a0,s0,-36
     98a:	00001097          	auipc	ra,0x1
     98e:	8be080e7          	jalr	-1858(ra) # 1248 <wait>
        free(memory_pointer);
        printf("finished free\n");
        pgf = setAndGetPageFaultsNum(-1);
        exit(pgf);
    }
    test_name_array[7] = test_name;
     992:	00001797          	auipc	a5,0x1
     996:	65678793          	addi	a5,a5,1622 # 1fe8 <test_name_array>
     99a:	ff84                	sd	s1,56(a5)
    pgf_array[7] = pgf;
     99c:	fdc42603          	lw	a2,-36(s0)
     9a0:	0ac7ae23          	sw	a2,188(a5)
    sum_value= sum_value+pgf;
     9a4:	00001717          	auipc	a4,0x1
     9a8:	63470713          	addi	a4,a4,1588 # 1fd8 <sum_value>
     9ac:	431c                	lw	a5,0(a4)
     9ae:	9fb1                	addw	a5,a5,a2
     9b0:	c31c                	sw	a5,0(a4)
    PRINT_END(test_name, pgf);
     9b2:	85a6                	mv	a1,s1
     9b4:	00001517          	auipc	a0,0x1
     9b8:	dec50513          	addi	a0,a0,-532 # 17a0 <malloc+0x122>
     9bc:	00001097          	auipc	ra,0x1
     9c0:	c04080e7          	jalr	-1020(ra) # 15c0 <printf>
}
     9c4:	70a2                	ld	ra,40(sp)
     9c6:	7402                	ld	s0,32(sp)
     9c8:	64e2                	ld	s1,24(sp)
     9ca:	6942                	ld	s2,16(sp)
     9cc:	6145                	addi	sp,sp,48
     9ce:	8082                	ret
        int * memory_pointer = (int*)(malloc(PGSIZE*num)+8);
     9d0:	6551                	lui	a0,0x14
     9d2:	00001097          	auipc	ra,0x1
     9d6:	cac080e7          	jalr	-852(ra) # 167e <malloc>
     9da:	84aa                	mv	s1,a0
     9dc:	00850913          	addi	s2,a0,8 # 14008 <__global_pointer$+0x11837>
        printf("finished alloc with malloc\n");
     9e0:	00001517          	auipc	a0,0x1
     9e4:	26050513          	addi	a0,a0,608 # 1c40 <malloc+0x5c2>
     9e8:	00001097          	auipc	ra,0x1
     9ec:	bd8080e7          	jalr	-1064(ra) # 15c0 <printf>
        for (i=0; i<PGSIZE*num/sizeof(int) +2; ++i){
     9f0:	87ca                	mv	a5,s2
     9f2:	6751                	lui	a4,0x14
     9f4:	0741                	addi	a4,a4,16
     9f6:	9726                	add	a4,a4,s1
            memory_pointer[i]=3;
     9f8:	468d                	li	a3,3
     9fa:	c394                	sw	a3,0(a5)
        for (i=0; i<PGSIZE*num/sizeof(int) +2; ++i){
     9fc:	0791                	addi	a5,a5,4
     9fe:	fee79ee3          	bne	a5,a4,9fa <malloc_test_not_multiply_of_PGSIZE+0xa8>
        printf("memory_pointer[malloc(PGSIZE*num)+7]=%d    ",memory_pointer[i-1]);
     a02:	67d1                	lui	a5,0x14
     a04:	94be                	add	s1,s1,a5
     a06:	44cc                	lw	a1,12(s1)
     a08:	00001517          	auipc	a0,0x1
     a0c:	27050513          	addi	a0,a0,624 # 1c78 <malloc+0x5fa>
     a10:	00001097          	auipc	ra,0x1
     a14:	bb0080e7          	jalr	-1104(ra) # 15c0 <printf>
        printf("memory_pointer[malloc(PGSIZE*num)+3]=%d    ",memory_pointer[i-2]);
     a18:	448c                	lw	a1,8(s1)
     a1a:	00001517          	auipc	a0,0x1
     a1e:	28e50513          	addi	a0,a0,654 # 1ca8 <malloc+0x62a>
     a22:	00001097          	auipc	ra,0x1
     a26:	b9e080e7          	jalr	-1122(ra) # 15c0 <printf>
        printf("\nfinished set values\n");
     a2a:	00001517          	auipc	a0,0x1
     a2e:	23650513          	addi	a0,a0,566 # 1c60 <malloc+0x5e2>
     a32:	00001097          	auipc	ra,0x1
     a36:	b8e080e7          	jalr	-1138(ra) # 15c0 <printf>
        free(memory_pointer);
     a3a:	854a                	mv	a0,s2
     a3c:	00001097          	auipc	ra,0x1
     a40:	bba080e7          	jalr	-1094(ra) # 15f6 <free>
        printf("finished free\n");
     a44:	00001517          	auipc	a0,0x1
     a48:	e4c50513          	addi	a0,a0,-436 # 1890 <malloc+0x212>
     a4c:	00001097          	auipc	ra,0x1
     a50:	b74080e7          	jalr	-1164(ra) # 15c0 <printf>
        pgf = setAndGetPageFaultsNum(-1);
     a54:	557d                	li	a0,-1
     a56:	00001097          	auipc	ra,0x1
     a5a:	88a080e7          	jalr	-1910(ra) # 12e0 <setAndGetPageFaultsNum>
     a5e:	fca42e23          	sw	a0,-36(s0)
        exit(pgf);
     a62:	00000097          	auipc	ra,0x0
     a66:	7de080e7          	jalr	2014(ra) # 1240 <exit>

0000000000000a6a <malloc_test_complicated>:

void malloc_test_complicated(char* test_name){ 
     a6a:	7179                	addi	sp,sp,-48
     a6c:	f406                	sd	ra,40(sp)
     a6e:	f022                	sd	s0,32(sp)
     a70:	ec26                	sd	s1,24(sp)
     a72:	e84a                	sd	s2,16(sp)
     a74:	1800                	addi	s0,sp,48
     a76:	892a                	mv	s2,a0
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
     a78:	4501                	li	a0,0
     a7a:	00001097          	auipc	ra,0x1
     a7e:	866080e7          	jalr	-1946(ra) # 12e0 <setAndGetPageFaultsNum>
    PRINT_START(test_name);
     a82:	85ca                	mv	a1,s2
     a84:	00001517          	auipc	a0,0x1
     a88:	ce450513          	addi	a0,a0,-796 # 1768 <malloc+0xea>
     a8c:	00001097          	auipc	ra,0x1
     a90:	b34080e7          	jalr	-1228(ra) # 15c0 <printf>
    int pgf;
    int i=0;
    int num = 25;
    int cpid = fork();
     a94:	00000097          	auipc	ra,0x0
     a98:	7a4080e7          	jalr	1956(ra) # 1238 <fork>
    if (cpid){//father
     a9c:	c539                	beqz	a0,aea <malloc_test_complicated+0x80>
        wait(&pgf);
     a9e:	fdc40513          	addi	a0,s0,-36
     aa2:	00000097          	auipc	ra,0x0
     aa6:	7a6080e7          	jalr	1958(ra) # 1248 <wait>
            //printf("chiled deallocated\n");
            sonAndGrandPgf = sonAndGrandPgf + setAndGetPageFaultsNum(-1);
            exit(sonAndGrandPgf);
        } 
    }
    test_name_array[8] = test_name;
     aaa:	00001797          	auipc	a5,0x1
     aae:	53e78793          	addi	a5,a5,1342 # 1fe8 <test_name_array>
     ab2:	0527b023          	sd	s2,64(a5)
    pgf_array[8] = pgf;
     ab6:	fdc42603          	lw	a2,-36(s0)
     aba:	0cc7a023          	sw	a2,192(a5)
    sum_value= sum_value+pgf;
     abe:	00001717          	auipc	a4,0x1
     ac2:	51a70713          	addi	a4,a4,1306 # 1fd8 <sum_value>
     ac6:	431c                	lw	a5,0(a4)
     ac8:	9fb1                	addw	a5,a5,a2
     aca:	c31c                	sw	a5,0(a4)
    PRINT_END(test_name, pgf);
     acc:	85ca                	mv	a1,s2
     ace:	00001517          	auipc	a0,0x1
     ad2:	cd250513          	addi	a0,a0,-814 # 17a0 <malloc+0x122>
     ad6:	00001097          	auipc	ra,0x1
     ada:	aea080e7          	jalr	-1302(ra) # 15c0 <printf>
}
     ade:	70a2                	ld	ra,40(sp)
     ae0:	7402                	ld	s0,32(sp)
     ae2:	64e2                	ld	s1,24(sp)
     ae4:	6942                	ld	s2,16(sp)
     ae6:	6145                	addi	sp,sp,48
     ae8:	8082                	ret
     aea:	84aa                	mv	s1,a0
        int sonAndGrandPgf=0;
     aec:	fc042c23          	sw	zero,-40(s0)
        int * memory_pointer = (int*)(malloc(PGSIZE*num));
     af0:	6565                	lui	a0,0x19
     af2:	00001097          	auipc	ra,0x1
     af6:	b8c080e7          	jalr	-1140(ra) # 167e <malloc>
     afa:	892a                	mv	s2,a0
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     afc:	87aa                	mv	a5,a0
     afe:	6719                	lui	a4,0x6
     b00:	40070713          	addi	a4,a4,1024 # 6400 <__global_pointer$+0x3c2f>
            memory_pointer[i]=i;
     b04:	c384                	sw	s1,0(a5)
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     b06:	2485                	addiw	s1,s1,1
     b08:	0791                	addi	a5,a5,4
     b0a:	fee49de3          	bne	s1,a4,b04 <malloc_test_complicated+0x9a>
        printf("finished first alloc and giving value\n");
     b0e:	00001517          	auipc	a0,0x1
     b12:	e2250513          	addi	a0,a0,-478 # 1930 <malloc+0x2b2>
     b16:	00001097          	auipc	ra,0x1
     b1a:	aaa080e7          	jalr	-1366(ra) # 15c0 <printf>
        int cpid2 = fork();
     b1e:	00000097          	auipc	ra,0x0
     b22:	71a080e7          	jalr	1818(ra) # 1238 <fork>
     b26:	84aa                	mv	s1,a0
        printf("finished second fork\n");
     b28:	00001517          	auipc	a0,0x1
     b2c:	ee050513          	addi	a0,a0,-288 # 1a08 <malloc+0x38a>
     b30:	00001097          	auipc	ra,0x1
     b34:	a90080e7          	jalr	-1392(ra) # 15c0 <printf>
        if (!cpid2){//grandchild
     b38:	e0a1                	bnez	s1,b78 <malloc_test_complicated+0x10e>
            printf("grandchild about to deallocatre the %d pages that were allocated by his parent and inherited to child\n", num);
     b3a:	45e5                	li	a1,25
     b3c:	00001517          	auipc	a0,0x1
     b40:	19c50513          	addi	a0,a0,412 # 1cd8 <malloc+0x65a>
     b44:	00001097          	auipc	ra,0x1
     b48:	a7c080e7          	jalr	-1412(ra) # 15c0 <printf>
            free(memory_pointer);
     b4c:	854a                	mv	a0,s2
     b4e:	00001097          	auipc	ra,0x1
     b52:	aa8080e7          	jalr	-1368(ra) # 15f6 <free>
            printf("granchiled deallocated successfully => inheritance works fine\n");
     b56:	00001517          	auipc	a0,0x1
     b5a:	f8250513          	addi	a0,a0,-126 # 1ad8 <malloc+0x45a>
     b5e:	00001097          	auipc	ra,0x1
     b62:	a62080e7          	jalr	-1438(ra) # 15c0 <printf>
            int pgf2 = setAndGetPageFaultsNum(-1);
     b66:	557d                	li	a0,-1
     b68:	00000097          	auipc	ra,0x0
     b6c:	778080e7          	jalr	1912(ra) # 12e0 <setAndGetPageFaultsNum>
            exit(pgf2); //to keep track of total num of page faults
     b70:	00000097          	auipc	ra,0x0
     b74:	6d0080e7          	jalr	1744(ra) # 1240 <exit>
            wait(&sonAndGrandPgf);
     b78:	fd840513          	addi	a0,s0,-40
     b7c:	00000097          	auipc	ra,0x0
     b80:	6cc080e7          	jalr	1740(ra) # 1248 <wait>
            free(memory_pointer);
     b84:	854a                	mv	a0,s2
     b86:	00001097          	auipc	ra,0x1
     b8a:	a70080e7          	jalr	-1424(ra) # 15f6 <free>
            sonAndGrandPgf = sonAndGrandPgf + setAndGetPageFaultsNum(-1);
     b8e:	557d                	li	a0,-1
     b90:	00000097          	auipc	ra,0x0
     b94:	750080e7          	jalr	1872(ra) # 12e0 <setAndGetPageFaultsNum>
     b98:	fd842783          	lw	a5,-40(s0)
     b9c:	9d3d                	addw	a0,a0,a5
     b9e:	fca42c23          	sw	a0,-40(s0)
            exit(sonAndGrandPgf);
     ba2:	2501                	sext.w	a0,a0
     ba4:	00000097          	auipc	ra,0x0
     ba8:	69c080e7          	jalr	1692(ra) # 1240 <exit>

0000000000000bac <test_goto_bad>:

void test_goto_bad(char* test_name){
     bac:	715d                	addi	sp,sp,-80
     bae:	e486                	sd	ra,72(sp)
     bb0:	e0a2                	sd	s0,64(sp)
     bb2:	fc26                	sd	s1,56(sp)
     bb4:	f84a                	sd	s2,48(sp)
     bb6:	f44e                	sd	s3,40(sp)
     bb8:	0880                	addi	s0,sp,80
     bba:	84aa                	mv	s1,a0
    PRINT_START(test_name);
     bbc:	85aa                	mv	a1,a0
     bbe:	00001517          	auipc	a0,0x1
     bc2:	baa50513          	addi	a0,a0,-1110 # 1768 <malloc+0xea>
     bc6:	00001097          	auipc	ra,0x1
     bca:	9fa080e7          	jalr	-1542(ra) # 15c0 <printf>
    int pgf;
    int i=0;
    int num=25; 
    int cpid = fork();
     bce:	00000097          	auipc	ra,0x0
     bd2:	66a080e7          	jalr	1642(ra) # 1238 <fork>
    if (cpid){//father
     bd6:	c539                	beqz	a0,c24 <test_goto_bad+0x78>
        wait(&pgf);
     bd8:	fcc40513          	addi	a0,s0,-52
     bdc:	00000097          	auipc	ra,0x0
     be0:	66c080e7          	jalr	1644(ra) # 1248 <wait>
        sbrk(-PGSIZE*num);
        printf("finished free\n");
        pgf = setAndGetPageFaultsNum(-1);
        exit(pgf);
    }
    test_name_array[9] = test_name;
     be4:	00001797          	auipc	a5,0x1
     be8:	40478793          	addi	a5,a5,1028 # 1fe8 <test_name_array>
     bec:	e7a4                	sd	s1,72(a5)
    pgf_array[9] = pgf;
     bee:	fcc42603          	lw	a2,-52(s0)
     bf2:	0cc7a223          	sw	a2,196(a5)
    sum_value= sum_value+pgf;
     bf6:	00001717          	auipc	a4,0x1
     bfa:	3e270713          	addi	a4,a4,994 # 1fd8 <sum_value>
     bfe:	431c                	lw	a5,0(a4)
     c00:	9fb1                	addw	a5,a5,a2
     c02:	c31c                	sw	a5,0(a4)
    PRINT_END(test_name, pgf);
     c04:	85a6                	mv	a1,s1
     c06:	00001517          	auipc	a0,0x1
     c0a:	b9a50513          	addi	a0,a0,-1126 # 17a0 <malloc+0x122>
     c0e:	00001097          	auipc	ra,0x1
     c12:	9b2080e7          	jalr	-1614(ra) # 15c0 <printf>
}
     c16:	60a6                	ld	ra,72(sp)
     c18:	6406                	ld	s0,64(sp)
     c1a:	74e2                	ld	s1,56(sp)
     c1c:	7942                	ld	s2,48(sp)
     c1e:	79a2                	ld	s3,40(sp)
     c20:	6161                	addi	sp,sp,80
     c22:	8082                	ret
        int * memory_pointer = (int*)(sbrk(PGSIZE*num));
     c24:	6565                	lui	a0,0x19
     c26:	00000097          	auipc	ra,0x0
     c2a:	6a2080e7          	jalr	1698(ra) # 12c8 <sbrk>
     c2e:	84aa                	mv	s1,a0
        printf("finished alloc with sbrk and set values\n");
     c30:	00001517          	auipc	a0,0x1
     c34:	c3050513          	addi	a0,a0,-976 # 1860 <malloc+0x1e2>
     c38:	00001097          	auipc	ra,0x1
     c3c:	988080e7          	jalr	-1656(ra) # 15c0 <printf>
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     c40:	8926                	mv	s2,s1
     c42:	69e5                	lui	s3,0x19
     c44:	99a6                	add	s3,s3,s1
        printf("finished alloc with sbrk and set values\n");
     c46:	87a6                	mv	a5,s1
            memory_pointer[i]=5;
     c48:	4715                	li	a4,5
     c4a:	c398                	sw	a4,0(a5)
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     c4c:	0791                	addi	a5,a5,4
     c4e:	ff379ee3          	bne	a5,s3,c4a <test_goto_bad+0x9e>
        char* argv[] = {"test",0};
     c52:	00001797          	auipc	a5,0x1
     c56:	0ee78793          	addi	a5,a5,238 # 1d40 <malloc+0x6c2>
     c5a:	faf43c23          	sd	a5,-72(s0)
     c5e:	fc043023          	sd	zero,-64(s0)
        printf("going to exec\n");
     c62:	00001517          	auipc	a0,0x1
     c66:	0e650513          	addi	a0,a0,230 # 1d48 <malloc+0x6ca>
     c6a:	00001097          	auipc	ra,0x1
     c6e:	956080e7          	jalr	-1706(ra) # 15c0 <printf>
		exec(argv[0],argv);
     c72:	fb840593          	addi	a1,s0,-72
     c76:	fb843503          	ld	a0,-72(s0)
     c7a:	00000097          	auipc	ra,0x0
     c7e:	5fe080e7          	jalr	1534(ra) # 1278 <exec>
        printf("returned from exec and gonna fill memory :))))\n");
     c82:	00001517          	auipc	a0,0x1
     c86:	0d650513          	addi	a0,a0,214 # 1d58 <malloc+0x6da>
     c8a:	00001097          	auipc	ra,0x1
     c8e:	936080e7          	jalr	-1738(ra) # 15c0 <printf>
            printf("memory_pointer[i]=%d\n", memory_pointer[i]);
     c92:	00001497          	auipc	s1,0x1
     c96:	d5e48493          	addi	s1,s1,-674 # 19f0 <malloc+0x372>
     c9a:	00092583          	lw	a1,0(s2)
     c9e:	8526                	mv	a0,s1
     ca0:	00001097          	auipc	ra,0x1
     ca4:	920080e7          	jalr	-1760(ra) # 15c0 <printf>
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     ca8:	0911                	addi	s2,s2,4
     caa:	ff3918e3          	bne	s2,s3,c9a <test_goto_bad+0xee>
        sbrk(-PGSIZE*num);
     cae:	751d                	lui	a0,0xfffe7
     cb0:	00000097          	auipc	ra,0x0
     cb4:	618080e7          	jalr	1560(ra) # 12c8 <sbrk>
        printf("finished free\n");
     cb8:	00001517          	auipc	a0,0x1
     cbc:	bd850513          	addi	a0,a0,-1064 # 1890 <malloc+0x212>
     cc0:	00001097          	auipc	ra,0x1
     cc4:	900080e7          	jalr	-1792(ra) # 15c0 <printf>
        pgf = setAndGetPageFaultsNum(-1);
     cc8:	557d                	li	a0,-1
     cca:	00000097          	auipc	ra,0x0
     cce:	616080e7          	jalr	1558(ra) # 12e0 <setAndGetPageFaultsNum>
     cd2:	fca42623          	sw	a0,-52(s0)
        exit(pgf);
     cd6:	00000097          	auipc	ra,0x0
     cda:	56a080e7          	jalr	1386(ra) # 1240 <exit>

0000000000000cde <ALGO_test>:

void ALGO_test(char* test_name){ 
     cde:	715d                	addi	sp,sp,-80
     ce0:	e486                	sd	ra,72(sp)
     ce2:	e0a2                	sd	s0,64(sp)
     ce4:	fc26                	sd	s1,56(sp)
     ce6:	f84a                	sd	s2,48(sp)
     ce8:	f44e                	sd	s3,40(sp)
     cea:	f052                	sd	s4,32(sp)
     cec:	ec56                	sd	s5,24(sp)
     cee:	0880                	addi	s0,sp,80
     cf0:	84aa                	mv	s1,a0
    setAndGetPageFaultsNum(0); // sets num of pagefaults to be zero
     cf2:	4501                	li	a0,0
     cf4:	00000097          	auipc	ra,0x0
     cf8:	5ec080e7          	jalr	1516(ra) # 12e0 <setAndGetPageFaultsNum>
    PRINT_START(test_name);
     cfc:	85a6                	mv	a1,s1
     cfe:	00001517          	auipc	a0,0x1
     d02:	a6a50513          	addi	a0,a0,-1430 # 1768 <malloc+0xea>
     d06:	00001097          	auipc	ra,0x1
     d0a:	8ba080e7          	jalr	-1862(ra) # 15c0 <printf>
    int pgf;
    int i=0;
    int num=13; 
    int cpid = fork();
     d0e:	00000097          	auipc	ra,0x0
     d12:	52a080e7          	jalr	1322(ra) # 1238 <fork>
    if (cpid){//father
     d16:	c929                	beqz	a0,d68 <ALGO_test+0x8a>
        wait(&pgf);
     d18:	fbc40513          	addi	a0,s0,-68
     d1c:	00000097          	auipc	ra,0x0
     d20:	52c080e7          	jalr	1324(ra) # 1248 <wait>
        sbrk(-PGSIZE*num);
        printf("finished free\n");
        pgf = setAndGetPageFaultsNum(-1);
        exit(pgf);
    }
    test_name_array[10] = test_name;
     d24:	00001797          	auipc	a5,0x1
     d28:	2c478793          	addi	a5,a5,708 # 1fe8 <test_name_array>
     d2c:	eba4                	sd	s1,80(a5)
    pgf_array[10] = pgf;
     d2e:	fbc42603          	lw	a2,-68(s0)
     d32:	0cc7a423          	sw	a2,200(a5)
    sum_value= sum_value+pgf;
     d36:	00001717          	auipc	a4,0x1
     d3a:	2a270713          	addi	a4,a4,674 # 1fd8 <sum_value>
     d3e:	431c                	lw	a5,0(a4)
     d40:	9fb1                	addw	a5,a5,a2
     d42:	c31c                	sw	a5,0(a4)
    PRINT_END(test_name, pgf);
     d44:	85a6                	mv	a1,s1
     d46:	00001517          	auipc	a0,0x1
     d4a:	a5a50513          	addi	a0,a0,-1446 # 17a0 <malloc+0x122>
     d4e:	00001097          	auipc	ra,0x1
     d52:	872080e7          	jalr	-1934(ra) # 15c0 <printf>
}
     d56:	60a6                	ld	ra,72(sp)
     d58:	6406                	ld	s0,64(sp)
     d5a:	74e2                	ld	s1,56(sp)
     d5c:	7942                	ld	s2,48(sp)
     d5e:	79a2                	ld	s3,40(sp)
     d60:	7a02                	ld	s4,32(sp)
     d62:	6ae2                	ld	s5,24(sp)
     d64:	6161                	addi	sp,sp,80
     d66:	8082                	ret
     d68:	892a                	mv	s2,a0
        printf("~~~~~~~~~~~~~~son gonna sbrk!!!!!\n");
     d6a:	00001517          	auipc	a0,0x1
     d6e:	aa650513          	addi	a0,a0,-1370 # 1810 <malloc+0x192>
     d72:	00001097          	auipc	ra,0x1
     d76:	84e080e7          	jalr	-1970(ra) # 15c0 <printf>
        int * memory_pointer = (int*)(sbrk(PGSIZE*num));
     d7a:	6535                	lui	a0,0xd
     d7c:	00000097          	auipc	ra,0x0
     d80:	54c080e7          	jalr	1356(ra) # 12c8 <sbrk>
     d84:	89aa                	mv	s3,a0
        printf("~~~~~~~~~~~~~~son finish sbrk!!!!!\n");
     d86:	00001517          	auipc	a0,0x1
     d8a:	ab250513          	addi	a0,a0,-1358 # 1838 <malloc+0x1ba>
     d8e:	00001097          	auipc	ra,0x1
     d92:	832080e7          	jalr	-1998(ra) # 15c0 <printf>
        printf("~~~~~~~~~~~~~~son gonna change value of last page!!!!!\n");
     d96:	00001517          	auipc	a0,0x1
     d9a:	ff250513          	addi	a0,a0,-14 # 1d88 <malloc+0x70a>
     d9e:	00001097          	auipc	ra,0x1
     da2:	822080e7          	jalr	-2014(ra) # 15c0 <printf>
            if(i > PGSIZE*12/sizeof(int))
     da6:	00498693          	addi	a3,s3,4 # 19004 <__global_pointer$+0x16833>
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     daa:	874a                	mv	a4,s2
     dac:	660d                	lui	a2,0x3
     dae:	40060593          	addi	a1,a2,1024 # 3400 <__global_pointer$+0xc2f>
            memory_pointer[i]=1;
     db2:	4505                	li	a0,1
     db4:	a011                	j	db8 <ALGO_test+0xda>
     db6:	0691                	addi	a3,a3,4
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     db8:	0017079b          	addiw	a5,a4,1
     dbc:	0007871b          	sext.w	a4,a5
     dc0:	00b70763          	beq	a4,a1,dce <ALGO_test+0xf0>
            if(i > PGSIZE*12/sizeof(int))
     dc4:	2781                	sext.w	a5,a5
     dc6:	fef678e3          	bgeu	a2,a5,db6 <ALGO_test+0xd8>
            memory_pointer[i]=1;
     dca:	c288                	sw	a0,0(a3)
     dcc:	b7ed                	j	db6 <ALGO_test+0xd8>
        sleep(2);
     dce:	4509                	li	a0,2
     dd0:	00000097          	auipc	ra,0x0
     dd4:	500080e7          	jalr	1280(ra) # 12d0 <sleep>
        memory_pointer[12*PGSIZE/sizeof(int)+1]=1;
     dd8:	67b1                	lui	a5,0xc
     dda:	97ce                	add	a5,a5,s3
     ddc:	4705                	li	a4,1
     dde:	c3d8                	sw	a4,4(a5)
        printf("~~~~~~~~~~~~~~son gonna change all values!!!!!\n");
     de0:	00001517          	auipc	a0,0x1
     de4:	fe050513          	addi	a0,a0,-32 # 1dc0 <malloc+0x742>
     de8:	00000097          	auipc	ra,0x0
     dec:	7d8080e7          	jalr	2008(ra) # 15c0 <printf>
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     df0:	84ce                	mv	s1,s3
                printf("num %d: memory_pointer[i]=%d\n", i*4/PGSIZE, memory_pointer[i]);
     df2:	00001a97          	auipc	s5,0x1
     df6:	bf6a8a93          	addi	s5,s5,-1034 # 19e8 <malloc+0x36a>
        for (i=0; i<PGSIZE*num/sizeof(int); ++i){
     dfa:	6a0d                	lui	s4,0x3
     dfc:	400a0a13          	addi	s4,s4,1024 # 3400 <__global_pointer$+0xc2f>
     e00:	a029                	j	e0a <ALGO_test+0x12c>
     e02:	2905                	addiw	s2,s2,1
     e04:	0491                	addi	s1,s1,4
     e06:	03490663          	beq	s2,s4,e32 <ALGO_test+0x154>
            memory_pointer[i]=0;
     e0a:	0004a023          	sw	zero,0(s1)
            if(i%(PGSIZE/sizeof(int)) == 0)
     e0e:	3ff97793          	andi	a5,s2,1023
     e12:	fbe5                	bnez	a5,e02 <ALGO_test+0x124>
                printf("num %d: memory_pointer[i]=%d\n", i*4/PGSIZE, memory_pointer[i]);
     e14:	41f9559b          	sraiw	a1,s2,0x1f
     e18:	0165d59b          	srliw	a1,a1,0x16
     e1c:	012585bb          	addw	a1,a1,s2
     e20:	4601                	li	a2,0
     e22:	40a5d59b          	sraiw	a1,a1,0xa
     e26:	8556                	mv	a0,s5
     e28:	00000097          	auipc	ra,0x0
     e2c:	798080e7          	jalr	1944(ra) # 15c0 <printf>
     e30:	bfc9                	j	e02 <ALGO_test+0x124>
        sleep(1);
     e32:	4505                	li	a0,1
     e34:	00000097          	auipc	ra,0x0
     e38:	49c080e7          	jalr	1180(ra) # 12d0 <sleep>
        memory_pointer[10*PGSIZE/sizeof(int)+1]=1;
     e3c:	67a9                	lui	a5,0xa
     e3e:	99be                	add	s3,s3,a5
     e40:	4785                	li	a5,1
     e42:	00f9a223          	sw	a5,4(s3)
        printf("\nfinished alloc with sbrk and set values\n");
     e46:	00001517          	auipc	a0,0x1
     e4a:	faa50513          	addi	a0,a0,-86 # 1df0 <malloc+0x772>
     e4e:	00000097          	auipc	ra,0x0
     e52:	772080e7          	jalr	1906(ra) # 15c0 <printf>
        sbrk(-PGSIZE*num);
     e56:	754d                	lui	a0,0xffff3
     e58:	00000097          	auipc	ra,0x0
     e5c:	470080e7          	jalr	1136(ra) # 12c8 <sbrk>
        printf("finished free\n");
     e60:	00001517          	auipc	a0,0x1
     e64:	a3050513          	addi	a0,a0,-1488 # 1890 <malloc+0x212>
     e68:	00000097          	auipc	ra,0x0
     e6c:	758080e7          	jalr	1880(ra) # 15c0 <printf>
        pgf = setAndGetPageFaultsNum(-1);
     e70:	557d                	li	a0,-1
     e72:	00000097          	auipc	ra,0x0
     e76:	46e080e7          	jalr	1134(ra) # 12e0 <setAndGetPageFaultsNum>
     e7a:	faa42e23          	sw	a0,-68(s0)
        exit(pgf);
     e7e:	00000097          	auipc	ra,0x0
     e82:	3c2080e7          	jalr	962(ra) # 1240 <exit>

0000000000000e86 <main>:


int
main(int argc, char *argv[])
{
     e86:	7179                	addi	sp,sp,-48
     e88:	f406                	sd	ra,40(sp)
     e8a:	f022                	sd	s0,32(sp)
     e8c:	ec26                	sd	s1,24(sp)
     e8e:	e84a                	sd	s2,16(sp)
     e90:	e44e                	sd	s3,8(sp)
     e92:	e052                	sd	s4,0(sp)
     e94:	1800                	addi	s0,sp,48
    //test_goto_bad("test_goto_bad");
    for(int i=0; i<20; i++){test_name_array[i]=0;}
     e96:	00001497          	auipc	s1,0x1
     e9a:	15248493          	addi	s1,s1,338 # 1fe8 <test_name_array>
     e9e:	00001997          	auipc	s3,0x1
     ea2:	1ea98993          	addi	s3,s3,490 # 2088 <pgf_array>
{
     ea6:	87a6                	mv	a5,s1
    for(int i=0; i<20; i++){test_name_array[i]=0;}
     ea8:	0007b023          	sd	zero,0(a5) # a000 <__global_pointer$+0x782f>
     eac:	07a1                	addi	a5,a5,8
     eae:	ff379de3          	bne	a5,s3,ea8 <main+0x22>


    basic_fork_test("basic_fork_test");
     eb2:	00001517          	auipc	a0,0x1
     eb6:	f6e50513          	addi	a0,a0,-146 # 1e20 <malloc+0x7a2>
     eba:	fffff097          	auipc	ra,0xfffff
     ebe:	146080e7          	jalr	326(ra) # 0 <basic_fork_test>
    
    sbrk_test_son("sbrk_test_son");
     ec2:	00001517          	auipc	a0,0x1
     ec6:	f6e50513          	addi	a0,a0,-146 # 1e30 <malloc+0x7b2>
     eca:	fffff097          	auipc	ra,0xfffff
     ece:	1e0080e7          	jalr	480(ra) # aa <sbrk_test_son>
    sbrk_test_father("sbrk_test_father");
     ed2:	00001517          	auipc	a0,0x1
     ed6:	f6e50513          	addi	a0,a0,-146 # 1e40 <malloc+0x7c2>
     eda:	fffff097          	auipc	ra,0xfffff
     ede:	3ee080e7          	jalr	1006(ra) # 2c8 <sbrk_test_father>
    double_sbrk_test_son("double_sbrk_test_son");
     ee2:	00001517          	auipc	a0,0x1
     ee6:	f7650513          	addi	a0,a0,-138 # 1e58 <malloc+0x7da>
     eea:	fffff097          	auipc	ra,0xfffff
     eee:	48c080e7          	jalr	1164(ra) # 376 <double_sbrk_test_son>
    sbrk_not_multiply_of_PGSIZE("sbrk_not_multiply_of_PGSIZE");
     ef2:	00001517          	auipc	a0,0x1
     ef6:	f7e50513          	addi	a0,a0,-130 # 1e70 <malloc+0x7f2>
     efa:	fffff097          	auipc	ra,0xfffff
     efe:	2a6080e7          	jalr	678(ra) # 1a0 <sbrk_not_multiply_of_PGSIZE>
    
    complicated_sbrk("complicated_sbrk");
     f02:	00001517          	auipc	a0,0x1
     f06:	f8e50513          	addi	a0,a0,-114 # 1e90 <malloc+0x812>
     f0a:	fffff097          	auipc	ra,0xfffff
     f0e:	5d4080e7          	jalr	1492(ra) # 4de <complicated_sbrk>
    
    //maxpages_switch("maxpages_switch");

    malloc_test_simple("malloc_test_simple");
     f12:	00001517          	auipc	a0,0x1
     f16:	f9650513          	addi	a0,a0,-106 # 1ea8 <malloc+0x82a>
     f1a:	00000097          	auipc	ra,0x0
     f1e:	952080e7          	jalr	-1710(ra) # 86c <malloc_test_simple>
    malloc_test_not_multiply_of_PGSIZE("malloc_test_not_multiply_of_PGSIZE");
     f22:	00001517          	auipc	a0,0x1
     f26:	f9e50513          	addi	a0,a0,-98 # 1ec0 <malloc+0x842>
     f2a:	00000097          	auipc	ra,0x0
     f2e:	a28080e7          	jalr	-1496(ra) # 952 <malloc_test_not_multiply_of_PGSIZE>
    
    malloc_test_complicated("malloc_test_complicated");
     f32:	00001517          	auipc	a0,0x1
     f36:	fb650513          	addi	a0,a0,-74 # 1ee8 <malloc+0x86a>
     f3a:	00000097          	auipc	ra,0x0
     f3e:	b30080e7          	jalr	-1232(ra) # a6a <malloc_test_complicated>
    
    ALGO_test("ALGO_test");
     f42:	00001517          	auipc	a0,0x1
     f46:	fbe50513          	addi	a0,a0,-66 # 1f00 <malloc+0x882>
     f4a:	00000097          	auipc	ra,0x0
     f4e:	d94080e7          	jalr	-620(ra) # cde <ALGO_test>
    


    //sum up 
    
    printf("\n         ~~~~~~~~~~~\n~~~~~~~~~~~      ~~~~~~~~~~~\n");
     f52:	00001517          	auipc	a0,0x1
     f56:	fbe50513          	addi	a0,a0,-66 # 1f10 <malloc+0x892>
     f5a:	00000097          	auipc	ra,0x0
     f5e:	666080e7          	jalr	1638(ra) # 15c0 <printf>
    printf("\n              SUMMARY\n");
     f62:	00001517          	auipc	a0,0x1
     f66:	fe650513          	addi	a0,a0,-26 # 1f48 <malloc+0x8ca>
     f6a:	00000097          	auipc	ra,0x0
     f6e:	656080e7          	jalr	1622(ra) # 15c0 <printf>
    for(int i=0; i<20; i++){
     f72:	00001917          	auipc	s2,0x1
     f76:	11690913          	addi	s2,s2,278 # 2088 <pgf_array>
        if(test_name_array[i]!=0){
            printf("%s:  %d\n", test_name_array[i], pgf_array[i]);
     f7a:	00001a17          	auipc	s4,0x1
     f7e:	fe6a0a13          	addi	s4,s4,-26 # 1f60 <malloc+0x8e2>
     f82:	a821                	j	f9a <main+0x114>
     f84:	00092603          	lw	a2,0(s2)
     f88:	8552                	mv	a0,s4
     f8a:	00000097          	auipc	ra,0x0
     f8e:	636080e7          	jalr	1590(ra) # 15c0 <printf>
    for(int i=0; i<20; i++){
     f92:	04a1                	addi	s1,s1,8
     f94:	0911                	addi	s2,s2,4
     f96:	01348563          	beq	s1,s3,fa0 <main+0x11a>
        if(test_name_array[i]!=0){
     f9a:	608c                	ld	a1,0(s1)
     f9c:	f5e5                	bnez	a1,f84 <main+0xfe>
     f9e:	bfd5                	j	f92 <main+0x10c>
        }
    }

    printf("\n SUM: %d\n", sum_value);
     fa0:	00001597          	auipc	a1,0x1
     fa4:	0385a583          	lw	a1,56(a1) # 1fd8 <sum_value>
     fa8:	00001517          	auipc	a0,0x1
     fac:	fc850513          	addi	a0,a0,-56 # 1f70 <malloc+0x8f2>
     fb0:	00000097          	auipc	ra,0x0
     fb4:	610080e7          	jalr	1552(ra) # 15c0 <printf>
    printf("\n~~~~~~~~~~~      ~~~~~~~~~~~\n         ~~~~~~~~~~~\n");
     fb8:	00001517          	auipc	a0,0x1
     fbc:	fc850513          	addi	a0,a0,-56 # 1f80 <malloc+0x902>
     fc0:	00000097          	auipc	ra,0x0
     fc4:	600080e7          	jalr	1536(ra) # 15c0 <printf>
    exit(0);
     fc8:	4501                	li	a0,0
     fca:	00000097          	auipc	ra,0x0
     fce:	276080e7          	jalr	630(ra) # 1240 <exit>

0000000000000fd2 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     fd2:	1141                	addi	sp,sp,-16
     fd4:	e422                	sd	s0,8(sp)
     fd6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     fd8:	87aa                	mv	a5,a0
     fda:	0585                	addi	a1,a1,1
     fdc:	0785                	addi	a5,a5,1
     fde:	fff5c703          	lbu	a4,-1(a1)
     fe2:	fee78fa3          	sb	a4,-1(a5)
     fe6:	fb75                	bnez	a4,fda <strcpy+0x8>
    ;
  return os;
}
     fe8:	6422                	ld	s0,8(sp)
     fea:	0141                	addi	sp,sp,16
     fec:	8082                	ret

0000000000000fee <strcmp>:

int
strcmp(const char *p, const char *q)
{
     fee:	1141                	addi	sp,sp,-16
     ff0:	e422                	sd	s0,8(sp)
     ff2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     ff4:	00054783          	lbu	a5,0(a0)
     ff8:	cb91                	beqz	a5,100c <strcmp+0x1e>
     ffa:	0005c703          	lbu	a4,0(a1)
     ffe:	00f71763          	bne	a4,a5,100c <strcmp+0x1e>
    p++, q++;
    1002:	0505                	addi	a0,a0,1
    1004:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    1006:	00054783          	lbu	a5,0(a0)
    100a:	fbe5                	bnez	a5,ffa <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    100c:	0005c503          	lbu	a0,0(a1)
}
    1010:	40a7853b          	subw	a0,a5,a0
    1014:	6422                	ld	s0,8(sp)
    1016:	0141                	addi	sp,sp,16
    1018:	8082                	ret

000000000000101a <strlen>:

uint
strlen(const char *s)
{
    101a:	1141                	addi	sp,sp,-16
    101c:	e422                	sd	s0,8(sp)
    101e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    1020:	00054783          	lbu	a5,0(a0)
    1024:	cf91                	beqz	a5,1040 <strlen+0x26>
    1026:	0505                	addi	a0,a0,1
    1028:	87aa                	mv	a5,a0
    102a:	4685                	li	a3,1
    102c:	9e89                	subw	a3,a3,a0
    102e:	00f6853b          	addw	a0,a3,a5
    1032:	0785                	addi	a5,a5,1
    1034:	fff7c703          	lbu	a4,-1(a5)
    1038:	fb7d                	bnez	a4,102e <strlen+0x14>
    ;
  return n;
}
    103a:	6422                	ld	s0,8(sp)
    103c:	0141                	addi	sp,sp,16
    103e:	8082                	ret
  for(n = 0; s[n]; n++)
    1040:	4501                	li	a0,0
    1042:	bfe5                	j	103a <strlen+0x20>

0000000000001044 <memset>:

void*
memset(void *dst, int c, uint n)
{
    1044:	1141                	addi	sp,sp,-16
    1046:	e422                	sd	s0,8(sp)
    1048:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    104a:	ca19                	beqz	a2,1060 <memset+0x1c>
    104c:	87aa                	mv	a5,a0
    104e:	1602                	slli	a2,a2,0x20
    1050:	9201                	srli	a2,a2,0x20
    1052:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    1056:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    105a:	0785                	addi	a5,a5,1
    105c:	fee79de3          	bne	a5,a4,1056 <memset+0x12>
  }
  return dst;
}
    1060:	6422                	ld	s0,8(sp)
    1062:	0141                	addi	sp,sp,16
    1064:	8082                	ret

0000000000001066 <strchr>:

char*
strchr(const char *s, char c)
{
    1066:	1141                	addi	sp,sp,-16
    1068:	e422                	sd	s0,8(sp)
    106a:	0800                	addi	s0,sp,16
  for(; *s; s++)
    106c:	00054783          	lbu	a5,0(a0)
    1070:	cb99                	beqz	a5,1086 <strchr+0x20>
    if(*s == c)
    1072:	00f58763          	beq	a1,a5,1080 <strchr+0x1a>
  for(; *s; s++)
    1076:	0505                	addi	a0,a0,1
    1078:	00054783          	lbu	a5,0(a0)
    107c:	fbfd                	bnez	a5,1072 <strchr+0xc>
      return (char*)s;
  return 0;
    107e:	4501                	li	a0,0
}
    1080:	6422                	ld	s0,8(sp)
    1082:	0141                	addi	sp,sp,16
    1084:	8082                	ret
  return 0;
    1086:	4501                	li	a0,0
    1088:	bfe5                	j	1080 <strchr+0x1a>

000000000000108a <gets>:

char*
gets(char *buf, int max)
{
    108a:	711d                	addi	sp,sp,-96
    108c:	ec86                	sd	ra,88(sp)
    108e:	e8a2                	sd	s0,80(sp)
    1090:	e4a6                	sd	s1,72(sp)
    1092:	e0ca                	sd	s2,64(sp)
    1094:	fc4e                	sd	s3,56(sp)
    1096:	f852                	sd	s4,48(sp)
    1098:	f456                	sd	s5,40(sp)
    109a:	f05a                	sd	s6,32(sp)
    109c:	ec5e                	sd	s7,24(sp)
    109e:	1080                	addi	s0,sp,96
    10a0:	8baa                	mv	s7,a0
    10a2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    10a4:	892a                	mv	s2,a0
    10a6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    10a8:	4aa9                	li	s5,10
    10aa:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    10ac:	89a6                	mv	s3,s1
    10ae:	2485                	addiw	s1,s1,1
    10b0:	0344d863          	bge	s1,s4,10e0 <gets+0x56>
    cc = read(0, &c, 1);
    10b4:	4605                	li	a2,1
    10b6:	faf40593          	addi	a1,s0,-81
    10ba:	4501                	li	a0,0
    10bc:	00000097          	auipc	ra,0x0
    10c0:	19c080e7          	jalr	412(ra) # 1258 <read>
    if(cc < 1)
    10c4:	00a05e63          	blez	a0,10e0 <gets+0x56>
    buf[i++] = c;
    10c8:	faf44783          	lbu	a5,-81(s0)
    10cc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    10d0:	01578763          	beq	a5,s5,10de <gets+0x54>
    10d4:	0905                	addi	s2,s2,1
    10d6:	fd679be3          	bne	a5,s6,10ac <gets+0x22>
  for(i=0; i+1 < max; ){
    10da:	89a6                	mv	s3,s1
    10dc:	a011                	j	10e0 <gets+0x56>
    10de:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    10e0:	99de                	add	s3,s3,s7
    10e2:	00098023          	sb	zero,0(s3)
  return buf;
}
    10e6:	855e                	mv	a0,s7
    10e8:	60e6                	ld	ra,88(sp)
    10ea:	6446                	ld	s0,80(sp)
    10ec:	64a6                	ld	s1,72(sp)
    10ee:	6906                	ld	s2,64(sp)
    10f0:	79e2                	ld	s3,56(sp)
    10f2:	7a42                	ld	s4,48(sp)
    10f4:	7aa2                	ld	s5,40(sp)
    10f6:	7b02                	ld	s6,32(sp)
    10f8:	6be2                	ld	s7,24(sp)
    10fa:	6125                	addi	sp,sp,96
    10fc:	8082                	ret

00000000000010fe <stat>:

int
stat(const char *n, struct stat *st)
{
    10fe:	1101                	addi	sp,sp,-32
    1100:	ec06                	sd	ra,24(sp)
    1102:	e822                	sd	s0,16(sp)
    1104:	e426                	sd	s1,8(sp)
    1106:	e04a                	sd	s2,0(sp)
    1108:	1000                	addi	s0,sp,32
    110a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    110c:	4581                	li	a1,0
    110e:	00000097          	auipc	ra,0x0
    1112:	172080e7          	jalr	370(ra) # 1280 <open>
  if(fd < 0)
    1116:	02054563          	bltz	a0,1140 <stat+0x42>
    111a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    111c:	85ca                	mv	a1,s2
    111e:	00000097          	auipc	ra,0x0
    1122:	17a080e7          	jalr	378(ra) # 1298 <fstat>
    1126:	892a                	mv	s2,a0
  close(fd);
    1128:	8526                	mv	a0,s1
    112a:	00000097          	auipc	ra,0x0
    112e:	13e080e7          	jalr	318(ra) # 1268 <close>
  return r;
}
    1132:	854a                	mv	a0,s2
    1134:	60e2                	ld	ra,24(sp)
    1136:	6442                	ld	s0,16(sp)
    1138:	64a2                	ld	s1,8(sp)
    113a:	6902                	ld	s2,0(sp)
    113c:	6105                	addi	sp,sp,32
    113e:	8082                	ret
    return -1;
    1140:	597d                	li	s2,-1
    1142:	bfc5                	j	1132 <stat+0x34>

0000000000001144 <atoi>:

int
atoi(const char *s)
{
    1144:	1141                	addi	sp,sp,-16
    1146:	e422                	sd	s0,8(sp)
    1148:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    114a:	00054603          	lbu	a2,0(a0)
    114e:	fd06079b          	addiw	a5,a2,-48
    1152:	0ff7f793          	andi	a5,a5,255
    1156:	4725                	li	a4,9
    1158:	02f76963          	bltu	a4,a5,118a <atoi+0x46>
    115c:	86aa                	mv	a3,a0
  n = 0;
    115e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    1160:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    1162:	0685                	addi	a3,a3,1
    1164:	0025179b          	slliw	a5,a0,0x2
    1168:	9fa9                	addw	a5,a5,a0
    116a:	0017979b          	slliw	a5,a5,0x1
    116e:	9fb1                	addw	a5,a5,a2
    1170:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    1174:	0006c603          	lbu	a2,0(a3)
    1178:	fd06071b          	addiw	a4,a2,-48
    117c:	0ff77713          	andi	a4,a4,255
    1180:	fee5f1e3          	bgeu	a1,a4,1162 <atoi+0x1e>
  return n;
}
    1184:	6422                	ld	s0,8(sp)
    1186:	0141                	addi	sp,sp,16
    1188:	8082                	ret
  n = 0;
    118a:	4501                	li	a0,0
    118c:	bfe5                	j	1184 <atoi+0x40>

000000000000118e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    118e:	1141                	addi	sp,sp,-16
    1190:	e422                	sd	s0,8(sp)
    1192:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    1194:	02b57463          	bgeu	a0,a1,11bc <memmove+0x2e>
    while(n-- > 0)
    1198:	00c05f63          	blez	a2,11b6 <memmove+0x28>
    119c:	1602                	slli	a2,a2,0x20
    119e:	9201                	srli	a2,a2,0x20
    11a0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    11a4:	872a                	mv	a4,a0
      *dst++ = *src++;
    11a6:	0585                	addi	a1,a1,1
    11a8:	0705                	addi	a4,a4,1
    11aa:	fff5c683          	lbu	a3,-1(a1)
    11ae:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    11b2:	fee79ae3          	bne	a5,a4,11a6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    11b6:	6422                	ld	s0,8(sp)
    11b8:	0141                	addi	sp,sp,16
    11ba:	8082                	ret
    dst += n;
    11bc:	00c50733          	add	a4,a0,a2
    src += n;
    11c0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    11c2:	fec05ae3          	blez	a2,11b6 <memmove+0x28>
    11c6:	fff6079b          	addiw	a5,a2,-1
    11ca:	1782                	slli	a5,a5,0x20
    11cc:	9381                	srli	a5,a5,0x20
    11ce:	fff7c793          	not	a5,a5
    11d2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    11d4:	15fd                	addi	a1,a1,-1
    11d6:	177d                	addi	a4,a4,-1
    11d8:	0005c683          	lbu	a3,0(a1)
    11dc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    11e0:	fee79ae3          	bne	a5,a4,11d4 <memmove+0x46>
    11e4:	bfc9                	j	11b6 <memmove+0x28>

00000000000011e6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    11e6:	1141                	addi	sp,sp,-16
    11e8:	e422                	sd	s0,8(sp)
    11ea:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    11ec:	ca05                	beqz	a2,121c <memcmp+0x36>
    11ee:	fff6069b          	addiw	a3,a2,-1
    11f2:	1682                	slli	a3,a3,0x20
    11f4:	9281                	srli	a3,a3,0x20
    11f6:	0685                	addi	a3,a3,1
    11f8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    11fa:	00054783          	lbu	a5,0(a0)
    11fe:	0005c703          	lbu	a4,0(a1)
    1202:	00e79863          	bne	a5,a4,1212 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    1206:	0505                	addi	a0,a0,1
    p2++;
    1208:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    120a:	fed518e3          	bne	a0,a3,11fa <memcmp+0x14>
  }
  return 0;
    120e:	4501                	li	a0,0
    1210:	a019                	j	1216 <memcmp+0x30>
      return *p1 - *p2;
    1212:	40e7853b          	subw	a0,a5,a4
}
    1216:	6422                	ld	s0,8(sp)
    1218:	0141                	addi	sp,sp,16
    121a:	8082                	ret
  return 0;
    121c:	4501                	li	a0,0
    121e:	bfe5                	j	1216 <memcmp+0x30>

0000000000001220 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    1220:	1141                	addi	sp,sp,-16
    1222:	e406                	sd	ra,8(sp)
    1224:	e022                	sd	s0,0(sp)
    1226:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    1228:	00000097          	auipc	ra,0x0
    122c:	f66080e7          	jalr	-154(ra) # 118e <memmove>
}
    1230:	60a2                	ld	ra,8(sp)
    1232:	6402                	ld	s0,0(sp)
    1234:	0141                	addi	sp,sp,16
    1236:	8082                	ret

0000000000001238 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    1238:	4885                	li	a7,1
 ecall
    123a:	00000073          	ecall
 ret
    123e:	8082                	ret

0000000000001240 <exit>:
.global exit
exit:
 li a7, SYS_exit
    1240:	4889                	li	a7,2
 ecall
    1242:	00000073          	ecall
 ret
    1246:	8082                	ret

0000000000001248 <wait>:
.global wait
wait:
 li a7, SYS_wait
    1248:	488d                	li	a7,3
 ecall
    124a:	00000073          	ecall
 ret
    124e:	8082                	ret

0000000000001250 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    1250:	4891                	li	a7,4
 ecall
    1252:	00000073          	ecall
 ret
    1256:	8082                	ret

0000000000001258 <read>:
.global read
read:
 li a7, SYS_read
    1258:	4895                	li	a7,5
 ecall
    125a:	00000073          	ecall
 ret
    125e:	8082                	ret

0000000000001260 <write>:
.global write
write:
 li a7, SYS_write
    1260:	48c1                	li	a7,16
 ecall
    1262:	00000073          	ecall
 ret
    1266:	8082                	ret

0000000000001268 <close>:
.global close
close:
 li a7, SYS_close
    1268:	48d5                	li	a7,21
 ecall
    126a:	00000073          	ecall
 ret
    126e:	8082                	ret

0000000000001270 <kill>:
.global kill
kill:
 li a7, SYS_kill
    1270:	4899                	li	a7,6
 ecall
    1272:	00000073          	ecall
 ret
    1276:	8082                	ret

0000000000001278 <exec>:
.global exec
exec:
 li a7, SYS_exec
    1278:	489d                	li	a7,7
 ecall
    127a:	00000073          	ecall
 ret
    127e:	8082                	ret

0000000000001280 <open>:
.global open
open:
 li a7, SYS_open
    1280:	48bd                	li	a7,15
 ecall
    1282:	00000073          	ecall
 ret
    1286:	8082                	ret

0000000000001288 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    1288:	48c5                	li	a7,17
 ecall
    128a:	00000073          	ecall
 ret
    128e:	8082                	ret

0000000000001290 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    1290:	48c9                	li	a7,18
 ecall
    1292:	00000073          	ecall
 ret
    1296:	8082                	ret

0000000000001298 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    1298:	48a1                	li	a7,8
 ecall
    129a:	00000073          	ecall
 ret
    129e:	8082                	ret

00000000000012a0 <link>:
.global link
link:
 li a7, SYS_link
    12a0:	48cd                	li	a7,19
 ecall
    12a2:	00000073          	ecall
 ret
    12a6:	8082                	ret

00000000000012a8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    12a8:	48d1                	li	a7,20
 ecall
    12aa:	00000073          	ecall
 ret
    12ae:	8082                	ret

00000000000012b0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    12b0:	48a5                	li	a7,9
 ecall
    12b2:	00000073          	ecall
 ret
    12b6:	8082                	ret

00000000000012b8 <dup>:
.global dup
dup:
 li a7, SYS_dup
    12b8:	48a9                	li	a7,10
 ecall
    12ba:	00000073          	ecall
 ret
    12be:	8082                	ret

00000000000012c0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    12c0:	48ad                	li	a7,11
 ecall
    12c2:	00000073          	ecall
 ret
    12c6:	8082                	ret

00000000000012c8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    12c8:	48b1                	li	a7,12
 ecall
    12ca:	00000073          	ecall
 ret
    12ce:	8082                	ret

00000000000012d0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    12d0:	48b5                	li	a7,13
 ecall
    12d2:	00000073          	ecall
 ret
    12d6:	8082                	ret

00000000000012d8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    12d8:	48b9                	li	a7,14
 ecall
    12da:	00000073          	ecall
 ret
    12de:	8082                	ret

00000000000012e0 <setAndGetPageFaultsNum>:
.global setAndGetPageFaultsNum
setAndGetPageFaultsNum:
 li a7, SYS_setAndGetPageFaultsNum
    12e0:	48d9                	li	a7,22
 ecall
    12e2:	00000073          	ecall
 ret
    12e6:	8082                	ret

00000000000012e8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    12e8:	1101                	addi	sp,sp,-32
    12ea:	ec06                	sd	ra,24(sp)
    12ec:	e822                	sd	s0,16(sp)
    12ee:	1000                	addi	s0,sp,32
    12f0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    12f4:	4605                	li	a2,1
    12f6:	fef40593          	addi	a1,s0,-17
    12fa:	00000097          	auipc	ra,0x0
    12fe:	f66080e7          	jalr	-154(ra) # 1260 <write>
}
    1302:	60e2                	ld	ra,24(sp)
    1304:	6442                	ld	s0,16(sp)
    1306:	6105                	addi	sp,sp,32
    1308:	8082                	ret

000000000000130a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    130a:	7139                	addi	sp,sp,-64
    130c:	fc06                	sd	ra,56(sp)
    130e:	f822                	sd	s0,48(sp)
    1310:	f426                	sd	s1,40(sp)
    1312:	f04a                	sd	s2,32(sp)
    1314:	ec4e                	sd	s3,24(sp)
    1316:	0080                	addi	s0,sp,64
    1318:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    131a:	c299                	beqz	a3,1320 <printint+0x16>
    131c:	0805c863          	bltz	a1,13ac <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    1320:	2581                	sext.w	a1,a1
  neg = 0;
    1322:	4881                	li	a7,0
    1324:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    1328:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    132a:	2601                	sext.w	a2,a2
    132c:	00001517          	auipc	a0,0x1
    1330:	c9450513          	addi	a0,a0,-876 # 1fc0 <digits>
    1334:	883a                	mv	a6,a4
    1336:	2705                	addiw	a4,a4,1
    1338:	02c5f7bb          	remuw	a5,a1,a2
    133c:	1782                	slli	a5,a5,0x20
    133e:	9381                	srli	a5,a5,0x20
    1340:	97aa                	add	a5,a5,a0
    1342:	0007c783          	lbu	a5,0(a5)
    1346:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    134a:	0005879b          	sext.w	a5,a1
    134e:	02c5d5bb          	divuw	a1,a1,a2
    1352:	0685                	addi	a3,a3,1
    1354:	fec7f0e3          	bgeu	a5,a2,1334 <printint+0x2a>
  if(neg)
    1358:	00088b63          	beqz	a7,136e <printint+0x64>
    buf[i++] = '-';
    135c:	fd040793          	addi	a5,s0,-48
    1360:	973e                	add	a4,a4,a5
    1362:	02d00793          	li	a5,45
    1366:	fef70823          	sb	a5,-16(a4)
    136a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    136e:	02e05863          	blez	a4,139e <printint+0x94>
    1372:	fc040793          	addi	a5,s0,-64
    1376:	00e78933          	add	s2,a5,a4
    137a:	fff78993          	addi	s3,a5,-1
    137e:	99ba                	add	s3,s3,a4
    1380:	377d                	addiw	a4,a4,-1
    1382:	1702                	slli	a4,a4,0x20
    1384:	9301                	srli	a4,a4,0x20
    1386:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    138a:	fff94583          	lbu	a1,-1(s2)
    138e:	8526                	mv	a0,s1
    1390:	00000097          	auipc	ra,0x0
    1394:	f58080e7          	jalr	-168(ra) # 12e8 <putc>
  while(--i >= 0)
    1398:	197d                	addi	s2,s2,-1
    139a:	ff3918e3          	bne	s2,s3,138a <printint+0x80>
}
    139e:	70e2                	ld	ra,56(sp)
    13a0:	7442                	ld	s0,48(sp)
    13a2:	74a2                	ld	s1,40(sp)
    13a4:	7902                	ld	s2,32(sp)
    13a6:	69e2                	ld	s3,24(sp)
    13a8:	6121                	addi	sp,sp,64
    13aa:	8082                	ret
    x = -xx;
    13ac:	40b005bb          	negw	a1,a1
    neg = 1;
    13b0:	4885                	li	a7,1
    x = -xx;
    13b2:	bf8d                	j	1324 <printint+0x1a>

00000000000013b4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    13b4:	7119                	addi	sp,sp,-128
    13b6:	fc86                	sd	ra,120(sp)
    13b8:	f8a2                	sd	s0,112(sp)
    13ba:	f4a6                	sd	s1,104(sp)
    13bc:	f0ca                	sd	s2,96(sp)
    13be:	ecce                	sd	s3,88(sp)
    13c0:	e8d2                	sd	s4,80(sp)
    13c2:	e4d6                	sd	s5,72(sp)
    13c4:	e0da                	sd	s6,64(sp)
    13c6:	fc5e                	sd	s7,56(sp)
    13c8:	f862                	sd	s8,48(sp)
    13ca:	f466                	sd	s9,40(sp)
    13cc:	f06a                	sd	s10,32(sp)
    13ce:	ec6e                	sd	s11,24(sp)
    13d0:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    13d2:	0005c903          	lbu	s2,0(a1)
    13d6:	18090f63          	beqz	s2,1574 <vprintf+0x1c0>
    13da:	8aaa                	mv	s5,a0
    13dc:	8b32                	mv	s6,a2
    13de:	00158493          	addi	s1,a1,1
  state = 0;
    13e2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    13e4:	02500a13          	li	s4,37
      if(c == 'd'){
    13e8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    13ec:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    13f0:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    13f4:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    13f8:	00001b97          	auipc	s7,0x1
    13fc:	bc8b8b93          	addi	s7,s7,-1080 # 1fc0 <digits>
    1400:	a839                	j	141e <vprintf+0x6a>
        putc(fd, c);
    1402:	85ca                	mv	a1,s2
    1404:	8556                	mv	a0,s5
    1406:	00000097          	auipc	ra,0x0
    140a:	ee2080e7          	jalr	-286(ra) # 12e8 <putc>
    140e:	a019                	j	1414 <vprintf+0x60>
    } else if(state == '%'){
    1410:	01498f63          	beq	s3,s4,142e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    1414:	0485                	addi	s1,s1,1
    1416:	fff4c903          	lbu	s2,-1(s1)
    141a:	14090d63          	beqz	s2,1574 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    141e:	0009079b          	sext.w	a5,s2
    if(state == 0){
    1422:	fe0997e3          	bnez	s3,1410 <vprintf+0x5c>
      if(c == '%'){
    1426:	fd479ee3          	bne	a5,s4,1402 <vprintf+0x4e>
        state = '%';
    142a:	89be                	mv	s3,a5
    142c:	b7e5                	j	1414 <vprintf+0x60>
      if(c == 'd'){
    142e:	05878063          	beq	a5,s8,146e <vprintf+0xba>
      } else if(c == 'l') {
    1432:	05978c63          	beq	a5,s9,148a <vprintf+0xd6>
      } else if(c == 'x') {
    1436:	07a78863          	beq	a5,s10,14a6 <vprintf+0xf2>
      } else if(c == 'p') {
    143a:	09b78463          	beq	a5,s11,14c2 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    143e:	07300713          	li	a4,115
    1442:	0ce78663          	beq	a5,a4,150e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1446:	06300713          	li	a4,99
    144a:	0ee78e63          	beq	a5,a4,1546 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    144e:	11478863          	beq	a5,s4,155e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1452:	85d2                	mv	a1,s4
    1454:	8556                	mv	a0,s5
    1456:	00000097          	auipc	ra,0x0
    145a:	e92080e7          	jalr	-366(ra) # 12e8 <putc>
        putc(fd, c);
    145e:	85ca                	mv	a1,s2
    1460:	8556                	mv	a0,s5
    1462:	00000097          	auipc	ra,0x0
    1466:	e86080e7          	jalr	-378(ra) # 12e8 <putc>
      }
      state = 0;
    146a:	4981                	li	s3,0
    146c:	b765                	j	1414 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    146e:	008b0913          	addi	s2,s6,8
    1472:	4685                	li	a3,1
    1474:	4629                	li	a2,10
    1476:	000b2583          	lw	a1,0(s6)
    147a:	8556                	mv	a0,s5
    147c:	00000097          	auipc	ra,0x0
    1480:	e8e080e7          	jalr	-370(ra) # 130a <printint>
    1484:	8b4a                	mv	s6,s2
      state = 0;
    1486:	4981                	li	s3,0
    1488:	b771                	j	1414 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    148a:	008b0913          	addi	s2,s6,8
    148e:	4681                	li	a3,0
    1490:	4629                	li	a2,10
    1492:	000b2583          	lw	a1,0(s6)
    1496:	8556                	mv	a0,s5
    1498:	00000097          	auipc	ra,0x0
    149c:	e72080e7          	jalr	-398(ra) # 130a <printint>
    14a0:	8b4a                	mv	s6,s2
      state = 0;
    14a2:	4981                	li	s3,0
    14a4:	bf85                	j	1414 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    14a6:	008b0913          	addi	s2,s6,8
    14aa:	4681                	li	a3,0
    14ac:	4641                	li	a2,16
    14ae:	000b2583          	lw	a1,0(s6)
    14b2:	8556                	mv	a0,s5
    14b4:	00000097          	auipc	ra,0x0
    14b8:	e56080e7          	jalr	-426(ra) # 130a <printint>
    14bc:	8b4a                	mv	s6,s2
      state = 0;
    14be:	4981                	li	s3,0
    14c0:	bf91                	j	1414 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    14c2:	008b0793          	addi	a5,s6,8
    14c6:	f8f43423          	sd	a5,-120(s0)
    14ca:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    14ce:	03000593          	li	a1,48
    14d2:	8556                	mv	a0,s5
    14d4:	00000097          	auipc	ra,0x0
    14d8:	e14080e7          	jalr	-492(ra) # 12e8 <putc>
  putc(fd, 'x');
    14dc:	85ea                	mv	a1,s10
    14de:	8556                	mv	a0,s5
    14e0:	00000097          	auipc	ra,0x0
    14e4:	e08080e7          	jalr	-504(ra) # 12e8 <putc>
    14e8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    14ea:	03c9d793          	srli	a5,s3,0x3c
    14ee:	97de                	add	a5,a5,s7
    14f0:	0007c583          	lbu	a1,0(a5)
    14f4:	8556                	mv	a0,s5
    14f6:	00000097          	auipc	ra,0x0
    14fa:	df2080e7          	jalr	-526(ra) # 12e8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    14fe:	0992                	slli	s3,s3,0x4
    1500:	397d                	addiw	s2,s2,-1
    1502:	fe0914e3          	bnez	s2,14ea <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    1506:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    150a:	4981                	li	s3,0
    150c:	b721                	j	1414 <vprintf+0x60>
        s = va_arg(ap, char*);
    150e:	008b0993          	addi	s3,s6,8
    1512:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    1516:	02090163          	beqz	s2,1538 <vprintf+0x184>
        while(*s != 0){
    151a:	00094583          	lbu	a1,0(s2)
    151e:	c9a1                	beqz	a1,156e <vprintf+0x1ba>
          putc(fd, *s);
    1520:	8556                	mv	a0,s5
    1522:	00000097          	auipc	ra,0x0
    1526:	dc6080e7          	jalr	-570(ra) # 12e8 <putc>
          s++;
    152a:	0905                	addi	s2,s2,1
        while(*s != 0){
    152c:	00094583          	lbu	a1,0(s2)
    1530:	f9e5                	bnez	a1,1520 <vprintf+0x16c>
        s = va_arg(ap, char*);
    1532:	8b4e                	mv	s6,s3
      state = 0;
    1534:	4981                	li	s3,0
    1536:	bdf9                	j	1414 <vprintf+0x60>
          s = "(null)";
    1538:	00001917          	auipc	s2,0x1
    153c:	a8090913          	addi	s2,s2,-1408 # 1fb8 <malloc+0x93a>
        while(*s != 0){
    1540:	02800593          	li	a1,40
    1544:	bff1                	j	1520 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    1546:	008b0913          	addi	s2,s6,8
    154a:	000b4583          	lbu	a1,0(s6)
    154e:	8556                	mv	a0,s5
    1550:	00000097          	auipc	ra,0x0
    1554:	d98080e7          	jalr	-616(ra) # 12e8 <putc>
    1558:	8b4a                	mv	s6,s2
      state = 0;
    155a:	4981                	li	s3,0
    155c:	bd65                	j	1414 <vprintf+0x60>
        putc(fd, c);
    155e:	85d2                	mv	a1,s4
    1560:	8556                	mv	a0,s5
    1562:	00000097          	auipc	ra,0x0
    1566:	d86080e7          	jalr	-634(ra) # 12e8 <putc>
      state = 0;
    156a:	4981                	li	s3,0
    156c:	b565                	j	1414 <vprintf+0x60>
        s = va_arg(ap, char*);
    156e:	8b4e                	mv	s6,s3
      state = 0;
    1570:	4981                	li	s3,0
    1572:	b54d                	j	1414 <vprintf+0x60>
    }
  }
}
    1574:	70e6                	ld	ra,120(sp)
    1576:	7446                	ld	s0,112(sp)
    1578:	74a6                	ld	s1,104(sp)
    157a:	7906                	ld	s2,96(sp)
    157c:	69e6                	ld	s3,88(sp)
    157e:	6a46                	ld	s4,80(sp)
    1580:	6aa6                	ld	s5,72(sp)
    1582:	6b06                	ld	s6,64(sp)
    1584:	7be2                	ld	s7,56(sp)
    1586:	7c42                	ld	s8,48(sp)
    1588:	7ca2                	ld	s9,40(sp)
    158a:	7d02                	ld	s10,32(sp)
    158c:	6de2                	ld	s11,24(sp)
    158e:	6109                	addi	sp,sp,128
    1590:	8082                	ret

0000000000001592 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1592:	715d                	addi	sp,sp,-80
    1594:	ec06                	sd	ra,24(sp)
    1596:	e822                	sd	s0,16(sp)
    1598:	1000                	addi	s0,sp,32
    159a:	e010                	sd	a2,0(s0)
    159c:	e414                	sd	a3,8(s0)
    159e:	e818                	sd	a4,16(s0)
    15a0:	ec1c                	sd	a5,24(s0)
    15a2:	03043023          	sd	a6,32(s0)
    15a6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    15aa:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    15ae:	8622                	mv	a2,s0
    15b0:	00000097          	auipc	ra,0x0
    15b4:	e04080e7          	jalr	-508(ra) # 13b4 <vprintf>
}
    15b8:	60e2                	ld	ra,24(sp)
    15ba:	6442                	ld	s0,16(sp)
    15bc:	6161                	addi	sp,sp,80
    15be:	8082                	ret

00000000000015c0 <printf>:

void
printf(const char *fmt, ...)
{
    15c0:	711d                	addi	sp,sp,-96
    15c2:	ec06                	sd	ra,24(sp)
    15c4:	e822                	sd	s0,16(sp)
    15c6:	1000                	addi	s0,sp,32
    15c8:	e40c                	sd	a1,8(s0)
    15ca:	e810                	sd	a2,16(s0)
    15cc:	ec14                	sd	a3,24(s0)
    15ce:	f018                	sd	a4,32(s0)
    15d0:	f41c                	sd	a5,40(s0)
    15d2:	03043823          	sd	a6,48(s0)
    15d6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    15da:	00840613          	addi	a2,s0,8
    15de:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    15e2:	85aa                	mv	a1,a0
    15e4:	4505                	li	a0,1
    15e6:	00000097          	auipc	ra,0x0
    15ea:	dce080e7          	jalr	-562(ra) # 13b4 <vprintf>
}
    15ee:	60e2                	ld	ra,24(sp)
    15f0:	6442                	ld	s0,16(sp)
    15f2:	6125                	addi	sp,sp,96
    15f4:	8082                	ret

00000000000015f6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    15f6:	1141                	addi	sp,sp,-16
    15f8:	e422                	sd	s0,8(sp)
    15fa:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    15fc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1600:	00001797          	auipc	a5,0x1
    1604:	9e07b783          	ld	a5,-1568(a5) # 1fe0 <freep>
    1608:	a805                	j	1638 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    160a:	4618                	lw	a4,8(a2)
    160c:	9db9                	addw	a1,a1,a4
    160e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1612:	6398                	ld	a4,0(a5)
    1614:	6318                	ld	a4,0(a4)
    1616:	fee53823          	sd	a4,-16(a0)
    161a:	a091                	j	165e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    161c:	ff852703          	lw	a4,-8(a0)
    1620:	9e39                	addw	a2,a2,a4
    1622:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    1624:	ff053703          	ld	a4,-16(a0)
    1628:	e398                	sd	a4,0(a5)
    162a:	a099                	j	1670 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    162c:	6398                	ld	a4,0(a5)
    162e:	00e7e463          	bltu	a5,a4,1636 <free+0x40>
    1632:	00e6ea63          	bltu	a3,a4,1646 <free+0x50>
{
    1636:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1638:	fed7fae3          	bgeu	a5,a3,162c <free+0x36>
    163c:	6398                	ld	a4,0(a5)
    163e:	00e6e463          	bltu	a3,a4,1646 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1642:	fee7eae3          	bltu	a5,a4,1636 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    1646:	ff852583          	lw	a1,-8(a0)
    164a:	6390                	ld	a2,0(a5)
    164c:	02059813          	slli	a6,a1,0x20
    1650:	01c85713          	srli	a4,a6,0x1c
    1654:	9736                	add	a4,a4,a3
    1656:	fae60ae3          	beq	a2,a4,160a <free+0x14>
    bp->s.ptr = p->s.ptr;
    165a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    165e:	4790                	lw	a2,8(a5)
    1660:	02061593          	slli	a1,a2,0x20
    1664:	01c5d713          	srli	a4,a1,0x1c
    1668:	973e                	add	a4,a4,a5
    166a:	fae689e3          	beq	a3,a4,161c <free+0x26>
  } else
    p->s.ptr = bp;
    166e:	e394                	sd	a3,0(a5)
  freep = p;
    1670:	00001717          	auipc	a4,0x1
    1674:	96f73823          	sd	a5,-1680(a4) # 1fe0 <freep>
}
    1678:	6422                	ld	s0,8(sp)
    167a:	0141                	addi	sp,sp,16
    167c:	8082                	ret

000000000000167e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    167e:	7139                	addi	sp,sp,-64
    1680:	fc06                	sd	ra,56(sp)
    1682:	f822                	sd	s0,48(sp)
    1684:	f426                	sd	s1,40(sp)
    1686:	f04a                	sd	s2,32(sp)
    1688:	ec4e                	sd	s3,24(sp)
    168a:	e852                	sd	s4,16(sp)
    168c:	e456                	sd	s5,8(sp)
    168e:	e05a                	sd	s6,0(sp)
    1690:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1692:	02051493          	slli	s1,a0,0x20
    1696:	9081                	srli	s1,s1,0x20
    1698:	04bd                	addi	s1,s1,15
    169a:	8091                	srli	s1,s1,0x4
    169c:	0014899b          	addiw	s3,s1,1
    16a0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    16a2:	00001517          	auipc	a0,0x1
    16a6:	93e53503          	ld	a0,-1730(a0) # 1fe0 <freep>
    16aa:	c515                	beqz	a0,16d6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    16ac:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    16ae:	4798                	lw	a4,8(a5)
    16b0:	02977f63          	bgeu	a4,s1,16ee <malloc+0x70>
    16b4:	8a4e                	mv	s4,s3
    16b6:	0009871b          	sext.w	a4,s3
    16ba:	6685                	lui	a3,0x1
    16bc:	00d77363          	bgeu	a4,a3,16c2 <malloc+0x44>
    16c0:	6a05                	lui	s4,0x1
    16c2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    16c6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep){
    16ca:	00001917          	auipc	s2,0x1
    16ce:	91690913          	addi	s2,s2,-1770 # 1fe0 <freep>
  if(p == (char*)-1)
    16d2:	5afd                	li	s5,-1
    16d4:	a895                	j	1748 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    16d6:	00001797          	auipc	a5,0x1
    16da:	a0278793          	addi	a5,a5,-1534 # 20d8 <base>
    16de:	00001717          	auipc	a4,0x1
    16e2:	90f73123          	sd	a5,-1790(a4) # 1fe0 <freep>
    16e6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    16e8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    16ec:	b7e1                	j	16b4 <malloc+0x36>
      if(p->s.size == nunits)
    16ee:	02e48c63          	beq	s1,a4,1726 <malloc+0xa8>
        p->s.size -= nunits;
    16f2:	4137073b          	subw	a4,a4,s3
    16f6:	c798                	sw	a4,8(a5)
        p += p->s.size;
    16f8:	02071693          	slli	a3,a4,0x20
    16fc:	01c6d713          	srli	a4,a3,0x1c
    1700:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1702:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1706:	00001717          	auipc	a4,0x1
    170a:	8ca73d23          	sd	a0,-1830(a4) # 1fe0 <freep>
      return (void*)(p + 1);
    170e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0){
        return 0;
      }
    }
  }
}
    1712:	70e2                	ld	ra,56(sp)
    1714:	7442                	ld	s0,48(sp)
    1716:	74a2                	ld	s1,40(sp)
    1718:	7902                	ld	s2,32(sp)
    171a:	69e2                	ld	s3,24(sp)
    171c:	6a42                	ld	s4,16(sp)
    171e:	6aa2                	ld	s5,8(sp)
    1720:	6b02                	ld	s6,0(sp)
    1722:	6121                	addi	sp,sp,64
    1724:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    1726:	6398                	ld	a4,0(a5)
    1728:	e118                	sd	a4,0(a0)
    172a:	bff1                	j	1706 <malloc+0x88>
  hp->s.size = nu;
    172c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  
    1730:	0541                	addi	a0,a0,16
    1732:	00000097          	auipc	ra,0x0
    1736:	ec4080e7          	jalr	-316(ra) # 15f6 <free>
  return freep;
    173a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0){
    173e:	d971                	beqz	a0,1712 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1740:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1742:	4798                	lw	a4,8(a5)
    1744:	fa9775e3          	bgeu	a4,s1,16ee <malloc+0x70>
    if(p == freep){
    1748:	00093703          	ld	a4,0(s2)
    174c:	853e                	mv	a0,a5
    174e:	fef719e3          	bne	a4,a5,1740 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    1752:	8552                	mv	a0,s4
    1754:	00000097          	auipc	ra,0x0
    1758:	b74080e7          	jalr	-1164(ra) # 12c8 <sbrk>
  if(p == (char*)-1)
    175c:	fd5518e3          	bne	a0,s5,172c <malloc+0xae>
        return 0;
    1760:	4501                	li	a0,0
    1762:	bf45                	j	1712 <malloc+0x94>
