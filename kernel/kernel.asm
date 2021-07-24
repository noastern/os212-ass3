
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	18010113          	addi	sp,sp,384 # 8000a180 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	0000a717          	auipc	a4,0xa
    80000056:	fee70713          	addi	a4,a4,-18 # 8000a040 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00007797          	auipc	a5,0x7
    80000068:	a1c78793          	addi	a5,a5,-1508 # 80006a80 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffca7ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dbe78793          	addi	a5,a5,-578 # 80000e6c <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  timerinit();
    800000d8:	00000097          	auipc	ra,0x0
    800000dc:	f44080e7          	jalr	-188(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000e0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000e4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000e6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e8:	30200073          	mret
}
    800000ec:	60a2                	ld	ra,8(sp)
    800000ee:	6402                	ld	s0,0(sp)
    800000f0:	0141                	addi	sp,sp,16
    800000f2:	8082                	ret

00000000800000f4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000f4:	715d                	addi	sp,sp,-80
    800000f6:	e486                	sd	ra,72(sp)
    800000f8:	e0a2                	sd	s0,64(sp)
    800000fa:	fc26                	sd	s1,56(sp)
    800000fc:	f84a                	sd	s2,48(sp)
    800000fe:	f44e                	sd	s3,40(sp)
    80000100:	f052                	sd	s4,32(sp)
    80000102:	ec56                	sd	s5,24(sp)
    80000104:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000106:	04c05663          	blez	a2,80000152 <consolewrite+0x5e>
    8000010a:	8a2a                	mv	s4,a0
    8000010c:	84ae                	mv	s1,a1
    8000010e:	89b2                	mv	s3,a2
    80000110:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000112:	5afd                	li	s5,-1
    80000114:	4685                	li	a3,1
    80000116:	8626                	mv	a2,s1
    80000118:	85d2                	mv	a1,s4
    8000011a:	fbf40513          	addi	a0,s0,-65
    8000011e:	00003097          	auipc	ra,0x3
    80000122:	992080e7          	jalr	-1646(ra) # 80002ab0 <either_copyin>
    80000126:	01550c63          	beq	a0,s5,8000013e <consolewrite+0x4a>
      break;
    uartputc(c);
    8000012a:	fbf44503          	lbu	a0,-65(s0)
    8000012e:	00000097          	auipc	ra,0x0
    80000132:	77a080e7          	jalr	1914(ra) # 800008a8 <uartputc>
  for(i = 0; i < n; i++){
    80000136:	2905                	addiw	s2,s2,1
    80000138:	0485                	addi	s1,s1,1
    8000013a:	fd299de3          	bne	s3,s2,80000114 <consolewrite+0x20>
  }

  return i;
}
    8000013e:	854a                	mv	a0,s2
    80000140:	60a6                	ld	ra,72(sp)
    80000142:	6406                	ld	s0,64(sp)
    80000144:	74e2                	ld	s1,56(sp)
    80000146:	7942                	ld	s2,48(sp)
    80000148:	79a2                	ld	s3,40(sp)
    8000014a:	7a02                	ld	s4,32(sp)
    8000014c:	6ae2                	ld	s5,24(sp)
    8000014e:	6161                	addi	sp,sp,80
    80000150:	8082                	ret
  for(i = 0; i < n; i++){
    80000152:	4901                	li	s2,0
    80000154:	b7ed                	j	8000013e <consolewrite+0x4a>

0000000080000156 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000156:	7159                	addi	sp,sp,-112
    80000158:	f486                	sd	ra,104(sp)
    8000015a:	f0a2                	sd	s0,96(sp)
    8000015c:	eca6                	sd	s1,88(sp)
    8000015e:	e8ca                	sd	s2,80(sp)
    80000160:	e4ce                	sd	s3,72(sp)
    80000162:	e0d2                	sd	s4,64(sp)
    80000164:	fc56                	sd	s5,56(sp)
    80000166:	f85a                	sd	s6,48(sp)
    80000168:	f45e                	sd	s7,40(sp)
    8000016a:	f062                	sd	s8,32(sp)
    8000016c:	ec66                	sd	s9,24(sp)
    8000016e:	e86a                	sd	s10,16(sp)
    80000170:	1880                	addi	s0,sp,112
    80000172:	8aaa                	mv	s5,a0
    80000174:	8a2e                	mv	s4,a1
    80000176:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000178:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000017c:	00012517          	auipc	a0,0x12
    80000180:	00450513          	addi	a0,a0,4 # 80012180 <cons>
    80000184:	00001097          	auipc	ra,0x1
    80000188:	a3e080e7          	jalr	-1474(ra) # 80000bc2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000018c:	00012497          	auipc	s1,0x12
    80000190:	ff448493          	addi	s1,s1,-12 # 80012180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000194:	00012917          	auipc	s2,0x12
    80000198:	08490913          	addi	s2,s2,132 # 80012218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    8000019c:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000019e:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001a0:	4ca9                	li	s9,10
  while(n > 0){
    800001a2:	07305863          	blez	s3,80000212 <consoleread+0xbc>
    while(cons.r == cons.w){
    800001a6:	0984a783          	lw	a5,152(s1)
    800001aa:	09c4a703          	lw	a4,156(s1)
    800001ae:	02f71463          	bne	a4,a5,800001d6 <consoleread+0x80>
      if(myproc()->killed){
    800001b2:	00002097          	auipc	ra,0x2
    800001b6:	c00080e7          	jalr	-1024(ra) # 80001db2 <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	4b0080e7          	jalr	1200(ra) # 80002672 <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef700e3          	beq	a4,a5,800001b2 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001d6:	0017871b          	addiw	a4,a5,1
    800001da:	08e4ac23          	sw	a4,152(s1)
    800001de:	07f7f713          	andi	a4,a5,127
    800001e2:	9726                	add	a4,a4,s1
    800001e4:	01874703          	lbu	a4,24(a4)
    800001e8:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001ec:	077d0563          	beq	s10,s7,80000256 <consoleread+0x100>
    cbuf = c;
    800001f0:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001f4:	4685                	li	a3,1
    800001f6:	f9f40613          	addi	a2,s0,-97
    800001fa:	85d2                	mv	a1,s4
    800001fc:	8556                	mv	a0,s5
    800001fe:	00003097          	auipc	ra,0x3
    80000202:	85c080e7          	jalr	-1956(ra) # 80002a5a <either_copyout>
    80000206:	01850663          	beq	a0,s8,80000212 <consoleread+0xbc>
    dst++;
    8000020a:	0a05                	addi	s4,s4,1
    --n;
    8000020c:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    8000020e:	f99d1ae3          	bne	s10,s9,800001a2 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000212:	00012517          	auipc	a0,0x12
    80000216:	f6e50513          	addi	a0,a0,-146 # 80012180 <cons>
    8000021a:	00001097          	auipc	ra,0x1
    8000021e:	a5c080e7          	jalr	-1444(ra) # 80000c76 <release>

  return target - n;
    80000222:	413b053b          	subw	a0,s6,s3
    80000226:	a811                	j	8000023a <consoleread+0xe4>
        release(&cons.lock);
    80000228:	00012517          	auipc	a0,0x12
    8000022c:	f5850513          	addi	a0,a0,-168 # 80012180 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a46080e7          	jalr	-1466(ra) # 80000c76 <release>
        return -1;
    80000238:	557d                	li	a0,-1
}
    8000023a:	70a6                	ld	ra,104(sp)
    8000023c:	7406                	ld	s0,96(sp)
    8000023e:	64e6                	ld	s1,88(sp)
    80000240:	6946                	ld	s2,80(sp)
    80000242:	69a6                	ld	s3,72(sp)
    80000244:	6a06                	ld	s4,64(sp)
    80000246:	7ae2                	ld	s5,56(sp)
    80000248:	7b42                	ld	s6,48(sp)
    8000024a:	7ba2                	ld	s7,40(sp)
    8000024c:	7c02                	ld	s8,32(sp)
    8000024e:	6ce2                	ld	s9,24(sp)
    80000250:	6d42                	ld	s10,16(sp)
    80000252:	6165                	addi	sp,sp,112
    80000254:	8082                	ret
      if(n < target){
    80000256:	0009871b          	sext.w	a4,s3
    8000025a:	fb677ce3          	bgeu	a4,s6,80000212 <consoleread+0xbc>
        cons.r--;
    8000025e:	00012717          	auipc	a4,0x12
    80000262:	faf72d23          	sw	a5,-70(a4) # 80012218 <cons+0x98>
    80000266:	b775                	j	80000212 <consoleread+0xbc>

0000000080000268 <consputc>:
{
    80000268:	1141                	addi	sp,sp,-16
    8000026a:	e406                	sd	ra,8(sp)
    8000026c:	e022                	sd	s0,0(sp)
    8000026e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000270:	10000793          	li	a5,256
    80000274:	00f50a63          	beq	a0,a5,80000288 <consputc+0x20>
    uartputc_sync(c);
    80000278:	00000097          	auipc	ra,0x0
    8000027c:	55e080e7          	jalr	1374(ra) # 800007d6 <uartputc_sync>
}
    80000280:	60a2                	ld	ra,8(sp)
    80000282:	6402                	ld	s0,0(sp)
    80000284:	0141                	addi	sp,sp,16
    80000286:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000288:	4521                	li	a0,8
    8000028a:	00000097          	auipc	ra,0x0
    8000028e:	54c080e7          	jalr	1356(ra) # 800007d6 <uartputc_sync>
    80000292:	02000513          	li	a0,32
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	540080e7          	jalr	1344(ra) # 800007d6 <uartputc_sync>
    8000029e:	4521                	li	a0,8
    800002a0:	00000097          	auipc	ra,0x0
    800002a4:	536080e7          	jalr	1334(ra) # 800007d6 <uartputc_sync>
    800002a8:	bfe1                	j	80000280 <consputc+0x18>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	e04a                	sd	s2,0(sp)
    800002b4:	1000                	addi	s0,sp,32
    800002b6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b8:	00012517          	auipc	a0,0x12
    800002bc:	ec850513          	addi	a0,a0,-312 # 80012180 <cons>
    800002c0:	00001097          	auipc	ra,0x1
    800002c4:	902080e7          	jalr	-1790(ra) # 80000bc2 <acquire>

  switch(c){
    800002c8:	47d5                	li	a5,21
    800002ca:	0af48663          	beq	s1,a5,80000376 <consoleintr+0xcc>
    800002ce:	0297ca63          	blt	a5,s1,80000302 <consoleintr+0x58>
    800002d2:	47a1                	li	a5,8
    800002d4:	0ef48763          	beq	s1,a5,800003c2 <consoleintr+0x118>
    800002d8:	47c1                	li	a5,16
    800002da:	10f49a63          	bne	s1,a5,800003ee <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002de:	00003097          	auipc	ra,0x3
    800002e2:	828080e7          	jalr	-2008(ra) # 80002b06 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002e6:	00012517          	auipc	a0,0x12
    800002ea:	e9a50513          	addi	a0,a0,-358 # 80012180 <cons>
    800002ee:	00001097          	auipc	ra,0x1
    800002f2:	988080e7          	jalr	-1656(ra) # 80000c76 <release>
}
    800002f6:	60e2                	ld	ra,24(sp)
    800002f8:	6442                	ld	s0,16(sp)
    800002fa:	64a2                	ld	s1,8(sp)
    800002fc:	6902                	ld	s2,0(sp)
    800002fe:	6105                	addi	sp,sp,32
    80000300:	8082                	ret
  switch(c){
    80000302:	07f00793          	li	a5,127
    80000306:	0af48e63          	beq	s1,a5,800003c2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000030a:	00012717          	auipc	a4,0x12
    8000030e:	e7670713          	addi	a4,a4,-394 # 80012180 <cons>
    80000312:	0a072783          	lw	a5,160(a4)
    80000316:	09872703          	lw	a4,152(a4)
    8000031a:	9f99                	subw	a5,a5,a4
    8000031c:	07f00713          	li	a4,127
    80000320:	fcf763e3          	bltu	a4,a5,800002e6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000324:	47b5                	li	a5,13
    80000326:	0cf48763          	beq	s1,a5,800003f4 <consoleintr+0x14a>
      consputc(c);
    8000032a:	8526                	mv	a0,s1
    8000032c:	00000097          	auipc	ra,0x0
    80000330:	f3c080e7          	jalr	-196(ra) # 80000268 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000334:	00012797          	auipc	a5,0x12
    80000338:	e4c78793          	addi	a5,a5,-436 # 80012180 <cons>
    8000033c:	0a07a703          	lw	a4,160(a5)
    80000340:	0017069b          	addiw	a3,a4,1
    80000344:	0006861b          	sext.w	a2,a3
    80000348:	0ad7a023          	sw	a3,160(a5)
    8000034c:	07f77713          	andi	a4,a4,127
    80000350:	97ba                	add	a5,a5,a4
    80000352:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000356:	47a9                	li	a5,10
    80000358:	0cf48563          	beq	s1,a5,80000422 <consoleintr+0x178>
    8000035c:	4791                	li	a5,4
    8000035e:	0cf48263          	beq	s1,a5,80000422 <consoleintr+0x178>
    80000362:	00012797          	auipc	a5,0x12
    80000366:	eb67a783          	lw	a5,-330(a5) # 80012218 <cons+0x98>
    8000036a:	0807879b          	addiw	a5,a5,128
    8000036e:	f6f61ce3          	bne	a2,a5,800002e6 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000372:	863e                	mv	a2,a5
    80000374:	a07d                	j	80000422 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000376:	00012717          	auipc	a4,0x12
    8000037a:	e0a70713          	addi	a4,a4,-502 # 80012180 <cons>
    8000037e:	0a072783          	lw	a5,160(a4)
    80000382:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000386:	00012497          	auipc	s1,0x12
    8000038a:	dfa48493          	addi	s1,s1,-518 # 80012180 <cons>
    while(cons.e != cons.w &&
    8000038e:	4929                	li	s2,10
    80000390:	f4f70be3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000394:	37fd                	addiw	a5,a5,-1
    80000396:	07f7f713          	andi	a4,a5,127
    8000039a:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000039c:	01874703          	lbu	a4,24(a4)
    800003a0:	f52703e3          	beq	a4,s2,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003a4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003a8:	10000513          	li	a0,256
    800003ac:	00000097          	auipc	ra,0x0
    800003b0:	ebc080e7          	jalr	-324(ra) # 80000268 <consputc>
    while(cons.e != cons.w &&
    800003b4:	0a04a783          	lw	a5,160(s1)
    800003b8:	09c4a703          	lw	a4,156(s1)
    800003bc:	fcf71ce3          	bne	a4,a5,80000394 <consoleintr+0xea>
    800003c0:	b71d                	j	800002e6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003c2:	00012717          	auipc	a4,0x12
    800003c6:	dbe70713          	addi	a4,a4,-578 # 80012180 <cons>
    800003ca:	0a072783          	lw	a5,160(a4)
    800003ce:	09c72703          	lw	a4,156(a4)
    800003d2:	f0f70ae3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003d6:	37fd                	addiw	a5,a5,-1
    800003d8:	00012717          	auipc	a4,0x12
    800003dc:	e4f72423          	sw	a5,-440(a4) # 80012220 <cons+0xa0>
      consputc(BACKSPACE);
    800003e0:	10000513          	li	a0,256
    800003e4:	00000097          	auipc	ra,0x0
    800003e8:	e84080e7          	jalr	-380(ra) # 80000268 <consputc>
    800003ec:	bded                	j	800002e6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003ee:	ee048ce3          	beqz	s1,800002e6 <consoleintr+0x3c>
    800003f2:	bf21                	j	8000030a <consoleintr+0x60>
      consputc(c);
    800003f4:	4529                	li	a0,10
    800003f6:	00000097          	auipc	ra,0x0
    800003fa:	e72080e7          	jalr	-398(ra) # 80000268 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003fe:	00012797          	auipc	a5,0x12
    80000402:	d8278793          	addi	a5,a5,-638 # 80012180 <cons>
    80000406:	0a07a703          	lw	a4,160(a5)
    8000040a:	0017069b          	addiw	a3,a4,1
    8000040e:	0006861b          	sext.w	a2,a3
    80000412:	0ad7a023          	sw	a3,160(a5)
    80000416:	07f77713          	andi	a4,a4,127
    8000041a:	97ba                	add	a5,a5,a4
    8000041c:	4729                	li	a4,10
    8000041e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000422:	00012797          	auipc	a5,0x12
    80000426:	dec7ad23          	sw	a2,-518(a5) # 8001221c <cons+0x9c>
        wakeup(&cons.r);
    8000042a:	00012517          	auipc	a0,0x12
    8000042e:	dee50513          	addi	a0,a0,-530 # 80012218 <cons+0x98>
    80000432:	00002097          	auipc	ra,0x2
    80000436:	3cc080e7          	jalr	972(ra) # 800027fe <wakeup>
    8000043a:	b575                	j	800002e6 <consoleintr+0x3c>

000000008000043c <consoleinit>:

void
consoleinit(void)
{
    8000043c:	1141                	addi	sp,sp,-16
    8000043e:	e406                	sd	ra,8(sp)
    80000440:	e022                	sd	s0,0(sp)
    80000442:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000444:	00009597          	auipc	a1,0x9
    80000448:	bcc58593          	addi	a1,a1,-1076 # 80009010 <etext+0x10>
    8000044c:	00012517          	auipc	a0,0x12
    80000450:	d3450513          	addi	a0,a0,-716 # 80012180 <cons>
    80000454:	00000097          	auipc	ra,0x0
    80000458:	6de080e7          	jalr	1758(ra) # 80000b32 <initlock>

  uartinit();
    8000045c:	00000097          	auipc	ra,0x0
    80000460:	32a080e7          	jalr	810(ra) # 80000786 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000464:	0002f797          	auipc	a5,0x2f
    80000468:	cb478793          	addi	a5,a5,-844 # 8002f118 <devsw>
    8000046c:	00000717          	auipc	a4,0x0
    80000470:	cea70713          	addi	a4,a4,-790 # 80000156 <consoleread>
    80000474:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000476:	00000717          	auipc	a4,0x0
    8000047a:	c7e70713          	addi	a4,a4,-898 # 800000f4 <consolewrite>
    8000047e:	ef98                	sd	a4,24(a5)
}
    80000480:	60a2                	ld	ra,8(sp)
    80000482:	6402                	ld	s0,0(sp)
    80000484:	0141                	addi	sp,sp,16
    80000486:	8082                	ret

0000000080000488 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000488:	7179                	addi	sp,sp,-48
    8000048a:	f406                	sd	ra,40(sp)
    8000048c:	f022                	sd	s0,32(sp)
    8000048e:	ec26                	sd	s1,24(sp)
    80000490:	e84a                	sd	s2,16(sp)
    80000492:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80000494:	c219                	beqz	a2,8000049a <printint+0x12>
    80000496:	08054663          	bltz	a0,80000522 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    8000049a:	2501                	sext.w	a0,a0
    8000049c:	4881                	li	a7,0
    8000049e:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004a2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004a4:	2581                	sext.w	a1,a1
    800004a6:	00009617          	auipc	a2,0x9
    800004aa:	b9a60613          	addi	a2,a2,-1126 # 80009040 <digits>
    800004ae:	883a                	mv	a6,a4
    800004b0:	2705                	addiw	a4,a4,1
    800004b2:	02b577bb          	remuw	a5,a0,a1
    800004b6:	1782                	slli	a5,a5,0x20
    800004b8:	9381                	srli	a5,a5,0x20
    800004ba:	97b2                	add	a5,a5,a2
    800004bc:	0007c783          	lbu	a5,0(a5)
    800004c0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004c4:	0005079b          	sext.w	a5,a0
    800004c8:	02b5553b          	divuw	a0,a0,a1
    800004cc:	0685                	addi	a3,a3,1
    800004ce:	feb7f0e3          	bgeu	a5,a1,800004ae <printint+0x26>

  if(sign)
    800004d2:	00088b63          	beqz	a7,800004e8 <printint+0x60>
    buf[i++] = '-';
    800004d6:	fe040793          	addi	a5,s0,-32
    800004da:	973e                	add	a4,a4,a5
    800004dc:	02d00793          	li	a5,45
    800004e0:	fef70823          	sb	a5,-16(a4)
    800004e4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004e8:	02e05763          	blez	a4,80000516 <printint+0x8e>
    800004ec:	fd040793          	addi	a5,s0,-48
    800004f0:	00e784b3          	add	s1,a5,a4
    800004f4:	fff78913          	addi	s2,a5,-1
    800004f8:	993a                	add	s2,s2,a4
    800004fa:	377d                	addiw	a4,a4,-1
    800004fc:	1702                	slli	a4,a4,0x20
    800004fe:	9301                	srli	a4,a4,0x20
    80000500:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000504:	fff4c503          	lbu	a0,-1(s1)
    80000508:	00000097          	auipc	ra,0x0
    8000050c:	d60080e7          	jalr	-672(ra) # 80000268 <consputc>
  while(--i >= 0)
    80000510:	14fd                	addi	s1,s1,-1
    80000512:	ff2499e3          	bne	s1,s2,80000504 <printint+0x7c>
}
    80000516:	70a2                	ld	ra,40(sp)
    80000518:	7402                	ld	s0,32(sp)
    8000051a:	64e2                	ld	s1,24(sp)
    8000051c:	6942                	ld	s2,16(sp)
    8000051e:	6145                	addi	sp,sp,48
    80000520:	8082                	ret
    x = -xx;
    80000522:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000526:	4885                	li	a7,1
    x = -xx;
    80000528:	bf9d                	j	8000049e <printint+0x16>

000000008000052a <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000052a:	1101                	addi	sp,sp,-32
    8000052c:	ec06                	sd	ra,24(sp)
    8000052e:	e822                	sd	s0,16(sp)
    80000530:	e426                	sd	s1,8(sp)
    80000532:	1000                	addi	s0,sp,32
    80000534:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000536:	00012797          	auipc	a5,0x12
    8000053a:	d007a523          	sw	zero,-758(a5) # 80012240 <pr+0x18>
  printf("panic: ");
    8000053e:	00009517          	auipc	a0,0x9
    80000542:	ada50513          	addi	a0,a0,-1318 # 80009018 <etext+0x18>
    80000546:	00000097          	auipc	ra,0x0
    8000054a:	02e080e7          	jalr	46(ra) # 80000574 <printf>
  printf(s);
    8000054e:	8526                	mv	a0,s1
    80000550:	00000097          	auipc	ra,0x0
    80000554:	024080e7          	jalr	36(ra) # 80000574 <printf>
  printf("\n");
    80000558:	00009517          	auipc	a0,0x9
    8000055c:	c2050513          	addi	a0,a0,-992 # 80009178 <digits+0x138>
    80000560:	00000097          	auipc	ra,0x0
    80000564:	014080e7          	jalr	20(ra) # 80000574 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000568:	4785                	li	a5,1
    8000056a:	0000a717          	auipc	a4,0xa
    8000056e:	a8f72b23          	sw	a5,-1386(a4) # 8000a000 <panicked>
  for(;;)
    80000572:	a001                	j	80000572 <panic+0x48>

0000000080000574 <printf>:
{
    80000574:	7131                	addi	sp,sp,-192
    80000576:	fc86                	sd	ra,120(sp)
    80000578:	f8a2                	sd	s0,112(sp)
    8000057a:	f4a6                	sd	s1,104(sp)
    8000057c:	f0ca                	sd	s2,96(sp)
    8000057e:	ecce                	sd	s3,88(sp)
    80000580:	e8d2                	sd	s4,80(sp)
    80000582:	e4d6                	sd	s5,72(sp)
    80000584:	e0da                	sd	s6,64(sp)
    80000586:	fc5e                	sd	s7,56(sp)
    80000588:	f862                	sd	s8,48(sp)
    8000058a:	f466                	sd	s9,40(sp)
    8000058c:	f06a                	sd	s10,32(sp)
    8000058e:	ec6e                	sd	s11,24(sp)
    80000590:	0100                	addi	s0,sp,128
    80000592:	8a2a                	mv	s4,a0
    80000594:	e40c                	sd	a1,8(s0)
    80000596:	e810                	sd	a2,16(s0)
    80000598:	ec14                	sd	a3,24(s0)
    8000059a:	f018                	sd	a4,32(s0)
    8000059c:	f41c                	sd	a5,40(s0)
    8000059e:	03043823          	sd	a6,48(s0)
    800005a2:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005a6:	00012d97          	auipc	s11,0x12
    800005aa:	c9adad83          	lw	s11,-870(s11) # 80012240 <pr+0x18>
  if(locking)
    800005ae:	020d9b63          	bnez	s11,800005e4 <printf+0x70>
  if (fmt == 0)
    800005b2:	040a0263          	beqz	s4,800005f6 <printf+0x82>
  va_start(ap, fmt);
    800005b6:	00840793          	addi	a5,s0,8
    800005ba:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005be:	000a4503          	lbu	a0,0(s4)
    800005c2:	14050f63          	beqz	a0,80000720 <printf+0x1ac>
    800005c6:	4981                	li	s3,0
    if(c != '%'){
    800005c8:	02500a93          	li	s5,37
    switch(c){
    800005cc:	07000b93          	li	s7,112
  consputc('x');
    800005d0:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005d2:	00009b17          	auipc	s6,0x9
    800005d6:	a6eb0b13          	addi	s6,s6,-1426 # 80009040 <digits>
    switch(c){
    800005da:	07300c93          	li	s9,115
    800005de:	06400c13          	li	s8,100
    800005e2:	a82d                	j	8000061c <printf+0xa8>
    acquire(&pr.lock);
    800005e4:	00012517          	auipc	a0,0x12
    800005e8:	c4450513          	addi	a0,a0,-956 # 80012228 <pr>
    800005ec:	00000097          	auipc	ra,0x0
    800005f0:	5d6080e7          	jalr	1494(ra) # 80000bc2 <acquire>
    800005f4:	bf7d                	j	800005b2 <printf+0x3e>
    panic("null fmt");
    800005f6:	00009517          	auipc	a0,0x9
    800005fa:	a3250513          	addi	a0,a0,-1486 # 80009028 <etext+0x28>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	f2c080e7          	jalr	-212(ra) # 8000052a <panic>
      consputc(c);
    80000606:	00000097          	auipc	ra,0x0
    8000060a:	c62080e7          	jalr	-926(ra) # 80000268 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000060e:	2985                	addiw	s3,s3,1
    80000610:	013a07b3          	add	a5,s4,s3
    80000614:	0007c503          	lbu	a0,0(a5)
    80000618:	10050463          	beqz	a0,80000720 <printf+0x1ac>
    if(c != '%'){
    8000061c:	ff5515e3          	bne	a0,s5,80000606 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000620:	2985                	addiw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c783          	lbu	a5,0(a5)
    8000062a:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000062e:	cbed                	beqz	a5,80000720 <printf+0x1ac>
    switch(c){
    80000630:	05778a63          	beq	a5,s7,80000684 <printf+0x110>
    80000634:	02fbf663          	bgeu	s7,a5,80000660 <printf+0xec>
    80000638:	09978863          	beq	a5,s9,800006c8 <printf+0x154>
    8000063c:	07800713          	li	a4,120
    80000640:	0ce79563          	bne	a5,a4,8000070a <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	85ea                	mv	a1,s10
    80000654:	4388                	lw	a0,0(a5)
    80000656:	00000097          	auipc	ra,0x0
    8000065a:	e32080e7          	jalr	-462(ra) # 80000488 <printint>
      break;
    8000065e:	bf45                	j	8000060e <printf+0x9a>
    switch(c){
    80000660:	09578f63          	beq	a5,s5,800006fe <printf+0x18a>
    80000664:	0b879363          	bne	a5,s8,8000070a <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000668:	f8843783          	ld	a5,-120(s0)
    8000066c:	00878713          	addi	a4,a5,8
    80000670:	f8e43423          	sd	a4,-120(s0)
    80000674:	4605                	li	a2,1
    80000676:	45a9                	li	a1,10
    80000678:	4388                	lw	a0,0(a5)
    8000067a:	00000097          	auipc	ra,0x0
    8000067e:	e0e080e7          	jalr	-498(ra) # 80000488 <printint>
      break;
    80000682:	b771                	j	8000060e <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000684:	f8843783          	ld	a5,-120(s0)
    80000688:	00878713          	addi	a4,a5,8
    8000068c:	f8e43423          	sd	a4,-120(s0)
    80000690:	0007b903          	ld	s2,0(a5)
  consputc('0');
    80000694:	03000513          	li	a0,48
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	bd0080e7          	jalr	-1072(ra) # 80000268 <consputc>
  consputc('x');
    800006a0:	07800513          	li	a0,120
    800006a4:	00000097          	auipc	ra,0x0
    800006a8:	bc4080e7          	jalr	-1084(ra) # 80000268 <consputc>
    800006ac:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ae:	03c95793          	srli	a5,s2,0x3c
    800006b2:	97da                	add	a5,a5,s6
    800006b4:	0007c503          	lbu	a0,0(a5)
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bb0080e7          	jalr	-1104(ra) # 80000268 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006c0:	0912                	slli	s2,s2,0x4
    800006c2:	34fd                	addiw	s1,s1,-1
    800006c4:	f4ed                	bnez	s1,800006ae <printf+0x13a>
    800006c6:	b7a1                	j	8000060e <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006c8:	f8843783          	ld	a5,-120(s0)
    800006cc:	00878713          	addi	a4,a5,8
    800006d0:	f8e43423          	sd	a4,-120(s0)
    800006d4:	6384                	ld	s1,0(a5)
    800006d6:	cc89                	beqz	s1,800006f0 <printf+0x17c>
      for(; *s; s++)
    800006d8:	0004c503          	lbu	a0,0(s1)
    800006dc:	d90d                	beqz	a0,8000060e <printf+0x9a>
        consputc(*s);
    800006de:	00000097          	auipc	ra,0x0
    800006e2:	b8a080e7          	jalr	-1142(ra) # 80000268 <consputc>
      for(; *s; s++)
    800006e6:	0485                	addi	s1,s1,1
    800006e8:	0004c503          	lbu	a0,0(s1)
    800006ec:	f96d                	bnez	a0,800006de <printf+0x16a>
    800006ee:	b705                	j	8000060e <printf+0x9a>
        s = "(null)";
    800006f0:	00009497          	auipc	s1,0x9
    800006f4:	93048493          	addi	s1,s1,-1744 # 80009020 <etext+0x20>
      for(; *s; s++)
    800006f8:	02800513          	li	a0,40
    800006fc:	b7cd                	j	800006de <printf+0x16a>
      consputc('%');
    800006fe:	8556                	mv	a0,s5
    80000700:	00000097          	auipc	ra,0x0
    80000704:	b68080e7          	jalr	-1176(ra) # 80000268 <consputc>
      break;
    80000708:	b719                	j	8000060e <printf+0x9a>
      consputc('%');
    8000070a:	8556                	mv	a0,s5
    8000070c:	00000097          	auipc	ra,0x0
    80000710:	b5c080e7          	jalr	-1188(ra) # 80000268 <consputc>
      consputc(c);
    80000714:	8526                	mv	a0,s1
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b52080e7          	jalr	-1198(ra) # 80000268 <consputc>
      break;
    8000071e:	bdc5                	j	8000060e <printf+0x9a>
  if(locking)
    80000720:	020d9163          	bnez	s11,80000742 <printf+0x1ce>
}
    80000724:	70e6                	ld	ra,120(sp)
    80000726:	7446                	ld	s0,112(sp)
    80000728:	74a6                	ld	s1,104(sp)
    8000072a:	7906                	ld	s2,96(sp)
    8000072c:	69e6                	ld	s3,88(sp)
    8000072e:	6a46                	ld	s4,80(sp)
    80000730:	6aa6                	ld	s5,72(sp)
    80000732:	6b06                	ld	s6,64(sp)
    80000734:	7be2                	ld	s7,56(sp)
    80000736:	7c42                	ld	s8,48(sp)
    80000738:	7ca2                	ld	s9,40(sp)
    8000073a:	7d02                	ld	s10,32(sp)
    8000073c:	6de2                	ld	s11,24(sp)
    8000073e:	6129                	addi	sp,sp,192
    80000740:	8082                	ret
    release(&pr.lock);
    80000742:	00012517          	auipc	a0,0x12
    80000746:	ae650513          	addi	a0,a0,-1306 # 80012228 <pr>
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	52c080e7          	jalr	1324(ra) # 80000c76 <release>
}
    80000752:	bfc9                	j	80000724 <printf+0x1b0>

0000000080000754 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000754:	1101                	addi	sp,sp,-32
    80000756:	ec06                	sd	ra,24(sp)
    80000758:	e822                	sd	s0,16(sp)
    8000075a:	e426                	sd	s1,8(sp)
    8000075c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000075e:	00012497          	auipc	s1,0x12
    80000762:	aca48493          	addi	s1,s1,-1334 # 80012228 <pr>
    80000766:	00009597          	auipc	a1,0x9
    8000076a:	8d258593          	addi	a1,a1,-1838 # 80009038 <etext+0x38>
    8000076e:	8526                	mv	a0,s1
    80000770:	00000097          	auipc	ra,0x0
    80000774:	3c2080e7          	jalr	962(ra) # 80000b32 <initlock>
  pr.locking = 1;
    80000778:	4785                	li	a5,1
    8000077a:	cc9c                	sw	a5,24(s1)
}
    8000077c:	60e2                	ld	ra,24(sp)
    8000077e:	6442                	ld	s0,16(sp)
    80000780:	64a2                	ld	s1,8(sp)
    80000782:	6105                	addi	sp,sp,32
    80000784:	8082                	ret

0000000080000786 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000786:	1141                	addi	sp,sp,-16
    80000788:	e406                	sd	ra,8(sp)
    8000078a:	e022                	sd	s0,0(sp)
    8000078c:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000078e:	100007b7          	lui	a5,0x10000
    80000792:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000796:	f8000713          	li	a4,-128
    8000079a:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000079e:	470d                	li	a4,3
    800007a0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007a4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007a8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007ac:	469d                	li	a3,7
    800007ae:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007b2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007b6:	00009597          	auipc	a1,0x9
    800007ba:	8a258593          	addi	a1,a1,-1886 # 80009058 <digits+0x18>
    800007be:	00012517          	auipc	a0,0x12
    800007c2:	a8a50513          	addi	a0,a0,-1398 # 80012248 <uart_tx_lock>
    800007c6:	00000097          	auipc	ra,0x0
    800007ca:	36c080e7          	jalr	876(ra) # 80000b32 <initlock>
}
    800007ce:	60a2                	ld	ra,8(sp)
    800007d0:	6402                	ld	s0,0(sp)
    800007d2:	0141                	addi	sp,sp,16
    800007d4:	8082                	ret

00000000800007d6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007d6:	1101                	addi	sp,sp,-32
    800007d8:	ec06                	sd	ra,24(sp)
    800007da:	e822                	sd	s0,16(sp)
    800007dc:	e426                	sd	s1,8(sp)
    800007de:	1000                	addi	s0,sp,32
    800007e0:	84aa                	mv	s1,a0
  push_off();
    800007e2:	00000097          	auipc	ra,0x0
    800007e6:	394080e7          	jalr	916(ra) # 80000b76 <push_off>

  if(panicked){
    800007ea:	0000a797          	auipc	a5,0xa
    800007ee:	8167a783          	lw	a5,-2026(a5) # 8000a000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007f2:	10000737          	lui	a4,0x10000
  if(panicked){
    800007f6:	c391                	beqz	a5,800007fa <uartputc_sync+0x24>
    for(;;)
    800007f8:	a001                	j	800007f8 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007fa:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800007fe:	0207f793          	andi	a5,a5,32
    80000802:	dfe5                	beqz	a5,800007fa <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000804:	0ff4f513          	andi	a0,s1,255
    80000808:	100007b7          	lui	a5,0x10000
    8000080c:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000810:	00000097          	auipc	ra,0x0
    80000814:	406080e7          	jalr	1030(ra) # 80000c16 <pop_off>
}
    80000818:	60e2                	ld	ra,24(sp)
    8000081a:	6442                	ld	s0,16(sp)
    8000081c:	64a2                	ld	s1,8(sp)
    8000081e:	6105                	addi	sp,sp,32
    80000820:	8082                	ret

0000000080000822 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000822:	00009797          	auipc	a5,0x9
    80000826:	7e67b783          	ld	a5,2022(a5) # 8000a008 <uart_tx_r>
    8000082a:	00009717          	auipc	a4,0x9
    8000082e:	7e673703          	ld	a4,2022(a4) # 8000a010 <uart_tx_w>
    80000832:	06f70a63          	beq	a4,a5,800008a6 <uartstart+0x84>
{
    80000836:	7139                	addi	sp,sp,-64
    80000838:	fc06                	sd	ra,56(sp)
    8000083a:	f822                	sd	s0,48(sp)
    8000083c:	f426                	sd	s1,40(sp)
    8000083e:	f04a                	sd	s2,32(sp)
    80000840:	ec4e                	sd	s3,24(sp)
    80000842:	e852                	sd	s4,16(sp)
    80000844:	e456                	sd	s5,8(sp)
    80000846:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000848:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000084c:	00012a17          	auipc	s4,0x12
    80000850:	9fca0a13          	addi	s4,s4,-1540 # 80012248 <uart_tx_lock>
    uart_tx_r += 1;
    80000854:	00009497          	auipc	s1,0x9
    80000858:	7b448493          	addi	s1,s1,1972 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000085c:	00009997          	auipc	s3,0x9
    80000860:	7b498993          	addi	s3,s3,1972 # 8000a010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000864:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000868:	02077713          	andi	a4,a4,32
    8000086c:	c705                	beqz	a4,80000894 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000086e:	01f7f713          	andi	a4,a5,31
    80000872:	9752                	add	a4,a4,s4
    80000874:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80000878:	0785                	addi	a5,a5,1
    8000087a:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000087c:	8526                	mv	a0,s1
    8000087e:	00002097          	auipc	ra,0x2
    80000882:	f80080e7          	jalr	-128(ra) # 800027fe <wakeup>
    
    WriteReg(THR, c);
    80000886:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000088a:	609c                	ld	a5,0(s1)
    8000088c:	0009b703          	ld	a4,0(s3)
    80000890:	fcf71ae3          	bne	a4,a5,80000864 <uartstart+0x42>
  }
}
    80000894:	70e2                	ld	ra,56(sp)
    80000896:	7442                	ld	s0,48(sp)
    80000898:	74a2                	ld	s1,40(sp)
    8000089a:	7902                	ld	s2,32(sp)
    8000089c:	69e2                	ld	s3,24(sp)
    8000089e:	6a42                	ld	s4,16(sp)
    800008a0:	6aa2                	ld	s5,8(sp)
    800008a2:	6121                	addi	sp,sp,64
    800008a4:	8082                	ret
    800008a6:	8082                	ret

00000000800008a8 <uartputc>:
{
    800008a8:	7179                	addi	sp,sp,-48
    800008aa:	f406                	sd	ra,40(sp)
    800008ac:	f022                	sd	s0,32(sp)
    800008ae:	ec26                	sd	s1,24(sp)
    800008b0:	e84a                	sd	s2,16(sp)
    800008b2:	e44e                	sd	s3,8(sp)
    800008b4:	e052                	sd	s4,0(sp)
    800008b6:	1800                	addi	s0,sp,48
    800008b8:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ba:	00012517          	auipc	a0,0x12
    800008be:	98e50513          	addi	a0,a0,-1650 # 80012248 <uart_tx_lock>
    800008c2:	00000097          	auipc	ra,0x0
    800008c6:	300080e7          	jalr	768(ra) # 80000bc2 <acquire>
  if(panicked){
    800008ca:	00009797          	auipc	a5,0x9
    800008ce:	7367a783          	lw	a5,1846(a5) # 8000a000 <panicked>
    800008d2:	c391                	beqz	a5,800008d6 <uartputc+0x2e>
    for(;;)
    800008d4:	a001                	j	800008d4 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008d6:	00009717          	auipc	a4,0x9
    800008da:	73a73703          	ld	a4,1850(a4) # 8000a010 <uart_tx_w>
    800008de:	00009797          	auipc	a5,0x9
    800008e2:	72a7b783          	ld	a5,1834(a5) # 8000a008 <uart_tx_r>
    800008e6:	02078793          	addi	a5,a5,32
    800008ea:	02e79b63          	bne	a5,a4,80000920 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008ee:	00012997          	auipc	s3,0x12
    800008f2:	95a98993          	addi	s3,s3,-1702 # 80012248 <uart_tx_lock>
    800008f6:	00009497          	auipc	s1,0x9
    800008fa:	71248493          	addi	s1,s1,1810 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fe:	00009917          	auipc	s2,0x9
    80000902:	71290913          	addi	s2,s2,1810 # 8000a010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000906:	85ce                	mv	a1,s3
    80000908:	8526                	mv	a0,s1
    8000090a:	00002097          	auipc	ra,0x2
    8000090e:	d68080e7          	jalr	-664(ra) # 80002672 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000912:	00093703          	ld	a4,0(s2)
    80000916:	609c                	ld	a5,0(s1)
    80000918:	02078793          	addi	a5,a5,32
    8000091c:	fee785e3          	beq	a5,a4,80000906 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000920:	00012497          	auipc	s1,0x12
    80000924:	92848493          	addi	s1,s1,-1752 # 80012248 <uart_tx_lock>
    80000928:	01f77793          	andi	a5,a4,31
    8000092c:	97a6                	add	a5,a5,s1
    8000092e:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000932:	0705                	addi	a4,a4,1
    80000934:	00009797          	auipc	a5,0x9
    80000938:	6ce7be23          	sd	a4,1756(a5) # 8000a010 <uart_tx_w>
      uartstart();
    8000093c:	00000097          	auipc	ra,0x0
    80000940:	ee6080e7          	jalr	-282(ra) # 80000822 <uartstart>
      release(&uart_tx_lock);
    80000944:	8526                	mv	a0,s1
    80000946:	00000097          	auipc	ra,0x0
    8000094a:	330080e7          	jalr	816(ra) # 80000c76 <release>
}
    8000094e:	70a2                	ld	ra,40(sp)
    80000950:	7402                	ld	s0,32(sp)
    80000952:	64e2                	ld	s1,24(sp)
    80000954:	6942                	ld	s2,16(sp)
    80000956:	69a2                	ld	s3,8(sp)
    80000958:	6a02                	ld	s4,0(sp)
    8000095a:	6145                	addi	sp,sp,48
    8000095c:	8082                	ret

000000008000095e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000095e:	1141                	addi	sp,sp,-16
    80000960:	e422                	sd	s0,8(sp)
    80000962:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000964:	100007b7          	lui	a5,0x10000
    80000968:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000096c:	8b85                	andi	a5,a5,1
    8000096e:	cb91                	beqz	a5,80000982 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000970:	100007b7          	lui	a5,0x10000
    80000974:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000978:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000097c:	6422                	ld	s0,8(sp)
    8000097e:	0141                	addi	sp,sp,16
    80000980:	8082                	ret
    return -1;
    80000982:	557d                	li	a0,-1
    80000984:	bfe5                	j	8000097c <uartgetc+0x1e>

0000000080000986 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000986:	1101                	addi	sp,sp,-32
    80000988:	ec06                	sd	ra,24(sp)
    8000098a:	e822                	sd	s0,16(sp)
    8000098c:	e426                	sd	s1,8(sp)
    8000098e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000990:	54fd                	li	s1,-1
    80000992:	a029                	j	8000099c <uartintr+0x16>
      break;
    consoleintr(c);
    80000994:	00000097          	auipc	ra,0x0
    80000998:	916080e7          	jalr	-1770(ra) # 800002aa <consoleintr>
    int c = uartgetc();
    8000099c:	00000097          	auipc	ra,0x0
    800009a0:	fc2080e7          	jalr	-62(ra) # 8000095e <uartgetc>
    if(c == -1)
    800009a4:	fe9518e3          	bne	a0,s1,80000994 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009a8:	00012497          	auipc	s1,0x12
    800009ac:	8a048493          	addi	s1,s1,-1888 # 80012248 <uart_tx_lock>
    800009b0:	8526                	mv	a0,s1
    800009b2:	00000097          	auipc	ra,0x0
    800009b6:	210080e7          	jalr	528(ra) # 80000bc2 <acquire>
  uartstart();
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	e68080e7          	jalr	-408(ra) # 80000822 <uartstart>
  release(&uart_tx_lock);
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	2b2080e7          	jalr	690(ra) # 80000c76 <release>
}
    800009cc:	60e2                	ld	ra,24(sp)
    800009ce:	6442                	ld	s0,16(sp)
    800009d0:	64a2                	ld	s1,8(sp)
    800009d2:	6105                	addi	sp,sp,32
    800009d4:	8082                	ret

00000000800009d6 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009d6:	1101                	addi	sp,sp,-32
    800009d8:	ec06                	sd	ra,24(sp)
    800009da:	e822                	sd	s0,16(sp)
    800009dc:	e426                	sd	s1,8(sp)
    800009de:	e04a                	sd	s2,0(sp)
    800009e0:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009e2:	03451793          	slli	a5,a0,0x34
    800009e6:	ebb9                	bnez	a5,80000a3c <kfree+0x66>
    800009e8:	84aa                	mv	s1,a0
    800009ea:	00033797          	auipc	a5,0x33
    800009ee:	61678793          	addi	a5,a5,1558 # 80034000 <end>
    800009f2:	04f56563          	bltu	a0,a5,80000a3c <kfree+0x66>
    800009f6:	47c5                	li	a5,17
    800009f8:	07ee                	slli	a5,a5,0x1b
    800009fa:	04f57163          	bgeu	a0,a5,80000a3c <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800009fe:	6605                	lui	a2,0x1
    80000a00:	4585                	li	a1,1
    80000a02:	00000097          	auipc	ra,0x0
    80000a06:	2bc080e7          	jalr	700(ra) # 80000cbe <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a0a:	00012917          	auipc	s2,0x12
    80000a0e:	87690913          	addi	s2,s2,-1930 # 80012280 <kmem>
    80000a12:	854a                	mv	a0,s2
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	1ae080e7          	jalr	430(ra) # 80000bc2 <acquire>
  r->next = kmem.freelist;
    80000a1c:	01893783          	ld	a5,24(s2)
    80000a20:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a22:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	24e080e7          	jalr	590(ra) # 80000c76 <release>
}
    80000a30:	60e2                	ld	ra,24(sp)
    80000a32:	6442                	ld	s0,16(sp)
    80000a34:	64a2                	ld	s1,8(sp)
    80000a36:	6902                	ld	s2,0(sp)
    80000a38:	6105                	addi	sp,sp,32
    80000a3a:	8082                	ret
    panic("kfree");
    80000a3c:	00008517          	auipc	a0,0x8
    80000a40:	62450513          	addi	a0,a0,1572 # 80009060 <digits+0x20>
    80000a44:	00000097          	auipc	ra,0x0
    80000a48:	ae6080e7          	jalr	-1306(ra) # 8000052a <panic>

0000000080000a4c <freerange>:
{
    80000a4c:	7179                	addi	sp,sp,-48
    80000a4e:	f406                	sd	ra,40(sp)
    80000a50:	f022                	sd	s0,32(sp)
    80000a52:	ec26                	sd	s1,24(sp)
    80000a54:	e84a                	sd	s2,16(sp)
    80000a56:	e44e                	sd	s3,8(sp)
    80000a58:	e052                	sd	s4,0(sp)
    80000a5a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a5c:	6785                	lui	a5,0x1
    80000a5e:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a62:	94aa                	add	s1,s1,a0
    80000a64:	757d                	lui	a0,0xfffff
    80000a66:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a68:	94be                	add	s1,s1,a5
    80000a6a:	0095ee63          	bltu	a1,s1,80000a86 <freerange+0x3a>
    80000a6e:	892e                	mv	s2,a1
    kfree(p);
    80000a70:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a72:	6985                	lui	s3,0x1
    kfree(p);
    80000a74:	01448533          	add	a0,s1,s4
    80000a78:	00000097          	auipc	ra,0x0
    80000a7c:	f5e080e7          	jalr	-162(ra) # 800009d6 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a80:	94ce                	add	s1,s1,s3
    80000a82:	fe9979e3          	bgeu	s2,s1,80000a74 <freerange+0x28>
}
    80000a86:	70a2                	ld	ra,40(sp)
    80000a88:	7402                	ld	s0,32(sp)
    80000a8a:	64e2                	ld	s1,24(sp)
    80000a8c:	6942                	ld	s2,16(sp)
    80000a8e:	69a2                	ld	s3,8(sp)
    80000a90:	6a02                	ld	s4,0(sp)
    80000a92:	6145                	addi	sp,sp,48
    80000a94:	8082                	ret

0000000080000a96 <kinit>:
{
    80000a96:	1141                	addi	sp,sp,-16
    80000a98:	e406                	sd	ra,8(sp)
    80000a9a:	e022                	sd	s0,0(sp)
    80000a9c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a9e:	00008597          	auipc	a1,0x8
    80000aa2:	5ca58593          	addi	a1,a1,1482 # 80009068 <digits+0x28>
    80000aa6:	00011517          	auipc	a0,0x11
    80000aaa:	7da50513          	addi	a0,a0,2010 # 80012280 <kmem>
    80000aae:	00000097          	auipc	ra,0x0
    80000ab2:	084080e7          	jalr	132(ra) # 80000b32 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ab6:	45c5                	li	a1,17
    80000ab8:	05ee                	slli	a1,a1,0x1b
    80000aba:	00033517          	auipc	a0,0x33
    80000abe:	54650513          	addi	a0,a0,1350 # 80034000 <end>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	f8a080e7          	jalr	-118(ra) # 80000a4c <freerange>
}
    80000aca:	60a2                	ld	ra,8(sp)
    80000acc:	6402                	ld	s0,0(sp)
    80000ace:	0141                	addi	sp,sp,16
    80000ad0:	8082                	ret

0000000080000ad2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ad2:	1101                	addi	sp,sp,-32
    80000ad4:	ec06                	sd	ra,24(sp)
    80000ad6:	e822                	sd	s0,16(sp)
    80000ad8:	e426                	sd	s1,8(sp)
    80000ada:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000adc:	00011497          	auipc	s1,0x11
    80000ae0:	7a448493          	addi	s1,s1,1956 # 80012280 <kmem>
    80000ae4:	8526                	mv	a0,s1
    80000ae6:	00000097          	auipc	ra,0x0
    80000aea:	0dc080e7          	jalr	220(ra) # 80000bc2 <acquire>
  r = kmem.freelist;
    80000aee:	6c84                	ld	s1,24(s1)
  if(r)
    80000af0:	c885                	beqz	s1,80000b20 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000af2:	609c                	ld	a5,0(s1)
    80000af4:	00011517          	auipc	a0,0x11
    80000af8:	78c50513          	addi	a0,a0,1932 # 80012280 <kmem>
    80000afc:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	178080e7          	jalr	376(ra) # 80000c76 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b06:	6605                	lui	a2,0x1
    80000b08:	4595                	li	a1,5
    80000b0a:	8526                	mv	a0,s1
    80000b0c:	00000097          	auipc	ra,0x0
    80000b10:	1b2080e7          	jalr	434(ra) # 80000cbe <memset>
  return (void*)r;
}
    80000b14:	8526                	mv	a0,s1
    80000b16:	60e2                	ld	ra,24(sp)
    80000b18:	6442                	ld	s0,16(sp)
    80000b1a:	64a2                	ld	s1,8(sp)
    80000b1c:	6105                	addi	sp,sp,32
    80000b1e:	8082                	ret
  release(&kmem.lock);
    80000b20:	00011517          	auipc	a0,0x11
    80000b24:	76050513          	addi	a0,a0,1888 # 80012280 <kmem>
    80000b28:	00000097          	auipc	ra,0x0
    80000b2c:	14e080e7          	jalr	334(ra) # 80000c76 <release>
  if(r)
    80000b30:	b7d5                	j	80000b14 <kalloc+0x42>

0000000080000b32 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b32:	1141                	addi	sp,sp,-16
    80000b34:	e422                	sd	s0,8(sp)
    80000b36:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b38:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b3a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b3e:	00053823          	sd	zero,16(a0)
}
    80000b42:	6422                	ld	s0,8(sp)
    80000b44:	0141                	addi	sp,sp,16
    80000b46:	8082                	ret

0000000080000b48 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b48:	411c                	lw	a5,0(a0)
    80000b4a:	e399                	bnez	a5,80000b50 <holding+0x8>
    80000b4c:	4501                	li	a0,0
  return r;
}
    80000b4e:	8082                	ret
{
    80000b50:	1101                	addi	sp,sp,-32
    80000b52:	ec06                	sd	ra,24(sp)
    80000b54:	e822                	sd	s0,16(sp)
    80000b56:	e426                	sd	s1,8(sp)
    80000b58:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b5a:	6904                	ld	s1,16(a0)
    80000b5c:	00001097          	auipc	ra,0x1
    80000b60:	23a080e7          	jalr	570(ra) # 80001d96 <mycpu>
    80000b64:	40a48533          	sub	a0,s1,a0
    80000b68:	00153513          	seqz	a0,a0
}
    80000b6c:	60e2                	ld	ra,24(sp)
    80000b6e:	6442                	ld	s0,16(sp)
    80000b70:	64a2                	ld	s1,8(sp)
    80000b72:	6105                	addi	sp,sp,32
    80000b74:	8082                	ret

0000000080000b76 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b76:	1101                	addi	sp,sp,-32
    80000b78:	ec06                	sd	ra,24(sp)
    80000b7a:	e822                	sd	s0,16(sp)
    80000b7c:	e426                	sd	s1,8(sp)
    80000b7e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b80:	100024f3          	csrr	s1,sstatus
    80000b84:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b88:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b8a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b8e:	00001097          	auipc	ra,0x1
    80000b92:	208080e7          	jalr	520(ra) # 80001d96 <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	1fc080e7          	jalr	508(ra) # 80001d96 <mycpu>
    80000ba2:	5d3c                	lw	a5,120(a0)
    80000ba4:	2785                	addiw	a5,a5,1
    80000ba6:	dd3c                	sw	a5,120(a0)
}
    80000ba8:	60e2                	ld	ra,24(sp)
    80000baa:	6442                	ld	s0,16(sp)
    80000bac:	64a2                	ld	s1,8(sp)
    80000bae:	6105                	addi	sp,sp,32
    80000bb0:	8082                	ret
    mycpu()->intena = old;
    80000bb2:	00001097          	auipc	ra,0x1
    80000bb6:	1e4080e7          	jalr	484(ra) # 80001d96 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bba:	8085                	srli	s1,s1,0x1
    80000bbc:	8885                	andi	s1,s1,1
    80000bbe:	dd64                	sw	s1,124(a0)
    80000bc0:	bfe9                	j	80000b9a <push_off+0x24>

0000000080000bc2 <acquire>:
{
    80000bc2:	1101                	addi	sp,sp,-32
    80000bc4:	ec06                	sd	ra,24(sp)
    80000bc6:	e822                	sd	s0,16(sp)
    80000bc8:	e426                	sd	s1,8(sp)
    80000bca:	1000                	addi	s0,sp,32
    80000bcc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bce:	00000097          	auipc	ra,0x0
    80000bd2:	fa8080e7          	jalr	-88(ra) # 80000b76 <push_off>
  if(holding(lk))
    80000bd6:	8526                	mv	a0,s1
    80000bd8:	00000097          	auipc	ra,0x0
    80000bdc:	f70080e7          	jalr	-144(ra) # 80000b48 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be0:	4705                	li	a4,1
  if(holding(lk))
    80000be2:	e115                	bnez	a0,80000c06 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	87ba                	mv	a5,a4
    80000be6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bea:	2781                	sext.w	a5,a5
    80000bec:	ffe5                	bnez	a5,80000be4 <acquire+0x22>
  __sync_synchronize();
    80000bee:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bf2:	00001097          	auipc	ra,0x1
    80000bf6:	1a4080e7          	jalr	420(ra) # 80001d96 <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00008517          	auipc	a0,0x8
    80000c0a:	46a50513          	addi	a0,a0,1130 # 80009070 <digits+0x30>
    80000c0e:	00000097          	auipc	ra,0x0
    80000c12:	91c080e7          	jalr	-1764(ra) # 8000052a <panic>

0000000080000c16 <pop_off>:

void
pop_off(void)
{
    80000c16:	1141                	addi	sp,sp,-16
    80000c18:	e406                	sd	ra,8(sp)
    80000c1a:	e022                	sd	s0,0(sp)
    80000c1c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1e:	00001097          	auipc	ra,0x1
    80000c22:	178080e7          	jalr	376(ra) # 80001d96 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c26:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c2a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c2c:	e78d                	bnez	a5,80000c56 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c2e:	5d3c                	lw	a5,120(a0)
    80000c30:	02f05b63          	blez	a5,80000c66 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c34:	37fd                	addiw	a5,a5,-1
    80000c36:	0007871b          	sext.w	a4,a5
    80000c3a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c3c:	eb09                	bnez	a4,80000c4e <pop_off+0x38>
    80000c3e:	5d7c                	lw	a5,124(a0)
    80000c40:	c799                	beqz	a5,80000c4e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c42:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c46:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c4a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c4e:	60a2                	ld	ra,8(sp)
    80000c50:	6402                	ld	s0,0(sp)
    80000c52:	0141                	addi	sp,sp,16
    80000c54:	8082                	ret
    panic("pop_off - interruptible");
    80000c56:	00008517          	auipc	a0,0x8
    80000c5a:	42250513          	addi	a0,a0,1058 # 80009078 <digits+0x38>
    80000c5e:	00000097          	auipc	ra,0x0
    80000c62:	8cc080e7          	jalr	-1844(ra) # 8000052a <panic>
    panic("pop_off");
    80000c66:	00008517          	auipc	a0,0x8
    80000c6a:	42a50513          	addi	a0,a0,1066 # 80009090 <digits+0x50>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8bc080e7          	jalr	-1860(ra) # 8000052a <panic>

0000000080000c76 <release>:
{
    80000c76:	1101                	addi	sp,sp,-32
    80000c78:	ec06                	sd	ra,24(sp)
    80000c7a:	e822                	sd	s0,16(sp)
    80000c7c:	e426                	sd	s1,8(sp)
    80000c7e:	1000                	addi	s0,sp,32
    80000c80:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	ec6080e7          	jalr	-314(ra) # 80000b48 <holding>
    80000c8a:	c115                	beqz	a0,80000cae <release+0x38>
  lk->cpu = 0;
    80000c8c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c90:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c94:	0f50000f          	fence	iorw,ow
    80000c98:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c9c:	00000097          	auipc	ra,0x0
    80000ca0:	f7a080e7          	jalr	-134(ra) # 80000c16 <pop_off>
}
    80000ca4:	60e2                	ld	ra,24(sp)
    80000ca6:	6442                	ld	s0,16(sp)
    80000ca8:	64a2                	ld	s1,8(sp)
    80000caa:	6105                	addi	sp,sp,32
    80000cac:	8082                	ret
    panic("release");
    80000cae:	00008517          	auipc	a0,0x8
    80000cb2:	3ea50513          	addi	a0,a0,1002 # 80009098 <digits+0x58>
    80000cb6:	00000097          	auipc	ra,0x0
    80000cba:	874080e7          	jalr	-1932(ra) # 8000052a <panic>

0000000080000cbe <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cbe:	1141                	addi	sp,sp,-16
    80000cc0:	e422                	sd	s0,8(sp)
    80000cc2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cc4:	ca19                	beqz	a2,80000cda <memset+0x1c>
    80000cc6:	87aa                	mv	a5,a0
    80000cc8:	1602                	slli	a2,a2,0x20
    80000cca:	9201                	srli	a2,a2,0x20
    80000ccc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cd0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cd4:	0785                	addi	a5,a5,1
    80000cd6:	fee79de3          	bne	a5,a4,80000cd0 <memset+0x12>
  }
  return dst;
}
    80000cda:	6422                	ld	s0,8(sp)
    80000cdc:	0141                	addi	sp,sp,16
    80000cde:	8082                	ret

0000000080000ce0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000ce0:	1141                	addi	sp,sp,-16
    80000ce2:	e422                	sd	s0,8(sp)
    80000ce4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000ce6:	ca05                	beqz	a2,80000d16 <memcmp+0x36>
    80000ce8:	fff6069b          	addiw	a3,a2,-1
    80000cec:	1682                	slli	a3,a3,0x20
    80000cee:	9281                	srli	a3,a3,0x20
    80000cf0:	0685                	addi	a3,a3,1
    80000cf2:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cf4:	00054783          	lbu	a5,0(a0)
    80000cf8:	0005c703          	lbu	a4,0(a1)
    80000cfc:	00e79863          	bne	a5,a4,80000d0c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d00:	0505                	addi	a0,a0,1
    80000d02:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d04:	fed518e3          	bne	a0,a3,80000cf4 <memcmp+0x14>
  }

  return 0;
    80000d08:	4501                	li	a0,0
    80000d0a:	a019                	j	80000d10 <memcmp+0x30>
      return *s1 - *s2;
    80000d0c:	40e7853b          	subw	a0,a5,a4
}
    80000d10:	6422                	ld	s0,8(sp)
    80000d12:	0141                	addi	sp,sp,16
    80000d14:	8082                	ret
  return 0;
    80000d16:	4501                	li	a0,0
    80000d18:	bfe5                	j	80000d10 <memcmp+0x30>

0000000080000d1a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d1a:	1141                	addi	sp,sp,-16
    80000d1c:	e422                	sd	s0,8(sp)
    80000d1e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d20:	02a5e563          	bltu	a1,a0,80000d4a <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d24:	fff6069b          	addiw	a3,a2,-1
    80000d28:	ce11                	beqz	a2,80000d44 <memmove+0x2a>
    80000d2a:	1682                	slli	a3,a3,0x20
    80000d2c:	9281                	srli	a3,a3,0x20
    80000d2e:	0685                	addi	a3,a3,1
    80000d30:	96ae                	add	a3,a3,a1
    80000d32:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d34:	0585                	addi	a1,a1,1
    80000d36:	0785                	addi	a5,a5,1
    80000d38:	fff5c703          	lbu	a4,-1(a1)
    80000d3c:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000d40:	fed59ae3          	bne	a1,a3,80000d34 <memmove+0x1a>

  return dst;
}
    80000d44:	6422                	ld	s0,8(sp)
    80000d46:	0141                	addi	sp,sp,16
    80000d48:	8082                	ret
  if(s < d && s + n > d){
    80000d4a:	02061713          	slli	a4,a2,0x20
    80000d4e:	9301                	srli	a4,a4,0x20
    80000d50:	00e587b3          	add	a5,a1,a4
    80000d54:	fcf578e3          	bgeu	a0,a5,80000d24 <memmove+0xa>
    d += n;
    80000d58:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000d5a:	fff6069b          	addiw	a3,a2,-1
    80000d5e:	d27d                	beqz	a2,80000d44 <memmove+0x2a>
    80000d60:	02069613          	slli	a2,a3,0x20
    80000d64:	9201                	srli	a2,a2,0x20
    80000d66:	fff64613          	not	a2,a2
    80000d6a:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000d6c:	17fd                	addi	a5,a5,-1
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	0007c683          	lbu	a3,0(a5)
    80000d74:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000d78:	fef61ae3          	bne	a2,a5,80000d6c <memmove+0x52>
    80000d7c:	b7e1                	j	80000d44 <memmove+0x2a>

0000000080000d7e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d7e:	1141                	addi	sp,sp,-16
    80000d80:	e406                	sd	ra,8(sp)
    80000d82:	e022                	sd	s0,0(sp)
    80000d84:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d86:	00000097          	auipc	ra,0x0
    80000d8a:	f94080e7          	jalr	-108(ra) # 80000d1a <memmove>
}
    80000d8e:	60a2                	ld	ra,8(sp)
    80000d90:	6402                	ld	s0,0(sp)
    80000d92:	0141                	addi	sp,sp,16
    80000d94:	8082                	ret

0000000080000d96 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d96:	1141                	addi	sp,sp,-16
    80000d98:	e422                	sd	s0,8(sp)
    80000d9a:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9c:	ce11                	beqz	a2,80000db8 <strncmp+0x22>
    80000d9e:	00054783          	lbu	a5,0(a0)
    80000da2:	cf89                	beqz	a5,80000dbc <strncmp+0x26>
    80000da4:	0005c703          	lbu	a4,0(a1)
    80000da8:	00f71a63          	bne	a4,a5,80000dbc <strncmp+0x26>
    n--, p++, q++;
    80000dac:	367d                	addiw	a2,a2,-1
    80000dae:	0505                	addi	a0,a0,1
    80000db0:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db2:	f675                	bnez	a2,80000d9e <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db4:	4501                	li	a0,0
    80000db6:	a809                	j	80000dc8 <strncmp+0x32>
    80000db8:	4501                	li	a0,0
    80000dba:	a039                	j	80000dc8 <strncmp+0x32>
  if(n == 0)
    80000dbc:	ca09                	beqz	a2,80000dce <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dbe:	00054503          	lbu	a0,0(a0)
    80000dc2:	0005c783          	lbu	a5,0(a1)
    80000dc6:	9d1d                	subw	a0,a0,a5
}
    80000dc8:	6422                	ld	s0,8(sp)
    80000dca:	0141                	addi	sp,sp,16
    80000dcc:	8082                	ret
    return 0;
    80000dce:	4501                	li	a0,0
    80000dd0:	bfe5                	j	80000dc8 <strncmp+0x32>

0000000080000dd2 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dd2:	1141                	addi	sp,sp,-16
    80000dd4:	e422                	sd	s0,8(sp)
    80000dd6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd8:	872a                	mv	a4,a0
    80000dda:	8832                	mv	a6,a2
    80000ddc:	367d                	addiw	a2,a2,-1
    80000dde:	01005963          	blez	a6,80000df0 <strncpy+0x1e>
    80000de2:	0705                	addi	a4,a4,1
    80000de4:	0005c783          	lbu	a5,0(a1)
    80000de8:	fef70fa3          	sb	a5,-1(a4)
    80000dec:	0585                	addi	a1,a1,1
    80000dee:	f7f5                	bnez	a5,80000dda <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df0:	86ba                	mv	a3,a4
    80000df2:	00c05c63          	blez	a2,80000e0a <strncpy+0x38>
    *s++ = 0;
    80000df6:	0685                	addi	a3,a3,1
    80000df8:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000dfc:	fff6c793          	not	a5,a3
    80000e00:	9fb9                	addw	a5,a5,a4
    80000e02:	010787bb          	addw	a5,a5,a6
    80000e06:	fef048e3          	bgtz	a5,80000df6 <strncpy+0x24>
  return os;
}
    80000e0a:	6422                	ld	s0,8(sp)
    80000e0c:	0141                	addi	sp,sp,16
    80000e0e:	8082                	ret

0000000080000e10 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e10:	1141                	addi	sp,sp,-16
    80000e12:	e422                	sd	s0,8(sp)
    80000e14:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e16:	02c05363          	blez	a2,80000e3c <safestrcpy+0x2c>
    80000e1a:	fff6069b          	addiw	a3,a2,-1
    80000e1e:	1682                	slli	a3,a3,0x20
    80000e20:	9281                	srli	a3,a3,0x20
    80000e22:	96ae                	add	a3,a3,a1
    80000e24:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e26:	00d58963          	beq	a1,a3,80000e38 <safestrcpy+0x28>
    80000e2a:	0585                	addi	a1,a1,1
    80000e2c:	0785                	addi	a5,a5,1
    80000e2e:	fff5c703          	lbu	a4,-1(a1)
    80000e32:	fee78fa3          	sb	a4,-1(a5)
    80000e36:	fb65                	bnez	a4,80000e26 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e38:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e3c:	6422                	ld	s0,8(sp)
    80000e3e:	0141                	addi	sp,sp,16
    80000e40:	8082                	ret

0000000080000e42 <strlen>:

int
strlen(const char *s)
{
    80000e42:	1141                	addi	sp,sp,-16
    80000e44:	e422                	sd	s0,8(sp)
    80000e46:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e48:	00054783          	lbu	a5,0(a0)
    80000e4c:	cf91                	beqz	a5,80000e68 <strlen+0x26>
    80000e4e:	0505                	addi	a0,a0,1
    80000e50:	87aa                	mv	a5,a0
    80000e52:	4685                	li	a3,1
    80000e54:	9e89                	subw	a3,a3,a0
    80000e56:	00f6853b          	addw	a0,a3,a5
    80000e5a:	0785                	addi	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	fb7d                	bnez	a4,80000e56 <strlen+0x14>
    ;
  return n;
}
    80000e62:	6422                	ld	s0,8(sp)
    80000e64:	0141                	addi	sp,sp,16
    80000e66:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e68:	4501                	li	a0,0
    80000e6a:	bfe5                	j	80000e62 <strlen+0x20>

0000000080000e6c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e6c:	1141                	addi	sp,sp,-16
    80000e6e:	e406                	sd	ra,8(sp)
    80000e70:	e022                	sd	s0,0(sp)
    80000e72:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e74:	00001097          	auipc	ra,0x1
    80000e78:	f12080e7          	jalr	-238(ra) # 80001d86 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e7c:	00009717          	auipc	a4,0x9
    80000e80:	19c70713          	addi	a4,a4,412 # 8000a018 <started>
  if(cpuid() == 0){
    80000e84:	c139                	beqz	a0,80000eca <main+0x5e>
    while(started == 0)
    80000e86:	431c                	lw	a5,0(a4)
    80000e88:	2781                	sext.w	a5,a5
    80000e8a:	dff5                	beqz	a5,80000e86 <main+0x1a>
      ;
    __sync_synchronize();
    80000e8c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e90:	00001097          	auipc	ra,0x1
    80000e94:	ef6080e7          	jalr	-266(ra) # 80001d86 <cpuid>
    80000e98:	85aa                	mv	a1,a0
    80000e9a:	00008517          	auipc	a0,0x8
    80000e9e:	21e50513          	addi	a0,a0,542 # 800090b8 <digits+0x78>
    80000ea2:	fffff097          	auipc	ra,0xfffff
    80000ea6:	6d2080e7          	jalr	1746(ra) # 80000574 <printf>
    kvminithart();    // turn on paging
    80000eaa:	00000097          	auipc	ra,0x0
    80000eae:	0d8080e7          	jalr	216(ra) # 80000f82 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb2:	00002097          	auipc	ra,0x2
    80000eb6:	f20080e7          	jalr	-224(ra) # 80002dd2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00006097          	auipc	ra,0x6
    80000ebe:	c06080e7          	jalr	-1018(ra) # 80006ac0 <plicinithart>
  }

  scheduler();        
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	5fe080e7          	jalr	1534(ra) # 800024c0 <scheduler>
    consoleinit();
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	572080e7          	jalr	1394(ra) # 8000043c <consoleinit>
    printfinit();
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	882080e7          	jalr	-1918(ra) # 80000754 <printfinit>
    printf("\n");
    80000eda:	00008517          	auipc	a0,0x8
    80000ede:	29e50513          	addi	a0,a0,670 # 80009178 <digits+0x138>
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	692080e7          	jalr	1682(ra) # 80000574 <printf>
    printf("xv6 kernel is booting\n");
    80000eea:	00008517          	auipc	a0,0x8
    80000eee:	1b650513          	addi	a0,a0,438 # 800090a0 <digits+0x60>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	682080e7          	jalr	1666(ra) # 80000574 <printf>
    printf("\n");
    80000efa:	00008517          	auipc	a0,0x8
    80000efe:	27e50513          	addi	a0,a0,638 # 80009178 <digits+0x138>
    80000f02:	fffff097          	auipc	ra,0xfffff
    80000f06:	672080e7          	jalr	1650(ra) # 80000574 <printf>
    kinit();         // physical page allocator
    80000f0a:	00000097          	auipc	ra,0x0
    80000f0e:	b8c080e7          	jalr	-1140(ra) # 80000a96 <kinit>
    kvminit();       // create kernel page table
    80000f12:	00000097          	auipc	ra,0x0
    80000f16:	310080e7          	jalr	784(ra) # 80001222 <kvminit>
    kvminithart();   // turn on paging
    80000f1a:	00000097          	auipc	ra,0x0
    80000f1e:	068080e7          	jalr	104(ra) # 80000f82 <kvminithart>
    procinit();      // process table
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	db4080e7          	jalr	-588(ra) # 80001cd6 <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	e80080e7          	jalr	-384(ra) # 80002daa <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	ea0080e7          	jalr	-352(ra) # 80002dd2 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00006097          	auipc	ra,0x6
    80000f3e:	b70080e7          	jalr	-1168(ra) # 80006aaa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00006097          	auipc	ra,0x6
    80000f46:	b7e080e7          	jalr	-1154(ra) # 80006ac0 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00002097          	auipc	ra,0x2
    80000f4e:	676080e7          	jalr	1654(ra) # 800035c0 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	d08080e7          	jalr	-760(ra) # 80003c5a <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	fee080e7          	jalr	-18(ra) # 80004f48 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00006097          	auipc	ra,0x6
    80000f66:	c80080e7          	jalr	-896(ra) # 80006be2 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	1c4080e7          	jalr	452(ra) # 8000212e <userinit>
    __sync_synchronize();
    80000f72:	0ff0000f          	fence
    started = 1;
    80000f76:	4785                	li	a5,1
    80000f78:	00009717          	auipc	a4,0x9
    80000f7c:	0af72023          	sw	a5,160(a4) # 8000a018 <started>
    80000f80:	b789                	j	80000ec2 <main+0x56>

0000000080000f82 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f82:	1141                	addi	sp,sp,-16
    80000f84:	e422                	sd	s0,8(sp)
    80000f86:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f88:	00009797          	auipc	a5,0x9
    80000f8c:	0987b783          	ld	a5,152(a5) # 8000a020 <kernel_pagetable>
    80000f90:	83b1                	srli	a5,a5,0xc
    80000f92:	577d                	li	a4,-1
    80000f94:	177e                	slli	a4,a4,0x3f
    80000f96:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f98:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f9c:	12000073          	sfence.vma
  sfence_vma();
}
    80000fa0:	6422                	ld	s0,8(sp)
    80000fa2:	0141                	addi	sp,sp,16
    80000fa4:	8082                	ret

0000000080000fa6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fa6:	7139                	addi	sp,sp,-64
    80000fa8:	fc06                	sd	ra,56(sp)
    80000faa:	f822                	sd	s0,48(sp)
    80000fac:	f426                	sd	s1,40(sp)
    80000fae:	f04a                	sd	s2,32(sp)
    80000fb0:	ec4e                	sd	s3,24(sp)
    80000fb2:	e852                	sd	s4,16(sp)
    80000fb4:	e456                	sd	s5,8(sp)
    80000fb6:	e05a                	sd	s6,0(sp)
    80000fb8:	0080                	addi	s0,sp,64
    80000fba:	84aa                	mv	s1,a0
    80000fbc:	89ae                	mv	s3,a1
    80000fbe:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fc0:	57fd                	li	a5,-1
    80000fc2:	83e9                	srli	a5,a5,0x1a
    80000fc4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fc6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fc8:	04b7f263          	bgeu	a5,a1,8000100c <walk+0x66>
    panic("walk");
    80000fcc:	00008517          	auipc	a0,0x8
    80000fd0:	10450513          	addi	a0,a0,260 # 800090d0 <digits+0x90>
    80000fd4:	fffff097          	auipc	ra,0xfffff
    80000fd8:	556080e7          	jalr	1366(ra) # 8000052a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      //
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fdc:	060a8663          	beqz	s5,80001048 <walk+0xa2>
    80000fe0:	00000097          	auipc	ra,0x0
    80000fe4:	af2080e7          	jalr	-1294(ra) # 80000ad2 <kalloc>
    80000fe8:	84aa                	mv	s1,a0
    80000fea:	c529                	beqz	a0,80001034 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000fec:	6605                	lui	a2,0x1
    80000fee:	4581                	li	a1,0
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	cce080e7          	jalr	-818(ra) # 80000cbe <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000ff8:	00c4d793          	srli	a5,s1,0xc
    80000ffc:	07aa                	slli	a5,a5,0xa
    80000ffe:	0017e793          	ori	a5,a5,1
    80001002:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001006:	3a5d                	addiw	s4,s4,-9
    80001008:	036a0063          	beq	s4,s6,80001028 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000100c:	0149d933          	srl	s2,s3,s4
    80001010:	1ff97913          	andi	s2,s2,511
    80001014:	090e                	slli	s2,s2,0x3
    80001016:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001018:	00093483          	ld	s1,0(s2)
    8000101c:	0014f793          	andi	a5,s1,1
    80001020:	dfd5                	beqz	a5,80000fdc <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001022:	80a9                	srli	s1,s1,0xa
    80001024:	04b2                	slli	s1,s1,0xc
    80001026:	b7c5                	j	80001006 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001028:	00c9d513          	srli	a0,s3,0xc
    8000102c:	1ff57513          	andi	a0,a0,511
    80001030:	050e                	slli	a0,a0,0x3
    80001032:	9526                	add	a0,a0,s1
}
    80001034:	70e2                	ld	ra,56(sp)
    80001036:	7442                	ld	s0,48(sp)
    80001038:	74a2                	ld	s1,40(sp)
    8000103a:	7902                	ld	s2,32(sp)
    8000103c:	69e2                	ld	s3,24(sp)
    8000103e:	6a42                	ld	s4,16(sp)
    80001040:	6aa2                	ld	s5,8(sp)
    80001042:	6b02                	ld	s6,0(sp)
    80001044:	6121                	addi	sp,sp,64
    80001046:	8082                	ret
        return 0;
    80001048:	4501                	li	a0,0
    8000104a:	b7ed                	j	80001034 <walk+0x8e>

000000008000104c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000104c:	57fd                	li	a5,-1
    8000104e:	83e9                	srli	a5,a5,0x1a
    80001050:	00b7f463          	bgeu	a5,a1,80001058 <walkaddr+0xc>
    return 0;
    80001054:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001056:	8082                	ret
{
    80001058:	1141                	addi	sp,sp,-16
    8000105a:	e406                	sd	ra,8(sp)
    8000105c:	e022                	sd	s0,0(sp)
    8000105e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001060:	4601                	li	a2,0
    80001062:	00000097          	auipc	ra,0x0
    80001066:	f44080e7          	jalr	-188(ra) # 80000fa6 <walk>
  if(pte == 0)
    8000106a:	c105                	beqz	a0,8000108a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000106c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000106e:	0117f693          	andi	a3,a5,17
    80001072:	4745                	li	a4,17
    return 0;
    80001074:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001076:	00e68663          	beq	a3,a4,80001082 <walkaddr+0x36>
}
    8000107a:	60a2                	ld	ra,8(sp)
    8000107c:	6402                	ld	s0,0(sp)
    8000107e:	0141                	addi	sp,sp,16
    80001080:	8082                	ret
  pa = PTE2PA(*pte);
    80001082:	00a7d513          	srli	a0,a5,0xa
    80001086:	0532                	slli	a0,a0,0xc
  return pa;
    80001088:	bfcd                	j	8000107a <walkaddr+0x2e>
    return 0;
    8000108a:	4501                	li	a0,0
    8000108c:	b7fd                	j	8000107a <walkaddr+0x2e>

000000008000108e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000108e:	715d                	addi	sp,sp,-80
    80001090:	e486                	sd	ra,72(sp)
    80001092:	e0a2                	sd	s0,64(sp)
    80001094:	fc26                	sd	s1,56(sp)
    80001096:	f84a                	sd	s2,48(sp)
    80001098:	f44e                	sd	s3,40(sp)
    8000109a:	f052                	sd	s4,32(sp)
    8000109c:	ec56                	sd	s5,24(sp)
    8000109e:	e85a                	sd	s6,16(sp)
    800010a0:	e45e                	sd	s7,8(sp)
    800010a2:	0880                	addi	s0,sp,80
    800010a4:	8aaa                	mv	s5,a0
    800010a6:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010a8:	777d                	lui	a4,0xfffff
    800010aa:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ae:	167d                	addi	a2,a2,-1
    800010b0:	00b609b3          	add	s3,a2,a1
    800010b4:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010b8:	893e                	mv	s2,a5
    800010ba:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010be:	6b85                	lui	s7,0x1
    800010c0:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010c4:	4605                	li	a2,1
    800010c6:	85ca                	mv	a1,s2
    800010c8:	8556                	mv	a0,s5
    800010ca:	00000097          	auipc	ra,0x0
    800010ce:	edc080e7          	jalr	-292(ra) # 80000fa6 <walk>
    800010d2:	c51d                	beqz	a0,80001100 <mappages+0x72>
    if(*pte & PTE_V)
    800010d4:	611c                	ld	a5,0(a0)
    800010d6:	8b85                	andi	a5,a5,1
    800010d8:	ef81                	bnez	a5,800010f0 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010da:	80b1                	srli	s1,s1,0xc
    800010dc:	04aa                	slli	s1,s1,0xa
    800010de:	0164e4b3          	or	s1,s1,s6
    800010e2:	0014e493          	ori	s1,s1,1
    800010e6:	e104                	sd	s1,0(a0)
    if(a == last)
    800010e8:	03390863          	beq	s2,s3,80001118 <mappages+0x8a>
    a += PGSIZE;
    800010ec:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010ee:	bfc9                	j	800010c0 <mappages+0x32>
      panic("remap");
    800010f0:	00008517          	auipc	a0,0x8
    800010f4:	fe850513          	addi	a0,a0,-24 # 800090d8 <digits+0x98>
    800010f8:	fffff097          	auipc	ra,0xfffff
    800010fc:	432080e7          	jalr	1074(ra) # 8000052a <panic>
      return -1;
    80001100:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001102:	60a6                	ld	ra,72(sp)
    80001104:	6406                	ld	s0,64(sp)
    80001106:	74e2                	ld	s1,56(sp)
    80001108:	7942                	ld	s2,48(sp)
    8000110a:	79a2                	ld	s3,40(sp)
    8000110c:	7a02                	ld	s4,32(sp)
    8000110e:	6ae2                	ld	s5,24(sp)
    80001110:	6b42                	ld	s6,16(sp)
    80001112:	6ba2                	ld	s7,8(sp)
    80001114:	6161                	addi	sp,sp,80
    80001116:	8082                	ret
  return 0;
    80001118:	4501                	li	a0,0
    8000111a:	b7e5                	j	80001102 <mappages+0x74>

000000008000111c <kvmmap>:
{
    8000111c:	1141                	addi	sp,sp,-16
    8000111e:	e406                	sd	ra,8(sp)
    80001120:	e022                	sd	s0,0(sp)
    80001122:	0800                	addi	s0,sp,16
    80001124:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001126:	86b2                	mv	a3,a2
    80001128:	863e                	mv	a2,a5
    8000112a:	00000097          	auipc	ra,0x0
    8000112e:	f64080e7          	jalr	-156(ra) # 8000108e <mappages>
    80001132:	e509                	bnez	a0,8000113c <kvmmap+0x20>
}
    80001134:	60a2                	ld	ra,8(sp)
    80001136:	6402                	ld	s0,0(sp)
    80001138:	0141                	addi	sp,sp,16
    8000113a:	8082                	ret
    panic("kvmmap");
    8000113c:	00008517          	auipc	a0,0x8
    80001140:	fa450513          	addi	a0,a0,-92 # 800090e0 <digits+0xa0>
    80001144:	fffff097          	auipc	ra,0xfffff
    80001148:	3e6080e7          	jalr	998(ra) # 8000052a <panic>

000000008000114c <kvmmake>:
{
    8000114c:	1101                	addi	sp,sp,-32
    8000114e:	ec06                	sd	ra,24(sp)
    80001150:	e822                	sd	s0,16(sp)
    80001152:	e426                	sd	s1,8(sp)
    80001154:	e04a                	sd	s2,0(sp)
    80001156:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001158:	00000097          	auipc	ra,0x0
    8000115c:	97a080e7          	jalr	-1670(ra) # 80000ad2 <kalloc>
    80001160:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001162:	6605                	lui	a2,0x1
    80001164:	4581                	li	a1,0
    80001166:	00000097          	auipc	ra,0x0
    8000116a:	b58080e7          	jalr	-1192(ra) # 80000cbe <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000116e:	4719                	li	a4,6
    80001170:	6685                	lui	a3,0x1
    80001172:	10000637          	lui	a2,0x10000
    80001176:	100005b7          	lui	a1,0x10000
    8000117a:	8526                	mv	a0,s1
    8000117c:	00000097          	auipc	ra,0x0
    80001180:	fa0080e7          	jalr	-96(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001184:	4719                	li	a4,6
    80001186:	6685                	lui	a3,0x1
    80001188:	10001637          	lui	a2,0x10001
    8000118c:	100015b7          	lui	a1,0x10001
    80001190:	8526                	mv	a0,s1
    80001192:	00000097          	auipc	ra,0x0
    80001196:	f8a080e7          	jalr	-118(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000119a:	4719                	li	a4,6
    8000119c:	004006b7          	lui	a3,0x400
    800011a0:	0c000637          	lui	a2,0xc000
    800011a4:	0c0005b7          	lui	a1,0xc000
    800011a8:	8526                	mv	a0,s1
    800011aa:	00000097          	auipc	ra,0x0
    800011ae:	f72080e7          	jalr	-142(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011b2:	00008917          	auipc	s2,0x8
    800011b6:	e4e90913          	addi	s2,s2,-434 # 80009000 <etext>
    800011ba:	4729                	li	a4,10
    800011bc:	80008697          	auipc	a3,0x80008
    800011c0:	e4468693          	addi	a3,a3,-444 # 9000 <_entry-0x7fff7000>
    800011c4:	4605                	li	a2,1
    800011c6:	067e                	slli	a2,a2,0x1f
    800011c8:	85b2                	mv	a1,a2
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f50080e7          	jalr	-176(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011d4:	4719                	li	a4,6
    800011d6:	46c5                	li	a3,17
    800011d8:	06ee                	slli	a3,a3,0x1b
    800011da:	412686b3          	sub	a3,a3,s2
    800011de:	864a                	mv	a2,s2
    800011e0:	85ca                	mv	a1,s2
    800011e2:	8526                	mv	a0,s1
    800011e4:	00000097          	auipc	ra,0x0
    800011e8:	f38080e7          	jalr	-200(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011ec:	4729                	li	a4,10
    800011ee:	6685                	lui	a3,0x1
    800011f0:	00007617          	auipc	a2,0x7
    800011f4:	e1060613          	addi	a2,a2,-496 # 80008000 <_trampoline>
    800011f8:	040005b7          	lui	a1,0x4000
    800011fc:	15fd                	addi	a1,a1,-1
    800011fe:	05b2                	slli	a1,a1,0xc
    80001200:	8526                	mv	a0,s1
    80001202:	00000097          	auipc	ra,0x0
    80001206:	f1a080e7          	jalr	-230(ra) # 8000111c <kvmmap>
  proc_mapstacks(kpgtbl);
    8000120a:	8526                	mv	a0,s1
    8000120c:	00001097          	auipc	ra,0x1
    80001210:	a34080e7          	jalr	-1484(ra) # 80001c40 <proc_mapstacks>
}
    80001214:	8526                	mv	a0,s1
    80001216:	60e2                	ld	ra,24(sp)
    80001218:	6442                	ld	s0,16(sp)
    8000121a:	64a2                	ld	s1,8(sp)
    8000121c:	6902                	ld	s2,0(sp)
    8000121e:	6105                	addi	sp,sp,32
    80001220:	8082                	ret

0000000080001222 <kvminit>:
{
    80001222:	1141                	addi	sp,sp,-16
    80001224:	e406                	sd	ra,8(sp)
    80001226:	e022                	sd	s0,0(sp)
    80001228:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000122a:	00000097          	auipc	ra,0x0
    8000122e:	f22080e7          	jalr	-222(ra) # 8000114c <kvmmake>
    80001232:	00009797          	auipc	a5,0x9
    80001236:	dea7b723          	sd	a0,-530(a5) # 8000a020 <kernel_pagetable>
}
    8000123a:	60a2                	ld	ra,8(sp)
    8000123c:	6402                	ld	s0,0(sp)
    8000123e:	0141                	addi	sp,sp,16
    80001240:	8082                	ret

0000000080001242 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001242:	7159                	addi	sp,sp,-112
    80001244:	f486                	sd	ra,104(sp)
    80001246:	f0a2                	sd	s0,96(sp)
    80001248:	eca6                	sd	s1,88(sp)
    8000124a:	e8ca                	sd	s2,80(sp)
    8000124c:	e4ce                	sd	s3,72(sp)
    8000124e:	e0d2                	sd	s4,64(sp)
    80001250:	fc56                	sd	s5,56(sp)
    80001252:	f85a                	sd	s6,48(sp)
    80001254:	f45e                	sd	s7,40(sp)
    80001256:	f062                	sd	s8,32(sp)
    80001258:	ec66                	sd	s9,24(sp)
    8000125a:	e86a                	sd	s10,16(sp)
    8000125c:	e46e                	sd	s11,8(sp)
    8000125e:	1880                	addi	s0,sp,112
  pte_t *pte;
  //#ifndef NONE
  //  struct proc * p = myproc();
  //#endif

  if((va % PGSIZE) != 0)
    80001260:	03459793          	slli	a5,a1,0x34
    80001264:	ef99                	bnez	a5,80001282 <uvmunmap+0x40>
    80001266:	89aa                	mv	s3,a0
    80001268:	892e                	mv	s2,a1
    8000126a:	8bb6                	mv	s7,a3
    panic("uvmunmap: not aligned");


  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000126c:	0632                	slli	a2,a2,0xc
    8000126e:	00b60a33          	add	s4,a2,a1
    80001272:	1545f663          	bgeu	a1,s4,800013be <uvmunmap+0x17c>
    #ifdef NONE
      if((*pte & PTE_V) == 0)
        panic("uvmunmap: not mapped");
    #endif

    if(PTE_FLAGS(*pte) == PTE_V)
    80001276:	4a85                	li	s5,1
      uint64 pa = PTE2PA(*pte);
      #ifndef NONE
        struct proc * p = myproc();
        if(p->pagetable == pagetable){
          int foundFlag = 0;
          for (int pi = 0; pi < MAX_PSYC_PAGES; pi++){
    80001278:	4cc1                	li	s9,16
            if(p->physPagesArray[pi].va == a){
              p->physPagesArray[pi].inUse = 0;
              p->physPagesArray[pi].va = -1;
    8000127a:	5d7d                	li	s10,-1
            for (int si = 0; si < MAX_PSYC_PAGES+1; si++){
    8000127c:	4c45                	li	s8,17
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000127e:	6b05                	lui	s6,0x1
    80001280:	a851                	j	80001314 <uvmunmap+0xd2>
    panic("uvmunmap: not aligned");
    80001282:	00008517          	auipc	a0,0x8
    80001286:	e6650513          	addi	a0,a0,-410 # 800090e8 <digits+0xa8>
    8000128a:	fffff097          	auipc	ra,0xfffff
    8000128e:	2a0080e7          	jalr	672(ra) # 8000052a <panic>
      panic("uvmunmap: walk");
    80001292:	00008517          	auipc	a0,0x8
    80001296:	e6e50513          	addi	a0,a0,-402 # 80009100 <digits+0xc0>
    8000129a:	fffff097          	auipc	ra,0xfffff
    8000129e:	290080e7          	jalr	656(ra) # 8000052a <panic>
      panic("uvmunmap: not a leaf");
    800012a2:	00008517          	auipc	a0,0x8
    800012a6:	e6e50513          	addi	a0,a0,-402 # 80009110 <digits+0xd0>
    800012aa:	fffff097          	auipc	ra,0xfffff
    800012ae:	280080e7          	jalr	640(ra) # 8000052a <panic>
          panic("uvmunmap: not mapped");
    800012b2:	00008517          	auipc	a0,0x8
    800012b6:	e7650513          	addi	a0,a0,-394 # 80009128 <digits+0xe8>
    800012ba:	fffff097          	auipc	ra,0xfffff
    800012be:	270080e7          	jalr	624(ra) # 8000052a <panic>
    800012c2:	18050713          	addi	a4,a0,384
            for (int si = 0; si < MAX_PSYC_PAGES+1; si++){
    800012c6:	4781                	li	a5,0
              if(p->swapPagesArray[si].va == a){
    800012c8:	6314                	ld	a3,0(a4)
    800012ca:	01268e63          	beq	a3,s2,800012e6 <uvmunmap+0xa4>
            for (int si = 0; si < MAX_PSYC_PAGES+1; si++){
    800012ce:	2785                	addiw	a5,a5,1
    800012d0:	0761                	addi	a4,a4,24
    800012d2:	ff879be3          	bne	a5,s8,800012c8 <uvmunmap+0x86>
              panic("In uvmunmap - didn't find the requred swap file to erase\n");
    800012d6:	00008517          	auipc	a0,0x8
    800012da:	e6a50513          	addi	a0,a0,-406 # 80009140 <digits+0x100>
    800012de:	fffff097          	auipc	ra,0xfffff
    800012e2:	24c080e7          	jalr	588(ra) # 8000052a <panic>
                p->swapPagesArray[si].inUse = 0;
    800012e6:	00179713          	slli	a4,a5,0x1
    800012ea:	00f706b3          	add	a3,a4,a5
    800012ee:	068e                	slli	a3,a3,0x3
    800012f0:	96aa                	add	a3,a3,a0
    800012f2:	1806a623          	sw	zero,396(a3) # 118c <_entry-0x7fffee74>
                p->swapPagesArray[si].va = -1;
    800012f6:	19a6b023          	sd	s10,384(a3)
                p->numOfTotalPages--;
    800012fa:	17c52783          	lw	a5,380(a0)
    800012fe:	37fd                	addiw	a5,a5,-1
    80001300:	16f52e23          	sw	a5,380(a0)
            if (!foundFlag){
    80001304:	a099                	j	8000134a <uvmunmap+0x108>
    if(do_free){
    80001306:	040b9563          	bnez	s7,80001350 <uvmunmap+0x10e>
          }
        }
         #endif
      kfree((void*)pa);
    }
    *pte = 0;
    8000130a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000130e:	995a                	add	s2,s2,s6
    80001310:	0b497763          	bgeu	s2,s4,800013be <uvmunmap+0x17c>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001314:	4601                	li	a2,0
    80001316:	85ca                	mv	a1,s2
    80001318:	854e                	mv	a0,s3
    8000131a:	00000097          	auipc	ra,0x0
    8000131e:	c8c080e7          	jalr	-884(ra) # 80000fa6 <walk>
    80001322:	84aa                	mv	s1,a0
    80001324:	d53d                	beqz	a0,80001292 <uvmunmap+0x50>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001326:	611c                	ld	a5,0(a0)
    80001328:	3ff7f713          	andi	a4,a5,1023
    8000132c:	f7570be3          	beq	a4,s5,800012a2 <uvmunmap+0x60>
      if((*pte & PTE_V) == 0){
    80001330:	0017f713          	andi	a4,a5,1
    80001334:	fb69                	bnez	a4,80001306 <uvmunmap+0xc4>
        if(!(*pte & PTE_PG)){ // check if PG flag is off
    80001336:	2007f793          	andi	a5,a5,512
    8000133a:	dfa5                	beqz	a5,800012b2 <uvmunmap+0x70>
          struct proc * p = myproc();
    8000133c:	00001097          	auipc	ra,0x1
    80001340:	a76080e7          	jalr	-1418(ra) # 80001db2 <myproc>
          if(p->pagetable == pagetable){
    80001344:	693c                	ld	a5,80(a0)
    80001346:	f7378ee3          	beq	a5,s3,800012c2 <uvmunmap+0x80>
        *pte = 0;
    8000134a:	0004b023          	sd	zero,0(s1)
        continue; 
    8000134e:	b7c1                	j	8000130e <uvmunmap+0xcc>
      uint64 pa = PTE2PA(*pte);
    80001350:	83a9                	srli	a5,a5,0xa
    80001352:	00c79d93          	slli	s11,a5,0xc
        struct proc * p = myproc();
    80001356:	00001097          	auipc	ra,0x1
    8000135a:	a5c080e7          	jalr	-1444(ra) # 80001db2 <myproc>
        if(p->pagetable == pagetable){
    8000135e:	693c                	ld	a5,80(a0)
    80001360:	01378863          	beq	a5,s3,80001370 <uvmunmap+0x12e>
      kfree((void*)pa);
    80001364:	856e                	mv	a0,s11
    80001366:	fffff097          	auipc	ra,0xfffff
    8000136a:	670080e7          	jalr	1648(ra) # 800009d6 <kfree>
    8000136e:	bf71                	j	8000130a <uvmunmap+0xc8>
    80001370:	31850713          	addi	a4,a0,792
          for (int pi = 0; pi < MAX_PSYC_PAGES; pi++){
    80001374:	4781                	li	a5,0
            if(p->physPagesArray[pi].va == a){
    80001376:	6314                	ld	a3,0(a4)
    80001378:	01268e63          	beq	a3,s2,80001394 <uvmunmap+0x152>
          for (int pi = 0; pi < MAX_PSYC_PAGES; pi++){
    8000137c:	2785                	addiw	a5,a5,1
    8000137e:	0761                	addi	a4,a4,24
    80001380:	ff979be3          	bne	a5,s9,80001376 <uvmunmap+0x134>
            panic("In uvmunmap - didn't find the requred ram file to erase\n");
    80001384:	00008517          	auipc	a0,0x8
    80001388:	dfc50513          	addi	a0,a0,-516 # 80009180 <digits+0x140>
    8000138c:	fffff097          	auipc	ra,0xfffff
    80001390:	19e080e7          	jalr	414(ra) # 8000052a <panic>
              p->physPagesArray[pi].inUse = 0;
    80001394:	00179713          	slli	a4,a5,0x1
    80001398:	00f706b3          	add	a3,a4,a5
    8000139c:	068e                	slli	a3,a3,0x3
    8000139e:	96aa                	add	a3,a3,a0
    800013a0:	3206a223          	sw	zero,804(a3)
              p->physPagesArray[pi].va = -1;
    800013a4:	31a6bc23          	sd	s10,792(a3)
              p->numOfPhyPages--;
    800013a8:	17852783          	lw	a5,376(a0)
    800013ac:	37fd                	addiw	a5,a5,-1
    800013ae:	16f52c23          	sw	a5,376(a0)
              p->numOfTotalPages--;
    800013b2:	17c52783          	lw	a5,380(a0)
    800013b6:	37fd                	addiw	a5,a5,-1
    800013b8:	16f52e23          	sw	a5,380(a0)
          if (!foundFlag){
    800013bc:	b765                	j	80001364 <uvmunmap+0x122>
  }
}
    800013be:	70a6                	ld	ra,104(sp)
    800013c0:	7406                	ld	s0,96(sp)
    800013c2:	64e6                	ld	s1,88(sp)
    800013c4:	6946                	ld	s2,80(sp)
    800013c6:	69a6                	ld	s3,72(sp)
    800013c8:	6a06                	ld	s4,64(sp)
    800013ca:	7ae2                	ld	s5,56(sp)
    800013cc:	7b42                	ld	s6,48(sp)
    800013ce:	7ba2                	ld	s7,40(sp)
    800013d0:	7c02                	ld	s8,32(sp)
    800013d2:	6ce2                	ld	s9,24(sp)
    800013d4:	6d42                	ld	s10,16(sp)
    800013d6:	6da2                	ld	s11,8(sp)
    800013d8:	6165                	addi	sp,sp,112
    800013da:	8082                	ret

00000000800013dc <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013dc:	1101                	addi	sp,sp,-32
    800013de:	ec06                	sd	ra,24(sp)
    800013e0:	e822                	sd	s0,16(sp)
    800013e2:	e426                	sd	s1,8(sp)
    800013e4:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013e6:	fffff097          	auipc	ra,0xfffff
    800013ea:	6ec080e7          	jalr	1772(ra) # 80000ad2 <kalloc>
    800013ee:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013f0:	c519                	beqz	a0,800013fe <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013f2:	6605                	lui	a2,0x1
    800013f4:	4581                	li	a1,0
    800013f6:	00000097          	auipc	ra,0x0
    800013fa:	8c8080e7          	jalr	-1848(ra) # 80000cbe <memset>
  return pagetable;
}
    800013fe:	8526                	mv	a0,s1
    80001400:	60e2                	ld	ra,24(sp)
    80001402:	6442                	ld	s0,16(sp)
    80001404:	64a2                	ld	s1,8(sp)
    80001406:	6105                	addi	sp,sp,32
    80001408:	8082                	ret

000000008000140a <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000140a:	7179                	addi	sp,sp,-48
    8000140c:	f406                	sd	ra,40(sp)
    8000140e:	f022                	sd	s0,32(sp)
    80001410:	ec26                	sd	s1,24(sp)
    80001412:	e84a                	sd	s2,16(sp)
    80001414:	e44e                	sd	s3,8(sp)
    80001416:	e052                	sd	s4,0(sp)
    80001418:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000141a:	6785                	lui	a5,0x1
    8000141c:	04f67863          	bgeu	a2,a5,8000146c <uvminit+0x62>
    80001420:	8a2a                	mv	s4,a0
    80001422:	89ae                	mv	s3,a1
    80001424:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001426:	fffff097          	auipc	ra,0xfffff
    8000142a:	6ac080e7          	jalr	1708(ra) # 80000ad2 <kalloc>
    8000142e:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001430:	6605                	lui	a2,0x1
    80001432:	4581                	li	a1,0
    80001434:	00000097          	auipc	ra,0x0
    80001438:	88a080e7          	jalr	-1910(ra) # 80000cbe <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000143c:	4779                	li	a4,30
    8000143e:	86ca                	mv	a3,s2
    80001440:	6605                	lui	a2,0x1
    80001442:	4581                	li	a1,0
    80001444:	8552                	mv	a0,s4
    80001446:	00000097          	auipc	ra,0x0
    8000144a:	c48080e7          	jalr	-952(ra) # 8000108e <mappages>
  memmove(mem, src, sz);
    8000144e:	8626                	mv	a2,s1
    80001450:	85ce                	mv	a1,s3
    80001452:	854a                	mv	a0,s2
    80001454:	00000097          	auipc	ra,0x0
    80001458:	8c6080e7          	jalr	-1850(ra) # 80000d1a <memmove>
}
    8000145c:	70a2                	ld	ra,40(sp)
    8000145e:	7402                	ld	s0,32(sp)
    80001460:	64e2                	ld	s1,24(sp)
    80001462:	6942                	ld	s2,16(sp)
    80001464:	69a2                	ld	s3,8(sp)
    80001466:	6a02                	ld	s4,0(sp)
    80001468:	6145                	addi	sp,sp,48
    8000146a:	8082                	ret
    panic("inituvm: more than a page");
    8000146c:	00008517          	auipc	a0,0x8
    80001470:	d5450513          	addi	a0,a0,-684 # 800091c0 <digits+0x180>
    80001474:	fffff097          	auipc	ra,0xfffff
    80001478:	0b6080e7          	jalr	182(ra) # 8000052a <panic>

000000008000147c <swapOut>:


#ifndef NONE
  void swapOut(struct proc * p){
    8000147c:	7139                	addi	sp,sp,-64
    8000147e:	fc06                	sd	ra,56(sp)
    80001480:	f822                	sd	s0,48(sp)
    80001482:	f426                	sd	s1,40(sp)
    80001484:	f04a                	sd	s2,32(sp)
    80001486:	ec4e                	sd	s3,24(sp)
    80001488:	e852                	sd	s4,16(sp)
    8000148a:	e456                	sd	s5,8(sp)
    8000148c:	e05a                	sd	s6,0(sp)
    8000148e:	0080                	addi	s0,sp,64
    80001490:	892a                	mv	s2,a0
    int i;

    int pagetableIndexToSwap = findPagetableIndexToSwap(p);
    80001492:	00002097          	auipc	ra,0x2
    80001496:	896080e7          	jalr	-1898(ra) # 80002d28 <findPagetableIndexToSwap>
    8000149a:	89aa                	mv	s3,a0

    //printf("--------------in swapout with pid: %d chose index: %d\n", p->pid, pagetableIndexToSwap); //for debugging reasons

    uint64 va = p->physPagesArray[pagetableIndexToSwap].va;
    8000149c:	00151793          	slli	a5,a0,0x1
    800014a0:	97aa                	add	a5,a5,a0
    800014a2:	078e                	slli	a5,a5,0x3
    800014a4:	97ca                	add	a5,a5,s2
    800014a6:	3187bb03          	ld	s6,792(a5) # 1318 <_entry-0x7fffece8>

    pte_t* pte = walk(p->pagetable, va, 0); // to do make sure va is ok
    800014aa:	4601                	li	a2,0
    800014ac:	85da                	mv	a1,s6
    800014ae:	05093503          	ld	a0,80(s2)
    800014b2:	00000097          	auipc	ra,0x0
    800014b6:	af4080e7          	jalr	-1292(ra) # 80000fa6 <walk>
    if(!(*pte))
    800014ba:	611c                	ld	a5,0(a0)
    800014bc:	cf85                	beqz	a5,800014f4 <swapOut+0x78>
    800014be:	8a2a                	mv	s4,a0
        panic("in swapOut - unvalid return value from walk! :(((((");

    uint64 pa = walkaddr(p->pagetable, va);
    800014c0:	85da                	mv	a1,s6
    800014c2:	05093503          	ld	a0,80(s2)
    800014c6:	00000097          	auipc	ra,0x0
    800014ca:	b86080e7          	jalr	-1146(ra) # 8000104c <walkaddr>
    800014ce:	8aaa                	mv	s5,a0
   
    //finding room in the array
    int foundSpace =0;
    int place = -1;
    for( i = 0; i < MAX_PSYC_PAGES+1; i++){ 
    800014d0:	18c90793          	addi	a5,s2,396
    800014d4:	4481                	li	s1,0
    800014d6:	46c5                	li	a3,17
      if(p->swapPagesArray[i].inUse == 0){
    800014d8:	4398                	lw	a4,0(a5)
    800014da:	c70d                	beqz	a4,80001504 <swapOut+0x88>
    for( i = 0; i < MAX_PSYC_PAGES+1; i++){ 
    800014dc:	2485                	addiw	s1,s1,1
    800014de:	07e1                	addi	a5,a5,24
    800014e0:	fed49ce3          	bne	s1,a3,800014d8 <swapOut+0x5c>
        break;
      }
    }
    
    if (!foundSpace){
      panic("in swapout - didn't find free space in swap pages array\n");
    800014e4:	00008517          	auipc	a0,0x8
    800014e8:	d3450513          	addi	a0,a0,-716 # 80009218 <digits+0x1d8>
    800014ec:	fffff097          	auipc	ra,0xfffff
    800014f0:	03e080e7          	jalr	62(ra) # 8000052a <panic>
        panic("in swapOut - unvalid return value from walk! :(((((");
    800014f4:	00008517          	auipc	a0,0x8
    800014f8:	cec50513          	addi	a0,a0,-788 # 800091e0 <digits+0x1a0>
    800014fc:	fffff097          	auipc	ra,0xfffff
    80001500:	02e080e7          	jalr	46(ra) # 8000052a <panic>
    }

    if(writeToSwapFile(p, (char*)pa, place*PGSIZE, PGSIZE) == -1){
    80001504:	6685                	lui	a3,0x1
    80001506:	00c4961b          	slliw	a2,s1,0xc
    8000150a:	85d6                	mv	a1,s5
    8000150c:	854a                	mv	a0,s2
    8000150e:	00003097          	auipc	ra,0x3
    80001512:	3fe080e7          	jalr	1022(ra) # 8000490c <writeToSwapFile>
    80001516:	57fd                	li	a5,-1
    80001518:	06f50763          	beq	a0,a5,80001586 <swapOut+0x10a>
      panic("writeToSwapFile FAILED in SwapOut!!!\n");
    }
 
    *pte = *pte | PTE_PG; // turning on the PTE_PG flag
    *pte = *pte & ~PTE_V; //turning off the PTE_V flag
    8000151c:	000a3783          	ld	a5,0(s4) # fffffffffffff000 <end+0xffffffff7ffcb000>
    80001520:	9bf9                	andi	a5,a5,-2
    80001522:	2007e793          	ori	a5,a5,512
    80001526:	00fa3023          	sd	a5,0(s4)

    //clearing the previous entry in p->swapPagesArray
    p->physPagesArray[pagetableIndexToSwap].inUse = 0;
    8000152a:	00199793          	slli	a5,s3,0x1
    8000152e:	01378733          	add	a4,a5,s3
    80001532:	070e                	slli	a4,a4,0x3
    80001534:	974a                	add	a4,a4,s2
    80001536:	32072223          	sw	zero,804(a4) # fffffffffffff324 <end+0xffffffff7ffcb324>
    p->physPagesArray[pagetableIndexToSwap].va = -1;
    8000153a:	56fd                	li	a3,-1
    8000153c:	30d73c23          	sd	a3,792(a4)
    #ifdef LAPA
      p->physPagesArray[pagetableIndexToSwap].counter = 0xFFFFFFFF;
    #endif

    #ifdef SCFIFO
      p->physPagesArray[pagetableIndexToSwap].placeInQueue = 0;
    80001540:	32072423          	sw	zero,808(a4)
    #endif


    //searching for a space in p->swapPagesArray

    p->swapPagesArray[place].inUse = 1;
    80001544:	00149793          	slli	a5,s1,0x1
    80001548:	00978733          	add	a4,a5,s1
    8000154c:	070e                	slli	a4,a4,0x3
    8000154e:	974a                	add	a4,a4,s2
    80001550:	4685                	li	a3,1
    80001552:	18d72623          	sw	a3,396(a4)
    p->swapPagesArray[place].va = va;
    80001556:	19673023          	sd	s6,384(a4)

    p->numOfPhyPages--;
    8000155a:	17892783          	lw	a5,376(s2)
    8000155e:	37fd                	addiw	a5,a5,-1
    80001560:	16f92c23          	sw	a5,376(s2)

    kfree((void*)pa);
    80001564:	8556                	mv	a0,s5
    80001566:	fffff097          	auipc	ra,0xfffff
    8000156a:	470080e7          	jalr	1136(ra) # 800009d6 <kfree>
    8000156e:	12000073          	sfence.vma
    sfence_vma(); // TLB flush 

  }
    80001572:	70e2                	ld	ra,56(sp)
    80001574:	7442                	ld	s0,48(sp)
    80001576:	74a2                	ld	s1,40(sp)
    80001578:	7902                	ld	s2,32(sp)
    8000157a:	69e2                	ld	s3,24(sp)
    8000157c:	6a42                	ld	s4,16(sp)
    8000157e:	6aa2                	ld	s5,8(sp)
    80001580:	6b02                	ld	s6,0(sp)
    80001582:	6121                	addi	sp,sp,64
    80001584:	8082                	ret
      panic("writeToSwapFile FAILED in SwapOut!!!\n");
    80001586:	00008517          	auipc	a0,0x8
    8000158a:	cd250513          	addi	a0,a0,-814 # 80009258 <digits+0x218>
    8000158e:	fffff097          	auipc	ra,0xfffff
    80001592:	f9c080e7          	jalr	-100(ra) # 8000052a <panic>

0000000080001596 <swapIn>:

  // move from swapfile (disk) to ram
  void
  swapIn(struct proc * p, uint64 va){
    80001596:	7139                	addi	sp,sp,-64
    80001598:	fc06                	sd	ra,56(sp)
    8000159a:	f822                	sd	s0,48(sp)
    8000159c:	f426                	sd	s1,40(sp)
    8000159e:	f04a                	sd	s2,32(sp)
    800015a0:	ec4e                	sd	s3,24(sp)
    800015a2:	e852                	sd	s4,16(sp)
    800015a4:	e456                	sd	s5,8(sp)
    800015a6:	0080                	addi	s0,sp,64
    800015a8:	89aa                	mv	s3,a0
    800015aa:	892e                	mv	s2,a1
    int found = 0;
    char *mem;
    int i;

    for(i = 0; i < MAX_PSYC_PAGES+1; i++){
    800015ac:	18050793          	addi	a5,a0,384
    800015b0:	4481                	li	s1,0
    800015b2:	46c5                	li	a3,17
      if (p->swapPagesArray[i].va == va){
    800015b4:	6398                	ld	a4,0(a5)
    800015b6:	07270263          	beq	a4,s2,8000161a <swapIn+0x84>
    for(i = 0; i < MAX_PSYC_PAGES+1; i++){
    800015ba:	2485                	addiw	s1,s1,1
    800015bc:	07e1                	addi	a5,a5,24
    800015be:	fed49be3          	bne	s1,a3,800015b4 <swapIn+0x1e>
        break;
      }
    }
    
    if (found == 0){
      panic("SwapIn FAILED! Didn't find the required file to swap in\n");
    800015c2:	00008517          	auipc	a0,0x8
    800015c6:	ce650513          	addi	a0,a0,-794 # 800092a8 <digits+0x268>
    800015ca:	fffff097          	auipc	ra,0xfffff
    800015ce:	f60080e7          	jalr	-160(ra) # 8000052a <panic>
      return;
    }
    
    // filling up mem with the swapped data
    if(readFromSwapFile(p, mem, i*PGSIZE, PGSIZE) == -1){ // to do release the space in swapFile!!!!!!!!!!!
      panic("readFromSwapFile FAILED in swapIn!!!\n");
    800015d2:	00008517          	auipc	a0,0x8
    800015d6:	cae50513          	addi	a0,a0,-850 # 80009280 <digits+0x240>
    800015da:	fffff097          	auipc	ra,0xfffff
    800015de:	f50080e7          	jalr	-176(ra) # 8000052a <panic>
      // do somethind...
      // return maybe?
    }

    if(mappages(p->pagetable, va, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
      kfree(mem);
    800015e2:	8552                	mv	a0,s4
    800015e4:	fffff097          	auipc	ra,0xfffff
    800015e8:	3f2080e7          	jalr	1010(ra) # 800009d6 <kfree>
      return;
    800015ec:	a87d                	j	800016aa <swapIn+0x114>
    p->swapPagesArray[i].va = -1;
    p->swapPagesArray[i].inUse = 0;

    for(int  j = 0; j < MAX_PSYC_PAGES; j++){ 
      if(p->physPagesArray[j].inUse == 0){
        p->physPagesArray[j].inUse = 1;
    800015ee:	00179713          	slli	a4,a5,0x1
    800015f2:	00f706b3          	add	a3,a4,a5
    800015f6:	068e                	slli	a3,a3,0x3
    800015f8:	96ce                	add	a3,a3,s3
    800015fa:	4605                	li	a2,1
    800015fc:	32c6a223          	sw	a2,804(a3) # 1324 <_entry-0x7fffecdc>
        p->physPagesArray[j].va = va;
    80001600:	3126bc23          	sd	s2,792(a3)
        #endif
        #ifdef LAPA
          p->physPagesArray[j].counter = 0xFFFFFFFF;
        #endif
        #ifdef SCFIFO
          p->physPagesArray[j].placeInQueue = p->nextPlaceInQueue;
    80001604:	1749a683          	lw	a3,372(s3) # 1174 <_entry-0x7fffee8c>
    80001608:	97ba                	add	a5,a5,a4
    8000160a:	078e                	slli	a5,a5,0x3
    8000160c:	97ce                	add	a5,a5,s3
    8000160e:	32d7a423          	sw	a3,808(a5)
          p->nextPlaceInQueue++;
    80001612:	2685                	addiw	a3,a3,1
    80001614:	16d9aa23          	sw	a3,372(s3)
        #endif
        break;
    80001618:	a061                	j	800016a0 <swapIn+0x10a>
    pte_t* pte = walk(p->pagetable, va, 0); // to do make sure va is ok
    8000161a:	4601                	li	a2,0
    8000161c:	85ca                	mv	a1,s2
    8000161e:	0509b503          	ld	a0,80(s3)
    80001622:	00000097          	auipc	ra,0x0
    80001626:	984080e7          	jalr	-1660(ra) # 80000fa6 <walk>
    8000162a:	8aaa                	mv	s5,a0
    mem = kalloc();
    8000162c:	fffff097          	auipc	ra,0xfffff
    80001630:	4a6080e7          	jalr	1190(ra) # 80000ad2 <kalloc>
    80001634:	8a2a                	mv	s4,a0
    if(mem == 0){
    80001636:	c935                	beqz	a0,800016aa <swapIn+0x114>
    if(readFromSwapFile(p, mem, i*PGSIZE, PGSIZE) == -1){ // to do release the space in swapFile!!!!!!!!!!!
    80001638:	6685                	lui	a3,0x1
    8000163a:	00c4961b          	slliw	a2,s1,0xc
    8000163e:	85d2                	mv	a1,s4
    80001640:	854e                	mv	a0,s3
    80001642:	00003097          	auipc	ra,0x3
    80001646:	314080e7          	jalr	788(ra) # 80004956 <readFromSwapFile>
    8000164a:	57fd                	li	a5,-1
    8000164c:	f8f503e3          	beq	a0,a5,800015d2 <swapIn+0x3c>
    if(mappages(p->pagetable, va, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001650:	4779                	li	a4,30
    80001652:	86d2                	mv	a3,s4
    80001654:	6605                	lui	a2,0x1
    80001656:	85ca                	mv	a1,s2
    80001658:	0509b503          	ld	a0,80(s3)
    8000165c:	00000097          	auipc	ra,0x0
    80001660:	a32080e7          	jalr	-1486(ra) # 8000108e <mappages>
    80001664:	87aa                	mv	a5,a0
    80001666:	fd35                	bnez	a0,800015e2 <swapIn+0x4c>
    *pte = *pte & ~PTE_PG; // turning off the PTE_PG flag
    80001668:	000ab703          	ld	a4,0(s5)
    8000166c:	dff77713          	andi	a4,a4,-513
    *pte = *pte | PTE_V; //turning on the PTE_V flag
    80001670:	00176713          	ori	a4,a4,1
    80001674:	00eab023          	sd	a4,0(s5)
    p->swapPagesArray[i].va = -1;
    80001678:	00149713          	slli	a4,s1,0x1
    8000167c:	009706b3          	add	a3,a4,s1
    80001680:	068e                	slli	a3,a3,0x3
    80001682:	96ce                	add	a3,a3,s3
    80001684:	567d                	li	a2,-1
    80001686:	18c6b023          	sd	a2,384(a3) # 1180 <_entry-0x7fffee80>
    p->swapPagesArray[i].inUse = 0;
    8000168a:	1806a623          	sw	zero,396(a3)
    for(int  j = 0; j < MAX_PSYC_PAGES; j++){ 
    8000168e:	32498713          	addi	a4,s3,804
    80001692:	4641                	li	a2,16
      if(p->physPagesArray[j].inUse == 0){
    80001694:	4314                	lw	a3,0(a4)
    80001696:	dea1                	beqz	a3,800015ee <swapIn+0x58>
    for(int  j = 0; j < MAX_PSYC_PAGES; j++){ 
    80001698:	2785                	addiw	a5,a5,1
    8000169a:	0761                	addi	a4,a4,24
    8000169c:	fec79ce3          	bne	a5,a2,80001694 <swapIn+0xfe>
      }
    }
    p->numOfPhyPages++;
    800016a0:	1789a783          	lw	a5,376(s3)
    800016a4:	2785                	addiw	a5,a5,1
    800016a6:	16f9ac23          	sw	a5,376(s3)
  }
    800016aa:	70e2                	ld	ra,56(sp)
    800016ac:	7442                	ld	s0,48(sp)
    800016ae:	74a2                	ld	s1,40(sp)
    800016b0:	7902                	ld	s2,32(sp)
    800016b2:	69e2                	ld	s3,24(sp)
    800016b4:	6a42                	ld	s4,16(sp)
    800016b6:	6aa2                	ld	s5,8(sp)
    800016b8:	6121                	addi	sp,sp,64
    800016ba:	8082                	ret

00000000800016bc <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800016bc:	1101                	addi	sp,sp,-32
    800016be:	ec06                	sd	ra,24(sp)
    800016c0:	e822                	sd	s0,16(sp)
    800016c2:	e426                	sd	s1,8(sp)
    800016c4:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800016c6:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800016c8:	00b67d63          	bgeu	a2,a1,800016e2 <uvmdealloc+0x26>
    800016cc:	84b2                	mv	s1,a2
  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800016ce:	6785                	lui	a5,0x1
    800016d0:	17fd                	addi	a5,a5,-1
    800016d2:	00f60733          	add	a4,a2,a5
    800016d6:	767d                	lui	a2,0xfffff
    800016d8:	8f71                	and	a4,a4,a2
    800016da:	97ae                	add	a5,a5,a1
    800016dc:	8ff1                	and	a5,a5,a2
    800016de:	00f76863          	bltu	a4,a5,800016ee <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }
  return newsz;
}
    800016e2:	8526                	mv	a0,s1
    800016e4:	60e2                	ld	ra,24(sp)
    800016e6:	6442                	ld	s0,16(sp)
    800016e8:	64a2                	ld	s1,8(sp)
    800016ea:	6105                	addi	sp,sp,32
    800016ec:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800016ee:	8f99                	sub	a5,a5,a4
    800016f0:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800016f2:	4685                	li	a3,1
    800016f4:	0007861b          	sext.w	a2,a5
    800016f8:	85ba                	mv	a1,a4
    800016fa:	00000097          	auipc	ra,0x0
    800016fe:	b48080e7          	jalr	-1208(ra) # 80001242 <uvmunmap>
    80001702:	b7c5                	j	800016e2 <uvmdealloc+0x26>

0000000080001704 <uvmalloc>:
{
    80001704:	715d                	addi	sp,sp,-80
    80001706:	e486                	sd	ra,72(sp)
    80001708:	e0a2                	sd	s0,64(sp)
    8000170a:	fc26                	sd	s1,56(sp)
    8000170c:	f84a                	sd	s2,48(sp)
    8000170e:	f44e                	sd	s3,40(sp)
    80001710:	f052                	sd	s4,32(sp)
    80001712:	ec56                	sd	s5,24(sp)
    80001714:	e85a                	sd	s6,16(sp)
    80001716:	e45e                	sd	s7,8(sp)
    80001718:	e062                	sd	s8,0(sp)
    8000171a:	0880                	addi	s0,sp,80
    8000171c:	8aaa                	mv	s5,a0
    8000171e:	892e                	mv	s2,a1
    80001720:	8a32                	mv	s4,a2
    struct proc* p = myproc();
    80001722:	00000097          	auipc	ra,0x0
    80001726:	690080e7          	jalr	1680(ra) # 80001db2 <myproc>
  if(newsz < oldsz)
    8000172a:	152a6863          	bltu	s4,s2,8000187a <uvmalloc+0x176>
    8000172e:	84aa                	mv	s1,a0
    for(i = oldsz; i < newsz; i += PGSIZE){
    80001730:	05497063          	bgeu	s2,s4,80001770 <uvmalloc+0x6c>
    80001734:	87ca                	mv	a5,s2
    int numOfPagesToAdd = 0;
    80001736:	4701                	li	a4,0
    for(i = oldsz; i < newsz; i += PGSIZE){
    80001738:	6685                	lui	a3,0x1
      numOfPagesToAdd++;
    8000173a:	2705                	addiw	a4,a4,1
    for(i = oldsz; i < newsz; i += PGSIZE){
    8000173c:	97b6                	add	a5,a5,a3
    8000173e:	ff47eee3          	bltu	a5,s4,8000173a <uvmalloc+0x36>
    if((numOfPagesToAdd > 32-p->numOfTotalPages) & (p->pid > 2)){
    80001742:	17c4a683          	lw	a3,380(s1)
    80001746:	02000793          	li	a5,32
    8000174a:	9f95                	subw	a5,a5,a3
    8000174c:	00e7d663          	bge	a5,a4,80001758 <uvmalloc+0x54>
    80001750:	5898                	lw	a4,48(s1)
    80001752:	4789                	li	a5,2
    80001754:	02e7c063          	blt	a5,a4,80001774 <uvmalloc+0x70>
  oldsz = PGROUNDUP(oldsz);
    80001758:	6b05                	lui	s6,0x1
    8000175a:	1b7d                	addi	s6,s6,-1
    8000175c:	995a                	add	s2,s2,s6
    8000175e:	7b7d                	lui	s6,0xfffff
    80001760:	01697b33          	and	s6,s2,s6
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001764:	134b7863          	bgeu	s6,s4,80001894 <uvmalloc+0x190>
    80001768:	89da                	mv	s3,s6
      if (p->numOfPhyPages == 16){
    8000176a:	4941                	li	s2,16
          p->physPagesArray[i].inUse = 1;
    8000176c:	4b85                	li	s7,1
    8000176e:	a04d                	j	80001810 <uvmalloc+0x10c>
    int numOfPagesToAdd = 0;
    80001770:	4701                	li	a4,0
    80001772:	bfc1                	j	80001742 <uvmalloc+0x3e>
      panic("more then 32 pages !!!\n");
    80001774:	00008517          	auipc	a0,0x8
    80001778:	b7450513          	addi	a0,a0,-1164 # 800092e8 <digits+0x2a8>
    8000177c:	fffff097          	auipc	ra,0xfffff
    80001780:	dae080e7          	jalr	-594(ra) # 8000052a <panic>
        printf("In exec - this program have more then 13 ELF pages and we do not support this in this work!\n");
    80001784:	00008517          	auipc	a0,0x8
    80001788:	b7c50513          	addi	a0,a0,-1156 # 80009300 <digits+0x2c0>
    8000178c:	fffff097          	auipc	ra,0xfffff
    80001790:	de8080e7          	jalr	-536(ra) # 80000574 <printf>
        uvmdealloc(pagetable, a, oldsz);
    80001794:	865a                	mv	a2,s6
    80001796:	85ce                	mv	a1,s3
    80001798:	8556                	mv	a0,s5
    8000179a:	00000097          	auipc	ra,0x0
    8000179e:	f22080e7          	jalr	-222(ra) # 800016bc <uvmdealloc>
        return 0;
    800017a2:	4501                	li	a0,0
    800017a4:	a8e1                	j	8000187c <uvmalloc+0x178>
        swapOut(p); // counting on first finishing swapout and only them continue - to do in swapout add update of the array!
    800017a6:	8526                	mv	a0,s1
    800017a8:	00000097          	auipc	ra,0x0
    800017ac:	cd4080e7          	jalr	-812(ra) # 8000147c <swapOut>
    800017b0:	a895                	j	80001824 <uvmalloc+0x120>
      uvmdealloc(pagetable, a, oldsz);
    800017b2:	865a                	mv	a2,s6
    800017b4:	85ce                	mv	a1,s3
    800017b6:	8556                	mv	a0,s5
    800017b8:	00000097          	auipc	ra,0x0
    800017bc:	f04080e7          	jalr	-252(ra) # 800016bc <uvmdealloc>
      return 0;
    800017c0:	4501                	li	a0,0
    800017c2:	a86d                	j	8000187c <uvmalloc+0x178>
      kfree(mem);
    800017c4:	8562                	mv	a0,s8
    800017c6:	fffff097          	auipc	ra,0xfffff
    800017ca:	210080e7          	jalr	528(ra) # 800009d6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800017ce:	865a                	mv	a2,s6
    800017d0:	85ce                	mv	a1,s3
    800017d2:	8556                	mv	a0,s5
    800017d4:	00000097          	auipc	ra,0x0
    800017d8:	ee8080e7          	jalr	-280(ra) # 800016bc <uvmdealloc>
      return 0;
    800017dc:	4501                	li	a0,0
    800017de:	a879                	j	8000187c <uvmalloc+0x178>
          p->physPagesArray[i].inUse = 1;
    800017e0:	00151793          	slli	a5,a0,0x1
    800017e4:	00a78733          	add	a4,a5,a0
    800017e8:	070e                	slli	a4,a4,0x3
    800017ea:	9726                	add	a4,a4,s1
    800017ec:	33772223          	sw	s7,804(a4)
          p->physPagesArray[i].va = a; // to do check this!! we think a is the va, and mem is the pa
    800017f0:	31373c23          	sd	s3,792(a4)
            p->physPagesArray[i].placeInQueue = p->nextPlaceInQueue;
    800017f4:	1744a703          	lw	a4,372(s1)
    800017f8:	97aa                	add	a5,a5,a0
    800017fa:	078e                	slli	a5,a5,0x3
    800017fc:	97a6                	add	a5,a5,s1
    800017fe:	32e7a423          	sw	a4,808(a5) # 1328 <_entry-0x7fffecd8>
            p->nextPlaceInQueue++;
    80001802:	2705                	addiw	a4,a4,1
    80001804:	16e4aa23          	sw	a4,372(s1)
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001808:	6785                	lui	a5,0x1
    8000180a:	99be                	add	s3,s3,a5
    8000180c:	0749f563          	bgeu	s3,s4,80001876 <uvmalloc+0x172>
      if ((p->numOfPhyPages == 16) & (p->pagetable != pagetable)){
    80001810:	1784a783          	lw	a5,376(s1)
    80001814:	68b8                	ld	a4,80(s1)
    80001816:	01570563          	beq	a4,s5,80001820 <uvmalloc+0x11c>
    8000181a:	ff078713          	addi	a4,a5,-16 # ff0 <_entry-0x7ffff010>
    8000181e:	d33d                	beqz	a4,80001784 <uvmalloc+0x80>
      if (p->numOfPhyPages == 16){
    80001820:	f92783e3          	beq	a5,s2,800017a6 <uvmalloc+0xa2>
    mem = kalloc();
    80001824:	fffff097          	auipc	ra,0xfffff
    80001828:	2ae080e7          	jalr	686(ra) # 80000ad2 <kalloc>
    8000182c:	8c2a                	mv	s8,a0
    if(mem == 0){
    8000182e:	d151                	beqz	a0,800017b2 <uvmalloc+0xae>
    memset(mem, 0, PGSIZE);
    80001830:	6605                	lui	a2,0x1
    80001832:	4581                	li	a1,0
    80001834:	fffff097          	auipc	ra,0xfffff
    80001838:	48a080e7          	jalr	1162(ra) # 80000cbe <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000183c:	4779                	li	a4,30
    8000183e:	86e2                	mv	a3,s8
    80001840:	6605                	lui	a2,0x1
    80001842:	85ce                	mv	a1,s3
    80001844:	8556                	mv	a0,s5
    80001846:	00000097          	auipc	ra,0x0
    8000184a:	848080e7          	jalr	-1976(ra) # 8000108e <mappages>
    8000184e:	f93d                	bnez	a0,800017c4 <uvmalloc+0xc0>
      p->numOfTotalPages++;
    80001850:	17c4a783          	lw	a5,380(s1)
    80001854:	2785                	addiw	a5,a5,1
    80001856:	16f4ae23          	sw	a5,380(s1)
      p->numOfPhyPages++;
    8000185a:	1784a783          	lw	a5,376(s1)
    8000185e:	2785                	addiw	a5,a5,1
    80001860:	16f4ac23          	sw	a5,376(s1)
      for (int i = 0; i < MAX_PSYC_PAGES; i++){
    80001864:	32448793          	addi	a5,s1,804
        if (p->physPagesArray[i].inUse == 0){
    80001868:	4398                	lw	a4,0(a5)
    8000186a:	db3d                	beqz	a4,800017e0 <uvmalloc+0xdc>
      for (int i = 0; i < MAX_PSYC_PAGES; i++){
    8000186c:	2505                	addiw	a0,a0,1
    8000186e:	07e1                	addi	a5,a5,24
    80001870:	ff251ce3          	bne	a0,s2,80001868 <uvmalloc+0x164>
    80001874:	bf51                	j	80001808 <uvmalloc+0x104>
  return newsz;
    80001876:	8552                	mv	a0,s4
    80001878:	a011                	j	8000187c <uvmalloc+0x178>
    return oldsz;
    8000187a:	854a                	mv	a0,s2
}
    8000187c:	60a6                	ld	ra,72(sp)
    8000187e:	6406                	ld	s0,64(sp)
    80001880:	74e2                	ld	s1,56(sp)
    80001882:	7942                	ld	s2,48(sp)
    80001884:	79a2                	ld	s3,40(sp)
    80001886:	7a02                	ld	s4,32(sp)
    80001888:	6ae2                	ld	s5,24(sp)
    8000188a:	6b42                	ld	s6,16(sp)
    8000188c:	6ba2                	ld	s7,8(sp)
    8000188e:	6c02                	ld	s8,0(sp)
    80001890:	6161                	addi	sp,sp,80
    80001892:	8082                	ret
  return newsz;
    80001894:	8552                	mv	a0,s4
    80001896:	b7dd                	j	8000187c <uvmalloc+0x178>

0000000080001898 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001898:	7179                	addi	sp,sp,-48
    8000189a:	f406                	sd	ra,40(sp)
    8000189c:	f022                	sd	s0,32(sp)
    8000189e:	ec26                	sd	s1,24(sp)
    800018a0:	e84a                	sd	s2,16(sp)
    800018a2:	e44e                	sd	s3,8(sp)
    800018a4:	e052                	sd	s4,0(sp)
    800018a6:	1800                	addi	s0,sp,48
    800018a8:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800018aa:	84aa                	mv	s1,a0
    800018ac:	6905                	lui	s2,0x1
    800018ae:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800018b0:	4985                	li	s3,1
    800018b2:	a821                	j	800018ca <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800018b4:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800018b6:	0532                	slli	a0,a0,0xc
    800018b8:	00000097          	auipc	ra,0x0
    800018bc:	fe0080e7          	jalr	-32(ra) # 80001898 <freewalk>
      pagetable[i] = 0;
    800018c0:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800018c4:	04a1                	addi	s1,s1,8
    800018c6:	03248163          	beq	s1,s2,800018e8 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800018ca:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800018cc:	00f57793          	andi	a5,a0,15
    800018d0:	ff3782e3          	beq	a5,s3,800018b4 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800018d4:	8905                	andi	a0,a0,1
    800018d6:	d57d                	beqz	a0,800018c4 <freewalk+0x2c>
      panic("freewalk: leaf");
    800018d8:	00008517          	auipc	a0,0x8
    800018dc:	a8850513          	addi	a0,a0,-1400 # 80009360 <digits+0x320>
    800018e0:	fffff097          	auipc	ra,0xfffff
    800018e4:	c4a080e7          	jalr	-950(ra) # 8000052a <panic>
    }
  }
  kfree((void*)pagetable);
    800018e8:	8552                	mv	a0,s4
    800018ea:	fffff097          	auipc	ra,0xfffff
    800018ee:	0ec080e7          	jalr	236(ra) # 800009d6 <kfree>
}
    800018f2:	70a2                	ld	ra,40(sp)
    800018f4:	7402                	ld	s0,32(sp)
    800018f6:	64e2                	ld	s1,24(sp)
    800018f8:	6942                	ld	s2,16(sp)
    800018fa:	69a2                	ld	s3,8(sp)
    800018fc:	6a02                	ld	s4,0(sp)
    800018fe:	6145                	addi	sp,sp,48
    80001900:	8082                	ret

0000000080001902 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001902:	1101                	addi	sp,sp,-32
    80001904:	ec06                	sd	ra,24(sp)
    80001906:	e822                	sd	s0,16(sp)
    80001908:	e426                	sd	s1,8(sp)
    8000190a:	1000                	addi	s0,sp,32
    8000190c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000190e:	e999                	bnez	a1,80001924 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001910:	8526                	mv	a0,s1
    80001912:	00000097          	auipc	ra,0x0
    80001916:	f86080e7          	jalr	-122(ra) # 80001898 <freewalk>
}
    8000191a:	60e2                	ld	ra,24(sp)
    8000191c:	6442                	ld	s0,16(sp)
    8000191e:	64a2                	ld	s1,8(sp)
    80001920:	6105                	addi	sp,sp,32
    80001922:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001924:	6605                	lui	a2,0x1
    80001926:	167d                	addi	a2,a2,-1
    80001928:	962e                	add	a2,a2,a1
    8000192a:	4685                	li	a3,1
    8000192c:	8231                	srli	a2,a2,0xc
    8000192e:	4581                	li	a1,0
    80001930:	00000097          	auipc	ra,0x0
    80001934:	912080e7          	jalr	-1774(ra) # 80001242 <uvmunmap>
    80001938:	bfe1                	j	80001910 <uvmfree+0xe>

000000008000193a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000193a:	10060163          	beqz	a2,80001a3c <uvmcopy+0x102>
{
    8000193e:	715d                	addi	sp,sp,-80
    80001940:	e486                	sd	ra,72(sp)
    80001942:	e0a2                	sd	s0,64(sp)
    80001944:	fc26                	sd	s1,56(sp)
    80001946:	f84a                	sd	s2,48(sp)
    80001948:	f44e                	sd	s3,40(sp)
    8000194a:	f052                	sd	s4,32(sp)
    8000194c:	ec56                	sd	s5,24(sp)
    8000194e:	e85a                	sd	s6,16(sp)
    80001950:	e45e                	sd	s7,8(sp)
    80001952:	0880                	addi	s0,sp,80
    80001954:	8aaa                	mv	s5,a0
    80001956:	8a2e                	mv	s4,a1
    80001958:	89b2                	mv	s3,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000195a:	4901                	li	s2,0
    8000195c:	a80d                	j	8000198e <uvmcopy+0x54>
    if((pte = walk(old, i, 0)) == 0)
      panic("uvmcopy: pte should exist");
    8000195e:	00008517          	auipc	a0,0x8
    80001962:	a1250513          	addi	a0,a0,-1518 # 80009370 <digits+0x330>
    80001966:	fffff097          	auipc	ra,0xfffff
    8000196a:	bc4080e7          	jalr	-1084(ra) # 8000052a <panic>
    if((*pte & PTE_V) == 0){
      if((*pte & PTE_PG) == 0)
        panic("uvmcopy: page not present");
    8000196e:	00008517          	auipc	a0,0x8
    80001972:	a2250513          	addi	a0,a0,-1502 # 80009390 <digits+0x350>
    80001976:	fffff097          	auipc	ra,0xfffff
    8000197a:	bb4080e7          	jalr	-1100(ra) # 8000052a <panic>
      else{
        if((pte = walk(new, i, 1)) == 0){
          panic("In uvmcopy walk FAILED - couldn't create new pte\n");
        }
        *pte= *pte | PTE_PG;
    8000197e:	611c                	ld	a5,0(a0)
    80001980:	2007e793          	ori	a5,a5,512
    80001984:	e11c                	sd	a5,0(a0)
  for(i = 0; i < sz; i += PGSIZE){
    80001986:	6785                	lui	a5,0x1
    80001988:	993e                	add	s2,s2,a5
    8000198a:	09397d63          	bgeu	s2,s3,80001a24 <uvmcopy+0xea>
    if((pte = walk(old, i, 0)) == 0)
    8000198e:	4601                	li	a2,0
    80001990:	85ca                	mv	a1,s2
    80001992:	8556                	mv	a0,s5
    80001994:	fffff097          	auipc	ra,0xfffff
    80001998:	612080e7          	jalr	1554(ra) # 80000fa6 <walk>
    8000199c:	d169                	beqz	a0,8000195e <uvmcopy+0x24>
    if((*pte & PTE_V) == 0){
    8000199e:	6118                	ld	a4,0(a0)
    800019a0:	00177793          	andi	a5,a4,1
    800019a4:	e785                	bnez	a5,800019cc <uvmcopy+0x92>
      if((*pte & PTE_PG) == 0)
    800019a6:	20077713          	andi	a4,a4,512
    800019aa:	d371                	beqz	a4,8000196e <uvmcopy+0x34>
        if((pte = walk(new, i, 1)) == 0){
    800019ac:	4605                	li	a2,1
    800019ae:	85ca                	mv	a1,s2
    800019b0:	8552                	mv	a0,s4
    800019b2:	fffff097          	auipc	ra,0xfffff
    800019b6:	5f4080e7          	jalr	1524(ra) # 80000fa6 <walk>
    800019ba:	f171                	bnez	a0,8000197e <uvmcopy+0x44>
          panic("In uvmcopy walk FAILED - couldn't create new pte\n");
    800019bc:	00008517          	auipc	a0,0x8
    800019c0:	9f450513          	addi	a0,a0,-1548 # 800093b0 <digits+0x370>
    800019c4:	fffff097          	auipc	ra,0xfffff
    800019c8:	b66080e7          	jalr	-1178(ra) # 8000052a <panic>
        continue;
      }  
    }
     
    pa = PTE2PA(*pte);
    800019cc:	00a75593          	srli	a1,a4,0xa
    800019d0:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800019d4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800019d8:	fffff097          	auipc	ra,0xfffff
    800019dc:	0fa080e7          	jalr	250(ra) # 80000ad2 <kalloc>
    800019e0:	8b2a                	mv	s6,a0
    800019e2:	c515                	beqz	a0,80001a0e <uvmcopy+0xd4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800019e4:	6605                	lui	a2,0x1
    800019e6:	85de                	mv	a1,s7
    800019e8:	fffff097          	auipc	ra,0xfffff
    800019ec:	332080e7          	jalr	818(ra) # 80000d1a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800019f0:	8726                	mv	a4,s1
    800019f2:	86da                	mv	a3,s6
    800019f4:	6605                	lui	a2,0x1
    800019f6:	85ca                	mv	a1,s2
    800019f8:	8552                	mv	a0,s4
    800019fa:	fffff097          	auipc	ra,0xfffff
    800019fe:	694080e7          	jalr	1684(ra) # 8000108e <mappages>
    80001a02:	d151                	beqz	a0,80001986 <uvmcopy+0x4c>
      kfree(mem);
    80001a04:	855a                	mv	a0,s6
    80001a06:	fffff097          	auipc	ra,0xfffff
    80001a0a:	fd0080e7          	jalr	-48(ra) # 800009d6 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001a0e:	4685                	li	a3,1
    80001a10:	00c95613          	srli	a2,s2,0xc
    80001a14:	4581                	li	a1,0
    80001a16:	8552                	mv	a0,s4
    80001a18:	00000097          	auipc	ra,0x0
    80001a1c:	82a080e7          	jalr	-2006(ra) # 80001242 <uvmunmap>
  return -1;
    80001a20:	557d                	li	a0,-1
    80001a22:	a011                	j	80001a26 <uvmcopy+0xec>
  return 0;
    80001a24:	4501                	li	a0,0
}
    80001a26:	60a6                	ld	ra,72(sp)
    80001a28:	6406                	ld	s0,64(sp)
    80001a2a:	74e2                	ld	s1,56(sp)
    80001a2c:	7942                	ld	s2,48(sp)
    80001a2e:	79a2                	ld	s3,40(sp)
    80001a30:	7a02                	ld	s4,32(sp)
    80001a32:	6ae2                	ld	s5,24(sp)
    80001a34:	6b42                	ld	s6,16(sp)
    80001a36:	6ba2                	ld	s7,8(sp)
    80001a38:	6161                	addi	sp,sp,80
    80001a3a:	8082                	ret
  return 0;
    80001a3c:	4501                	li	a0,0
}
    80001a3e:	8082                	ret

0000000080001a40 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001a40:	1141                	addi	sp,sp,-16
    80001a42:	e406                	sd	ra,8(sp)
    80001a44:	e022                	sd	s0,0(sp)
    80001a46:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001a48:	4601                	li	a2,0
    80001a4a:	fffff097          	auipc	ra,0xfffff
    80001a4e:	55c080e7          	jalr	1372(ra) # 80000fa6 <walk>
  if(pte == 0)
    80001a52:	c901                	beqz	a0,80001a62 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001a54:	611c                	ld	a5,0(a0)
    80001a56:	9bbd                	andi	a5,a5,-17
    80001a58:	e11c                	sd	a5,0(a0)
}
    80001a5a:	60a2                	ld	ra,8(sp)
    80001a5c:	6402                	ld	s0,0(sp)
    80001a5e:	0141                	addi	sp,sp,16
    80001a60:	8082                	ret
    panic("uvmclear");
    80001a62:	00008517          	auipc	a0,0x8
    80001a66:	98650513          	addi	a0,a0,-1658 # 800093e8 <digits+0x3a8>
    80001a6a:	fffff097          	auipc	ra,0xfffff
    80001a6e:	ac0080e7          	jalr	-1344(ra) # 8000052a <panic>

0000000080001a72 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001a72:	c6bd                	beqz	a3,80001ae0 <copyout+0x6e>
{
    80001a74:	715d                	addi	sp,sp,-80
    80001a76:	e486                	sd	ra,72(sp)
    80001a78:	e0a2                	sd	s0,64(sp)
    80001a7a:	fc26                	sd	s1,56(sp)
    80001a7c:	f84a                	sd	s2,48(sp)
    80001a7e:	f44e                	sd	s3,40(sp)
    80001a80:	f052                	sd	s4,32(sp)
    80001a82:	ec56                	sd	s5,24(sp)
    80001a84:	e85a                	sd	s6,16(sp)
    80001a86:	e45e                	sd	s7,8(sp)
    80001a88:	e062                	sd	s8,0(sp)
    80001a8a:	0880                	addi	s0,sp,80
    80001a8c:	8b2a                	mv	s6,a0
    80001a8e:	8c2e                	mv	s8,a1
    80001a90:	8a32                	mv	s4,a2
    80001a92:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001a94:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001a96:	6a85                	lui	s5,0x1
    80001a98:	a015                	j	80001abc <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001a9a:	9562                	add	a0,a0,s8
    80001a9c:	0004861b          	sext.w	a2,s1
    80001aa0:	85d2                	mv	a1,s4
    80001aa2:	41250533          	sub	a0,a0,s2
    80001aa6:	fffff097          	auipc	ra,0xfffff
    80001aaa:	274080e7          	jalr	628(ra) # 80000d1a <memmove>

    len -= n;
    80001aae:	409989b3          	sub	s3,s3,s1
    src += n;
    80001ab2:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001ab4:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001ab8:	02098263          	beqz	s3,80001adc <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001abc:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001ac0:	85ca                	mv	a1,s2
    80001ac2:	855a                	mv	a0,s6
    80001ac4:	fffff097          	auipc	ra,0xfffff
    80001ac8:	588080e7          	jalr	1416(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    80001acc:	cd01                	beqz	a0,80001ae4 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001ace:	418904b3          	sub	s1,s2,s8
    80001ad2:	94d6                	add	s1,s1,s5
    if(n > len)
    80001ad4:	fc99f3e3          	bgeu	s3,s1,80001a9a <copyout+0x28>
    80001ad8:	84ce                	mv	s1,s3
    80001ada:	b7c1                	j	80001a9a <copyout+0x28>
  }
  return 0;
    80001adc:	4501                	li	a0,0
    80001ade:	a021                	j	80001ae6 <copyout+0x74>
    80001ae0:	4501                	li	a0,0
}
    80001ae2:	8082                	ret
      return -1;
    80001ae4:	557d                	li	a0,-1
}
    80001ae6:	60a6                	ld	ra,72(sp)
    80001ae8:	6406                	ld	s0,64(sp)
    80001aea:	74e2                	ld	s1,56(sp)
    80001aec:	7942                	ld	s2,48(sp)
    80001aee:	79a2                	ld	s3,40(sp)
    80001af0:	7a02                	ld	s4,32(sp)
    80001af2:	6ae2                	ld	s5,24(sp)
    80001af4:	6b42                	ld	s6,16(sp)
    80001af6:	6ba2                	ld	s7,8(sp)
    80001af8:	6c02                	ld	s8,0(sp)
    80001afa:	6161                	addi	sp,sp,80
    80001afc:	8082                	ret

0000000080001afe <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001afe:	caa5                	beqz	a3,80001b6e <copyin+0x70>
{
    80001b00:	715d                	addi	sp,sp,-80
    80001b02:	e486                	sd	ra,72(sp)
    80001b04:	e0a2                	sd	s0,64(sp)
    80001b06:	fc26                	sd	s1,56(sp)
    80001b08:	f84a                	sd	s2,48(sp)
    80001b0a:	f44e                	sd	s3,40(sp)
    80001b0c:	f052                	sd	s4,32(sp)
    80001b0e:	ec56                	sd	s5,24(sp)
    80001b10:	e85a                	sd	s6,16(sp)
    80001b12:	e45e                	sd	s7,8(sp)
    80001b14:	e062                	sd	s8,0(sp)
    80001b16:	0880                	addi	s0,sp,80
    80001b18:	8b2a                	mv	s6,a0
    80001b1a:	8a2e                	mv	s4,a1
    80001b1c:	8c32                	mv	s8,a2
    80001b1e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001b20:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001b22:	6a85                	lui	s5,0x1
    80001b24:	a01d                	j	80001b4a <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001b26:	018505b3          	add	a1,a0,s8
    80001b2a:	0004861b          	sext.w	a2,s1
    80001b2e:	412585b3          	sub	a1,a1,s2
    80001b32:	8552                	mv	a0,s4
    80001b34:	fffff097          	auipc	ra,0xfffff
    80001b38:	1e6080e7          	jalr	486(ra) # 80000d1a <memmove>

    len -= n;
    80001b3c:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001b40:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001b42:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001b46:	02098263          	beqz	s3,80001b6a <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001b4a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001b4e:	85ca                	mv	a1,s2
    80001b50:	855a                	mv	a0,s6
    80001b52:	fffff097          	auipc	ra,0xfffff
    80001b56:	4fa080e7          	jalr	1274(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    80001b5a:	cd01                	beqz	a0,80001b72 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001b5c:	418904b3          	sub	s1,s2,s8
    80001b60:	94d6                	add	s1,s1,s5
    if(n > len)
    80001b62:	fc99f2e3          	bgeu	s3,s1,80001b26 <copyin+0x28>
    80001b66:	84ce                	mv	s1,s3
    80001b68:	bf7d                	j	80001b26 <copyin+0x28>
  }
  return 0;
    80001b6a:	4501                	li	a0,0
    80001b6c:	a021                	j	80001b74 <copyin+0x76>
    80001b6e:	4501                	li	a0,0
}
    80001b70:	8082                	ret
      return -1;
    80001b72:	557d                	li	a0,-1
}
    80001b74:	60a6                	ld	ra,72(sp)
    80001b76:	6406                	ld	s0,64(sp)
    80001b78:	74e2                	ld	s1,56(sp)
    80001b7a:	7942                	ld	s2,48(sp)
    80001b7c:	79a2                	ld	s3,40(sp)
    80001b7e:	7a02                	ld	s4,32(sp)
    80001b80:	6ae2                	ld	s5,24(sp)
    80001b82:	6b42                	ld	s6,16(sp)
    80001b84:	6ba2                	ld	s7,8(sp)
    80001b86:	6c02                	ld	s8,0(sp)
    80001b88:	6161                	addi	sp,sp,80
    80001b8a:	8082                	ret

0000000080001b8c <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001b8c:	c6c5                	beqz	a3,80001c34 <copyinstr+0xa8>
{
    80001b8e:	715d                	addi	sp,sp,-80
    80001b90:	e486                	sd	ra,72(sp)
    80001b92:	e0a2                	sd	s0,64(sp)
    80001b94:	fc26                	sd	s1,56(sp)
    80001b96:	f84a                	sd	s2,48(sp)
    80001b98:	f44e                	sd	s3,40(sp)
    80001b9a:	f052                	sd	s4,32(sp)
    80001b9c:	ec56                	sd	s5,24(sp)
    80001b9e:	e85a                	sd	s6,16(sp)
    80001ba0:	e45e                	sd	s7,8(sp)
    80001ba2:	0880                	addi	s0,sp,80
    80001ba4:	8a2a                	mv	s4,a0
    80001ba6:	8b2e                	mv	s6,a1
    80001ba8:	8bb2                	mv	s7,a2
    80001baa:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001bac:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001bae:	6985                	lui	s3,0x1
    80001bb0:	a035                	j	80001bdc <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001bb2:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001bb6:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001bb8:	0017b793          	seqz	a5,a5
    80001bbc:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001bc0:	60a6                	ld	ra,72(sp)
    80001bc2:	6406                	ld	s0,64(sp)
    80001bc4:	74e2                	ld	s1,56(sp)
    80001bc6:	7942                	ld	s2,48(sp)
    80001bc8:	79a2                	ld	s3,40(sp)
    80001bca:	7a02                	ld	s4,32(sp)
    80001bcc:	6ae2                	ld	s5,24(sp)
    80001bce:	6b42                	ld	s6,16(sp)
    80001bd0:	6ba2                	ld	s7,8(sp)
    80001bd2:	6161                	addi	sp,sp,80
    80001bd4:	8082                	ret
    srcva = va0 + PGSIZE;
    80001bd6:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001bda:	c8a9                	beqz	s1,80001c2c <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001bdc:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001be0:	85ca                	mv	a1,s2
    80001be2:	8552                	mv	a0,s4
    80001be4:	fffff097          	auipc	ra,0xfffff
    80001be8:	468080e7          	jalr	1128(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    80001bec:	c131                	beqz	a0,80001c30 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001bee:	41790833          	sub	a6,s2,s7
    80001bf2:	984e                	add	a6,a6,s3
    if(n > max)
    80001bf4:	0104f363          	bgeu	s1,a6,80001bfa <copyinstr+0x6e>
    80001bf8:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001bfa:	955e                	add	a0,a0,s7
    80001bfc:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001c00:	fc080be3          	beqz	a6,80001bd6 <copyinstr+0x4a>
    80001c04:	985a                	add	a6,a6,s6
    80001c06:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001c08:	41650633          	sub	a2,a0,s6
    80001c0c:	14fd                	addi	s1,s1,-1
    80001c0e:	9b26                	add	s6,s6,s1
    80001c10:	00f60733          	add	a4,a2,a5
    80001c14:	00074703          	lbu	a4,0(a4)
    80001c18:	df49                	beqz	a4,80001bb2 <copyinstr+0x26>
        *dst = *p;
    80001c1a:	00e78023          	sb	a4,0(a5)
      --max;
    80001c1e:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001c22:	0785                	addi	a5,a5,1
    while(n > 0){
    80001c24:	ff0796e3          	bne	a5,a6,80001c10 <copyinstr+0x84>
      dst++;
    80001c28:	8b42                	mv	s6,a6
    80001c2a:	b775                	j	80001bd6 <copyinstr+0x4a>
    80001c2c:	4781                	li	a5,0
    80001c2e:	b769                	j	80001bb8 <copyinstr+0x2c>
      return -1;
    80001c30:	557d                	li	a0,-1
    80001c32:	b779                	j	80001bc0 <copyinstr+0x34>
  int got_null = 0;
    80001c34:	4781                	li	a5,0
  if(got_null){
    80001c36:	0017b793          	seqz	a5,a5
    80001c3a:	40f00533          	neg	a0,a5
}
    80001c3e:	8082                	ret

0000000080001c40 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001c40:	7139                	addi	sp,sp,-64
    80001c42:	fc06                	sd	ra,56(sp)
    80001c44:	f822                	sd	s0,48(sp)
    80001c46:	f426                	sd	s1,40(sp)
    80001c48:	f04a                	sd	s2,32(sp)
    80001c4a:	ec4e                	sd	s3,24(sp)
    80001c4c:	e852                	sd	s4,16(sp)
    80001c4e:	e456                	sd	s5,8(sp)
    80001c50:	e05a                	sd	s6,0(sp)
    80001c52:	0080                	addi	s0,sp,64
    80001c54:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c56:	00011497          	auipc	s1,0x11
    80001c5a:	a7a48493          	addi	s1,s1,-1414 # 800126d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001c5e:	8b26                	mv	s6,s1
    80001c60:	00007a97          	auipc	s5,0x7
    80001c64:	3a0a8a93          	addi	s5,s5,928 # 80009000 <etext>
    80001c68:	04000937          	lui	s2,0x4000
    80001c6c:	197d                	addi	s2,s2,-1
    80001c6e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c70:	00023a17          	auipc	s4,0x23
    80001c74:	260a0a13          	addi	s4,s4,608 # 80024ed0 <tickslock>
    char *pa = kalloc();
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	e5a080e7          	jalr	-422(ra) # 80000ad2 <kalloc>
    80001c80:	862a                	mv	a2,a0
    if(pa == 0)
    80001c82:	c131                	beqz	a0,80001cc6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001c84:	416485b3          	sub	a1,s1,s6
    80001c88:	8595                	srai	a1,a1,0x5
    80001c8a:	000ab783          	ld	a5,0(s5)
    80001c8e:	02f585b3          	mul	a1,a1,a5
    80001c92:	2585                	addiw	a1,a1,1
    80001c94:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001c98:	4719                	li	a4,6
    80001c9a:	6685                	lui	a3,0x1
    80001c9c:	40b905b3          	sub	a1,s2,a1
    80001ca0:	854e                	mv	a0,s3
    80001ca2:	fffff097          	auipc	ra,0xfffff
    80001ca6:	47a080e7          	jalr	1146(ra) # 8000111c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001caa:	4a048493          	addi	s1,s1,1184
    80001cae:	fd4495e3          	bne	s1,s4,80001c78 <proc_mapstacks+0x38>
  }
}
    80001cb2:	70e2                	ld	ra,56(sp)
    80001cb4:	7442                	ld	s0,48(sp)
    80001cb6:	74a2                	ld	s1,40(sp)
    80001cb8:	7902                	ld	s2,32(sp)
    80001cba:	69e2                	ld	s3,24(sp)
    80001cbc:	6a42                	ld	s4,16(sp)
    80001cbe:	6aa2                	ld	s5,8(sp)
    80001cc0:	6b02                	ld	s6,0(sp)
    80001cc2:	6121                	addi	sp,sp,64
    80001cc4:	8082                	ret
      panic("kalloc");
    80001cc6:	00007517          	auipc	a0,0x7
    80001cca:	73250513          	addi	a0,a0,1842 # 800093f8 <digits+0x3b8>
    80001cce:	fffff097          	auipc	ra,0xfffff
    80001cd2:	85c080e7          	jalr	-1956(ra) # 8000052a <panic>

0000000080001cd6 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    80001cd6:	7139                	addi	sp,sp,-64
    80001cd8:	fc06                	sd	ra,56(sp)
    80001cda:	f822                	sd	s0,48(sp)
    80001cdc:	f426                	sd	s1,40(sp)
    80001cde:	f04a                	sd	s2,32(sp)
    80001ce0:	ec4e                	sd	s3,24(sp)
    80001ce2:	e852                	sd	s4,16(sp)
    80001ce4:	e456                	sd	s5,8(sp)
    80001ce6:	e05a                	sd	s6,0(sp)
    80001ce8:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001cea:	00007597          	auipc	a1,0x7
    80001cee:	71658593          	addi	a1,a1,1814 # 80009400 <digits+0x3c0>
    80001cf2:	00010517          	auipc	a0,0x10
    80001cf6:	5ae50513          	addi	a0,a0,1454 # 800122a0 <pid_lock>
    80001cfa:	fffff097          	auipc	ra,0xfffff
    80001cfe:	e38080e7          	jalr	-456(ra) # 80000b32 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001d02:	00007597          	auipc	a1,0x7
    80001d06:	70658593          	addi	a1,a1,1798 # 80009408 <digits+0x3c8>
    80001d0a:	00010517          	auipc	a0,0x10
    80001d0e:	5ae50513          	addi	a0,a0,1454 # 800122b8 <wait_lock>
    80001d12:	fffff097          	auipc	ra,0xfffff
    80001d16:	e20080e7          	jalr	-480(ra) # 80000b32 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d1a:	00011497          	auipc	s1,0x11
    80001d1e:	9b648493          	addi	s1,s1,-1610 # 800126d0 <proc>
      initlock(&p->lock, "proc");
    80001d22:	00007b17          	auipc	s6,0x7
    80001d26:	6f6b0b13          	addi	s6,s6,1782 # 80009418 <digits+0x3d8>
      p->kstack = KSTACK((int) (p - proc));
    80001d2a:	8aa6                	mv	s5,s1
    80001d2c:	00007a17          	auipc	s4,0x7
    80001d30:	2d4a0a13          	addi	s4,s4,724 # 80009000 <etext>
    80001d34:	04000937          	lui	s2,0x4000
    80001d38:	197d                	addi	s2,s2,-1
    80001d3a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d3c:	00023997          	auipc	s3,0x23
    80001d40:	19498993          	addi	s3,s3,404 # 80024ed0 <tickslock>
      initlock(&p->lock, "proc");
    80001d44:	85da                	mv	a1,s6
    80001d46:	8526                	mv	a0,s1
    80001d48:	fffff097          	auipc	ra,0xfffff
    80001d4c:	dea080e7          	jalr	-534(ra) # 80000b32 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001d50:	415487b3          	sub	a5,s1,s5
    80001d54:	8795                	srai	a5,a5,0x5
    80001d56:	000a3703          	ld	a4,0(s4)
    80001d5a:	02e787b3          	mul	a5,a5,a4
    80001d5e:	2785                	addiw	a5,a5,1
    80001d60:	00d7979b          	slliw	a5,a5,0xd
    80001d64:	40f907b3          	sub	a5,s2,a5
    80001d68:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d6a:	4a048493          	addi	s1,s1,1184
    80001d6e:	fd349be3          	bne	s1,s3,80001d44 <procinit+0x6e>
  }
}
    80001d72:	70e2                	ld	ra,56(sp)
    80001d74:	7442                	ld	s0,48(sp)
    80001d76:	74a2                	ld	s1,40(sp)
    80001d78:	7902                	ld	s2,32(sp)
    80001d7a:	69e2                	ld	s3,24(sp)
    80001d7c:	6a42                	ld	s4,16(sp)
    80001d7e:	6aa2                	ld	s5,8(sp)
    80001d80:	6b02                	ld	s6,0(sp)
    80001d82:	6121                	addi	sp,sp,64
    80001d84:	8082                	ret

0000000080001d86 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001d86:	1141                	addi	sp,sp,-16
    80001d88:	e422                	sd	s0,8(sp)
    80001d8a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d8c:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001d8e:	2501                	sext.w	a0,a0
    80001d90:	6422                	ld	s0,8(sp)
    80001d92:	0141                	addi	sp,sp,16
    80001d94:	8082                	ret

0000000080001d96 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001d96:	1141                	addi	sp,sp,-16
    80001d98:	e422                	sd	s0,8(sp)
    80001d9a:	0800                	addi	s0,sp,16
    80001d9c:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001d9e:	2781                	sext.w	a5,a5
    80001da0:	079e                	slli	a5,a5,0x7
  return c;
}
    80001da2:	00010517          	auipc	a0,0x10
    80001da6:	52e50513          	addi	a0,a0,1326 # 800122d0 <cpus>
    80001daa:	953e                	add	a0,a0,a5
    80001dac:	6422                	ld	s0,8(sp)
    80001dae:	0141                	addi	sp,sp,16
    80001db0:	8082                	ret

0000000080001db2 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001db2:	1101                	addi	sp,sp,-32
    80001db4:	ec06                	sd	ra,24(sp)
    80001db6:	e822                	sd	s0,16(sp)
    80001db8:	e426                	sd	s1,8(sp)
    80001dba:	1000                	addi	s0,sp,32
  push_off();
    80001dbc:	fffff097          	auipc	ra,0xfffff
    80001dc0:	dba080e7          	jalr	-582(ra) # 80000b76 <push_off>
    80001dc4:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001dc6:	2781                	sext.w	a5,a5
    80001dc8:	079e                	slli	a5,a5,0x7
    80001dca:	00010717          	auipc	a4,0x10
    80001dce:	4d670713          	addi	a4,a4,1238 # 800122a0 <pid_lock>
    80001dd2:	97ba                	add	a5,a5,a4
    80001dd4:	7b84                	ld	s1,48(a5)
  pop_off();
    80001dd6:	fffff097          	auipc	ra,0xfffff
    80001dda:	e40080e7          	jalr	-448(ra) # 80000c16 <pop_off>
  return p;
}
    80001dde:	8526                	mv	a0,s1
    80001de0:	60e2                	ld	ra,24(sp)
    80001de2:	6442                	ld	s0,16(sp)
    80001de4:	64a2                	ld	s1,8(sp)
    80001de6:	6105                	addi	sp,sp,32
    80001de8:	8082                	ret

0000000080001dea <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001dea:	1141                	addi	sp,sp,-16
    80001dec:	e406                	sd	ra,8(sp)
    80001dee:	e022                	sd	s0,0(sp)
    80001df0:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001df2:	00000097          	auipc	ra,0x0
    80001df6:	fc0080e7          	jalr	-64(ra) # 80001db2 <myproc>
    80001dfa:	fffff097          	auipc	ra,0xfffff
    80001dfe:	e7c080e7          	jalr	-388(ra) # 80000c76 <release>

  if (first) {
    80001e02:	00008797          	auipc	a5,0x8
    80001e06:	d3e7a783          	lw	a5,-706(a5) # 80009b40 <first.1>
    80001e0a:	eb89                	bnez	a5,80001e1c <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001e0c:	00001097          	auipc	ra,0x1
    80001e10:	fde080e7          	jalr	-34(ra) # 80002dea <usertrapret>
}
    80001e14:	60a2                	ld	ra,8(sp)
    80001e16:	6402                	ld	s0,0(sp)
    80001e18:	0141                	addi	sp,sp,16
    80001e1a:	8082                	ret
    first = 0;
    80001e1c:	00008797          	auipc	a5,0x8
    80001e20:	d207a223          	sw	zero,-732(a5) # 80009b40 <first.1>
    fsinit(ROOTDEV);
    80001e24:	4505                	li	a0,1
    80001e26:	00002097          	auipc	ra,0x2
    80001e2a:	db4080e7          	jalr	-588(ra) # 80003bda <fsinit>
    80001e2e:	bff9                	j	80001e0c <forkret+0x22>

0000000080001e30 <allocpid>:
allocpid() {
    80001e30:	1101                	addi	sp,sp,-32
    80001e32:	ec06                	sd	ra,24(sp)
    80001e34:	e822                	sd	s0,16(sp)
    80001e36:	e426                	sd	s1,8(sp)
    80001e38:	e04a                	sd	s2,0(sp)
    80001e3a:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001e3c:	00010917          	auipc	s2,0x10
    80001e40:	46490913          	addi	s2,s2,1124 # 800122a0 <pid_lock>
    80001e44:	854a                	mv	a0,s2
    80001e46:	fffff097          	auipc	ra,0xfffff
    80001e4a:	d7c080e7          	jalr	-644(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001e4e:	00008797          	auipc	a5,0x8
    80001e52:	cf678793          	addi	a5,a5,-778 # 80009b44 <nextpid>
    80001e56:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001e58:	0014871b          	addiw	a4,s1,1
    80001e5c:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001e5e:	854a                	mv	a0,s2
    80001e60:	fffff097          	auipc	ra,0xfffff
    80001e64:	e16080e7          	jalr	-490(ra) # 80000c76 <release>
}
    80001e68:	8526                	mv	a0,s1
    80001e6a:	60e2                	ld	ra,24(sp)
    80001e6c:	6442                	ld	s0,16(sp)
    80001e6e:	64a2                	ld	s1,8(sp)
    80001e70:	6902                	ld	s2,0(sp)
    80001e72:	6105                	addi	sp,sp,32
    80001e74:	8082                	ret

0000000080001e76 <setAndGetPageFaultsNum>:
setAndGetPageFaultsNum(int num){
    80001e76:	1101                	addi	sp,sp,-32
    80001e78:	ec06                	sd	ra,24(sp)
    80001e7a:	e822                	sd	s0,16(sp)
    80001e7c:	e426                	sd	s1,8(sp)
    80001e7e:	1000                	addi	s0,sp,32
    80001e80:	84aa                	mv	s1,a0
    struct proc * p = myproc();
    80001e82:	00000097          	auipc	ra,0x0
    80001e86:	f30080e7          	jalr	-208(ra) # 80001db2 <myproc>
    80001e8a:	87aa                	mv	a5,a0
    int tmp = p->numOfPageFault;
    80001e8c:	49852503          	lw	a0,1176(a0)
    if(num >= 0){
    80001e90:	0004c463          	bltz	s1,80001e98 <setAndGetPageFaultsNum+0x22>
      p->numOfPageFault = 0;
    80001e94:	4807ac23          	sw	zero,1176(a5)
}
    80001e98:	60e2                	ld	ra,24(sp)
    80001e9a:	6442                	ld	s0,16(sp)
    80001e9c:	64a2                	ld	s1,8(sp)
    80001e9e:	6105                	addi	sp,sp,32
    80001ea0:	8082                	ret

0000000080001ea2 <proc_pagetable>:
{
    80001ea2:	1101                	addi	sp,sp,-32
    80001ea4:	ec06                	sd	ra,24(sp)
    80001ea6:	e822                	sd	s0,16(sp)
    80001ea8:	e426                	sd	s1,8(sp)
    80001eaa:	e04a                	sd	s2,0(sp)
    80001eac:	1000                	addi	s0,sp,32
    80001eae:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001eb0:	fffff097          	auipc	ra,0xfffff
    80001eb4:	52c080e7          	jalr	1324(ra) # 800013dc <uvmcreate>
    80001eb8:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001eba:	c121                	beqz	a0,80001efa <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ebc:	4729                	li	a4,10
    80001ebe:	00006697          	auipc	a3,0x6
    80001ec2:	14268693          	addi	a3,a3,322 # 80008000 <_trampoline>
    80001ec6:	6605                	lui	a2,0x1
    80001ec8:	040005b7          	lui	a1,0x4000
    80001ecc:	15fd                	addi	a1,a1,-1
    80001ece:	05b2                	slli	a1,a1,0xc
    80001ed0:	fffff097          	auipc	ra,0xfffff
    80001ed4:	1be080e7          	jalr	446(ra) # 8000108e <mappages>
    80001ed8:	02054863          	bltz	a0,80001f08 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001edc:	4719                	li	a4,6
    80001ede:	05893683          	ld	a3,88(s2)
    80001ee2:	6605                	lui	a2,0x1
    80001ee4:	020005b7          	lui	a1,0x2000
    80001ee8:	15fd                	addi	a1,a1,-1
    80001eea:	05b6                	slli	a1,a1,0xd
    80001eec:	8526                	mv	a0,s1
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	1a0080e7          	jalr	416(ra) # 8000108e <mappages>
    80001ef6:	02054163          	bltz	a0,80001f18 <proc_pagetable+0x76>
}
    80001efa:	8526                	mv	a0,s1
    80001efc:	60e2                	ld	ra,24(sp)
    80001efe:	6442                	ld	s0,16(sp)
    80001f00:	64a2                	ld	s1,8(sp)
    80001f02:	6902                	ld	s2,0(sp)
    80001f04:	6105                	addi	sp,sp,32
    80001f06:	8082                	ret
    uvmfree(pagetable, 0);
    80001f08:	4581                	li	a1,0
    80001f0a:	8526                	mv	a0,s1
    80001f0c:	00000097          	auipc	ra,0x0
    80001f10:	9f6080e7          	jalr	-1546(ra) # 80001902 <uvmfree>
    return 0;
    80001f14:	4481                	li	s1,0
    80001f16:	b7d5                	j	80001efa <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f18:	4681                	li	a3,0
    80001f1a:	4605                	li	a2,1
    80001f1c:	040005b7          	lui	a1,0x4000
    80001f20:	15fd                	addi	a1,a1,-1
    80001f22:	05b2                	slli	a1,a1,0xc
    80001f24:	8526                	mv	a0,s1
    80001f26:	fffff097          	auipc	ra,0xfffff
    80001f2a:	31c080e7          	jalr	796(ra) # 80001242 <uvmunmap>
    uvmfree(pagetable, 0);
    80001f2e:	4581                	li	a1,0
    80001f30:	8526                	mv	a0,s1
    80001f32:	00000097          	auipc	ra,0x0
    80001f36:	9d0080e7          	jalr	-1584(ra) # 80001902 <uvmfree>
    return 0;
    80001f3a:	4481                	li	s1,0
    80001f3c:	bf7d                	j	80001efa <proc_pagetable+0x58>

0000000080001f3e <proc_freepagetable>:
{
    80001f3e:	1101                	addi	sp,sp,-32
    80001f40:	ec06                	sd	ra,24(sp)
    80001f42:	e822                	sd	s0,16(sp)
    80001f44:	e426                	sd	s1,8(sp)
    80001f46:	e04a                	sd	s2,0(sp)
    80001f48:	1000                	addi	s0,sp,32
    80001f4a:	84aa                	mv	s1,a0
    80001f4c:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f4e:	4681                	li	a3,0
    80001f50:	4605                	li	a2,1
    80001f52:	040005b7          	lui	a1,0x4000
    80001f56:	15fd                	addi	a1,a1,-1
    80001f58:	05b2                	slli	a1,a1,0xc
    80001f5a:	fffff097          	auipc	ra,0xfffff
    80001f5e:	2e8080e7          	jalr	744(ra) # 80001242 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001f62:	4681                	li	a3,0
    80001f64:	4605                	li	a2,1
    80001f66:	020005b7          	lui	a1,0x2000
    80001f6a:	15fd                	addi	a1,a1,-1
    80001f6c:	05b6                	slli	a1,a1,0xd
    80001f6e:	8526                	mv	a0,s1
    80001f70:	fffff097          	auipc	ra,0xfffff
    80001f74:	2d2080e7          	jalr	722(ra) # 80001242 <uvmunmap>
  uvmfree(pagetable, sz);
    80001f78:	85ca                	mv	a1,s2
    80001f7a:	8526                	mv	a0,s1
    80001f7c:	00000097          	auipc	ra,0x0
    80001f80:	986080e7          	jalr	-1658(ra) # 80001902 <uvmfree>
}
    80001f84:	60e2                	ld	ra,24(sp)
    80001f86:	6442                	ld	s0,16(sp)
    80001f88:	64a2                	ld	s1,8(sp)
    80001f8a:	6902                	ld	s2,0(sp)
    80001f8c:	6105                	addi	sp,sp,32
    80001f8e:	8082                	ret

0000000080001f90 <freeproc>:
{
    80001f90:	1101                	addi	sp,sp,-32
    80001f92:	ec06                	sd	ra,24(sp)
    80001f94:	e822                	sd	s0,16(sp)
    80001f96:	e426                	sd	s1,8(sp)
    80001f98:	1000                	addi	s0,sp,32
    80001f9a:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001f9c:	6d28                	ld	a0,88(a0)
    80001f9e:	c509                	beqz	a0,80001fa8 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001fa0:	fffff097          	auipc	ra,0xfffff
    80001fa4:	a36080e7          	jalr	-1482(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    80001fa8:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable){
    80001fac:	68a8                	ld	a0,80(s1)
    80001fae:	c511                	beqz	a0,80001fba <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001fb0:	64ac                	ld	a1,72(s1)
    80001fb2:	00000097          	auipc	ra,0x0
    80001fb6:	f8c080e7          	jalr	-116(ra) # 80001f3e <proc_freepagetable>
  p->pagetable = 0;
    80001fba:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001fbe:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001fc2:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001fc6:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001fca:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001fce:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001fd2:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001fd6:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001fda:	0004ac23          	sw	zero,24(s1)
}
    80001fde:	60e2                	ld	ra,24(sp)
    80001fe0:	6442                	ld	s0,16(sp)
    80001fe2:	64a2                	ld	s1,8(sp)
    80001fe4:	6105                	addi	sp,sp,32
    80001fe6:	8082                	ret

0000000080001fe8 <allocproc>:
{
    80001fe8:	7179                	addi	sp,sp,-48
    80001fea:	f406                	sd	ra,40(sp)
    80001fec:	f022                	sd	s0,32(sp)
    80001fee:	ec26                	sd	s1,24(sp)
    80001ff0:	e84a                	sd	s2,16(sp)
    80001ff2:	e44e                	sd	s3,8(sp)
    80001ff4:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ff6:	00010497          	auipc	s1,0x10
    80001ffa:	6da48493          	addi	s1,s1,1754 # 800126d0 <proc>
    80001ffe:	00023997          	auipc	s3,0x23
    80002002:	ed298993          	addi	s3,s3,-302 # 80024ed0 <tickslock>
    acquire(&p->lock);
    80002006:	8926                	mv	s2,s1
    80002008:	8526                	mv	a0,s1
    8000200a:	fffff097          	auipc	ra,0xfffff
    8000200e:	bb8080e7          	jalr	-1096(ra) # 80000bc2 <acquire>
    if(p->state == UNUSED) {
    80002012:	4c9c                	lw	a5,24(s1)
    80002014:	cf81                	beqz	a5,8000202c <allocproc+0x44>
      release(&p->lock);
    80002016:	8526                	mv	a0,s1
    80002018:	fffff097          	auipc	ra,0xfffff
    8000201c:	c5e080e7          	jalr	-930(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002020:	4a048493          	addi	s1,s1,1184
    80002024:	ff3491e3          	bne	s1,s3,80002006 <allocproc+0x1e>
  return 0;
    80002028:	4481                	li	s1,0
    8000202a:	a055                	j	800020ce <allocproc+0xe6>
  p->pid = allocpid();
    8000202c:	00000097          	auipc	ra,0x0
    80002030:	e04080e7          	jalr	-508(ra) # 80001e30 <allocpid>
    80002034:	d888                	sw	a0,48(s1)
  p->state = USED;
    80002036:	4785                	li	a5,1
    80002038:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    8000203a:	fffff097          	auipc	ra,0xfffff
    8000203e:	a98080e7          	jalr	-1384(ra) # 80000ad2 <kalloc>
    80002042:	89aa                	mv	s3,a0
    80002044:	eca8                	sd	a0,88(s1)
    80002046:	cd41                	beqz	a0,800020de <allocproc+0xf6>
  p->pagetable = proc_pagetable(p);
    80002048:	8526                	mv	a0,s1
    8000204a:	00000097          	auipc	ra,0x0
    8000204e:	e58080e7          	jalr	-424(ra) # 80001ea2 <proc_pagetable>
    80002052:	89aa                	mv	s3,a0
    80002054:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80002056:	c145                	beqz	a0,800020f6 <allocproc+0x10e>
    p->swapOffset = 0;
    80002058:	1604a823          	sw	zero,368(s1)
    if (p->pid > 2){
    8000205c:	5898                	lw	a4,48(s1)
    8000205e:	4789                	li	a5,2
    80002060:	0ae7c763          	blt	a5,a4,8000210e <allocproc+0x126>
    p->numOfPhyPages = 0;
    80002064:	1604ac23          	sw	zero,376(s1)
    p->numOfTotalPages = 0;
    80002068:	1604ae23          	sw	zero,380(s1)
    p->numOfPageFault = 0;
    8000206c:	4804ac23          	sw	zero,1176(s1)
      p->nextPlaceInQueue = 1;
    80002070:	4785                	li	a5,1
    80002072:	16f4aa23          	sw	a5,372(s1)
    for(int k = 0; k < MAX_PSYC_PAGES; k++){
    80002076:	18048793          	addi	a5,s1,384
    8000207a:	30090913          	addi	s2,s2,768
      p->swapPagesArray[k].va = -1;
    8000207e:	577d                	li	a4,-1
      p->swapPagesArray[k].inUse = 0;
    80002080:	0007a623          	sw	zero,12(a5)
      p->swapPagesArray[k].va = -1;
    80002084:	e398                	sd	a4,0(a5)
      p->physPagesArray[k].inUse = 0;
    80002086:	1a07a223          	sw	zero,420(a5)
      p->physPagesArray[k].va = -1;
    8000208a:	18e7bc23          	sd	a4,408(a5)
        p->swapPagesArray[k].placeInQueue = 0;
    8000208e:	0007a823          	sw	zero,16(a5)
        p->physPagesArray[k].placeInQueue = 0;
    80002092:	1a07a423          	sw	zero,424(a5)
    for(int k = 0; k < MAX_PSYC_PAGES; k++){
    80002096:	07e1                	addi	a5,a5,24
    80002098:	ff2794e3          	bne	a5,s2,80002080 <allocproc+0x98>
    p->swapPagesArray[16].inUse = 0;
    8000209c:	3004a623          	sw	zero,780(s1)
    p->swapPagesArray[16].va = -1;
    800020a0:	57fd                	li	a5,-1
    800020a2:	30f4b023          	sd	a5,768(s1)
      p->swapPagesArray[16].placeInQueue = 0;
    800020a6:	3004a823          	sw	zero,784(s1)
  memset(&p->context, 0, sizeof(p->context));
    800020aa:	07000613          	li	a2,112
    800020ae:	4581                	li	a1,0
    800020b0:	06048513          	addi	a0,s1,96
    800020b4:	fffff097          	auipc	ra,0xfffff
    800020b8:	c0a080e7          	jalr	-1014(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    800020bc:	00000797          	auipc	a5,0x0
    800020c0:	d2e78793          	addi	a5,a5,-722 # 80001dea <forkret>
    800020c4:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800020c6:	60bc                	ld	a5,64(s1)
    800020c8:	6705                	lui	a4,0x1
    800020ca:	97ba                	add	a5,a5,a4
    800020cc:	f4bc                	sd	a5,104(s1)
}
    800020ce:	8526                	mv	a0,s1
    800020d0:	70a2                	ld	ra,40(sp)
    800020d2:	7402                	ld	s0,32(sp)
    800020d4:	64e2                	ld	s1,24(sp)
    800020d6:	6942                	ld	s2,16(sp)
    800020d8:	69a2                	ld	s3,8(sp)
    800020da:	6145                	addi	sp,sp,48
    800020dc:	8082                	ret
    freeproc(p);
    800020de:	8526                	mv	a0,s1
    800020e0:	00000097          	auipc	ra,0x0
    800020e4:	eb0080e7          	jalr	-336(ra) # 80001f90 <freeproc>
    release(&p->lock);
    800020e8:	8526                	mv	a0,s1
    800020ea:	fffff097          	auipc	ra,0xfffff
    800020ee:	b8c080e7          	jalr	-1140(ra) # 80000c76 <release>
    return 0;
    800020f2:	84ce                	mv	s1,s3
    800020f4:	bfe9                	j	800020ce <allocproc+0xe6>
    freeproc(p);
    800020f6:	8526                	mv	a0,s1
    800020f8:	00000097          	auipc	ra,0x0
    800020fc:	e98080e7          	jalr	-360(ra) # 80001f90 <freeproc>
    release(&p->lock);
    80002100:	8526                	mv	a0,s1
    80002102:	fffff097          	auipc	ra,0xfffff
    80002106:	b74080e7          	jalr	-1164(ra) # 80000c76 <release>
    return 0;
    8000210a:	84ce                	mv	s1,s3
    8000210c:	b7c9                	j	800020ce <allocproc+0xe6>
      release(&p->lock);
    8000210e:	8526                	mv	a0,s1
    80002110:	fffff097          	auipc	ra,0xfffff
    80002114:	b66080e7          	jalr	-1178(ra) # 80000c76 <release>
      createSwapFile(p);
    80002118:	8526                	mv	a0,s1
    8000211a:	00002097          	auipc	ra,0x2
    8000211e:	742080e7          	jalr	1858(ra) # 8000485c <createSwapFile>
      acquire(&p->lock);
    80002122:	8526                	mv	a0,s1
    80002124:	fffff097          	auipc	ra,0xfffff
    80002128:	a9e080e7          	jalr	-1378(ra) # 80000bc2 <acquire>
    8000212c:	bf25                	j	80002064 <allocproc+0x7c>

000000008000212e <userinit>:
{
    8000212e:	1101                	addi	sp,sp,-32
    80002130:	ec06                	sd	ra,24(sp)
    80002132:	e822                	sd	s0,16(sp)
    80002134:	e426                	sd	s1,8(sp)
    80002136:	1000                	addi	s0,sp,32
  p = allocproc();
    80002138:	00000097          	auipc	ra,0x0
    8000213c:	eb0080e7          	jalr	-336(ra) # 80001fe8 <allocproc>
    80002140:	84aa                	mv	s1,a0
  initproc = p;
    80002142:	00008797          	auipc	a5,0x8
    80002146:	eea7b323          	sd	a0,-282(a5) # 8000a028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    8000214a:	03400613          	li	a2,52
    8000214e:	00008597          	auipc	a1,0x8
    80002152:	a0258593          	addi	a1,a1,-1534 # 80009b50 <initcode>
    80002156:	6928                	ld	a0,80(a0)
    80002158:	fffff097          	auipc	ra,0xfffff
    8000215c:	2b2080e7          	jalr	690(ra) # 8000140a <uvminit>
  p->sz = PGSIZE;
    80002160:	6785                	lui	a5,0x1
    80002162:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80002164:	6cb8                	ld	a4,88(s1)
    80002166:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    8000216a:	6cb8                	ld	a4,88(s1)
    8000216c:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    8000216e:	4641                	li	a2,16
    80002170:	00007597          	auipc	a1,0x7
    80002174:	2b058593          	addi	a1,a1,688 # 80009420 <digits+0x3e0>
    80002178:	15848513          	addi	a0,s1,344
    8000217c:	fffff097          	auipc	ra,0xfffff
    80002180:	c94080e7          	jalr	-876(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    80002184:	00007517          	auipc	a0,0x7
    80002188:	2ac50513          	addi	a0,a0,684 # 80009430 <digits+0x3f0>
    8000218c:	00002097          	auipc	ra,0x2
    80002190:	47c080e7          	jalr	1148(ra) # 80004608 <namei>
    80002194:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80002198:	478d                	li	a5,3
    8000219a:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    8000219c:	8526                	mv	a0,s1
    8000219e:	fffff097          	auipc	ra,0xfffff
    800021a2:	ad8080e7          	jalr	-1320(ra) # 80000c76 <release>
}
    800021a6:	60e2                	ld	ra,24(sp)
    800021a8:	6442                	ld	s0,16(sp)
    800021aa:	64a2                	ld	s1,8(sp)
    800021ac:	6105                	addi	sp,sp,32
    800021ae:	8082                	ret

00000000800021b0 <growproc>:
{
    800021b0:	1101                	addi	sp,sp,-32
    800021b2:	ec06                	sd	ra,24(sp)
    800021b4:	e822                	sd	s0,16(sp)
    800021b6:	e426                	sd	s1,8(sp)
    800021b8:	e04a                	sd	s2,0(sp)
    800021ba:	1000                	addi	s0,sp,32
    800021bc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800021be:	00000097          	auipc	ra,0x0
    800021c2:	bf4080e7          	jalr	-1036(ra) # 80001db2 <myproc>
    800021c6:	892a                	mv	s2,a0
  sz = p->sz;
    800021c8:	652c                	ld	a1,72(a0)
    800021ca:	0005861b          	sext.w	a2,a1
  if(n > 0){
    800021ce:	00904f63          	bgtz	s1,800021ec <growproc+0x3c>
  } else if(n < 0){
    800021d2:	0204cc63          	bltz	s1,8000220a <growproc+0x5a>
  p->sz = sz;
    800021d6:	1602                	slli	a2,a2,0x20
    800021d8:	9201                	srli	a2,a2,0x20
    800021da:	04c93423          	sd	a2,72(s2)
  return 0;
    800021de:	4501                	li	a0,0
}
    800021e0:	60e2                	ld	ra,24(sp)
    800021e2:	6442                	ld	s0,16(sp)
    800021e4:	64a2                	ld	s1,8(sp)
    800021e6:	6902                	ld	s2,0(sp)
    800021e8:	6105                	addi	sp,sp,32
    800021ea:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    800021ec:	9e25                	addw	a2,a2,s1
    800021ee:	1602                	slli	a2,a2,0x20
    800021f0:	9201                	srli	a2,a2,0x20
    800021f2:	1582                	slli	a1,a1,0x20
    800021f4:	9181                	srli	a1,a1,0x20
    800021f6:	6928                	ld	a0,80(a0)
    800021f8:	fffff097          	auipc	ra,0xfffff
    800021fc:	50c080e7          	jalr	1292(ra) # 80001704 <uvmalloc>
    80002200:	0005061b          	sext.w	a2,a0
    80002204:	fa69                	bnez	a2,800021d6 <growproc+0x26>
      return -1;
    80002206:	557d                	li	a0,-1
    80002208:	bfe1                	j	800021e0 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000220a:	9e25                	addw	a2,a2,s1
    8000220c:	1602                	slli	a2,a2,0x20
    8000220e:	9201                	srli	a2,a2,0x20
    80002210:	1582                	slli	a1,a1,0x20
    80002212:	9181                	srli	a1,a1,0x20
    80002214:	6928                	ld	a0,80(a0)
    80002216:	fffff097          	auipc	ra,0xfffff
    8000221a:	4a6080e7          	jalr	1190(ra) # 800016bc <uvmdealloc>
    8000221e:	0005061b          	sext.w	a2,a0
    80002222:	bf55                	j	800021d6 <growproc+0x26>

0000000080002224 <swapFileCopy>:
swapFileCopy(struct proc* np, struct proc* p){
    80002224:	715d                	addi	sp,sp,-80
    80002226:	e486                	sd	ra,72(sp)
    80002228:	e0a2                	sd	s0,64(sp)
    8000222a:	fc26                	sd	s1,56(sp)
    8000222c:	f84a                	sd	s2,48(sp)
    8000222e:	f44e                	sd	s3,40(sp)
    80002230:	f052                	sd	s4,32(sp)
    80002232:	ec56                	sd	s5,24(sp)
    80002234:	e85a                	sd	s6,16(sp)
    80002236:	e45e                	sd	s7,8(sp)
    80002238:	e062                	sd	s8,0(sp)
    8000223a:	0880                	addi	s0,sp,80
    8000223c:	8aaa                	mv	s5,a0
    8000223e:	8b2e                	mv	s6,a1
  if ( (buffer = kalloc()) == 0 ){
    80002240:	fffff097          	auipc	ra,0xfffff
    80002244:	892080e7          	jalr	-1902(ra) # 80000ad2 <kalloc>
    80002248:	cd35                	beqz	a0,800022c4 <swapFileCopy+0xa0>
    8000224a:	89aa                	mv	s3,a0
  release(&np->lock);
    8000224c:	8556                	mv	a0,s5
    8000224e:	fffff097          	auipc	ra,0xfffff
    80002252:	a28080e7          	jalr	-1496(ra) # 80000c76 <release>
  int offset = p->swapOffset;
    80002256:	170b2b83          	lw	s7,368(s6)
  for (int i=0; i<offset; i=i+PGSIZE){
    8000225a:	03705f63          	blez	s7,80002298 <swapFileCopy+0x74>
    8000225e:	4481                	li	s1,0
    if(readFromSwapFile(p, buffer, i, PGSIZE) == -1){
    80002260:	5a7d                	li	s4,-1
  for (int i=0; i<offset; i=i+PGSIZE){
    80002262:	6c05                	lui	s8,0x1
    if(readFromSwapFile(p, buffer, i, PGSIZE) == -1){
    80002264:	0004891b          	sext.w	s2,s1
    80002268:	6685                	lui	a3,0x1
    8000226a:	864a                	mv	a2,s2
    8000226c:	85ce                	mv	a1,s3
    8000226e:	855a                	mv	a0,s6
    80002270:	00002097          	auipc	ra,0x2
    80002274:	6e6080e7          	jalr	1766(ra) # 80004956 <readFromSwapFile>
    80002278:	05450e63          	beq	a0,s4,800022d4 <swapFileCopy+0xb0>
    if(writeToSwapFile(np, buffer, i, PGSIZE) == -1){
    8000227c:	6685                	lui	a3,0x1
    8000227e:	864a                	mv	a2,s2
    80002280:	85ce                	mv	a1,s3
    80002282:	8556                	mv	a0,s5
    80002284:	00002097          	auipc	ra,0x2
    80002288:	688080e7          	jalr	1672(ra) # 8000490c <writeToSwapFile>
    8000228c:	05450c63          	beq	a0,s4,800022e4 <swapFileCopy+0xc0>
  for (int i=0; i<offset; i=i+PGSIZE){
    80002290:	009c04bb          	addw	s1,s8,s1
    80002294:	fd74c8e3          	blt	s1,s7,80002264 <swapFileCopy+0x40>
  kfree(buffer);
    80002298:	854e                	mv	a0,s3
    8000229a:	ffffe097          	auipc	ra,0xffffe
    8000229e:	73c080e7          	jalr	1852(ra) # 800009d6 <kfree>
  acquire(&np->lock);
    800022a2:	8556                	mv	a0,s5
    800022a4:	fffff097          	auipc	ra,0xfffff
    800022a8:	91e080e7          	jalr	-1762(ra) # 80000bc2 <acquire>
}
    800022ac:	60a6                	ld	ra,72(sp)
    800022ae:	6406                	ld	s0,64(sp)
    800022b0:	74e2                	ld	s1,56(sp)
    800022b2:	7942                	ld	s2,48(sp)
    800022b4:	79a2                	ld	s3,40(sp)
    800022b6:	7a02                	ld	s4,32(sp)
    800022b8:	6ae2                	ld	s5,24(sp)
    800022ba:	6b42                	ld	s6,16(sp)
    800022bc:	6ba2                	ld	s7,8(sp)
    800022be:	6c02                	ld	s8,0(sp)
    800022c0:	6161                	addi	sp,sp,80
    800022c2:	8082                	ret
    panic("kalloc failed on swapFileCopy");
    800022c4:	00007517          	auipc	a0,0x7
    800022c8:	17450513          	addi	a0,a0,372 # 80009438 <digits+0x3f8>
    800022cc:	ffffe097          	auipc	ra,0xffffe
    800022d0:	25e080e7          	jalr	606(ra) # 8000052a <panic>
      panic("readFromSwapFile FAILD in fork\n");
    800022d4:	00007517          	auipc	a0,0x7
    800022d8:	18450513          	addi	a0,a0,388 # 80009458 <digits+0x418>
    800022dc:	ffffe097          	auipc	ra,0xffffe
    800022e0:	24e080e7          	jalr	590(ra) # 8000052a <panic>
      panic("writeToSwapFile FAILD in fork\n");
    800022e4:	00007517          	auipc	a0,0x7
    800022e8:	19450513          	addi	a0,a0,404 # 80009478 <digits+0x438>
    800022ec:	ffffe097          	auipc	ra,0xffffe
    800022f0:	23e080e7          	jalr	574(ra) # 8000052a <panic>

00000000800022f4 <fork>:
{
    800022f4:	7139                	addi	sp,sp,-64
    800022f6:	fc06                	sd	ra,56(sp)
    800022f8:	f822                	sd	s0,48(sp)
    800022fa:	f426                	sd	s1,40(sp)
    800022fc:	f04a                	sd	s2,32(sp)
    800022fe:	ec4e                	sd	s3,24(sp)
    80002300:	e852                	sd	s4,16(sp)
    80002302:	e456                	sd	s5,8(sp)
    80002304:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002306:	00000097          	auipc	ra,0x0
    8000230a:	aac080e7          	jalr	-1364(ra) # 80001db2 <myproc>
    8000230e:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80002310:	00000097          	auipc	ra,0x0
    80002314:	cd8080e7          	jalr	-808(ra) # 80001fe8 <allocproc>
    80002318:	1a050263          	beqz	a0,800024bc <fork+0x1c8>
    8000231c:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000231e:	048ab603          	ld	a2,72(s5)
    80002322:	692c                	ld	a1,80(a0)
    80002324:	050ab503          	ld	a0,80(s5)
    80002328:	fffff097          	auipc	ra,0xfffff
    8000232c:	612080e7          	jalr	1554(ra) # 8000193a <uvmcopy>
    80002330:	04054d63          	bltz	a0,8000238a <fork+0x96>
  np->sz = p->sz;
    80002334:	048ab783          	ld	a5,72(s5)
    80002338:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    8000233c:	058ab683          	ld	a3,88(s5)
    80002340:	87b6                	mv	a5,a3
    80002342:	0589b703          	ld	a4,88(s3)
    80002346:	12068693          	addi	a3,a3,288 # 1120 <_entry-0x7fffeee0>
    8000234a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    8000234e:	6788                	ld	a0,8(a5)
    80002350:	6b8c                	ld	a1,16(a5)
    80002352:	6f90                	ld	a2,24(a5)
    80002354:	01073023          	sd	a6,0(a4)
    80002358:	e708                	sd	a0,8(a4)
    8000235a:	eb0c                	sd	a1,16(a4)
    8000235c:	ef10                	sd	a2,24(a4)
    8000235e:	02078793          	addi	a5,a5,32
    80002362:	02070713          	addi	a4,a4,32
    80002366:	fed792e3          	bne	a5,a3,8000234a <fork+0x56>
    if(p->pid > 2){
    8000236a:	030aa703          	lw	a4,48(s5)
    8000236e:	4789                	li	a5,2
    80002370:	02e7c963          	blt	a5,a4,800023a2 <fork+0xae>
  np->trapframe->a0 = 0;
    80002374:	0589b783          	ld	a5,88(s3)
    80002378:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    8000237c:	0d0a8493          	addi	s1,s5,208
    80002380:	0d098913          	addi	s2,s3,208
    80002384:	150a8a13          	addi	s4,s5,336
    80002388:	a055                	j	8000242c <fork+0x138>
    freeproc(np);
    8000238a:	854e                	mv	a0,s3
    8000238c:	00000097          	auipc	ra,0x0
    80002390:	c04080e7          	jalr	-1020(ra) # 80001f90 <freeproc>
    release(&np->lock);
    80002394:	854e                	mv	a0,s3
    80002396:	fffff097          	auipc	ra,0xfffff
    8000239a:	8e0080e7          	jalr	-1824(ra) # 80000c76 <release>
    return -1;
    8000239e:	597d                	li	s2,-1
    800023a0:	a221                	j	800024a8 <fork+0x1b4>
      swapFileCopy(np, p);
    800023a2:	85d6                	mv	a1,s5
    800023a4:	854e                	mv	a0,s3
    800023a6:	00000097          	auipc	ra,0x0
    800023aa:	e7e080e7          	jalr	-386(ra) # 80002224 <swapFileCopy>
        np->nextPlaceInQueue = p->nextPlaceInQueue;
    800023ae:	174aa783          	lw	a5,372(s5)
    800023b2:	16f9aa23          	sw	a5,372(s3)
      np->swapOffset = p->swapOffset;
    800023b6:	170aa783          	lw	a5,368(s5)
    800023ba:	16f9a823          	sw	a5,368(s3)
      np->numOfPhyPages = p->numOfPhyPages;
    800023be:	178aa783          	lw	a5,376(s5)
    800023c2:	16f9ac23          	sw	a5,376(s3)
      np->numOfTotalPages = p->numOfTotalPages;
    800023c6:	17caa783          	lw	a5,380(s5)
    800023ca:	16f9ae23          	sw	a5,380(s3)
      np->numOfPageFault = 0;
    800023ce:	4809ac23          	sw	zero,1176(s3)
      for(int k = 0; k < MAX_PSYC_PAGES; k++){
    800023d2:	180a8793          	addi	a5,s5,384
    800023d6:	18098713          	addi	a4,s3,384
    800023da:	300a8613          	addi	a2,s5,768
        np->swapPagesArray[k].inUse = p->swapPagesArray[k].inUse;
    800023de:	47d4                	lw	a3,12(a5)
    800023e0:	c754                	sw	a3,12(a4)
        np->swapPagesArray[k].va = p->swapPagesArray[k].va; 
    800023e2:	6394                	ld	a3,0(a5)
    800023e4:	e314                	sd	a3,0(a4)
        np->physPagesArray[k].inUse = p->physPagesArray[k].inUse;
    800023e6:	1a47a683          	lw	a3,420(a5)
    800023ea:	1ad72223          	sw	a3,420(a4)
        np->physPagesArray[k].va = p->physPagesArray[k].va; 
    800023ee:	1987b683          	ld	a3,408(a5)
    800023f2:	18d73c23          	sd	a3,408(a4)
          np->swapPagesArray[k].placeInQueue = p->swapPagesArray[k].placeInQueue;
    800023f6:	4b94                	lw	a3,16(a5)
    800023f8:	cb14                	sw	a3,16(a4)
          np->physPagesArray[k].placeInQueue = p->physPagesArray[k].placeInQueue;
    800023fa:	1a87a683          	lw	a3,424(a5)
    800023fe:	1ad72423          	sw	a3,424(a4)
      for(int k = 0; k < MAX_PSYC_PAGES; k++){
    80002402:	07e1                	addi	a5,a5,24
    80002404:	0761                	addi	a4,a4,24
    80002406:	fcc79ce3          	bne	a5,a2,800023de <fork+0xea>
      np->swapPagesArray[16].inUse = p->swapPagesArray[16].inUse;
    8000240a:	30caa783          	lw	a5,780(s5)
    8000240e:	30f9a623          	sw	a5,780(s3)
      np->swapPagesArray[16].va = p->swapPagesArray[16].va; 
    80002412:	300ab783          	ld	a5,768(s5)
    80002416:	30f9b023          	sd	a5,768(s3)
        np->swapPagesArray[16].placeInQueue = p->swapPagesArray[16].placeInQueue;
    8000241a:	310aa783          	lw	a5,784(s5)
    8000241e:	30f9a823          	sw	a5,784(s3)
    80002422:	bf89                	j	80002374 <fork+0x80>
  for(i = 0; i < NOFILE; i++)
    80002424:	04a1                	addi	s1,s1,8
    80002426:	0921                	addi	s2,s2,8
    80002428:	01448b63          	beq	s1,s4,8000243e <fork+0x14a>
    if(p->ofile[i])
    8000242c:	6088                	ld	a0,0(s1)
    8000242e:	d97d                	beqz	a0,80002424 <fork+0x130>
      np->ofile[i] = filedup(p->ofile[i]);
    80002430:	00003097          	auipc	ra,0x3
    80002434:	baa080e7          	jalr	-1110(ra) # 80004fda <filedup>
    80002438:	00a93023          	sd	a0,0(s2)
    8000243c:	b7e5                	j	80002424 <fork+0x130>
  np->cwd = idup(p->cwd);
    8000243e:	150ab503          	ld	a0,336(s5)
    80002442:	00002097          	auipc	ra,0x2
    80002446:	9d2080e7          	jalr	-1582(ra) # 80003e14 <idup>
    8000244a:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000244e:	4641                	li	a2,16
    80002450:	158a8593          	addi	a1,s5,344
    80002454:	15898513          	addi	a0,s3,344
    80002458:	fffff097          	auipc	ra,0xfffff
    8000245c:	9b8080e7          	jalr	-1608(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    80002460:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80002464:	854e                	mv	a0,s3
    80002466:	fffff097          	auipc	ra,0xfffff
    8000246a:	810080e7          	jalr	-2032(ra) # 80000c76 <release>
  acquire(&wait_lock);
    8000246e:	00010497          	auipc	s1,0x10
    80002472:	e4a48493          	addi	s1,s1,-438 # 800122b8 <wait_lock>
    80002476:	8526                	mv	a0,s1
    80002478:	ffffe097          	auipc	ra,0xffffe
    8000247c:	74a080e7          	jalr	1866(ra) # 80000bc2 <acquire>
  np->parent = p;
    80002480:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80002484:	8526                	mv	a0,s1
    80002486:	ffffe097          	auipc	ra,0xffffe
    8000248a:	7f0080e7          	jalr	2032(ra) # 80000c76 <release>
  acquire(&np->lock);
    8000248e:	854e                	mv	a0,s3
    80002490:	ffffe097          	auipc	ra,0xffffe
    80002494:	732080e7          	jalr	1842(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    80002498:	478d                	li	a5,3
    8000249a:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    8000249e:	854e                	mv	a0,s3
    800024a0:	ffffe097          	auipc	ra,0xffffe
    800024a4:	7d6080e7          	jalr	2006(ra) # 80000c76 <release>
}
    800024a8:	854a                	mv	a0,s2
    800024aa:	70e2                	ld	ra,56(sp)
    800024ac:	7442                	ld	s0,48(sp)
    800024ae:	74a2                	ld	s1,40(sp)
    800024b0:	7902                	ld	s2,32(sp)
    800024b2:	69e2                	ld	s3,24(sp)
    800024b4:	6a42                	ld	s4,16(sp)
    800024b6:	6aa2                	ld	s5,8(sp)
    800024b8:	6121                	addi	sp,sp,64
    800024ba:	8082                	ret
    return -1;
    800024bc:	597d                	li	s2,-1
    800024be:	b7ed                	j	800024a8 <fork+0x1b4>

00000000800024c0 <scheduler>:
{
    800024c0:	7139                	addi	sp,sp,-64
    800024c2:	fc06                	sd	ra,56(sp)
    800024c4:	f822                	sd	s0,48(sp)
    800024c6:	f426                	sd	s1,40(sp)
    800024c8:	f04a                	sd	s2,32(sp)
    800024ca:	ec4e                	sd	s3,24(sp)
    800024cc:	e852                	sd	s4,16(sp)
    800024ce:	e456                	sd	s5,8(sp)
    800024d0:	e05a                	sd	s6,0(sp)
    800024d2:	0080                	addi	s0,sp,64
    800024d4:	8792                	mv	a5,tp
  int id = r_tp();
    800024d6:	2781                	sext.w	a5,a5
  c->proc = 0;
    800024d8:	00779a93          	slli	s5,a5,0x7
    800024dc:	00010717          	auipc	a4,0x10
    800024e0:	dc470713          	addi	a4,a4,-572 # 800122a0 <pid_lock>
    800024e4:	9756                	add	a4,a4,s5
    800024e6:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800024ea:	00010717          	auipc	a4,0x10
    800024ee:	dee70713          	addi	a4,a4,-530 # 800122d8 <cpus+0x8>
    800024f2:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    800024f4:	498d                	li	s3,3
        p->state = RUNNING;
    800024f6:	4b11                	li	s6,4
        c->proc = p;
    800024f8:	079e                	slli	a5,a5,0x7
    800024fa:	00010a17          	auipc	s4,0x10
    800024fe:	da6a0a13          	addi	s4,s4,-602 # 800122a0 <pid_lock>
    80002502:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002504:	00023917          	auipc	s2,0x23
    80002508:	9cc90913          	addi	s2,s2,-1588 # 80024ed0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000250c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002510:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002514:	10079073          	csrw	sstatus,a5
    80002518:	00010497          	auipc	s1,0x10
    8000251c:	1b848493          	addi	s1,s1,440 # 800126d0 <proc>
    80002520:	a811                	j	80002534 <scheduler+0x74>
      release(&p->lock);
    80002522:	8526                	mv	a0,s1
    80002524:	ffffe097          	auipc	ra,0xffffe
    80002528:	752080e7          	jalr	1874(ra) # 80000c76 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000252c:	4a048493          	addi	s1,s1,1184
    80002530:	fd248ee3          	beq	s1,s2,8000250c <scheduler+0x4c>
      acquire(&p->lock);
    80002534:	8526                	mv	a0,s1
    80002536:	ffffe097          	auipc	ra,0xffffe
    8000253a:	68c080e7          	jalr	1676(ra) # 80000bc2 <acquire>
      if(p->state == RUNNABLE) {
    8000253e:	4c9c                	lw	a5,24(s1)
    80002540:	ff3791e3          	bne	a5,s3,80002522 <scheduler+0x62>
        p->state = RUNNING;
    80002544:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80002548:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    8000254c:	06048593          	addi	a1,s1,96
    80002550:	8556                	mv	a0,s5
    80002552:	00000097          	auipc	ra,0x0
    80002556:	7ee080e7          	jalr	2030(ra) # 80002d40 <swtch>
        c->proc = 0;
    8000255a:	020a3823          	sd	zero,48(s4)
    8000255e:	b7d1                	j	80002522 <scheduler+0x62>

0000000080002560 <sched>:
{
    80002560:	7179                	addi	sp,sp,-48
    80002562:	f406                	sd	ra,40(sp)
    80002564:	f022                	sd	s0,32(sp)
    80002566:	ec26                	sd	s1,24(sp)
    80002568:	e84a                	sd	s2,16(sp)
    8000256a:	e44e                	sd	s3,8(sp)
    8000256c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000256e:	00000097          	auipc	ra,0x0
    80002572:	844080e7          	jalr	-1980(ra) # 80001db2 <myproc>
    80002576:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002578:	ffffe097          	auipc	ra,0xffffe
    8000257c:	5d0080e7          	jalr	1488(ra) # 80000b48 <holding>
    80002580:	c93d                	beqz	a0,800025f6 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002582:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002584:	2781                	sext.w	a5,a5
    80002586:	079e                	slli	a5,a5,0x7
    80002588:	00010717          	auipc	a4,0x10
    8000258c:	d1870713          	addi	a4,a4,-744 # 800122a0 <pid_lock>
    80002590:	97ba                	add	a5,a5,a4
    80002592:	0a87a703          	lw	a4,168(a5)
    80002596:	4785                	li	a5,1
    80002598:	06f71763          	bne	a4,a5,80002606 <sched+0xa6>
  if(p->state == RUNNING)
    8000259c:	4c98                	lw	a4,24(s1)
    8000259e:	4791                	li	a5,4
    800025a0:	06f70b63          	beq	a4,a5,80002616 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025a4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800025a8:	8b89                	andi	a5,a5,2
  if(intr_get())
    800025aa:	efb5                	bnez	a5,80002626 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800025ac:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800025ae:	00010917          	auipc	s2,0x10
    800025b2:	cf290913          	addi	s2,s2,-782 # 800122a0 <pid_lock>
    800025b6:	2781                	sext.w	a5,a5
    800025b8:	079e                	slli	a5,a5,0x7
    800025ba:	97ca                	add	a5,a5,s2
    800025bc:	0ac7a983          	lw	s3,172(a5)
    800025c0:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800025c2:	2781                	sext.w	a5,a5
    800025c4:	079e                	slli	a5,a5,0x7
    800025c6:	00010597          	auipc	a1,0x10
    800025ca:	d1258593          	addi	a1,a1,-750 # 800122d8 <cpus+0x8>
    800025ce:	95be                	add	a1,a1,a5
    800025d0:	06048513          	addi	a0,s1,96
    800025d4:	00000097          	auipc	ra,0x0
    800025d8:	76c080e7          	jalr	1900(ra) # 80002d40 <swtch>
    800025dc:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800025de:	2781                	sext.w	a5,a5
    800025e0:	079e                	slli	a5,a5,0x7
    800025e2:	97ca                	add	a5,a5,s2
    800025e4:	0b37a623          	sw	s3,172(a5)
}
    800025e8:	70a2                	ld	ra,40(sp)
    800025ea:	7402                	ld	s0,32(sp)
    800025ec:	64e2                	ld	s1,24(sp)
    800025ee:	6942                	ld	s2,16(sp)
    800025f0:	69a2                	ld	s3,8(sp)
    800025f2:	6145                	addi	sp,sp,48
    800025f4:	8082                	ret
    panic("sched p->lock");
    800025f6:	00007517          	auipc	a0,0x7
    800025fa:	ea250513          	addi	a0,a0,-350 # 80009498 <digits+0x458>
    800025fe:	ffffe097          	auipc	ra,0xffffe
    80002602:	f2c080e7          	jalr	-212(ra) # 8000052a <panic>
    panic("sched locks");
    80002606:	00007517          	auipc	a0,0x7
    8000260a:	ea250513          	addi	a0,a0,-350 # 800094a8 <digits+0x468>
    8000260e:	ffffe097          	auipc	ra,0xffffe
    80002612:	f1c080e7          	jalr	-228(ra) # 8000052a <panic>
    panic("sched running");
    80002616:	00007517          	auipc	a0,0x7
    8000261a:	ea250513          	addi	a0,a0,-350 # 800094b8 <digits+0x478>
    8000261e:	ffffe097          	auipc	ra,0xffffe
    80002622:	f0c080e7          	jalr	-244(ra) # 8000052a <panic>
    panic("sched interruptible");
    80002626:	00007517          	auipc	a0,0x7
    8000262a:	ea250513          	addi	a0,a0,-350 # 800094c8 <digits+0x488>
    8000262e:	ffffe097          	auipc	ra,0xffffe
    80002632:	efc080e7          	jalr	-260(ra) # 8000052a <panic>

0000000080002636 <yield>:
{
    80002636:	1101                	addi	sp,sp,-32
    80002638:	ec06                	sd	ra,24(sp)
    8000263a:	e822                	sd	s0,16(sp)
    8000263c:	e426                	sd	s1,8(sp)
    8000263e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002640:	fffff097          	auipc	ra,0xfffff
    80002644:	772080e7          	jalr	1906(ra) # 80001db2 <myproc>
    80002648:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000264a:	ffffe097          	auipc	ra,0xffffe
    8000264e:	578080e7          	jalr	1400(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    80002652:	478d                	li	a5,3
    80002654:	cc9c                	sw	a5,24(s1)
  sched();
    80002656:	00000097          	auipc	ra,0x0
    8000265a:	f0a080e7          	jalr	-246(ra) # 80002560 <sched>
  release(&p->lock);
    8000265e:	8526                	mv	a0,s1
    80002660:	ffffe097          	auipc	ra,0xffffe
    80002664:	616080e7          	jalr	1558(ra) # 80000c76 <release>
}
    80002668:	60e2                	ld	ra,24(sp)
    8000266a:	6442                	ld	s0,16(sp)
    8000266c:	64a2                	ld	s1,8(sp)
    8000266e:	6105                	addi	sp,sp,32
    80002670:	8082                	ret

0000000080002672 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002672:	7179                	addi	sp,sp,-48
    80002674:	f406                	sd	ra,40(sp)
    80002676:	f022                	sd	s0,32(sp)
    80002678:	ec26                	sd	s1,24(sp)
    8000267a:	e84a                	sd	s2,16(sp)
    8000267c:	e44e                	sd	s3,8(sp)
    8000267e:	1800                	addi	s0,sp,48
    80002680:	89aa                	mv	s3,a0
    80002682:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002684:	fffff097          	auipc	ra,0xfffff
    80002688:	72e080e7          	jalr	1838(ra) # 80001db2 <myproc>
    8000268c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000268e:	ffffe097          	auipc	ra,0xffffe
    80002692:	534080e7          	jalr	1332(ra) # 80000bc2 <acquire>
  release(lk);
    80002696:	854a                	mv	a0,s2
    80002698:	ffffe097          	auipc	ra,0xffffe
    8000269c:	5de080e7          	jalr	1502(ra) # 80000c76 <release>

  // Go to sleep.
  p->chan = chan;
    800026a0:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800026a4:	4789                	li	a5,2
    800026a6:	cc9c                	sw	a5,24(s1)

  sched();
    800026a8:	00000097          	auipc	ra,0x0
    800026ac:	eb8080e7          	jalr	-328(ra) # 80002560 <sched>

  // Tidy up.
  p->chan = 0;
    800026b0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800026b4:	8526                	mv	a0,s1
    800026b6:	ffffe097          	auipc	ra,0xffffe
    800026ba:	5c0080e7          	jalr	1472(ra) # 80000c76 <release>
  acquire(lk);
    800026be:	854a                	mv	a0,s2
    800026c0:	ffffe097          	auipc	ra,0xffffe
    800026c4:	502080e7          	jalr	1282(ra) # 80000bc2 <acquire>
}
    800026c8:	70a2                	ld	ra,40(sp)
    800026ca:	7402                	ld	s0,32(sp)
    800026cc:	64e2                	ld	s1,24(sp)
    800026ce:	6942                	ld	s2,16(sp)
    800026d0:	69a2                	ld	s3,8(sp)
    800026d2:	6145                	addi	sp,sp,48
    800026d4:	8082                	ret

00000000800026d6 <wait>:
{
    800026d6:	715d                	addi	sp,sp,-80
    800026d8:	e486                	sd	ra,72(sp)
    800026da:	e0a2                	sd	s0,64(sp)
    800026dc:	fc26                	sd	s1,56(sp)
    800026de:	f84a                	sd	s2,48(sp)
    800026e0:	f44e                	sd	s3,40(sp)
    800026e2:	f052                	sd	s4,32(sp)
    800026e4:	ec56                	sd	s5,24(sp)
    800026e6:	e85a                	sd	s6,16(sp)
    800026e8:	e45e                	sd	s7,8(sp)
    800026ea:	e062                	sd	s8,0(sp)
    800026ec:	0880                	addi	s0,sp,80
    800026ee:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800026f0:	fffff097          	auipc	ra,0xfffff
    800026f4:	6c2080e7          	jalr	1730(ra) # 80001db2 <myproc>
    800026f8:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800026fa:	00010517          	auipc	a0,0x10
    800026fe:	bbe50513          	addi	a0,a0,-1090 # 800122b8 <wait_lock>
    80002702:	ffffe097          	auipc	ra,0xffffe
    80002706:	4c0080e7          	jalr	1216(ra) # 80000bc2 <acquire>
    havekids = 0;
    8000270a:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    8000270c:	4a15                	li	s4,5
        havekids = 1;
    8000270e:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002710:	00022997          	auipc	s3,0x22
    80002714:	7c098993          	addi	s3,s3,1984 # 80024ed0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002718:	00010c17          	auipc	s8,0x10
    8000271c:	ba0c0c13          	addi	s8,s8,-1120 # 800122b8 <wait_lock>
    havekids = 0;
    80002720:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002722:	00010497          	auipc	s1,0x10
    80002726:	fae48493          	addi	s1,s1,-82 # 800126d0 <proc>
    8000272a:	a0bd                	j	80002798 <wait+0xc2>
          pid = np->pid;
    8000272c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002730:	000b0e63          	beqz	s6,8000274c <wait+0x76>
    80002734:	4691                	li	a3,4
    80002736:	02c48613          	addi	a2,s1,44
    8000273a:	85da                	mv	a1,s6
    8000273c:	05093503          	ld	a0,80(s2)
    80002740:	fffff097          	auipc	ra,0xfffff
    80002744:	332080e7          	jalr	818(ra) # 80001a72 <copyout>
    80002748:	02054563          	bltz	a0,80002772 <wait+0x9c>
          freeproc(np);
    8000274c:	8526                	mv	a0,s1
    8000274e:	00000097          	auipc	ra,0x0
    80002752:	842080e7          	jalr	-1982(ra) # 80001f90 <freeproc>
          release(&np->lock);
    80002756:	8526                	mv	a0,s1
    80002758:	ffffe097          	auipc	ra,0xffffe
    8000275c:	51e080e7          	jalr	1310(ra) # 80000c76 <release>
          release(&wait_lock);
    80002760:	00010517          	auipc	a0,0x10
    80002764:	b5850513          	addi	a0,a0,-1192 # 800122b8 <wait_lock>
    80002768:	ffffe097          	auipc	ra,0xffffe
    8000276c:	50e080e7          	jalr	1294(ra) # 80000c76 <release>
          return pid;
    80002770:	a09d                	j	800027d6 <wait+0x100>
            release(&np->lock);
    80002772:	8526                	mv	a0,s1
    80002774:	ffffe097          	auipc	ra,0xffffe
    80002778:	502080e7          	jalr	1282(ra) # 80000c76 <release>
            release(&wait_lock);
    8000277c:	00010517          	auipc	a0,0x10
    80002780:	b3c50513          	addi	a0,a0,-1220 # 800122b8 <wait_lock>
    80002784:	ffffe097          	auipc	ra,0xffffe
    80002788:	4f2080e7          	jalr	1266(ra) # 80000c76 <release>
            return -1;
    8000278c:	59fd                	li	s3,-1
    8000278e:	a0a1                	j	800027d6 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    80002790:	4a048493          	addi	s1,s1,1184
    80002794:	03348463          	beq	s1,s3,800027bc <wait+0xe6>
      if(np->parent == p){
    80002798:	7c9c                	ld	a5,56(s1)
    8000279a:	ff279be3          	bne	a5,s2,80002790 <wait+0xba>
        acquire(&np->lock);
    8000279e:	8526                	mv	a0,s1
    800027a0:	ffffe097          	auipc	ra,0xffffe
    800027a4:	422080e7          	jalr	1058(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    800027a8:	4c9c                	lw	a5,24(s1)
    800027aa:	f94781e3          	beq	a5,s4,8000272c <wait+0x56>
        release(&np->lock);
    800027ae:	8526                	mv	a0,s1
    800027b0:	ffffe097          	auipc	ra,0xffffe
    800027b4:	4c6080e7          	jalr	1222(ra) # 80000c76 <release>
        havekids = 1;
    800027b8:	8756                	mv	a4,s5
    800027ba:	bfd9                	j	80002790 <wait+0xba>
    if(!havekids || p->killed){
    800027bc:	c701                	beqz	a4,800027c4 <wait+0xee>
    800027be:	02892783          	lw	a5,40(s2)
    800027c2:	c79d                	beqz	a5,800027f0 <wait+0x11a>
      release(&wait_lock);
    800027c4:	00010517          	auipc	a0,0x10
    800027c8:	af450513          	addi	a0,a0,-1292 # 800122b8 <wait_lock>
    800027cc:	ffffe097          	auipc	ra,0xffffe
    800027d0:	4aa080e7          	jalr	1194(ra) # 80000c76 <release>
      return -1;
    800027d4:	59fd                	li	s3,-1
}
    800027d6:	854e                	mv	a0,s3
    800027d8:	60a6                	ld	ra,72(sp)
    800027da:	6406                	ld	s0,64(sp)
    800027dc:	74e2                	ld	s1,56(sp)
    800027de:	7942                	ld	s2,48(sp)
    800027e0:	79a2                	ld	s3,40(sp)
    800027e2:	7a02                	ld	s4,32(sp)
    800027e4:	6ae2                	ld	s5,24(sp)
    800027e6:	6b42                	ld	s6,16(sp)
    800027e8:	6ba2                	ld	s7,8(sp)
    800027ea:	6c02                	ld	s8,0(sp)
    800027ec:	6161                	addi	sp,sp,80
    800027ee:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800027f0:	85e2                	mv	a1,s8
    800027f2:	854a                	mv	a0,s2
    800027f4:	00000097          	auipc	ra,0x0
    800027f8:	e7e080e7          	jalr	-386(ra) # 80002672 <sleep>
    havekids = 0;
    800027fc:	b715                	j	80002720 <wait+0x4a>

00000000800027fe <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800027fe:	7139                	addi	sp,sp,-64
    80002800:	fc06                	sd	ra,56(sp)
    80002802:	f822                	sd	s0,48(sp)
    80002804:	f426                	sd	s1,40(sp)
    80002806:	f04a                	sd	s2,32(sp)
    80002808:	ec4e                	sd	s3,24(sp)
    8000280a:	e852                	sd	s4,16(sp)
    8000280c:	e456                	sd	s5,8(sp)
    8000280e:	0080                	addi	s0,sp,64
    80002810:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002812:	00010497          	auipc	s1,0x10
    80002816:	ebe48493          	addi	s1,s1,-322 # 800126d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000281a:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000281c:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000281e:	00022917          	auipc	s2,0x22
    80002822:	6b290913          	addi	s2,s2,1714 # 80024ed0 <tickslock>
    80002826:	a811                	j	8000283a <wakeup+0x3c>
      }
      release(&p->lock);
    80002828:	8526                	mv	a0,s1
    8000282a:	ffffe097          	auipc	ra,0xffffe
    8000282e:	44c080e7          	jalr	1100(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002832:	4a048493          	addi	s1,s1,1184
    80002836:	03248663          	beq	s1,s2,80002862 <wakeup+0x64>
    if(p != myproc()){
    8000283a:	fffff097          	auipc	ra,0xfffff
    8000283e:	578080e7          	jalr	1400(ra) # 80001db2 <myproc>
    80002842:	fea488e3          	beq	s1,a0,80002832 <wakeup+0x34>
      acquire(&p->lock);
    80002846:	8526                	mv	a0,s1
    80002848:	ffffe097          	auipc	ra,0xffffe
    8000284c:	37a080e7          	jalr	890(ra) # 80000bc2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002850:	4c9c                	lw	a5,24(s1)
    80002852:	fd379be3          	bne	a5,s3,80002828 <wakeup+0x2a>
    80002856:	709c                	ld	a5,32(s1)
    80002858:	fd4798e3          	bne	a5,s4,80002828 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000285c:	0154ac23          	sw	s5,24(s1)
    80002860:	b7e1                	j	80002828 <wakeup+0x2a>
    }
  }
}
    80002862:	70e2                	ld	ra,56(sp)
    80002864:	7442                	ld	s0,48(sp)
    80002866:	74a2                	ld	s1,40(sp)
    80002868:	7902                	ld	s2,32(sp)
    8000286a:	69e2                	ld	s3,24(sp)
    8000286c:	6a42                	ld	s4,16(sp)
    8000286e:	6aa2                	ld	s5,8(sp)
    80002870:	6121                	addi	sp,sp,64
    80002872:	8082                	ret

0000000080002874 <reparent>:
{
    80002874:	7179                	addi	sp,sp,-48
    80002876:	f406                	sd	ra,40(sp)
    80002878:	f022                	sd	s0,32(sp)
    8000287a:	ec26                	sd	s1,24(sp)
    8000287c:	e84a                	sd	s2,16(sp)
    8000287e:	e44e                	sd	s3,8(sp)
    80002880:	e052                	sd	s4,0(sp)
    80002882:	1800                	addi	s0,sp,48
    80002884:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002886:	00010497          	auipc	s1,0x10
    8000288a:	e4a48493          	addi	s1,s1,-438 # 800126d0 <proc>
      pp->parent = initproc;
    8000288e:	00007a17          	auipc	s4,0x7
    80002892:	79aa0a13          	addi	s4,s4,1946 # 8000a028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002896:	00022997          	auipc	s3,0x22
    8000289a:	63a98993          	addi	s3,s3,1594 # 80024ed0 <tickslock>
    8000289e:	a029                	j	800028a8 <reparent+0x34>
    800028a0:	4a048493          	addi	s1,s1,1184
    800028a4:	01348d63          	beq	s1,s3,800028be <reparent+0x4a>
    if(pp->parent == p){
    800028a8:	7c9c                	ld	a5,56(s1)
    800028aa:	ff279be3          	bne	a5,s2,800028a0 <reparent+0x2c>
      pp->parent = initproc;
    800028ae:	000a3503          	ld	a0,0(s4)
    800028b2:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800028b4:	00000097          	auipc	ra,0x0
    800028b8:	f4a080e7          	jalr	-182(ra) # 800027fe <wakeup>
    800028bc:	b7d5                	j	800028a0 <reparent+0x2c>
}
    800028be:	70a2                	ld	ra,40(sp)
    800028c0:	7402                	ld	s0,32(sp)
    800028c2:	64e2                	ld	s1,24(sp)
    800028c4:	6942                	ld	s2,16(sp)
    800028c6:	69a2                	ld	s3,8(sp)
    800028c8:	6a02                	ld	s4,0(sp)
    800028ca:	6145                	addi	sp,sp,48
    800028cc:	8082                	ret

00000000800028ce <exit>:
{
    800028ce:	7179                	addi	sp,sp,-48
    800028d0:	f406                	sd	ra,40(sp)
    800028d2:	f022                	sd	s0,32(sp)
    800028d4:	ec26                	sd	s1,24(sp)
    800028d6:	e84a                	sd	s2,16(sp)
    800028d8:	e44e                	sd	s3,8(sp)
    800028da:	e052                	sd	s4,0(sp)
    800028dc:	1800                	addi	s0,sp,48
    800028de:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800028e0:	fffff097          	auipc	ra,0xfffff
    800028e4:	4d2080e7          	jalr	1234(ra) # 80001db2 <myproc>
    800028e8:	892a                	mv	s2,a0
  if(p == initproc)
    800028ea:	00007797          	auipc	a5,0x7
    800028ee:	73e7b783          	ld	a5,1854(a5) # 8000a028 <initproc>
    800028f2:	0d050493          	addi	s1,a0,208
    800028f6:	15050993          	addi	s3,a0,336
    800028fa:	00a79d63          	bne	a5,a0,80002914 <exit+0x46>
    panic("init exiting");
    800028fe:	00007517          	auipc	a0,0x7
    80002902:	be250513          	addi	a0,a0,-1054 # 800094e0 <digits+0x4a0>
    80002906:	ffffe097          	auipc	ra,0xffffe
    8000290a:	c24080e7          	jalr	-988(ra) # 8000052a <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    8000290e:	04a1                	addi	s1,s1,8
    80002910:	01348b63          	beq	s1,s3,80002926 <exit+0x58>
    if(p->ofile[fd]){
    80002914:	6088                	ld	a0,0(s1)
    80002916:	dd65                	beqz	a0,8000290e <exit+0x40>
      fileclose(f);
    80002918:	00002097          	auipc	ra,0x2
    8000291c:	714080e7          	jalr	1812(ra) # 8000502c <fileclose>
      p->ofile[fd] = 0;
    80002920:	0004b023          	sd	zero,0(s1)
    80002924:	b7ed                	j	8000290e <exit+0x40>
    if (p->pid > 2){
    80002926:	03092703          	lw	a4,48(s2)
    8000292a:	4789                	li	a5,2
    8000292c:	0ae7c863          	blt	a5,a4,800029dc <exit+0x10e>
    p->numOfPhyPages = 0;
    80002930:	16092c23          	sw	zero,376(s2)
    p->numOfTotalPages = 0;
    80002934:	16092e23          	sw	zero,380(s2)
    p->numOfPageFault = 0;
    80002938:	48092c23          	sw	zero,1176(s2)
    p->swapOffset = 0;
    8000293c:	16092823          	sw	zero,368(s2)
      p->nextPlaceInQueue = 0;
    80002940:	16092a23          	sw	zero,372(s2)
    for(int i = 0; i < MAX_PSYC_PAGES; i++){
    80002944:	18c90793          	addi	a5,s2,396
    80002948:	30c90713          	addi	a4,s2,780
      p->swapPagesArray[i].inUse = 0;
    8000294c:	0007a023          	sw	zero,0(a5)
      p->physPagesArray[i].inUse = 0;
    80002950:	1807ac23          	sw	zero,408(a5)
    for(int i = 0; i < MAX_PSYC_PAGES; i++){
    80002954:	07e1                	addi	a5,a5,24
    80002956:	fee79be3          	bne	a5,a4,8000294c <exit+0x7e>
    p->swapPagesArray[16].inUse = 0; 
    8000295a:	30092623          	sw	zero,780(s2)
  begin_op();
    8000295e:	00002097          	auipc	ra,0x2
    80002962:	202080e7          	jalr	514(ra) # 80004b60 <begin_op>
  iput(p->cwd);
    80002966:	15093503          	ld	a0,336(s2)
    8000296a:	00001097          	auipc	ra,0x1
    8000296e:	6a2080e7          	jalr	1698(ra) # 8000400c <iput>
  end_op();
    80002972:	00002097          	auipc	ra,0x2
    80002976:	26e080e7          	jalr	622(ra) # 80004be0 <end_op>
  p->cwd = 0;
    8000297a:	14093823          	sd	zero,336(s2)
  acquire(&wait_lock);
    8000297e:	00010497          	auipc	s1,0x10
    80002982:	93a48493          	addi	s1,s1,-1734 # 800122b8 <wait_lock>
    80002986:	8526                	mv	a0,s1
    80002988:	ffffe097          	auipc	ra,0xffffe
    8000298c:	23a080e7          	jalr	570(ra) # 80000bc2 <acquire>
  reparent(p);
    80002990:	854a                	mv	a0,s2
    80002992:	00000097          	auipc	ra,0x0
    80002996:	ee2080e7          	jalr	-286(ra) # 80002874 <reparent>
  wakeup(p->parent);
    8000299a:	03893503          	ld	a0,56(s2)
    8000299e:	00000097          	auipc	ra,0x0
    800029a2:	e60080e7          	jalr	-416(ra) # 800027fe <wakeup>
  acquire(&p->lock);
    800029a6:	854a                	mv	a0,s2
    800029a8:	ffffe097          	auipc	ra,0xffffe
    800029ac:	21a080e7          	jalr	538(ra) # 80000bc2 <acquire>
  p->xstate = status;
    800029b0:	03492623          	sw	s4,44(s2)
  p->state = ZOMBIE;
    800029b4:	4795                	li	a5,5
    800029b6:	00f92c23          	sw	a5,24(s2)
  release(&wait_lock);
    800029ba:	8526                	mv	a0,s1
    800029bc:	ffffe097          	auipc	ra,0xffffe
    800029c0:	2ba080e7          	jalr	698(ra) # 80000c76 <release>
  sched();
    800029c4:	00000097          	auipc	ra,0x0
    800029c8:	b9c080e7          	jalr	-1124(ra) # 80002560 <sched>
  panic("zombie exit");
    800029cc:	00007517          	auipc	a0,0x7
    800029d0:	b2450513          	addi	a0,a0,-1244 # 800094f0 <digits+0x4b0>
    800029d4:	ffffe097          	auipc	ra,0xffffe
    800029d8:	b56080e7          	jalr	-1194(ra) # 8000052a <panic>
      removeSwapFile(p);
    800029dc:	854a                	mv	a0,s2
    800029de:	00002097          	auipc	ra,0x2
    800029e2:	cd6080e7          	jalr	-810(ra) # 800046b4 <removeSwapFile>
    800029e6:	b7a9                	j	80002930 <exit+0x62>

00000000800029e8 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800029e8:	7179                	addi	sp,sp,-48
    800029ea:	f406                	sd	ra,40(sp)
    800029ec:	f022                	sd	s0,32(sp)
    800029ee:	ec26                	sd	s1,24(sp)
    800029f0:	e84a                	sd	s2,16(sp)
    800029f2:	e44e                	sd	s3,8(sp)
    800029f4:	1800                	addi	s0,sp,48
    800029f6:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800029f8:	00010497          	auipc	s1,0x10
    800029fc:	cd848493          	addi	s1,s1,-808 # 800126d0 <proc>
    80002a00:	00022997          	auipc	s3,0x22
    80002a04:	4d098993          	addi	s3,s3,1232 # 80024ed0 <tickslock>
    acquire(&p->lock);
    80002a08:	8526                	mv	a0,s1
    80002a0a:	ffffe097          	auipc	ra,0xffffe
    80002a0e:	1b8080e7          	jalr	440(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    80002a12:	589c                	lw	a5,48(s1)
    80002a14:	01278d63          	beq	a5,s2,80002a2e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002a18:	8526                	mv	a0,s1
    80002a1a:	ffffe097          	auipc	ra,0xffffe
    80002a1e:	25c080e7          	jalr	604(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002a22:	4a048493          	addi	s1,s1,1184
    80002a26:	ff3491e3          	bne	s1,s3,80002a08 <kill+0x20>
  }
  return -1;
    80002a2a:	557d                	li	a0,-1
    80002a2c:	a829                	j	80002a46 <kill+0x5e>
      p->killed = 1;
    80002a2e:	4785                	li	a5,1
    80002a30:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002a32:	4c98                	lw	a4,24(s1)
    80002a34:	4789                	li	a5,2
    80002a36:	00f70f63          	beq	a4,a5,80002a54 <kill+0x6c>
      release(&p->lock);
    80002a3a:	8526                	mv	a0,s1
    80002a3c:	ffffe097          	auipc	ra,0xffffe
    80002a40:	23a080e7          	jalr	570(ra) # 80000c76 <release>
      return 0;
    80002a44:	4501                	li	a0,0
}
    80002a46:	70a2                	ld	ra,40(sp)
    80002a48:	7402                	ld	s0,32(sp)
    80002a4a:	64e2                	ld	s1,24(sp)
    80002a4c:	6942                	ld	s2,16(sp)
    80002a4e:	69a2                	ld	s3,8(sp)
    80002a50:	6145                	addi	sp,sp,48
    80002a52:	8082                	ret
        p->state = RUNNABLE;
    80002a54:	478d                	li	a5,3
    80002a56:	cc9c                	sw	a5,24(s1)
    80002a58:	b7cd                	j	80002a3a <kill+0x52>

0000000080002a5a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002a5a:	7179                	addi	sp,sp,-48
    80002a5c:	f406                	sd	ra,40(sp)
    80002a5e:	f022                	sd	s0,32(sp)
    80002a60:	ec26                	sd	s1,24(sp)
    80002a62:	e84a                	sd	s2,16(sp)
    80002a64:	e44e                	sd	s3,8(sp)
    80002a66:	e052                	sd	s4,0(sp)
    80002a68:	1800                	addi	s0,sp,48
    80002a6a:	84aa                	mv	s1,a0
    80002a6c:	892e                	mv	s2,a1
    80002a6e:	89b2                	mv	s3,a2
    80002a70:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002a72:	fffff097          	auipc	ra,0xfffff
    80002a76:	340080e7          	jalr	832(ra) # 80001db2 <myproc>
  if(user_dst){
    80002a7a:	c08d                	beqz	s1,80002a9c <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002a7c:	86d2                	mv	a3,s4
    80002a7e:	864e                	mv	a2,s3
    80002a80:	85ca                	mv	a1,s2
    80002a82:	6928                	ld	a0,80(a0)
    80002a84:	fffff097          	auipc	ra,0xfffff
    80002a88:	fee080e7          	jalr	-18(ra) # 80001a72 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002a8c:	70a2                	ld	ra,40(sp)
    80002a8e:	7402                	ld	s0,32(sp)
    80002a90:	64e2                	ld	s1,24(sp)
    80002a92:	6942                	ld	s2,16(sp)
    80002a94:	69a2                	ld	s3,8(sp)
    80002a96:	6a02                	ld	s4,0(sp)
    80002a98:	6145                	addi	sp,sp,48
    80002a9a:	8082                	ret
    memmove((char *)dst, src, len);
    80002a9c:	000a061b          	sext.w	a2,s4
    80002aa0:	85ce                	mv	a1,s3
    80002aa2:	854a                	mv	a0,s2
    80002aa4:	ffffe097          	auipc	ra,0xffffe
    80002aa8:	276080e7          	jalr	630(ra) # 80000d1a <memmove>
    return 0;
    80002aac:	8526                	mv	a0,s1
    80002aae:	bff9                	j	80002a8c <either_copyout+0x32>

0000000080002ab0 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002ab0:	7179                	addi	sp,sp,-48
    80002ab2:	f406                	sd	ra,40(sp)
    80002ab4:	f022                	sd	s0,32(sp)
    80002ab6:	ec26                	sd	s1,24(sp)
    80002ab8:	e84a                	sd	s2,16(sp)
    80002aba:	e44e                	sd	s3,8(sp)
    80002abc:	e052                	sd	s4,0(sp)
    80002abe:	1800                	addi	s0,sp,48
    80002ac0:	892a                	mv	s2,a0
    80002ac2:	84ae                	mv	s1,a1
    80002ac4:	89b2                	mv	s3,a2
    80002ac6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002ac8:	fffff097          	auipc	ra,0xfffff
    80002acc:	2ea080e7          	jalr	746(ra) # 80001db2 <myproc>
  if(user_src){
    80002ad0:	c08d                	beqz	s1,80002af2 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002ad2:	86d2                	mv	a3,s4
    80002ad4:	864e                	mv	a2,s3
    80002ad6:	85ca                	mv	a1,s2
    80002ad8:	6928                	ld	a0,80(a0)
    80002ada:	fffff097          	auipc	ra,0xfffff
    80002ade:	024080e7          	jalr	36(ra) # 80001afe <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002ae2:	70a2                	ld	ra,40(sp)
    80002ae4:	7402                	ld	s0,32(sp)
    80002ae6:	64e2                	ld	s1,24(sp)
    80002ae8:	6942                	ld	s2,16(sp)
    80002aea:	69a2                	ld	s3,8(sp)
    80002aec:	6a02                	ld	s4,0(sp)
    80002aee:	6145                	addi	sp,sp,48
    80002af0:	8082                	ret
    memmove(dst, (char*)src, len);
    80002af2:	000a061b          	sext.w	a2,s4
    80002af6:	85ce                	mv	a1,s3
    80002af8:	854a                	mv	a0,s2
    80002afa:	ffffe097          	auipc	ra,0xffffe
    80002afe:	220080e7          	jalr	544(ra) # 80000d1a <memmove>
    return 0;
    80002b02:	8526                	mv	a0,s1
    80002b04:	bff9                	j	80002ae2 <either_copyin+0x32>

0000000080002b06 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002b06:	715d                	addi	sp,sp,-80
    80002b08:	e486                	sd	ra,72(sp)
    80002b0a:	e0a2                	sd	s0,64(sp)
    80002b0c:	fc26                	sd	s1,56(sp)
    80002b0e:	f84a                	sd	s2,48(sp)
    80002b10:	f44e                	sd	s3,40(sp)
    80002b12:	f052                	sd	s4,32(sp)
    80002b14:	ec56                	sd	s5,24(sp)
    80002b16:	e85a                	sd	s6,16(sp)
    80002b18:	e45e                	sd	s7,8(sp)
    80002b1a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002b1c:	00006517          	auipc	a0,0x6
    80002b20:	65c50513          	addi	a0,a0,1628 # 80009178 <digits+0x138>
    80002b24:	ffffe097          	auipc	ra,0xffffe
    80002b28:	a50080e7          	jalr	-1456(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b2c:	00010497          	auipc	s1,0x10
    80002b30:	cfc48493          	addi	s1,s1,-772 # 80012828 <proc+0x158>
    80002b34:	00022917          	auipc	s2,0x22
    80002b38:	4f490913          	addi	s2,s2,1268 # 80025028 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b3c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002b3e:	00007997          	auipc	s3,0x7
    80002b42:	9c298993          	addi	s3,s3,-1598 # 80009500 <digits+0x4c0>
    printf("%d %s %s", p->pid, state, p->name);
    80002b46:	00007a97          	auipc	s5,0x7
    80002b4a:	9c2a8a93          	addi	s5,s5,-1598 # 80009508 <digits+0x4c8>
    printf("\n");
    80002b4e:	00006a17          	auipc	s4,0x6
    80002b52:	62aa0a13          	addi	s4,s4,1578 # 80009178 <digits+0x138>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b56:	00007b97          	auipc	s7,0x7
    80002b5a:	9eab8b93          	addi	s7,s7,-1558 # 80009540 <states.0>
    80002b5e:	a00d                	j	80002b80 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002b60:	ed86a583          	lw	a1,-296(a3)
    80002b64:	8556                	mv	a0,s5
    80002b66:	ffffe097          	auipc	ra,0xffffe
    80002b6a:	a0e080e7          	jalr	-1522(ra) # 80000574 <printf>
    printf("\n");
    80002b6e:	8552                	mv	a0,s4
    80002b70:	ffffe097          	auipc	ra,0xffffe
    80002b74:	a04080e7          	jalr	-1532(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b78:	4a048493          	addi	s1,s1,1184
    80002b7c:	03248263          	beq	s1,s2,80002ba0 <procdump+0x9a>
    if(p->state == UNUSED)
    80002b80:	86a6                	mv	a3,s1
    80002b82:	ec04a783          	lw	a5,-320(s1)
    80002b86:	dbed                	beqz	a5,80002b78 <procdump+0x72>
      state = "???";
    80002b88:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b8a:	fcfb6be3          	bltu	s6,a5,80002b60 <procdump+0x5a>
    80002b8e:	02079713          	slli	a4,a5,0x20
    80002b92:	01d75793          	srli	a5,a4,0x1d
    80002b96:	97de                	add	a5,a5,s7
    80002b98:	6390                	ld	a2,0(a5)
    80002b9a:	f279                	bnez	a2,80002b60 <procdump+0x5a>
      state = "???";
    80002b9c:	864e                	mv	a2,s3
    80002b9e:	b7c9                	j	80002b60 <procdump+0x5a>
  }
}
    80002ba0:	60a6                	ld	ra,72(sp)
    80002ba2:	6406                	ld	s0,64(sp)
    80002ba4:	74e2                	ld	s1,56(sp)
    80002ba6:	7942                	ld	s2,48(sp)
    80002ba8:	79a2                	ld	s3,40(sp)
    80002baa:	7a02                	ld	s4,32(sp)
    80002bac:	6ae2                	ld	s5,24(sp)
    80002bae:	6b42                	ld	s6,16(sp)
    80002bb0:	6ba2                	ld	s7,8(sp)
    80002bb2:	6161                	addi	sp,sp,80
    80002bb4:	8082                	ret

0000000080002bb6 <findNextMin>:
    #ifdef SCFIFO
        int
        findNextMin(struct proc * p){
            uint min = 0xFFFFFFFF;
            int minindex = -1;
            for(int i = 0; i < 16; i++){
    80002bb6:	32450793          	addi	a5,a0,804
    80002bba:	4681                	li	a3,0
            int minindex = -1;
    80002bbc:	557d                	li	a0,-1
            uint min = 0xFFFFFFFF;
    80002bbe:	55fd                	li	a1,-1
            for(int i = 0; i < 16; i++){
    80002bc0:	4841                	li	a6,16
    80002bc2:	a039                	j	80002bd0 <findNextMin+0x1a>
                if ((p->physPagesArray[i].inUse == 1) & (p->physPagesArray[i].placeInQueue < min)){
    80002bc4:	8536                	mv	a0,a3
                    min = p->physPagesArray[i].placeInQueue;
    80002bc6:	85b2                	mv	a1,a2
            for(int i = 0; i < 16; i++){
    80002bc8:	2685                	addiw	a3,a3,1
    80002bca:	07e1                	addi	a5,a5,24
    80002bcc:	01068963          	beq	a3,a6,80002bde <findNextMin+0x28>
                if ((p->physPagesArray[i].inUse == 1) & (p->physPagesArray[i].placeInQueue < min)){
    80002bd0:	43d0                	lw	a2,4(a5)
    80002bd2:	4398                	lw	a4,0(a5)
    80002bd4:	177d                	addi	a4,a4,-1
    80002bd6:	fb6d                	bnez	a4,80002bc8 <findNextMin+0x12>
    80002bd8:	feb666e3          	bltu	a2,a1,80002bc4 <findNextMin+0xe>
    80002bdc:	b7f5                	j	80002bc8 <findNextMin+0x12>
                    minindex = i;
                }
            }
            if(minindex == -1){
    80002bde:	57fd                	li	a5,-1
    80002be0:	00f50363          	beq	a0,a5,80002be6 <findNextMin+0x30>
                panic("in findNextMin\n");
            }
            return minindex;
        }
    80002be4:	8082                	ret
        findNextMin(struct proc * p){
    80002be6:	1141                	addi	sp,sp,-16
    80002be8:	e406                	sd	ra,8(sp)
    80002bea:	e022                	sd	s0,0(sp)
    80002bec:	0800                	addi	s0,sp,16
                panic("in findNextMin\n");
    80002bee:	00007517          	auipc	a0,0x7
    80002bf2:	98250513          	addi	a0,a0,-1662 # 80009570 <states.0+0x30>
    80002bf6:	ffffe097          	auipc	ra,0xffffe
    80002bfa:	934080e7          	jalr	-1740(ra) # 8000052a <panic>

0000000080002bfe <sortArry>:


        void
        sortArry(struct proc * p){
    80002bfe:	7161                	addi	sp,sp,-432
    80002c00:	f706                	sd	ra,424(sp)
    80002c02:	f322                	sd	s0,416(sp)
    80002c04:	ef26                	sd	s1,408(sp)
    80002c06:	eb4a                	sd	s2,400(sp)
    80002c08:	e74e                	sd	s3,392(sp)
    80002c0a:	e352                	sd	s4,384(sp)
    80002c0c:	1b00                	addi	s0,sp,432
    80002c0e:	84aa                	mv	s1,a0
            struct page pages[16];
            for(int i = 0; i < 16; i++){
    80002c10:	e5040913          	addi	s2,s0,-432
    80002c14:	fd040993          	addi	s3,s0,-48
        sortArry(struct proc * p){
    80002c18:	8a4a                	mv	s4,s2
                int curr = findNextMin(p);
    80002c1a:	8526                	mv	a0,s1
    80002c1c:	00000097          	auipc	ra,0x0
    80002c20:	f9a080e7          	jalr	-102(ra) # 80002bb6 <findNextMin>
                pages[i] = p->physPagesArray[curr]; // maybe we need deep copy here!
    80002c24:	00151793          	slli	a5,a0,0x1
    80002c28:	00a78733          	add	a4,a5,a0
    80002c2c:	070e                	slli	a4,a4,0x3
    80002c2e:	9726                	add	a4,a4,s1
    80002c30:	31873683          	ld	a3,792(a4)
    80002c34:	00da3023          	sd	a3,0(s4)
    80002c38:	32073683          	ld	a3,800(a4)
    80002c3c:	00da3423          	sd	a3,8(s4)
    80002c40:	32873703          	ld	a4,808(a4)
    80002c44:	00ea3823          	sd	a4,16(s4)
                p->physPagesArray[curr].inUse = 0;
    80002c48:	97aa                	add	a5,a5,a0
    80002c4a:	078e                	slli	a5,a5,0x3
    80002c4c:	97a6                	add	a5,a5,s1
    80002c4e:	3207a223          	sw	zero,804(a5)
            for(int i = 0; i < 16; i++){
    80002c52:	0a61                	addi	s4,s4,24
    80002c54:	fd3a13e3          	bne	s4,s3,80002c1a <sortArry+0x1c>
    80002c58:	31848793          	addi	a5,s1,792

            }
            for(int j = 0; j < 16; j++){
                p->physPagesArray[j] = pages[j];
    80002c5c:	00093703          	ld	a4,0(s2)
    80002c60:	e398                	sd	a4,0(a5)
    80002c62:	00893703          	ld	a4,8(s2)
    80002c66:	e798                	sd	a4,8(a5)
    80002c68:	01093703          	ld	a4,16(s2)
    80002c6c:	eb98                	sd	a4,16(a5)
            for(int j = 0; j < 16; j++){
    80002c6e:	0961                	addi	s2,s2,24
    80002c70:	07e1                	addi	a5,a5,24
    80002c72:	ff3915e3          	bne	s2,s3,80002c5c <sortArry+0x5e>
            }
        }
    80002c76:	70ba                	ld	ra,424(sp)
    80002c78:	741a                	ld	s0,416(sp)
    80002c7a:	64fa                	ld	s1,408(sp)
    80002c7c:	695a                	ld	s2,400(sp)
    80002c7e:	69ba                	ld	s3,392(sp)
    80002c80:	6a1a                	ld	s4,384(sp)
    80002c82:	615d                	addi	sp,sp,432
    80002c84:	8082                	ret

0000000080002c86 <SCFIFOAlgo>:

        int
        SCFIFOAlgo(struct proc* p){
    80002c86:	7139                	addi	sp,sp,-64
    80002c88:	fc06                	sd	ra,56(sp)
    80002c8a:	f822                	sd	s0,48(sp)
    80002c8c:	f426                	sd	s1,40(sp)
    80002c8e:	f04a                	sd	s2,32(sp)
    80002c90:	ec4e                	sd	s3,24(sp)
    80002c92:	e852                	sd	s4,16(sp)
    80002c94:	e456                	sd	s5,8(sp)
    80002c96:	0080                	addi	s0,sp,64
    80002c98:	89aa                	mv	s3,a0
            sortArry(p);
    80002c9a:	00000097          	auipc	ra,0x0
    80002c9e:	f64080e7          	jalr	-156(ra) # 80002bfe <sortArry>
            }
            printf("\n");
            */

            int i = 0;
            for (int j = 0; j < MAX_PSYC_PAGES*2; j++){
    80002ca2:	4901                	li	s2,0
                i = j%16;
                if (p->physPagesArray[i].inUse == 1){
    80002ca4:	4a05                	li	s4,1
            for (int j = 0; j < MAX_PSYC_PAGES*2; j++){
    80002ca6:	02000a93          	li	s5,32
    80002caa:	a039                	j	80002cb8 <SCFIFOAlgo+0x32>
                    pte_t* pte = walk(p->pagetable, p->physPagesArray[i].va, 0);       
                        
                    if (*pte & PTE_U){ //check that this page is private to the user
                        if (*pte & PTE_A){ // accessed flag is on
                            //printf("page %d with place in que %d has pte_a on\n", i, p->physPagesArray[i].placeInQueue); //for debugging reasons
                            *pte = *pte & ~PTE_A; // turning off PTE_A flag
    80002cac:	fbf7f793          	andi	a5,a5,-65
    80002cb0:	e11c                	sd	a5,0(a0)
            for (int j = 0; j < MAX_PSYC_PAGES*2; j++){
    80002cb2:	2905                	addiw	s2,s2,1
    80002cb4:	07590263          	beq	s2,s5,80002d18 <SCFIFOAlgo+0x92>
                i = j%16;
    80002cb8:	41f9549b          	sraiw	s1,s2,0x1f
    80002cbc:	01c4d79b          	srliw	a5,s1,0x1c
    80002cc0:	012784bb          	addw	s1,a5,s2
    80002cc4:	88bd                	andi	s1,s1,15
    80002cc6:	9c9d                	subw	s1,s1,a5
                if (p->physPagesArray[i].inUse == 1){
    80002cc8:	00149793          	slli	a5,s1,0x1
    80002ccc:	97a6                	add	a5,a5,s1
    80002cce:	078e                	slli	a5,a5,0x3
    80002cd0:	97ce                	add	a5,a5,s3
    80002cd2:	3247a783          	lw	a5,804(a5)
    80002cd6:	fd479ee3          	bne	a5,s4,80002cb2 <SCFIFOAlgo+0x2c>
                    pte_t* pte = walk(p->pagetable, p->physPagesArray[i].va, 0);       
    80002cda:	00149793          	slli	a5,s1,0x1
    80002cde:	97a6                	add	a5,a5,s1
    80002ce0:	078e                	slli	a5,a5,0x3
    80002ce2:	97ce                	add	a5,a5,s3
    80002ce4:	4601                	li	a2,0
    80002ce6:	3187b583          	ld	a1,792(a5)
    80002cea:	0509b503          	ld	a0,80(s3)
    80002cee:	ffffe097          	auipc	ra,0xffffe
    80002cf2:	2b8080e7          	jalr	696(ra) # 80000fa6 <walk>
                    if (*pte & PTE_U){ //check that this page is private to the user
    80002cf6:	611c                	ld	a5,0(a0)
    80002cf8:	0107f713          	andi	a4,a5,16
    80002cfc:	db5d                	beqz	a4,80002cb2 <SCFIFOAlgo+0x2c>
                        if (*pte & PTE_A){ // accessed flag is on
    80002cfe:	0407f713          	andi	a4,a5,64
    80002d02:	f74d                	bnez	a4,80002cac <SCFIFOAlgo+0x26>
                    }
                }
            }
            panic("SCFIFOAlgo  FAILED! didnt find any isUsed physical pages");
            return -1;
        }
    80002d04:	8526                	mv	a0,s1
    80002d06:	70e2                	ld	ra,56(sp)
    80002d08:	7442                	ld	s0,48(sp)
    80002d0a:	74a2                	ld	s1,40(sp)
    80002d0c:	7902                	ld	s2,32(sp)
    80002d0e:	69e2                	ld	s3,24(sp)
    80002d10:	6a42                	ld	s4,16(sp)
    80002d12:	6aa2                	ld	s5,8(sp)
    80002d14:	6121                	addi	sp,sp,64
    80002d16:	8082                	ret
            panic("SCFIFOAlgo  FAILED! didnt find any isUsed physical pages");
    80002d18:	00007517          	auipc	a0,0x7
    80002d1c:	86850513          	addi	a0,a0,-1944 # 80009580 <states.0+0x40>
    80002d20:	ffffe097          	auipc	ra,0xffffe
    80002d24:	80a080e7          	jalr	-2038(ra) # 8000052a <panic>

0000000080002d28 <findPagetableIndexToSwap>:
    findPagetableIndexToSwap(struct proc* p){
    80002d28:	1141                	addi	sp,sp,-16
    80002d2a:	e406                	sd	ra,8(sp)
    80002d2c:	e022                	sd	s0,0(sp)
    80002d2e:	0800                	addi	s0,sp,16
            return SCFIFOAlgo(p);
    80002d30:	00000097          	auipc	ra,0x0
    80002d34:	f56080e7          	jalr	-170(ra) # 80002c86 <SCFIFOAlgo>
    }
    80002d38:	60a2                	ld	ra,8(sp)
    80002d3a:	6402                	ld	s0,0(sp)
    80002d3c:	0141                	addi	sp,sp,16
    80002d3e:	8082                	ret

0000000080002d40 <swtch>:
    80002d40:	00153023          	sd	ra,0(a0)
    80002d44:	00253423          	sd	sp,8(a0)
    80002d48:	e900                	sd	s0,16(a0)
    80002d4a:	ed04                	sd	s1,24(a0)
    80002d4c:	03253023          	sd	s2,32(a0)
    80002d50:	03353423          	sd	s3,40(a0)
    80002d54:	03453823          	sd	s4,48(a0)
    80002d58:	03553c23          	sd	s5,56(a0)
    80002d5c:	05653023          	sd	s6,64(a0)
    80002d60:	05753423          	sd	s7,72(a0)
    80002d64:	05853823          	sd	s8,80(a0)
    80002d68:	05953c23          	sd	s9,88(a0)
    80002d6c:	07a53023          	sd	s10,96(a0)
    80002d70:	07b53423          	sd	s11,104(a0)
    80002d74:	0005b083          	ld	ra,0(a1)
    80002d78:	0085b103          	ld	sp,8(a1)
    80002d7c:	6980                	ld	s0,16(a1)
    80002d7e:	6d84                	ld	s1,24(a1)
    80002d80:	0205b903          	ld	s2,32(a1)
    80002d84:	0285b983          	ld	s3,40(a1)
    80002d88:	0305ba03          	ld	s4,48(a1)
    80002d8c:	0385ba83          	ld	s5,56(a1)
    80002d90:	0405bb03          	ld	s6,64(a1)
    80002d94:	0485bb83          	ld	s7,72(a1)
    80002d98:	0505bc03          	ld	s8,80(a1)
    80002d9c:	0585bc83          	ld	s9,88(a1)
    80002da0:	0605bd03          	ld	s10,96(a1)
    80002da4:	0685bd83          	ld	s11,104(a1)
    80002da8:	8082                	ret

0000000080002daa <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002daa:	1141                	addi	sp,sp,-16
    80002dac:	e406                	sd	ra,8(sp)
    80002dae:	e022                	sd	s0,0(sp)
    80002db0:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002db2:	00007597          	auipc	a1,0x7
    80002db6:	80e58593          	addi	a1,a1,-2034 # 800095c0 <states.0+0x80>
    80002dba:	00022517          	auipc	a0,0x22
    80002dbe:	11650513          	addi	a0,a0,278 # 80024ed0 <tickslock>
    80002dc2:	ffffe097          	auipc	ra,0xffffe
    80002dc6:	d70080e7          	jalr	-656(ra) # 80000b32 <initlock>
}
    80002dca:	60a2                	ld	ra,8(sp)
    80002dcc:	6402                	ld	s0,0(sp)
    80002dce:	0141                	addi	sp,sp,16
    80002dd0:	8082                	ret

0000000080002dd2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002dd2:	1141                	addi	sp,sp,-16
    80002dd4:	e422                	sd	s0,8(sp)
    80002dd6:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002dd8:	00004797          	auipc	a5,0x4
    80002ddc:	c1878793          	addi	a5,a5,-1000 # 800069f0 <kernelvec>
    80002de0:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002de4:	6422                	ld	s0,8(sp)
    80002de6:	0141                	addi	sp,sp,16
    80002de8:	8082                	ret

0000000080002dea <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002dea:	1141                	addi	sp,sp,-16
    80002dec:	e406                	sd	ra,8(sp)
    80002dee:	e022                	sd	s0,0(sp)
    80002df0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002df2:	fffff097          	auipc	ra,0xfffff
    80002df6:	fc0080e7          	jalr	-64(ra) # 80001db2 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002dfa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002dfe:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e00:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002e04:	00005617          	auipc	a2,0x5
    80002e08:	1fc60613          	addi	a2,a2,508 # 80008000 <_trampoline>
    80002e0c:	00005697          	auipc	a3,0x5
    80002e10:	1f468693          	addi	a3,a3,500 # 80008000 <_trampoline>
    80002e14:	8e91                	sub	a3,a3,a2
    80002e16:	040007b7          	lui	a5,0x4000
    80002e1a:	17fd                	addi	a5,a5,-1
    80002e1c:	07b2                	slli	a5,a5,0xc
    80002e1e:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e20:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002e24:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002e26:	180026f3          	csrr	a3,satp
    80002e2a:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002e2c:	6d38                	ld	a4,88(a0)
    80002e2e:	6134                	ld	a3,64(a0)
    80002e30:	6585                	lui	a1,0x1
    80002e32:	96ae                	add	a3,a3,a1
    80002e34:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002e36:	6d38                	ld	a4,88(a0)
    80002e38:	00000697          	auipc	a3,0x0
    80002e3c:	13868693          	addi	a3,a3,312 # 80002f70 <usertrap>
    80002e40:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002e42:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002e44:	8692                	mv	a3,tp
    80002e46:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e48:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002e4c:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002e50:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e54:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002e58:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002e5a:	6f18                	ld	a4,24(a4)
    80002e5c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002e60:	692c                	ld	a1,80(a0)
    80002e62:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002e64:	00005717          	auipc	a4,0x5
    80002e68:	22c70713          	addi	a4,a4,556 # 80008090 <userret>
    80002e6c:	8f11                	sub	a4,a4,a2
    80002e6e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002e70:	577d                	li	a4,-1
    80002e72:	177e                	slli	a4,a4,0x3f
    80002e74:	8dd9                	or	a1,a1,a4
    80002e76:	02000537          	lui	a0,0x2000
    80002e7a:	157d                	addi	a0,a0,-1
    80002e7c:	0536                	slli	a0,a0,0xd
    80002e7e:	9782                	jalr	a5
}
    80002e80:	60a2                	ld	ra,8(sp)
    80002e82:	6402                	ld	s0,0(sp)
    80002e84:	0141                	addi	sp,sp,16
    80002e86:	8082                	ret

0000000080002e88 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002e88:	1101                	addi	sp,sp,-32
    80002e8a:	ec06                	sd	ra,24(sp)
    80002e8c:	e822                	sd	s0,16(sp)
    80002e8e:	e426                	sd	s1,8(sp)
    80002e90:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002e92:	00022497          	auipc	s1,0x22
    80002e96:	03e48493          	addi	s1,s1,62 # 80024ed0 <tickslock>
    80002e9a:	8526                	mv	a0,s1
    80002e9c:	ffffe097          	auipc	ra,0xffffe
    80002ea0:	d26080e7          	jalr	-730(ra) # 80000bc2 <acquire>
  ticks++;
    80002ea4:	00007517          	auipc	a0,0x7
    80002ea8:	18c50513          	addi	a0,a0,396 # 8000a030 <ticks>
    80002eac:	411c                	lw	a5,0(a0)
    80002eae:	2785                	addiw	a5,a5,1
    80002eb0:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002eb2:	00000097          	auipc	ra,0x0
    80002eb6:	94c080e7          	jalr	-1716(ra) # 800027fe <wakeup>
  release(&tickslock);
    80002eba:	8526                	mv	a0,s1
    80002ebc:	ffffe097          	auipc	ra,0xffffe
    80002ec0:	dba080e7          	jalr	-582(ra) # 80000c76 <release>
}
    80002ec4:	60e2                	ld	ra,24(sp)
    80002ec6:	6442                	ld	s0,16(sp)
    80002ec8:	64a2                	ld	s1,8(sp)
    80002eca:	6105                	addi	sp,sp,32
    80002ecc:	8082                	ret

0000000080002ece <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002ece:	1101                	addi	sp,sp,-32
    80002ed0:	ec06                	sd	ra,24(sp)
    80002ed2:	e822                	sd	s0,16(sp)
    80002ed4:	e426                	sd	s1,8(sp)
    80002ed6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ed8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002edc:	00074d63          	bltz	a4,80002ef6 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002ee0:	57fd                	li	a5,-1
    80002ee2:	17fe                	slli	a5,a5,0x3f
    80002ee4:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002ee6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002ee8:	06f70363          	beq	a4,a5,80002f4e <devintr+0x80>
  }
}
    80002eec:	60e2                	ld	ra,24(sp)
    80002eee:	6442                	ld	s0,16(sp)
    80002ef0:	64a2                	ld	s1,8(sp)
    80002ef2:	6105                	addi	sp,sp,32
    80002ef4:	8082                	ret
     (scause & 0xff) == 9){
    80002ef6:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002efa:	46a5                	li	a3,9
    80002efc:	fed792e3          	bne	a5,a3,80002ee0 <devintr+0x12>
    int irq = plic_claim();
    80002f00:	00004097          	auipc	ra,0x4
    80002f04:	bf8080e7          	jalr	-1032(ra) # 80006af8 <plic_claim>
    80002f08:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002f0a:	47a9                	li	a5,10
    80002f0c:	02f50763          	beq	a0,a5,80002f3a <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002f10:	4785                	li	a5,1
    80002f12:	02f50963          	beq	a0,a5,80002f44 <devintr+0x76>
    return 1;
    80002f16:	4505                	li	a0,1
    } else if(irq){
    80002f18:	d8f1                	beqz	s1,80002eec <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002f1a:	85a6                	mv	a1,s1
    80002f1c:	00006517          	auipc	a0,0x6
    80002f20:	6ac50513          	addi	a0,a0,1708 # 800095c8 <states.0+0x88>
    80002f24:	ffffd097          	auipc	ra,0xffffd
    80002f28:	650080e7          	jalr	1616(ra) # 80000574 <printf>
      plic_complete(irq);
    80002f2c:	8526                	mv	a0,s1
    80002f2e:	00004097          	auipc	ra,0x4
    80002f32:	bee080e7          	jalr	-1042(ra) # 80006b1c <plic_complete>
    return 1;
    80002f36:	4505                	li	a0,1
    80002f38:	bf55                	j	80002eec <devintr+0x1e>
      uartintr();
    80002f3a:	ffffe097          	auipc	ra,0xffffe
    80002f3e:	a4c080e7          	jalr	-1460(ra) # 80000986 <uartintr>
    80002f42:	b7ed                	j	80002f2c <devintr+0x5e>
      virtio_disk_intr();
    80002f44:	00004097          	auipc	ra,0x4
    80002f48:	06a080e7          	jalr	106(ra) # 80006fae <virtio_disk_intr>
    80002f4c:	b7c5                	j	80002f2c <devintr+0x5e>
    if(cpuid() == 0){
    80002f4e:	fffff097          	auipc	ra,0xfffff
    80002f52:	e38080e7          	jalr	-456(ra) # 80001d86 <cpuid>
    80002f56:	c901                	beqz	a0,80002f66 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002f58:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002f5c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002f5e:	14479073          	csrw	sip,a5
    return 2;
    80002f62:	4509                	li	a0,2
    80002f64:	b761                	j	80002eec <devintr+0x1e>
      clockintr();
    80002f66:	00000097          	auipc	ra,0x0
    80002f6a:	f22080e7          	jalr	-222(ra) # 80002e88 <clockintr>
    80002f6e:	b7ed                	j	80002f58 <devintr+0x8a>

0000000080002f70 <usertrap>:
{
    80002f70:	7179                	addi	sp,sp,-48
    80002f72:	f406                	sd	ra,40(sp)
    80002f74:	f022                	sd	s0,32(sp)
    80002f76:	ec26                	sd	s1,24(sp)
    80002f78:	e84a                	sd	s2,16(sp)
    80002f7a:	e44e                	sd	s3,8(sp)
    80002f7c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f7e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002f82:	1007f793          	andi	a5,a5,256
    80002f86:	e3b5                	bnez	a5,80002fea <usertrap+0x7a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002f88:	00004797          	auipc	a5,0x4
    80002f8c:	a6878793          	addi	a5,a5,-1432 # 800069f0 <kernelvec>
    80002f90:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002f94:	fffff097          	auipc	ra,0xfffff
    80002f98:	e1e080e7          	jalr	-482(ra) # 80001db2 <myproc>
    80002f9c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002f9e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fa0:	14102773          	csrr	a4,sepc
    80002fa4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002fa6:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002faa:	47a1                	li	a5,8
    80002fac:	04f71d63          	bne	a4,a5,80003006 <usertrap+0x96>
    if(p->killed)
    80002fb0:	551c                	lw	a5,40(a0)
    80002fb2:	e7a1                	bnez	a5,80002ffa <usertrap+0x8a>
    p->trapframe->epc += 4;
    80002fb4:	6cb8                	ld	a4,88(s1)
    80002fb6:	6f1c                	ld	a5,24(a4)
    80002fb8:	0791                	addi	a5,a5,4
    80002fba:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fbc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002fc0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002fc4:	10079073          	csrw	sstatus,a5
    syscall();
    80002fc8:	00000097          	auipc	ra,0x0
    80002fcc:	35a080e7          	jalr	858(ra) # 80003322 <syscall>
  if(p->killed)
    80002fd0:	549c                	lw	a5,40(s1)
    80002fd2:	ebed                	bnez	a5,800030c4 <usertrap+0x154>
  usertrapret();
    80002fd4:	00000097          	auipc	ra,0x0
    80002fd8:	e16080e7          	jalr	-490(ra) # 80002dea <usertrapret>
}
    80002fdc:	70a2                	ld	ra,40(sp)
    80002fde:	7402                	ld	s0,32(sp)
    80002fe0:	64e2                	ld	s1,24(sp)
    80002fe2:	6942                	ld	s2,16(sp)
    80002fe4:	69a2                	ld	s3,8(sp)
    80002fe6:	6145                	addi	sp,sp,48
    80002fe8:	8082                	ret
    panic("usertrap: not from user mode");
    80002fea:	00006517          	auipc	a0,0x6
    80002fee:	5fe50513          	addi	a0,a0,1534 # 800095e8 <states.0+0xa8>
    80002ff2:	ffffd097          	auipc	ra,0xffffd
    80002ff6:	538080e7          	jalr	1336(ra) # 8000052a <panic>
      exit(-1);
    80002ffa:	557d                	li	a0,-1
    80002ffc:	00000097          	auipc	ra,0x0
    80003000:	8d2080e7          	jalr	-1838(ra) # 800028ce <exit>
    80003004:	bf45                	j	80002fb4 <usertrap+0x44>
  } else if((which_dev = devintr()) != 0){
    80003006:	00000097          	auipc	ra,0x0
    8000300a:	ec8080e7          	jalr	-312(ra) # 80002ece <devintr>
    8000300e:	892a                	mv	s2,a0
    80003010:	e55d                	bnez	a0,800030be <usertrap+0x14e>
      if (p->pid > 2){
    80003012:	5898                	lw	a4,48(s1)
    80003014:	4789                	li	a5,2
    80003016:	fae7dde3          	bge	a5,a4,80002fd0 <usertrap+0x60>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000301a:	142027f3          	csrr	a5,scause
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000301e:	143026f3          	csrr	a3,stval
        if ( (cause == 13) | (cause == 15) | (cause==12) ){ 
    80003022:	ff478713          	addi	a4,a5,-12
    80003026:	00273713          	sltiu	a4,a4,2
    8000302a:	e319                	bnez	a4,80003030 <usertrap+0xc0>
    8000302c:	17c5                	addi	a5,a5,-15
    8000302e:	f3cd                	bnez	a5,80002fd0 <usertrap+0x60>
        uint64 va =  PGROUNDDOWN(r_stval());
    80003030:	79fd                	lui	s3,0xfffff
    80003032:	0136f9b3          	and	s3,a3,s3
          pte_t* pte = walk(p->pagetable, va, 0);
    80003036:	4601                	li	a2,0
    80003038:	85ce                	mv	a1,s3
    8000303a:	68a8                	ld	a0,80(s1)
    8000303c:	ffffe097          	auipc	ra,0xffffe
    80003040:	f6a080e7          	jalr	-150(ra) # 80000fa6 <walk>
          if (*pte & PTE_PG ){ //check if this page is in swap file
    80003044:	611c                	ld	a5,0(a0)
    80003046:	2007f793          	andi	a5,a5,512
    8000304a:	cb85                	beqz	a5,8000307a <usertrap+0x10a>
            p->numOfPageFault++;
    8000304c:	4984a783          	lw	a5,1176(s1)
    80003050:	2785                	addiw	a5,a5,1
    80003052:	48f4ac23          	sw	a5,1176(s1)
            if(p->numOfPhyPages == 16){
    80003056:	1784a703          	lw	a4,376(s1)
    8000305a:	47c1                	li	a5,16
    8000305c:	00f70963          	beq	a4,a5,8000306e <usertrap+0xfe>
            swapIn(p, va);
    80003060:	85ce                	mv	a1,s3
    80003062:	8526                	mv	a0,s1
    80003064:	ffffe097          	auipc	ra,0xffffe
    80003068:	532080e7          	jalr	1330(ra) # 80001596 <swapIn>
    8000306c:	b795                	j	80002fd0 <usertrap+0x60>
              swapOut(p);
    8000306e:	8526                	mv	a0,s1
    80003070:	ffffe097          	auipc	ra,0xffffe
    80003074:	40c080e7          	jalr	1036(ra) # 8000147c <swapOut>
    80003078:	b7e5                	j	80003060 <usertrap+0xf0>
            printf("segmentation fault!\n");
    8000307a:	00006517          	auipc	a0,0x6
    8000307e:	58e50513          	addi	a0,a0,1422 # 80009608 <states.0+0xc8>
    80003082:	ffffd097          	auipc	ra,0xffffd
    80003086:	4f2080e7          	jalr	1266(ra) # 80000574 <printf>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000308a:	142025f3          	csrr	a1,scause
            printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000308e:	5890                	lw	a2,48(s1)
    80003090:	00006517          	auipc	a0,0x6
    80003094:	59050513          	addi	a0,a0,1424 # 80009620 <states.0+0xe0>
    80003098:	ffffd097          	auipc	ra,0xffffd
    8000309c:	4dc080e7          	jalr	1244(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800030a0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800030a4:	14302673          	csrr	a2,stval
            printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800030a8:	00006517          	auipc	a0,0x6
    800030ac:	5a850513          	addi	a0,a0,1448 # 80009650 <states.0+0x110>
    800030b0:	ffffd097          	auipc	ra,0xffffd
    800030b4:	4c4080e7          	jalr	1220(ra) # 80000574 <printf>
            p->killed = 1;
    800030b8:	4785                	li	a5,1
    800030ba:	d49c                	sw	a5,40(s1)
  if(p->killed)
    800030bc:	a029                	j	800030c6 <usertrap+0x156>
    800030be:	549c                	lw	a5,40(s1)
    800030c0:	cb81                	beqz	a5,800030d0 <usertrap+0x160>
    800030c2:	a011                	j	800030c6 <usertrap+0x156>
    800030c4:	4901                	li	s2,0
    exit(-1);
    800030c6:	557d                	li	a0,-1
    800030c8:	00000097          	auipc	ra,0x0
    800030cc:	806080e7          	jalr	-2042(ra) # 800028ce <exit>
  if(which_dev == 2)
    800030d0:	4789                	li	a5,2
    800030d2:	f0f911e3          	bne	s2,a5,80002fd4 <usertrap+0x64>
    yield();
    800030d6:	fffff097          	auipc	ra,0xfffff
    800030da:	560080e7          	jalr	1376(ra) # 80002636 <yield>
    800030de:	bddd                	j	80002fd4 <usertrap+0x64>

00000000800030e0 <kerneltrap>:
{
    800030e0:	7179                	addi	sp,sp,-48
    800030e2:	f406                	sd	ra,40(sp)
    800030e4:	f022                	sd	s0,32(sp)
    800030e6:	ec26                	sd	s1,24(sp)
    800030e8:	e84a                	sd	s2,16(sp)
    800030ea:	e44e                	sd	s3,8(sp)
    800030ec:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800030ee:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800030f2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800030f6:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800030fa:	1004f793          	andi	a5,s1,256
    800030fe:	cb85                	beqz	a5,8000312e <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003100:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003104:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80003106:	ef85                	bnez	a5,8000313e <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80003108:	00000097          	auipc	ra,0x0
    8000310c:	dc6080e7          	jalr	-570(ra) # 80002ece <devintr>
    80003110:	cd1d                	beqz	a0,8000314e <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003112:	4789                	li	a5,2
    80003114:	06f50a63          	beq	a0,a5,80003188 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003118:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000311c:	10049073          	csrw	sstatus,s1
}
    80003120:	70a2                	ld	ra,40(sp)
    80003122:	7402                	ld	s0,32(sp)
    80003124:	64e2                	ld	s1,24(sp)
    80003126:	6942                	ld	s2,16(sp)
    80003128:	69a2                	ld	s3,8(sp)
    8000312a:	6145                	addi	sp,sp,48
    8000312c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000312e:	00006517          	auipc	a0,0x6
    80003132:	54250513          	addi	a0,a0,1346 # 80009670 <states.0+0x130>
    80003136:	ffffd097          	auipc	ra,0xffffd
    8000313a:	3f4080e7          	jalr	1012(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    8000313e:	00006517          	auipc	a0,0x6
    80003142:	55a50513          	addi	a0,a0,1370 # 80009698 <states.0+0x158>
    80003146:	ffffd097          	auipc	ra,0xffffd
    8000314a:	3e4080e7          	jalr	996(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    8000314e:	85ce                	mv	a1,s3
    80003150:	00006517          	auipc	a0,0x6
    80003154:	56850513          	addi	a0,a0,1384 # 800096b8 <states.0+0x178>
    80003158:	ffffd097          	auipc	ra,0xffffd
    8000315c:	41c080e7          	jalr	1052(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003160:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003164:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003168:	00006517          	auipc	a0,0x6
    8000316c:	56050513          	addi	a0,a0,1376 # 800096c8 <states.0+0x188>
    80003170:	ffffd097          	auipc	ra,0xffffd
    80003174:	404080e7          	jalr	1028(ra) # 80000574 <printf>
    panic("kerneltrap");
    80003178:	00006517          	auipc	a0,0x6
    8000317c:	56850513          	addi	a0,a0,1384 # 800096e0 <states.0+0x1a0>
    80003180:	ffffd097          	auipc	ra,0xffffd
    80003184:	3aa080e7          	jalr	938(ra) # 8000052a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003188:	fffff097          	auipc	ra,0xfffff
    8000318c:	c2a080e7          	jalr	-982(ra) # 80001db2 <myproc>
    80003190:	d541                	beqz	a0,80003118 <kerneltrap+0x38>
    80003192:	fffff097          	auipc	ra,0xfffff
    80003196:	c20080e7          	jalr	-992(ra) # 80001db2 <myproc>
    8000319a:	4d18                	lw	a4,24(a0)
    8000319c:	4791                	li	a5,4
    8000319e:	f6f71de3          	bne	a4,a5,80003118 <kerneltrap+0x38>
    yield();
    800031a2:	fffff097          	auipc	ra,0xfffff
    800031a6:	494080e7          	jalr	1172(ra) # 80002636 <yield>
    800031aa:	b7bd                	j	80003118 <kerneltrap+0x38>

00000000800031ac <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800031ac:	1101                	addi	sp,sp,-32
    800031ae:	ec06                	sd	ra,24(sp)
    800031b0:	e822                	sd	s0,16(sp)
    800031b2:	e426                	sd	s1,8(sp)
    800031b4:	1000                	addi	s0,sp,32
    800031b6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800031b8:	fffff097          	auipc	ra,0xfffff
    800031bc:	bfa080e7          	jalr	-1030(ra) # 80001db2 <myproc>
  switch (n) {
    800031c0:	4795                	li	a5,5
    800031c2:	0497e163          	bltu	a5,s1,80003204 <argraw+0x58>
    800031c6:	048a                	slli	s1,s1,0x2
    800031c8:	00006717          	auipc	a4,0x6
    800031cc:	55070713          	addi	a4,a4,1360 # 80009718 <states.0+0x1d8>
    800031d0:	94ba                	add	s1,s1,a4
    800031d2:	409c                	lw	a5,0(s1)
    800031d4:	97ba                	add	a5,a5,a4
    800031d6:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800031d8:	6d3c                	ld	a5,88(a0)
    800031da:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800031dc:	60e2                	ld	ra,24(sp)
    800031de:	6442                	ld	s0,16(sp)
    800031e0:	64a2                	ld	s1,8(sp)
    800031e2:	6105                	addi	sp,sp,32
    800031e4:	8082                	ret
    return p->trapframe->a1;
    800031e6:	6d3c                	ld	a5,88(a0)
    800031e8:	7fa8                	ld	a0,120(a5)
    800031ea:	bfcd                	j	800031dc <argraw+0x30>
    return p->trapframe->a2;
    800031ec:	6d3c                	ld	a5,88(a0)
    800031ee:	63c8                	ld	a0,128(a5)
    800031f0:	b7f5                	j	800031dc <argraw+0x30>
    return p->trapframe->a3;
    800031f2:	6d3c                	ld	a5,88(a0)
    800031f4:	67c8                	ld	a0,136(a5)
    800031f6:	b7dd                	j	800031dc <argraw+0x30>
    return p->trapframe->a4;
    800031f8:	6d3c                	ld	a5,88(a0)
    800031fa:	6bc8                	ld	a0,144(a5)
    800031fc:	b7c5                	j	800031dc <argraw+0x30>
    return p->trapframe->a5;
    800031fe:	6d3c                	ld	a5,88(a0)
    80003200:	6fc8                	ld	a0,152(a5)
    80003202:	bfe9                	j	800031dc <argraw+0x30>
  panic("argraw");
    80003204:	00006517          	auipc	a0,0x6
    80003208:	4ec50513          	addi	a0,a0,1260 # 800096f0 <states.0+0x1b0>
    8000320c:	ffffd097          	auipc	ra,0xffffd
    80003210:	31e080e7          	jalr	798(ra) # 8000052a <panic>

0000000080003214 <fetchaddr>:
{
    80003214:	1101                	addi	sp,sp,-32
    80003216:	ec06                	sd	ra,24(sp)
    80003218:	e822                	sd	s0,16(sp)
    8000321a:	e426                	sd	s1,8(sp)
    8000321c:	e04a                	sd	s2,0(sp)
    8000321e:	1000                	addi	s0,sp,32
    80003220:	84aa                	mv	s1,a0
    80003222:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003224:	fffff097          	auipc	ra,0xfffff
    80003228:	b8e080e7          	jalr	-1138(ra) # 80001db2 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    8000322c:	653c                	ld	a5,72(a0)
    8000322e:	02f4f863          	bgeu	s1,a5,8000325e <fetchaddr+0x4a>
    80003232:	00848713          	addi	a4,s1,8
    80003236:	02e7e663          	bltu	a5,a4,80003262 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000323a:	46a1                	li	a3,8
    8000323c:	8626                	mv	a2,s1
    8000323e:	85ca                	mv	a1,s2
    80003240:	6928                	ld	a0,80(a0)
    80003242:	fffff097          	auipc	ra,0xfffff
    80003246:	8bc080e7          	jalr	-1860(ra) # 80001afe <copyin>
    8000324a:	00a03533          	snez	a0,a0
    8000324e:	40a00533          	neg	a0,a0
}
    80003252:	60e2                	ld	ra,24(sp)
    80003254:	6442                	ld	s0,16(sp)
    80003256:	64a2                	ld	s1,8(sp)
    80003258:	6902                	ld	s2,0(sp)
    8000325a:	6105                	addi	sp,sp,32
    8000325c:	8082                	ret
    return -1;
    8000325e:	557d                	li	a0,-1
    80003260:	bfcd                	j	80003252 <fetchaddr+0x3e>
    80003262:	557d                	li	a0,-1
    80003264:	b7fd                	j	80003252 <fetchaddr+0x3e>

0000000080003266 <fetchstr>:
{
    80003266:	7179                	addi	sp,sp,-48
    80003268:	f406                	sd	ra,40(sp)
    8000326a:	f022                	sd	s0,32(sp)
    8000326c:	ec26                	sd	s1,24(sp)
    8000326e:	e84a                	sd	s2,16(sp)
    80003270:	e44e                	sd	s3,8(sp)
    80003272:	1800                	addi	s0,sp,48
    80003274:	892a                	mv	s2,a0
    80003276:	84ae                	mv	s1,a1
    80003278:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000327a:	fffff097          	auipc	ra,0xfffff
    8000327e:	b38080e7          	jalr	-1224(ra) # 80001db2 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003282:	86ce                	mv	a3,s3
    80003284:	864a                	mv	a2,s2
    80003286:	85a6                	mv	a1,s1
    80003288:	6928                	ld	a0,80(a0)
    8000328a:	fffff097          	auipc	ra,0xfffff
    8000328e:	902080e7          	jalr	-1790(ra) # 80001b8c <copyinstr>
  if(err < 0)
    80003292:	00054763          	bltz	a0,800032a0 <fetchstr+0x3a>
  return strlen(buf);
    80003296:	8526                	mv	a0,s1
    80003298:	ffffe097          	auipc	ra,0xffffe
    8000329c:	baa080e7          	jalr	-1110(ra) # 80000e42 <strlen>
}
    800032a0:	70a2                	ld	ra,40(sp)
    800032a2:	7402                	ld	s0,32(sp)
    800032a4:	64e2                	ld	s1,24(sp)
    800032a6:	6942                	ld	s2,16(sp)
    800032a8:	69a2                	ld	s3,8(sp)
    800032aa:	6145                	addi	sp,sp,48
    800032ac:	8082                	ret

00000000800032ae <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    800032ae:	1101                	addi	sp,sp,-32
    800032b0:	ec06                	sd	ra,24(sp)
    800032b2:	e822                	sd	s0,16(sp)
    800032b4:	e426                	sd	s1,8(sp)
    800032b6:	1000                	addi	s0,sp,32
    800032b8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800032ba:	00000097          	auipc	ra,0x0
    800032be:	ef2080e7          	jalr	-270(ra) # 800031ac <argraw>
    800032c2:	c088                	sw	a0,0(s1)
  return 0;
}
    800032c4:	4501                	li	a0,0
    800032c6:	60e2                	ld	ra,24(sp)
    800032c8:	6442                	ld	s0,16(sp)
    800032ca:	64a2                	ld	s1,8(sp)
    800032cc:	6105                	addi	sp,sp,32
    800032ce:	8082                	ret

00000000800032d0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    800032d0:	1101                	addi	sp,sp,-32
    800032d2:	ec06                	sd	ra,24(sp)
    800032d4:	e822                	sd	s0,16(sp)
    800032d6:	e426                	sd	s1,8(sp)
    800032d8:	1000                	addi	s0,sp,32
    800032da:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800032dc:	00000097          	auipc	ra,0x0
    800032e0:	ed0080e7          	jalr	-304(ra) # 800031ac <argraw>
    800032e4:	e088                	sd	a0,0(s1)
  return 0;
}
    800032e6:	4501                	li	a0,0
    800032e8:	60e2                	ld	ra,24(sp)
    800032ea:	6442                	ld	s0,16(sp)
    800032ec:	64a2                	ld	s1,8(sp)
    800032ee:	6105                	addi	sp,sp,32
    800032f0:	8082                	ret

00000000800032f2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800032f2:	1101                	addi	sp,sp,-32
    800032f4:	ec06                	sd	ra,24(sp)
    800032f6:	e822                	sd	s0,16(sp)
    800032f8:	e426                	sd	s1,8(sp)
    800032fa:	e04a                	sd	s2,0(sp)
    800032fc:	1000                	addi	s0,sp,32
    800032fe:	84ae                	mv	s1,a1
    80003300:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003302:	00000097          	auipc	ra,0x0
    80003306:	eaa080e7          	jalr	-342(ra) # 800031ac <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    8000330a:	864a                	mv	a2,s2
    8000330c:	85a6                	mv	a1,s1
    8000330e:	00000097          	auipc	ra,0x0
    80003312:	f58080e7          	jalr	-168(ra) # 80003266 <fetchstr>
}
    80003316:	60e2                	ld	ra,24(sp)
    80003318:	6442                	ld	s0,16(sp)
    8000331a:	64a2                	ld	s1,8(sp)
    8000331c:	6902                	ld	s2,0(sp)
    8000331e:	6105                	addi	sp,sp,32
    80003320:	8082                	ret

0000000080003322 <syscall>:
[SYS_setAndGetPageFaultsNum]   sys_setAndGetPageFaultsNum,
};

void
syscall(void)
{
    80003322:	1101                	addi	sp,sp,-32
    80003324:	ec06                	sd	ra,24(sp)
    80003326:	e822                	sd	s0,16(sp)
    80003328:	e426                	sd	s1,8(sp)
    8000332a:	e04a                	sd	s2,0(sp)
    8000332c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000332e:	fffff097          	auipc	ra,0xfffff
    80003332:	a84080e7          	jalr	-1404(ra) # 80001db2 <myproc>
    80003336:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003338:	05853903          	ld	s2,88(a0)
    8000333c:	0a893783          	ld	a5,168(s2)
    80003340:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003344:	37fd                	addiw	a5,a5,-1
    80003346:	4755                	li	a4,21
    80003348:	00f76f63          	bltu	a4,a5,80003366 <syscall+0x44>
    8000334c:	00369713          	slli	a4,a3,0x3
    80003350:	00006797          	auipc	a5,0x6
    80003354:	3e078793          	addi	a5,a5,992 # 80009730 <syscalls>
    80003358:	97ba                	add	a5,a5,a4
    8000335a:	639c                	ld	a5,0(a5)
    8000335c:	c789                	beqz	a5,80003366 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    8000335e:	9782                	jalr	a5
    80003360:	06a93823          	sd	a0,112(s2)
    80003364:	a839                	j	80003382 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003366:	15848613          	addi	a2,s1,344
    8000336a:	588c                	lw	a1,48(s1)
    8000336c:	00006517          	auipc	a0,0x6
    80003370:	38c50513          	addi	a0,a0,908 # 800096f8 <states.0+0x1b8>
    80003374:	ffffd097          	auipc	ra,0xffffd
    80003378:	200080e7          	jalr	512(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000337c:	6cbc                	ld	a5,88(s1)
    8000337e:	577d                	li	a4,-1
    80003380:	fbb8                	sd	a4,112(a5)
  }
}
    80003382:	60e2                	ld	ra,24(sp)
    80003384:	6442                	ld	s0,16(sp)
    80003386:	64a2                	ld	s1,8(sp)
    80003388:	6902                	ld	s2,0(sp)
    8000338a:	6105                	addi	sp,sp,32
    8000338c:	8082                	ret

000000008000338e <sys_setAndGetPageFaultsNum>:
#include "proc.h"


uint64
sys_setAndGetPageFaultsNum(void)
{
    8000338e:	1101                	addi	sp,sp,-32
    80003390:	ec06                	sd	ra,24(sp)
    80003392:	e822                	sd	s0,16(sp)
    80003394:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003396:	fec40593          	addi	a1,s0,-20
    8000339a:	4501                	li	a0,0
    8000339c:	00000097          	auipc	ra,0x0
    800033a0:	f12080e7          	jalr	-238(ra) # 800032ae <argint>
    800033a4:	87aa                	mv	a5,a0
    return -1;
    800033a6:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    800033a8:	0007c863          	bltz	a5,800033b8 <sys_setAndGetPageFaultsNum+0x2a>
  return setAndGetPageFaultsNum(n);  // not reached
    800033ac:	fec42503          	lw	a0,-20(s0)
    800033b0:	fffff097          	auipc	ra,0xfffff
    800033b4:	ac6080e7          	jalr	-1338(ra) # 80001e76 <setAndGetPageFaultsNum>
}
    800033b8:	60e2                	ld	ra,24(sp)
    800033ba:	6442                	ld	s0,16(sp)
    800033bc:	6105                	addi	sp,sp,32
    800033be:	8082                	ret

00000000800033c0 <sys_exit>:


uint64
sys_exit(void)
{
    800033c0:	1101                	addi	sp,sp,-32
    800033c2:	ec06                	sd	ra,24(sp)
    800033c4:	e822                	sd	s0,16(sp)
    800033c6:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800033c8:	fec40593          	addi	a1,s0,-20
    800033cc:	4501                	li	a0,0
    800033ce:	00000097          	auipc	ra,0x0
    800033d2:	ee0080e7          	jalr	-288(ra) # 800032ae <argint>
    return -1;
    800033d6:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800033d8:	00054963          	bltz	a0,800033ea <sys_exit+0x2a>
  exit(n);
    800033dc:	fec42503          	lw	a0,-20(s0)
    800033e0:	fffff097          	auipc	ra,0xfffff
    800033e4:	4ee080e7          	jalr	1262(ra) # 800028ce <exit>
  return 0;  // not reached
    800033e8:	4781                	li	a5,0
}
    800033ea:	853e                	mv	a0,a5
    800033ec:	60e2                	ld	ra,24(sp)
    800033ee:	6442                	ld	s0,16(sp)
    800033f0:	6105                	addi	sp,sp,32
    800033f2:	8082                	ret

00000000800033f4 <sys_getpid>:

uint64
sys_getpid(void)
{
    800033f4:	1141                	addi	sp,sp,-16
    800033f6:	e406                	sd	ra,8(sp)
    800033f8:	e022                	sd	s0,0(sp)
    800033fa:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800033fc:	fffff097          	auipc	ra,0xfffff
    80003400:	9b6080e7          	jalr	-1610(ra) # 80001db2 <myproc>
}
    80003404:	5908                	lw	a0,48(a0)
    80003406:	60a2                	ld	ra,8(sp)
    80003408:	6402                	ld	s0,0(sp)
    8000340a:	0141                	addi	sp,sp,16
    8000340c:	8082                	ret

000000008000340e <sys_fork>:

uint64
sys_fork(void)
{
    8000340e:	1141                	addi	sp,sp,-16
    80003410:	e406                	sd	ra,8(sp)
    80003412:	e022                	sd	s0,0(sp)
    80003414:	0800                	addi	s0,sp,16
  return fork();
    80003416:	fffff097          	auipc	ra,0xfffff
    8000341a:	ede080e7          	jalr	-290(ra) # 800022f4 <fork>
}
    8000341e:	60a2                	ld	ra,8(sp)
    80003420:	6402                	ld	s0,0(sp)
    80003422:	0141                	addi	sp,sp,16
    80003424:	8082                	ret

0000000080003426 <sys_wait>:

uint64
sys_wait(void)
{
    80003426:	1101                	addi	sp,sp,-32
    80003428:	ec06                	sd	ra,24(sp)
    8000342a:	e822                	sd	s0,16(sp)
    8000342c:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    8000342e:	fe840593          	addi	a1,s0,-24
    80003432:	4501                	li	a0,0
    80003434:	00000097          	auipc	ra,0x0
    80003438:	e9c080e7          	jalr	-356(ra) # 800032d0 <argaddr>
    8000343c:	87aa                	mv	a5,a0
    return -1;
    8000343e:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003440:	0007c863          	bltz	a5,80003450 <sys_wait+0x2a>
  return wait(p);
    80003444:	fe843503          	ld	a0,-24(s0)
    80003448:	fffff097          	auipc	ra,0xfffff
    8000344c:	28e080e7          	jalr	654(ra) # 800026d6 <wait>
}
    80003450:	60e2                	ld	ra,24(sp)
    80003452:	6442                	ld	s0,16(sp)
    80003454:	6105                	addi	sp,sp,32
    80003456:	8082                	ret

0000000080003458 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003458:	7179                	addi	sp,sp,-48
    8000345a:	f406                	sd	ra,40(sp)
    8000345c:	f022                	sd	s0,32(sp)
    8000345e:	ec26                	sd	s1,24(sp)
    80003460:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003462:	fdc40593          	addi	a1,s0,-36
    80003466:	4501                	li	a0,0
    80003468:	00000097          	auipc	ra,0x0
    8000346c:	e46080e7          	jalr	-442(ra) # 800032ae <argint>
    return -1;
    80003470:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80003472:	00054f63          	bltz	a0,80003490 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80003476:	fffff097          	auipc	ra,0xfffff
    8000347a:	93c080e7          	jalr	-1732(ra) # 80001db2 <myproc>
    8000347e:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80003480:	fdc42503          	lw	a0,-36(s0)
    80003484:	fffff097          	auipc	ra,0xfffff
    80003488:	d2c080e7          	jalr	-724(ra) # 800021b0 <growproc>
    8000348c:	00054863          	bltz	a0,8000349c <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80003490:	8526                	mv	a0,s1
    80003492:	70a2                	ld	ra,40(sp)
    80003494:	7402                	ld	s0,32(sp)
    80003496:	64e2                	ld	s1,24(sp)
    80003498:	6145                	addi	sp,sp,48
    8000349a:	8082                	ret
    return -1;
    8000349c:	54fd                	li	s1,-1
    8000349e:	bfcd                	j	80003490 <sys_sbrk+0x38>

00000000800034a0 <sys_sleep>:

uint64
sys_sleep(void)
{
    800034a0:	7139                	addi	sp,sp,-64
    800034a2:	fc06                	sd	ra,56(sp)
    800034a4:	f822                	sd	s0,48(sp)
    800034a6:	f426                	sd	s1,40(sp)
    800034a8:	f04a                	sd	s2,32(sp)
    800034aa:	ec4e                	sd	s3,24(sp)
    800034ac:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800034ae:	fcc40593          	addi	a1,s0,-52
    800034b2:	4501                	li	a0,0
    800034b4:	00000097          	auipc	ra,0x0
    800034b8:	dfa080e7          	jalr	-518(ra) # 800032ae <argint>
    return -1;
    800034bc:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800034be:	06054563          	bltz	a0,80003528 <sys_sleep+0x88>
  acquire(&tickslock);
    800034c2:	00022517          	auipc	a0,0x22
    800034c6:	a0e50513          	addi	a0,a0,-1522 # 80024ed0 <tickslock>
    800034ca:	ffffd097          	auipc	ra,0xffffd
    800034ce:	6f8080e7          	jalr	1784(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    800034d2:	00007917          	auipc	s2,0x7
    800034d6:	b5e92903          	lw	s2,-1186(s2) # 8000a030 <ticks>
  while(ticks - ticks0 < n){
    800034da:	fcc42783          	lw	a5,-52(s0)
    800034de:	cf85                	beqz	a5,80003516 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800034e0:	00022997          	auipc	s3,0x22
    800034e4:	9f098993          	addi	s3,s3,-1552 # 80024ed0 <tickslock>
    800034e8:	00007497          	auipc	s1,0x7
    800034ec:	b4848493          	addi	s1,s1,-1208 # 8000a030 <ticks>
    if(myproc()->killed){
    800034f0:	fffff097          	auipc	ra,0xfffff
    800034f4:	8c2080e7          	jalr	-1854(ra) # 80001db2 <myproc>
    800034f8:	551c                	lw	a5,40(a0)
    800034fa:	ef9d                	bnez	a5,80003538 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    800034fc:	85ce                	mv	a1,s3
    800034fe:	8526                	mv	a0,s1
    80003500:	fffff097          	auipc	ra,0xfffff
    80003504:	172080e7          	jalr	370(ra) # 80002672 <sleep>
  while(ticks - ticks0 < n){
    80003508:	409c                	lw	a5,0(s1)
    8000350a:	412787bb          	subw	a5,a5,s2
    8000350e:	fcc42703          	lw	a4,-52(s0)
    80003512:	fce7efe3          	bltu	a5,a4,800034f0 <sys_sleep+0x50>
  }
  release(&tickslock);
    80003516:	00022517          	auipc	a0,0x22
    8000351a:	9ba50513          	addi	a0,a0,-1606 # 80024ed0 <tickslock>
    8000351e:	ffffd097          	auipc	ra,0xffffd
    80003522:	758080e7          	jalr	1880(ra) # 80000c76 <release>
  return 0;
    80003526:	4781                	li	a5,0
}
    80003528:	853e                	mv	a0,a5
    8000352a:	70e2                	ld	ra,56(sp)
    8000352c:	7442                	ld	s0,48(sp)
    8000352e:	74a2                	ld	s1,40(sp)
    80003530:	7902                	ld	s2,32(sp)
    80003532:	69e2                	ld	s3,24(sp)
    80003534:	6121                	addi	sp,sp,64
    80003536:	8082                	ret
      release(&tickslock);
    80003538:	00022517          	auipc	a0,0x22
    8000353c:	99850513          	addi	a0,a0,-1640 # 80024ed0 <tickslock>
    80003540:	ffffd097          	auipc	ra,0xffffd
    80003544:	736080e7          	jalr	1846(ra) # 80000c76 <release>
      return -1;
    80003548:	57fd                	li	a5,-1
    8000354a:	bff9                	j	80003528 <sys_sleep+0x88>

000000008000354c <sys_kill>:

uint64
sys_kill(void)
{
    8000354c:	1101                	addi	sp,sp,-32
    8000354e:	ec06                	sd	ra,24(sp)
    80003550:	e822                	sd	s0,16(sp)
    80003552:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003554:	fec40593          	addi	a1,s0,-20
    80003558:	4501                	li	a0,0
    8000355a:	00000097          	auipc	ra,0x0
    8000355e:	d54080e7          	jalr	-684(ra) # 800032ae <argint>
    80003562:	87aa                	mv	a5,a0
    return -1;
    80003564:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003566:	0007c863          	bltz	a5,80003576 <sys_kill+0x2a>
  return kill(pid);
    8000356a:	fec42503          	lw	a0,-20(s0)
    8000356e:	fffff097          	auipc	ra,0xfffff
    80003572:	47a080e7          	jalr	1146(ra) # 800029e8 <kill>
}
    80003576:	60e2                	ld	ra,24(sp)
    80003578:	6442                	ld	s0,16(sp)
    8000357a:	6105                	addi	sp,sp,32
    8000357c:	8082                	ret

000000008000357e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000357e:	1101                	addi	sp,sp,-32
    80003580:	ec06                	sd	ra,24(sp)
    80003582:	e822                	sd	s0,16(sp)
    80003584:	e426                	sd	s1,8(sp)
    80003586:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003588:	00022517          	auipc	a0,0x22
    8000358c:	94850513          	addi	a0,a0,-1720 # 80024ed0 <tickslock>
    80003590:	ffffd097          	auipc	ra,0xffffd
    80003594:	632080e7          	jalr	1586(ra) # 80000bc2 <acquire>
  xticks = ticks;
    80003598:	00007497          	auipc	s1,0x7
    8000359c:	a984a483          	lw	s1,-1384(s1) # 8000a030 <ticks>
  release(&tickslock);
    800035a0:	00022517          	auipc	a0,0x22
    800035a4:	93050513          	addi	a0,a0,-1744 # 80024ed0 <tickslock>
    800035a8:	ffffd097          	auipc	ra,0xffffd
    800035ac:	6ce080e7          	jalr	1742(ra) # 80000c76 <release>
  return xticks;
}
    800035b0:	02049513          	slli	a0,s1,0x20
    800035b4:	9101                	srli	a0,a0,0x20
    800035b6:	60e2                	ld	ra,24(sp)
    800035b8:	6442                	ld	s0,16(sp)
    800035ba:	64a2                	ld	s1,8(sp)
    800035bc:	6105                	addi	sp,sp,32
    800035be:	8082                	ret

00000000800035c0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800035c0:	7179                	addi	sp,sp,-48
    800035c2:	f406                	sd	ra,40(sp)
    800035c4:	f022                	sd	s0,32(sp)
    800035c6:	ec26                	sd	s1,24(sp)
    800035c8:	e84a                	sd	s2,16(sp)
    800035ca:	e44e                	sd	s3,8(sp)
    800035cc:	e052                	sd	s4,0(sp)
    800035ce:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800035d0:	00006597          	auipc	a1,0x6
    800035d4:	21858593          	addi	a1,a1,536 # 800097e8 <syscalls+0xb8>
    800035d8:	00022517          	auipc	a0,0x22
    800035dc:	91050513          	addi	a0,a0,-1776 # 80024ee8 <bcache>
    800035e0:	ffffd097          	auipc	ra,0xffffd
    800035e4:	552080e7          	jalr	1362(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800035e8:	0002a797          	auipc	a5,0x2a
    800035ec:	90078793          	addi	a5,a5,-1792 # 8002cee8 <bcache+0x8000>
    800035f0:	0002a717          	auipc	a4,0x2a
    800035f4:	b6070713          	addi	a4,a4,-1184 # 8002d150 <bcache+0x8268>
    800035f8:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800035fc:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003600:	00022497          	auipc	s1,0x22
    80003604:	90048493          	addi	s1,s1,-1792 # 80024f00 <bcache+0x18>
    b->next = bcache.head.next;
    80003608:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000360a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000360c:	00006a17          	auipc	s4,0x6
    80003610:	1e4a0a13          	addi	s4,s4,484 # 800097f0 <syscalls+0xc0>
    b->next = bcache.head.next;
    80003614:	2b893783          	ld	a5,696(s2)
    80003618:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000361a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000361e:	85d2                	mv	a1,s4
    80003620:	01048513          	addi	a0,s1,16
    80003624:	00001097          	auipc	ra,0x1
    80003628:	7fa080e7          	jalr	2042(ra) # 80004e1e <initsleeplock>
    bcache.head.next->prev = b;
    8000362c:	2b893783          	ld	a5,696(s2)
    80003630:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003632:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003636:	45848493          	addi	s1,s1,1112
    8000363a:	fd349de3          	bne	s1,s3,80003614 <binit+0x54>
  }
}
    8000363e:	70a2                	ld	ra,40(sp)
    80003640:	7402                	ld	s0,32(sp)
    80003642:	64e2                	ld	s1,24(sp)
    80003644:	6942                	ld	s2,16(sp)
    80003646:	69a2                	ld	s3,8(sp)
    80003648:	6a02                	ld	s4,0(sp)
    8000364a:	6145                	addi	sp,sp,48
    8000364c:	8082                	ret

000000008000364e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000364e:	7179                	addi	sp,sp,-48
    80003650:	f406                	sd	ra,40(sp)
    80003652:	f022                	sd	s0,32(sp)
    80003654:	ec26                	sd	s1,24(sp)
    80003656:	e84a                	sd	s2,16(sp)
    80003658:	e44e                	sd	s3,8(sp)
    8000365a:	1800                	addi	s0,sp,48
    8000365c:	892a                	mv	s2,a0
    8000365e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003660:	00022517          	auipc	a0,0x22
    80003664:	88850513          	addi	a0,a0,-1912 # 80024ee8 <bcache>
    80003668:	ffffd097          	auipc	ra,0xffffd
    8000366c:	55a080e7          	jalr	1370(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003670:	0002a497          	auipc	s1,0x2a
    80003674:	b304b483          	ld	s1,-1232(s1) # 8002d1a0 <bcache+0x82b8>
    80003678:	0002a797          	auipc	a5,0x2a
    8000367c:	ad878793          	addi	a5,a5,-1320 # 8002d150 <bcache+0x8268>
    80003680:	02f48f63          	beq	s1,a5,800036be <bread+0x70>
    80003684:	873e                	mv	a4,a5
    80003686:	a021                	j	8000368e <bread+0x40>
    80003688:	68a4                	ld	s1,80(s1)
    8000368a:	02e48a63          	beq	s1,a4,800036be <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000368e:	449c                	lw	a5,8(s1)
    80003690:	ff279ce3          	bne	a5,s2,80003688 <bread+0x3a>
    80003694:	44dc                	lw	a5,12(s1)
    80003696:	ff3799e3          	bne	a5,s3,80003688 <bread+0x3a>
      b->refcnt++;
    8000369a:	40bc                	lw	a5,64(s1)
    8000369c:	2785                	addiw	a5,a5,1
    8000369e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800036a0:	00022517          	auipc	a0,0x22
    800036a4:	84850513          	addi	a0,a0,-1976 # 80024ee8 <bcache>
    800036a8:	ffffd097          	auipc	ra,0xffffd
    800036ac:	5ce080e7          	jalr	1486(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    800036b0:	01048513          	addi	a0,s1,16
    800036b4:	00001097          	auipc	ra,0x1
    800036b8:	7a4080e7          	jalr	1956(ra) # 80004e58 <acquiresleep>
      return b;
    800036bc:	a8b9                	j	8000371a <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800036be:	0002a497          	auipc	s1,0x2a
    800036c2:	ada4b483          	ld	s1,-1318(s1) # 8002d198 <bcache+0x82b0>
    800036c6:	0002a797          	auipc	a5,0x2a
    800036ca:	a8a78793          	addi	a5,a5,-1398 # 8002d150 <bcache+0x8268>
    800036ce:	00f48863          	beq	s1,a5,800036de <bread+0x90>
    800036d2:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800036d4:	40bc                	lw	a5,64(s1)
    800036d6:	cf81                	beqz	a5,800036ee <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800036d8:	64a4                	ld	s1,72(s1)
    800036da:	fee49de3          	bne	s1,a4,800036d4 <bread+0x86>
  panic("bget: no buffers");
    800036de:	00006517          	auipc	a0,0x6
    800036e2:	11a50513          	addi	a0,a0,282 # 800097f8 <syscalls+0xc8>
    800036e6:	ffffd097          	auipc	ra,0xffffd
    800036ea:	e44080e7          	jalr	-444(ra) # 8000052a <panic>
      b->dev = dev;
    800036ee:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800036f2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800036f6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800036fa:	4785                	li	a5,1
    800036fc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800036fe:	00021517          	auipc	a0,0x21
    80003702:	7ea50513          	addi	a0,a0,2026 # 80024ee8 <bcache>
    80003706:	ffffd097          	auipc	ra,0xffffd
    8000370a:	570080e7          	jalr	1392(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    8000370e:	01048513          	addi	a0,s1,16
    80003712:	00001097          	auipc	ra,0x1
    80003716:	746080e7          	jalr	1862(ra) # 80004e58 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000371a:	409c                	lw	a5,0(s1)
    8000371c:	cb89                	beqz	a5,8000372e <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000371e:	8526                	mv	a0,s1
    80003720:	70a2                	ld	ra,40(sp)
    80003722:	7402                	ld	s0,32(sp)
    80003724:	64e2                	ld	s1,24(sp)
    80003726:	6942                	ld	s2,16(sp)
    80003728:	69a2                	ld	s3,8(sp)
    8000372a:	6145                	addi	sp,sp,48
    8000372c:	8082                	ret
    virtio_disk_rw(b, 0);
    8000372e:	4581                	li	a1,0
    80003730:	8526                	mv	a0,s1
    80003732:	00003097          	auipc	ra,0x3
    80003736:	5f4080e7          	jalr	1524(ra) # 80006d26 <virtio_disk_rw>
    b->valid = 1;
    8000373a:	4785                	li	a5,1
    8000373c:	c09c                	sw	a5,0(s1)
  return b;
    8000373e:	b7c5                	j	8000371e <bread+0xd0>

0000000080003740 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003740:	1101                	addi	sp,sp,-32
    80003742:	ec06                	sd	ra,24(sp)
    80003744:	e822                	sd	s0,16(sp)
    80003746:	e426                	sd	s1,8(sp)
    80003748:	1000                	addi	s0,sp,32
    8000374a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000374c:	0541                	addi	a0,a0,16
    8000374e:	00001097          	auipc	ra,0x1
    80003752:	7a4080e7          	jalr	1956(ra) # 80004ef2 <holdingsleep>
    80003756:	cd01                	beqz	a0,8000376e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003758:	4585                	li	a1,1
    8000375a:	8526                	mv	a0,s1
    8000375c:	00003097          	auipc	ra,0x3
    80003760:	5ca080e7          	jalr	1482(ra) # 80006d26 <virtio_disk_rw>
}
    80003764:	60e2                	ld	ra,24(sp)
    80003766:	6442                	ld	s0,16(sp)
    80003768:	64a2                	ld	s1,8(sp)
    8000376a:	6105                	addi	sp,sp,32
    8000376c:	8082                	ret
    panic("bwrite");
    8000376e:	00006517          	auipc	a0,0x6
    80003772:	0a250513          	addi	a0,a0,162 # 80009810 <syscalls+0xe0>
    80003776:	ffffd097          	auipc	ra,0xffffd
    8000377a:	db4080e7          	jalr	-588(ra) # 8000052a <panic>

000000008000377e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000377e:	1101                	addi	sp,sp,-32
    80003780:	ec06                	sd	ra,24(sp)
    80003782:	e822                	sd	s0,16(sp)
    80003784:	e426                	sd	s1,8(sp)
    80003786:	e04a                	sd	s2,0(sp)
    80003788:	1000                	addi	s0,sp,32
    8000378a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000378c:	01050913          	addi	s2,a0,16
    80003790:	854a                	mv	a0,s2
    80003792:	00001097          	auipc	ra,0x1
    80003796:	760080e7          	jalr	1888(ra) # 80004ef2 <holdingsleep>
    8000379a:	c92d                	beqz	a0,8000380c <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000379c:	854a                	mv	a0,s2
    8000379e:	00001097          	auipc	ra,0x1
    800037a2:	710080e7          	jalr	1808(ra) # 80004eae <releasesleep>

  acquire(&bcache.lock);
    800037a6:	00021517          	auipc	a0,0x21
    800037aa:	74250513          	addi	a0,a0,1858 # 80024ee8 <bcache>
    800037ae:	ffffd097          	auipc	ra,0xffffd
    800037b2:	414080e7          	jalr	1044(ra) # 80000bc2 <acquire>
  b->refcnt--;
    800037b6:	40bc                	lw	a5,64(s1)
    800037b8:	37fd                	addiw	a5,a5,-1
    800037ba:	0007871b          	sext.w	a4,a5
    800037be:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800037c0:	eb05                	bnez	a4,800037f0 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800037c2:	68bc                	ld	a5,80(s1)
    800037c4:	64b8                	ld	a4,72(s1)
    800037c6:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800037c8:	64bc                	ld	a5,72(s1)
    800037ca:	68b8                	ld	a4,80(s1)
    800037cc:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800037ce:	00029797          	auipc	a5,0x29
    800037d2:	71a78793          	addi	a5,a5,1818 # 8002cee8 <bcache+0x8000>
    800037d6:	2b87b703          	ld	a4,696(a5)
    800037da:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800037dc:	0002a717          	auipc	a4,0x2a
    800037e0:	97470713          	addi	a4,a4,-1676 # 8002d150 <bcache+0x8268>
    800037e4:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800037e6:	2b87b703          	ld	a4,696(a5)
    800037ea:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800037ec:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800037f0:	00021517          	auipc	a0,0x21
    800037f4:	6f850513          	addi	a0,a0,1784 # 80024ee8 <bcache>
    800037f8:	ffffd097          	auipc	ra,0xffffd
    800037fc:	47e080e7          	jalr	1150(ra) # 80000c76 <release>
}
    80003800:	60e2                	ld	ra,24(sp)
    80003802:	6442                	ld	s0,16(sp)
    80003804:	64a2                	ld	s1,8(sp)
    80003806:	6902                	ld	s2,0(sp)
    80003808:	6105                	addi	sp,sp,32
    8000380a:	8082                	ret
    panic("brelse");
    8000380c:	00006517          	auipc	a0,0x6
    80003810:	00c50513          	addi	a0,a0,12 # 80009818 <syscalls+0xe8>
    80003814:	ffffd097          	auipc	ra,0xffffd
    80003818:	d16080e7          	jalr	-746(ra) # 8000052a <panic>

000000008000381c <bpin>:

void
bpin(struct buf *b) {
    8000381c:	1101                	addi	sp,sp,-32
    8000381e:	ec06                	sd	ra,24(sp)
    80003820:	e822                	sd	s0,16(sp)
    80003822:	e426                	sd	s1,8(sp)
    80003824:	1000                	addi	s0,sp,32
    80003826:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003828:	00021517          	auipc	a0,0x21
    8000382c:	6c050513          	addi	a0,a0,1728 # 80024ee8 <bcache>
    80003830:	ffffd097          	auipc	ra,0xffffd
    80003834:	392080e7          	jalr	914(ra) # 80000bc2 <acquire>
  b->refcnt++;
    80003838:	40bc                	lw	a5,64(s1)
    8000383a:	2785                	addiw	a5,a5,1
    8000383c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000383e:	00021517          	auipc	a0,0x21
    80003842:	6aa50513          	addi	a0,a0,1706 # 80024ee8 <bcache>
    80003846:	ffffd097          	auipc	ra,0xffffd
    8000384a:	430080e7          	jalr	1072(ra) # 80000c76 <release>
}
    8000384e:	60e2                	ld	ra,24(sp)
    80003850:	6442                	ld	s0,16(sp)
    80003852:	64a2                	ld	s1,8(sp)
    80003854:	6105                	addi	sp,sp,32
    80003856:	8082                	ret

0000000080003858 <bunpin>:

void
bunpin(struct buf *b) {
    80003858:	1101                	addi	sp,sp,-32
    8000385a:	ec06                	sd	ra,24(sp)
    8000385c:	e822                	sd	s0,16(sp)
    8000385e:	e426                	sd	s1,8(sp)
    80003860:	1000                	addi	s0,sp,32
    80003862:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003864:	00021517          	auipc	a0,0x21
    80003868:	68450513          	addi	a0,a0,1668 # 80024ee8 <bcache>
    8000386c:	ffffd097          	auipc	ra,0xffffd
    80003870:	356080e7          	jalr	854(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003874:	40bc                	lw	a5,64(s1)
    80003876:	37fd                	addiw	a5,a5,-1
    80003878:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000387a:	00021517          	auipc	a0,0x21
    8000387e:	66e50513          	addi	a0,a0,1646 # 80024ee8 <bcache>
    80003882:	ffffd097          	auipc	ra,0xffffd
    80003886:	3f4080e7          	jalr	1012(ra) # 80000c76 <release>
}
    8000388a:	60e2                	ld	ra,24(sp)
    8000388c:	6442                	ld	s0,16(sp)
    8000388e:	64a2                	ld	s1,8(sp)
    80003890:	6105                	addi	sp,sp,32
    80003892:	8082                	ret

0000000080003894 <bfree>:
  }

  // Free a disk block.
  static void
  bfree(int dev, uint b)
  {
    80003894:	1101                	addi	sp,sp,-32
    80003896:	ec06                	sd	ra,24(sp)
    80003898:	e822                	sd	s0,16(sp)
    8000389a:	e426                	sd	s1,8(sp)
    8000389c:	e04a                	sd	s2,0(sp)
    8000389e:	1000                	addi	s0,sp,32
    800038a0:	84ae                	mv	s1,a1
    struct buf *bp;
    int bi, m;

    bp = bread(dev, BBLOCK(b, sb));
    800038a2:	00d5d59b          	srliw	a1,a1,0xd
    800038a6:	0002a797          	auipc	a5,0x2a
    800038aa:	d1e7a783          	lw	a5,-738(a5) # 8002d5c4 <sb+0x1c>
    800038ae:	9dbd                	addw	a1,a1,a5
    800038b0:	00000097          	auipc	ra,0x0
    800038b4:	d9e080e7          	jalr	-610(ra) # 8000364e <bread>
    bi = b % BPB;
    m = 1 << (bi % 8);
    800038b8:	0074f713          	andi	a4,s1,7
    800038bc:	4785                	li	a5,1
    800038be:	00e797bb          	sllw	a5,a5,a4
    if((bp->data[bi/8] & m) == 0)
    800038c2:	14ce                	slli	s1,s1,0x33
    800038c4:	90d9                	srli	s1,s1,0x36
    800038c6:	00950733          	add	a4,a0,s1
    800038ca:	05874703          	lbu	a4,88(a4)
    800038ce:	00e7f6b3          	and	a3,a5,a4
    800038d2:	c69d                	beqz	a3,80003900 <bfree+0x6c>
    800038d4:	892a                	mv	s2,a0
      panic("freeing free block");
    bp->data[bi/8] &= ~m;
    800038d6:	94aa                	add	s1,s1,a0
    800038d8:	fff7c793          	not	a5,a5
    800038dc:	8ff9                	and	a5,a5,a4
    800038de:	04f48c23          	sb	a5,88(s1)
    log_write(bp);
    800038e2:	00001097          	auipc	ra,0x1
    800038e6:	456080e7          	jalr	1110(ra) # 80004d38 <log_write>
    brelse(bp);
    800038ea:	854a                	mv	a0,s2
    800038ec:	00000097          	auipc	ra,0x0
    800038f0:	e92080e7          	jalr	-366(ra) # 8000377e <brelse>
  }
    800038f4:	60e2                	ld	ra,24(sp)
    800038f6:	6442                	ld	s0,16(sp)
    800038f8:	64a2                	ld	s1,8(sp)
    800038fa:	6902                	ld	s2,0(sp)
    800038fc:	6105                	addi	sp,sp,32
    800038fe:	8082                	ret
      panic("freeing free block");
    80003900:	00006517          	auipc	a0,0x6
    80003904:	f2050513          	addi	a0,a0,-224 # 80009820 <syscalls+0xf0>
    80003908:	ffffd097          	auipc	ra,0xffffd
    8000390c:	c22080e7          	jalr	-990(ra) # 8000052a <panic>

0000000080003910 <balloc>:
  {
    80003910:	711d                	addi	sp,sp,-96
    80003912:	ec86                	sd	ra,88(sp)
    80003914:	e8a2                	sd	s0,80(sp)
    80003916:	e4a6                	sd	s1,72(sp)
    80003918:	e0ca                	sd	s2,64(sp)
    8000391a:	fc4e                	sd	s3,56(sp)
    8000391c:	f852                	sd	s4,48(sp)
    8000391e:	f456                	sd	s5,40(sp)
    80003920:	f05a                	sd	s6,32(sp)
    80003922:	ec5e                	sd	s7,24(sp)
    80003924:	e862                	sd	s8,16(sp)
    80003926:	e466                	sd	s9,8(sp)
    80003928:	1080                	addi	s0,sp,96
    for(b = 0; b < sb.size; b += BPB){
    8000392a:	0002a797          	auipc	a5,0x2a
    8000392e:	c827a783          	lw	a5,-894(a5) # 8002d5ac <sb+0x4>
    80003932:	cbd1                	beqz	a5,800039c6 <balloc+0xb6>
    80003934:	8baa                	mv	s7,a0
    80003936:	4a81                	li	s5,0
      bp = bread(dev, BBLOCK(b, sb));
    80003938:	0002ab17          	auipc	s6,0x2a
    8000393c:	c70b0b13          	addi	s6,s6,-912 # 8002d5a8 <sb>
      for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003940:	4c01                	li	s8,0
        m = 1 << (bi % 8);
    80003942:	4985                	li	s3,1
      for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003944:	6a09                	lui	s4,0x2
    for(b = 0; b < sb.size; b += BPB){
    80003946:	6c89                	lui	s9,0x2
    80003948:	a831                	j	80003964 <balloc+0x54>
      brelse(bp);
    8000394a:	854a                	mv	a0,s2
    8000394c:	00000097          	auipc	ra,0x0
    80003950:	e32080e7          	jalr	-462(ra) # 8000377e <brelse>
    for(b = 0; b < sb.size; b += BPB){
    80003954:	015c87bb          	addw	a5,s9,s5
    80003958:	00078a9b          	sext.w	s5,a5
    8000395c:	004b2703          	lw	a4,4(s6)
    80003960:	06eaf363          	bgeu	s5,a4,800039c6 <balloc+0xb6>
      bp = bread(dev, BBLOCK(b, sb));
    80003964:	41fad79b          	sraiw	a5,s5,0x1f
    80003968:	0137d79b          	srliw	a5,a5,0x13
    8000396c:	015787bb          	addw	a5,a5,s5
    80003970:	40d7d79b          	sraiw	a5,a5,0xd
    80003974:	01cb2583          	lw	a1,28(s6)
    80003978:	9dbd                	addw	a1,a1,a5
    8000397a:	855e                	mv	a0,s7
    8000397c:	00000097          	auipc	ra,0x0
    80003980:	cd2080e7          	jalr	-814(ra) # 8000364e <bread>
    80003984:	892a                	mv	s2,a0
      for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003986:	004b2503          	lw	a0,4(s6)
    8000398a:	000a849b          	sext.w	s1,s5
    8000398e:	8662                	mv	a2,s8
    80003990:	faa4fde3          	bgeu	s1,a0,8000394a <balloc+0x3a>
        m = 1 << (bi % 8);
    80003994:	41f6579b          	sraiw	a5,a2,0x1f
    80003998:	01d7d69b          	srliw	a3,a5,0x1d
    8000399c:	00c6873b          	addw	a4,a3,a2
    800039a0:	00777793          	andi	a5,a4,7
    800039a4:	9f95                	subw	a5,a5,a3
    800039a6:	00f997bb          	sllw	a5,s3,a5
        if((bp->data[bi/8] & m) == 0){  // Is block free?
    800039aa:	4037571b          	sraiw	a4,a4,0x3
    800039ae:	00e906b3          	add	a3,s2,a4
    800039b2:	0586c683          	lbu	a3,88(a3)
    800039b6:	00d7f5b3          	and	a1,a5,a3
    800039ba:	cd91                	beqz	a1,800039d6 <balloc+0xc6>
      for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800039bc:	2605                	addiw	a2,a2,1
    800039be:	2485                	addiw	s1,s1,1
    800039c0:	fd4618e3          	bne	a2,s4,80003990 <balloc+0x80>
    800039c4:	b759                	j	8000394a <balloc+0x3a>
    panic("balloc: out of blocks");
    800039c6:	00006517          	auipc	a0,0x6
    800039ca:	e7250513          	addi	a0,a0,-398 # 80009838 <syscalls+0x108>
    800039ce:	ffffd097          	auipc	ra,0xffffd
    800039d2:	b5c080e7          	jalr	-1188(ra) # 8000052a <panic>
          bp->data[bi/8] |= m;  // Mark block in use.
    800039d6:	974a                	add	a4,a4,s2
    800039d8:	8fd5                	or	a5,a5,a3
    800039da:	04f70c23          	sb	a5,88(a4)
          log_write(bp);
    800039de:	854a                	mv	a0,s2
    800039e0:	00001097          	auipc	ra,0x1
    800039e4:	358080e7          	jalr	856(ra) # 80004d38 <log_write>
          brelse(bp);
    800039e8:	854a                	mv	a0,s2
    800039ea:	00000097          	auipc	ra,0x0
    800039ee:	d94080e7          	jalr	-620(ra) # 8000377e <brelse>
    bp = bread(dev, bno);
    800039f2:	85a6                	mv	a1,s1
    800039f4:	855e                	mv	a0,s7
    800039f6:	00000097          	auipc	ra,0x0
    800039fa:	c58080e7          	jalr	-936(ra) # 8000364e <bread>
    800039fe:	892a                	mv	s2,a0
    memset(bp->data, 0, BSIZE);
    80003a00:	40000613          	li	a2,1024
    80003a04:	4581                	li	a1,0
    80003a06:	05850513          	addi	a0,a0,88
    80003a0a:	ffffd097          	auipc	ra,0xffffd
    80003a0e:	2b4080e7          	jalr	692(ra) # 80000cbe <memset>
    log_write(bp);
    80003a12:	854a                	mv	a0,s2
    80003a14:	00001097          	auipc	ra,0x1
    80003a18:	324080e7          	jalr	804(ra) # 80004d38 <log_write>
    brelse(bp);
    80003a1c:	854a                	mv	a0,s2
    80003a1e:	00000097          	auipc	ra,0x0
    80003a22:	d60080e7          	jalr	-672(ra) # 8000377e <brelse>
  }
    80003a26:	8526                	mv	a0,s1
    80003a28:	60e6                	ld	ra,88(sp)
    80003a2a:	6446                	ld	s0,80(sp)
    80003a2c:	64a6                	ld	s1,72(sp)
    80003a2e:	6906                	ld	s2,64(sp)
    80003a30:	79e2                	ld	s3,56(sp)
    80003a32:	7a42                	ld	s4,48(sp)
    80003a34:	7aa2                	ld	s5,40(sp)
    80003a36:	7b02                	ld	s6,32(sp)
    80003a38:	6be2                	ld	s7,24(sp)
    80003a3a:	6c42                	ld	s8,16(sp)
    80003a3c:	6ca2                	ld	s9,8(sp)
    80003a3e:	6125                	addi	sp,sp,96
    80003a40:	8082                	ret

0000000080003a42 <bmap>:

  // Return the disk block address of the nth block in inode ip.
  // If there is no such block, bmap allocates one.
  static uint
  bmap(struct inode *ip, uint bn)
  {
    80003a42:	7179                	addi	sp,sp,-48
    80003a44:	f406                	sd	ra,40(sp)
    80003a46:	f022                	sd	s0,32(sp)
    80003a48:	ec26                	sd	s1,24(sp)
    80003a4a:	e84a                	sd	s2,16(sp)
    80003a4c:	e44e                	sd	s3,8(sp)
    80003a4e:	e052                	sd	s4,0(sp)
    80003a50:	1800                	addi	s0,sp,48
    80003a52:	892a                	mv	s2,a0
    uint addr, *a;
    struct buf *bp;

    if(bn < NDIRECT){
    80003a54:	47ad                	li	a5,11
    80003a56:	04b7fe63          	bgeu	a5,a1,80003ab2 <bmap+0x70>
      if((addr = ip->addrs[bn]) == 0)
        ip->addrs[bn] = addr = balloc(ip->dev);
      return addr;
    }
    bn -= NDIRECT;
    80003a5a:	ff45849b          	addiw	s1,a1,-12
    80003a5e:	0004871b          	sext.w	a4,s1

    if(bn < NINDIRECT){
    80003a62:	0ff00793          	li	a5,255
    80003a66:	0ae7e463          	bltu	a5,a4,80003b0e <bmap+0xcc>
      // Load indirect block, allocating if necessary.
      if((addr = ip->addrs[NDIRECT]) == 0)
    80003a6a:	08052583          	lw	a1,128(a0)
    80003a6e:	c5b5                	beqz	a1,80003ada <bmap+0x98>
        ip->addrs[NDIRECT] = addr = balloc(ip->dev);
      bp = bread(ip->dev, addr);
    80003a70:	00092503          	lw	a0,0(s2)
    80003a74:	00000097          	auipc	ra,0x0
    80003a78:	bda080e7          	jalr	-1062(ra) # 8000364e <bread>
    80003a7c:	8a2a                	mv	s4,a0
      a = (uint*)bp->data;
    80003a7e:	05850793          	addi	a5,a0,88
      if((addr = a[bn]) == 0){
    80003a82:	02049713          	slli	a4,s1,0x20
    80003a86:	01e75593          	srli	a1,a4,0x1e
    80003a8a:	00b784b3          	add	s1,a5,a1
    80003a8e:	0004a983          	lw	s3,0(s1)
    80003a92:	04098e63          	beqz	s3,80003aee <bmap+0xac>
        a[bn] = addr = balloc(ip->dev);
        log_write(bp);
      }
      brelse(bp);
    80003a96:	8552                	mv	a0,s4
    80003a98:	00000097          	auipc	ra,0x0
    80003a9c:	ce6080e7          	jalr	-794(ra) # 8000377e <brelse>
      return addr;
    }

    panic("bmap: out of range");
  }
    80003aa0:	854e                	mv	a0,s3
    80003aa2:	70a2                	ld	ra,40(sp)
    80003aa4:	7402                	ld	s0,32(sp)
    80003aa6:	64e2                	ld	s1,24(sp)
    80003aa8:	6942                	ld	s2,16(sp)
    80003aaa:	69a2                	ld	s3,8(sp)
    80003aac:	6a02                	ld	s4,0(sp)
    80003aae:	6145                	addi	sp,sp,48
    80003ab0:	8082                	ret
      if((addr = ip->addrs[bn]) == 0)
    80003ab2:	02059793          	slli	a5,a1,0x20
    80003ab6:	01e7d593          	srli	a1,a5,0x1e
    80003aba:	00b504b3          	add	s1,a0,a1
    80003abe:	0504a983          	lw	s3,80(s1)
    80003ac2:	fc099fe3          	bnez	s3,80003aa0 <bmap+0x5e>
        ip->addrs[bn] = addr = balloc(ip->dev);
    80003ac6:	4108                	lw	a0,0(a0)
    80003ac8:	00000097          	auipc	ra,0x0
    80003acc:	e48080e7          	jalr	-440(ra) # 80003910 <balloc>
    80003ad0:	0005099b          	sext.w	s3,a0
    80003ad4:	0534a823          	sw	s3,80(s1)
    80003ad8:	b7e1                	j	80003aa0 <bmap+0x5e>
        ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003ada:	4108                	lw	a0,0(a0)
    80003adc:	00000097          	auipc	ra,0x0
    80003ae0:	e34080e7          	jalr	-460(ra) # 80003910 <balloc>
    80003ae4:	0005059b          	sext.w	a1,a0
    80003ae8:	08b92023          	sw	a1,128(s2)
    80003aec:	b751                	j	80003a70 <bmap+0x2e>
        a[bn] = addr = balloc(ip->dev);
    80003aee:	00092503          	lw	a0,0(s2)
    80003af2:	00000097          	auipc	ra,0x0
    80003af6:	e1e080e7          	jalr	-482(ra) # 80003910 <balloc>
    80003afa:	0005099b          	sext.w	s3,a0
    80003afe:	0134a023          	sw	s3,0(s1)
        log_write(bp);
    80003b02:	8552                	mv	a0,s4
    80003b04:	00001097          	auipc	ra,0x1
    80003b08:	234080e7          	jalr	564(ra) # 80004d38 <log_write>
    80003b0c:	b769                	j	80003a96 <bmap+0x54>
    panic("bmap: out of range");
    80003b0e:	00006517          	auipc	a0,0x6
    80003b12:	d4250513          	addi	a0,a0,-702 # 80009850 <syscalls+0x120>
    80003b16:	ffffd097          	auipc	ra,0xffffd
    80003b1a:	a14080e7          	jalr	-1516(ra) # 8000052a <panic>

0000000080003b1e <iget>:
  {
    80003b1e:	7179                	addi	sp,sp,-48
    80003b20:	f406                	sd	ra,40(sp)
    80003b22:	f022                	sd	s0,32(sp)
    80003b24:	ec26                	sd	s1,24(sp)
    80003b26:	e84a                	sd	s2,16(sp)
    80003b28:	e44e                	sd	s3,8(sp)
    80003b2a:	e052                	sd	s4,0(sp)
    80003b2c:	1800                	addi	s0,sp,48
    80003b2e:	89aa                	mv	s3,a0
    80003b30:	8a2e                	mv	s4,a1
    acquire(&itable.lock);
    80003b32:	0002a517          	auipc	a0,0x2a
    80003b36:	a9650513          	addi	a0,a0,-1386 # 8002d5c8 <itable>
    80003b3a:	ffffd097          	auipc	ra,0xffffd
    80003b3e:	088080e7          	jalr	136(ra) # 80000bc2 <acquire>
    empty = 0;
    80003b42:	4901                	li	s2,0
    for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003b44:	0002a497          	auipc	s1,0x2a
    80003b48:	a9c48493          	addi	s1,s1,-1380 # 8002d5e0 <itable+0x18>
    80003b4c:	0002b697          	auipc	a3,0x2b
    80003b50:	52468693          	addi	a3,a3,1316 # 8002f070 <log>
    80003b54:	a039                	j	80003b62 <iget+0x44>
      if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003b56:	02090b63          	beqz	s2,80003b8c <iget+0x6e>
    for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003b5a:	08848493          	addi	s1,s1,136
    80003b5e:	02d48a63          	beq	s1,a3,80003b92 <iget+0x74>
      if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003b62:	449c                	lw	a5,8(s1)
    80003b64:	fef059e3          	blez	a5,80003b56 <iget+0x38>
    80003b68:	4098                	lw	a4,0(s1)
    80003b6a:	ff3716e3          	bne	a4,s3,80003b56 <iget+0x38>
    80003b6e:	40d8                	lw	a4,4(s1)
    80003b70:	ff4713e3          	bne	a4,s4,80003b56 <iget+0x38>
        ip->ref++;
    80003b74:	2785                	addiw	a5,a5,1
    80003b76:	c49c                	sw	a5,8(s1)
        release(&itable.lock);
    80003b78:	0002a517          	auipc	a0,0x2a
    80003b7c:	a5050513          	addi	a0,a0,-1456 # 8002d5c8 <itable>
    80003b80:	ffffd097          	auipc	ra,0xffffd
    80003b84:	0f6080e7          	jalr	246(ra) # 80000c76 <release>
        return ip;
    80003b88:	8926                	mv	s2,s1
    80003b8a:	a03d                	j	80003bb8 <iget+0x9a>
      if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003b8c:	f7f9                	bnez	a5,80003b5a <iget+0x3c>
    80003b8e:	8926                	mv	s2,s1
    80003b90:	b7e9                	j	80003b5a <iget+0x3c>
    if(empty == 0)
    80003b92:	02090c63          	beqz	s2,80003bca <iget+0xac>
    ip->dev = dev;
    80003b96:	01392023          	sw	s3,0(s2)
    ip->inum = inum;
    80003b9a:	01492223          	sw	s4,4(s2)
    ip->ref = 1;
    80003b9e:	4785                	li	a5,1
    80003ba0:	00f92423          	sw	a5,8(s2)
    ip->valid = 0;
    80003ba4:	04092023          	sw	zero,64(s2)
    release(&itable.lock);
    80003ba8:	0002a517          	auipc	a0,0x2a
    80003bac:	a2050513          	addi	a0,a0,-1504 # 8002d5c8 <itable>
    80003bb0:	ffffd097          	auipc	ra,0xffffd
    80003bb4:	0c6080e7          	jalr	198(ra) # 80000c76 <release>
  }
    80003bb8:	854a                	mv	a0,s2
    80003bba:	70a2                	ld	ra,40(sp)
    80003bbc:	7402                	ld	s0,32(sp)
    80003bbe:	64e2                	ld	s1,24(sp)
    80003bc0:	6942                	ld	s2,16(sp)
    80003bc2:	69a2                	ld	s3,8(sp)
    80003bc4:	6a02                	ld	s4,0(sp)
    80003bc6:	6145                	addi	sp,sp,48
    80003bc8:	8082                	ret
      panic("iget: no inodes");
    80003bca:	00006517          	auipc	a0,0x6
    80003bce:	c9e50513          	addi	a0,a0,-866 # 80009868 <syscalls+0x138>
    80003bd2:	ffffd097          	auipc	ra,0xffffd
    80003bd6:	958080e7          	jalr	-1704(ra) # 8000052a <panic>

0000000080003bda <fsinit>:
  fsinit(int dev) {
    80003bda:	7179                	addi	sp,sp,-48
    80003bdc:	f406                	sd	ra,40(sp)
    80003bde:	f022                	sd	s0,32(sp)
    80003be0:	ec26                	sd	s1,24(sp)
    80003be2:	e84a                	sd	s2,16(sp)
    80003be4:	e44e                	sd	s3,8(sp)
    80003be6:	1800                	addi	s0,sp,48
    80003be8:	892a                	mv	s2,a0
    bp = bread(dev, 1);
    80003bea:	4585                	li	a1,1
    80003bec:	00000097          	auipc	ra,0x0
    80003bf0:	a62080e7          	jalr	-1438(ra) # 8000364e <bread>
    80003bf4:	84aa                	mv	s1,a0
    memmove(sb, bp->data, sizeof(*sb));
    80003bf6:	0002a997          	auipc	s3,0x2a
    80003bfa:	9b298993          	addi	s3,s3,-1614 # 8002d5a8 <sb>
    80003bfe:	02000613          	li	a2,32
    80003c02:	05850593          	addi	a1,a0,88
    80003c06:	854e                	mv	a0,s3
    80003c08:	ffffd097          	auipc	ra,0xffffd
    80003c0c:	112080e7          	jalr	274(ra) # 80000d1a <memmove>
    brelse(bp);
    80003c10:	8526                	mv	a0,s1
    80003c12:	00000097          	auipc	ra,0x0
    80003c16:	b6c080e7          	jalr	-1172(ra) # 8000377e <brelse>
    if(sb.magic != FSMAGIC)
    80003c1a:	0009a703          	lw	a4,0(s3)
    80003c1e:	102037b7          	lui	a5,0x10203
    80003c22:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003c26:	02f71263          	bne	a4,a5,80003c4a <fsinit+0x70>
    initlog(dev, &sb);
    80003c2a:	0002a597          	auipc	a1,0x2a
    80003c2e:	97e58593          	addi	a1,a1,-1666 # 8002d5a8 <sb>
    80003c32:	854a                	mv	a0,s2
    80003c34:	00001097          	auipc	ra,0x1
    80003c38:	e86080e7          	jalr	-378(ra) # 80004aba <initlog>
  }
    80003c3c:	70a2                	ld	ra,40(sp)
    80003c3e:	7402                	ld	s0,32(sp)
    80003c40:	64e2                	ld	s1,24(sp)
    80003c42:	6942                	ld	s2,16(sp)
    80003c44:	69a2                	ld	s3,8(sp)
    80003c46:	6145                	addi	sp,sp,48
    80003c48:	8082                	ret
      panic("invalid file system");
    80003c4a:	00006517          	auipc	a0,0x6
    80003c4e:	c2e50513          	addi	a0,a0,-978 # 80009878 <syscalls+0x148>
    80003c52:	ffffd097          	auipc	ra,0xffffd
    80003c56:	8d8080e7          	jalr	-1832(ra) # 8000052a <panic>

0000000080003c5a <iinit>:
  {
    80003c5a:	7179                	addi	sp,sp,-48
    80003c5c:	f406                	sd	ra,40(sp)
    80003c5e:	f022                	sd	s0,32(sp)
    80003c60:	ec26                	sd	s1,24(sp)
    80003c62:	e84a                	sd	s2,16(sp)
    80003c64:	e44e                	sd	s3,8(sp)
    80003c66:	1800                	addi	s0,sp,48
    initlock(&itable.lock, "itable");
    80003c68:	00006597          	auipc	a1,0x6
    80003c6c:	c2858593          	addi	a1,a1,-984 # 80009890 <syscalls+0x160>
    80003c70:	0002a517          	auipc	a0,0x2a
    80003c74:	95850513          	addi	a0,a0,-1704 # 8002d5c8 <itable>
    80003c78:	ffffd097          	auipc	ra,0xffffd
    80003c7c:	eba080e7          	jalr	-326(ra) # 80000b32 <initlock>
    for(i = 0; i < NINODE; i++) {
    80003c80:	0002a497          	auipc	s1,0x2a
    80003c84:	97048493          	addi	s1,s1,-1680 # 8002d5f0 <itable+0x28>
    80003c88:	0002b997          	auipc	s3,0x2b
    80003c8c:	3f898993          	addi	s3,s3,1016 # 8002f080 <log+0x10>
      initsleeplock(&itable.inode[i].lock, "inode");
    80003c90:	00006917          	auipc	s2,0x6
    80003c94:	c0890913          	addi	s2,s2,-1016 # 80009898 <syscalls+0x168>
    80003c98:	85ca                	mv	a1,s2
    80003c9a:	8526                	mv	a0,s1
    80003c9c:	00001097          	auipc	ra,0x1
    80003ca0:	182080e7          	jalr	386(ra) # 80004e1e <initsleeplock>
    for(i = 0; i < NINODE; i++) {
    80003ca4:	08848493          	addi	s1,s1,136
    80003ca8:	ff3498e3          	bne	s1,s3,80003c98 <iinit+0x3e>
  }
    80003cac:	70a2                	ld	ra,40(sp)
    80003cae:	7402                	ld	s0,32(sp)
    80003cb0:	64e2                	ld	s1,24(sp)
    80003cb2:	6942                	ld	s2,16(sp)
    80003cb4:	69a2                	ld	s3,8(sp)
    80003cb6:	6145                	addi	sp,sp,48
    80003cb8:	8082                	ret

0000000080003cba <ialloc>:
  {
    80003cba:	715d                	addi	sp,sp,-80
    80003cbc:	e486                	sd	ra,72(sp)
    80003cbe:	e0a2                	sd	s0,64(sp)
    80003cc0:	fc26                	sd	s1,56(sp)
    80003cc2:	f84a                	sd	s2,48(sp)
    80003cc4:	f44e                	sd	s3,40(sp)
    80003cc6:	f052                	sd	s4,32(sp)
    80003cc8:	ec56                	sd	s5,24(sp)
    80003cca:	e85a                	sd	s6,16(sp)
    80003ccc:	e45e                	sd	s7,8(sp)
    80003cce:	0880                	addi	s0,sp,80
    for(inum = 1; inum < sb.ninodes; inum++){
    80003cd0:	0002a717          	auipc	a4,0x2a
    80003cd4:	8e472703          	lw	a4,-1820(a4) # 8002d5b4 <sb+0xc>
    80003cd8:	4785                	li	a5,1
    80003cda:	04e7fa63          	bgeu	a5,a4,80003d2e <ialloc+0x74>
    80003cde:	8aaa                	mv	s5,a0
    80003ce0:	8bae                	mv	s7,a1
    80003ce2:	4485                	li	s1,1
      bp = bread(dev, IBLOCK(inum, sb));
    80003ce4:	0002aa17          	auipc	s4,0x2a
    80003ce8:	8c4a0a13          	addi	s4,s4,-1852 # 8002d5a8 <sb>
    80003cec:	00048b1b          	sext.w	s6,s1
    80003cf0:	0044d793          	srli	a5,s1,0x4
    80003cf4:	018a2583          	lw	a1,24(s4)
    80003cf8:	9dbd                	addw	a1,a1,a5
    80003cfa:	8556                	mv	a0,s5
    80003cfc:	00000097          	auipc	ra,0x0
    80003d00:	952080e7          	jalr	-1710(ra) # 8000364e <bread>
    80003d04:	892a                	mv	s2,a0
      dip = (struct dinode*)bp->data + inum%IPB;
    80003d06:	05850993          	addi	s3,a0,88
    80003d0a:	00f4f793          	andi	a5,s1,15
    80003d0e:	079a                	slli	a5,a5,0x6
    80003d10:	99be                	add	s3,s3,a5
      if(dip->type == 0){  // a free inode
    80003d12:	00099783          	lh	a5,0(s3)
    80003d16:	c785                	beqz	a5,80003d3e <ialloc+0x84>
      brelse(bp);
    80003d18:	00000097          	auipc	ra,0x0
    80003d1c:	a66080e7          	jalr	-1434(ra) # 8000377e <brelse>
    for(inum = 1; inum < sb.ninodes; inum++){
    80003d20:	0485                	addi	s1,s1,1
    80003d22:	00ca2703          	lw	a4,12(s4)
    80003d26:	0004879b          	sext.w	a5,s1
    80003d2a:	fce7e1e3          	bltu	a5,a4,80003cec <ialloc+0x32>
    panic("ialloc: no inodes");
    80003d2e:	00006517          	auipc	a0,0x6
    80003d32:	b7250513          	addi	a0,a0,-1166 # 800098a0 <syscalls+0x170>
    80003d36:	ffffc097          	auipc	ra,0xffffc
    80003d3a:	7f4080e7          	jalr	2036(ra) # 8000052a <panic>
        memset(dip, 0, sizeof(*dip));
    80003d3e:	04000613          	li	a2,64
    80003d42:	4581                	li	a1,0
    80003d44:	854e                	mv	a0,s3
    80003d46:	ffffd097          	auipc	ra,0xffffd
    80003d4a:	f78080e7          	jalr	-136(ra) # 80000cbe <memset>
        dip->type = type;
    80003d4e:	01799023          	sh	s7,0(s3)
        log_write(bp);   // mark it allocated on the disk
    80003d52:	854a                	mv	a0,s2
    80003d54:	00001097          	auipc	ra,0x1
    80003d58:	fe4080e7          	jalr	-28(ra) # 80004d38 <log_write>
        brelse(bp);
    80003d5c:	854a                	mv	a0,s2
    80003d5e:	00000097          	auipc	ra,0x0
    80003d62:	a20080e7          	jalr	-1504(ra) # 8000377e <brelse>
        return iget(dev, inum);
    80003d66:	85da                	mv	a1,s6
    80003d68:	8556                	mv	a0,s5
    80003d6a:	00000097          	auipc	ra,0x0
    80003d6e:	db4080e7          	jalr	-588(ra) # 80003b1e <iget>
  }
    80003d72:	60a6                	ld	ra,72(sp)
    80003d74:	6406                	ld	s0,64(sp)
    80003d76:	74e2                	ld	s1,56(sp)
    80003d78:	7942                	ld	s2,48(sp)
    80003d7a:	79a2                	ld	s3,40(sp)
    80003d7c:	7a02                	ld	s4,32(sp)
    80003d7e:	6ae2                	ld	s5,24(sp)
    80003d80:	6b42                	ld	s6,16(sp)
    80003d82:	6ba2                	ld	s7,8(sp)
    80003d84:	6161                	addi	sp,sp,80
    80003d86:	8082                	ret

0000000080003d88 <iupdate>:
  {
    80003d88:	1101                	addi	sp,sp,-32
    80003d8a:	ec06                	sd	ra,24(sp)
    80003d8c:	e822                	sd	s0,16(sp)
    80003d8e:	e426                	sd	s1,8(sp)
    80003d90:	e04a                	sd	s2,0(sp)
    80003d92:	1000                	addi	s0,sp,32
    80003d94:	84aa                	mv	s1,a0
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d96:	415c                	lw	a5,4(a0)
    80003d98:	0047d79b          	srliw	a5,a5,0x4
    80003d9c:	0002a597          	auipc	a1,0x2a
    80003da0:	8245a583          	lw	a1,-2012(a1) # 8002d5c0 <sb+0x18>
    80003da4:	9dbd                	addw	a1,a1,a5
    80003da6:	4108                	lw	a0,0(a0)
    80003da8:	00000097          	auipc	ra,0x0
    80003dac:	8a6080e7          	jalr	-1882(ra) # 8000364e <bread>
    80003db0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003db2:	05850793          	addi	a5,a0,88
    80003db6:	40c8                	lw	a0,4(s1)
    80003db8:	893d                	andi	a0,a0,15
    80003dba:	051a                	slli	a0,a0,0x6
    80003dbc:	953e                	add	a0,a0,a5
    dip->type = ip->type;
    80003dbe:	04449703          	lh	a4,68(s1)
    80003dc2:	00e51023          	sh	a4,0(a0)
    dip->major = ip->major;
    80003dc6:	04649703          	lh	a4,70(s1)
    80003dca:	00e51123          	sh	a4,2(a0)
    dip->minor = ip->minor;
    80003dce:	04849703          	lh	a4,72(s1)
    80003dd2:	00e51223          	sh	a4,4(a0)
    dip->nlink = ip->nlink;
    80003dd6:	04a49703          	lh	a4,74(s1)
    80003dda:	00e51323          	sh	a4,6(a0)
    dip->size = ip->size;
    80003dde:	44f8                	lw	a4,76(s1)
    80003de0:	c518                	sw	a4,8(a0)
    memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003de2:	03400613          	li	a2,52
    80003de6:	05048593          	addi	a1,s1,80
    80003dea:	0531                	addi	a0,a0,12
    80003dec:	ffffd097          	auipc	ra,0xffffd
    80003df0:	f2e080e7          	jalr	-210(ra) # 80000d1a <memmove>
    log_write(bp);
    80003df4:	854a                	mv	a0,s2
    80003df6:	00001097          	auipc	ra,0x1
    80003dfa:	f42080e7          	jalr	-190(ra) # 80004d38 <log_write>
    brelse(bp);
    80003dfe:	854a                	mv	a0,s2
    80003e00:	00000097          	auipc	ra,0x0
    80003e04:	97e080e7          	jalr	-1666(ra) # 8000377e <brelse>
  }
    80003e08:	60e2                	ld	ra,24(sp)
    80003e0a:	6442                	ld	s0,16(sp)
    80003e0c:	64a2                	ld	s1,8(sp)
    80003e0e:	6902                	ld	s2,0(sp)
    80003e10:	6105                	addi	sp,sp,32
    80003e12:	8082                	ret

0000000080003e14 <idup>:
  {
    80003e14:	1101                	addi	sp,sp,-32
    80003e16:	ec06                	sd	ra,24(sp)
    80003e18:	e822                	sd	s0,16(sp)
    80003e1a:	e426                	sd	s1,8(sp)
    80003e1c:	1000                	addi	s0,sp,32
    80003e1e:	84aa                	mv	s1,a0
    acquire(&itable.lock);
    80003e20:	00029517          	auipc	a0,0x29
    80003e24:	7a850513          	addi	a0,a0,1960 # 8002d5c8 <itable>
    80003e28:	ffffd097          	auipc	ra,0xffffd
    80003e2c:	d9a080e7          	jalr	-614(ra) # 80000bc2 <acquire>
    ip->ref++;
    80003e30:	449c                	lw	a5,8(s1)
    80003e32:	2785                	addiw	a5,a5,1
    80003e34:	c49c                	sw	a5,8(s1)
    release(&itable.lock);
    80003e36:	00029517          	auipc	a0,0x29
    80003e3a:	79250513          	addi	a0,a0,1938 # 8002d5c8 <itable>
    80003e3e:	ffffd097          	auipc	ra,0xffffd
    80003e42:	e38080e7          	jalr	-456(ra) # 80000c76 <release>
  }
    80003e46:	8526                	mv	a0,s1
    80003e48:	60e2                	ld	ra,24(sp)
    80003e4a:	6442                	ld	s0,16(sp)
    80003e4c:	64a2                	ld	s1,8(sp)
    80003e4e:	6105                	addi	sp,sp,32
    80003e50:	8082                	ret

0000000080003e52 <ilock>:
  {
    80003e52:	1101                	addi	sp,sp,-32
    80003e54:	ec06                	sd	ra,24(sp)
    80003e56:	e822                	sd	s0,16(sp)
    80003e58:	e426                	sd	s1,8(sp)
    80003e5a:	e04a                	sd	s2,0(sp)
    80003e5c:	1000                	addi	s0,sp,32
    if(ip == 0 || ip->ref < 1)
    80003e5e:	c115                	beqz	a0,80003e82 <ilock+0x30>
    80003e60:	84aa                	mv	s1,a0
    80003e62:	451c                	lw	a5,8(a0)
    80003e64:	00f05f63          	blez	a5,80003e82 <ilock+0x30>
    acquiresleep(&ip->lock);
    80003e68:	0541                	addi	a0,a0,16
    80003e6a:	00001097          	auipc	ra,0x1
    80003e6e:	fee080e7          	jalr	-18(ra) # 80004e58 <acquiresleep>
    if(ip->valid == 0){
    80003e72:	40bc                	lw	a5,64(s1)
    80003e74:	cf99                	beqz	a5,80003e92 <ilock+0x40>
  }
    80003e76:	60e2                	ld	ra,24(sp)
    80003e78:	6442                	ld	s0,16(sp)
    80003e7a:	64a2                	ld	s1,8(sp)
    80003e7c:	6902                	ld	s2,0(sp)
    80003e7e:	6105                	addi	sp,sp,32
    80003e80:	8082                	ret
      panic("ilock");
    80003e82:	00006517          	auipc	a0,0x6
    80003e86:	a3650513          	addi	a0,a0,-1482 # 800098b8 <syscalls+0x188>
    80003e8a:	ffffc097          	auipc	ra,0xffffc
    80003e8e:	6a0080e7          	jalr	1696(ra) # 8000052a <panic>
      bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e92:	40dc                	lw	a5,4(s1)
    80003e94:	0047d79b          	srliw	a5,a5,0x4
    80003e98:	00029597          	auipc	a1,0x29
    80003e9c:	7285a583          	lw	a1,1832(a1) # 8002d5c0 <sb+0x18>
    80003ea0:	9dbd                	addw	a1,a1,a5
    80003ea2:	4088                	lw	a0,0(s1)
    80003ea4:	fffff097          	auipc	ra,0xfffff
    80003ea8:	7aa080e7          	jalr	1962(ra) # 8000364e <bread>
    80003eac:	892a                	mv	s2,a0
      dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003eae:	05850593          	addi	a1,a0,88
    80003eb2:	40dc                	lw	a5,4(s1)
    80003eb4:	8bbd                	andi	a5,a5,15
    80003eb6:	079a                	slli	a5,a5,0x6
    80003eb8:	95be                	add	a1,a1,a5
      ip->type = dip->type;
    80003eba:	00059783          	lh	a5,0(a1)
    80003ebe:	04f49223          	sh	a5,68(s1)
      ip->major = dip->major;
    80003ec2:	00259783          	lh	a5,2(a1)
    80003ec6:	04f49323          	sh	a5,70(s1)
      ip->minor = dip->minor;
    80003eca:	00459783          	lh	a5,4(a1)
    80003ece:	04f49423          	sh	a5,72(s1)
      ip->nlink = dip->nlink;
    80003ed2:	00659783          	lh	a5,6(a1)
    80003ed6:	04f49523          	sh	a5,74(s1)
      ip->size = dip->size;
    80003eda:	459c                	lw	a5,8(a1)
    80003edc:	c4fc                	sw	a5,76(s1)
      memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003ede:	03400613          	li	a2,52
    80003ee2:	05b1                	addi	a1,a1,12
    80003ee4:	05048513          	addi	a0,s1,80
    80003ee8:	ffffd097          	auipc	ra,0xffffd
    80003eec:	e32080e7          	jalr	-462(ra) # 80000d1a <memmove>
      brelse(bp);
    80003ef0:	854a                	mv	a0,s2
    80003ef2:	00000097          	auipc	ra,0x0
    80003ef6:	88c080e7          	jalr	-1908(ra) # 8000377e <brelse>
      ip->valid = 1;
    80003efa:	4785                	li	a5,1
    80003efc:	c0bc                	sw	a5,64(s1)
      if(ip->type == 0)
    80003efe:	04449783          	lh	a5,68(s1)
    80003f02:	fbb5                	bnez	a5,80003e76 <ilock+0x24>
        panic("ilock: no type");
    80003f04:	00006517          	auipc	a0,0x6
    80003f08:	9bc50513          	addi	a0,a0,-1604 # 800098c0 <syscalls+0x190>
    80003f0c:	ffffc097          	auipc	ra,0xffffc
    80003f10:	61e080e7          	jalr	1566(ra) # 8000052a <panic>

0000000080003f14 <iunlock>:
  {
    80003f14:	1101                	addi	sp,sp,-32
    80003f16:	ec06                	sd	ra,24(sp)
    80003f18:	e822                	sd	s0,16(sp)
    80003f1a:	e426                	sd	s1,8(sp)
    80003f1c:	e04a                	sd	s2,0(sp)
    80003f1e:	1000                	addi	s0,sp,32
    if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003f20:	c905                	beqz	a0,80003f50 <iunlock+0x3c>
    80003f22:	84aa                	mv	s1,a0
    80003f24:	01050913          	addi	s2,a0,16
    80003f28:	854a                	mv	a0,s2
    80003f2a:	00001097          	auipc	ra,0x1
    80003f2e:	fc8080e7          	jalr	-56(ra) # 80004ef2 <holdingsleep>
    80003f32:	cd19                	beqz	a0,80003f50 <iunlock+0x3c>
    80003f34:	449c                	lw	a5,8(s1)
    80003f36:	00f05d63          	blez	a5,80003f50 <iunlock+0x3c>
    releasesleep(&ip->lock);
    80003f3a:	854a                	mv	a0,s2
    80003f3c:	00001097          	auipc	ra,0x1
    80003f40:	f72080e7          	jalr	-142(ra) # 80004eae <releasesleep>
  }
    80003f44:	60e2                	ld	ra,24(sp)
    80003f46:	6442                	ld	s0,16(sp)
    80003f48:	64a2                	ld	s1,8(sp)
    80003f4a:	6902                	ld	s2,0(sp)
    80003f4c:	6105                	addi	sp,sp,32
    80003f4e:	8082                	ret
      panic("iunlock");
    80003f50:	00006517          	auipc	a0,0x6
    80003f54:	98050513          	addi	a0,a0,-1664 # 800098d0 <syscalls+0x1a0>
    80003f58:	ffffc097          	auipc	ra,0xffffc
    80003f5c:	5d2080e7          	jalr	1490(ra) # 8000052a <panic>

0000000080003f60 <itrunc>:

  // Truncate inode (discard contents).
  // Caller must hold ip->lock.
  void
  itrunc(struct inode *ip)
  {
    80003f60:	7179                	addi	sp,sp,-48
    80003f62:	f406                	sd	ra,40(sp)
    80003f64:	f022                	sd	s0,32(sp)
    80003f66:	ec26                	sd	s1,24(sp)
    80003f68:	e84a                	sd	s2,16(sp)
    80003f6a:	e44e                	sd	s3,8(sp)
    80003f6c:	e052                	sd	s4,0(sp)
    80003f6e:	1800                	addi	s0,sp,48
    80003f70:	89aa                	mv	s3,a0
    int i, j;
    struct buf *bp;
    uint *a;

    for(i = 0; i < NDIRECT; i++){
    80003f72:	05050493          	addi	s1,a0,80
    80003f76:	08050913          	addi	s2,a0,128
    80003f7a:	a021                	j	80003f82 <itrunc+0x22>
    80003f7c:	0491                	addi	s1,s1,4
    80003f7e:	01248d63          	beq	s1,s2,80003f98 <itrunc+0x38>
      if(ip->addrs[i]){
    80003f82:	408c                	lw	a1,0(s1)
    80003f84:	dde5                	beqz	a1,80003f7c <itrunc+0x1c>
        bfree(ip->dev, ip->addrs[i]);
    80003f86:	0009a503          	lw	a0,0(s3)
    80003f8a:	00000097          	auipc	ra,0x0
    80003f8e:	90a080e7          	jalr	-1782(ra) # 80003894 <bfree>
        ip->addrs[i] = 0;
    80003f92:	0004a023          	sw	zero,0(s1)
    80003f96:	b7dd                	j	80003f7c <itrunc+0x1c>
      }
    }

    if(ip->addrs[NDIRECT]){
    80003f98:	0809a583          	lw	a1,128(s3)
    80003f9c:	e185                	bnez	a1,80003fbc <itrunc+0x5c>
      brelse(bp);
      bfree(ip->dev, ip->addrs[NDIRECT]);
      ip->addrs[NDIRECT] = 0;
    }

    ip->size = 0;
    80003f9e:	0409a623          	sw	zero,76(s3)
    iupdate(ip);
    80003fa2:	854e                	mv	a0,s3
    80003fa4:	00000097          	auipc	ra,0x0
    80003fa8:	de4080e7          	jalr	-540(ra) # 80003d88 <iupdate>
  }
    80003fac:	70a2                	ld	ra,40(sp)
    80003fae:	7402                	ld	s0,32(sp)
    80003fb0:	64e2                	ld	s1,24(sp)
    80003fb2:	6942                	ld	s2,16(sp)
    80003fb4:	69a2                	ld	s3,8(sp)
    80003fb6:	6a02                	ld	s4,0(sp)
    80003fb8:	6145                	addi	sp,sp,48
    80003fba:	8082                	ret
      bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003fbc:	0009a503          	lw	a0,0(s3)
    80003fc0:	fffff097          	auipc	ra,0xfffff
    80003fc4:	68e080e7          	jalr	1678(ra) # 8000364e <bread>
    80003fc8:	8a2a                	mv	s4,a0
      for(j = 0; j < NINDIRECT; j++){
    80003fca:	05850493          	addi	s1,a0,88
    80003fce:	45850913          	addi	s2,a0,1112
    80003fd2:	a021                	j	80003fda <itrunc+0x7a>
    80003fd4:	0491                	addi	s1,s1,4
    80003fd6:	01248b63          	beq	s1,s2,80003fec <itrunc+0x8c>
        if(a[j])
    80003fda:	408c                	lw	a1,0(s1)
    80003fdc:	dde5                	beqz	a1,80003fd4 <itrunc+0x74>
          bfree(ip->dev, a[j]);
    80003fde:	0009a503          	lw	a0,0(s3)
    80003fe2:	00000097          	auipc	ra,0x0
    80003fe6:	8b2080e7          	jalr	-1870(ra) # 80003894 <bfree>
    80003fea:	b7ed                	j	80003fd4 <itrunc+0x74>
      brelse(bp);
    80003fec:	8552                	mv	a0,s4
    80003fee:	fffff097          	auipc	ra,0xfffff
    80003ff2:	790080e7          	jalr	1936(ra) # 8000377e <brelse>
      bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ff6:	0809a583          	lw	a1,128(s3)
    80003ffa:	0009a503          	lw	a0,0(s3)
    80003ffe:	00000097          	auipc	ra,0x0
    80004002:	896080e7          	jalr	-1898(ra) # 80003894 <bfree>
      ip->addrs[NDIRECT] = 0;
    80004006:	0809a023          	sw	zero,128(s3)
    8000400a:	bf51                	j	80003f9e <itrunc+0x3e>

000000008000400c <iput>:
  {
    8000400c:	1101                	addi	sp,sp,-32
    8000400e:	ec06                	sd	ra,24(sp)
    80004010:	e822                	sd	s0,16(sp)
    80004012:	e426                	sd	s1,8(sp)
    80004014:	e04a                	sd	s2,0(sp)
    80004016:	1000                	addi	s0,sp,32
    80004018:	84aa                	mv	s1,a0
    acquire(&itable.lock);
    8000401a:	00029517          	auipc	a0,0x29
    8000401e:	5ae50513          	addi	a0,a0,1454 # 8002d5c8 <itable>
    80004022:	ffffd097          	auipc	ra,0xffffd
    80004026:	ba0080e7          	jalr	-1120(ra) # 80000bc2 <acquire>
    if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000402a:	4498                	lw	a4,8(s1)
    8000402c:	4785                	li	a5,1
    8000402e:	02f70363          	beq	a4,a5,80004054 <iput+0x48>
    ip->ref--;
    80004032:	449c                	lw	a5,8(s1)
    80004034:	37fd                	addiw	a5,a5,-1
    80004036:	c49c                	sw	a5,8(s1)
    release(&itable.lock);
    80004038:	00029517          	auipc	a0,0x29
    8000403c:	59050513          	addi	a0,a0,1424 # 8002d5c8 <itable>
    80004040:	ffffd097          	auipc	ra,0xffffd
    80004044:	c36080e7          	jalr	-970(ra) # 80000c76 <release>
  }
    80004048:	60e2                	ld	ra,24(sp)
    8000404a:	6442                	ld	s0,16(sp)
    8000404c:	64a2                	ld	s1,8(sp)
    8000404e:	6902                	ld	s2,0(sp)
    80004050:	6105                	addi	sp,sp,32
    80004052:	8082                	ret
    if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004054:	40bc                	lw	a5,64(s1)
    80004056:	dff1                	beqz	a5,80004032 <iput+0x26>
    80004058:	04a49783          	lh	a5,74(s1)
    8000405c:	fbf9                	bnez	a5,80004032 <iput+0x26>
      acquiresleep(&ip->lock);
    8000405e:	01048913          	addi	s2,s1,16
    80004062:	854a                	mv	a0,s2
    80004064:	00001097          	auipc	ra,0x1
    80004068:	df4080e7          	jalr	-524(ra) # 80004e58 <acquiresleep>
      release(&itable.lock);
    8000406c:	00029517          	auipc	a0,0x29
    80004070:	55c50513          	addi	a0,a0,1372 # 8002d5c8 <itable>
    80004074:	ffffd097          	auipc	ra,0xffffd
    80004078:	c02080e7          	jalr	-1022(ra) # 80000c76 <release>
      itrunc(ip);
    8000407c:	8526                	mv	a0,s1
    8000407e:	00000097          	auipc	ra,0x0
    80004082:	ee2080e7          	jalr	-286(ra) # 80003f60 <itrunc>
      ip->type = 0;
    80004086:	04049223          	sh	zero,68(s1)
      iupdate(ip);
    8000408a:	8526                	mv	a0,s1
    8000408c:	00000097          	auipc	ra,0x0
    80004090:	cfc080e7          	jalr	-772(ra) # 80003d88 <iupdate>
      ip->valid = 0;
    80004094:	0404a023          	sw	zero,64(s1)
      releasesleep(&ip->lock);
    80004098:	854a                	mv	a0,s2
    8000409a:	00001097          	auipc	ra,0x1
    8000409e:	e14080e7          	jalr	-492(ra) # 80004eae <releasesleep>
      acquire(&itable.lock);
    800040a2:	00029517          	auipc	a0,0x29
    800040a6:	52650513          	addi	a0,a0,1318 # 8002d5c8 <itable>
    800040aa:	ffffd097          	auipc	ra,0xffffd
    800040ae:	b18080e7          	jalr	-1256(ra) # 80000bc2 <acquire>
    800040b2:	b741                	j	80004032 <iput+0x26>

00000000800040b4 <iunlockput>:
  {
    800040b4:	1101                	addi	sp,sp,-32
    800040b6:	ec06                	sd	ra,24(sp)
    800040b8:	e822                	sd	s0,16(sp)
    800040ba:	e426                	sd	s1,8(sp)
    800040bc:	1000                	addi	s0,sp,32
    800040be:	84aa                	mv	s1,a0
    iunlock(ip);
    800040c0:	00000097          	auipc	ra,0x0
    800040c4:	e54080e7          	jalr	-428(ra) # 80003f14 <iunlock>
    iput(ip);
    800040c8:	8526                	mv	a0,s1
    800040ca:	00000097          	auipc	ra,0x0
    800040ce:	f42080e7          	jalr	-190(ra) # 8000400c <iput>
  }
    800040d2:	60e2                	ld	ra,24(sp)
    800040d4:	6442                	ld	s0,16(sp)
    800040d6:	64a2                	ld	s1,8(sp)
    800040d8:	6105                	addi	sp,sp,32
    800040da:	8082                	ret

00000000800040dc <stati>:

  // Copy stat information from inode.
  // Caller must hold ip->lock.
  void
  stati(struct inode *ip, struct stat *st)
  {
    800040dc:	1141                	addi	sp,sp,-16
    800040de:	e422                	sd	s0,8(sp)
    800040e0:	0800                	addi	s0,sp,16
    st->dev = ip->dev;
    800040e2:	411c                	lw	a5,0(a0)
    800040e4:	c19c                	sw	a5,0(a1)
    st->ino = ip->inum;
    800040e6:	415c                	lw	a5,4(a0)
    800040e8:	c1dc                	sw	a5,4(a1)
    st->type = ip->type;
    800040ea:	04451783          	lh	a5,68(a0)
    800040ee:	00f59423          	sh	a5,8(a1)
    st->nlink = ip->nlink;
    800040f2:	04a51783          	lh	a5,74(a0)
    800040f6:	00f59523          	sh	a5,10(a1)
    st->size = ip->size;
    800040fa:	04c56783          	lwu	a5,76(a0)
    800040fe:	e99c                	sd	a5,16(a1)
  }
    80004100:	6422                	ld	s0,8(sp)
    80004102:	0141                	addi	sp,sp,16
    80004104:	8082                	ret

0000000080004106 <readi>:
  readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
  {
    uint tot, m;
    struct buf *bp;

    if(off > ip->size || off + n < off)
    80004106:	457c                	lw	a5,76(a0)
    80004108:	0ed7e963          	bltu	a5,a3,800041fa <readi+0xf4>
  {
    8000410c:	7159                	addi	sp,sp,-112
    8000410e:	f486                	sd	ra,104(sp)
    80004110:	f0a2                	sd	s0,96(sp)
    80004112:	eca6                	sd	s1,88(sp)
    80004114:	e8ca                	sd	s2,80(sp)
    80004116:	e4ce                	sd	s3,72(sp)
    80004118:	e0d2                	sd	s4,64(sp)
    8000411a:	fc56                	sd	s5,56(sp)
    8000411c:	f85a                	sd	s6,48(sp)
    8000411e:	f45e                	sd	s7,40(sp)
    80004120:	f062                	sd	s8,32(sp)
    80004122:	ec66                	sd	s9,24(sp)
    80004124:	e86a                	sd	s10,16(sp)
    80004126:	e46e                	sd	s11,8(sp)
    80004128:	1880                	addi	s0,sp,112
    8000412a:	8baa                	mv	s7,a0
    8000412c:	8c2e                	mv	s8,a1
    8000412e:	8ab2                	mv	s5,a2
    80004130:	84b6                	mv	s1,a3
    80004132:	8b3a                	mv	s6,a4
    if(off > ip->size || off + n < off)
    80004134:	9f35                	addw	a4,a4,a3
      return 0;
    80004136:	4501                	li	a0,0
    if(off > ip->size || off + n < off)
    80004138:	0ad76063          	bltu	a4,a3,800041d8 <readi+0xd2>
    if(off + n > ip->size)
    8000413c:	00e7f463          	bgeu	a5,a4,80004144 <readi+0x3e>
      n = ip->size - off;
    80004140:	40d78b3b          	subw	s6,a5,a3

    for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004144:	0a0b0963          	beqz	s6,800041f6 <readi+0xf0>
    80004148:	4981                	li	s3,0
      bp = bread(ip->dev, bmap(ip, off/BSIZE));
      m = min(n - tot, BSIZE - off%BSIZE);
    8000414a:	40000d13          	li	s10,1024
      if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000414e:	5cfd                	li	s9,-1
    80004150:	a82d                	j	8000418a <readi+0x84>
    80004152:	020a1d93          	slli	s11,s4,0x20
    80004156:	020ddd93          	srli	s11,s11,0x20
    8000415a:	05890793          	addi	a5,s2,88
    8000415e:	86ee                	mv	a3,s11
    80004160:	963e                	add	a2,a2,a5
    80004162:	85d6                	mv	a1,s5
    80004164:	8562                	mv	a0,s8
    80004166:	fffff097          	auipc	ra,0xfffff
    8000416a:	8f4080e7          	jalr	-1804(ra) # 80002a5a <either_copyout>
    8000416e:	05950d63          	beq	a0,s9,800041c8 <readi+0xc2>
        brelse(bp);
        tot = -1;
        break;
      }
      brelse(bp);
    80004172:	854a                	mv	a0,s2
    80004174:	fffff097          	auipc	ra,0xfffff
    80004178:	60a080e7          	jalr	1546(ra) # 8000377e <brelse>
    for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000417c:	013a09bb          	addw	s3,s4,s3
    80004180:	009a04bb          	addw	s1,s4,s1
    80004184:	9aee                	add	s5,s5,s11
    80004186:	0569f763          	bgeu	s3,s6,800041d4 <readi+0xce>
      bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000418a:	000ba903          	lw	s2,0(s7)
    8000418e:	00a4d59b          	srliw	a1,s1,0xa
    80004192:	855e                	mv	a0,s7
    80004194:	00000097          	auipc	ra,0x0
    80004198:	8ae080e7          	jalr	-1874(ra) # 80003a42 <bmap>
    8000419c:	0005059b          	sext.w	a1,a0
    800041a0:	854a                	mv	a0,s2
    800041a2:	fffff097          	auipc	ra,0xfffff
    800041a6:	4ac080e7          	jalr	1196(ra) # 8000364e <bread>
    800041aa:	892a                	mv	s2,a0
      m = min(n - tot, BSIZE - off%BSIZE);
    800041ac:	3ff4f613          	andi	a2,s1,1023
    800041b0:	40cd07bb          	subw	a5,s10,a2
    800041b4:	413b073b          	subw	a4,s6,s3
    800041b8:	8a3e                	mv	s4,a5
    800041ba:	2781                	sext.w	a5,a5
    800041bc:	0007069b          	sext.w	a3,a4
    800041c0:	f8f6f9e3          	bgeu	a3,a5,80004152 <readi+0x4c>
    800041c4:	8a3a                	mv	s4,a4
    800041c6:	b771                	j	80004152 <readi+0x4c>
        brelse(bp);
    800041c8:	854a                	mv	a0,s2
    800041ca:	fffff097          	auipc	ra,0xfffff
    800041ce:	5b4080e7          	jalr	1460(ra) # 8000377e <brelse>
        tot = -1;
    800041d2:	59fd                	li	s3,-1
    }
    return tot;
    800041d4:	0009851b          	sext.w	a0,s3
  }
    800041d8:	70a6                	ld	ra,104(sp)
    800041da:	7406                	ld	s0,96(sp)
    800041dc:	64e6                	ld	s1,88(sp)
    800041de:	6946                	ld	s2,80(sp)
    800041e0:	69a6                	ld	s3,72(sp)
    800041e2:	6a06                	ld	s4,64(sp)
    800041e4:	7ae2                	ld	s5,56(sp)
    800041e6:	7b42                	ld	s6,48(sp)
    800041e8:	7ba2                	ld	s7,40(sp)
    800041ea:	7c02                	ld	s8,32(sp)
    800041ec:	6ce2                	ld	s9,24(sp)
    800041ee:	6d42                	ld	s10,16(sp)
    800041f0:	6da2                	ld	s11,8(sp)
    800041f2:	6165                	addi	sp,sp,112
    800041f4:	8082                	ret
    for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800041f6:	89da                	mv	s3,s6
    800041f8:	bff1                	j	800041d4 <readi+0xce>
      return 0;
    800041fa:	4501                	li	a0,0
  }
    800041fc:	8082                	ret

00000000800041fe <writei>:
  writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
  {
    uint tot, m;
    struct buf *bp;

    if(off > ip->size || off + n < off)
    800041fe:	457c                	lw	a5,76(a0)
    80004200:	10d7e863          	bltu	a5,a3,80004310 <writei+0x112>
  {
    80004204:	7159                	addi	sp,sp,-112
    80004206:	f486                	sd	ra,104(sp)
    80004208:	f0a2                	sd	s0,96(sp)
    8000420a:	eca6                	sd	s1,88(sp)
    8000420c:	e8ca                	sd	s2,80(sp)
    8000420e:	e4ce                	sd	s3,72(sp)
    80004210:	e0d2                	sd	s4,64(sp)
    80004212:	fc56                	sd	s5,56(sp)
    80004214:	f85a                	sd	s6,48(sp)
    80004216:	f45e                	sd	s7,40(sp)
    80004218:	f062                	sd	s8,32(sp)
    8000421a:	ec66                	sd	s9,24(sp)
    8000421c:	e86a                	sd	s10,16(sp)
    8000421e:	e46e                	sd	s11,8(sp)
    80004220:	1880                	addi	s0,sp,112
    80004222:	8b2a                	mv	s6,a0
    80004224:	8c2e                	mv	s8,a1
    80004226:	8ab2                	mv	s5,a2
    80004228:	8936                	mv	s2,a3
    8000422a:	8bba                	mv	s7,a4
    if(off > ip->size || off + n < off)
    8000422c:	00e687bb          	addw	a5,a3,a4
    80004230:	0ed7e263          	bltu	a5,a3,80004314 <writei+0x116>
      return -1;
    if(off + n > MAXFILE*BSIZE)
    80004234:	00043737          	lui	a4,0x43
    80004238:	0ef76063          	bltu	a4,a5,80004318 <writei+0x11a>
      return -1;

    for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000423c:	0c0b8863          	beqz	s7,8000430c <writei+0x10e>
    80004240:	4a01                	li	s4,0
      bp = bread(ip->dev, bmap(ip, off/BSIZE));
      m = min(n - tot, BSIZE - off%BSIZE);
    80004242:	40000d13          	li	s10,1024
      if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004246:	5cfd                	li	s9,-1
    80004248:	a091                	j	8000428c <writei+0x8e>
    8000424a:	02099d93          	slli	s11,s3,0x20
    8000424e:	020ddd93          	srli	s11,s11,0x20
    80004252:	05848793          	addi	a5,s1,88
    80004256:	86ee                	mv	a3,s11
    80004258:	8656                	mv	a2,s5
    8000425a:	85e2                	mv	a1,s8
    8000425c:	953e                	add	a0,a0,a5
    8000425e:	fffff097          	auipc	ra,0xfffff
    80004262:	852080e7          	jalr	-1966(ra) # 80002ab0 <either_copyin>
    80004266:	07950263          	beq	a0,s9,800042ca <writei+0xcc>
        brelse(bp);
        break;
      }
      log_write(bp);
    8000426a:	8526                	mv	a0,s1
    8000426c:	00001097          	auipc	ra,0x1
    80004270:	acc080e7          	jalr	-1332(ra) # 80004d38 <log_write>
      brelse(bp);
    80004274:	8526                	mv	a0,s1
    80004276:	fffff097          	auipc	ra,0xfffff
    8000427a:	508080e7          	jalr	1288(ra) # 8000377e <brelse>
    for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000427e:	01498a3b          	addw	s4,s3,s4
    80004282:	0129893b          	addw	s2,s3,s2
    80004286:	9aee                	add	s5,s5,s11
    80004288:	057a7663          	bgeu	s4,s7,800042d4 <writei+0xd6>
      bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000428c:	000b2483          	lw	s1,0(s6)
    80004290:	00a9559b          	srliw	a1,s2,0xa
    80004294:	855a                	mv	a0,s6
    80004296:	fffff097          	auipc	ra,0xfffff
    8000429a:	7ac080e7          	jalr	1964(ra) # 80003a42 <bmap>
    8000429e:	0005059b          	sext.w	a1,a0
    800042a2:	8526                	mv	a0,s1
    800042a4:	fffff097          	auipc	ra,0xfffff
    800042a8:	3aa080e7          	jalr	938(ra) # 8000364e <bread>
    800042ac:	84aa                	mv	s1,a0
      m = min(n - tot, BSIZE - off%BSIZE);
    800042ae:	3ff97513          	andi	a0,s2,1023
    800042b2:	40ad07bb          	subw	a5,s10,a0
    800042b6:	414b873b          	subw	a4,s7,s4
    800042ba:	89be                	mv	s3,a5
    800042bc:	2781                	sext.w	a5,a5
    800042be:	0007069b          	sext.w	a3,a4
    800042c2:	f8f6f4e3          	bgeu	a3,a5,8000424a <writei+0x4c>
    800042c6:	89ba                	mv	s3,a4
    800042c8:	b749                	j	8000424a <writei+0x4c>
        brelse(bp);
    800042ca:	8526                	mv	a0,s1
    800042cc:	fffff097          	auipc	ra,0xfffff
    800042d0:	4b2080e7          	jalr	1202(ra) # 8000377e <brelse>
    }

    if(off > ip->size)
    800042d4:	04cb2783          	lw	a5,76(s6)
    800042d8:	0127f463          	bgeu	a5,s2,800042e0 <writei+0xe2>
      ip->size = off;
    800042dc:	052b2623          	sw	s2,76(s6)

    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    800042e0:	855a                	mv	a0,s6
    800042e2:	00000097          	auipc	ra,0x0
    800042e6:	aa6080e7          	jalr	-1370(ra) # 80003d88 <iupdate>

    return tot;
    800042ea:	000a051b          	sext.w	a0,s4
  }
    800042ee:	70a6                	ld	ra,104(sp)
    800042f0:	7406                	ld	s0,96(sp)
    800042f2:	64e6                	ld	s1,88(sp)
    800042f4:	6946                	ld	s2,80(sp)
    800042f6:	69a6                	ld	s3,72(sp)
    800042f8:	6a06                	ld	s4,64(sp)
    800042fa:	7ae2                	ld	s5,56(sp)
    800042fc:	7b42                	ld	s6,48(sp)
    800042fe:	7ba2                	ld	s7,40(sp)
    80004300:	7c02                	ld	s8,32(sp)
    80004302:	6ce2                	ld	s9,24(sp)
    80004304:	6d42                	ld	s10,16(sp)
    80004306:	6da2                	ld	s11,8(sp)
    80004308:	6165                	addi	sp,sp,112
    8000430a:	8082                	ret
    for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000430c:	8a5e                	mv	s4,s7
    8000430e:	bfc9                	j	800042e0 <writei+0xe2>
      return -1;
    80004310:	557d                	li	a0,-1
  }
    80004312:	8082                	ret
      return -1;
    80004314:	557d                	li	a0,-1
    80004316:	bfe1                	j	800042ee <writei+0xf0>
      return -1;
    80004318:	557d                	li	a0,-1
    8000431a:	bfd1                	j	800042ee <writei+0xf0>

000000008000431c <namecmp>:

  // Directories

  int
  namecmp(const char *s, const char *t)
  {
    8000431c:	1141                	addi	sp,sp,-16
    8000431e:	e406                	sd	ra,8(sp)
    80004320:	e022                	sd	s0,0(sp)
    80004322:	0800                	addi	s0,sp,16
    return strncmp(s, t, DIRSIZ);
    80004324:	4639                	li	a2,14
    80004326:	ffffd097          	auipc	ra,0xffffd
    8000432a:	a70080e7          	jalr	-1424(ra) # 80000d96 <strncmp>
  }
    8000432e:	60a2                	ld	ra,8(sp)
    80004330:	6402                	ld	s0,0(sp)
    80004332:	0141                	addi	sp,sp,16
    80004334:	8082                	ret

0000000080004336 <dirlookup>:

  // Look for a directory entry in a directory.
  // If found, set *poff to byte offset of entry.
  struct inode*
  dirlookup(struct inode *dp, char *name, uint *poff)
  {
    80004336:	7139                	addi	sp,sp,-64
    80004338:	fc06                	sd	ra,56(sp)
    8000433a:	f822                	sd	s0,48(sp)
    8000433c:	f426                	sd	s1,40(sp)
    8000433e:	f04a                	sd	s2,32(sp)
    80004340:	ec4e                	sd	s3,24(sp)
    80004342:	e852                	sd	s4,16(sp)
    80004344:	0080                	addi	s0,sp,64
    uint off, inum;
    struct dirent de;

    if(dp->type != T_DIR)
    80004346:	04451703          	lh	a4,68(a0)
    8000434a:	4785                	li	a5,1
    8000434c:	00f71a63          	bne	a4,a5,80004360 <dirlookup+0x2a>
    80004350:	892a                	mv	s2,a0
    80004352:	89ae                	mv	s3,a1
    80004354:	8a32                	mv	s4,a2
      panic("dirlookup not DIR");

    for(off = 0; off < dp->size; off += sizeof(de)){
    80004356:	457c                	lw	a5,76(a0)
    80004358:	4481                	li	s1,0
        inum = de.inum;
        return iget(dp->dev, inum);
      }
    }

    return 0;
    8000435a:	4501                	li	a0,0
    for(off = 0; off < dp->size; off += sizeof(de)){
    8000435c:	e79d                	bnez	a5,8000438a <dirlookup+0x54>
    8000435e:	a8a5                	j	800043d6 <dirlookup+0xa0>
      panic("dirlookup not DIR");
    80004360:	00005517          	auipc	a0,0x5
    80004364:	57850513          	addi	a0,a0,1400 # 800098d8 <syscalls+0x1a8>
    80004368:	ffffc097          	auipc	ra,0xffffc
    8000436c:	1c2080e7          	jalr	450(ra) # 8000052a <panic>
        panic("dirlookup read");
    80004370:	00005517          	auipc	a0,0x5
    80004374:	58050513          	addi	a0,a0,1408 # 800098f0 <syscalls+0x1c0>
    80004378:	ffffc097          	auipc	ra,0xffffc
    8000437c:	1b2080e7          	jalr	434(ra) # 8000052a <panic>
    for(off = 0; off < dp->size; off += sizeof(de)){
    80004380:	24c1                	addiw	s1,s1,16
    80004382:	04c92783          	lw	a5,76(s2)
    80004386:	04f4f763          	bgeu	s1,a5,800043d4 <dirlookup+0x9e>
      if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000438a:	4741                	li	a4,16
    8000438c:	86a6                	mv	a3,s1
    8000438e:	fc040613          	addi	a2,s0,-64
    80004392:	4581                	li	a1,0
    80004394:	854a                	mv	a0,s2
    80004396:	00000097          	auipc	ra,0x0
    8000439a:	d70080e7          	jalr	-656(ra) # 80004106 <readi>
    8000439e:	47c1                	li	a5,16
    800043a0:	fcf518e3          	bne	a0,a5,80004370 <dirlookup+0x3a>
      if(de.inum == 0)
    800043a4:	fc045783          	lhu	a5,-64(s0)
    800043a8:	dfe1                	beqz	a5,80004380 <dirlookup+0x4a>
      if(namecmp(name, de.name) == 0){
    800043aa:	fc240593          	addi	a1,s0,-62
    800043ae:	854e                	mv	a0,s3
    800043b0:	00000097          	auipc	ra,0x0
    800043b4:	f6c080e7          	jalr	-148(ra) # 8000431c <namecmp>
    800043b8:	f561                	bnez	a0,80004380 <dirlookup+0x4a>
        if(poff)
    800043ba:	000a0463          	beqz	s4,800043c2 <dirlookup+0x8c>
          *poff = off;
    800043be:	009a2023          	sw	s1,0(s4)
        return iget(dp->dev, inum);
    800043c2:	fc045583          	lhu	a1,-64(s0)
    800043c6:	00092503          	lw	a0,0(s2)
    800043ca:	fffff097          	auipc	ra,0xfffff
    800043ce:	754080e7          	jalr	1876(ra) # 80003b1e <iget>
    800043d2:	a011                	j	800043d6 <dirlookup+0xa0>
    return 0;
    800043d4:	4501                	li	a0,0
  }
    800043d6:	70e2                	ld	ra,56(sp)
    800043d8:	7442                	ld	s0,48(sp)
    800043da:	74a2                	ld	s1,40(sp)
    800043dc:	7902                	ld	s2,32(sp)
    800043de:	69e2                	ld	s3,24(sp)
    800043e0:	6a42                	ld	s4,16(sp)
    800043e2:	6121                	addi	sp,sp,64
    800043e4:	8082                	ret

00000000800043e6 <namex>:
  // If parent != 0, return the inode for the parent and copy the final
  // path element into name, which must have room for DIRSIZ bytes.
  // Must be called inside a transaction since it calls iput().
  static struct inode*
  namex(char *path, int nameiparent, char *name)
  {
    800043e6:	711d                	addi	sp,sp,-96
    800043e8:	ec86                	sd	ra,88(sp)
    800043ea:	e8a2                	sd	s0,80(sp)
    800043ec:	e4a6                	sd	s1,72(sp)
    800043ee:	e0ca                	sd	s2,64(sp)
    800043f0:	fc4e                	sd	s3,56(sp)
    800043f2:	f852                	sd	s4,48(sp)
    800043f4:	f456                	sd	s5,40(sp)
    800043f6:	f05a                	sd	s6,32(sp)
    800043f8:	ec5e                	sd	s7,24(sp)
    800043fa:	e862                	sd	s8,16(sp)
    800043fc:	e466                	sd	s9,8(sp)
    800043fe:	1080                	addi	s0,sp,96
    80004400:	84aa                	mv	s1,a0
    80004402:	8aae                	mv	s5,a1
    80004404:	8a32                	mv	s4,a2
    struct inode *ip, *next;

    if(*path == '/')
    80004406:	00054703          	lbu	a4,0(a0)
    8000440a:	02f00793          	li	a5,47
    8000440e:	02f70363          	beq	a4,a5,80004434 <namex+0x4e>
      ip = iget(ROOTDEV, ROOTINO);
    else
      ip = idup(myproc()->cwd);
    80004412:	ffffe097          	auipc	ra,0xffffe
    80004416:	9a0080e7          	jalr	-1632(ra) # 80001db2 <myproc>
    8000441a:	15053503          	ld	a0,336(a0)
    8000441e:	00000097          	auipc	ra,0x0
    80004422:	9f6080e7          	jalr	-1546(ra) # 80003e14 <idup>
    80004426:	89aa                	mv	s3,a0
    while(*path == '/')
    80004428:	02f00913          	li	s2,47
    len = path - s;
    8000442c:	4b01                	li	s6,0
    if(len >= DIRSIZ)
    8000442e:	4c35                	li	s8,13

    while((path = skipelem(path, name)) != 0){
      ilock(ip);
      if(ip->type != T_DIR){
    80004430:	4b85                	li	s7,1
    80004432:	a865                	j	800044ea <namex+0x104>
      ip = iget(ROOTDEV, ROOTINO);
    80004434:	4585                	li	a1,1
    80004436:	4505                	li	a0,1
    80004438:	fffff097          	auipc	ra,0xfffff
    8000443c:	6e6080e7          	jalr	1766(ra) # 80003b1e <iget>
    80004440:	89aa                	mv	s3,a0
    80004442:	b7dd                	j	80004428 <namex+0x42>
        iunlockput(ip);
    80004444:	854e                	mv	a0,s3
    80004446:	00000097          	auipc	ra,0x0
    8000444a:	c6e080e7          	jalr	-914(ra) # 800040b4 <iunlockput>
        return 0;
    8000444e:	4981                	li	s3,0
    if(nameiparent){
      iput(ip);
      return 0;
    }
    return ip;
  }
    80004450:	854e                	mv	a0,s3
    80004452:	60e6                	ld	ra,88(sp)
    80004454:	6446                	ld	s0,80(sp)
    80004456:	64a6                	ld	s1,72(sp)
    80004458:	6906                	ld	s2,64(sp)
    8000445a:	79e2                	ld	s3,56(sp)
    8000445c:	7a42                	ld	s4,48(sp)
    8000445e:	7aa2                	ld	s5,40(sp)
    80004460:	7b02                	ld	s6,32(sp)
    80004462:	6be2                	ld	s7,24(sp)
    80004464:	6c42                	ld	s8,16(sp)
    80004466:	6ca2                	ld	s9,8(sp)
    80004468:	6125                	addi	sp,sp,96
    8000446a:	8082                	ret
        iunlock(ip);
    8000446c:	854e                	mv	a0,s3
    8000446e:	00000097          	auipc	ra,0x0
    80004472:	aa6080e7          	jalr	-1370(ra) # 80003f14 <iunlock>
        return ip;
    80004476:	bfe9                	j	80004450 <namex+0x6a>
        iunlockput(ip);
    80004478:	854e                	mv	a0,s3
    8000447a:	00000097          	auipc	ra,0x0
    8000447e:	c3a080e7          	jalr	-966(ra) # 800040b4 <iunlockput>
        return 0;
    80004482:	89e6                	mv	s3,s9
    80004484:	b7f1                	j	80004450 <namex+0x6a>
    len = path - s;
    80004486:	40b48633          	sub	a2,s1,a1
    8000448a:	00060c9b          	sext.w	s9,a2
    if(len >= DIRSIZ)
    8000448e:	099c5463          	bge	s8,s9,80004516 <namex+0x130>
      memmove(name, s, DIRSIZ);
    80004492:	4639                	li	a2,14
    80004494:	8552                	mv	a0,s4
    80004496:	ffffd097          	auipc	ra,0xffffd
    8000449a:	884080e7          	jalr	-1916(ra) # 80000d1a <memmove>
    while(*path == '/')
    8000449e:	0004c783          	lbu	a5,0(s1)
    800044a2:	01279763          	bne	a5,s2,800044b0 <namex+0xca>
      path++;
    800044a6:	0485                	addi	s1,s1,1
    while(*path == '/')
    800044a8:	0004c783          	lbu	a5,0(s1)
    800044ac:	ff278de3          	beq	a5,s2,800044a6 <namex+0xc0>
      ilock(ip);
    800044b0:	854e                	mv	a0,s3
    800044b2:	00000097          	auipc	ra,0x0
    800044b6:	9a0080e7          	jalr	-1632(ra) # 80003e52 <ilock>
      if(ip->type != T_DIR){
    800044ba:	04499783          	lh	a5,68(s3)
    800044be:	f97793e3          	bne	a5,s7,80004444 <namex+0x5e>
      if(nameiparent && *path == '\0'){
    800044c2:	000a8563          	beqz	s5,800044cc <namex+0xe6>
    800044c6:	0004c783          	lbu	a5,0(s1)
    800044ca:	d3cd                	beqz	a5,8000446c <namex+0x86>
      if((next = dirlookup(ip, name, 0)) == 0){
    800044cc:	865a                	mv	a2,s6
    800044ce:	85d2                	mv	a1,s4
    800044d0:	854e                	mv	a0,s3
    800044d2:	00000097          	auipc	ra,0x0
    800044d6:	e64080e7          	jalr	-412(ra) # 80004336 <dirlookup>
    800044da:	8caa                	mv	s9,a0
    800044dc:	dd51                	beqz	a0,80004478 <namex+0x92>
      iunlockput(ip);
    800044de:	854e                	mv	a0,s3
    800044e0:	00000097          	auipc	ra,0x0
    800044e4:	bd4080e7          	jalr	-1068(ra) # 800040b4 <iunlockput>
      ip = next;
    800044e8:	89e6                	mv	s3,s9
    while(*path == '/')
    800044ea:	0004c783          	lbu	a5,0(s1)
    800044ee:	05279763          	bne	a5,s2,8000453c <namex+0x156>
      path++;
    800044f2:	0485                	addi	s1,s1,1
    while(*path == '/')
    800044f4:	0004c783          	lbu	a5,0(s1)
    800044f8:	ff278de3          	beq	a5,s2,800044f2 <namex+0x10c>
    if(*path == 0)
    800044fc:	c79d                	beqz	a5,8000452a <namex+0x144>
      path++;
    800044fe:	85a6                	mv	a1,s1
    len = path - s;
    80004500:	8cda                	mv	s9,s6
    80004502:	865a                	mv	a2,s6
    while(*path != '/' && *path != 0)
    80004504:	01278963          	beq	a5,s2,80004516 <namex+0x130>
    80004508:	dfbd                	beqz	a5,80004486 <namex+0xa0>
      path++;
    8000450a:	0485                	addi	s1,s1,1
    while(*path != '/' && *path != 0)
    8000450c:	0004c783          	lbu	a5,0(s1)
    80004510:	ff279ce3          	bne	a5,s2,80004508 <namex+0x122>
    80004514:	bf8d                	j	80004486 <namex+0xa0>
      memmove(name, s, len);
    80004516:	2601                	sext.w	a2,a2
    80004518:	8552                	mv	a0,s4
    8000451a:	ffffd097          	auipc	ra,0xffffd
    8000451e:	800080e7          	jalr	-2048(ra) # 80000d1a <memmove>
      name[len] = 0;
    80004522:	9cd2                	add	s9,s9,s4
    80004524:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004528:	bf9d                	j	8000449e <namex+0xb8>
    if(nameiparent){
    8000452a:	f20a83e3          	beqz	s5,80004450 <namex+0x6a>
      iput(ip);
    8000452e:	854e                	mv	a0,s3
    80004530:	00000097          	auipc	ra,0x0
    80004534:	adc080e7          	jalr	-1316(ra) # 8000400c <iput>
      return 0;
    80004538:	4981                	li	s3,0
    8000453a:	bf19                	j	80004450 <namex+0x6a>
    if(*path == 0)
    8000453c:	d7fd                	beqz	a5,8000452a <namex+0x144>
    while(*path != '/' && *path != 0)
    8000453e:	0004c783          	lbu	a5,0(s1)
    80004542:	85a6                	mv	a1,s1
    80004544:	b7d1                	j	80004508 <namex+0x122>

0000000080004546 <dirlink>:
  {
    80004546:	7139                	addi	sp,sp,-64
    80004548:	fc06                	sd	ra,56(sp)
    8000454a:	f822                	sd	s0,48(sp)
    8000454c:	f426                	sd	s1,40(sp)
    8000454e:	f04a                	sd	s2,32(sp)
    80004550:	ec4e                	sd	s3,24(sp)
    80004552:	e852                	sd	s4,16(sp)
    80004554:	0080                	addi	s0,sp,64
    80004556:	892a                	mv	s2,a0
    80004558:	8a2e                	mv	s4,a1
    8000455a:	89b2                	mv	s3,a2
    if((ip = dirlookup(dp, name, 0)) != 0){
    8000455c:	4601                	li	a2,0
    8000455e:	00000097          	auipc	ra,0x0
    80004562:	dd8080e7          	jalr	-552(ra) # 80004336 <dirlookup>
    80004566:	e93d                	bnez	a0,800045dc <dirlink+0x96>
    for(off = 0; off < dp->size; off += sizeof(de)){
    80004568:	04c92483          	lw	s1,76(s2)
    8000456c:	c49d                	beqz	s1,8000459a <dirlink+0x54>
    8000456e:	4481                	li	s1,0
      if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004570:	4741                	li	a4,16
    80004572:	86a6                	mv	a3,s1
    80004574:	fc040613          	addi	a2,s0,-64
    80004578:	4581                	li	a1,0
    8000457a:	854a                	mv	a0,s2
    8000457c:	00000097          	auipc	ra,0x0
    80004580:	b8a080e7          	jalr	-1142(ra) # 80004106 <readi>
    80004584:	47c1                	li	a5,16
    80004586:	06f51163          	bne	a0,a5,800045e8 <dirlink+0xa2>
      if(de.inum == 0)
    8000458a:	fc045783          	lhu	a5,-64(s0)
    8000458e:	c791                	beqz	a5,8000459a <dirlink+0x54>
    for(off = 0; off < dp->size; off += sizeof(de)){
    80004590:	24c1                	addiw	s1,s1,16
    80004592:	04c92783          	lw	a5,76(s2)
    80004596:	fcf4ede3          	bltu	s1,a5,80004570 <dirlink+0x2a>
    strncpy(de.name, name, DIRSIZ);
    8000459a:	4639                	li	a2,14
    8000459c:	85d2                	mv	a1,s4
    8000459e:	fc240513          	addi	a0,s0,-62
    800045a2:	ffffd097          	auipc	ra,0xffffd
    800045a6:	830080e7          	jalr	-2000(ra) # 80000dd2 <strncpy>
    de.inum = inum;
    800045aa:	fd341023          	sh	s3,-64(s0)
    if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800045ae:	4741                	li	a4,16
    800045b0:	86a6                	mv	a3,s1
    800045b2:	fc040613          	addi	a2,s0,-64
    800045b6:	4581                	li	a1,0
    800045b8:	854a                	mv	a0,s2
    800045ba:	00000097          	auipc	ra,0x0
    800045be:	c44080e7          	jalr	-956(ra) # 800041fe <writei>
    800045c2:	872a                	mv	a4,a0
    800045c4:	47c1                	li	a5,16
    return 0;
    800045c6:	4501                	li	a0,0
    if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800045c8:	02f71863          	bne	a4,a5,800045f8 <dirlink+0xb2>
  }
    800045cc:	70e2                	ld	ra,56(sp)
    800045ce:	7442                	ld	s0,48(sp)
    800045d0:	74a2                	ld	s1,40(sp)
    800045d2:	7902                	ld	s2,32(sp)
    800045d4:	69e2                	ld	s3,24(sp)
    800045d6:	6a42                	ld	s4,16(sp)
    800045d8:	6121                	addi	sp,sp,64
    800045da:	8082                	ret
      iput(ip);
    800045dc:	00000097          	auipc	ra,0x0
    800045e0:	a30080e7          	jalr	-1488(ra) # 8000400c <iput>
      return -1;
    800045e4:	557d                	li	a0,-1
    800045e6:	b7dd                	j	800045cc <dirlink+0x86>
        panic("dirlink read");
    800045e8:	00005517          	auipc	a0,0x5
    800045ec:	31850513          	addi	a0,a0,792 # 80009900 <syscalls+0x1d0>
    800045f0:	ffffc097          	auipc	ra,0xffffc
    800045f4:	f3a080e7          	jalr	-198(ra) # 8000052a <panic>
      panic("dirlink");
    800045f8:	00005517          	auipc	a0,0x5
    800045fc:	49050513          	addi	a0,a0,1168 # 80009a88 <syscalls+0x358>
    80004600:	ffffc097          	auipc	ra,0xffffc
    80004604:	f2a080e7          	jalr	-214(ra) # 8000052a <panic>

0000000080004608 <namei>:

  struct inode*
  namei(char *path)
  {
    80004608:	1101                	addi	sp,sp,-32
    8000460a:	ec06                	sd	ra,24(sp)
    8000460c:	e822                	sd	s0,16(sp)
    8000460e:	1000                	addi	s0,sp,32
    char name[DIRSIZ];
    return namex(path, 0, name);
    80004610:	fe040613          	addi	a2,s0,-32
    80004614:	4581                	li	a1,0
    80004616:	00000097          	auipc	ra,0x0
    8000461a:	dd0080e7          	jalr	-560(ra) # 800043e6 <namex>
  }
    8000461e:	60e2                	ld	ra,24(sp)
    80004620:	6442                	ld	s0,16(sp)
    80004622:	6105                	addi	sp,sp,32
    80004624:	8082                	ret

0000000080004626 <nameiparent>:

  struct inode*
  nameiparent(char *path, char *name)
  {
    80004626:	1141                	addi	sp,sp,-16
    80004628:	e406                	sd	ra,8(sp)
    8000462a:	e022                	sd	s0,0(sp)
    8000462c:	0800                	addi	s0,sp,16
    8000462e:	862e                	mv	a2,a1
    return namex(path, 1, name);
    80004630:	4585                	li	a1,1
    80004632:	00000097          	auipc	ra,0x0
    80004636:	db4080e7          	jalr	-588(ra) # 800043e6 <namex>
  }
    8000463a:	60a2                	ld	ra,8(sp)
    8000463c:	6402                	ld	s0,0(sp)
    8000463e:	0141                	addi	sp,sp,16
    80004640:	8082                	ret

0000000080004642 <itoa>:


  #include "fcntl.h"
  #define DIGITS 14

  char* itoa(int i, char b[]){
    80004642:	1101                	addi	sp,sp,-32
    80004644:	ec22                	sd	s0,24(sp)
    80004646:	1000                	addi	s0,sp,32
    80004648:	872a                	mv	a4,a0
    8000464a:	852e                	mv	a0,a1
      char const digit[] = "0123456789";
    8000464c:	00005797          	auipc	a5,0x5
    80004650:	2c478793          	addi	a5,a5,708 # 80009910 <syscalls+0x1e0>
    80004654:	6394                	ld	a3,0(a5)
    80004656:	fed43023          	sd	a3,-32(s0)
    8000465a:	0087d683          	lhu	a3,8(a5)
    8000465e:	fed41423          	sh	a3,-24(s0)
    80004662:	00a7c783          	lbu	a5,10(a5)
    80004666:	fef40523          	sb	a5,-22(s0)
      char* p = b;
    8000466a:	87ae                	mv	a5,a1
      if(i<0){
    8000466c:	02074b63          	bltz	a4,800046a2 <itoa+0x60>
          *p++ = '-';
          i *= -1;
      }
      int shifter = i;
    80004670:	86ba                	mv	a3,a4
      do{ //Move to where representation ends
          ++p;
          shifter = shifter/10;
    80004672:	4629                	li	a2,10
          ++p;
    80004674:	0785                	addi	a5,a5,1
          shifter = shifter/10;
    80004676:	02c6c6bb          	divw	a3,a3,a2
      }while(shifter);
    8000467a:	feed                	bnez	a3,80004674 <itoa+0x32>
      *p = '\0';
    8000467c:	00078023          	sb	zero,0(a5)
      do{ //Move back, inserting digits as u go
          *--p = digit[i%10];
    80004680:	4629                	li	a2,10
    80004682:	17fd                	addi	a5,a5,-1
    80004684:	02c766bb          	remw	a3,a4,a2
    80004688:	ff040593          	addi	a1,s0,-16
    8000468c:	96ae                	add	a3,a3,a1
    8000468e:	ff06c683          	lbu	a3,-16(a3)
    80004692:	00d78023          	sb	a3,0(a5)
          i = i/10;
    80004696:	02c7473b          	divw	a4,a4,a2
      }while(i);
    8000469a:	f765                	bnez	a4,80004682 <itoa+0x40>
      return b;
  }
    8000469c:	6462                	ld	s0,24(sp)
    8000469e:	6105                	addi	sp,sp,32
    800046a0:	8082                	ret
          *p++ = '-';
    800046a2:	00158793          	addi	a5,a1,1
    800046a6:	02d00693          	li	a3,45
    800046aa:	00d58023          	sb	a3,0(a1)
          i *= -1;
    800046ae:	40e0073b          	negw	a4,a4
    800046b2:	bf7d                	j	80004670 <itoa+0x2e>

00000000800046b4 <removeSwapFile>:
  //remove swap file of proc p;
  int
  removeSwapFile(struct proc* p)
  {
    800046b4:	711d                	addi	sp,sp,-96
    800046b6:	ec86                	sd	ra,88(sp)
    800046b8:	e8a2                	sd	s0,80(sp)
    800046ba:	e4a6                	sd	s1,72(sp)
    800046bc:	e0ca                	sd	s2,64(sp)
    800046be:	1080                	addi	s0,sp,96
    800046c0:	84aa                	mv	s1,a0
    //path of proccess
    char path[DIGITS];
    memmove(path,"/.swap", 6);
    800046c2:	4619                	li	a2,6
    800046c4:	00005597          	auipc	a1,0x5
    800046c8:	25c58593          	addi	a1,a1,604 # 80009920 <syscalls+0x1f0>
    800046cc:	fd040513          	addi	a0,s0,-48
    800046d0:	ffffc097          	auipc	ra,0xffffc
    800046d4:	64a080e7          	jalr	1610(ra) # 80000d1a <memmove>
    itoa(p->pid, path+ 6);
    800046d8:	fd640593          	addi	a1,s0,-42
    800046dc:	5888                	lw	a0,48(s1)
    800046de:	00000097          	auipc	ra,0x0
    800046e2:	f64080e7          	jalr	-156(ra) # 80004642 <itoa>
    struct inode *ip, *dp;
    struct dirent de;
    char name[DIRSIZ];
    uint off;

    if(0 == p->swapFile)
    800046e6:	1684b503          	ld	a0,360(s1)
    800046ea:	16050763          	beqz	a0,80004858 <removeSwapFile+0x1a4>
    {
      return -1;
    }
    fileclose(p->swapFile);
    800046ee:	00001097          	auipc	ra,0x1
    800046f2:	93e080e7          	jalr	-1730(ra) # 8000502c <fileclose>

    begin_op();
    800046f6:	00000097          	auipc	ra,0x0
    800046fa:	46a080e7          	jalr	1130(ra) # 80004b60 <begin_op>
    if((dp = nameiparent(path, name)) == 0)
    800046fe:	fb040593          	addi	a1,s0,-80
    80004702:	fd040513          	addi	a0,s0,-48
    80004706:	00000097          	auipc	ra,0x0
    8000470a:	f20080e7          	jalr	-224(ra) # 80004626 <nameiparent>
    8000470e:	892a                	mv	s2,a0
    80004710:	cd69                	beqz	a0,800047ea <removeSwapFile+0x136>
    {
      end_op();
      return -1;
    }

    ilock(dp);
    80004712:	fffff097          	auipc	ra,0xfffff
    80004716:	740080e7          	jalr	1856(ra) # 80003e52 <ilock>

      // Cannot unlink "." or "..".
    if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000471a:	00005597          	auipc	a1,0x5
    8000471e:	20e58593          	addi	a1,a1,526 # 80009928 <syscalls+0x1f8>
    80004722:	fb040513          	addi	a0,s0,-80
    80004726:	00000097          	auipc	ra,0x0
    8000472a:	bf6080e7          	jalr	-1034(ra) # 8000431c <namecmp>
    8000472e:	c57d                	beqz	a0,8000481c <removeSwapFile+0x168>
    80004730:	00005597          	auipc	a1,0x5
    80004734:	20058593          	addi	a1,a1,512 # 80009930 <syscalls+0x200>
    80004738:	fb040513          	addi	a0,s0,-80
    8000473c:	00000097          	auipc	ra,0x0
    80004740:	be0080e7          	jalr	-1056(ra) # 8000431c <namecmp>
    80004744:	cd61                	beqz	a0,8000481c <removeSwapFile+0x168>
      goto bad;

    if((ip = dirlookup(dp, name, &off)) == 0)
    80004746:	fac40613          	addi	a2,s0,-84
    8000474a:	fb040593          	addi	a1,s0,-80
    8000474e:	854a                	mv	a0,s2
    80004750:	00000097          	auipc	ra,0x0
    80004754:	be6080e7          	jalr	-1050(ra) # 80004336 <dirlookup>
    80004758:	84aa                	mv	s1,a0
    8000475a:	c169                	beqz	a0,8000481c <removeSwapFile+0x168>
      goto bad;
    ilock(ip);
    8000475c:	fffff097          	auipc	ra,0xfffff
    80004760:	6f6080e7          	jalr	1782(ra) # 80003e52 <ilock>

    if(ip->nlink < 1)
    80004764:	04a49783          	lh	a5,74(s1)
    80004768:	08f05763          	blez	a5,800047f6 <removeSwapFile+0x142>
      panic("unlink: nlink < 1");
    if(ip->type == T_DIR && !isdirempty(ip)){
    8000476c:	04449703          	lh	a4,68(s1)
    80004770:	4785                	li	a5,1
    80004772:	08f70a63          	beq	a4,a5,80004806 <removeSwapFile+0x152>
      iunlockput(ip);
      goto bad;
    }

    memset(&de, 0, sizeof(de));
    80004776:	4641                	li	a2,16
    80004778:	4581                	li	a1,0
    8000477a:	fc040513          	addi	a0,s0,-64
    8000477e:	ffffc097          	auipc	ra,0xffffc
    80004782:	540080e7          	jalr	1344(ra) # 80000cbe <memset>
    if(writei(dp,0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004786:	4741                	li	a4,16
    80004788:	fac42683          	lw	a3,-84(s0)
    8000478c:	fc040613          	addi	a2,s0,-64
    80004790:	4581                	li	a1,0
    80004792:	854a                	mv	a0,s2
    80004794:	00000097          	auipc	ra,0x0
    80004798:	a6a080e7          	jalr	-1430(ra) # 800041fe <writei>
    8000479c:	47c1                	li	a5,16
    8000479e:	08f51a63          	bne	a0,a5,80004832 <removeSwapFile+0x17e>
      panic("unlink: writei");
    if(ip->type == T_DIR){
    800047a2:	04449703          	lh	a4,68(s1)
    800047a6:	4785                	li	a5,1
    800047a8:	08f70d63          	beq	a4,a5,80004842 <removeSwapFile+0x18e>
      dp->nlink--;
      iupdate(dp);
    }
    iunlockput(dp);
    800047ac:	854a                	mv	a0,s2
    800047ae:	00000097          	auipc	ra,0x0
    800047b2:	906080e7          	jalr	-1786(ra) # 800040b4 <iunlockput>

    ip->nlink--;
    800047b6:	04a4d783          	lhu	a5,74(s1)
    800047ba:	37fd                	addiw	a5,a5,-1
    800047bc:	04f49523          	sh	a5,74(s1)
    iupdate(ip);
    800047c0:	8526                	mv	a0,s1
    800047c2:	fffff097          	auipc	ra,0xfffff
    800047c6:	5c6080e7          	jalr	1478(ra) # 80003d88 <iupdate>
    iunlockput(ip);
    800047ca:	8526                	mv	a0,s1
    800047cc:	00000097          	auipc	ra,0x0
    800047d0:	8e8080e7          	jalr	-1816(ra) # 800040b4 <iunlockput>

    end_op();
    800047d4:	00000097          	auipc	ra,0x0
    800047d8:	40c080e7          	jalr	1036(ra) # 80004be0 <end_op>

    return 0;
    800047dc:	4501                	li	a0,0
    bad:
      iunlockput(dp);
      end_op();
      return -1;

  }
    800047de:	60e6                	ld	ra,88(sp)
    800047e0:	6446                	ld	s0,80(sp)
    800047e2:	64a6                	ld	s1,72(sp)
    800047e4:	6906                	ld	s2,64(sp)
    800047e6:	6125                	addi	sp,sp,96
    800047e8:	8082                	ret
      end_op();
    800047ea:	00000097          	auipc	ra,0x0
    800047ee:	3f6080e7          	jalr	1014(ra) # 80004be0 <end_op>
      return -1;
    800047f2:	557d                	li	a0,-1
    800047f4:	b7ed                	j	800047de <removeSwapFile+0x12a>
      panic("unlink: nlink < 1");
    800047f6:	00005517          	auipc	a0,0x5
    800047fa:	14250513          	addi	a0,a0,322 # 80009938 <syscalls+0x208>
    800047fe:	ffffc097          	auipc	ra,0xffffc
    80004802:	d2c080e7          	jalr	-724(ra) # 8000052a <panic>
    if(ip->type == T_DIR && !isdirempty(ip)){
    80004806:	8526                	mv	a0,s1
    80004808:	00002097          	auipc	ra,0x2
    8000480c:	93e080e7          	jalr	-1730(ra) # 80006146 <isdirempty>
    80004810:	f13d                	bnez	a0,80004776 <removeSwapFile+0xc2>
      iunlockput(ip);
    80004812:	8526                	mv	a0,s1
    80004814:	00000097          	auipc	ra,0x0
    80004818:	8a0080e7          	jalr	-1888(ra) # 800040b4 <iunlockput>
      iunlockput(dp);
    8000481c:	854a                	mv	a0,s2
    8000481e:	00000097          	auipc	ra,0x0
    80004822:	896080e7          	jalr	-1898(ra) # 800040b4 <iunlockput>
      end_op();
    80004826:	00000097          	auipc	ra,0x0
    8000482a:	3ba080e7          	jalr	954(ra) # 80004be0 <end_op>
      return -1;
    8000482e:	557d                	li	a0,-1
    80004830:	b77d                	j	800047de <removeSwapFile+0x12a>
      panic("unlink: writei");
    80004832:	00005517          	auipc	a0,0x5
    80004836:	11e50513          	addi	a0,a0,286 # 80009950 <syscalls+0x220>
    8000483a:	ffffc097          	auipc	ra,0xffffc
    8000483e:	cf0080e7          	jalr	-784(ra) # 8000052a <panic>
      dp->nlink--;
    80004842:	04a95783          	lhu	a5,74(s2)
    80004846:	37fd                	addiw	a5,a5,-1
    80004848:	04f91523          	sh	a5,74(s2)
      iupdate(dp);
    8000484c:	854a                	mv	a0,s2
    8000484e:	fffff097          	auipc	ra,0xfffff
    80004852:	53a080e7          	jalr	1338(ra) # 80003d88 <iupdate>
    80004856:	bf99                	j	800047ac <removeSwapFile+0xf8>
      return -1;
    80004858:	557d                	li	a0,-1
    8000485a:	b751                	j	800047de <removeSwapFile+0x12a>

000000008000485c <createSwapFile>:


  //return 0 on success
  int
  createSwapFile(struct proc* p)
  {
    8000485c:	7179                	addi	sp,sp,-48
    8000485e:	f406                	sd	ra,40(sp)
    80004860:	f022                	sd	s0,32(sp)
    80004862:	ec26                	sd	s1,24(sp)
    80004864:	e84a                	sd	s2,16(sp)
    80004866:	1800                	addi	s0,sp,48
    80004868:	84aa                	mv	s1,a0

    char path[DIGITS];
    memmove(path,"/.swap", 6);
    8000486a:	4619                	li	a2,6
    8000486c:	00005597          	auipc	a1,0x5
    80004870:	0b458593          	addi	a1,a1,180 # 80009920 <syscalls+0x1f0>
    80004874:	fd040513          	addi	a0,s0,-48
    80004878:	ffffc097          	auipc	ra,0xffffc
    8000487c:	4a2080e7          	jalr	1186(ra) # 80000d1a <memmove>
    itoa(p->pid, path+ 6);
    80004880:	fd640593          	addi	a1,s0,-42
    80004884:	5888                	lw	a0,48(s1)
    80004886:	00000097          	auipc	ra,0x0
    8000488a:	dbc080e7          	jalr	-580(ra) # 80004642 <itoa>

    begin_op();
    8000488e:	00000097          	auipc	ra,0x0
    80004892:	2d2080e7          	jalr	722(ra) # 80004b60 <begin_op>
    
    struct inode * in = create(path, T_FILE, 0, 0);
    80004896:	4681                	li	a3,0
    80004898:	4601                	li	a2,0
    8000489a:	4589                	li	a1,2
    8000489c:	fd040513          	addi	a0,s0,-48
    800048a0:	00002097          	auipc	ra,0x2
    800048a4:	a9a080e7          	jalr	-1382(ra) # 8000633a <create>
    800048a8:	892a                	mv	s2,a0
    iunlock(in);
    800048aa:	fffff097          	auipc	ra,0xfffff
    800048ae:	66a080e7          	jalr	1642(ra) # 80003f14 <iunlock>
    p->swapFile = filealloc();
    800048b2:	00000097          	auipc	ra,0x0
    800048b6:	6be080e7          	jalr	1726(ra) # 80004f70 <filealloc>
    800048ba:	16a4b423          	sd	a0,360(s1)
    if (p->swapFile == 0)
    800048be:	cd1d                	beqz	a0,800048fc <createSwapFile+0xa0>
      panic("no slot for files on /store");

    p->swapFile->ip = in;
    800048c0:	01253c23          	sd	s2,24(a0)
    p->swapFile->type = FD_INODE;
    800048c4:	1684b703          	ld	a4,360(s1)
    800048c8:	4789                	li	a5,2
    800048ca:	c31c                	sw	a5,0(a4)
    p->swapFile->off = 0;
    800048cc:	1684b703          	ld	a4,360(s1)
    800048d0:	02072023          	sw	zero,32(a4) # 43020 <_entry-0x7ffbcfe0>
    p->swapFile->readable = O_WRONLY;
    800048d4:	1684b703          	ld	a4,360(s1)
    800048d8:	4685                	li	a3,1
    800048da:	00d70423          	sb	a3,8(a4)
    p->swapFile->writable = O_RDWR;
    800048de:	1684b703          	ld	a4,360(s1)
    800048e2:	00f704a3          	sb	a5,9(a4)
      end_op();
    800048e6:	00000097          	auipc	ra,0x0
    800048ea:	2fa080e7          	jalr	762(ra) # 80004be0 <end_op>

      return 0;
  }
    800048ee:	4501                	li	a0,0
    800048f0:	70a2                	ld	ra,40(sp)
    800048f2:	7402                	ld	s0,32(sp)
    800048f4:	64e2                	ld	s1,24(sp)
    800048f6:	6942                	ld	s2,16(sp)
    800048f8:	6145                	addi	sp,sp,48
    800048fa:	8082                	ret
      panic("no slot for files on /store");
    800048fc:	00005517          	auipc	a0,0x5
    80004900:	06450513          	addi	a0,a0,100 # 80009960 <syscalls+0x230>
    80004904:	ffffc097          	auipc	ra,0xffffc
    80004908:	c26080e7          	jalr	-986(ra) # 8000052a <panic>

000000008000490c <writeToSwapFile>:

  //return as sys_write (-1 when error)
  int
  writeToSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
  {
    8000490c:	7179                	addi	sp,sp,-48
    8000490e:	f406                	sd	ra,40(sp)
    80004910:	f022                	sd	s0,32(sp)
    80004912:	ec26                	sd	s1,24(sp)
    80004914:	e84a                	sd	s2,16(sp)
    80004916:	e44e                	sd	s3,8(sp)
    80004918:	1800                	addi	s0,sp,48
    8000491a:	892a                	mv	s2,a0
    8000491c:	84b2                	mv	s1,a2
    8000491e:	89b6                	mv	s3,a3
    p->swapFile->off = placeOnFile;
    80004920:	16853783          	ld	a5,360(a0)
    80004924:	d390                	sw	a2,32(a5)
    int returnval = kfilewrite(p->swapFile, (uint64)buffer, size);
    80004926:	8636                	mv	a2,a3
    80004928:	16853503          	ld	a0,360(a0)
    8000492c:	00001097          	auipc	ra,0x1
    80004930:	af2080e7          	jalr	-1294(ra) # 8000541e <kfilewrite>
    if (p->swapOffset < placeOnFile + size){
    80004934:	013484bb          	addw	s1,s1,s3
    80004938:	0004879b          	sext.w	a5,s1
    8000493c:	17092703          	lw	a4,368(s2)
    80004940:	00f77463          	bgeu	a4,a5,80004948 <writeToSwapFile+0x3c>
      p->swapOffset = placeOnFile + size;
    80004944:	16992823          	sw	s1,368(s2)
    }
    return returnval;
  }
    80004948:	70a2                	ld	ra,40(sp)
    8000494a:	7402                	ld	s0,32(sp)
    8000494c:	64e2                	ld	s1,24(sp)
    8000494e:	6942                	ld	s2,16(sp)
    80004950:	69a2                	ld	s3,8(sp)
    80004952:	6145                	addi	sp,sp,48
    80004954:	8082                	ret

0000000080004956 <readFromSwapFile>:

  //return as sys_read (-1 when error)
  int
  readFromSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
  {
    80004956:	1141                	addi	sp,sp,-16
    80004958:	e406                	sd	ra,8(sp)
    8000495a:	e022                	sd	s0,0(sp)
    8000495c:	0800                	addi	s0,sp,16

    p->swapFile->off = placeOnFile;
    8000495e:	16853783          	ld	a5,360(a0)
    80004962:	d390                	sw	a2,32(a5)

    return kfileread(p->swapFile, (uint64)buffer,  size);
    80004964:	8636                	mv	a2,a3
    80004966:	16853503          	ld	a0,360(a0)
    8000496a:	00001097          	auipc	ra,0x1
    8000496e:	9f2080e7          	jalr	-1550(ra) # 8000535c <kfileread>
  }
    80004972:	60a2                	ld	ra,8(sp)
    80004974:	6402                	ld	s0,0(sp)
    80004976:	0141                	addi	sp,sp,16
    80004978:	8082                	ret

000000008000497a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000497a:	1101                	addi	sp,sp,-32
    8000497c:	ec06                	sd	ra,24(sp)
    8000497e:	e822                	sd	s0,16(sp)
    80004980:	e426                	sd	s1,8(sp)
    80004982:	e04a                	sd	s2,0(sp)
    80004984:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004986:	0002a917          	auipc	s2,0x2a
    8000498a:	6ea90913          	addi	s2,s2,1770 # 8002f070 <log>
    8000498e:	01892583          	lw	a1,24(s2)
    80004992:	02892503          	lw	a0,40(s2)
    80004996:	fffff097          	auipc	ra,0xfffff
    8000499a:	cb8080e7          	jalr	-840(ra) # 8000364e <bread>
    8000499e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800049a0:	02c92683          	lw	a3,44(s2)
    800049a4:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800049a6:	02d05863          	blez	a3,800049d6 <write_head+0x5c>
    800049aa:	0002a797          	auipc	a5,0x2a
    800049ae:	6f678793          	addi	a5,a5,1782 # 8002f0a0 <log+0x30>
    800049b2:	05c50713          	addi	a4,a0,92
    800049b6:	36fd                	addiw	a3,a3,-1
    800049b8:	02069613          	slli	a2,a3,0x20
    800049bc:	01e65693          	srli	a3,a2,0x1e
    800049c0:	0002a617          	auipc	a2,0x2a
    800049c4:	6e460613          	addi	a2,a2,1764 # 8002f0a4 <log+0x34>
    800049c8:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800049ca:	4390                	lw	a2,0(a5)
    800049cc:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800049ce:	0791                	addi	a5,a5,4
    800049d0:	0711                	addi	a4,a4,4
    800049d2:	fed79ce3          	bne	a5,a3,800049ca <write_head+0x50>
  }
  bwrite(buf);
    800049d6:	8526                	mv	a0,s1
    800049d8:	fffff097          	auipc	ra,0xfffff
    800049dc:	d68080e7          	jalr	-664(ra) # 80003740 <bwrite>
  brelse(buf);
    800049e0:	8526                	mv	a0,s1
    800049e2:	fffff097          	auipc	ra,0xfffff
    800049e6:	d9c080e7          	jalr	-612(ra) # 8000377e <brelse>
}
    800049ea:	60e2                	ld	ra,24(sp)
    800049ec:	6442                	ld	s0,16(sp)
    800049ee:	64a2                	ld	s1,8(sp)
    800049f0:	6902                	ld	s2,0(sp)
    800049f2:	6105                	addi	sp,sp,32
    800049f4:	8082                	ret

00000000800049f6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800049f6:	0002a797          	auipc	a5,0x2a
    800049fa:	6a67a783          	lw	a5,1702(a5) # 8002f09c <log+0x2c>
    800049fe:	0af05d63          	blez	a5,80004ab8 <install_trans+0xc2>
{
    80004a02:	7139                	addi	sp,sp,-64
    80004a04:	fc06                	sd	ra,56(sp)
    80004a06:	f822                	sd	s0,48(sp)
    80004a08:	f426                	sd	s1,40(sp)
    80004a0a:	f04a                	sd	s2,32(sp)
    80004a0c:	ec4e                	sd	s3,24(sp)
    80004a0e:	e852                	sd	s4,16(sp)
    80004a10:	e456                	sd	s5,8(sp)
    80004a12:	e05a                	sd	s6,0(sp)
    80004a14:	0080                	addi	s0,sp,64
    80004a16:	8b2a                	mv	s6,a0
    80004a18:	0002aa97          	auipc	s5,0x2a
    80004a1c:	688a8a93          	addi	s5,s5,1672 # 8002f0a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a20:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004a22:	0002a997          	auipc	s3,0x2a
    80004a26:	64e98993          	addi	s3,s3,1614 # 8002f070 <log>
    80004a2a:	a00d                	j	80004a4c <install_trans+0x56>
    brelse(lbuf);
    80004a2c:	854a                	mv	a0,s2
    80004a2e:	fffff097          	auipc	ra,0xfffff
    80004a32:	d50080e7          	jalr	-688(ra) # 8000377e <brelse>
    brelse(dbuf);
    80004a36:	8526                	mv	a0,s1
    80004a38:	fffff097          	auipc	ra,0xfffff
    80004a3c:	d46080e7          	jalr	-698(ra) # 8000377e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a40:	2a05                	addiw	s4,s4,1
    80004a42:	0a91                	addi	s5,s5,4
    80004a44:	02c9a783          	lw	a5,44(s3)
    80004a48:	04fa5e63          	bge	s4,a5,80004aa4 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004a4c:	0189a583          	lw	a1,24(s3)
    80004a50:	014585bb          	addw	a1,a1,s4
    80004a54:	2585                	addiw	a1,a1,1
    80004a56:	0289a503          	lw	a0,40(s3)
    80004a5a:	fffff097          	auipc	ra,0xfffff
    80004a5e:	bf4080e7          	jalr	-1036(ra) # 8000364e <bread>
    80004a62:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004a64:	000aa583          	lw	a1,0(s5)
    80004a68:	0289a503          	lw	a0,40(s3)
    80004a6c:	fffff097          	auipc	ra,0xfffff
    80004a70:	be2080e7          	jalr	-1054(ra) # 8000364e <bread>
    80004a74:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004a76:	40000613          	li	a2,1024
    80004a7a:	05890593          	addi	a1,s2,88
    80004a7e:	05850513          	addi	a0,a0,88
    80004a82:	ffffc097          	auipc	ra,0xffffc
    80004a86:	298080e7          	jalr	664(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004a8a:	8526                	mv	a0,s1
    80004a8c:	fffff097          	auipc	ra,0xfffff
    80004a90:	cb4080e7          	jalr	-844(ra) # 80003740 <bwrite>
    if(recovering == 0)
    80004a94:	f80b1ce3          	bnez	s6,80004a2c <install_trans+0x36>
      bunpin(dbuf);
    80004a98:	8526                	mv	a0,s1
    80004a9a:	fffff097          	auipc	ra,0xfffff
    80004a9e:	dbe080e7          	jalr	-578(ra) # 80003858 <bunpin>
    80004aa2:	b769                	j	80004a2c <install_trans+0x36>
}
    80004aa4:	70e2                	ld	ra,56(sp)
    80004aa6:	7442                	ld	s0,48(sp)
    80004aa8:	74a2                	ld	s1,40(sp)
    80004aaa:	7902                	ld	s2,32(sp)
    80004aac:	69e2                	ld	s3,24(sp)
    80004aae:	6a42                	ld	s4,16(sp)
    80004ab0:	6aa2                	ld	s5,8(sp)
    80004ab2:	6b02                	ld	s6,0(sp)
    80004ab4:	6121                	addi	sp,sp,64
    80004ab6:	8082                	ret
    80004ab8:	8082                	ret

0000000080004aba <initlog>:
{
    80004aba:	7179                	addi	sp,sp,-48
    80004abc:	f406                	sd	ra,40(sp)
    80004abe:	f022                	sd	s0,32(sp)
    80004ac0:	ec26                	sd	s1,24(sp)
    80004ac2:	e84a                	sd	s2,16(sp)
    80004ac4:	e44e                	sd	s3,8(sp)
    80004ac6:	1800                	addi	s0,sp,48
    80004ac8:	892a                	mv	s2,a0
    80004aca:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004acc:	0002a497          	auipc	s1,0x2a
    80004ad0:	5a448493          	addi	s1,s1,1444 # 8002f070 <log>
    80004ad4:	00005597          	auipc	a1,0x5
    80004ad8:	eac58593          	addi	a1,a1,-340 # 80009980 <syscalls+0x250>
    80004adc:	8526                	mv	a0,s1
    80004ade:	ffffc097          	auipc	ra,0xffffc
    80004ae2:	054080e7          	jalr	84(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    80004ae6:	0149a583          	lw	a1,20(s3)
    80004aea:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004aec:	0109a783          	lw	a5,16(s3)
    80004af0:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004af2:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004af6:	854a                	mv	a0,s2
    80004af8:	fffff097          	auipc	ra,0xfffff
    80004afc:	b56080e7          	jalr	-1194(ra) # 8000364e <bread>
  log.lh.n = lh->n;
    80004b00:	4d34                	lw	a3,88(a0)
    80004b02:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004b04:	02d05663          	blez	a3,80004b30 <initlog+0x76>
    80004b08:	05c50793          	addi	a5,a0,92
    80004b0c:	0002a717          	auipc	a4,0x2a
    80004b10:	59470713          	addi	a4,a4,1428 # 8002f0a0 <log+0x30>
    80004b14:	36fd                	addiw	a3,a3,-1
    80004b16:	02069613          	slli	a2,a3,0x20
    80004b1a:	01e65693          	srli	a3,a2,0x1e
    80004b1e:	06050613          	addi	a2,a0,96
    80004b22:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004b24:	4390                	lw	a2,0(a5)
    80004b26:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004b28:	0791                	addi	a5,a5,4
    80004b2a:	0711                	addi	a4,a4,4
    80004b2c:	fed79ce3          	bne	a5,a3,80004b24 <initlog+0x6a>
  brelse(buf);
    80004b30:	fffff097          	auipc	ra,0xfffff
    80004b34:	c4e080e7          	jalr	-946(ra) # 8000377e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004b38:	4505                	li	a0,1
    80004b3a:	00000097          	auipc	ra,0x0
    80004b3e:	ebc080e7          	jalr	-324(ra) # 800049f6 <install_trans>
  log.lh.n = 0;
    80004b42:	0002a797          	auipc	a5,0x2a
    80004b46:	5407ad23          	sw	zero,1370(a5) # 8002f09c <log+0x2c>
  write_head(); // clear the log
    80004b4a:	00000097          	auipc	ra,0x0
    80004b4e:	e30080e7          	jalr	-464(ra) # 8000497a <write_head>
}
    80004b52:	70a2                	ld	ra,40(sp)
    80004b54:	7402                	ld	s0,32(sp)
    80004b56:	64e2                	ld	s1,24(sp)
    80004b58:	6942                	ld	s2,16(sp)
    80004b5a:	69a2                	ld	s3,8(sp)
    80004b5c:	6145                	addi	sp,sp,48
    80004b5e:	8082                	ret

0000000080004b60 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004b60:	1101                	addi	sp,sp,-32
    80004b62:	ec06                	sd	ra,24(sp)
    80004b64:	e822                	sd	s0,16(sp)
    80004b66:	e426                	sd	s1,8(sp)
    80004b68:	e04a                	sd	s2,0(sp)
    80004b6a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004b6c:	0002a517          	auipc	a0,0x2a
    80004b70:	50450513          	addi	a0,a0,1284 # 8002f070 <log>
    80004b74:	ffffc097          	auipc	ra,0xffffc
    80004b78:	04e080e7          	jalr	78(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    80004b7c:	0002a497          	auipc	s1,0x2a
    80004b80:	4f448493          	addi	s1,s1,1268 # 8002f070 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004b84:	4979                	li	s2,30
    80004b86:	a039                	j	80004b94 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004b88:	85a6                	mv	a1,s1
    80004b8a:	8526                	mv	a0,s1
    80004b8c:	ffffe097          	auipc	ra,0xffffe
    80004b90:	ae6080e7          	jalr	-1306(ra) # 80002672 <sleep>
    if(log.committing){
    80004b94:	50dc                	lw	a5,36(s1)
    80004b96:	fbed                	bnez	a5,80004b88 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004b98:	509c                	lw	a5,32(s1)
    80004b9a:	0017871b          	addiw	a4,a5,1
    80004b9e:	0007069b          	sext.w	a3,a4
    80004ba2:	0027179b          	slliw	a5,a4,0x2
    80004ba6:	9fb9                	addw	a5,a5,a4
    80004ba8:	0017979b          	slliw	a5,a5,0x1
    80004bac:	54d8                	lw	a4,44(s1)
    80004bae:	9fb9                	addw	a5,a5,a4
    80004bb0:	00f95963          	bge	s2,a5,80004bc2 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004bb4:	85a6                	mv	a1,s1
    80004bb6:	8526                	mv	a0,s1
    80004bb8:	ffffe097          	auipc	ra,0xffffe
    80004bbc:	aba080e7          	jalr	-1350(ra) # 80002672 <sleep>
    80004bc0:	bfd1                	j	80004b94 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004bc2:	0002a517          	auipc	a0,0x2a
    80004bc6:	4ae50513          	addi	a0,a0,1198 # 8002f070 <log>
    80004bca:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004bcc:	ffffc097          	auipc	ra,0xffffc
    80004bd0:	0aa080e7          	jalr	170(ra) # 80000c76 <release>
      break;
    }
  }
}
    80004bd4:	60e2                	ld	ra,24(sp)
    80004bd6:	6442                	ld	s0,16(sp)
    80004bd8:	64a2                	ld	s1,8(sp)
    80004bda:	6902                	ld	s2,0(sp)
    80004bdc:	6105                	addi	sp,sp,32
    80004bde:	8082                	ret

0000000080004be0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004be0:	7139                	addi	sp,sp,-64
    80004be2:	fc06                	sd	ra,56(sp)
    80004be4:	f822                	sd	s0,48(sp)
    80004be6:	f426                	sd	s1,40(sp)
    80004be8:	f04a                	sd	s2,32(sp)
    80004bea:	ec4e                	sd	s3,24(sp)
    80004bec:	e852                	sd	s4,16(sp)
    80004bee:	e456                	sd	s5,8(sp)
    80004bf0:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004bf2:	0002a497          	auipc	s1,0x2a
    80004bf6:	47e48493          	addi	s1,s1,1150 # 8002f070 <log>
    80004bfa:	8526                	mv	a0,s1
    80004bfc:	ffffc097          	auipc	ra,0xffffc
    80004c00:	fc6080e7          	jalr	-58(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    80004c04:	509c                	lw	a5,32(s1)
    80004c06:	37fd                	addiw	a5,a5,-1
    80004c08:	0007891b          	sext.w	s2,a5
    80004c0c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004c0e:	50dc                	lw	a5,36(s1)
    80004c10:	e7b9                	bnez	a5,80004c5e <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004c12:	04091e63          	bnez	s2,80004c6e <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004c16:	0002a497          	auipc	s1,0x2a
    80004c1a:	45a48493          	addi	s1,s1,1114 # 8002f070 <log>
    80004c1e:	4785                	li	a5,1
    80004c20:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004c22:	8526                	mv	a0,s1
    80004c24:	ffffc097          	auipc	ra,0xffffc
    80004c28:	052080e7          	jalr	82(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004c2c:	54dc                	lw	a5,44(s1)
    80004c2e:	06f04763          	bgtz	a5,80004c9c <end_op+0xbc>
    acquire(&log.lock);
    80004c32:	0002a497          	auipc	s1,0x2a
    80004c36:	43e48493          	addi	s1,s1,1086 # 8002f070 <log>
    80004c3a:	8526                	mv	a0,s1
    80004c3c:	ffffc097          	auipc	ra,0xffffc
    80004c40:	f86080e7          	jalr	-122(ra) # 80000bc2 <acquire>
    log.committing = 0;
    80004c44:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004c48:	8526                	mv	a0,s1
    80004c4a:	ffffe097          	auipc	ra,0xffffe
    80004c4e:	bb4080e7          	jalr	-1100(ra) # 800027fe <wakeup>
    release(&log.lock);
    80004c52:	8526                	mv	a0,s1
    80004c54:	ffffc097          	auipc	ra,0xffffc
    80004c58:	022080e7          	jalr	34(ra) # 80000c76 <release>
}
    80004c5c:	a03d                	j	80004c8a <end_op+0xaa>
    panic("log.committing");
    80004c5e:	00005517          	auipc	a0,0x5
    80004c62:	d2a50513          	addi	a0,a0,-726 # 80009988 <syscalls+0x258>
    80004c66:	ffffc097          	auipc	ra,0xffffc
    80004c6a:	8c4080e7          	jalr	-1852(ra) # 8000052a <panic>
    wakeup(&log);
    80004c6e:	0002a497          	auipc	s1,0x2a
    80004c72:	40248493          	addi	s1,s1,1026 # 8002f070 <log>
    80004c76:	8526                	mv	a0,s1
    80004c78:	ffffe097          	auipc	ra,0xffffe
    80004c7c:	b86080e7          	jalr	-1146(ra) # 800027fe <wakeup>
  release(&log.lock);
    80004c80:	8526                	mv	a0,s1
    80004c82:	ffffc097          	auipc	ra,0xffffc
    80004c86:	ff4080e7          	jalr	-12(ra) # 80000c76 <release>
}
    80004c8a:	70e2                	ld	ra,56(sp)
    80004c8c:	7442                	ld	s0,48(sp)
    80004c8e:	74a2                	ld	s1,40(sp)
    80004c90:	7902                	ld	s2,32(sp)
    80004c92:	69e2                	ld	s3,24(sp)
    80004c94:	6a42                	ld	s4,16(sp)
    80004c96:	6aa2                	ld	s5,8(sp)
    80004c98:	6121                	addi	sp,sp,64
    80004c9a:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004c9c:	0002aa97          	auipc	s5,0x2a
    80004ca0:	404a8a93          	addi	s5,s5,1028 # 8002f0a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004ca4:	0002aa17          	auipc	s4,0x2a
    80004ca8:	3cca0a13          	addi	s4,s4,972 # 8002f070 <log>
    80004cac:	018a2583          	lw	a1,24(s4)
    80004cb0:	012585bb          	addw	a1,a1,s2
    80004cb4:	2585                	addiw	a1,a1,1
    80004cb6:	028a2503          	lw	a0,40(s4)
    80004cba:	fffff097          	auipc	ra,0xfffff
    80004cbe:	994080e7          	jalr	-1644(ra) # 8000364e <bread>
    80004cc2:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004cc4:	000aa583          	lw	a1,0(s5)
    80004cc8:	028a2503          	lw	a0,40(s4)
    80004ccc:	fffff097          	auipc	ra,0xfffff
    80004cd0:	982080e7          	jalr	-1662(ra) # 8000364e <bread>
    80004cd4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004cd6:	40000613          	li	a2,1024
    80004cda:	05850593          	addi	a1,a0,88
    80004cde:	05848513          	addi	a0,s1,88
    80004ce2:	ffffc097          	auipc	ra,0xffffc
    80004ce6:	038080e7          	jalr	56(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    80004cea:	8526                	mv	a0,s1
    80004cec:	fffff097          	auipc	ra,0xfffff
    80004cf0:	a54080e7          	jalr	-1452(ra) # 80003740 <bwrite>
    brelse(from);
    80004cf4:	854e                	mv	a0,s3
    80004cf6:	fffff097          	auipc	ra,0xfffff
    80004cfa:	a88080e7          	jalr	-1400(ra) # 8000377e <brelse>
    brelse(to);
    80004cfe:	8526                	mv	a0,s1
    80004d00:	fffff097          	auipc	ra,0xfffff
    80004d04:	a7e080e7          	jalr	-1410(ra) # 8000377e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004d08:	2905                	addiw	s2,s2,1
    80004d0a:	0a91                	addi	s5,s5,4
    80004d0c:	02ca2783          	lw	a5,44(s4)
    80004d10:	f8f94ee3          	blt	s2,a5,80004cac <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004d14:	00000097          	auipc	ra,0x0
    80004d18:	c66080e7          	jalr	-922(ra) # 8000497a <write_head>
    install_trans(0); // Now install writes to home locations
    80004d1c:	4501                	li	a0,0
    80004d1e:	00000097          	auipc	ra,0x0
    80004d22:	cd8080e7          	jalr	-808(ra) # 800049f6 <install_trans>
    log.lh.n = 0;
    80004d26:	0002a797          	auipc	a5,0x2a
    80004d2a:	3607ab23          	sw	zero,886(a5) # 8002f09c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004d2e:	00000097          	auipc	ra,0x0
    80004d32:	c4c080e7          	jalr	-948(ra) # 8000497a <write_head>
    80004d36:	bdf5                	j	80004c32 <end_op+0x52>

0000000080004d38 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004d38:	1101                	addi	sp,sp,-32
    80004d3a:	ec06                	sd	ra,24(sp)
    80004d3c:	e822                	sd	s0,16(sp)
    80004d3e:	e426                	sd	s1,8(sp)
    80004d40:	e04a                	sd	s2,0(sp)
    80004d42:	1000                	addi	s0,sp,32
    80004d44:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004d46:	0002a917          	auipc	s2,0x2a
    80004d4a:	32a90913          	addi	s2,s2,810 # 8002f070 <log>
    80004d4e:	854a                	mv	a0,s2
    80004d50:	ffffc097          	auipc	ra,0xffffc
    80004d54:	e72080e7          	jalr	-398(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004d58:	02c92603          	lw	a2,44(s2)
    80004d5c:	47f5                	li	a5,29
    80004d5e:	06c7c563          	blt	a5,a2,80004dc8 <log_write+0x90>
    80004d62:	0002a797          	auipc	a5,0x2a
    80004d66:	32a7a783          	lw	a5,810(a5) # 8002f08c <log+0x1c>
    80004d6a:	37fd                	addiw	a5,a5,-1
    80004d6c:	04f65e63          	bge	a2,a5,80004dc8 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004d70:	0002a797          	auipc	a5,0x2a
    80004d74:	3207a783          	lw	a5,800(a5) # 8002f090 <log+0x20>
    80004d78:	06f05063          	blez	a5,80004dd8 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004d7c:	4781                	li	a5,0
    80004d7e:	06c05563          	blez	a2,80004de8 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004d82:	44cc                	lw	a1,12(s1)
    80004d84:	0002a717          	auipc	a4,0x2a
    80004d88:	31c70713          	addi	a4,a4,796 # 8002f0a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004d8c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004d8e:	4314                	lw	a3,0(a4)
    80004d90:	04b68c63          	beq	a3,a1,80004de8 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004d94:	2785                	addiw	a5,a5,1
    80004d96:	0711                	addi	a4,a4,4
    80004d98:	fef61be3          	bne	a2,a5,80004d8e <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004d9c:	0621                	addi	a2,a2,8
    80004d9e:	060a                	slli	a2,a2,0x2
    80004da0:	0002a797          	auipc	a5,0x2a
    80004da4:	2d078793          	addi	a5,a5,720 # 8002f070 <log>
    80004da8:	963e                	add	a2,a2,a5
    80004daa:	44dc                	lw	a5,12(s1)
    80004dac:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004dae:	8526                	mv	a0,s1
    80004db0:	fffff097          	auipc	ra,0xfffff
    80004db4:	a6c080e7          	jalr	-1428(ra) # 8000381c <bpin>
    log.lh.n++;
    80004db8:	0002a717          	auipc	a4,0x2a
    80004dbc:	2b870713          	addi	a4,a4,696 # 8002f070 <log>
    80004dc0:	575c                	lw	a5,44(a4)
    80004dc2:	2785                	addiw	a5,a5,1
    80004dc4:	d75c                	sw	a5,44(a4)
    80004dc6:	a835                	j	80004e02 <log_write+0xca>
    panic("too big a transaction");
    80004dc8:	00005517          	auipc	a0,0x5
    80004dcc:	bd050513          	addi	a0,a0,-1072 # 80009998 <syscalls+0x268>
    80004dd0:	ffffb097          	auipc	ra,0xffffb
    80004dd4:	75a080e7          	jalr	1882(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    80004dd8:	00005517          	auipc	a0,0x5
    80004ddc:	bd850513          	addi	a0,a0,-1064 # 800099b0 <syscalls+0x280>
    80004de0:	ffffb097          	auipc	ra,0xffffb
    80004de4:	74a080e7          	jalr	1866(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80004de8:	00878713          	addi	a4,a5,8
    80004dec:	00271693          	slli	a3,a4,0x2
    80004df0:	0002a717          	auipc	a4,0x2a
    80004df4:	28070713          	addi	a4,a4,640 # 8002f070 <log>
    80004df8:	9736                	add	a4,a4,a3
    80004dfa:	44d4                	lw	a3,12(s1)
    80004dfc:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004dfe:	faf608e3          	beq	a2,a5,80004dae <log_write+0x76>
  }
  release(&log.lock);
    80004e02:	0002a517          	auipc	a0,0x2a
    80004e06:	26e50513          	addi	a0,a0,622 # 8002f070 <log>
    80004e0a:	ffffc097          	auipc	ra,0xffffc
    80004e0e:	e6c080e7          	jalr	-404(ra) # 80000c76 <release>
}
    80004e12:	60e2                	ld	ra,24(sp)
    80004e14:	6442                	ld	s0,16(sp)
    80004e16:	64a2                	ld	s1,8(sp)
    80004e18:	6902                	ld	s2,0(sp)
    80004e1a:	6105                	addi	sp,sp,32
    80004e1c:	8082                	ret

0000000080004e1e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004e1e:	1101                	addi	sp,sp,-32
    80004e20:	ec06                	sd	ra,24(sp)
    80004e22:	e822                	sd	s0,16(sp)
    80004e24:	e426                	sd	s1,8(sp)
    80004e26:	e04a                	sd	s2,0(sp)
    80004e28:	1000                	addi	s0,sp,32
    80004e2a:	84aa                	mv	s1,a0
    80004e2c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004e2e:	00005597          	auipc	a1,0x5
    80004e32:	ba258593          	addi	a1,a1,-1118 # 800099d0 <syscalls+0x2a0>
    80004e36:	0521                	addi	a0,a0,8
    80004e38:	ffffc097          	auipc	ra,0xffffc
    80004e3c:	cfa080e7          	jalr	-774(ra) # 80000b32 <initlock>
  lk->name = name;
    80004e40:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004e44:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004e48:	0204a423          	sw	zero,40(s1)
}
    80004e4c:	60e2                	ld	ra,24(sp)
    80004e4e:	6442                	ld	s0,16(sp)
    80004e50:	64a2                	ld	s1,8(sp)
    80004e52:	6902                	ld	s2,0(sp)
    80004e54:	6105                	addi	sp,sp,32
    80004e56:	8082                	ret

0000000080004e58 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004e58:	1101                	addi	sp,sp,-32
    80004e5a:	ec06                	sd	ra,24(sp)
    80004e5c:	e822                	sd	s0,16(sp)
    80004e5e:	e426                	sd	s1,8(sp)
    80004e60:	e04a                	sd	s2,0(sp)
    80004e62:	1000                	addi	s0,sp,32
    80004e64:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004e66:	00850913          	addi	s2,a0,8
    80004e6a:	854a                	mv	a0,s2
    80004e6c:	ffffc097          	auipc	ra,0xffffc
    80004e70:	d56080e7          	jalr	-682(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    80004e74:	409c                	lw	a5,0(s1)
    80004e76:	cb89                	beqz	a5,80004e88 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004e78:	85ca                	mv	a1,s2
    80004e7a:	8526                	mv	a0,s1
    80004e7c:	ffffd097          	auipc	ra,0xffffd
    80004e80:	7f6080e7          	jalr	2038(ra) # 80002672 <sleep>
  while (lk->locked) {
    80004e84:	409c                	lw	a5,0(s1)
    80004e86:	fbed                	bnez	a5,80004e78 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004e88:	4785                	li	a5,1
    80004e8a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004e8c:	ffffd097          	auipc	ra,0xffffd
    80004e90:	f26080e7          	jalr	-218(ra) # 80001db2 <myproc>
    80004e94:	591c                	lw	a5,48(a0)
    80004e96:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004e98:	854a                	mv	a0,s2
    80004e9a:	ffffc097          	auipc	ra,0xffffc
    80004e9e:	ddc080e7          	jalr	-548(ra) # 80000c76 <release>
}
    80004ea2:	60e2                	ld	ra,24(sp)
    80004ea4:	6442                	ld	s0,16(sp)
    80004ea6:	64a2                	ld	s1,8(sp)
    80004ea8:	6902                	ld	s2,0(sp)
    80004eaa:	6105                	addi	sp,sp,32
    80004eac:	8082                	ret

0000000080004eae <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004eae:	1101                	addi	sp,sp,-32
    80004eb0:	ec06                	sd	ra,24(sp)
    80004eb2:	e822                	sd	s0,16(sp)
    80004eb4:	e426                	sd	s1,8(sp)
    80004eb6:	e04a                	sd	s2,0(sp)
    80004eb8:	1000                	addi	s0,sp,32
    80004eba:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004ebc:	00850913          	addi	s2,a0,8
    80004ec0:	854a                	mv	a0,s2
    80004ec2:	ffffc097          	auipc	ra,0xffffc
    80004ec6:	d00080e7          	jalr	-768(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    80004eca:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004ece:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004ed2:	8526                	mv	a0,s1
    80004ed4:	ffffe097          	auipc	ra,0xffffe
    80004ed8:	92a080e7          	jalr	-1750(ra) # 800027fe <wakeup>
  release(&lk->lk);
    80004edc:	854a                	mv	a0,s2
    80004ede:	ffffc097          	auipc	ra,0xffffc
    80004ee2:	d98080e7          	jalr	-616(ra) # 80000c76 <release>
}
    80004ee6:	60e2                	ld	ra,24(sp)
    80004ee8:	6442                	ld	s0,16(sp)
    80004eea:	64a2                	ld	s1,8(sp)
    80004eec:	6902                	ld	s2,0(sp)
    80004eee:	6105                	addi	sp,sp,32
    80004ef0:	8082                	ret

0000000080004ef2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004ef2:	7179                	addi	sp,sp,-48
    80004ef4:	f406                	sd	ra,40(sp)
    80004ef6:	f022                	sd	s0,32(sp)
    80004ef8:	ec26                	sd	s1,24(sp)
    80004efa:	e84a                	sd	s2,16(sp)
    80004efc:	e44e                	sd	s3,8(sp)
    80004efe:	1800                	addi	s0,sp,48
    80004f00:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004f02:	00850913          	addi	s2,a0,8
    80004f06:	854a                	mv	a0,s2
    80004f08:	ffffc097          	auipc	ra,0xffffc
    80004f0c:	cba080e7          	jalr	-838(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004f10:	409c                	lw	a5,0(s1)
    80004f12:	ef99                	bnez	a5,80004f30 <holdingsleep+0x3e>
    80004f14:	4481                	li	s1,0
  release(&lk->lk);
    80004f16:	854a                	mv	a0,s2
    80004f18:	ffffc097          	auipc	ra,0xffffc
    80004f1c:	d5e080e7          	jalr	-674(ra) # 80000c76 <release>
  return r;
}
    80004f20:	8526                	mv	a0,s1
    80004f22:	70a2                	ld	ra,40(sp)
    80004f24:	7402                	ld	s0,32(sp)
    80004f26:	64e2                	ld	s1,24(sp)
    80004f28:	6942                	ld	s2,16(sp)
    80004f2a:	69a2                	ld	s3,8(sp)
    80004f2c:	6145                	addi	sp,sp,48
    80004f2e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004f30:	0284a983          	lw	s3,40(s1)
    80004f34:	ffffd097          	auipc	ra,0xffffd
    80004f38:	e7e080e7          	jalr	-386(ra) # 80001db2 <myproc>
    80004f3c:	5904                	lw	s1,48(a0)
    80004f3e:	413484b3          	sub	s1,s1,s3
    80004f42:	0014b493          	seqz	s1,s1
    80004f46:	bfc1                	j	80004f16 <holdingsleep+0x24>

0000000080004f48 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004f48:	1141                	addi	sp,sp,-16
    80004f4a:	e406                	sd	ra,8(sp)
    80004f4c:	e022                	sd	s0,0(sp)
    80004f4e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004f50:	00005597          	auipc	a1,0x5
    80004f54:	a9058593          	addi	a1,a1,-1392 # 800099e0 <syscalls+0x2b0>
    80004f58:	0002a517          	auipc	a0,0x2a
    80004f5c:	26050513          	addi	a0,a0,608 # 8002f1b8 <ftable>
    80004f60:	ffffc097          	auipc	ra,0xffffc
    80004f64:	bd2080e7          	jalr	-1070(ra) # 80000b32 <initlock>
}
    80004f68:	60a2                	ld	ra,8(sp)
    80004f6a:	6402                	ld	s0,0(sp)
    80004f6c:	0141                	addi	sp,sp,16
    80004f6e:	8082                	ret

0000000080004f70 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004f70:	1101                	addi	sp,sp,-32
    80004f72:	ec06                	sd	ra,24(sp)
    80004f74:	e822                	sd	s0,16(sp)
    80004f76:	e426                	sd	s1,8(sp)
    80004f78:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004f7a:	0002a517          	auipc	a0,0x2a
    80004f7e:	23e50513          	addi	a0,a0,574 # 8002f1b8 <ftable>
    80004f82:	ffffc097          	auipc	ra,0xffffc
    80004f86:	c40080e7          	jalr	-960(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004f8a:	0002a497          	auipc	s1,0x2a
    80004f8e:	24648493          	addi	s1,s1,582 # 8002f1d0 <ftable+0x18>
    80004f92:	0002b717          	auipc	a4,0x2b
    80004f96:	1de70713          	addi	a4,a4,478 # 80030170 <ftable+0xfb8>
    if(f->ref == 0){
    80004f9a:	40dc                	lw	a5,4(s1)
    80004f9c:	cf99                	beqz	a5,80004fba <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004f9e:	02848493          	addi	s1,s1,40
    80004fa2:	fee49ce3          	bne	s1,a4,80004f9a <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004fa6:	0002a517          	auipc	a0,0x2a
    80004faa:	21250513          	addi	a0,a0,530 # 8002f1b8 <ftable>
    80004fae:	ffffc097          	auipc	ra,0xffffc
    80004fb2:	cc8080e7          	jalr	-824(ra) # 80000c76 <release>
  return 0;
    80004fb6:	4481                	li	s1,0
    80004fb8:	a819                	j	80004fce <filealloc+0x5e>
      f->ref = 1;
    80004fba:	4785                	li	a5,1
    80004fbc:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004fbe:	0002a517          	auipc	a0,0x2a
    80004fc2:	1fa50513          	addi	a0,a0,506 # 8002f1b8 <ftable>
    80004fc6:	ffffc097          	auipc	ra,0xffffc
    80004fca:	cb0080e7          	jalr	-848(ra) # 80000c76 <release>
}
    80004fce:	8526                	mv	a0,s1
    80004fd0:	60e2                	ld	ra,24(sp)
    80004fd2:	6442                	ld	s0,16(sp)
    80004fd4:	64a2                	ld	s1,8(sp)
    80004fd6:	6105                	addi	sp,sp,32
    80004fd8:	8082                	ret

0000000080004fda <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004fda:	1101                	addi	sp,sp,-32
    80004fdc:	ec06                	sd	ra,24(sp)
    80004fde:	e822                	sd	s0,16(sp)
    80004fe0:	e426                	sd	s1,8(sp)
    80004fe2:	1000                	addi	s0,sp,32
    80004fe4:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004fe6:	0002a517          	auipc	a0,0x2a
    80004fea:	1d250513          	addi	a0,a0,466 # 8002f1b8 <ftable>
    80004fee:	ffffc097          	auipc	ra,0xffffc
    80004ff2:	bd4080e7          	jalr	-1068(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004ff6:	40dc                	lw	a5,4(s1)
    80004ff8:	02f05263          	blez	a5,8000501c <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004ffc:	2785                	addiw	a5,a5,1
    80004ffe:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80005000:	0002a517          	auipc	a0,0x2a
    80005004:	1b850513          	addi	a0,a0,440 # 8002f1b8 <ftable>
    80005008:	ffffc097          	auipc	ra,0xffffc
    8000500c:	c6e080e7          	jalr	-914(ra) # 80000c76 <release>
  return f;
}
    80005010:	8526                	mv	a0,s1
    80005012:	60e2                	ld	ra,24(sp)
    80005014:	6442                	ld	s0,16(sp)
    80005016:	64a2                	ld	s1,8(sp)
    80005018:	6105                	addi	sp,sp,32
    8000501a:	8082                	ret
    panic("filedup");
    8000501c:	00005517          	auipc	a0,0x5
    80005020:	9cc50513          	addi	a0,a0,-1588 # 800099e8 <syscalls+0x2b8>
    80005024:	ffffb097          	auipc	ra,0xffffb
    80005028:	506080e7          	jalr	1286(ra) # 8000052a <panic>

000000008000502c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000502c:	7139                	addi	sp,sp,-64
    8000502e:	fc06                	sd	ra,56(sp)
    80005030:	f822                	sd	s0,48(sp)
    80005032:	f426                	sd	s1,40(sp)
    80005034:	f04a                	sd	s2,32(sp)
    80005036:	ec4e                	sd	s3,24(sp)
    80005038:	e852                	sd	s4,16(sp)
    8000503a:	e456                	sd	s5,8(sp)
    8000503c:	0080                	addi	s0,sp,64
    8000503e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80005040:	0002a517          	auipc	a0,0x2a
    80005044:	17850513          	addi	a0,a0,376 # 8002f1b8 <ftable>
    80005048:	ffffc097          	auipc	ra,0xffffc
    8000504c:	b7a080e7          	jalr	-1158(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80005050:	40dc                	lw	a5,4(s1)
    80005052:	06f05163          	blez	a5,800050b4 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80005056:	37fd                	addiw	a5,a5,-1
    80005058:	0007871b          	sext.w	a4,a5
    8000505c:	c0dc                	sw	a5,4(s1)
    8000505e:	06e04363          	bgtz	a4,800050c4 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80005062:	0004a903          	lw	s2,0(s1)
    80005066:	0094ca83          	lbu	s5,9(s1)
    8000506a:	0104ba03          	ld	s4,16(s1)
    8000506e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80005072:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80005076:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000507a:	0002a517          	auipc	a0,0x2a
    8000507e:	13e50513          	addi	a0,a0,318 # 8002f1b8 <ftable>
    80005082:	ffffc097          	auipc	ra,0xffffc
    80005086:	bf4080e7          	jalr	-1036(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    8000508a:	4785                	li	a5,1
    8000508c:	04f90d63          	beq	s2,a5,800050e6 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80005090:	3979                	addiw	s2,s2,-2
    80005092:	4785                	li	a5,1
    80005094:	0527e063          	bltu	a5,s2,800050d4 <fileclose+0xa8>
    begin_op();
    80005098:	00000097          	auipc	ra,0x0
    8000509c:	ac8080e7          	jalr	-1336(ra) # 80004b60 <begin_op>
    iput(ff.ip);
    800050a0:	854e                	mv	a0,s3
    800050a2:	fffff097          	auipc	ra,0xfffff
    800050a6:	f6a080e7          	jalr	-150(ra) # 8000400c <iput>
    end_op();
    800050aa:	00000097          	auipc	ra,0x0
    800050ae:	b36080e7          	jalr	-1226(ra) # 80004be0 <end_op>
    800050b2:	a00d                	j	800050d4 <fileclose+0xa8>
    panic("fileclose");
    800050b4:	00005517          	auipc	a0,0x5
    800050b8:	93c50513          	addi	a0,a0,-1732 # 800099f0 <syscalls+0x2c0>
    800050bc:	ffffb097          	auipc	ra,0xffffb
    800050c0:	46e080e7          	jalr	1134(ra) # 8000052a <panic>
    release(&ftable.lock);
    800050c4:	0002a517          	auipc	a0,0x2a
    800050c8:	0f450513          	addi	a0,a0,244 # 8002f1b8 <ftable>
    800050cc:	ffffc097          	auipc	ra,0xffffc
    800050d0:	baa080e7          	jalr	-1110(ra) # 80000c76 <release>
  }
}
    800050d4:	70e2                	ld	ra,56(sp)
    800050d6:	7442                	ld	s0,48(sp)
    800050d8:	74a2                	ld	s1,40(sp)
    800050da:	7902                	ld	s2,32(sp)
    800050dc:	69e2                	ld	s3,24(sp)
    800050de:	6a42                	ld	s4,16(sp)
    800050e0:	6aa2                	ld	s5,8(sp)
    800050e2:	6121                	addi	sp,sp,64
    800050e4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800050e6:	85d6                	mv	a1,s5
    800050e8:	8552                	mv	a0,s4
    800050ea:	00000097          	auipc	ra,0x0
    800050ee:	542080e7          	jalr	1346(ra) # 8000562c <pipeclose>
    800050f2:	b7cd                	j	800050d4 <fileclose+0xa8>

00000000800050f4 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800050f4:	715d                	addi	sp,sp,-80
    800050f6:	e486                	sd	ra,72(sp)
    800050f8:	e0a2                	sd	s0,64(sp)
    800050fa:	fc26                	sd	s1,56(sp)
    800050fc:	f84a                	sd	s2,48(sp)
    800050fe:	f44e                	sd	s3,40(sp)
    80005100:	0880                	addi	s0,sp,80
    80005102:	84aa                	mv	s1,a0
    80005104:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80005106:	ffffd097          	auipc	ra,0xffffd
    8000510a:	cac080e7          	jalr	-852(ra) # 80001db2 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000510e:	409c                	lw	a5,0(s1)
    80005110:	37f9                	addiw	a5,a5,-2
    80005112:	4705                	li	a4,1
    80005114:	04f76763          	bltu	a4,a5,80005162 <filestat+0x6e>
    80005118:	892a                	mv	s2,a0
    ilock(f->ip);
    8000511a:	6c88                	ld	a0,24(s1)
    8000511c:	fffff097          	auipc	ra,0xfffff
    80005120:	d36080e7          	jalr	-714(ra) # 80003e52 <ilock>
    stati(f->ip, &st);
    80005124:	fb840593          	addi	a1,s0,-72
    80005128:	6c88                	ld	a0,24(s1)
    8000512a:	fffff097          	auipc	ra,0xfffff
    8000512e:	fb2080e7          	jalr	-78(ra) # 800040dc <stati>
    iunlock(f->ip);
    80005132:	6c88                	ld	a0,24(s1)
    80005134:	fffff097          	auipc	ra,0xfffff
    80005138:	de0080e7          	jalr	-544(ra) # 80003f14 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000513c:	46e1                	li	a3,24
    8000513e:	fb840613          	addi	a2,s0,-72
    80005142:	85ce                	mv	a1,s3
    80005144:	05093503          	ld	a0,80(s2)
    80005148:	ffffd097          	auipc	ra,0xffffd
    8000514c:	92a080e7          	jalr	-1750(ra) # 80001a72 <copyout>
    80005150:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80005154:	60a6                	ld	ra,72(sp)
    80005156:	6406                	ld	s0,64(sp)
    80005158:	74e2                	ld	s1,56(sp)
    8000515a:	7942                	ld	s2,48(sp)
    8000515c:	79a2                	ld	s3,40(sp)
    8000515e:	6161                	addi	sp,sp,80
    80005160:	8082                	ret
  return -1;
    80005162:	557d                	li	a0,-1
    80005164:	bfc5                	j	80005154 <filestat+0x60>

0000000080005166 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80005166:	7179                	addi	sp,sp,-48
    80005168:	f406                	sd	ra,40(sp)
    8000516a:	f022                	sd	s0,32(sp)
    8000516c:	ec26                	sd	s1,24(sp)
    8000516e:	e84a                	sd	s2,16(sp)
    80005170:	e44e                	sd	s3,8(sp)
    80005172:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005174:	00854783          	lbu	a5,8(a0)
    80005178:	c3d5                	beqz	a5,8000521c <fileread+0xb6>
    8000517a:	84aa                	mv	s1,a0
    8000517c:	89ae                	mv	s3,a1
    8000517e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005180:	411c                	lw	a5,0(a0)
    80005182:	4705                	li	a4,1
    80005184:	04e78963          	beq	a5,a4,800051d6 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005188:	470d                	li	a4,3
    8000518a:	04e78d63          	beq	a5,a4,800051e4 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000518e:	4709                	li	a4,2
    80005190:	06e79e63          	bne	a5,a4,8000520c <fileread+0xa6>
    ilock(f->ip);
    80005194:	6d08                	ld	a0,24(a0)
    80005196:	fffff097          	auipc	ra,0xfffff
    8000519a:	cbc080e7          	jalr	-836(ra) # 80003e52 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000519e:	874a                	mv	a4,s2
    800051a0:	5094                	lw	a3,32(s1)
    800051a2:	864e                	mv	a2,s3
    800051a4:	4585                	li	a1,1
    800051a6:	6c88                	ld	a0,24(s1)
    800051a8:	fffff097          	auipc	ra,0xfffff
    800051ac:	f5e080e7          	jalr	-162(ra) # 80004106 <readi>
    800051b0:	892a                	mv	s2,a0
    800051b2:	00a05563          	blez	a0,800051bc <fileread+0x56>
      f->off += r;
    800051b6:	509c                	lw	a5,32(s1)
    800051b8:	9fa9                	addw	a5,a5,a0
    800051ba:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800051bc:	6c88                	ld	a0,24(s1)
    800051be:	fffff097          	auipc	ra,0xfffff
    800051c2:	d56080e7          	jalr	-682(ra) # 80003f14 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800051c6:	854a                	mv	a0,s2
    800051c8:	70a2                	ld	ra,40(sp)
    800051ca:	7402                	ld	s0,32(sp)
    800051cc:	64e2                	ld	s1,24(sp)
    800051ce:	6942                	ld	s2,16(sp)
    800051d0:	69a2                	ld	s3,8(sp)
    800051d2:	6145                	addi	sp,sp,48
    800051d4:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800051d6:	6908                	ld	a0,16(a0)
    800051d8:	00000097          	auipc	ra,0x0
    800051dc:	5b6080e7          	jalr	1462(ra) # 8000578e <piperead>
    800051e0:	892a                	mv	s2,a0
    800051e2:	b7d5                	j	800051c6 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800051e4:	02451783          	lh	a5,36(a0)
    800051e8:	03079693          	slli	a3,a5,0x30
    800051ec:	92c1                	srli	a3,a3,0x30
    800051ee:	4725                	li	a4,9
    800051f0:	02d76863          	bltu	a4,a3,80005220 <fileread+0xba>
    800051f4:	0792                	slli	a5,a5,0x4
    800051f6:	0002a717          	auipc	a4,0x2a
    800051fa:	f2270713          	addi	a4,a4,-222 # 8002f118 <devsw>
    800051fe:	97ba                	add	a5,a5,a4
    80005200:	639c                	ld	a5,0(a5)
    80005202:	c38d                	beqz	a5,80005224 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005204:	4505                	li	a0,1
    80005206:	9782                	jalr	a5
    80005208:	892a                	mv	s2,a0
    8000520a:	bf75                	j	800051c6 <fileread+0x60>
    panic("fileread");
    8000520c:	00004517          	auipc	a0,0x4
    80005210:	7f450513          	addi	a0,a0,2036 # 80009a00 <syscalls+0x2d0>
    80005214:	ffffb097          	auipc	ra,0xffffb
    80005218:	316080e7          	jalr	790(ra) # 8000052a <panic>
    return -1;
    8000521c:	597d                	li	s2,-1
    8000521e:	b765                	j	800051c6 <fileread+0x60>
      return -1;
    80005220:	597d                	li	s2,-1
    80005222:	b755                	j	800051c6 <fileread+0x60>
    80005224:	597d                	li	s2,-1
    80005226:	b745                	j	800051c6 <fileread+0x60>

0000000080005228 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80005228:	715d                	addi	sp,sp,-80
    8000522a:	e486                	sd	ra,72(sp)
    8000522c:	e0a2                	sd	s0,64(sp)
    8000522e:	fc26                	sd	s1,56(sp)
    80005230:	f84a                	sd	s2,48(sp)
    80005232:	f44e                	sd	s3,40(sp)
    80005234:	f052                	sd	s4,32(sp)
    80005236:	ec56                	sd	s5,24(sp)
    80005238:	e85a                	sd	s6,16(sp)
    8000523a:	e45e                	sd	s7,8(sp)
    8000523c:	e062                	sd	s8,0(sp)
    8000523e:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005240:	00954783          	lbu	a5,9(a0)
    80005244:	10078663          	beqz	a5,80005350 <filewrite+0x128>
    80005248:	892a                	mv	s2,a0
    8000524a:	8aae                	mv	s5,a1
    8000524c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000524e:	411c                	lw	a5,0(a0)
    80005250:	4705                	li	a4,1
    80005252:	02e78263          	beq	a5,a4,80005276 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005256:	470d                	li	a4,3
    80005258:	02e78663          	beq	a5,a4,80005284 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000525c:	4709                	li	a4,2
    8000525e:	0ee79163          	bne	a5,a4,80005340 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005262:	0ac05d63          	blez	a2,8000531c <filewrite+0xf4>
    int i = 0;
    80005266:	4981                	li	s3,0
    80005268:	6b05                	lui	s6,0x1
    8000526a:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000526e:	6b85                	lui	s7,0x1
    80005270:	c00b8b9b          	addiw	s7,s7,-1024
    80005274:	a861                	j	8000530c <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005276:	6908                	ld	a0,16(a0)
    80005278:	00000097          	auipc	ra,0x0
    8000527c:	424080e7          	jalr	1060(ra) # 8000569c <pipewrite>
    80005280:	8a2a                	mv	s4,a0
    80005282:	a045                	j	80005322 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005284:	02451783          	lh	a5,36(a0)
    80005288:	03079693          	slli	a3,a5,0x30
    8000528c:	92c1                	srli	a3,a3,0x30
    8000528e:	4725                	li	a4,9
    80005290:	0cd76263          	bltu	a4,a3,80005354 <filewrite+0x12c>
    80005294:	0792                	slli	a5,a5,0x4
    80005296:	0002a717          	auipc	a4,0x2a
    8000529a:	e8270713          	addi	a4,a4,-382 # 8002f118 <devsw>
    8000529e:	97ba                	add	a5,a5,a4
    800052a0:	679c                	ld	a5,8(a5)
    800052a2:	cbdd                	beqz	a5,80005358 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800052a4:	4505                	li	a0,1
    800052a6:	9782                	jalr	a5
    800052a8:	8a2a                	mv	s4,a0
    800052aa:	a8a5                	j	80005322 <filewrite+0xfa>
    800052ac:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800052b0:	00000097          	auipc	ra,0x0
    800052b4:	8b0080e7          	jalr	-1872(ra) # 80004b60 <begin_op>
      ilock(f->ip);
    800052b8:	01893503          	ld	a0,24(s2)
    800052bc:	fffff097          	auipc	ra,0xfffff
    800052c0:	b96080e7          	jalr	-1130(ra) # 80003e52 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800052c4:	8762                	mv	a4,s8
    800052c6:	02092683          	lw	a3,32(s2)
    800052ca:	01598633          	add	a2,s3,s5
    800052ce:	4585                	li	a1,1
    800052d0:	01893503          	ld	a0,24(s2)
    800052d4:	fffff097          	auipc	ra,0xfffff
    800052d8:	f2a080e7          	jalr	-214(ra) # 800041fe <writei>
    800052dc:	84aa                	mv	s1,a0
    800052de:	00a05763          	blez	a0,800052ec <filewrite+0xc4>
        f->off += r;
    800052e2:	02092783          	lw	a5,32(s2)
    800052e6:	9fa9                	addw	a5,a5,a0
    800052e8:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800052ec:	01893503          	ld	a0,24(s2)
    800052f0:	fffff097          	auipc	ra,0xfffff
    800052f4:	c24080e7          	jalr	-988(ra) # 80003f14 <iunlock>
      end_op();
    800052f8:	00000097          	auipc	ra,0x0
    800052fc:	8e8080e7          	jalr	-1816(ra) # 80004be0 <end_op>

      if(r != n1){
    80005300:	009c1f63          	bne	s8,s1,8000531e <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005304:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005308:	0149db63          	bge	s3,s4,8000531e <filewrite+0xf6>
      int n1 = n - i;
    8000530c:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005310:	84be                	mv	s1,a5
    80005312:	2781                	sext.w	a5,a5
    80005314:	f8fb5ce3          	bge	s6,a5,800052ac <filewrite+0x84>
    80005318:	84de                	mv	s1,s7
    8000531a:	bf49                	j	800052ac <filewrite+0x84>
    int i = 0;
    8000531c:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000531e:	013a1f63          	bne	s4,s3,8000533c <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005322:	8552                	mv	a0,s4
    80005324:	60a6                	ld	ra,72(sp)
    80005326:	6406                	ld	s0,64(sp)
    80005328:	74e2                	ld	s1,56(sp)
    8000532a:	7942                	ld	s2,48(sp)
    8000532c:	79a2                	ld	s3,40(sp)
    8000532e:	7a02                	ld	s4,32(sp)
    80005330:	6ae2                	ld	s5,24(sp)
    80005332:	6b42                	ld	s6,16(sp)
    80005334:	6ba2                	ld	s7,8(sp)
    80005336:	6c02                	ld	s8,0(sp)
    80005338:	6161                	addi	sp,sp,80
    8000533a:	8082                	ret
    ret = (i == n ? n : -1);
    8000533c:	5a7d                	li	s4,-1
    8000533e:	b7d5                	j	80005322 <filewrite+0xfa>
    panic("filewrite");
    80005340:	00004517          	auipc	a0,0x4
    80005344:	6d050513          	addi	a0,a0,1744 # 80009a10 <syscalls+0x2e0>
    80005348:	ffffb097          	auipc	ra,0xffffb
    8000534c:	1e2080e7          	jalr	482(ra) # 8000052a <panic>
    return -1;
    80005350:	5a7d                	li	s4,-1
    80005352:	bfc1                	j	80005322 <filewrite+0xfa>
      return -1;
    80005354:	5a7d                	li	s4,-1
    80005356:	b7f1                	j	80005322 <filewrite+0xfa>
    80005358:	5a7d                	li	s4,-1
    8000535a:	b7e1                	j	80005322 <filewrite+0xfa>

000000008000535c <kfileread>:

// Read from file f.
// addr is a kernel virtual address.
int
kfileread(struct file *f, uint64 addr, int n)
{
    8000535c:	7179                	addi	sp,sp,-48
    8000535e:	f406                	sd	ra,40(sp)
    80005360:	f022                	sd	s0,32(sp)
    80005362:	ec26                	sd	s1,24(sp)
    80005364:	e84a                	sd	s2,16(sp)
    80005366:	e44e                	sd	s3,8(sp)
    80005368:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000536a:	00854783          	lbu	a5,8(a0)
    8000536e:	c3d5                	beqz	a5,80005412 <kfileread+0xb6>
    80005370:	84aa                	mv	s1,a0
    80005372:	89ae                	mv	s3,a1
    80005374:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005376:	411c                	lw	a5,0(a0)
    80005378:	4705                	li	a4,1
    8000537a:	04e78963          	beq	a5,a4,800053cc <kfileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000537e:	470d                	li	a4,3
    80005380:	04e78d63          	beq	a5,a4,800053da <kfileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005384:	4709                	li	a4,2
    80005386:	06e79e63          	bne	a5,a4,80005402 <kfileread+0xa6>
    ilock(f->ip);
    8000538a:	6d08                	ld	a0,24(a0)
    8000538c:	fffff097          	auipc	ra,0xfffff
    80005390:	ac6080e7          	jalr	-1338(ra) # 80003e52 <ilock>
    if((r = readi(f->ip, 0, addr, f->off, n)) > 0){
    80005394:	874a                	mv	a4,s2
    80005396:	5094                	lw	a3,32(s1)
    80005398:	864e                	mv	a2,s3
    8000539a:	4581                	li	a1,0
    8000539c:	6c88                	ld	a0,24(s1)
    8000539e:	fffff097          	auipc	ra,0xfffff
    800053a2:	d68080e7          	jalr	-664(ra) # 80004106 <readi>
    800053a6:	892a                	mv	s2,a0
    800053a8:	00a05563          	blez	a0,800053b2 <kfileread+0x56>
      f->off += r;
    800053ac:	509c                	lw	a5,32(s1)
    800053ae:	9fa9                	addw	a5,a5,a0
    800053b0:	d09c                	sw	a5,32(s1)
    }
    iunlock(f->ip);
    800053b2:	6c88                	ld	a0,24(s1)
    800053b4:	fffff097          	auipc	ra,0xfffff
    800053b8:	b60080e7          	jalr	-1184(ra) # 80003f14 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800053bc:	854a                	mv	a0,s2
    800053be:	70a2                	ld	ra,40(sp)
    800053c0:	7402                	ld	s0,32(sp)
    800053c2:	64e2                	ld	s1,24(sp)
    800053c4:	6942                	ld	s2,16(sp)
    800053c6:	69a2                	ld	s3,8(sp)
    800053c8:	6145                	addi	sp,sp,48
    800053ca:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800053cc:	6908                	ld	a0,16(a0)
    800053ce:	00000097          	auipc	ra,0x0
    800053d2:	3c0080e7          	jalr	960(ra) # 8000578e <piperead>
    800053d6:	892a                	mv	s2,a0
    800053d8:	b7d5                	j	800053bc <kfileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800053da:	02451783          	lh	a5,36(a0)
    800053de:	03079693          	slli	a3,a5,0x30
    800053e2:	92c1                	srli	a3,a3,0x30
    800053e4:	4725                	li	a4,9
    800053e6:	02d76863          	bltu	a4,a3,80005416 <kfileread+0xba>
    800053ea:	0792                	slli	a5,a5,0x4
    800053ec:	0002a717          	auipc	a4,0x2a
    800053f0:	d2c70713          	addi	a4,a4,-724 # 8002f118 <devsw>
    800053f4:	97ba                	add	a5,a5,a4
    800053f6:	639c                	ld	a5,0(a5)
    800053f8:	c38d                	beqz	a5,8000541a <kfileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800053fa:	4505                	li	a0,1
    800053fc:	9782                	jalr	a5
    800053fe:	892a                	mv	s2,a0
    80005400:	bf75                	j	800053bc <kfileread+0x60>
    panic("fileread");
    80005402:	00004517          	auipc	a0,0x4
    80005406:	5fe50513          	addi	a0,a0,1534 # 80009a00 <syscalls+0x2d0>
    8000540a:	ffffb097          	auipc	ra,0xffffb
    8000540e:	120080e7          	jalr	288(ra) # 8000052a <panic>
    return -1;
    80005412:	597d                	li	s2,-1
    80005414:	b765                	j	800053bc <kfileread+0x60>
      return -1;
    80005416:	597d                	li	s2,-1
    80005418:	b755                	j	800053bc <kfileread+0x60>
    8000541a:	597d                	li	s2,-1
    8000541c:	b745                	j	800053bc <kfileread+0x60>

000000008000541e <kfilewrite>:

// Write to file f.
// addr is a kernel virtual address.
int
kfilewrite(struct file *f, uint64 addr, int n)
{
    8000541e:	715d                	addi	sp,sp,-80
    80005420:	e486                	sd	ra,72(sp)
    80005422:	e0a2                	sd	s0,64(sp)
    80005424:	fc26                	sd	s1,56(sp)
    80005426:	f84a                	sd	s2,48(sp)
    80005428:	f44e                	sd	s3,40(sp)
    8000542a:	f052                	sd	s4,32(sp)
    8000542c:	ec56                	sd	s5,24(sp)
    8000542e:	e85a                	sd	s6,16(sp)
    80005430:	e45e                	sd	s7,8(sp)
    80005432:	e062                	sd	s8,0(sp)
    80005434:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005436:	00954783          	lbu	a5,9(a0)
    8000543a:	10078663          	beqz	a5,80005546 <kfilewrite+0x128>
    8000543e:	892a                	mv	s2,a0
    80005440:	8aae                	mv	s5,a1
    80005442:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005444:	411c                	lw	a5,0(a0)
    80005446:	4705                	li	a4,1
    80005448:	02e78263          	beq	a5,a4,8000546c <kfilewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000544c:	470d                	li	a4,3
    8000544e:	02e78663          	beq	a5,a4,8000547a <kfilewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005452:	4709                	li	a4,2
    80005454:	0ee79163          	bne	a5,a4,80005536 <kfilewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005458:	0ac05d63          	blez	a2,80005512 <kfilewrite+0xf4>
    int i = 0;
    8000545c:	4981                	li	s3,0
    8000545e:	6b05                	lui	s6,0x1
    80005460:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80005464:	6b85                	lui	s7,0x1
    80005466:	c00b8b9b          	addiw	s7,s7,-1024
    8000546a:	a861                	j	80005502 <kfilewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    8000546c:	6908                	ld	a0,16(a0)
    8000546e:	00000097          	auipc	ra,0x0
    80005472:	22e080e7          	jalr	558(ra) # 8000569c <pipewrite>
    80005476:	8a2a                	mv	s4,a0
    80005478:	a045                	j	80005518 <kfilewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000547a:	02451783          	lh	a5,36(a0)
    8000547e:	03079693          	slli	a3,a5,0x30
    80005482:	92c1                	srli	a3,a3,0x30
    80005484:	4725                	li	a4,9
    80005486:	0cd76263          	bltu	a4,a3,8000554a <kfilewrite+0x12c>
    8000548a:	0792                	slli	a5,a5,0x4
    8000548c:	0002a717          	auipc	a4,0x2a
    80005490:	c8c70713          	addi	a4,a4,-884 # 8002f118 <devsw>
    80005494:	97ba                	add	a5,a5,a4
    80005496:	679c                	ld	a5,8(a5)
    80005498:	cbdd                	beqz	a5,8000554e <kfilewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    8000549a:	4505                	li	a0,1
    8000549c:	9782                	jalr	a5
    8000549e:	8a2a                	mv	s4,a0
    800054a0:	a8a5                	j	80005518 <kfilewrite+0xfa>
    800054a2:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800054a6:	fffff097          	auipc	ra,0xfffff
    800054aa:	6ba080e7          	jalr	1722(ra) # 80004b60 <begin_op>
      ilock(f->ip);
    800054ae:	01893503          	ld	a0,24(s2)
    800054b2:	fffff097          	auipc	ra,0xfffff
    800054b6:	9a0080e7          	jalr	-1632(ra) # 80003e52 <ilock>
      if ((r = writei(f->ip, 0, addr + i, f->off, n1)) > 0)
    800054ba:	8762                	mv	a4,s8
    800054bc:	02092683          	lw	a3,32(s2)
    800054c0:	01598633          	add	a2,s3,s5
    800054c4:	4581                	li	a1,0
    800054c6:	01893503          	ld	a0,24(s2)
    800054ca:	fffff097          	auipc	ra,0xfffff
    800054ce:	d34080e7          	jalr	-716(ra) # 800041fe <writei>
    800054d2:	84aa                	mv	s1,a0
    800054d4:	00a05763          	blez	a0,800054e2 <kfilewrite+0xc4>
        f->off += r;
    800054d8:	02092783          	lw	a5,32(s2)
    800054dc:	9fa9                	addw	a5,a5,a0
    800054de:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800054e2:	01893503          	ld	a0,24(s2)
    800054e6:	fffff097          	auipc	ra,0xfffff
    800054ea:	a2e080e7          	jalr	-1490(ra) # 80003f14 <iunlock>
      end_op();
    800054ee:	fffff097          	auipc	ra,0xfffff
    800054f2:	6f2080e7          	jalr	1778(ra) # 80004be0 <end_op>

      if(r != n1){
    800054f6:	009c1f63          	bne	s8,s1,80005514 <kfilewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800054fa:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800054fe:	0149db63          	bge	s3,s4,80005514 <kfilewrite+0xf6>
      int n1 = n - i;
    80005502:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005506:	84be                	mv	s1,a5
    80005508:	2781                	sext.w	a5,a5
    8000550a:	f8fb5ce3          	bge	s6,a5,800054a2 <kfilewrite+0x84>
    8000550e:	84de                	mv	s1,s7
    80005510:	bf49                	j	800054a2 <kfilewrite+0x84>
    int i = 0;
    80005512:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005514:	013a1f63          	bne	s4,s3,80005532 <kfilewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
    80005518:	8552                	mv	a0,s4
    8000551a:	60a6                	ld	ra,72(sp)
    8000551c:	6406                	ld	s0,64(sp)
    8000551e:	74e2                	ld	s1,56(sp)
    80005520:	7942                	ld	s2,48(sp)
    80005522:	79a2                	ld	s3,40(sp)
    80005524:	7a02                	ld	s4,32(sp)
    80005526:	6ae2                	ld	s5,24(sp)
    80005528:	6b42                	ld	s6,16(sp)
    8000552a:	6ba2                	ld	s7,8(sp)
    8000552c:	6c02                	ld	s8,0(sp)
    8000552e:	6161                	addi	sp,sp,80
    80005530:	8082                	ret
    ret = (i == n ? n : -1);
    80005532:	5a7d                	li	s4,-1
    80005534:	b7d5                	j	80005518 <kfilewrite+0xfa>
    panic("filewrite");
    80005536:	00004517          	auipc	a0,0x4
    8000553a:	4da50513          	addi	a0,a0,1242 # 80009a10 <syscalls+0x2e0>
    8000553e:	ffffb097          	auipc	ra,0xffffb
    80005542:	fec080e7          	jalr	-20(ra) # 8000052a <panic>
    return -1;
    80005546:	5a7d                	li	s4,-1
    80005548:	bfc1                	j	80005518 <kfilewrite+0xfa>
      return -1;
    8000554a:	5a7d                	li	s4,-1
    8000554c:	b7f1                	j	80005518 <kfilewrite+0xfa>
    8000554e:	5a7d                	li	s4,-1
    80005550:	b7e1                	j	80005518 <kfilewrite+0xfa>

0000000080005552 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005552:	7179                	addi	sp,sp,-48
    80005554:	f406                	sd	ra,40(sp)
    80005556:	f022                	sd	s0,32(sp)
    80005558:	ec26                	sd	s1,24(sp)
    8000555a:	e84a                	sd	s2,16(sp)
    8000555c:	e44e                	sd	s3,8(sp)
    8000555e:	e052                	sd	s4,0(sp)
    80005560:	1800                	addi	s0,sp,48
    80005562:	84aa                	mv	s1,a0
    80005564:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005566:	0005b023          	sd	zero,0(a1)
    8000556a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000556e:	00000097          	auipc	ra,0x0
    80005572:	a02080e7          	jalr	-1534(ra) # 80004f70 <filealloc>
    80005576:	e088                	sd	a0,0(s1)
    80005578:	c551                	beqz	a0,80005604 <pipealloc+0xb2>
    8000557a:	00000097          	auipc	ra,0x0
    8000557e:	9f6080e7          	jalr	-1546(ra) # 80004f70 <filealloc>
    80005582:	00aa3023          	sd	a0,0(s4)
    80005586:	c92d                	beqz	a0,800055f8 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005588:	ffffb097          	auipc	ra,0xffffb
    8000558c:	54a080e7          	jalr	1354(ra) # 80000ad2 <kalloc>
    80005590:	892a                	mv	s2,a0
    80005592:	c125                	beqz	a0,800055f2 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005594:	4985                	li	s3,1
    80005596:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000559a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000559e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800055a2:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800055a6:	00004597          	auipc	a1,0x4
    800055aa:	47a58593          	addi	a1,a1,1146 # 80009a20 <syscalls+0x2f0>
    800055ae:	ffffb097          	auipc	ra,0xffffb
    800055b2:	584080e7          	jalr	1412(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    800055b6:	609c                	ld	a5,0(s1)
    800055b8:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800055bc:	609c                	ld	a5,0(s1)
    800055be:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800055c2:	609c                	ld	a5,0(s1)
    800055c4:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800055c8:	609c                	ld	a5,0(s1)
    800055ca:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800055ce:	000a3783          	ld	a5,0(s4)
    800055d2:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800055d6:	000a3783          	ld	a5,0(s4)
    800055da:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800055de:	000a3783          	ld	a5,0(s4)
    800055e2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800055e6:	000a3783          	ld	a5,0(s4)
    800055ea:	0127b823          	sd	s2,16(a5)
  return 0;
    800055ee:	4501                	li	a0,0
    800055f0:	a025                	j	80005618 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800055f2:	6088                	ld	a0,0(s1)
    800055f4:	e501                	bnez	a0,800055fc <pipealloc+0xaa>
    800055f6:	a039                	j	80005604 <pipealloc+0xb2>
    800055f8:	6088                	ld	a0,0(s1)
    800055fa:	c51d                	beqz	a0,80005628 <pipealloc+0xd6>
    fileclose(*f0);
    800055fc:	00000097          	auipc	ra,0x0
    80005600:	a30080e7          	jalr	-1488(ra) # 8000502c <fileclose>
  if(*f1)
    80005604:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005608:	557d                	li	a0,-1
  if(*f1)
    8000560a:	c799                	beqz	a5,80005618 <pipealloc+0xc6>
    fileclose(*f1);
    8000560c:	853e                	mv	a0,a5
    8000560e:	00000097          	auipc	ra,0x0
    80005612:	a1e080e7          	jalr	-1506(ra) # 8000502c <fileclose>
  return -1;
    80005616:	557d                	li	a0,-1
}
    80005618:	70a2                	ld	ra,40(sp)
    8000561a:	7402                	ld	s0,32(sp)
    8000561c:	64e2                	ld	s1,24(sp)
    8000561e:	6942                	ld	s2,16(sp)
    80005620:	69a2                	ld	s3,8(sp)
    80005622:	6a02                	ld	s4,0(sp)
    80005624:	6145                	addi	sp,sp,48
    80005626:	8082                	ret
  return -1;
    80005628:	557d                	li	a0,-1
    8000562a:	b7fd                	j	80005618 <pipealloc+0xc6>

000000008000562c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000562c:	1101                	addi	sp,sp,-32
    8000562e:	ec06                	sd	ra,24(sp)
    80005630:	e822                	sd	s0,16(sp)
    80005632:	e426                	sd	s1,8(sp)
    80005634:	e04a                	sd	s2,0(sp)
    80005636:	1000                	addi	s0,sp,32
    80005638:	84aa                	mv	s1,a0
    8000563a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000563c:	ffffb097          	auipc	ra,0xffffb
    80005640:	586080e7          	jalr	1414(ra) # 80000bc2 <acquire>
  if(writable){
    80005644:	02090d63          	beqz	s2,8000567e <pipeclose+0x52>
    pi->writeopen = 0;
    80005648:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000564c:	21848513          	addi	a0,s1,536
    80005650:	ffffd097          	auipc	ra,0xffffd
    80005654:	1ae080e7          	jalr	430(ra) # 800027fe <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005658:	2204b783          	ld	a5,544(s1)
    8000565c:	eb95                	bnez	a5,80005690 <pipeclose+0x64>
    release(&pi->lock);
    8000565e:	8526                	mv	a0,s1
    80005660:	ffffb097          	auipc	ra,0xffffb
    80005664:	616080e7          	jalr	1558(ra) # 80000c76 <release>
    kfree((char*)pi);
    80005668:	8526                	mv	a0,s1
    8000566a:	ffffb097          	auipc	ra,0xffffb
    8000566e:	36c080e7          	jalr	876(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    80005672:	60e2                	ld	ra,24(sp)
    80005674:	6442                	ld	s0,16(sp)
    80005676:	64a2                	ld	s1,8(sp)
    80005678:	6902                	ld	s2,0(sp)
    8000567a:	6105                	addi	sp,sp,32
    8000567c:	8082                	ret
    pi->readopen = 0;
    8000567e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005682:	21c48513          	addi	a0,s1,540
    80005686:	ffffd097          	auipc	ra,0xffffd
    8000568a:	178080e7          	jalr	376(ra) # 800027fe <wakeup>
    8000568e:	b7e9                	j	80005658 <pipeclose+0x2c>
    release(&pi->lock);
    80005690:	8526                	mv	a0,s1
    80005692:	ffffb097          	auipc	ra,0xffffb
    80005696:	5e4080e7          	jalr	1508(ra) # 80000c76 <release>
}
    8000569a:	bfe1                	j	80005672 <pipeclose+0x46>

000000008000569c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000569c:	711d                	addi	sp,sp,-96
    8000569e:	ec86                	sd	ra,88(sp)
    800056a0:	e8a2                	sd	s0,80(sp)
    800056a2:	e4a6                	sd	s1,72(sp)
    800056a4:	e0ca                	sd	s2,64(sp)
    800056a6:	fc4e                	sd	s3,56(sp)
    800056a8:	f852                	sd	s4,48(sp)
    800056aa:	f456                	sd	s5,40(sp)
    800056ac:	f05a                	sd	s6,32(sp)
    800056ae:	ec5e                	sd	s7,24(sp)
    800056b0:	e862                	sd	s8,16(sp)
    800056b2:	1080                	addi	s0,sp,96
    800056b4:	84aa                	mv	s1,a0
    800056b6:	8aae                	mv	s5,a1
    800056b8:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800056ba:	ffffc097          	auipc	ra,0xffffc
    800056be:	6f8080e7          	jalr	1784(ra) # 80001db2 <myproc>
    800056c2:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800056c4:	8526                	mv	a0,s1
    800056c6:	ffffb097          	auipc	ra,0xffffb
    800056ca:	4fc080e7          	jalr	1276(ra) # 80000bc2 <acquire>
  while(i < n){
    800056ce:	0b405363          	blez	s4,80005774 <pipewrite+0xd8>
  int i = 0;
    800056d2:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800056d4:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800056d6:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800056da:	21c48b93          	addi	s7,s1,540
    800056de:	a089                	j	80005720 <pipewrite+0x84>
      release(&pi->lock);
    800056e0:	8526                	mv	a0,s1
    800056e2:	ffffb097          	auipc	ra,0xffffb
    800056e6:	594080e7          	jalr	1428(ra) # 80000c76 <release>
      return -1;
    800056ea:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800056ec:	854a                	mv	a0,s2
    800056ee:	60e6                	ld	ra,88(sp)
    800056f0:	6446                	ld	s0,80(sp)
    800056f2:	64a6                	ld	s1,72(sp)
    800056f4:	6906                	ld	s2,64(sp)
    800056f6:	79e2                	ld	s3,56(sp)
    800056f8:	7a42                	ld	s4,48(sp)
    800056fa:	7aa2                	ld	s5,40(sp)
    800056fc:	7b02                	ld	s6,32(sp)
    800056fe:	6be2                	ld	s7,24(sp)
    80005700:	6c42                	ld	s8,16(sp)
    80005702:	6125                	addi	sp,sp,96
    80005704:	8082                	ret
      wakeup(&pi->nread);
    80005706:	8562                	mv	a0,s8
    80005708:	ffffd097          	auipc	ra,0xffffd
    8000570c:	0f6080e7          	jalr	246(ra) # 800027fe <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005710:	85a6                	mv	a1,s1
    80005712:	855e                	mv	a0,s7
    80005714:	ffffd097          	auipc	ra,0xffffd
    80005718:	f5e080e7          	jalr	-162(ra) # 80002672 <sleep>
  while(i < n){
    8000571c:	05495d63          	bge	s2,s4,80005776 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80005720:	2204a783          	lw	a5,544(s1)
    80005724:	dfd5                	beqz	a5,800056e0 <pipewrite+0x44>
    80005726:	0289a783          	lw	a5,40(s3)
    8000572a:	fbdd                	bnez	a5,800056e0 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000572c:	2184a783          	lw	a5,536(s1)
    80005730:	21c4a703          	lw	a4,540(s1)
    80005734:	2007879b          	addiw	a5,a5,512
    80005738:	fcf707e3          	beq	a4,a5,80005706 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000573c:	4685                	li	a3,1
    8000573e:	01590633          	add	a2,s2,s5
    80005742:	faf40593          	addi	a1,s0,-81
    80005746:	0509b503          	ld	a0,80(s3)
    8000574a:	ffffc097          	auipc	ra,0xffffc
    8000574e:	3b4080e7          	jalr	948(ra) # 80001afe <copyin>
    80005752:	03650263          	beq	a0,s6,80005776 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005756:	21c4a783          	lw	a5,540(s1)
    8000575a:	0017871b          	addiw	a4,a5,1
    8000575e:	20e4ae23          	sw	a4,540(s1)
    80005762:	1ff7f793          	andi	a5,a5,511
    80005766:	97a6                	add	a5,a5,s1
    80005768:	faf44703          	lbu	a4,-81(s0)
    8000576c:	00e78c23          	sb	a4,24(a5)
      i++;
    80005770:	2905                	addiw	s2,s2,1
    80005772:	b76d                	j	8000571c <pipewrite+0x80>
  int i = 0;
    80005774:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005776:	21848513          	addi	a0,s1,536
    8000577a:	ffffd097          	auipc	ra,0xffffd
    8000577e:	084080e7          	jalr	132(ra) # 800027fe <wakeup>
  release(&pi->lock);
    80005782:	8526                	mv	a0,s1
    80005784:	ffffb097          	auipc	ra,0xffffb
    80005788:	4f2080e7          	jalr	1266(ra) # 80000c76 <release>
  return i;
    8000578c:	b785                	j	800056ec <pipewrite+0x50>

000000008000578e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000578e:	715d                	addi	sp,sp,-80
    80005790:	e486                	sd	ra,72(sp)
    80005792:	e0a2                	sd	s0,64(sp)
    80005794:	fc26                	sd	s1,56(sp)
    80005796:	f84a                	sd	s2,48(sp)
    80005798:	f44e                	sd	s3,40(sp)
    8000579a:	f052                	sd	s4,32(sp)
    8000579c:	ec56                	sd	s5,24(sp)
    8000579e:	e85a                	sd	s6,16(sp)
    800057a0:	0880                	addi	s0,sp,80
    800057a2:	84aa                	mv	s1,a0
    800057a4:	892e                	mv	s2,a1
    800057a6:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800057a8:	ffffc097          	auipc	ra,0xffffc
    800057ac:	60a080e7          	jalr	1546(ra) # 80001db2 <myproc>
    800057b0:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800057b2:	8526                	mv	a0,s1
    800057b4:	ffffb097          	auipc	ra,0xffffb
    800057b8:	40e080e7          	jalr	1038(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800057bc:	2184a703          	lw	a4,536(s1)
    800057c0:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800057c4:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800057c8:	02f71463          	bne	a4,a5,800057f0 <piperead+0x62>
    800057cc:	2244a783          	lw	a5,548(s1)
    800057d0:	c385                	beqz	a5,800057f0 <piperead+0x62>
    if(pr->killed){
    800057d2:	028a2783          	lw	a5,40(s4)
    800057d6:	ebc1                	bnez	a5,80005866 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800057d8:	85a6                	mv	a1,s1
    800057da:	854e                	mv	a0,s3
    800057dc:	ffffd097          	auipc	ra,0xffffd
    800057e0:	e96080e7          	jalr	-362(ra) # 80002672 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800057e4:	2184a703          	lw	a4,536(s1)
    800057e8:	21c4a783          	lw	a5,540(s1)
    800057ec:	fef700e3          	beq	a4,a5,800057cc <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800057f0:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800057f2:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800057f4:	05505363          	blez	s5,8000583a <piperead+0xac>
    if(pi->nread == pi->nwrite)
    800057f8:	2184a783          	lw	a5,536(s1)
    800057fc:	21c4a703          	lw	a4,540(s1)
    80005800:	02f70d63          	beq	a4,a5,8000583a <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005804:	0017871b          	addiw	a4,a5,1
    80005808:	20e4ac23          	sw	a4,536(s1)
    8000580c:	1ff7f793          	andi	a5,a5,511
    80005810:	97a6                	add	a5,a5,s1
    80005812:	0187c783          	lbu	a5,24(a5)
    80005816:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000581a:	4685                	li	a3,1
    8000581c:	fbf40613          	addi	a2,s0,-65
    80005820:	85ca                	mv	a1,s2
    80005822:	050a3503          	ld	a0,80(s4)
    80005826:	ffffc097          	auipc	ra,0xffffc
    8000582a:	24c080e7          	jalr	588(ra) # 80001a72 <copyout>
    8000582e:	01650663          	beq	a0,s6,8000583a <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005832:	2985                	addiw	s3,s3,1
    80005834:	0905                	addi	s2,s2,1
    80005836:	fd3a91e3          	bne	s5,s3,800057f8 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000583a:	21c48513          	addi	a0,s1,540
    8000583e:	ffffd097          	auipc	ra,0xffffd
    80005842:	fc0080e7          	jalr	-64(ra) # 800027fe <wakeup>
  release(&pi->lock);
    80005846:	8526                	mv	a0,s1
    80005848:	ffffb097          	auipc	ra,0xffffb
    8000584c:	42e080e7          	jalr	1070(ra) # 80000c76 <release>
  return i;
}
    80005850:	854e                	mv	a0,s3
    80005852:	60a6                	ld	ra,72(sp)
    80005854:	6406                	ld	s0,64(sp)
    80005856:	74e2                	ld	s1,56(sp)
    80005858:	7942                	ld	s2,48(sp)
    8000585a:	79a2                	ld	s3,40(sp)
    8000585c:	7a02                	ld	s4,32(sp)
    8000585e:	6ae2                	ld	s5,24(sp)
    80005860:	6b42                	ld	s6,16(sp)
    80005862:	6161                	addi	sp,sp,80
    80005864:	8082                	ret
      release(&pi->lock);
    80005866:	8526                	mv	a0,s1
    80005868:	ffffb097          	auipc	ra,0xffffb
    8000586c:	40e080e7          	jalr	1038(ra) # 80000c76 <release>
      return -1;
    80005870:	59fd                	li	s3,-1
    80005872:	bff9                	j	80005850 <piperead+0xc2>

0000000080005874 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005874:	a9010113          	addi	sp,sp,-1392
    80005878:	56113423          	sd	ra,1384(sp)
    8000587c:	56813023          	sd	s0,1376(sp)
    80005880:	54913c23          	sd	s1,1368(sp)
    80005884:	55213823          	sd	s2,1360(sp)
    80005888:	55313423          	sd	s3,1352(sp)
    8000588c:	55413023          	sd	s4,1344(sp)
    80005890:	53513c23          	sd	s5,1336(sp)
    80005894:	53613823          	sd	s6,1328(sp)
    80005898:	53713423          	sd	s7,1320(sp)
    8000589c:	53813023          	sd	s8,1312(sp)
    800058a0:	51913c23          	sd	s9,1304(sp)
    800058a4:	51a13823          	sd	s10,1296(sp)
    800058a8:	51b13423          	sd	s11,1288(sp)
    800058ac:	57010413          	addi	s0,sp,1392
    800058b0:	89aa                	mv	s3,a0
    800058b2:	a8a43c23          	sd	a0,-1384(s0)
    800058b6:	aab43423          	sd	a1,-1368(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800058ba:	ffffc097          	auipc	ra,0xffffc
    800058be:	4f8080e7          	jalr	1272(ra) # 80001db2 <myproc>
    800058c2:	8b2a                	mv	s6,a0

  #ifndef NONE
    //struct file *swapFile_backup;
    int numOfPhyPages_backup = p->numOfPhyPages;
    800058c4:	17852783          	lw	a5,376(a0)
    800058c8:	acf43423          	sd	a5,-1336(s0)
    int numOfTotalPages_backup = p->numOfTotalPages;
    800058cc:	17c52783          	lw	a5,380(a0)
    800058d0:	acf43023          	sd	a5,-1344(s0)
    int numOfPageFaults_backup = p->numOfPageFault; 
    800058d4:	49852783          	lw	a5,1176(a0)
    800058d8:	aaf43c23          	sd	a5,-1352(s0)
    int swapOffset_backup = p->swapOffset;
    800058dc:	17052783          	lw	a5,368(a0)
    800058e0:	aaf43823          	sd	a5,-1360(s0)
    struct page swapPagesArray_backup[(MAX_TOTAL_PAGES/2)+1]; //disc, secondary memory
    memmove(&swapPagesArray_backup, &p->swapPagesArray, sizeof(p->swapPagesArray));
    800058e4:	18050913          	addi	s2,a0,384
    800058e8:	19800613          	li	a2,408
    800058ec:	85ca                	mv	a1,s2
    800058ee:	c7840513          	addi	a0,s0,-904
    800058f2:	ffffb097          	auipc	ra,0xffffb
    800058f6:	428080e7          	jalr	1064(ra) # 80000d1a <memmove>
    struct page physPagesArray_backup[MAX_TOTAL_PAGES/2];
    memmove(&physPagesArray_backup, &p->physPagesArray, sizeof(p->physPagesArray));
    800058fa:	318b0493          	addi	s1,s6,792
    800058fe:	18000613          	li	a2,384
    80005902:	85a6                	mv	a1,s1
    80005904:	af840513          	addi	a0,s0,-1288
    80005908:	ffffb097          	auipc	ra,0xffffb
    8000590c:	412080e7          	jalr	1042(ra) # 80000d1a <memmove>
  #endif

  begin_op();
    80005910:	fffff097          	auipc	ra,0xfffff
    80005914:	250080e7          	jalr	592(ra) # 80004b60 <begin_op>

  if((ip = namei(path)) == 0){
    80005918:	854e                	mv	a0,s3
    8000591a:	fffff097          	auipc	ra,0xfffff
    8000591e:	cee080e7          	jalr	-786(ra) # 80004608 <namei>
    80005922:	c161                	beqz	a0,800059e2 <exec+0x16e>
    80005924:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005926:	ffffe097          	auipc	ra,0xffffe
    8000592a:	52c080e7          	jalr	1324(ra) # 80003e52 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000592e:	04000713          	li	a4,64
    80005932:	4681                	li	a3,0
    80005934:	e4840613          	addi	a2,s0,-440
    80005938:	4581                	li	a1,0
    8000593a:	8556                	mv	a0,s5
    8000593c:	ffffe097          	auipc	ra,0xffffe
    80005940:	7ca080e7          	jalr	1994(ra) # 80004106 <readi>
    80005944:	04000793          	li	a5,64
    80005948:	32f51363          	bne	a0,a5,80005c6e <exec+0x3fa>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    8000594c:	e4842703          	lw	a4,-440(s0)
    80005950:	464c47b7          	lui	a5,0x464c4
    80005954:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005958:	30f71b63          	bne	a4,a5,80005c6e <exec+0x3fa>
    goto bad;

  #ifndef NONE
    if (p->pid>2){
    8000595c:	030b2703          	lw	a4,48(s6)
    80005960:	4789                	li	a5,2
    80005962:	04e7d763          	bge	a5,a4,800059b0 <exec+0x13c>
      // our code: clearing the SwapFile

      p->numOfPhyPages = 0;
    80005966:	160b2c23          	sw	zero,376(s6)
      p->numOfTotalPages = 0;
    8000596a:	160b2e23          	sw	zero,380(s6)
      p->numOfPageFault = 0;
    8000596e:	480b2c23          	sw	zero,1176(s6)
      p->swapOffset = 0;
    80005972:	160b2823          	sw	zero,368(s6)

      #ifdef SCFIFO
        p->nextPlaceInQueue = 1;
    80005976:	4785                	li	a5,1
    80005978:	16fb2a23          	sw	a5,372(s6)
      #endif
      for(int k = 0; k < MAX_PSYC_PAGES; k++){
    8000597c:	180b0793          	addi	a5,s6,384
    80005980:	300b0693          	addi	a3,s6,768
        p->swapPagesArray[k].inUse = 0;
        p->swapPagesArray[k].va = -1;
    80005984:	577d                	li	a4,-1
        p->swapPagesArray[k].inUse = 0;
    80005986:	0007a623          	sw	zero,12(a5)
        p->swapPagesArray[k].va = -1;
    8000598a:	e398                	sd	a4,0(a5)
        p->physPagesArray[k].inUse = 0;
    8000598c:	1a07a223          	sw	zero,420(a5)
        p->physPagesArray[k].va = -1;
    80005990:	18e7bc23          	sd	a4,408(a5)
          p->swapPagesArray[k].counter = 0xFFFFFFFF;
          p->physPagesArray[k].counter = 0xFFFFFFFF;
        #endif

        #ifdef SCFIFO
          p->swapPagesArray[k].placeInQueue = 0;
    80005994:	0007a823          	sw	zero,16(a5)
          p->physPagesArray[k].placeInQueue = 0;
    80005998:	1a07a423          	sw	zero,424(a5)
      for(int k = 0; k < MAX_PSYC_PAGES; k++){
    8000599c:	07e1                	addi	a5,a5,24
    8000599e:	fed794e3          	bne	a5,a3,80005986 <exec+0x112>
        #endif
      }
      p->swapPagesArray[16].inUse = 0;
    800059a2:	300b2623          	sw	zero,780(s6)
      p->swapPagesArray[16].va = -1;
    800059a6:	57fd                	li	a5,-1
    800059a8:	30fb3023          	sd	a5,768(s6)
      #ifdef LAPA
        p->swapPagesArray[16].counter = 0xFFFFFFFF;
      #endif

      #ifdef SCFIFO
        p->swapPagesArray[16].placeInQueue = 0;
    800059ac:	300b2823          	sw	zero,784(s6)
      #endif
    } 
  #endif 
  

  if((pagetable = proc_pagetable(p)) == 0)
    800059b0:	855a                	mv	a0,s6
    800059b2:	ffffc097          	auipc	ra,0xffffc
    800059b6:	4f0080e7          	jalr	1264(ra) # 80001ea2 <proc_pagetable>
    800059ba:	aea43423          	sd	a0,-1304(s0)
    800059be:	2a050863          	beqz	a0,80005c6e <exec+0x3fa>
    goto bad;

  // Load program into memory.
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800059c2:	e6842783          	lw	a5,-408(s0)
    800059c6:	e8045703          	lhu	a4,-384(s0)
    800059ca:	cf2d                	beqz	a4,80005a44 <exec+0x1d0>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800059cc:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800059ce:	ae043023          	sd	zero,-1312(s0)
      goto bad;
    uint64 sz1;
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    sz = sz1;
    if(ph.vaddr % PGSIZE != 0)
    800059d2:	6a05                	lui	s4,0x1
    800059d4:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800059d8:	aae43023          	sd	a4,-1376(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    800059dc:	6d85                	lui	s11,0x1
    800059de:	7d7d                	lui	s10,0xfffff
    800059e0:	a681                	j	80005d20 <exec+0x4ac>
    end_op();
    800059e2:	fffff097          	auipc	ra,0xfffff
    800059e6:	1fe080e7          	jalr	510(ra) # 80004be0 <end_op>
    return -1;
    800059ea:	557d                	li	a0,-1
    800059ec:	ace9                	j	80005cc6 <exec+0x452>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800059ee:	00004517          	auipc	a0,0x4
    800059f2:	03a50513          	addi	a0,a0,58 # 80009a28 <syscalls+0x2f8>
    800059f6:	ffffb097          	auipc	ra,0xffffb
    800059fa:	b34080e7          	jalr	-1228(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800059fe:	874a                	mv	a4,s2
    80005a00:	009c86bb          	addw	a3,s9,s1
    80005a04:	4581                	li	a1,0
    80005a06:	8556                	mv	a0,s5
    80005a08:	ffffe097          	auipc	ra,0xffffe
    80005a0c:	6fe080e7          	jalr	1790(ra) # 80004106 <readi>
    80005a10:	2501                	sext.w	a0,a0
    80005a12:	1ca91963          	bne	s2,a0,80005be4 <exec+0x370>
  for(i = 0; i < sz; i += PGSIZE){
    80005a16:	009d84bb          	addw	s1,s11,s1
    80005a1a:	013d09bb          	addw	s3,s10,s3
    80005a1e:	2f74f163          	bgeu	s1,s7,80005d00 <exec+0x48c>
    pa = walkaddr(pagetable, va + i);
    80005a22:	02049593          	slli	a1,s1,0x20
    80005a26:	9181                	srli	a1,a1,0x20
    80005a28:	95e2                	add	a1,a1,s8
    80005a2a:	ae843503          	ld	a0,-1304(s0)
    80005a2e:	ffffb097          	auipc	ra,0xffffb
    80005a32:	61e080e7          	jalr	1566(ra) # 8000104c <walkaddr>
    80005a36:	862a                	mv	a2,a0
    if(pa == 0)
    80005a38:	d95d                	beqz	a0,800059ee <exec+0x17a>
      n = PGSIZE;
    80005a3a:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005a3c:	fd49f1e3          	bgeu	s3,s4,800059fe <exec+0x18a>
      n = sz - i;
    80005a40:	894e                	mv	s2,s3
    80005a42:	bf75                	j	800059fe <exec+0x18a>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005a44:	4481                	li	s1,0
  iunlockput(ip);
    80005a46:	8556                	mv	a0,s5
    80005a48:	ffffe097          	auipc	ra,0xffffe
    80005a4c:	66c080e7          	jalr	1644(ra) # 800040b4 <iunlockput>
  end_op();
    80005a50:	fffff097          	auipc	ra,0xfffff
    80005a54:	190080e7          	jalr	400(ra) # 80004be0 <end_op>
  p = myproc();
    80005a58:	ffffc097          	auipc	ra,0xffffc
    80005a5c:	35a080e7          	jalr	858(ra) # 80001db2 <myproc>
    80005a60:	8b2a                	mv	s6,a0
  uint64 oldsz = p->sz;
    80005a62:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80005a66:	6785                	lui	a5,0x1
    80005a68:	17fd                	addi	a5,a5,-1
    80005a6a:	94be                	add	s1,s1,a5
    80005a6c:	77fd                	lui	a5,0xfffff
    80005a6e:	8fe5                	and	a5,a5,s1
    80005a70:	acf43823          	sd	a5,-1328(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005a74:	6609                	lui	a2,0x2
    80005a76:	963e                	add	a2,a2,a5
    80005a78:	85be                	mv	a1,a5
    80005a7a:	ae843483          	ld	s1,-1304(s0)
    80005a7e:	8526                	mv	a0,s1
    80005a80:	ffffc097          	auipc	ra,0xffffc
    80005a84:	c84080e7          	jalr	-892(ra) # 80001704 <uvmalloc>
    80005a88:	8c2a                	mv	s8,a0
  ip = 0;
    80005a8a:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005a8c:	14050c63          	beqz	a0,80005be4 <exec+0x370>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005a90:	75f9                	lui	a1,0xffffe
    80005a92:	95aa                	add	a1,a1,a0
    80005a94:	8526                	mv	a0,s1
    80005a96:	ffffc097          	auipc	ra,0xffffc
    80005a9a:	faa080e7          	jalr	-86(ra) # 80001a40 <uvmclear>
  stackbase = sp - PGSIZE;
    80005a9e:	7afd                	lui	s5,0xfffff
    80005aa0:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005aa2:	aa843783          	ld	a5,-1368(s0)
    80005aa6:	6388                	ld	a0,0(a5)
    80005aa8:	c53d                	beqz	a0,80005b16 <exec+0x2a2>
    80005aaa:	e8840913          	addi	s2,s0,-376
    80005aae:	f8840b93          	addi	s7,s0,-120
  sp = sz;
    80005ab2:	84e2                	mv	s1,s8
  for(argc = 0; argv[argc]; argc++) {
    80005ab4:	4a01                	li	s4,0
    sp -= strlen(argv[argc]) + 1;
    80005ab6:	ffffb097          	auipc	ra,0xffffb
    80005aba:	38c080e7          	jalr	908(ra) # 80000e42 <strlen>
    80005abe:	0015079b          	addiw	a5,a0,1
    80005ac2:	8c9d                	sub	s1,s1,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005ac4:	98c1                	andi	s1,s1,-16
    if(sp < stackbase)
    80005ac6:	1954e863          	bltu	s1,s5,80005c56 <exec+0x3e2>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005aca:	aa843d03          	ld	s10,-1368(s0)
    80005ace:	000d3983          	ld	s3,0(s10) # fffffffffffff000 <end+0xffffffff7ffcb000>
    80005ad2:	854e                	mv	a0,s3
    80005ad4:	ffffb097          	auipc	ra,0xffffb
    80005ad8:	36e080e7          	jalr	878(ra) # 80000e42 <strlen>
    80005adc:	0015069b          	addiw	a3,a0,1
    80005ae0:	864e                	mv	a2,s3
    80005ae2:	85a6                	mv	a1,s1
    80005ae4:	ae843503          	ld	a0,-1304(s0)
    80005ae8:	ffffc097          	auipc	ra,0xffffc
    80005aec:	f8a080e7          	jalr	-118(ra) # 80001a72 <copyout>
    80005af0:	16054763          	bltz	a0,80005c5e <exec+0x3ea>
    ustack[argc] = sp;
    80005af4:	00993023          	sd	s1,0(s2)
  for(argc = 0; argv[argc]; argc++) {
    80005af8:	0a05                	addi	s4,s4,1
    80005afa:	008d0793          	addi	a5,s10,8
    80005afe:	aaf43423          	sd	a5,-1368(s0)
    80005b02:	008d3503          	ld	a0,8(s10)
    80005b06:	c911                	beqz	a0,80005b1a <exec+0x2a6>
    if(argc >= MAXARG)
    80005b08:	0921                	addi	s2,s2,8
    80005b0a:	fb2b96e3          	bne	s7,s2,80005ab6 <exec+0x242>
  sz = sz1;
    80005b0e:	ad843823          	sd	s8,-1328(s0)
  ip = 0;
    80005b12:	4a81                	li	s5,0
    80005b14:	a8c1                	j	80005be4 <exec+0x370>
  sp = sz;
    80005b16:	84e2                	mv	s1,s8
  for(argc = 0; argv[argc]; argc++) {
    80005b18:	4a01                	li	s4,0
  ustack[argc] = 0;
    80005b1a:	003a1793          	slli	a5,s4,0x3
    80005b1e:	f9040713          	addi	a4,s0,-112
    80005b22:	97ba                	add	a5,a5,a4
    80005b24:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffcaef8>
  sp -= (argc+1) * sizeof(uint64);
    80005b28:	001a0693          	addi	a3,s4,1
    80005b2c:	068e                	slli	a3,a3,0x3
    80005b2e:	8c95                	sub	s1,s1,a3
  sp -= sp % 16;
    80005b30:	98c1                	andi	s1,s1,-16
  if(sp < stackbase)
    80005b32:	0154f663          	bgeu	s1,s5,80005b3e <exec+0x2ca>
  sz = sz1;
    80005b36:	ad843823          	sd	s8,-1328(s0)
  ip = 0;
    80005b3a:	4a81                	li	s5,0
    80005b3c:	a065                	j	80005be4 <exec+0x370>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005b3e:	e8840613          	addi	a2,s0,-376
    80005b42:	85a6                	mv	a1,s1
    80005b44:	ae843503          	ld	a0,-1304(s0)
    80005b48:	ffffc097          	auipc	ra,0xffffc
    80005b4c:	f2a080e7          	jalr	-214(ra) # 80001a72 <copyout>
    80005b50:	10054b63          	bltz	a0,80005c66 <exec+0x3f2>
    if(p->pid > 2){
    80005b54:	030b2703          	lw	a4,48(s6)
    80005b58:	4789                	li	a5,2
    80005b5a:	00e7ce63          	blt	a5,a4,80005b76 <exec+0x302>
  p->trapframe->a1 = sp;
    80005b5e:	058b3783          	ld	a5,88(s6)
    80005b62:	ffa4                	sd	s1,120(a5)
  for(last=s=path; *s; s++)
    80005b64:	a9843783          	ld	a5,-1384(s0)
    80005b68:	0007c703          	lbu	a4,0(a5)
    80005b6c:	cb0d                	beqz	a4,80005b9e <exec+0x32a>
    80005b6e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005b70:	02f00693          	li	a3,47
    80005b74:	a015                	j	80005b98 <exec+0x324>
      removeSwapFile(p);
    80005b76:	855a                	mv	a0,s6
    80005b78:	fffff097          	auipc	ra,0xfffff
    80005b7c:	b3c080e7          	jalr	-1220(ra) # 800046b4 <removeSwapFile>
      createSwapFile(p);
    80005b80:	855a                	mv	a0,s6
    80005b82:	fffff097          	auipc	ra,0xfffff
    80005b86:	cda080e7          	jalr	-806(ra) # 8000485c <createSwapFile>
    80005b8a:	bfd1                	j	80005b5e <exec+0x2ea>
      last = s+1;
    80005b8c:	a8f43c23          	sd	a5,-1384(s0)
  for(last=s=path; *s; s++)
    80005b90:	0785                	addi	a5,a5,1
    80005b92:	fff7c703          	lbu	a4,-1(a5)
    80005b96:	c701                	beqz	a4,80005b9e <exec+0x32a>
    if(*s == '/')
    80005b98:	fed71ce3          	bne	a4,a3,80005b90 <exec+0x31c>
    80005b9c:	bfc5                	j	80005b8c <exec+0x318>
  safestrcpy(p->name, last, sizeof(p->name));
    80005b9e:	4641                	li	a2,16
    80005ba0:	a9843583          	ld	a1,-1384(s0)
    80005ba4:	158b0513          	addi	a0,s6,344
    80005ba8:	ffffb097          	auipc	ra,0xffffb
    80005bac:	268080e7          	jalr	616(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    80005bb0:	050b3503          	ld	a0,80(s6)
  p->pagetable = pagetable;
    80005bb4:	ae843783          	ld	a5,-1304(s0)
    80005bb8:	04fb3823          	sd	a5,80(s6)
  p->sz = sz;
    80005bbc:	058b3423          	sd	s8,72(s6)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005bc0:	058b3783          	ld	a5,88(s6)
    80005bc4:	e6043703          	ld	a4,-416(s0)
    80005bc8:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005bca:	058b3783          	ld	a5,88(s6)
    80005bce:	fb84                	sd	s1,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005bd0:	85e6                	mv	a1,s9
    80005bd2:	ffffc097          	auipc	ra,0xffffc
    80005bd6:	36c080e7          	jalr	876(ra) # 80001f3e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005bda:	000a051b          	sext.w	a0,s4
    80005bde:	a0e5                	j	80005cc6 <exec+0x452>
    80005be0:	ac943823          	sd	s1,-1328(s0)
    p->numOfPhyPages = numOfPhyPages_backup;
    80005be4:	ac843783          	ld	a5,-1336(s0)
    80005be8:	16fb2c23          	sw	a5,376(s6)
    p->numOfTotalPages = numOfTotalPages_backup;
    80005bec:	ac043783          	ld	a5,-1344(s0)
    80005bf0:	16fb2e23          	sw	a5,380(s6)
    p->numOfPageFault = numOfPageFaults_backup; 
    80005bf4:	ab843783          	ld	a5,-1352(s0)
    80005bf8:	48fb2c23          	sw	a5,1176(s6)
    p->swapOffset = swapOffset_backup;
    80005bfc:	ab043783          	ld	a5,-1360(s0)
    80005c00:	16fb2823          	sw	a5,368(s6)
    memmove(&p->swapPagesArray, &swapPagesArray_backup, sizeof(p->swapPagesArray));
    80005c04:	19800613          	li	a2,408
    80005c08:	c7840593          	addi	a1,s0,-904
    80005c0c:	180b0513          	addi	a0,s6,384
    80005c10:	ffffb097          	auipc	ra,0xffffb
    80005c14:	10a080e7          	jalr	266(ra) # 80000d1a <memmove>
    memmove(&p->physPagesArray, &physPagesArray_backup, sizeof(p->physPagesArray));
    80005c18:	18000613          	li	a2,384
    80005c1c:	af840593          	addi	a1,s0,-1288
    80005c20:	318b0513          	addi	a0,s6,792
    80005c24:	ffffb097          	auipc	ra,0xffffb
    80005c28:	0f6080e7          	jalr	246(ra) # 80000d1a <memmove>
    proc_freepagetable(pagetable, sz);
    80005c2c:	ad043583          	ld	a1,-1328(s0)
    80005c30:	ae843503          	ld	a0,-1304(s0)
    80005c34:	ffffc097          	auipc	ra,0xffffc
    80005c38:	30a080e7          	jalr	778(ra) # 80001f3e <proc_freepagetable>
  if(ip){
    80005c3c:	060a9b63          	bnez	s5,80005cb2 <exec+0x43e>
  return -1;
    80005c40:	557d                	li	a0,-1
    80005c42:	a051                	j	80005cc6 <exec+0x452>
    80005c44:	ac943823          	sd	s1,-1328(s0)
    80005c48:	bf71                	j	80005be4 <exec+0x370>
    80005c4a:	ac943823          	sd	s1,-1328(s0)
    80005c4e:	bf59                	j	80005be4 <exec+0x370>
    80005c50:	ac943823          	sd	s1,-1328(s0)
    80005c54:	bf41                	j	80005be4 <exec+0x370>
  sz = sz1;
    80005c56:	ad843823          	sd	s8,-1328(s0)
  ip = 0;
    80005c5a:	4a81                	li	s5,0
    80005c5c:	b761                	j	80005be4 <exec+0x370>
  sz = sz1;
    80005c5e:	ad843823          	sd	s8,-1328(s0)
  ip = 0;
    80005c62:	4a81                	li	s5,0
    80005c64:	b741                	j	80005be4 <exec+0x370>
  sz = sz1;
    80005c66:	ad843823          	sd	s8,-1328(s0)
  ip = 0;
    80005c6a:	4a81                	li	s5,0
    80005c6c:	bfa5                	j	80005be4 <exec+0x370>
    p->numOfPhyPages = numOfPhyPages_backup;
    80005c6e:	ac843783          	ld	a5,-1336(s0)
    80005c72:	16fb2c23          	sw	a5,376(s6)
    p->numOfTotalPages = numOfTotalPages_backup;
    80005c76:	ac043783          	ld	a5,-1344(s0)
    80005c7a:	16fb2e23          	sw	a5,380(s6)
    p->numOfPageFault = numOfPageFaults_backup; 
    80005c7e:	ab843783          	ld	a5,-1352(s0)
    80005c82:	48fb2c23          	sw	a5,1176(s6)
    p->swapOffset = swapOffset_backup;
    80005c86:	ab043783          	ld	a5,-1360(s0)
    80005c8a:	16fb2823          	sw	a5,368(s6)
    memmove(&p->swapPagesArray, &swapPagesArray_backup, sizeof(p->swapPagesArray));
    80005c8e:	19800613          	li	a2,408
    80005c92:	c7840593          	addi	a1,s0,-904
    80005c96:	854a                	mv	a0,s2
    80005c98:	ffffb097          	auipc	ra,0xffffb
    80005c9c:	082080e7          	jalr	130(ra) # 80000d1a <memmove>
    memmove(&p->physPagesArray, &physPagesArray_backup, sizeof(p->physPagesArray));
    80005ca0:	18000613          	li	a2,384
    80005ca4:	af840593          	addi	a1,s0,-1288
    80005ca8:	8526                	mv	a0,s1
    80005caa:	ffffb097          	auipc	ra,0xffffb
    80005cae:	070080e7          	jalr	112(ra) # 80000d1a <memmove>
    iunlockput(ip);
    80005cb2:	8556                	mv	a0,s5
    80005cb4:	ffffe097          	auipc	ra,0xffffe
    80005cb8:	400080e7          	jalr	1024(ra) # 800040b4 <iunlockput>
    end_op();
    80005cbc:	fffff097          	auipc	ra,0xfffff
    80005cc0:	f24080e7          	jalr	-220(ra) # 80004be0 <end_op>
  return -1;
    80005cc4:	557d                	li	a0,-1
}
    80005cc6:	56813083          	ld	ra,1384(sp)
    80005cca:	56013403          	ld	s0,1376(sp)
    80005cce:	55813483          	ld	s1,1368(sp)
    80005cd2:	55013903          	ld	s2,1360(sp)
    80005cd6:	54813983          	ld	s3,1352(sp)
    80005cda:	54013a03          	ld	s4,1344(sp)
    80005cde:	53813a83          	ld	s5,1336(sp)
    80005ce2:	53013b03          	ld	s6,1328(sp)
    80005ce6:	52813b83          	ld	s7,1320(sp)
    80005cea:	52013c03          	ld	s8,1312(sp)
    80005cee:	51813c83          	ld	s9,1304(sp)
    80005cf2:	51013d03          	ld	s10,1296(sp)
    80005cf6:	50813d83          	ld	s11,1288(sp)
    80005cfa:	57010113          	addi	sp,sp,1392
    80005cfe:	8082                	ret
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005d00:	ad043483          	ld	s1,-1328(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005d04:	ae043783          	ld	a5,-1312(s0)
    80005d08:	0017869b          	addiw	a3,a5,1
    80005d0c:	aed43023          	sd	a3,-1312(s0)
    80005d10:	ad843783          	ld	a5,-1320(s0)
    80005d14:	0387879b          	addiw	a5,a5,56
    80005d18:	e8045703          	lhu	a4,-384(s0)
    80005d1c:	d2e6d5e3          	bge	a3,a4,80005a46 <exec+0x1d2>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005d20:	2781                	sext.w	a5,a5
    80005d22:	acf43c23          	sd	a5,-1320(s0)
    80005d26:	03800713          	li	a4,56
    80005d2a:	86be                	mv	a3,a5
    80005d2c:	e1040613          	addi	a2,s0,-496
    80005d30:	4581                	li	a1,0
    80005d32:	8556                	mv	a0,s5
    80005d34:	ffffe097          	auipc	ra,0xffffe
    80005d38:	3d2080e7          	jalr	978(ra) # 80004106 <readi>
    80005d3c:	03800793          	li	a5,56
    80005d40:	eaf510e3          	bne	a0,a5,80005be0 <exec+0x36c>
    if(ph.type != ELF_PROG_LOAD)
    80005d44:	e1042783          	lw	a5,-496(s0)
    80005d48:	4705                	li	a4,1
    80005d4a:	fae79de3          	bne	a5,a4,80005d04 <exec+0x490>
    if(ph.memsz < ph.filesz)
    80005d4e:	e3843603          	ld	a2,-456(s0)
    80005d52:	e3043783          	ld	a5,-464(s0)
    80005d56:	eef667e3          	bltu	a2,a5,80005c44 <exec+0x3d0>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005d5a:	e2043783          	ld	a5,-480(s0)
    80005d5e:	963e                	add	a2,a2,a5
    80005d60:	eef665e3          	bltu	a2,a5,80005c4a <exec+0x3d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005d64:	85a6                	mv	a1,s1
    80005d66:	ae843503          	ld	a0,-1304(s0)
    80005d6a:	ffffc097          	auipc	ra,0xffffc
    80005d6e:	99a080e7          	jalr	-1638(ra) # 80001704 <uvmalloc>
    80005d72:	aca43823          	sd	a0,-1328(s0)
    80005d76:	ec050de3          	beqz	a0,80005c50 <exec+0x3dc>
    if(ph.vaddr % PGSIZE != 0)
    80005d7a:	e2043c03          	ld	s8,-480(s0)
    80005d7e:	aa043783          	ld	a5,-1376(s0)
    80005d82:	00fc77b3          	and	a5,s8,a5
    80005d86:	e4079fe3          	bnez	a5,80005be4 <exec+0x370>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005d8a:	e1842c83          	lw	s9,-488(s0)
    80005d8e:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005d92:	f60b87e3          	beqz	s7,80005d00 <exec+0x48c>
    80005d96:	89de                	mv	s3,s7
    80005d98:	4481                	li	s1,0
    80005d9a:	b161                	j	80005a22 <exec+0x1ae>

0000000080005d9c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005d9c:	7179                	addi	sp,sp,-48
    80005d9e:	f406                	sd	ra,40(sp)
    80005da0:	f022                	sd	s0,32(sp)
    80005da2:	ec26                	sd	s1,24(sp)
    80005da4:	e84a                	sd	s2,16(sp)
    80005da6:	1800                	addi	s0,sp,48
    80005da8:	892e                	mv	s2,a1
    80005daa:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005dac:	fdc40593          	addi	a1,s0,-36
    80005db0:	ffffd097          	auipc	ra,0xffffd
    80005db4:	4fe080e7          	jalr	1278(ra) # 800032ae <argint>
    80005db8:	04054063          	bltz	a0,80005df8 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005dbc:	fdc42703          	lw	a4,-36(s0)
    80005dc0:	47bd                	li	a5,15
    80005dc2:	02e7ed63          	bltu	a5,a4,80005dfc <argfd+0x60>
    80005dc6:	ffffc097          	auipc	ra,0xffffc
    80005dca:	fec080e7          	jalr	-20(ra) # 80001db2 <myproc>
    80005dce:	fdc42703          	lw	a4,-36(s0)
    80005dd2:	01a70793          	addi	a5,a4,26
    80005dd6:	078e                	slli	a5,a5,0x3
    80005dd8:	953e                	add	a0,a0,a5
    80005dda:	611c                	ld	a5,0(a0)
    80005ddc:	c395                	beqz	a5,80005e00 <argfd+0x64>
    return -1;
  if(pfd)
    80005dde:	00090463          	beqz	s2,80005de6 <argfd+0x4a>
    *pfd = fd;
    80005de2:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005de6:	4501                	li	a0,0
  if(pf)
    80005de8:	c091                	beqz	s1,80005dec <argfd+0x50>
    *pf = f;
    80005dea:	e09c                	sd	a5,0(s1)
}
    80005dec:	70a2                	ld	ra,40(sp)
    80005dee:	7402                	ld	s0,32(sp)
    80005df0:	64e2                	ld	s1,24(sp)
    80005df2:	6942                	ld	s2,16(sp)
    80005df4:	6145                	addi	sp,sp,48
    80005df6:	8082                	ret
    return -1;
    80005df8:	557d                	li	a0,-1
    80005dfa:	bfcd                	j	80005dec <argfd+0x50>
    return -1;
    80005dfc:	557d                	li	a0,-1
    80005dfe:	b7fd                	j	80005dec <argfd+0x50>
    80005e00:	557d                	li	a0,-1
    80005e02:	b7ed                	j	80005dec <argfd+0x50>

0000000080005e04 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005e04:	1101                	addi	sp,sp,-32
    80005e06:	ec06                	sd	ra,24(sp)
    80005e08:	e822                	sd	s0,16(sp)
    80005e0a:	e426                	sd	s1,8(sp)
    80005e0c:	1000                	addi	s0,sp,32
    80005e0e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005e10:	ffffc097          	auipc	ra,0xffffc
    80005e14:	fa2080e7          	jalr	-94(ra) # 80001db2 <myproc>
    80005e18:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005e1a:	0d050793          	addi	a5,a0,208
    80005e1e:	4501                	li	a0,0
    80005e20:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005e22:	6398                	ld	a4,0(a5)
    80005e24:	cb19                	beqz	a4,80005e3a <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005e26:	2505                	addiw	a0,a0,1
    80005e28:	07a1                	addi	a5,a5,8
    80005e2a:	fed51ce3          	bne	a0,a3,80005e22 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005e2e:	557d                	li	a0,-1
}
    80005e30:	60e2                	ld	ra,24(sp)
    80005e32:	6442                	ld	s0,16(sp)
    80005e34:	64a2                	ld	s1,8(sp)
    80005e36:	6105                	addi	sp,sp,32
    80005e38:	8082                	ret
      p->ofile[fd] = f;
    80005e3a:	01a50793          	addi	a5,a0,26
    80005e3e:	078e                	slli	a5,a5,0x3
    80005e40:	963e                	add	a2,a2,a5
    80005e42:	e204                	sd	s1,0(a2)
      return fd;
    80005e44:	b7f5                	j	80005e30 <fdalloc+0x2c>

0000000080005e46 <sys_dup>:

uint64
sys_dup(void)
{
    80005e46:	7179                	addi	sp,sp,-48
    80005e48:	f406                	sd	ra,40(sp)
    80005e4a:	f022                	sd	s0,32(sp)
    80005e4c:	ec26                	sd	s1,24(sp)
    80005e4e:	1800                	addi	s0,sp,48
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
    80005e50:	fd840613          	addi	a2,s0,-40
    80005e54:	4581                	li	a1,0
    80005e56:	4501                	li	a0,0
    80005e58:	00000097          	auipc	ra,0x0
    80005e5c:	f44080e7          	jalr	-188(ra) # 80005d9c <argfd>
    return -1;
    80005e60:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005e62:	02054363          	bltz	a0,80005e88 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005e66:	fd843503          	ld	a0,-40(s0)
    80005e6a:	00000097          	auipc	ra,0x0
    80005e6e:	f9a080e7          	jalr	-102(ra) # 80005e04 <fdalloc>
    80005e72:	84aa                	mv	s1,a0
    return -1;
    80005e74:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005e76:	00054963          	bltz	a0,80005e88 <sys_dup+0x42>
  filedup(f);
    80005e7a:	fd843503          	ld	a0,-40(s0)
    80005e7e:	fffff097          	auipc	ra,0xfffff
    80005e82:	15c080e7          	jalr	348(ra) # 80004fda <filedup>
  return fd;
    80005e86:	87a6                	mv	a5,s1
}
    80005e88:	853e                	mv	a0,a5
    80005e8a:	70a2                	ld	ra,40(sp)
    80005e8c:	7402                	ld	s0,32(sp)
    80005e8e:	64e2                	ld	s1,24(sp)
    80005e90:	6145                	addi	sp,sp,48
    80005e92:	8082                	ret

0000000080005e94 <sys_read>:

uint64
sys_read(void)
{
    80005e94:	7179                	addi	sp,sp,-48
    80005e96:	f406                	sd	ra,40(sp)
    80005e98:	f022                	sd	s0,32(sp)
    80005e9a:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005e9c:	fe840613          	addi	a2,s0,-24
    80005ea0:	4581                	li	a1,0
    80005ea2:	4501                	li	a0,0
    80005ea4:	00000097          	auipc	ra,0x0
    80005ea8:	ef8080e7          	jalr	-264(ra) # 80005d9c <argfd>
    return -1;
    80005eac:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005eae:	04054163          	bltz	a0,80005ef0 <sys_read+0x5c>
    80005eb2:	fe440593          	addi	a1,s0,-28
    80005eb6:	4509                	li	a0,2
    80005eb8:	ffffd097          	auipc	ra,0xffffd
    80005ebc:	3f6080e7          	jalr	1014(ra) # 800032ae <argint>
    return -1;
    80005ec0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005ec2:	02054763          	bltz	a0,80005ef0 <sys_read+0x5c>
    80005ec6:	fd840593          	addi	a1,s0,-40
    80005eca:	4505                	li	a0,1
    80005ecc:	ffffd097          	auipc	ra,0xffffd
    80005ed0:	404080e7          	jalr	1028(ra) # 800032d0 <argaddr>
    return -1;
    80005ed4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005ed6:	00054d63          	bltz	a0,80005ef0 <sys_read+0x5c>
  return fileread(f, p, n);
    80005eda:	fe442603          	lw	a2,-28(s0)
    80005ede:	fd843583          	ld	a1,-40(s0)
    80005ee2:	fe843503          	ld	a0,-24(s0)
    80005ee6:	fffff097          	auipc	ra,0xfffff
    80005eea:	280080e7          	jalr	640(ra) # 80005166 <fileread>
    80005eee:	87aa                	mv	a5,a0
}
    80005ef0:	853e                	mv	a0,a5
    80005ef2:	70a2                	ld	ra,40(sp)
    80005ef4:	7402                	ld	s0,32(sp)
    80005ef6:	6145                	addi	sp,sp,48
    80005ef8:	8082                	ret

0000000080005efa <sys_write>:

uint64
sys_write(void)
{
    80005efa:	7179                	addi	sp,sp,-48
    80005efc:	f406                	sd	ra,40(sp)
    80005efe:	f022                	sd	s0,32(sp)
    80005f00:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f02:	fe840613          	addi	a2,s0,-24
    80005f06:	4581                	li	a1,0
    80005f08:	4501                	li	a0,0
    80005f0a:	00000097          	auipc	ra,0x0
    80005f0e:	e92080e7          	jalr	-366(ra) # 80005d9c <argfd>
    return -1;
    80005f12:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f14:	04054163          	bltz	a0,80005f56 <sys_write+0x5c>
    80005f18:	fe440593          	addi	a1,s0,-28
    80005f1c:	4509                	li	a0,2
    80005f1e:	ffffd097          	auipc	ra,0xffffd
    80005f22:	390080e7          	jalr	912(ra) # 800032ae <argint>
    return -1;
    80005f26:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f28:	02054763          	bltz	a0,80005f56 <sys_write+0x5c>
    80005f2c:	fd840593          	addi	a1,s0,-40
    80005f30:	4505                	li	a0,1
    80005f32:	ffffd097          	auipc	ra,0xffffd
    80005f36:	39e080e7          	jalr	926(ra) # 800032d0 <argaddr>
    return -1;
    80005f3a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f3c:	00054d63          	bltz	a0,80005f56 <sys_write+0x5c>

  return filewrite(f, p, n);
    80005f40:	fe442603          	lw	a2,-28(s0)
    80005f44:	fd843583          	ld	a1,-40(s0)
    80005f48:	fe843503          	ld	a0,-24(s0)
    80005f4c:	fffff097          	auipc	ra,0xfffff
    80005f50:	2dc080e7          	jalr	732(ra) # 80005228 <filewrite>
    80005f54:	87aa                	mv	a5,a0
}
    80005f56:	853e                	mv	a0,a5
    80005f58:	70a2                	ld	ra,40(sp)
    80005f5a:	7402                	ld	s0,32(sp)
    80005f5c:	6145                	addi	sp,sp,48
    80005f5e:	8082                	ret

0000000080005f60 <sys_close>:

uint64
sys_close(void)
{
    80005f60:	1101                	addi	sp,sp,-32
    80005f62:	ec06                	sd	ra,24(sp)
    80005f64:	e822                	sd	s0,16(sp)
    80005f66:	1000                	addi	s0,sp,32
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    80005f68:	fe040613          	addi	a2,s0,-32
    80005f6c:	fec40593          	addi	a1,s0,-20
    80005f70:	4501                	li	a0,0
    80005f72:	00000097          	auipc	ra,0x0
    80005f76:	e2a080e7          	jalr	-470(ra) # 80005d9c <argfd>
    return -1;
    80005f7a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005f7c:	02054463          	bltz	a0,80005fa4 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005f80:	ffffc097          	auipc	ra,0xffffc
    80005f84:	e32080e7          	jalr	-462(ra) # 80001db2 <myproc>
    80005f88:	fec42783          	lw	a5,-20(s0)
    80005f8c:	07e9                	addi	a5,a5,26
    80005f8e:	078e                	slli	a5,a5,0x3
    80005f90:	97aa                	add	a5,a5,a0
    80005f92:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005f96:	fe043503          	ld	a0,-32(s0)
    80005f9a:	fffff097          	auipc	ra,0xfffff
    80005f9e:	092080e7          	jalr	146(ra) # 8000502c <fileclose>
  return 0;
    80005fa2:	4781                	li	a5,0
}
    80005fa4:	853e                	mv	a0,a5
    80005fa6:	60e2                	ld	ra,24(sp)
    80005fa8:	6442                	ld	s0,16(sp)
    80005faa:	6105                	addi	sp,sp,32
    80005fac:	8082                	ret

0000000080005fae <sys_fstat>:

uint64
sys_fstat(void)
{
    80005fae:	1101                	addi	sp,sp,-32
    80005fb0:	ec06                	sd	ra,24(sp)
    80005fb2:	e822                	sd	s0,16(sp)
    80005fb4:	1000                	addi	s0,sp,32
  struct file *f;
  uint64 st; // user pointer to struct stat

  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005fb6:	fe840613          	addi	a2,s0,-24
    80005fba:	4581                	li	a1,0
    80005fbc:	4501                	li	a0,0
    80005fbe:	00000097          	auipc	ra,0x0
    80005fc2:	dde080e7          	jalr	-546(ra) # 80005d9c <argfd>
    return -1;
    80005fc6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005fc8:	02054563          	bltz	a0,80005ff2 <sys_fstat+0x44>
    80005fcc:	fe040593          	addi	a1,s0,-32
    80005fd0:	4505                	li	a0,1
    80005fd2:	ffffd097          	auipc	ra,0xffffd
    80005fd6:	2fe080e7          	jalr	766(ra) # 800032d0 <argaddr>
    return -1;
    80005fda:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005fdc:	00054b63          	bltz	a0,80005ff2 <sys_fstat+0x44>
  return filestat(f, st);
    80005fe0:	fe043583          	ld	a1,-32(s0)
    80005fe4:	fe843503          	ld	a0,-24(s0)
    80005fe8:	fffff097          	auipc	ra,0xfffff
    80005fec:	10c080e7          	jalr	268(ra) # 800050f4 <filestat>
    80005ff0:	87aa                	mv	a5,a0
}
    80005ff2:	853e                	mv	a0,a5
    80005ff4:	60e2                	ld	ra,24(sp)
    80005ff6:	6442                	ld	s0,16(sp)
    80005ff8:	6105                	addi	sp,sp,32
    80005ffa:	8082                	ret

0000000080005ffc <sys_link>:

// Create the path new as a link to the same inode as old.
uint64
sys_link(void)
{
    80005ffc:	7169                	addi	sp,sp,-304
    80005ffe:	f606                	sd	ra,296(sp)
    80006000:	f222                	sd	s0,288(sp)
    80006002:	ee26                	sd	s1,280(sp)
    80006004:	ea4a                	sd	s2,272(sp)
    80006006:	1a00                	addi	s0,sp,304
  char name[DIRSIZ], new[MAXPATH], old[MAXPATH];
  struct inode *dp, *ip;

  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006008:	08000613          	li	a2,128
    8000600c:	ed040593          	addi	a1,s0,-304
    80006010:	4501                	li	a0,0
    80006012:	ffffd097          	auipc	ra,0xffffd
    80006016:	2e0080e7          	jalr	736(ra) # 800032f2 <argstr>
    return -1;
    8000601a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000601c:	10054e63          	bltz	a0,80006138 <sys_link+0x13c>
    80006020:	08000613          	li	a2,128
    80006024:	f5040593          	addi	a1,s0,-176
    80006028:	4505                	li	a0,1
    8000602a:	ffffd097          	auipc	ra,0xffffd
    8000602e:	2c8080e7          	jalr	712(ra) # 800032f2 <argstr>
    return -1;
    80006032:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006034:	10054263          	bltz	a0,80006138 <sys_link+0x13c>

  begin_op();
    80006038:	fffff097          	auipc	ra,0xfffff
    8000603c:	b28080e7          	jalr	-1240(ra) # 80004b60 <begin_op>
  if((ip = namei(old)) == 0){
    80006040:	ed040513          	addi	a0,s0,-304
    80006044:	ffffe097          	auipc	ra,0xffffe
    80006048:	5c4080e7          	jalr	1476(ra) # 80004608 <namei>
    8000604c:	84aa                	mv	s1,a0
    8000604e:	c551                	beqz	a0,800060da <sys_link+0xde>
    end_op();
    return -1;
  }

  ilock(ip);
    80006050:	ffffe097          	auipc	ra,0xffffe
    80006054:	e02080e7          	jalr	-510(ra) # 80003e52 <ilock>
  if(ip->type == T_DIR){
    80006058:	04449703          	lh	a4,68(s1)
    8000605c:	4785                	li	a5,1
    8000605e:	08f70463          	beq	a4,a5,800060e6 <sys_link+0xea>
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
    80006062:	04a4d783          	lhu	a5,74(s1)
    80006066:	2785                	addiw	a5,a5,1
    80006068:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000606c:	8526                	mv	a0,s1
    8000606e:	ffffe097          	auipc	ra,0xffffe
    80006072:	d1a080e7          	jalr	-742(ra) # 80003d88 <iupdate>
  iunlock(ip);
    80006076:	8526                	mv	a0,s1
    80006078:	ffffe097          	auipc	ra,0xffffe
    8000607c:	e9c080e7          	jalr	-356(ra) # 80003f14 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
    80006080:	fd040593          	addi	a1,s0,-48
    80006084:	f5040513          	addi	a0,s0,-176
    80006088:	ffffe097          	auipc	ra,0xffffe
    8000608c:	59e080e7          	jalr	1438(ra) # 80004626 <nameiparent>
    80006090:	892a                	mv	s2,a0
    80006092:	c935                	beqz	a0,80006106 <sys_link+0x10a>
    goto bad;
  ilock(dp);
    80006094:	ffffe097          	auipc	ra,0xffffe
    80006098:	dbe080e7          	jalr	-578(ra) # 80003e52 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000609c:	00092703          	lw	a4,0(s2)
    800060a0:	409c                	lw	a5,0(s1)
    800060a2:	04f71d63          	bne	a4,a5,800060fc <sys_link+0x100>
    800060a6:	40d0                	lw	a2,4(s1)
    800060a8:	fd040593          	addi	a1,s0,-48
    800060ac:	854a                	mv	a0,s2
    800060ae:	ffffe097          	auipc	ra,0xffffe
    800060b2:	498080e7          	jalr	1176(ra) # 80004546 <dirlink>
    800060b6:	04054363          	bltz	a0,800060fc <sys_link+0x100>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
    800060ba:	854a                	mv	a0,s2
    800060bc:	ffffe097          	auipc	ra,0xffffe
    800060c0:	ff8080e7          	jalr	-8(ra) # 800040b4 <iunlockput>
  iput(ip);
    800060c4:	8526                	mv	a0,s1
    800060c6:	ffffe097          	auipc	ra,0xffffe
    800060ca:	f46080e7          	jalr	-186(ra) # 8000400c <iput>

  end_op();
    800060ce:	fffff097          	auipc	ra,0xfffff
    800060d2:	b12080e7          	jalr	-1262(ra) # 80004be0 <end_op>

  return 0;
    800060d6:	4781                	li	a5,0
    800060d8:	a085                	j	80006138 <sys_link+0x13c>
    end_op();
    800060da:	fffff097          	auipc	ra,0xfffff
    800060de:	b06080e7          	jalr	-1274(ra) # 80004be0 <end_op>
    return -1;
    800060e2:	57fd                	li	a5,-1
    800060e4:	a891                	j	80006138 <sys_link+0x13c>
    iunlockput(ip);
    800060e6:	8526                	mv	a0,s1
    800060e8:	ffffe097          	auipc	ra,0xffffe
    800060ec:	fcc080e7          	jalr	-52(ra) # 800040b4 <iunlockput>
    end_op();
    800060f0:	fffff097          	auipc	ra,0xfffff
    800060f4:	af0080e7          	jalr	-1296(ra) # 80004be0 <end_op>
    return -1;
    800060f8:	57fd                	li	a5,-1
    800060fa:	a83d                	j	80006138 <sys_link+0x13c>
    iunlockput(dp);
    800060fc:	854a                	mv	a0,s2
    800060fe:	ffffe097          	auipc	ra,0xffffe
    80006102:	fb6080e7          	jalr	-74(ra) # 800040b4 <iunlockput>

bad:
  ilock(ip);
    80006106:	8526                	mv	a0,s1
    80006108:	ffffe097          	auipc	ra,0xffffe
    8000610c:	d4a080e7          	jalr	-694(ra) # 80003e52 <ilock>
  ip->nlink--;
    80006110:	04a4d783          	lhu	a5,74(s1)
    80006114:	37fd                	addiw	a5,a5,-1
    80006116:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000611a:	8526                	mv	a0,s1
    8000611c:	ffffe097          	auipc	ra,0xffffe
    80006120:	c6c080e7          	jalr	-916(ra) # 80003d88 <iupdate>
  iunlockput(ip);
    80006124:	8526                	mv	a0,s1
    80006126:	ffffe097          	auipc	ra,0xffffe
    8000612a:	f8e080e7          	jalr	-114(ra) # 800040b4 <iunlockput>
  end_op();
    8000612e:	fffff097          	auipc	ra,0xfffff
    80006132:	ab2080e7          	jalr	-1358(ra) # 80004be0 <end_op>
  return -1;
    80006136:	57fd                	li	a5,-1
}
    80006138:	853e                	mv	a0,a5
    8000613a:	70b2                	ld	ra,296(sp)
    8000613c:	7412                	ld	s0,288(sp)
    8000613e:	64f2                	ld	s1,280(sp)
    80006140:	6952                	ld	s2,272(sp)
    80006142:	6155                	addi	sp,sp,304
    80006144:	8082                	ret

0000000080006146 <isdirempty>:
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006146:	4578                	lw	a4,76(a0)
    80006148:	02000793          	li	a5,32
    8000614c:	04e7fa63          	bgeu	a5,a4,800061a0 <isdirempty+0x5a>
{
    80006150:	7179                	addi	sp,sp,-48
    80006152:	f406                	sd	ra,40(sp)
    80006154:	f022                	sd	s0,32(sp)
    80006156:	ec26                	sd	s1,24(sp)
    80006158:	e84a                	sd	s2,16(sp)
    8000615a:	1800                	addi	s0,sp,48
    8000615c:	892a                	mv	s2,a0
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000615e:	02000493          	li	s1,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006162:	4741                	li	a4,16
    80006164:	86a6                	mv	a3,s1
    80006166:	fd040613          	addi	a2,s0,-48
    8000616a:	4581                	li	a1,0
    8000616c:	854a                	mv	a0,s2
    8000616e:	ffffe097          	auipc	ra,0xffffe
    80006172:	f98080e7          	jalr	-104(ra) # 80004106 <readi>
    80006176:	47c1                	li	a5,16
    80006178:	00f51c63          	bne	a0,a5,80006190 <isdirempty+0x4a>
      panic("isdirempty: readi");
    if(de.inum != 0)
    8000617c:	fd045783          	lhu	a5,-48(s0)
    80006180:	e395                	bnez	a5,800061a4 <isdirempty+0x5e>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006182:	24c1                	addiw	s1,s1,16
    80006184:	04c92783          	lw	a5,76(s2)
    80006188:	fcf4ede3          	bltu	s1,a5,80006162 <isdirempty+0x1c>
      return 0;
  }
  return 1;
    8000618c:	4505                	li	a0,1
    8000618e:	a821                	j	800061a6 <isdirempty+0x60>
      panic("isdirempty: readi");
    80006190:	00004517          	auipc	a0,0x4
    80006194:	8b850513          	addi	a0,a0,-1864 # 80009a48 <syscalls+0x318>
    80006198:	ffffa097          	auipc	ra,0xffffa
    8000619c:	392080e7          	jalr	914(ra) # 8000052a <panic>
  return 1;
    800061a0:	4505                	li	a0,1
}
    800061a2:	8082                	ret
      return 0;
    800061a4:	4501                	li	a0,0
}
    800061a6:	70a2                	ld	ra,40(sp)
    800061a8:	7402                	ld	s0,32(sp)
    800061aa:	64e2                	ld	s1,24(sp)
    800061ac:	6942                	ld	s2,16(sp)
    800061ae:	6145                	addi	sp,sp,48
    800061b0:	8082                	ret

00000000800061b2 <sys_unlink>:

uint64
sys_unlink(void)
{
    800061b2:	7155                	addi	sp,sp,-208
    800061b4:	e586                	sd	ra,200(sp)
    800061b6:	e1a2                	sd	s0,192(sp)
    800061b8:	fd26                	sd	s1,184(sp)
    800061ba:	f94a                	sd	s2,176(sp)
    800061bc:	0980                	addi	s0,sp,208
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], path[MAXPATH];
  uint off;

  if(argstr(0, path, MAXPATH) < 0)
    800061be:	08000613          	li	a2,128
    800061c2:	f4040593          	addi	a1,s0,-192
    800061c6:	4501                	li	a0,0
    800061c8:	ffffd097          	auipc	ra,0xffffd
    800061cc:	12a080e7          	jalr	298(ra) # 800032f2 <argstr>
    800061d0:	16054363          	bltz	a0,80006336 <sys_unlink+0x184>
    return -1;

  begin_op();
    800061d4:	fffff097          	auipc	ra,0xfffff
    800061d8:	98c080e7          	jalr	-1652(ra) # 80004b60 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800061dc:	fc040593          	addi	a1,s0,-64
    800061e0:	f4040513          	addi	a0,s0,-192
    800061e4:	ffffe097          	auipc	ra,0xffffe
    800061e8:	442080e7          	jalr	1090(ra) # 80004626 <nameiparent>
    800061ec:	84aa                	mv	s1,a0
    800061ee:	c961                	beqz	a0,800062be <sys_unlink+0x10c>
    end_op();
    return -1;
  }

  ilock(dp);
    800061f0:	ffffe097          	auipc	ra,0xffffe
    800061f4:	c62080e7          	jalr	-926(ra) # 80003e52 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800061f8:	00003597          	auipc	a1,0x3
    800061fc:	73058593          	addi	a1,a1,1840 # 80009928 <syscalls+0x1f8>
    80006200:	fc040513          	addi	a0,s0,-64
    80006204:	ffffe097          	auipc	ra,0xffffe
    80006208:	118080e7          	jalr	280(ra) # 8000431c <namecmp>
    8000620c:	c175                	beqz	a0,800062f0 <sys_unlink+0x13e>
    8000620e:	00003597          	auipc	a1,0x3
    80006212:	72258593          	addi	a1,a1,1826 # 80009930 <syscalls+0x200>
    80006216:	fc040513          	addi	a0,s0,-64
    8000621a:	ffffe097          	auipc	ra,0xffffe
    8000621e:	102080e7          	jalr	258(ra) # 8000431c <namecmp>
    80006222:	c579                	beqz	a0,800062f0 <sys_unlink+0x13e>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    80006224:	f3c40613          	addi	a2,s0,-196
    80006228:	fc040593          	addi	a1,s0,-64
    8000622c:	8526                	mv	a0,s1
    8000622e:	ffffe097          	auipc	ra,0xffffe
    80006232:	108080e7          	jalr	264(ra) # 80004336 <dirlookup>
    80006236:	892a                	mv	s2,a0
    80006238:	cd45                	beqz	a0,800062f0 <sys_unlink+0x13e>
    goto bad;
  ilock(ip);
    8000623a:	ffffe097          	auipc	ra,0xffffe
    8000623e:	c18080e7          	jalr	-1000(ra) # 80003e52 <ilock>

  if(ip->nlink < 1)
    80006242:	04a91783          	lh	a5,74(s2)
    80006246:	08f05263          	blez	a5,800062ca <sys_unlink+0x118>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000624a:	04491703          	lh	a4,68(s2)
    8000624e:	4785                	li	a5,1
    80006250:	08f70563          	beq	a4,a5,800062da <sys_unlink+0x128>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    80006254:	4641                	li	a2,16
    80006256:	4581                	li	a1,0
    80006258:	fd040513          	addi	a0,s0,-48
    8000625c:	ffffb097          	auipc	ra,0xffffb
    80006260:	a62080e7          	jalr	-1438(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006264:	4741                	li	a4,16
    80006266:	f3c42683          	lw	a3,-196(s0)
    8000626a:	fd040613          	addi	a2,s0,-48
    8000626e:	4581                	li	a1,0
    80006270:	8526                	mv	a0,s1
    80006272:	ffffe097          	auipc	ra,0xffffe
    80006276:	f8c080e7          	jalr	-116(ra) # 800041fe <writei>
    8000627a:	47c1                	li	a5,16
    8000627c:	08f51a63          	bne	a0,a5,80006310 <sys_unlink+0x15e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    80006280:	04491703          	lh	a4,68(s2)
    80006284:	4785                	li	a5,1
    80006286:	08f70d63          	beq	a4,a5,80006320 <sys_unlink+0x16e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    8000628a:	8526                	mv	a0,s1
    8000628c:	ffffe097          	auipc	ra,0xffffe
    80006290:	e28080e7          	jalr	-472(ra) # 800040b4 <iunlockput>

  ip->nlink--;
    80006294:	04a95783          	lhu	a5,74(s2)
    80006298:	37fd                	addiw	a5,a5,-1
    8000629a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000629e:	854a                	mv	a0,s2
    800062a0:	ffffe097          	auipc	ra,0xffffe
    800062a4:	ae8080e7          	jalr	-1304(ra) # 80003d88 <iupdate>
  iunlockput(ip);
    800062a8:	854a                	mv	a0,s2
    800062aa:	ffffe097          	auipc	ra,0xffffe
    800062ae:	e0a080e7          	jalr	-502(ra) # 800040b4 <iunlockput>

  end_op();
    800062b2:	fffff097          	auipc	ra,0xfffff
    800062b6:	92e080e7          	jalr	-1746(ra) # 80004be0 <end_op>

  return 0;
    800062ba:	4501                	li	a0,0
    800062bc:	a0a1                	j	80006304 <sys_unlink+0x152>
    end_op();
    800062be:	fffff097          	auipc	ra,0xfffff
    800062c2:	922080e7          	jalr	-1758(ra) # 80004be0 <end_op>
    return -1;
    800062c6:	557d                	li	a0,-1
    800062c8:	a835                	j	80006304 <sys_unlink+0x152>
    panic("unlink: nlink < 1");
    800062ca:	00003517          	auipc	a0,0x3
    800062ce:	66e50513          	addi	a0,a0,1646 # 80009938 <syscalls+0x208>
    800062d2:	ffffa097          	auipc	ra,0xffffa
    800062d6:	258080e7          	jalr	600(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800062da:	854a                	mv	a0,s2
    800062dc:	00000097          	auipc	ra,0x0
    800062e0:	e6a080e7          	jalr	-406(ra) # 80006146 <isdirempty>
    800062e4:	f925                	bnez	a0,80006254 <sys_unlink+0xa2>
    iunlockput(ip);
    800062e6:	854a                	mv	a0,s2
    800062e8:	ffffe097          	auipc	ra,0xffffe
    800062ec:	dcc080e7          	jalr	-564(ra) # 800040b4 <iunlockput>

bad:
  iunlockput(dp);
    800062f0:	8526                	mv	a0,s1
    800062f2:	ffffe097          	auipc	ra,0xffffe
    800062f6:	dc2080e7          	jalr	-574(ra) # 800040b4 <iunlockput>
  end_op();
    800062fa:	fffff097          	auipc	ra,0xfffff
    800062fe:	8e6080e7          	jalr	-1818(ra) # 80004be0 <end_op>
  return -1;
    80006302:	557d                	li	a0,-1
}
    80006304:	60ae                	ld	ra,200(sp)
    80006306:	640e                	ld	s0,192(sp)
    80006308:	74ea                	ld	s1,184(sp)
    8000630a:	794a                	ld	s2,176(sp)
    8000630c:	6169                	addi	sp,sp,208
    8000630e:	8082                	ret
    panic("unlink: writei");
    80006310:	00003517          	auipc	a0,0x3
    80006314:	64050513          	addi	a0,a0,1600 # 80009950 <syscalls+0x220>
    80006318:	ffffa097          	auipc	ra,0xffffa
    8000631c:	212080e7          	jalr	530(ra) # 8000052a <panic>
    dp->nlink--;
    80006320:	04a4d783          	lhu	a5,74(s1)
    80006324:	37fd                	addiw	a5,a5,-1
    80006326:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000632a:	8526                	mv	a0,s1
    8000632c:	ffffe097          	auipc	ra,0xffffe
    80006330:	a5c080e7          	jalr	-1444(ra) # 80003d88 <iupdate>
    80006334:	bf99                	j	8000628a <sys_unlink+0xd8>
    return -1;
    80006336:	557d                	li	a0,-1
    80006338:	b7f1                	j	80006304 <sys_unlink+0x152>

000000008000633a <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
    8000633a:	715d                	addi	sp,sp,-80
    8000633c:	e486                	sd	ra,72(sp)
    8000633e:	e0a2                	sd	s0,64(sp)
    80006340:	fc26                	sd	s1,56(sp)
    80006342:	f84a                	sd	s2,48(sp)
    80006344:	f44e                	sd	s3,40(sp)
    80006346:	f052                	sd	s4,32(sp)
    80006348:	ec56                	sd	s5,24(sp)
    8000634a:	0880                	addi	s0,sp,80
    8000634c:	89ae                	mv	s3,a1
    8000634e:	8ab2                	mv	s5,a2
    80006350:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80006352:	fb040593          	addi	a1,s0,-80
    80006356:	ffffe097          	auipc	ra,0xffffe
    8000635a:	2d0080e7          	jalr	720(ra) # 80004626 <nameiparent>
    8000635e:	892a                	mv	s2,a0
    80006360:	12050e63          	beqz	a0,8000649c <create+0x162>
    return 0;

  ilock(dp);
    80006364:	ffffe097          	auipc	ra,0xffffe
    80006368:	aee080e7          	jalr	-1298(ra) # 80003e52 <ilock>
  
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000636c:	4601                	li	a2,0
    8000636e:	fb040593          	addi	a1,s0,-80
    80006372:	854a                	mv	a0,s2
    80006374:	ffffe097          	auipc	ra,0xffffe
    80006378:	fc2080e7          	jalr	-62(ra) # 80004336 <dirlookup>
    8000637c:	84aa                	mv	s1,a0
    8000637e:	c921                	beqz	a0,800063ce <create+0x94>
    iunlockput(dp);
    80006380:	854a                	mv	a0,s2
    80006382:	ffffe097          	auipc	ra,0xffffe
    80006386:	d32080e7          	jalr	-718(ra) # 800040b4 <iunlockput>
    ilock(ip);
    8000638a:	8526                	mv	a0,s1
    8000638c:	ffffe097          	auipc	ra,0xffffe
    80006390:	ac6080e7          	jalr	-1338(ra) # 80003e52 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80006394:	2981                	sext.w	s3,s3
    80006396:	4789                	li	a5,2
    80006398:	02f99463          	bne	s3,a5,800063c0 <create+0x86>
    8000639c:	0444d783          	lhu	a5,68(s1)
    800063a0:	37f9                	addiw	a5,a5,-2
    800063a2:	17c2                	slli	a5,a5,0x30
    800063a4:	93c1                	srli	a5,a5,0x30
    800063a6:	4705                	li	a4,1
    800063a8:	00f76c63          	bltu	a4,a5,800063c0 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800063ac:	8526                	mv	a0,s1
    800063ae:	60a6                	ld	ra,72(sp)
    800063b0:	6406                	ld	s0,64(sp)
    800063b2:	74e2                	ld	s1,56(sp)
    800063b4:	7942                	ld	s2,48(sp)
    800063b6:	79a2                	ld	s3,40(sp)
    800063b8:	7a02                	ld	s4,32(sp)
    800063ba:	6ae2                	ld	s5,24(sp)
    800063bc:	6161                	addi	sp,sp,80
    800063be:	8082                	ret
    iunlockput(ip);
    800063c0:	8526                	mv	a0,s1
    800063c2:	ffffe097          	auipc	ra,0xffffe
    800063c6:	cf2080e7          	jalr	-782(ra) # 800040b4 <iunlockput>
    return 0;
    800063ca:	4481                	li	s1,0
    800063cc:	b7c5                	j	800063ac <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800063ce:	85ce                	mv	a1,s3
    800063d0:	00092503          	lw	a0,0(s2)
    800063d4:	ffffe097          	auipc	ra,0xffffe
    800063d8:	8e6080e7          	jalr	-1818(ra) # 80003cba <ialloc>
    800063dc:	84aa                	mv	s1,a0
    800063de:	c521                	beqz	a0,80006426 <create+0xec>
  ilock(ip);
    800063e0:	ffffe097          	auipc	ra,0xffffe
    800063e4:	a72080e7          	jalr	-1422(ra) # 80003e52 <ilock>
  ip->major = major;
    800063e8:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800063ec:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800063f0:	4a05                	li	s4,1
    800063f2:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800063f6:	8526                	mv	a0,s1
    800063f8:	ffffe097          	auipc	ra,0xffffe
    800063fc:	990080e7          	jalr	-1648(ra) # 80003d88 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80006400:	2981                	sext.w	s3,s3
    80006402:	03498a63          	beq	s3,s4,80006436 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80006406:	40d0                	lw	a2,4(s1)
    80006408:	fb040593          	addi	a1,s0,-80
    8000640c:	854a                	mv	a0,s2
    8000640e:	ffffe097          	auipc	ra,0xffffe
    80006412:	138080e7          	jalr	312(ra) # 80004546 <dirlink>
    80006416:	06054b63          	bltz	a0,8000648c <create+0x152>
  iunlockput(dp);
    8000641a:	854a                	mv	a0,s2
    8000641c:	ffffe097          	auipc	ra,0xffffe
    80006420:	c98080e7          	jalr	-872(ra) # 800040b4 <iunlockput>
  return ip;
    80006424:	b761                	j	800063ac <create+0x72>
    panic("create: ialloc");
    80006426:	00003517          	auipc	a0,0x3
    8000642a:	63a50513          	addi	a0,a0,1594 # 80009a60 <syscalls+0x330>
    8000642e:	ffffa097          	auipc	ra,0xffffa
    80006432:	0fc080e7          	jalr	252(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    80006436:	04a95783          	lhu	a5,74(s2)
    8000643a:	2785                	addiw	a5,a5,1
    8000643c:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80006440:	854a                	mv	a0,s2
    80006442:	ffffe097          	auipc	ra,0xffffe
    80006446:	946080e7          	jalr	-1722(ra) # 80003d88 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000644a:	40d0                	lw	a2,4(s1)
    8000644c:	00003597          	auipc	a1,0x3
    80006450:	4dc58593          	addi	a1,a1,1244 # 80009928 <syscalls+0x1f8>
    80006454:	8526                	mv	a0,s1
    80006456:	ffffe097          	auipc	ra,0xffffe
    8000645a:	0f0080e7          	jalr	240(ra) # 80004546 <dirlink>
    8000645e:	00054f63          	bltz	a0,8000647c <create+0x142>
    80006462:	00492603          	lw	a2,4(s2)
    80006466:	00003597          	auipc	a1,0x3
    8000646a:	4ca58593          	addi	a1,a1,1226 # 80009930 <syscalls+0x200>
    8000646e:	8526                	mv	a0,s1
    80006470:	ffffe097          	auipc	ra,0xffffe
    80006474:	0d6080e7          	jalr	214(ra) # 80004546 <dirlink>
    80006478:	f80557e3          	bgez	a0,80006406 <create+0xcc>
      panic("create dots");
    8000647c:	00003517          	auipc	a0,0x3
    80006480:	5f450513          	addi	a0,a0,1524 # 80009a70 <syscalls+0x340>
    80006484:	ffffa097          	auipc	ra,0xffffa
    80006488:	0a6080e7          	jalr	166(ra) # 8000052a <panic>
    panic("create: dirlink");
    8000648c:	00003517          	auipc	a0,0x3
    80006490:	5f450513          	addi	a0,a0,1524 # 80009a80 <syscalls+0x350>
    80006494:	ffffa097          	auipc	ra,0xffffa
    80006498:	096080e7          	jalr	150(ra) # 8000052a <panic>
    return 0;
    8000649c:	84aa                	mv	s1,a0
    8000649e:	b739                	j	800063ac <create+0x72>

00000000800064a0 <sys_open>:

uint64
sys_open(void)
{
    800064a0:	7131                	addi	sp,sp,-192
    800064a2:	fd06                	sd	ra,184(sp)
    800064a4:	f922                	sd	s0,176(sp)
    800064a6:	f526                	sd	s1,168(sp)
    800064a8:	f14a                	sd	s2,160(sp)
    800064aa:	ed4e                	sd	s3,152(sp)
    800064ac:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800064ae:	08000613          	li	a2,128
    800064b2:	f5040593          	addi	a1,s0,-176
    800064b6:	4501                	li	a0,0
    800064b8:	ffffd097          	auipc	ra,0xffffd
    800064bc:	e3a080e7          	jalr	-454(ra) # 800032f2 <argstr>
    return -1;
    800064c0:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800064c2:	0c054163          	bltz	a0,80006584 <sys_open+0xe4>
    800064c6:	f4c40593          	addi	a1,s0,-180
    800064ca:	4505                	li	a0,1
    800064cc:	ffffd097          	auipc	ra,0xffffd
    800064d0:	de2080e7          	jalr	-542(ra) # 800032ae <argint>
    800064d4:	0a054863          	bltz	a0,80006584 <sys_open+0xe4>

  begin_op();
    800064d8:	ffffe097          	auipc	ra,0xffffe
    800064dc:	688080e7          	jalr	1672(ra) # 80004b60 <begin_op>

  if(omode & O_CREATE){
    800064e0:	f4c42783          	lw	a5,-180(s0)
    800064e4:	2007f793          	andi	a5,a5,512
    800064e8:	cbdd                	beqz	a5,8000659e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800064ea:	4681                	li	a3,0
    800064ec:	4601                	li	a2,0
    800064ee:	4589                	li	a1,2
    800064f0:	f5040513          	addi	a0,s0,-176
    800064f4:	00000097          	auipc	ra,0x0
    800064f8:	e46080e7          	jalr	-442(ra) # 8000633a <create>
    800064fc:	892a                	mv	s2,a0
    if(ip == 0){
    800064fe:	c959                	beqz	a0,80006594 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80006500:	04491703          	lh	a4,68(s2)
    80006504:	478d                	li	a5,3
    80006506:	00f71763          	bne	a4,a5,80006514 <sys_open+0x74>
    8000650a:	04695703          	lhu	a4,70(s2)
    8000650e:	47a5                	li	a5,9
    80006510:	0ce7ec63          	bltu	a5,a4,800065e8 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80006514:	fffff097          	auipc	ra,0xfffff
    80006518:	a5c080e7          	jalr	-1444(ra) # 80004f70 <filealloc>
    8000651c:	89aa                	mv	s3,a0
    8000651e:	10050263          	beqz	a0,80006622 <sys_open+0x182>
    80006522:	00000097          	auipc	ra,0x0
    80006526:	8e2080e7          	jalr	-1822(ra) # 80005e04 <fdalloc>
    8000652a:	84aa                	mv	s1,a0
    8000652c:	0e054663          	bltz	a0,80006618 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80006530:	04491703          	lh	a4,68(s2)
    80006534:	478d                	li	a5,3
    80006536:	0cf70463          	beq	a4,a5,800065fe <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000653a:	4789                	li	a5,2
    8000653c:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80006540:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80006544:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80006548:	f4c42783          	lw	a5,-180(s0)
    8000654c:	0017c713          	xori	a4,a5,1
    80006550:	8b05                	andi	a4,a4,1
    80006552:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006556:	0037f713          	andi	a4,a5,3
    8000655a:	00e03733          	snez	a4,a4
    8000655e:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006562:	4007f793          	andi	a5,a5,1024
    80006566:	c791                	beqz	a5,80006572 <sys_open+0xd2>
    80006568:	04491703          	lh	a4,68(s2)
    8000656c:	4789                	li	a5,2
    8000656e:	08f70f63          	beq	a4,a5,8000660c <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80006572:	854a                	mv	a0,s2
    80006574:	ffffe097          	auipc	ra,0xffffe
    80006578:	9a0080e7          	jalr	-1632(ra) # 80003f14 <iunlock>
  end_op();
    8000657c:	ffffe097          	auipc	ra,0xffffe
    80006580:	664080e7          	jalr	1636(ra) # 80004be0 <end_op>

  return fd;
}
    80006584:	8526                	mv	a0,s1
    80006586:	70ea                	ld	ra,184(sp)
    80006588:	744a                	ld	s0,176(sp)
    8000658a:	74aa                	ld	s1,168(sp)
    8000658c:	790a                	ld	s2,160(sp)
    8000658e:	69ea                	ld	s3,152(sp)
    80006590:	6129                	addi	sp,sp,192
    80006592:	8082                	ret
      end_op();
    80006594:	ffffe097          	auipc	ra,0xffffe
    80006598:	64c080e7          	jalr	1612(ra) # 80004be0 <end_op>
      return -1;
    8000659c:	b7e5                	j	80006584 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000659e:	f5040513          	addi	a0,s0,-176
    800065a2:	ffffe097          	auipc	ra,0xffffe
    800065a6:	066080e7          	jalr	102(ra) # 80004608 <namei>
    800065aa:	892a                	mv	s2,a0
    800065ac:	c905                	beqz	a0,800065dc <sys_open+0x13c>
    ilock(ip);
    800065ae:	ffffe097          	auipc	ra,0xffffe
    800065b2:	8a4080e7          	jalr	-1884(ra) # 80003e52 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800065b6:	04491703          	lh	a4,68(s2)
    800065ba:	4785                	li	a5,1
    800065bc:	f4f712e3          	bne	a4,a5,80006500 <sys_open+0x60>
    800065c0:	f4c42783          	lw	a5,-180(s0)
    800065c4:	dba1                	beqz	a5,80006514 <sys_open+0x74>
      iunlockput(ip);
    800065c6:	854a                	mv	a0,s2
    800065c8:	ffffe097          	auipc	ra,0xffffe
    800065cc:	aec080e7          	jalr	-1300(ra) # 800040b4 <iunlockput>
      end_op();
    800065d0:	ffffe097          	auipc	ra,0xffffe
    800065d4:	610080e7          	jalr	1552(ra) # 80004be0 <end_op>
      return -1;
    800065d8:	54fd                	li	s1,-1
    800065da:	b76d                	j	80006584 <sys_open+0xe4>
      end_op();
    800065dc:	ffffe097          	auipc	ra,0xffffe
    800065e0:	604080e7          	jalr	1540(ra) # 80004be0 <end_op>
      return -1;
    800065e4:	54fd                	li	s1,-1
    800065e6:	bf79                	j	80006584 <sys_open+0xe4>
    iunlockput(ip);
    800065e8:	854a                	mv	a0,s2
    800065ea:	ffffe097          	auipc	ra,0xffffe
    800065ee:	aca080e7          	jalr	-1334(ra) # 800040b4 <iunlockput>
    end_op();
    800065f2:	ffffe097          	auipc	ra,0xffffe
    800065f6:	5ee080e7          	jalr	1518(ra) # 80004be0 <end_op>
    return -1;
    800065fa:	54fd                	li	s1,-1
    800065fc:	b761                	j	80006584 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800065fe:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80006602:	04691783          	lh	a5,70(s2)
    80006606:	02f99223          	sh	a5,36(s3)
    8000660a:	bf2d                	j	80006544 <sys_open+0xa4>
    itrunc(ip);
    8000660c:	854a                	mv	a0,s2
    8000660e:	ffffe097          	auipc	ra,0xffffe
    80006612:	952080e7          	jalr	-1710(ra) # 80003f60 <itrunc>
    80006616:	bfb1                	j	80006572 <sys_open+0xd2>
      fileclose(f);
    80006618:	854e                	mv	a0,s3
    8000661a:	fffff097          	auipc	ra,0xfffff
    8000661e:	a12080e7          	jalr	-1518(ra) # 8000502c <fileclose>
    iunlockput(ip);
    80006622:	854a                	mv	a0,s2
    80006624:	ffffe097          	auipc	ra,0xffffe
    80006628:	a90080e7          	jalr	-1392(ra) # 800040b4 <iunlockput>
    end_op();
    8000662c:	ffffe097          	auipc	ra,0xffffe
    80006630:	5b4080e7          	jalr	1460(ra) # 80004be0 <end_op>
    return -1;
    80006634:	54fd                	li	s1,-1
    80006636:	b7b9                	j	80006584 <sys_open+0xe4>

0000000080006638 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006638:	7175                	addi	sp,sp,-144
    8000663a:	e506                	sd	ra,136(sp)
    8000663c:	e122                	sd	s0,128(sp)
    8000663e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006640:	ffffe097          	auipc	ra,0xffffe
    80006644:	520080e7          	jalr	1312(ra) # 80004b60 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006648:	08000613          	li	a2,128
    8000664c:	f7040593          	addi	a1,s0,-144
    80006650:	4501                	li	a0,0
    80006652:	ffffd097          	auipc	ra,0xffffd
    80006656:	ca0080e7          	jalr	-864(ra) # 800032f2 <argstr>
    8000665a:	02054963          	bltz	a0,8000668c <sys_mkdir+0x54>
    8000665e:	4681                	li	a3,0
    80006660:	4601                	li	a2,0
    80006662:	4585                	li	a1,1
    80006664:	f7040513          	addi	a0,s0,-144
    80006668:	00000097          	auipc	ra,0x0
    8000666c:	cd2080e7          	jalr	-814(ra) # 8000633a <create>
    80006670:	cd11                	beqz	a0,8000668c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006672:	ffffe097          	auipc	ra,0xffffe
    80006676:	a42080e7          	jalr	-1470(ra) # 800040b4 <iunlockput>
  end_op();
    8000667a:	ffffe097          	auipc	ra,0xffffe
    8000667e:	566080e7          	jalr	1382(ra) # 80004be0 <end_op>
  return 0;
    80006682:	4501                	li	a0,0
}
    80006684:	60aa                	ld	ra,136(sp)
    80006686:	640a                	ld	s0,128(sp)
    80006688:	6149                	addi	sp,sp,144
    8000668a:	8082                	ret
    end_op();
    8000668c:	ffffe097          	auipc	ra,0xffffe
    80006690:	554080e7          	jalr	1364(ra) # 80004be0 <end_op>
    return -1;
    80006694:	557d                	li	a0,-1
    80006696:	b7fd                	j	80006684 <sys_mkdir+0x4c>

0000000080006698 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006698:	7135                	addi	sp,sp,-160
    8000669a:	ed06                	sd	ra,152(sp)
    8000669c:	e922                	sd	s0,144(sp)
    8000669e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800066a0:	ffffe097          	auipc	ra,0xffffe
    800066a4:	4c0080e7          	jalr	1216(ra) # 80004b60 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800066a8:	08000613          	li	a2,128
    800066ac:	f7040593          	addi	a1,s0,-144
    800066b0:	4501                	li	a0,0
    800066b2:	ffffd097          	auipc	ra,0xffffd
    800066b6:	c40080e7          	jalr	-960(ra) # 800032f2 <argstr>
    800066ba:	04054a63          	bltz	a0,8000670e <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800066be:	f6c40593          	addi	a1,s0,-148
    800066c2:	4505                	li	a0,1
    800066c4:	ffffd097          	auipc	ra,0xffffd
    800066c8:	bea080e7          	jalr	-1046(ra) # 800032ae <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800066cc:	04054163          	bltz	a0,8000670e <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800066d0:	f6840593          	addi	a1,s0,-152
    800066d4:	4509                	li	a0,2
    800066d6:	ffffd097          	auipc	ra,0xffffd
    800066da:	bd8080e7          	jalr	-1064(ra) # 800032ae <argint>
     argint(1, &major) < 0 ||
    800066de:	02054863          	bltz	a0,8000670e <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800066e2:	f6841683          	lh	a3,-152(s0)
    800066e6:	f6c41603          	lh	a2,-148(s0)
    800066ea:	458d                	li	a1,3
    800066ec:	f7040513          	addi	a0,s0,-144
    800066f0:	00000097          	auipc	ra,0x0
    800066f4:	c4a080e7          	jalr	-950(ra) # 8000633a <create>
     argint(2, &minor) < 0 ||
    800066f8:	c919                	beqz	a0,8000670e <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800066fa:	ffffe097          	auipc	ra,0xffffe
    800066fe:	9ba080e7          	jalr	-1606(ra) # 800040b4 <iunlockput>
  end_op();
    80006702:	ffffe097          	auipc	ra,0xffffe
    80006706:	4de080e7          	jalr	1246(ra) # 80004be0 <end_op>
  return 0;
    8000670a:	4501                	li	a0,0
    8000670c:	a031                	j	80006718 <sys_mknod+0x80>
    end_op();
    8000670e:	ffffe097          	auipc	ra,0xffffe
    80006712:	4d2080e7          	jalr	1234(ra) # 80004be0 <end_op>
    return -1;
    80006716:	557d                	li	a0,-1
}
    80006718:	60ea                	ld	ra,152(sp)
    8000671a:	644a                	ld	s0,144(sp)
    8000671c:	610d                	addi	sp,sp,160
    8000671e:	8082                	ret

0000000080006720 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006720:	7135                	addi	sp,sp,-160
    80006722:	ed06                	sd	ra,152(sp)
    80006724:	e922                	sd	s0,144(sp)
    80006726:	e526                	sd	s1,136(sp)
    80006728:	e14a                	sd	s2,128(sp)
    8000672a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000672c:	ffffb097          	auipc	ra,0xffffb
    80006730:	686080e7          	jalr	1670(ra) # 80001db2 <myproc>
    80006734:	892a                	mv	s2,a0
  
  begin_op();
    80006736:	ffffe097          	auipc	ra,0xffffe
    8000673a:	42a080e7          	jalr	1066(ra) # 80004b60 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000673e:	08000613          	li	a2,128
    80006742:	f6040593          	addi	a1,s0,-160
    80006746:	4501                	li	a0,0
    80006748:	ffffd097          	auipc	ra,0xffffd
    8000674c:	baa080e7          	jalr	-1110(ra) # 800032f2 <argstr>
    80006750:	04054b63          	bltz	a0,800067a6 <sys_chdir+0x86>
    80006754:	f6040513          	addi	a0,s0,-160
    80006758:	ffffe097          	auipc	ra,0xffffe
    8000675c:	eb0080e7          	jalr	-336(ra) # 80004608 <namei>
    80006760:	84aa                	mv	s1,a0
    80006762:	c131                	beqz	a0,800067a6 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006764:	ffffd097          	auipc	ra,0xffffd
    80006768:	6ee080e7          	jalr	1774(ra) # 80003e52 <ilock>
  if(ip->type != T_DIR){
    8000676c:	04449703          	lh	a4,68(s1)
    80006770:	4785                	li	a5,1
    80006772:	04f71063          	bne	a4,a5,800067b2 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006776:	8526                	mv	a0,s1
    80006778:	ffffd097          	auipc	ra,0xffffd
    8000677c:	79c080e7          	jalr	1948(ra) # 80003f14 <iunlock>
  iput(p->cwd);
    80006780:	15093503          	ld	a0,336(s2)
    80006784:	ffffe097          	auipc	ra,0xffffe
    80006788:	888080e7          	jalr	-1912(ra) # 8000400c <iput>
  end_op();
    8000678c:	ffffe097          	auipc	ra,0xffffe
    80006790:	454080e7          	jalr	1108(ra) # 80004be0 <end_op>
  p->cwd = ip;
    80006794:	14993823          	sd	s1,336(s2)
  return 0;
    80006798:	4501                	li	a0,0
}
    8000679a:	60ea                	ld	ra,152(sp)
    8000679c:	644a                	ld	s0,144(sp)
    8000679e:	64aa                	ld	s1,136(sp)
    800067a0:	690a                	ld	s2,128(sp)
    800067a2:	610d                	addi	sp,sp,160
    800067a4:	8082                	ret
    end_op();
    800067a6:	ffffe097          	auipc	ra,0xffffe
    800067aa:	43a080e7          	jalr	1082(ra) # 80004be0 <end_op>
    return -1;
    800067ae:	557d                	li	a0,-1
    800067b0:	b7ed                	j	8000679a <sys_chdir+0x7a>
    iunlockput(ip);
    800067b2:	8526                	mv	a0,s1
    800067b4:	ffffe097          	auipc	ra,0xffffe
    800067b8:	900080e7          	jalr	-1792(ra) # 800040b4 <iunlockput>
    end_op();
    800067bc:	ffffe097          	auipc	ra,0xffffe
    800067c0:	424080e7          	jalr	1060(ra) # 80004be0 <end_op>
    return -1;
    800067c4:	557d                	li	a0,-1
    800067c6:	bfd1                	j	8000679a <sys_chdir+0x7a>

00000000800067c8 <sys_exec>:

uint64
sys_exec(void)
{
    800067c8:	7145                	addi	sp,sp,-464
    800067ca:	e786                	sd	ra,456(sp)
    800067cc:	e3a2                	sd	s0,448(sp)
    800067ce:	ff26                	sd	s1,440(sp)
    800067d0:	fb4a                	sd	s2,432(sp)
    800067d2:	f74e                	sd	s3,424(sp)
    800067d4:	f352                	sd	s4,416(sp)
    800067d6:	ef56                	sd	s5,408(sp)
    800067d8:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800067da:	08000613          	li	a2,128
    800067de:	f4040593          	addi	a1,s0,-192
    800067e2:	4501                	li	a0,0
    800067e4:	ffffd097          	auipc	ra,0xffffd
    800067e8:	b0e080e7          	jalr	-1266(ra) # 800032f2 <argstr>
    return -1;
    800067ec:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800067ee:	0c054a63          	bltz	a0,800068c2 <sys_exec+0xfa>
    800067f2:	e3840593          	addi	a1,s0,-456
    800067f6:	4505                	li	a0,1
    800067f8:	ffffd097          	auipc	ra,0xffffd
    800067fc:	ad8080e7          	jalr	-1320(ra) # 800032d0 <argaddr>
    80006800:	0c054163          	bltz	a0,800068c2 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006804:	10000613          	li	a2,256
    80006808:	4581                	li	a1,0
    8000680a:	e4040513          	addi	a0,s0,-448
    8000680e:	ffffa097          	auipc	ra,0xffffa
    80006812:	4b0080e7          	jalr	1200(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006816:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    8000681a:	89a6                	mv	s3,s1
    8000681c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000681e:	02000a13          	li	s4,32
    80006822:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006826:	00391793          	slli	a5,s2,0x3
    8000682a:	e3040593          	addi	a1,s0,-464
    8000682e:	e3843503          	ld	a0,-456(s0)
    80006832:	953e                	add	a0,a0,a5
    80006834:	ffffd097          	auipc	ra,0xffffd
    80006838:	9e0080e7          	jalr	-1568(ra) # 80003214 <fetchaddr>
    8000683c:	02054a63          	bltz	a0,80006870 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006840:	e3043783          	ld	a5,-464(s0)
    80006844:	c3b9                	beqz	a5,8000688a <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006846:	ffffa097          	auipc	ra,0xffffa
    8000684a:	28c080e7          	jalr	652(ra) # 80000ad2 <kalloc>
    8000684e:	85aa                	mv	a1,a0
    80006850:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006854:	cd11                	beqz	a0,80006870 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006856:	6605                	lui	a2,0x1
    80006858:	e3043503          	ld	a0,-464(s0)
    8000685c:	ffffd097          	auipc	ra,0xffffd
    80006860:	a0a080e7          	jalr	-1526(ra) # 80003266 <fetchstr>
    80006864:	00054663          	bltz	a0,80006870 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006868:	0905                	addi	s2,s2,1
    8000686a:	09a1                	addi	s3,s3,8
    8000686c:	fb491be3          	bne	s2,s4,80006822 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006870:	10048913          	addi	s2,s1,256
    80006874:	6088                	ld	a0,0(s1)
    80006876:	c529                	beqz	a0,800068c0 <sys_exec+0xf8>
    kfree(argv[i]);
    80006878:	ffffa097          	auipc	ra,0xffffa
    8000687c:	15e080e7          	jalr	350(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006880:	04a1                	addi	s1,s1,8
    80006882:	ff2499e3          	bne	s1,s2,80006874 <sys_exec+0xac>
  return -1;
    80006886:	597d                	li	s2,-1
    80006888:	a82d                	j	800068c2 <sys_exec+0xfa>
      argv[i] = 0;
    8000688a:	0a8e                	slli	s5,s5,0x3
    8000688c:	fc040793          	addi	a5,s0,-64
    80006890:	9abe                	add	s5,s5,a5
    80006892:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffcae80>
  int ret = exec(path, argv);
    80006896:	e4040593          	addi	a1,s0,-448
    8000689a:	f4040513          	addi	a0,s0,-192
    8000689e:	fffff097          	auipc	ra,0xfffff
    800068a2:	fd6080e7          	jalr	-42(ra) # 80005874 <exec>
    800068a6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800068a8:	10048993          	addi	s3,s1,256
    800068ac:	6088                	ld	a0,0(s1)
    800068ae:	c911                	beqz	a0,800068c2 <sys_exec+0xfa>
    kfree(argv[i]);
    800068b0:	ffffa097          	auipc	ra,0xffffa
    800068b4:	126080e7          	jalr	294(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800068b8:	04a1                	addi	s1,s1,8
    800068ba:	ff3499e3          	bne	s1,s3,800068ac <sys_exec+0xe4>
    800068be:	a011                	j	800068c2 <sys_exec+0xfa>
  return -1;
    800068c0:	597d                	li	s2,-1
}
    800068c2:	854a                	mv	a0,s2
    800068c4:	60be                	ld	ra,456(sp)
    800068c6:	641e                	ld	s0,448(sp)
    800068c8:	74fa                	ld	s1,440(sp)
    800068ca:	795a                	ld	s2,432(sp)
    800068cc:	79ba                	ld	s3,424(sp)
    800068ce:	7a1a                	ld	s4,416(sp)
    800068d0:	6afa                	ld	s5,408(sp)
    800068d2:	6179                	addi	sp,sp,464
    800068d4:	8082                	ret

00000000800068d6 <sys_pipe>:

uint64
sys_pipe(void)
{
    800068d6:	7139                	addi	sp,sp,-64
    800068d8:	fc06                	sd	ra,56(sp)
    800068da:	f822                	sd	s0,48(sp)
    800068dc:	f426                	sd	s1,40(sp)
    800068de:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800068e0:	ffffb097          	auipc	ra,0xffffb
    800068e4:	4d2080e7          	jalr	1234(ra) # 80001db2 <myproc>
    800068e8:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800068ea:	fd840593          	addi	a1,s0,-40
    800068ee:	4501                	li	a0,0
    800068f0:	ffffd097          	auipc	ra,0xffffd
    800068f4:	9e0080e7          	jalr	-1568(ra) # 800032d0 <argaddr>
    return -1;
    800068f8:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800068fa:	0e054063          	bltz	a0,800069da <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    800068fe:	fc840593          	addi	a1,s0,-56
    80006902:	fd040513          	addi	a0,s0,-48
    80006906:	fffff097          	auipc	ra,0xfffff
    8000690a:	c4c080e7          	jalr	-948(ra) # 80005552 <pipealloc>
    return -1;
    8000690e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006910:	0c054563          	bltz	a0,800069da <sys_pipe+0x104>
  fd0 = -1;
    80006914:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006918:	fd043503          	ld	a0,-48(s0)
    8000691c:	fffff097          	auipc	ra,0xfffff
    80006920:	4e8080e7          	jalr	1256(ra) # 80005e04 <fdalloc>
    80006924:	fca42223          	sw	a0,-60(s0)
    80006928:	08054c63          	bltz	a0,800069c0 <sys_pipe+0xea>
    8000692c:	fc843503          	ld	a0,-56(s0)
    80006930:	fffff097          	auipc	ra,0xfffff
    80006934:	4d4080e7          	jalr	1236(ra) # 80005e04 <fdalloc>
    80006938:	fca42023          	sw	a0,-64(s0)
    8000693c:	06054863          	bltz	a0,800069ac <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006940:	4691                	li	a3,4
    80006942:	fc440613          	addi	a2,s0,-60
    80006946:	fd843583          	ld	a1,-40(s0)
    8000694a:	68a8                	ld	a0,80(s1)
    8000694c:	ffffb097          	auipc	ra,0xffffb
    80006950:	126080e7          	jalr	294(ra) # 80001a72 <copyout>
    80006954:	02054063          	bltz	a0,80006974 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006958:	4691                	li	a3,4
    8000695a:	fc040613          	addi	a2,s0,-64
    8000695e:	fd843583          	ld	a1,-40(s0)
    80006962:	0591                	addi	a1,a1,4
    80006964:	68a8                	ld	a0,80(s1)
    80006966:	ffffb097          	auipc	ra,0xffffb
    8000696a:	10c080e7          	jalr	268(ra) # 80001a72 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000696e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006970:	06055563          	bgez	a0,800069da <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006974:	fc442783          	lw	a5,-60(s0)
    80006978:	07e9                	addi	a5,a5,26
    8000697a:	078e                	slli	a5,a5,0x3
    8000697c:	97a6                	add	a5,a5,s1
    8000697e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006982:	fc042503          	lw	a0,-64(s0)
    80006986:	0569                	addi	a0,a0,26
    80006988:	050e                	slli	a0,a0,0x3
    8000698a:	9526                	add	a0,a0,s1
    8000698c:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006990:	fd043503          	ld	a0,-48(s0)
    80006994:	ffffe097          	auipc	ra,0xffffe
    80006998:	698080e7          	jalr	1688(ra) # 8000502c <fileclose>
    fileclose(wf);
    8000699c:	fc843503          	ld	a0,-56(s0)
    800069a0:	ffffe097          	auipc	ra,0xffffe
    800069a4:	68c080e7          	jalr	1676(ra) # 8000502c <fileclose>
    return -1;
    800069a8:	57fd                	li	a5,-1
    800069aa:	a805                	j	800069da <sys_pipe+0x104>
    if(fd0 >= 0)
    800069ac:	fc442783          	lw	a5,-60(s0)
    800069b0:	0007c863          	bltz	a5,800069c0 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    800069b4:	01a78513          	addi	a0,a5,26
    800069b8:	050e                	slli	a0,a0,0x3
    800069ba:	9526                	add	a0,a0,s1
    800069bc:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    800069c0:	fd043503          	ld	a0,-48(s0)
    800069c4:	ffffe097          	auipc	ra,0xffffe
    800069c8:	668080e7          	jalr	1640(ra) # 8000502c <fileclose>
    fileclose(wf);
    800069cc:	fc843503          	ld	a0,-56(s0)
    800069d0:	ffffe097          	auipc	ra,0xffffe
    800069d4:	65c080e7          	jalr	1628(ra) # 8000502c <fileclose>
    return -1;
    800069d8:	57fd                	li	a5,-1
}
    800069da:	853e                	mv	a0,a5
    800069dc:	70e2                	ld	ra,56(sp)
    800069de:	7442                	ld	s0,48(sp)
    800069e0:	74a2                	ld	s1,40(sp)
    800069e2:	6121                	addi	sp,sp,64
    800069e4:	8082                	ret
	...

00000000800069f0 <kernelvec>:
    800069f0:	7111                	addi	sp,sp,-256
    800069f2:	e006                	sd	ra,0(sp)
    800069f4:	e40a                	sd	sp,8(sp)
    800069f6:	e80e                	sd	gp,16(sp)
    800069f8:	ec12                	sd	tp,24(sp)
    800069fa:	f016                	sd	t0,32(sp)
    800069fc:	f41a                	sd	t1,40(sp)
    800069fe:	f81e                	sd	t2,48(sp)
    80006a00:	fc22                	sd	s0,56(sp)
    80006a02:	e0a6                	sd	s1,64(sp)
    80006a04:	e4aa                	sd	a0,72(sp)
    80006a06:	e8ae                	sd	a1,80(sp)
    80006a08:	ecb2                	sd	a2,88(sp)
    80006a0a:	f0b6                	sd	a3,96(sp)
    80006a0c:	f4ba                	sd	a4,104(sp)
    80006a0e:	f8be                	sd	a5,112(sp)
    80006a10:	fcc2                	sd	a6,120(sp)
    80006a12:	e146                	sd	a7,128(sp)
    80006a14:	e54a                	sd	s2,136(sp)
    80006a16:	e94e                	sd	s3,144(sp)
    80006a18:	ed52                	sd	s4,152(sp)
    80006a1a:	f156                	sd	s5,160(sp)
    80006a1c:	f55a                	sd	s6,168(sp)
    80006a1e:	f95e                	sd	s7,176(sp)
    80006a20:	fd62                	sd	s8,184(sp)
    80006a22:	e1e6                	sd	s9,192(sp)
    80006a24:	e5ea                	sd	s10,200(sp)
    80006a26:	e9ee                	sd	s11,208(sp)
    80006a28:	edf2                	sd	t3,216(sp)
    80006a2a:	f1f6                	sd	t4,224(sp)
    80006a2c:	f5fa                	sd	t5,232(sp)
    80006a2e:	f9fe                	sd	t6,240(sp)
    80006a30:	eb0fc0ef          	jal	ra,800030e0 <kerneltrap>
    80006a34:	6082                	ld	ra,0(sp)
    80006a36:	6122                	ld	sp,8(sp)
    80006a38:	61c2                	ld	gp,16(sp)
    80006a3a:	7282                	ld	t0,32(sp)
    80006a3c:	7322                	ld	t1,40(sp)
    80006a3e:	73c2                	ld	t2,48(sp)
    80006a40:	7462                	ld	s0,56(sp)
    80006a42:	6486                	ld	s1,64(sp)
    80006a44:	6526                	ld	a0,72(sp)
    80006a46:	65c6                	ld	a1,80(sp)
    80006a48:	6666                	ld	a2,88(sp)
    80006a4a:	7686                	ld	a3,96(sp)
    80006a4c:	7726                	ld	a4,104(sp)
    80006a4e:	77c6                	ld	a5,112(sp)
    80006a50:	7866                	ld	a6,120(sp)
    80006a52:	688a                	ld	a7,128(sp)
    80006a54:	692a                	ld	s2,136(sp)
    80006a56:	69ca                	ld	s3,144(sp)
    80006a58:	6a6a                	ld	s4,152(sp)
    80006a5a:	7a8a                	ld	s5,160(sp)
    80006a5c:	7b2a                	ld	s6,168(sp)
    80006a5e:	7bca                	ld	s7,176(sp)
    80006a60:	7c6a                	ld	s8,184(sp)
    80006a62:	6c8e                	ld	s9,192(sp)
    80006a64:	6d2e                	ld	s10,200(sp)
    80006a66:	6dce                	ld	s11,208(sp)
    80006a68:	6e6e                	ld	t3,216(sp)
    80006a6a:	7e8e                	ld	t4,224(sp)
    80006a6c:	7f2e                	ld	t5,232(sp)
    80006a6e:	7fce                	ld	t6,240(sp)
    80006a70:	6111                	addi	sp,sp,256
    80006a72:	10200073          	sret
    80006a76:	00000013          	nop
    80006a7a:	00000013          	nop
    80006a7e:	0001                	nop

0000000080006a80 <timervec>:
    80006a80:	34051573          	csrrw	a0,mscratch,a0
    80006a84:	e10c                	sd	a1,0(a0)
    80006a86:	e510                	sd	a2,8(a0)
    80006a88:	e914                	sd	a3,16(a0)
    80006a8a:	6d0c                	ld	a1,24(a0)
    80006a8c:	7110                	ld	a2,32(a0)
    80006a8e:	6194                	ld	a3,0(a1)
    80006a90:	96b2                	add	a3,a3,a2
    80006a92:	e194                	sd	a3,0(a1)
    80006a94:	4589                	li	a1,2
    80006a96:	14459073          	csrw	sip,a1
    80006a9a:	6914                	ld	a3,16(a0)
    80006a9c:	6510                	ld	a2,8(a0)
    80006a9e:	610c                	ld	a1,0(a0)
    80006aa0:	34051573          	csrrw	a0,mscratch,a0
    80006aa4:	30200073          	mret
	...

0000000080006aaa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80006aaa:	1141                	addi	sp,sp,-16
    80006aac:	e422                	sd	s0,8(sp)
    80006aae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006ab0:	0c0007b7          	lui	a5,0xc000
    80006ab4:	4705                	li	a4,1
    80006ab6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006ab8:	c3d8                	sw	a4,4(a5)
}
    80006aba:	6422                	ld	s0,8(sp)
    80006abc:	0141                	addi	sp,sp,16
    80006abe:	8082                	ret

0000000080006ac0 <plicinithart>:

void
plicinithart(void)
{
    80006ac0:	1141                	addi	sp,sp,-16
    80006ac2:	e406                	sd	ra,8(sp)
    80006ac4:	e022                	sd	s0,0(sp)
    80006ac6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006ac8:	ffffb097          	auipc	ra,0xffffb
    80006acc:	2be080e7          	jalr	702(ra) # 80001d86 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006ad0:	0085171b          	slliw	a4,a0,0x8
    80006ad4:	0c0027b7          	lui	a5,0xc002
    80006ad8:	97ba                	add	a5,a5,a4
    80006ada:	40200713          	li	a4,1026
    80006ade:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006ae2:	00d5151b          	slliw	a0,a0,0xd
    80006ae6:	0c2017b7          	lui	a5,0xc201
    80006aea:	953e                	add	a0,a0,a5
    80006aec:	00052023          	sw	zero,0(a0)
}
    80006af0:	60a2                	ld	ra,8(sp)
    80006af2:	6402                	ld	s0,0(sp)
    80006af4:	0141                	addi	sp,sp,16
    80006af6:	8082                	ret

0000000080006af8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006af8:	1141                	addi	sp,sp,-16
    80006afa:	e406                	sd	ra,8(sp)
    80006afc:	e022                	sd	s0,0(sp)
    80006afe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006b00:	ffffb097          	auipc	ra,0xffffb
    80006b04:	286080e7          	jalr	646(ra) # 80001d86 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006b08:	00d5179b          	slliw	a5,a0,0xd
    80006b0c:	0c201537          	lui	a0,0xc201
    80006b10:	953e                	add	a0,a0,a5
  return irq;
}
    80006b12:	4148                	lw	a0,4(a0)
    80006b14:	60a2                	ld	ra,8(sp)
    80006b16:	6402                	ld	s0,0(sp)
    80006b18:	0141                	addi	sp,sp,16
    80006b1a:	8082                	ret

0000000080006b1c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006b1c:	1101                	addi	sp,sp,-32
    80006b1e:	ec06                	sd	ra,24(sp)
    80006b20:	e822                	sd	s0,16(sp)
    80006b22:	e426                	sd	s1,8(sp)
    80006b24:	1000                	addi	s0,sp,32
    80006b26:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006b28:	ffffb097          	auipc	ra,0xffffb
    80006b2c:	25e080e7          	jalr	606(ra) # 80001d86 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006b30:	00d5151b          	slliw	a0,a0,0xd
    80006b34:	0c2017b7          	lui	a5,0xc201
    80006b38:	97aa                	add	a5,a5,a0
    80006b3a:	c3c4                	sw	s1,4(a5)
}
    80006b3c:	60e2                	ld	ra,24(sp)
    80006b3e:	6442                	ld	s0,16(sp)
    80006b40:	64a2                	ld	s1,8(sp)
    80006b42:	6105                	addi	sp,sp,32
    80006b44:	8082                	ret

0000000080006b46 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006b46:	1141                	addi	sp,sp,-16
    80006b48:	e406                	sd	ra,8(sp)
    80006b4a:	e022                	sd	s0,0(sp)
    80006b4c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006b4e:	479d                	li	a5,7
    80006b50:	06a7c963          	blt	a5,a0,80006bc2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006b54:	0002a797          	auipc	a5,0x2a
    80006b58:	4ac78793          	addi	a5,a5,1196 # 80031000 <disk>
    80006b5c:	00a78733          	add	a4,a5,a0
    80006b60:	6789                	lui	a5,0x2
    80006b62:	97ba                	add	a5,a5,a4
    80006b64:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006b68:	e7ad                	bnez	a5,80006bd2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006b6a:	00451793          	slli	a5,a0,0x4
    80006b6e:	0002c717          	auipc	a4,0x2c
    80006b72:	49270713          	addi	a4,a4,1170 # 80033000 <disk+0x2000>
    80006b76:	6314                	ld	a3,0(a4)
    80006b78:	96be                	add	a3,a3,a5
    80006b7a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006b7e:	6314                	ld	a3,0(a4)
    80006b80:	96be                	add	a3,a3,a5
    80006b82:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006b86:	6314                	ld	a3,0(a4)
    80006b88:	96be                	add	a3,a3,a5
    80006b8a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006b8e:	6318                	ld	a4,0(a4)
    80006b90:	97ba                	add	a5,a5,a4
    80006b92:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006b96:	0002a797          	auipc	a5,0x2a
    80006b9a:	46a78793          	addi	a5,a5,1130 # 80031000 <disk>
    80006b9e:	97aa                	add	a5,a5,a0
    80006ba0:	6509                	lui	a0,0x2
    80006ba2:	953e                	add	a0,a0,a5
    80006ba4:	4785                	li	a5,1
    80006ba6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006baa:	0002c517          	auipc	a0,0x2c
    80006bae:	46e50513          	addi	a0,a0,1134 # 80033018 <disk+0x2018>
    80006bb2:	ffffc097          	auipc	ra,0xffffc
    80006bb6:	c4c080e7          	jalr	-948(ra) # 800027fe <wakeup>
}
    80006bba:	60a2                	ld	ra,8(sp)
    80006bbc:	6402                	ld	s0,0(sp)
    80006bbe:	0141                	addi	sp,sp,16
    80006bc0:	8082                	ret
    panic("free_desc 1");
    80006bc2:	00003517          	auipc	a0,0x3
    80006bc6:	ece50513          	addi	a0,a0,-306 # 80009a90 <syscalls+0x360>
    80006bca:	ffffa097          	auipc	ra,0xffffa
    80006bce:	960080e7          	jalr	-1696(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006bd2:	00003517          	auipc	a0,0x3
    80006bd6:	ece50513          	addi	a0,a0,-306 # 80009aa0 <syscalls+0x370>
    80006bda:	ffffa097          	auipc	ra,0xffffa
    80006bde:	950080e7          	jalr	-1712(ra) # 8000052a <panic>

0000000080006be2 <virtio_disk_init>:
{
    80006be2:	1101                	addi	sp,sp,-32
    80006be4:	ec06                	sd	ra,24(sp)
    80006be6:	e822                	sd	s0,16(sp)
    80006be8:	e426                	sd	s1,8(sp)
    80006bea:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006bec:	00003597          	auipc	a1,0x3
    80006bf0:	ec458593          	addi	a1,a1,-316 # 80009ab0 <syscalls+0x380>
    80006bf4:	0002c517          	auipc	a0,0x2c
    80006bf8:	53450513          	addi	a0,a0,1332 # 80033128 <disk+0x2128>
    80006bfc:	ffffa097          	auipc	ra,0xffffa
    80006c00:	f36080e7          	jalr	-202(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006c04:	100017b7          	lui	a5,0x10001
    80006c08:	4398                	lw	a4,0(a5)
    80006c0a:	2701                	sext.w	a4,a4
    80006c0c:	747277b7          	lui	a5,0x74727
    80006c10:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006c14:	0ef71163          	bne	a4,a5,80006cf6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006c18:	100017b7          	lui	a5,0x10001
    80006c1c:	43dc                	lw	a5,4(a5)
    80006c1e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006c20:	4705                	li	a4,1
    80006c22:	0ce79a63          	bne	a5,a4,80006cf6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006c26:	100017b7          	lui	a5,0x10001
    80006c2a:	479c                	lw	a5,8(a5)
    80006c2c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006c2e:	4709                	li	a4,2
    80006c30:	0ce79363          	bne	a5,a4,80006cf6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006c34:	100017b7          	lui	a5,0x10001
    80006c38:	47d8                	lw	a4,12(a5)
    80006c3a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006c3c:	554d47b7          	lui	a5,0x554d4
    80006c40:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006c44:	0af71963          	bne	a4,a5,80006cf6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006c48:	100017b7          	lui	a5,0x10001
    80006c4c:	4705                	li	a4,1
    80006c4e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006c50:	470d                	li	a4,3
    80006c52:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006c54:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006c56:	c7ffe737          	lui	a4,0xc7ffe
    80006c5a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fca75f>
    80006c5e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006c60:	2701                	sext.w	a4,a4
    80006c62:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006c64:	472d                	li	a4,11
    80006c66:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006c68:	473d                	li	a4,15
    80006c6a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006c6c:	6705                	lui	a4,0x1
    80006c6e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006c70:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006c74:	5bdc                	lw	a5,52(a5)
    80006c76:	2781                	sext.w	a5,a5
  if(max == 0)
    80006c78:	c7d9                	beqz	a5,80006d06 <virtio_disk_init+0x124>
  if(max < NUM)
    80006c7a:	471d                	li	a4,7
    80006c7c:	08f77d63          	bgeu	a4,a5,80006d16 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006c80:	100014b7          	lui	s1,0x10001
    80006c84:	47a1                	li	a5,8
    80006c86:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006c88:	6609                	lui	a2,0x2
    80006c8a:	4581                	li	a1,0
    80006c8c:	0002a517          	auipc	a0,0x2a
    80006c90:	37450513          	addi	a0,a0,884 # 80031000 <disk>
    80006c94:	ffffa097          	auipc	ra,0xffffa
    80006c98:	02a080e7          	jalr	42(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006c9c:	0002a717          	auipc	a4,0x2a
    80006ca0:	36470713          	addi	a4,a4,868 # 80031000 <disk>
    80006ca4:	00c75793          	srli	a5,a4,0xc
    80006ca8:	2781                	sext.w	a5,a5
    80006caa:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006cac:	0002c797          	auipc	a5,0x2c
    80006cb0:	35478793          	addi	a5,a5,852 # 80033000 <disk+0x2000>
    80006cb4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006cb6:	0002a717          	auipc	a4,0x2a
    80006cba:	3ca70713          	addi	a4,a4,970 # 80031080 <disk+0x80>
    80006cbe:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006cc0:	0002b717          	auipc	a4,0x2b
    80006cc4:	34070713          	addi	a4,a4,832 # 80032000 <disk+0x1000>
    80006cc8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006cca:	4705                	li	a4,1
    80006ccc:	00e78c23          	sb	a4,24(a5)
    80006cd0:	00e78ca3          	sb	a4,25(a5)
    80006cd4:	00e78d23          	sb	a4,26(a5)
    80006cd8:	00e78da3          	sb	a4,27(a5)
    80006cdc:	00e78e23          	sb	a4,28(a5)
    80006ce0:	00e78ea3          	sb	a4,29(a5)
    80006ce4:	00e78f23          	sb	a4,30(a5)
    80006ce8:	00e78fa3          	sb	a4,31(a5)
}
    80006cec:	60e2                	ld	ra,24(sp)
    80006cee:	6442                	ld	s0,16(sp)
    80006cf0:	64a2                	ld	s1,8(sp)
    80006cf2:	6105                	addi	sp,sp,32
    80006cf4:	8082                	ret
    panic("could not find virtio disk");
    80006cf6:	00003517          	auipc	a0,0x3
    80006cfa:	dca50513          	addi	a0,a0,-566 # 80009ac0 <syscalls+0x390>
    80006cfe:	ffffa097          	auipc	ra,0xffffa
    80006d02:	82c080e7          	jalr	-2004(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    80006d06:	00003517          	auipc	a0,0x3
    80006d0a:	dda50513          	addi	a0,a0,-550 # 80009ae0 <syscalls+0x3b0>
    80006d0e:	ffffa097          	auipc	ra,0xffffa
    80006d12:	81c080e7          	jalr	-2020(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    80006d16:	00003517          	auipc	a0,0x3
    80006d1a:	dea50513          	addi	a0,a0,-534 # 80009b00 <syscalls+0x3d0>
    80006d1e:	ffffa097          	auipc	ra,0xffffa
    80006d22:	80c080e7          	jalr	-2036(ra) # 8000052a <panic>

0000000080006d26 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006d26:	7119                	addi	sp,sp,-128
    80006d28:	fc86                	sd	ra,120(sp)
    80006d2a:	f8a2                	sd	s0,112(sp)
    80006d2c:	f4a6                	sd	s1,104(sp)
    80006d2e:	f0ca                	sd	s2,96(sp)
    80006d30:	ecce                	sd	s3,88(sp)
    80006d32:	e8d2                	sd	s4,80(sp)
    80006d34:	e4d6                	sd	s5,72(sp)
    80006d36:	e0da                	sd	s6,64(sp)
    80006d38:	fc5e                	sd	s7,56(sp)
    80006d3a:	f862                	sd	s8,48(sp)
    80006d3c:	f466                	sd	s9,40(sp)
    80006d3e:	f06a                	sd	s10,32(sp)
    80006d40:	ec6e                	sd	s11,24(sp)
    80006d42:	0100                	addi	s0,sp,128
    80006d44:	8aaa                	mv	s5,a0
    80006d46:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006d48:	00c52c83          	lw	s9,12(a0)
    80006d4c:	001c9c9b          	slliw	s9,s9,0x1
    80006d50:	1c82                	slli	s9,s9,0x20
    80006d52:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006d56:	0002c517          	auipc	a0,0x2c
    80006d5a:	3d250513          	addi	a0,a0,978 # 80033128 <disk+0x2128>
    80006d5e:	ffffa097          	auipc	ra,0xffffa
    80006d62:	e64080e7          	jalr	-412(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    80006d66:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006d68:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006d6a:	0002ac17          	auipc	s8,0x2a
    80006d6e:	296c0c13          	addi	s8,s8,662 # 80031000 <disk>
    80006d72:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006d74:	4b0d                	li	s6,3
    80006d76:	a0ad                	j	80006de0 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006d78:	00fc0733          	add	a4,s8,a5
    80006d7c:	975e                	add	a4,a4,s7
    80006d7e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006d82:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006d84:	0207c563          	bltz	a5,80006dae <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006d88:	2905                	addiw	s2,s2,1
    80006d8a:	0611                	addi	a2,a2,4
    80006d8c:	19690d63          	beq	s2,s6,80006f26 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006d90:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006d92:	0002c717          	auipc	a4,0x2c
    80006d96:	28670713          	addi	a4,a4,646 # 80033018 <disk+0x2018>
    80006d9a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006d9c:	00074683          	lbu	a3,0(a4)
    80006da0:	fee1                	bnez	a3,80006d78 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006da2:	2785                	addiw	a5,a5,1
    80006da4:	0705                	addi	a4,a4,1
    80006da6:	fe979be3          	bne	a5,s1,80006d9c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006daa:	57fd                	li	a5,-1
    80006dac:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006dae:	01205d63          	blez	s2,80006dc8 <virtio_disk_rw+0xa2>
    80006db2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006db4:	000a2503          	lw	a0,0(s4)
    80006db8:	00000097          	auipc	ra,0x0
    80006dbc:	d8e080e7          	jalr	-626(ra) # 80006b46 <free_desc>
      for(int j = 0; j < i; j++)
    80006dc0:	2d85                	addiw	s11,s11,1
    80006dc2:	0a11                	addi	s4,s4,4
    80006dc4:	ffb918e3          	bne	s2,s11,80006db4 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006dc8:	0002c597          	auipc	a1,0x2c
    80006dcc:	36058593          	addi	a1,a1,864 # 80033128 <disk+0x2128>
    80006dd0:	0002c517          	auipc	a0,0x2c
    80006dd4:	24850513          	addi	a0,a0,584 # 80033018 <disk+0x2018>
    80006dd8:	ffffc097          	auipc	ra,0xffffc
    80006ddc:	89a080e7          	jalr	-1894(ra) # 80002672 <sleep>
  for(int i = 0; i < 3; i++){
    80006de0:	f8040a13          	addi	s4,s0,-128
{
    80006de4:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006de6:	894e                	mv	s2,s3
    80006de8:	b765                	j	80006d90 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006dea:	0002c697          	auipc	a3,0x2c
    80006dee:	2166b683          	ld	a3,534(a3) # 80033000 <disk+0x2000>
    80006df2:	96ba                	add	a3,a3,a4
    80006df4:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006df8:	0002a817          	auipc	a6,0x2a
    80006dfc:	20880813          	addi	a6,a6,520 # 80031000 <disk>
    80006e00:	0002c697          	auipc	a3,0x2c
    80006e04:	20068693          	addi	a3,a3,512 # 80033000 <disk+0x2000>
    80006e08:	6290                	ld	a2,0(a3)
    80006e0a:	963a                	add	a2,a2,a4
    80006e0c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006e10:	0015e593          	ori	a1,a1,1
    80006e14:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006e18:	f8842603          	lw	a2,-120(s0)
    80006e1c:	628c                	ld	a1,0(a3)
    80006e1e:	972e                	add	a4,a4,a1
    80006e20:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006e24:	20050593          	addi	a1,a0,512
    80006e28:	0592                	slli	a1,a1,0x4
    80006e2a:	95c2                	add	a1,a1,a6
    80006e2c:	577d                	li	a4,-1
    80006e2e:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006e32:	00461713          	slli	a4,a2,0x4
    80006e36:	6290                	ld	a2,0(a3)
    80006e38:	963a                	add	a2,a2,a4
    80006e3a:	03078793          	addi	a5,a5,48
    80006e3e:	97c2                	add	a5,a5,a6
    80006e40:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006e42:	629c                	ld	a5,0(a3)
    80006e44:	97ba                	add	a5,a5,a4
    80006e46:	4605                	li	a2,1
    80006e48:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006e4a:	629c                	ld	a5,0(a3)
    80006e4c:	97ba                	add	a5,a5,a4
    80006e4e:	4809                	li	a6,2
    80006e50:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006e54:	629c                	ld	a5,0(a3)
    80006e56:	973e                	add	a4,a4,a5
    80006e58:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006e5c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006e60:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006e64:	6698                	ld	a4,8(a3)
    80006e66:	00275783          	lhu	a5,2(a4)
    80006e6a:	8b9d                	andi	a5,a5,7
    80006e6c:	0786                	slli	a5,a5,0x1
    80006e6e:	97ba                	add	a5,a5,a4
    80006e70:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006e74:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006e78:	6698                	ld	a4,8(a3)
    80006e7a:	00275783          	lhu	a5,2(a4)
    80006e7e:	2785                	addiw	a5,a5,1
    80006e80:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006e84:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006e88:	100017b7          	lui	a5,0x10001
    80006e8c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006e90:	004aa783          	lw	a5,4(s5)
    80006e94:	02c79163          	bne	a5,a2,80006eb6 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006e98:	0002c917          	auipc	s2,0x2c
    80006e9c:	29090913          	addi	s2,s2,656 # 80033128 <disk+0x2128>
  while(b->disk == 1) {
    80006ea0:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006ea2:	85ca                	mv	a1,s2
    80006ea4:	8556                	mv	a0,s5
    80006ea6:	ffffb097          	auipc	ra,0xffffb
    80006eaa:	7cc080e7          	jalr	1996(ra) # 80002672 <sleep>
  while(b->disk == 1) {
    80006eae:	004aa783          	lw	a5,4(s5)
    80006eb2:	fe9788e3          	beq	a5,s1,80006ea2 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006eb6:	f8042903          	lw	s2,-128(s0)
    80006eba:	20090793          	addi	a5,s2,512
    80006ebe:	00479713          	slli	a4,a5,0x4
    80006ec2:	0002a797          	auipc	a5,0x2a
    80006ec6:	13e78793          	addi	a5,a5,318 # 80031000 <disk>
    80006eca:	97ba                	add	a5,a5,a4
    80006ecc:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006ed0:	0002c997          	auipc	s3,0x2c
    80006ed4:	13098993          	addi	s3,s3,304 # 80033000 <disk+0x2000>
    80006ed8:	00491713          	slli	a4,s2,0x4
    80006edc:	0009b783          	ld	a5,0(s3)
    80006ee0:	97ba                	add	a5,a5,a4
    80006ee2:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006ee6:	854a                	mv	a0,s2
    80006ee8:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006eec:	00000097          	auipc	ra,0x0
    80006ef0:	c5a080e7          	jalr	-934(ra) # 80006b46 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006ef4:	8885                	andi	s1,s1,1
    80006ef6:	f0ed                	bnez	s1,80006ed8 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006ef8:	0002c517          	auipc	a0,0x2c
    80006efc:	23050513          	addi	a0,a0,560 # 80033128 <disk+0x2128>
    80006f00:	ffffa097          	auipc	ra,0xffffa
    80006f04:	d76080e7          	jalr	-650(ra) # 80000c76 <release>
}
    80006f08:	70e6                	ld	ra,120(sp)
    80006f0a:	7446                	ld	s0,112(sp)
    80006f0c:	74a6                	ld	s1,104(sp)
    80006f0e:	7906                	ld	s2,96(sp)
    80006f10:	69e6                	ld	s3,88(sp)
    80006f12:	6a46                	ld	s4,80(sp)
    80006f14:	6aa6                	ld	s5,72(sp)
    80006f16:	6b06                	ld	s6,64(sp)
    80006f18:	7be2                	ld	s7,56(sp)
    80006f1a:	7c42                	ld	s8,48(sp)
    80006f1c:	7ca2                	ld	s9,40(sp)
    80006f1e:	7d02                	ld	s10,32(sp)
    80006f20:	6de2                	ld	s11,24(sp)
    80006f22:	6109                	addi	sp,sp,128
    80006f24:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006f26:	f8042503          	lw	a0,-128(s0)
    80006f2a:	20050793          	addi	a5,a0,512
    80006f2e:	0792                	slli	a5,a5,0x4
  if(write)
    80006f30:	0002a817          	auipc	a6,0x2a
    80006f34:	0d080813          	addi	a6,a6,208 # 80031000 <disk>
    80006f38:	00f80733          	add	a4,a6,a5
    80006f3c:	01a036b3          	snez	a3,s10
    80006f40:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80006f44:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006f48:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006f4c:	7679                	lui	a2,0xffffe
    80006f4e:	963e                	add	a2,a2,a5
    80006f50:	0002c697          	auipc	a3,0x2c
    80006f54:	0b068693          	addi	a3,a3,176 # 80033000 <disk+0x2000>
    80006f58:	6298                	ld	a4,0(a3)
    80006f5a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006f5c:	0a878593          	addi	a1,a5,168
    80006f60:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006f62:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006f64:	6298                	ld	a4,0(a3)
    80006f66:	9732                	add	a4,a4,a2
    80006f68:	45c1                	li	a1,16
    80006f6a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006f6c:	6298                	ld	a4,0(a3)
    80006f6e:	9732                	add	a4,a4,a2
    80006f70:	4585                	li	a1,1
    80006f72:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006f76:	f8442703          	lw	a4,-124(s0)
    80006f7a:	628c                	ld	a1,0(a3)
    80006f7c:	962e                	add	a2,a2,a1
    80006f7e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffca00e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006f82:	0712                	slli	a4,a4,0x4
    80006f84:	6290                	ld	a2,0(a3)
    80006f86:	963a                	add	a2,a2,a4
    80006f88:	058a8593          	addi	a1,s5,88
    80006f8c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006f8e:	6294                	ld	a3,0(a3)
    80006f90:	96ba                	add	a3,a3,a4
    80006f92:	40000613          	li	a2,1024
    80006f96:	c690                	sw	a2,8(a3)
  if(write)
    80006f98:	e40d19e3          	bnez	s10,80006dea <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006f9c:	0002c697          	auipc	a3,0x2c
    80006fa0:	0646b683          	ld	a3,100(a3) # 80033000 <disk+0x2000>
    80006fa4:	96ba                	add	a3,a3,a4
    80006fa6:	4609                	li	a2,2
    80006fa8:	00c69623          	sh	a2,12(a3)
    80006fac:	b5b1                	j	80006df8 <virtio_disk_rw+0xd2>

0000000080006fae <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006fae:	1101                	addi	sp,sp,-32
    80006fb0:	ec06                	sd	ra,24(sp)
    80006fb2:	e822                	sd	s0,16(sp)
    80006fb4:	e426                	sd	s1,8(sp)
    80006fb6:	e04a                	sd	s2,0(sp)
    80006fb8:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006fba:	0002c517          	auipc	a0,0x2c
    80006fbe:	16e50513          	addi	a0,a0,366 # 80033128 <disk+0x2128>
    80006fc2:	ffffa097          	auipc	ra,0xffffa
    80006fc6:	c00080e7          	jalr	-1024(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006fca:	10001737          	lui	a4,0x10001
    80006fce:	533c                	lw	a5,96(a4)
    80006fd0:	8b8d                	andi	a5,a5,3
    80006fd2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006fd4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006fd8:	0002c797          	auipc	a5,0x2c
    80006fdc:	02878793          	addi	a5,a5,40 # 80033000 <disk+0x2000>
    80006fe0:	6b94                	ld	a3,16(a5)
    80006fe2:	0207d703          	lhu	a4,32(a5)
    80006fe6:	0026d783          	lhu	a5,2(a3)
    80006fea:	06f70163          	beq	a4,a5,8000704c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006fee:	0002a917          	auipc	s2,0x2a
    80006ff2:	01290913          	addi	s2,s2,18 # 80031000 <disk>
    80006ff6:	0002c497          	auipc	s1,0x2c
    80006ffa:	00a48493          	addi	s1,s1,10 # 80033000 <disk+0x2000>
    __sync_synchronize();
    80006ffe:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007002:	6898                	ld	a4,16(s1)
    80007004:	0204d783          	lhu	a5,32(s1)
    80007008:	8b9d                	andi	a5,a5,7
    8000700a:	078e                	slli	a5,a5,0x3
    8000700c:	97ba                	add	a5,a5,a4
    8000700e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80007010:	20078713          	addi	a4,a5,512
    80007014:	0712                	slli	a4,a4,0x4
    80007016:	974a                	add	a4,a4,s2
    80007018:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000701c:	e731                	bnez	a4,80007068 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000701e:	20078793          	addi	a5,a5,512
    80007022:	0792                	slli	a5,a5,0x4
    80007024:	97ca                	add	a5,a5,s2
    80007026:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80007028:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000702c:	ffffb097          	auipc	ra,0xffffb
    80007030:	7d2080e7          	jalr	2002(ra) # 800027fe <wakeup>

    disk.used_idx += 1;
    80007034:	0204d783          	lhu	a5,32(s1)
    80007038:	2785                	addiw	a5,a5,1
    8000703a:	17c2                	slli	a5,a5,0x30
    8000703c:	93c1                	srli	a5,a5,0x30
    8000703e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80007042:	6898                	ld	a4,16(s1)
    80007044:	00275703          	lhu	a4,2(a4)
    80007048:	faf71be3          	bne	a4,a5,80006ffe <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000704c:	0002c517          	auipc	a0,0x2c
    80007050:	0dc50513          	addi	a0,a0,220 # 80033128 <disk+0x2128>
    80007054:	ffffa097          	auipc	ra,0xffffa
    80007058:	c22080e7          	jalr	-990(ra) # 80000c76 <release>
}
    8000705c:	60e2                	ld	ra,24(sp)
    8000705e:	6442                	ld	s0,16(sp)
    80007060:	64a2                	ld	s1,8(sp)
    80007062:	6902                	ld	s2,0(sp)
    80007064:	6105                	addi	sp,sp,32
    80007066:	8082                	ret
      panic("virtio_disk_intr status");
    80007068:	00003517          	auipc	a0,0x3
    8000706c:	ab850513          	addi	a0,a0,-1352 # 80009b20 <syscalls+0x3f0>
    80007070:	ffff9097          	auipc	ra,0xffff9
    80007074:	4ba080e7          	jalr	1210(ra) # 8000052a <panic>
	...

0000000080008000 <_trampoline>:
    80008000:	14051573          	csrrw	a0,sscratch,a0
    80008004:	02153423          	sd	ra,40(a0)
    80008008:	02253823          	sd	sp,48(a0)
    8000800c:	02353c23          	sd	gp,56(a0)
    80008010:	04453023          	sd	tp,64(a0)
    80008014:	04553423          	sd	t0,72(a0)
    80008018:	04653823          	sd	t1,80(a0)
    8000801c:	04753c23          	sd	t2,88(a0)
    80008020:	f120                	sd	s0,96(a0)
    80008022:	f524                	sd	s1,104(a0)
    80008024:	fd2c                	sd	a1,120(a0)
    80008026:	e150                	sd	a2,128(a0)
    80008028:	e554                	sd	a3,136(a0)
    8000802a:	e958                	sd	a4,144(a0)
    8000802c:	ed5c                	sd	a5,152(a0)
    8000802e:	0b053023          	sd	a6,160(a0)
    80008032:	0b153423          	sd	a7,168(a0)
    80008036:	0b253823          	sd	s2,176(a0)
    8000803a:	0b353c23          	sd	s3,184(a0)
    8000803e:	0d453023          	sd	s4,192(a0)
    80008042:	0d553423          	sd	s5,200(a0)
    80008046:	0d653823          	sd	s6,208(a0)
    8000804a:	0d753c23          	sd	s7,216(a0)
    8000804e:	0f853023          	sd	s8,224(a0)
    80008052:	0f953423          	sd	s9,232(a0)
    80008056:	0fa53823          	sd	s10,240(a0)
    8000805a:	0fb53c23          	sd	s11,248(a0)
    8000805e:	11c53023          	sd	t3,256(a0)
    80008062:	11d53423          	sd	t4,264(a0)
    80008066:	11e53823          	sd	t5,272(a0)
    8000806a:	11f53c23          	sd	t6,280(a0)
    8000806e:	140022f3          	csrr	t0,sscratch
    80008072:	06553823          	sd	t0,112(a0)
    80008076:	00853103          	ld	sp,8(a0)
    8000807a:	02053203          	ld	tp,32(a0)
    8000807e:	01053283          	ld	t0,16(a0)
    80008082:	00053303          	ld	t1,0(a0)
    80008086:	18031073          	csrw	satp,t1
    8000808a:	12000073          	sfence.vma
    8000808e:	8282                	jr	t0

0000000080008090 <userret>:
    80008090:	18059073          	csrw	satp,a1
    80008094:	12000073          	sfence.vma
    80008098:	07053283          	ld	t0,112(a0)
    8000809c:	14029073          	csrw	sscratch,t0
    800080a0:	02853083          	ld	ra,40(a0)
    800080a4:	03053103          	ld	sp,48(a0)
    800080a8:	03853183          	ld	gp,56(a0)
    800080ac:	04053203          	ld	tp,64(a0)
    800080b0:	04853283          	ld	t0,72(a0)
    800080b4:	05053303          	ld	t1,80(a0)
    800080b8:	05853383          	ld	t2,88(a0)
    800080bc:	7120                	ld	s0,96(a0)
    800080be:	7524                	ld	s1,104(a0)
    800080c0:	7d2c                	ld	a1,120(a0)
    800080c2:	6150                	ld	a2,128(a0)
    800080c4:	6554                	ld	a3,136(a0)
    800080c6:	6958                	ld	a4,144(a0)
    800080c8:	6d5c                	ld	a5,152(a0)
    800080ca:	0a053803          	ld	a6,160(a0)
    800080ce:	0a853883          	ld	a7,168(a0)
    800080d2:	0b053903          	ld	s2,176(a0)
    800080d6:	0b853983          	ld	s3,184(a0)
    800080da:	0c053a03          	ld	s4,192(a0)
    800080de:	0c853a83          	ld	s5,200(a0)
    800080e2:	0d053b03          	ld	s6,208(a0)
    800080e6:	0d853b83          	ld	s7,216(a0)
    800080ea:	0e053c03          	ld	s8,224(a0)
    800080ee:	0e853c83          	ld	s9,232(a0)
    800080f2:	0f053d03          	ld	s10,240(a0)
    800080f6:	0f853d83          	ld	s11,248(a0)
    800080fa:	10053e03          	ld	t3,256(a0)
    800080fe:	10853e83          	ld	t4,264(a0)
    80008102:	11053f03          	ld	t5,272(a0)
    80008106:	11853f83          	ld	t6,280(a0)
    8000810a:	14051573          	csrrw	a0,sscratch,a0
    8000810e:	10200073          	sret
	...
