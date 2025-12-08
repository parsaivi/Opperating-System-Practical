
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	89010113          	addi	sp,sp,-1904 # 80007890 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdda27>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	dbc78793          	addi	a5,a5,-580 # 80000e3c <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a2:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	7119                	addi	sp,sp,-128
    800000d2:	fc86                	sd	ra,120(sp)
    800000d4:	f8a2                	sd	s0,112(sp)
    800000d6:	f4a6                	sd	s1,104(sp)
    800000d8:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000da:	06c05a63          	blez	a2,8000014e <consolewrite+0x7e>
    800000de:	f0ca                	sd	s2,96(sp)
    800000e0:	ecce                	sd	s3,88(sp)
    800000e2:	e8d2                	sd	s4,80(sp)
    800000e4:	e4d6                	sd	s5,72(sp)
    800000e6:	e0da                	sd	s6,64(sp)
    800000e8:	fc5e                	sd	s7,56(sp)
    800000ea:	f862                	sd	s8,48(sp)
    800000ec:	f466                	sd	s9,40(sp)
    800000ee:	8aaa                	mv	s5,a0
    800000f0:	8b2e                	mv	s6,a1
    800000f2:	8a32                	mv	s4,a2
  int i = 0;
    800000f4:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000f6:	02000c13          	li	s8,32
    800000fa:	02000c93          	li	s9,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    800000fe:	5bfd                	li	s7,-1
    80000100:	a035                	j	8000012c <consolewrite+0x5c>
    if(nn > n - i)
    80000102:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000106:	86ce                	mv	a3,s3
    80000108:	01648633          	add	a2,s1,s6
    8000010c:	85d6                	mv	a1,s5
    8000010e:	f8040513          	addi	a0,s0,-128
    80000112:	348020ef          	jal	8000245a <either_copyin>
    80000116:	03750e63          	beq	a0,s7,80000152 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    8000011a:	85ce                	mv	a1,s3
    8000011c:	f8040513          	addi	a0,s0,-128
    80000120:	778000ef          	jal	80000898 <uartwrite>
    i += nn;
    80000124:	009904bb          	addw	s1,s2,s1
  while(i < n){
    80000128:	0144da63          	bge	s1,s4,8000013c <consolewrite+0x6c>
    if(nn > n - i)
    8000012c:	409a093b          	subw	s2,s4,s1
    80000130:	0009079b          	sext.w	a5,s2
    80000134:	fcfc57e3          	bge	s8,a5,80000102 <consolewrite+0x32>
    80000138:	8966                	mv	s2,s9
    8000013a:	b7e1                	j	80000102 <consolewrite+0x32>
    8000013c:	7906                	ld	s2,96(sp)
    8000013e:	69e6                	ld	s3,88(sp)
    80000140:	6a46                	ld	s4,80(sp)
    80000142:	6aa6                	ld	s5,72(sp)
    80000144:	6b06                	ld	s6,64(sp)
    80000146:	7be2                	ld	s7,56(sp)
    80000148:	7c42                	ld	s8,48(sp)
    8000014a:	7ca2                	ld	s9,40(sp)
    8000014c:	a819                	j	80000162 <consolewrite+0x92>
  int i = 0;
    8000014e:	4481                	li	s1,0
    80000150:	a809                	j	80000162 <consolewrite+0x92>
    80000152:	7906                	ld	s2,96(sp)
    80000154:	69e6                	ld	s3,88(sp)
    80000156:	6a46                	ld	s4,80(sp)
    80000158:	6aa6                	ld	s5,72(sp)
    8000015a:	6b06                	ld	s6,64(sp)
    8000015c:	7be2                	ld	s7,56(sp)
    8000015e:	7c42                	ld	s8,48(sp)
    80000160:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80000162:	8526                	mv	a0,s1
    80000164:	70e6                	ld	ra,120(sp)
    80000166:	7446                	ld	s0,112(sp)
    80000168:	74a6                	ld	s1,104(sp)
    8000016a:	6109                	addi	sp,sp,128
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	addi	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	addi	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	0000f517          	auipc	a0,0xf
    80000190:	70450513          	addi	a0,a0,1796 # 8000f890 <cons>
    80000194:	23b000ef          	jal	80000bce <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	0000f497          	auipc	s1,0xf
    8000019c:	6f848493          	addi	s1,s1,1784 # 8000f890 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	0000f917          	auipc	s2,0xf
    800001a4:	78890913          	addi	s2,s2,1928 # 8000f928 <cons+0x98>
  while(n > 0){
    800001a8:	0b305d63          	blez	s3,80000262 <consoleread+0xf4>
    while(cons.r == cons.w){
    800001ac:	0984a783          	lw	a5,152(s1)
    800001b0:	09c4a703          	lw	a4,156(s1)
    800001b4:	0af71263          	bne	a4,a5,80000258 <consoleread+0xea>
      if(killed(myproc())){
    800001b8:	08f010ef          	jal	80001a46 <myproc>
    800001bc:	130020ef          	jal	800022ec <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	6ef010ef          	jal	800020b4 <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef703e3          	beq	a4,a5,800001b8 <consoleread+0x4a>
    800001d6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001d8:	0000f717          	auipc	a4,0xf
    800001dc:	6b870713          	addi	a4,a4,1720 # 8000f890 <cons>
    800001e0:	0017869b          	addiw	a3,a5,1
    800001e4:	08d72c23          	sw	a3,152(a4)
    800001e8:	07f7f693          	andi	a3,a5,127
    800001ec:	9736                	add	a4,a4,a3
    800001ee:	01874703          	lbu	a4,24(a4)
    800001f2:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001f6:	4691                	li	a3,4
    800001f8:	04db8663          	beq	s7,a3,80000244 <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001fc:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000200:	4685                	li	a3,1
    80000202:	faf40613          	addi	a2,s0,-81
    80000206:	85d2                	mv	a1,s4
    80000208:	8556                	mv	a0,s5
    8000020a:	206020ef          	jal	80002410 <either_copyout>
    8000020e:	57fd                	li	a5,-1
    80000210:	04f50863          	beq	a0,a5,80000260 <consoleread+0xf2>
      break;

    dst++;
    80000214:	0a05                	addi	s4,s4,1
    --n;
    80000216:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000218:	47a9                	li	a5,10
    8000021a:	04fb8d63          	beq	s7,a5,80000274 <consoleread+0x106>
    8000021e:	6be2                	ld	s7,24(sp)
    80000220:	b761                	j	800001a8 <consoleread+0x3a>
        release(&cons.lock);
    80000222:	0000f517          	auipc	a0,0xf
    80000226:	66e50513          	addi	a0,a0,1646 # 8000f890 <cons>
    8000022a:	23d000ef          	jal	80000c66 <release>
        return -1;
    8000022e:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000230:	60e6                	ld	ra,88(sp)
    80000232:	6446                	ld	s0,80(sp)
    80000234:	64a6                	ld	s1,72(sp)
    80000236:	6906                	ld	s2,64(sp)
    80000238:	79e2                	ld	s3,56(sp)
    8000023a:	7a42                	ld	s4,48(sp)
    8000023c:	7aa2                	ld	s5,40(sp)
    8000023e:	7b02                	ld	s6,32(sp)
    80000240:	6125                	addi	sp,sp,96
    80000242:	8082                	ret
      if(n < target){
    80000244:	0009871b          	sext.w	a4,s3
    80000248:	01677a63          	bgeu	a4,s6,8000025c <consoleread+0xee>
        cons.r--;
    8000024c:	0000f717          	auipc	a4,0xf
    80000250:	6cf72e23          	sw	a5,1756(a4) # 8000f928 <cons+0x98>
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	a031                	j	80000262 <consoleread+0xf4>
    80000258:	ec5e                	sd	s7,24(sp)
    8000025a:	bfbd                	j	800001d8 <consoleread+0x6a>
    8000025c:	6be2                	ld	s7,24(sp)
    8000025e:	a011                	j	80000262 <consoleread+0xf4>
    80000260:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000262:	0000f517          	auipc	a0,0xf
    80000266:	62e50513          	addi	a0,a0,1582 # 8000f890 <cons>
    8000026a:	1fd000ef          	jal	80000c66 <release>
  return target - n;
    8000026e:	413b053b          	subw	a0,s6,s3
    80000272:	bf7d                	j	80000230 <consoleread+0xc2>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	b7f5                	j	80000262 <consoleread+0xf4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50863          	beq	a0,a5,80000294 <consputc+0x1c>
    uartputc_sync(c);
    80000288:	6a4000ef          	jal	8000092c <uartputc_sync>
}
    8000028c:	60a2                	ld	ra,8(sp)
    8000028e:	6402                	ld	s0,0(sp)
    80000290:	0141                	addi	sp,sp,16
    80000292:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000294:	4521                	li	a0,8
    80000296:	696000ef          	jal	8000092c <uartputc_sync>
    8000029a:	02000513          	li	a0,32
    8000029e:	68e000ef          	jal	8000092c <uartputc_sync>
    800002a2:	4521                	li	a0,8
    800002a4:	688000ef          	jal	8000092c <uartputc_sync>
    800002a8:	b7d5                	j	8000028c <consputc+0x14>

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
    800002b2:	1000                	addi	s0,sp,32
    800002b4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b6:	0000f517          	auipc	a0,0xf
    800002ba:	5da50513          	addi	a0,a0,1498 # 8000f890 <cons>
    800002be:	111000ef          	jal	80000bce <acquire>

  switch(c){
    800002c2:	47d5                	li	a5,21
    800002c4:	08f48f63          	beq	s1,a5,80000362 <consoleintr+0xb8>
    800002c8:	0297c563          	blt	a5,s1,800002f2 <consoleintr+0x48>
    800002cc:	47a1                	li	a5,8
    800002ce:	0ef48463          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    800002d2:	47c1                	li	a5,16
    800002d4:	10f49563          	bne	s1,a5,800003de <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002d8:	1cc020ef          	jal	800024a4 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002dc:	0000f517          	auipc	a0,0xf
    800002e0:	5b450513          	addi	a0,a0,1460 # 8000f890 <cons>
    800002e4:	183000ef          	jal	80000c66 <release>
}
    800002e8:	60e2                	ld	ra,24(sp)
    800002ea:	6442                	ld	s0,16(sp)
    800002ec:	64a2                	ld	s1,8(sp)
    800002ee:	6105                	addi	sp,sp,32
    800002f0:	8082                	ret
  switch(c){
    800002f2:	07f00793          	li	a5,127
    800002f6:	0cf48063          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fa:	0000f717          	auipc	a4,0xf
    800002fe:	59670713          	addi	a4,a4,1430 # 8000f890 <cons>
    80000302:	0a072783          	lw	a5,160(a4)
    80000306:	09872703          	lw	a4,152(a4)
    8000030a:	9f99                	subw	a5,a5,a4
    8000030c:	07f00713          	li	a4,127
    80000310:	fcf766e3          	bltu	a4,a5,800002dc <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000314:	47b5                	li	a5,13
    80000316:	0cf48763          	beq	s1,a5,800003e4 <consoleintr+0x13a>
      consputc(c);
    8000031a:	8526                	mv	a0,s1
    8000031c:	f5dff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000320:	0000f797          	auipc	a5,0xf
    80000324:	57078793          	addi	a5,a5,1392 # 8000f890 <cons>
    80000328:	0a07a683          	lw	a3,160(a5)
    8000032c:	0016871b          	addiw	a4,a3,1
    80000330:	0007061b          	sext.w	a2,a4
    80000334:	0ae7a023          	sw	a4,160(a5)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	97b6                	add	a5,a5,a3
    8000033e:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	47a9                	li	a5,10
    80000344:	0cf48563          	beq	s1,a5,8000040e <consoleintr+0x164>
    80000348:	4791                	li	a5,4
    8000034a:	0cf48263          	beq	s1,a5,8000040e <consoleintr+0x164>
    8000034e:	0000f797          	auipc	a5,0xf
    80000352:	5da7a783          	lw	a5,1498(a5) # 8000f928 <cons+0x98>
    80000356:	9f1d                	subw	a4,a4,a5
    80000358:	08000793          	li	a5,128
    8000035c:	f8f710e3          	bne	a4,a5,800002dc <consoleintr+0x32>
    80000360:	a07d                	j	8000040e <consoleintr+0x164>
    80000362:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000364:	0000f717          	auipc	a4,0xf
    80000368:	52c70713          	addi	a4,a4,1324 # 8000f890 <cons>
    8000036c:	0a072783          	lw	a5,160(a4)
    80000370:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000374:	0000f497          	auipc	s1,0xf
    80000378:	51c48493          	addi	s1,s1,1308 # 8000f890 <cons>
    while(cons.e != cons.w &&
    8000037c:	4929                	li	s2,10
    8000037e:	02f70863          	beq	a4,a5,800003ae <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000382:	37fd                	addiw	a5,a5,-1
    80000384:	07f7f713          	andi	a4,a5,127
    80000388:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000038a:	01874703          	lbu	a4,24(a4)
    8000038e:	03270263          	beq	a4,s2,800003b2 <consoleintr+0x108>
      cons.e--;
    80000392:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000396:	10000513          	li	a0,256
    8000039a:	edfff0ef          	jal	80000278 <consputc>
    while(cons.e != cons.w &&
    8000039e:	0a04a783          	lw	a5,160(s1)
    800003a2:	09c4a703          	lw	a4,156(s1)
    800003a6:	fcf71ee3          	bne	a4,a5,80000382 <consoleintr+0xd8>
    800003aa:	6902                	ld	s2,0(sp)
    800003ac:	bf05                	j	800002dc <consoleintr+0x32>
    800003ae:	6902                	ld	s2,0(sp)
    800003b0:	b735                	j	800002dc <consoleintr+0x32>
    800003b2:	6902                	ld	s2,0(sp)
    800003b4:	b725                	j	800002dc <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b6:	0000f717          	auipc	a4,0xf
    800003ba:	4da70713          	addi	a4,a4,1242 # 8000f890 <cons>
    800003be:	0a072783          	lw	a5,160(a4)
    800003c2:	09c72703          	lw	a4,156(a4)
    800003c6:	f0f70be3          	beq	a4,a5,800002dc <consoleintr+0x32>
      cons.e--;
    800003ca:	37fd                	addiw	a5,a5,-1
    800003cc:	0000f717          	auipc	a4,0xf
    800003d0:	56f72223          	sw	a5,1380(a4) # 8000f930 <cons+0xa0>
      consputc(BACKSPACE);
    800003d4:	10000513          	li	a0,256
    800003d8:	ea1ff0ef          	jal	80000278 <consputc>
    800003dc:	b701                	j	800002dc <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003de:	ee048fe3          	beqz	s1,800002dc <consoleintr+0x32>
    800003e2:	bf21                	j	800002fa <consoleintr+0x50>
      consputc(c);
    800003e4:	4529                	li	a0,10
    800003e6:	e93ff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003ea:	0000f797          	auipc	a5,0xf
    800003ee:	4a678793          	addi	a5,a5,1190 # 8000f890 <cons>
    800003f2:	0a07a703          	lw	a4,160(a5)
    800003f6:	0017069b          	addiw	a3,a4,1
    800003fa:	0006861b          	sext.w	a2,a3
    800003fe:	0ad7a023          	sw	a3,160(a5)
    80000402:	07f77713          	andi	a4,a4,127
    80000406:	97ba                	add	a5,a5,a4
    80000408:	4729                	li	a4,10
    8000040a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040e:	0000f797          	auipc	a5,0xf
    80000412:	50c7af23          	sw	a2,1310(a5) # 8000f92c <cons+0x9c>
        wakeup(&cons.r);
    80000416:	0000f517          	auipc	a0,0xf
    8000041a:	51250513          	addi	a0,a0,1298 # 8000f928 <cons+0x98>
    8000041e:	4e3010ef          	jal	80002100 <wakeup>
    80000422:	bd6d                	j	800002dc <consoleintr+0x32>

0000000080000424 <consoleinit>:

void
consoleinit(void)
{
    80000424:	1141                	addi	sp,sp,-16
    80000426:	e406                	sd	ra,8(sp)
    80000428:	e022                	sd	s0,0(sp)
    8000042a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000042c:	00007597          	auipc	a1,0x7
    80000430:	bd458593          	addi	a1,a1,-1068 # 80007000 <etext>
    80000434:	0000f517          	auipc	a0,0xf
    80000438:	45c50513          	addi	a0,a0,1116 # 8000f890 <cons>
    8000043c:	712000ef          	jal	80000b4e <initlock>

  uartinit();
    80000440:	400000ef          	jal	80000840 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000444:	0001f797          	auipc	a5,0x1f
    80000448:	7fc78793          	addi	a5,a5,2044 # 8001fc40 <devsw>
    8000044c:	00000717          	auipc	a4,0x0
    80000450:	d2270713          	addi	a4,a4,-734 # 8000016e <consoleread>
    80000454:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000456:	00000717          	auipc	a4,0x0
    8000045a:	c7a70713          	addi	a4,a4,-902 # 800000d0 <consolewrite>
    8000045e:	ef98                	sd	a4,24(a5)
}
    80000460:	60a2                	ld	ra,8(sp)
    80000462:	6402                	ld	s0,0(sp)
    80000464:	0141                	addi	sp,sp,16
    80000466:	8082                	ret

0000000080000468 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000468:	7139                	addi	sp,sp,-64
    8000046a:	fc06                	sd	ra,56(sp)
    8000046c:	f822                	sd	s0,48(sp)
    8000046e:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000470:	c219                	beqz	a2,80000476 <printint+0xe>
    80000472:	08054063          	bltz	a0,800004f2 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000476:	4881                	li	a7,0
    80000478:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000047c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00007617          	auipc	a2,0x7
    80000482:	2b260613          	addi	a2,a2,690 # 80007730 <digits>
    80000486:	883e                	mv	a6,a5
    80000488:	2785                	addiw	a5,a5,1
    8000048a:	02b57733          	remu	a4,a0,a1
    8000048e:	9732                	add	a4,a4,a2
    80000490:	00074703          	lbu	a4,0(a4)
    80000494:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000498:	872a                	mv	a4,a0
    8000049a:	02b55533          	divu	a0,a0,a1
    8000049e:	0685                	addi	a3,a3,1
    800004a0:	feb773e3          	bgeu	a4,a1,80000486 <printint+0x1e>

  if(sign)
    800004a4:	00088a63          	beqz	a7,800004b8 <printint+0x50>
    buf[i++] = '-';
    800004a8:	1781                	addi	a5,a5,-32
    800004aa:	97a2                	add	a5,a5,s0
    800004ac:	02d00713          	li	a4,45
    800004b0:	fee78423          	sb	a4,-24(a5)
    800004b4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800004b8:	02f05963          	blez	a5,800004ea <printint+0x82>
    800004bc:	f426                	sd	s1,40(sp)
    800004be:	f04a                	sd	s2,32(sp)
    800004c0:	fc840713          	addi	a4,s0,-56
    800004c4:	00f704b3          	add	s1,a4,a5
    800004c8:	fff70913          	addi	s2,a4,-1
    800004cc:	993e                	add	s2,s2,a5
    800004ce:	37fd                	addiw	a5,a5,-1
    800004d0:	1782                	slli	a5,a5,0x20
    800004d2:	9381                	srli	a5,a5,0x20
    800004d4:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004d8:	fff4c503          	lbu	a0,-1(s1)
    800004dc:	d9dff0ef          	jal	80000278 <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x70>
    800004e6:	74a2                	ld	s1,40(sp)
    800004e8:	7902                	ld	s2,32(sp)
}
    800004ea:	70e2                	ld	ra,56(sp)
    800004ec:	7442                	ld	s0,48(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4885                	li	a7,1
    x = -xx;
    800004f8:	b741                	j	80000478 <printint+0x10>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	e8d2                	sd	s4,80(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	8a2a                	mv	s4,a0
    80000506:	e40c                	sd	a1,8(s0)
    80000508:	e810                	sd	a2,16(s0)
    8000050a:	ec14                	sd	a3,24(s0)
    8000050c:	f018                	sd	a4,32(s0)
    8000050e:	f41c                	sd	a5,40(s0)
    80000510:	03043823          	sd	a6,48(s0)
    80000514:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000518:	00007797          	auipc	a5,0x7
    8000051c:	34c7a783          	lw	a5,844(a5) # 80007864 <panicking>
    80000520:	c3a1                	beqz	a5,80000560 <printf+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	000a4503          	lbu	a0,0(s4)
    8000052e:	28050763          	beqz	a0,800007bc <printf+0x2c2>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	f0ca                	sd	s2,96(sp)
    80000536:	ecce                	sd	s3,88(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	f862                	sd	s8,48(sp)
    8000053e:	f466                	sd	s9,40(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4981                	li	s3,0
    if(cx != '%'){
    80000546:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    8000054a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000054e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000552:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000556:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    8000055a:	07000d93          	li	s11,112
    8000055e:	a01d                	j	80000584 <printf+0x8a>
    acquire(&pr.lock);
    80000560:	0000f517          	auipc	a0,0xf
    80000564:	3d850513          	addi	a0,a0,984 # 8000f938 <pr>
    80000568:	666000ef          	jal	80000bce <acquire>
    8000056c:	bf5d                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056e:	d0bff0ef          	jal	80000278 <consputc>
      continue;
    80000572:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000574:	0014899b          	addiw	s3,s1,1
    80000578:	013a07b3          	add	a5,s4,s3
    8000057c:	0007c503          	lbu	a0,0(a5)
    80000580:	20050b63          	beqz	a0,80000796 <printf+0x29c>
    if(cx != '%'){
    80000584:	ff5515e3          	bne	a0,s5,8000056e <printf+0x74>
    i++;
    80000588:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000058c:	009a07b3          	add	a5,s4,s1
    80000590:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000594:	20090b63          	beqz	s2,800007aa <printf+0x2b0>
    80000598:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    8000059c:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059e:	c789                	beqz	a5,800005a8 <printf+0xae>
    800005a0:	009a0733          	add	a4,s4,s1
    800005a4:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800005a8:	03690963          	beq	s2,s6,800005da <printf+0xe0>
    } else if(c0 == 'l' && c1 == 'd'){
    800005ac:	05890363          	beq	s2,s8,800005f2 <printf+0xf8>
    } else if(c0 == 'u'){
    800005b0:	0d990663          	beq	s2,s9,8000067c <printf+0x182>
    } else if(c0 == 'x'){
    800005b4:	11a90d63          	beq	s2,s10,800006ce <printf+0x1d4>
    } else if(c0 == 'p'){
    800005b8:	15b90663          	beq	s2,s11,80000704 <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    800005bc:	06300793          	li	a5,99
    800005c0:	18f90563          	beq	s2,a5,8000074a <printf+0x250>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    800005c4:	07300793          	li	a5,115
    800005c8:	18f90b63          	beq	s2,a5,8000075e <printf+0x264>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005cc:	03591b63          	bne	s2,s5,80000602 <printf+0x108>
      consputc('%');
    800005d0:	02500513          	li	a0,37
    800005d4:	ca5ff0ef          	jal	80000278 <consputc>
    800005d8:	bf71                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005da:	f8843783          	ld	a5,-120(s0)
    800005de:	00878713          	addi	a4,a5,8
    800005e2:	f8e43423          	sd	a4,-120(s0)
    800005e6:	4605                	li	a2,1
    800005e8:	45a9                	li	a1,10
    800005ea:	4388                	lw	a0,0(a5)
    800005ec:	e7dff0ef          	jal	80000468 <printint>
    800005f0:	b751                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'd'){
    800005f2:	01678f63          	beq	a5,s6,80000610 <printf+0x116>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005f6:	03878b63          	beq	a5,s8,8000062c <printf+0x132>
    } else if(c0 == 'l' && c1 == 'u'){
    800005fa:	09978e63          	beq	a5,s9,80000696 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'x'){
    800005fe:	0fa78563          	beq	a5,s10,800006e8 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000602:	8556                	mv	a0,s5
    80000604:	c75ff0ef          	jal	80000278 <consputc>
      consputc(c0);
    80000608:	854a                	mv	a0,s2
    8000060a:	c6fff0ef          	jal	80000278 <consputc>
    8000060e:	b79d                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000610:	f8843783          	ld	a5,-120(s0)
    80000614:	00878713          	addi	a4,a5,8
    80000618:	f8e43423          	sd	a4,-120(s0)
    8000061c:	4605                	li	a2,1
    8000061e:	45a9                	li	a1,10
    80000620:	6388                	ld	a0,0(a5)
    80000622:	e47ff0ef          	jal	80000468 <printint>
      i += 1;
    80000626:	0029849b          	addiw	s1,s3,2
    8000062a:	b7a9                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000062c:	06400793          	li	a5,100
    80000630:	02f68863          	beq	a3,a5,80000660 <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000634:	07500793          	li	a5,117
    80000638:	06f68d63          	beq	a3,a5,800006b2 <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000063c:	07800793          	li	a5,120
    80000640:	fcf691e3          	bne	a3,a5,80000602 <printf+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4601                	li	a2,0
    80000652:	45c1                	li	a1,16
    80000654:	6388                	ld	a0,0(a5)
    80000656:	e13ff0ef          	jal	80000468 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bf19                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4605                	li	a2,1
    8000066e:	45a9                	li	a1,10
    80000670:	6388                	ld	a0,0(a5)
    80000672:	df7ff0ef          	jal	80000468 <printint>
      i += 2;
    80000676:	0039849b          	addiw	s1,s3,3
    8000067a:	bded                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4601                	li	a2,0
    8000068a:	45a9                	li	a1,10
    8000068c:	0007e503          	lwu	a0,0(a5)
    80000690:	dd9ff0ef          	jal	80000468 <printint>
    80000694:	b5c5                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	4601                	li	a2,0
    800006a4:	45a9                	li	a1,10
    800006a6:	6388                	ld	a0,0(a5)
    800006a8:	dc1ff0ef          	jal	80000468 <printint>
      i += 1;
    800006ac:	0029849b          	addiw	s1,s3,2
    800006b0:	b5d1                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4601                	li	a2,0
    800006c0:	45a9                	li	a1,10
    800006c2:	6388                	ld	a0,0(a5)
    800006c4:	da5ff0ef          	jal	80000468 <printint>
      i += 2;
    800006c8:	0039849b          	addiw	s1,s3,3
    800006cc:	b565                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	4601                	li	a2,0
    800006dc:	45c1                	li	a1,16
    800006de:	0007e503          	lwu	a0,0(a5)
    800006e2:	d87ff0ef          	jal	80000468 <printint>
    800006e6:	b579                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	4601                	li	a2,0
    800006f6:	45c1                	li	a1,16
    800006f8:	6388                	ld	a0,0(a5)
    800006fa:	d6fff0ef          	jal	80000468 <printint>
      i += 1;
    800006fe:	0029849b          	addiw	s1,s3,2
    80000702:	bd8d                	j	80000574 <printf+0x7a>
    80000704:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000706:	f8843783          	ld	a5,-120(s0)
    8000070a:	00878713          	addi	a4,a5,8
    8000070e:	f8e43423          	sd	a4,-120(s0)
    80000712:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000716:	03000513          	li	a0,48
    8000071a:	b5fff0ef          	jal	80000278 <consputc>
  consputc('x');
    8000071e:	07800513          	li	a0,120
    80000722:	b57ff0ef          	jal	80000278 <consputc>
    80000726:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000728:	00007b97          	auipc	s7,0x7
    8000072c:	008b8b93          	addi	s7,s7,8 # 80007730 <digits>
    80000730:	03c9d793          	srli	a5,s3,0x3c
    80000734:	97de                	add	a5,a5,s7
    80000736:	0007c503          	lbu	a0,0(a5)
    8000073a:	b3fff0ef          	jal	80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000073e:	0992                	slli	s3,s3,0x4
    80000740:	397d                	addiw	s2,s2,-1
    80000742:	fe0917e3          	bnez	s2,80000730 <printf+0x236>
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	b535                	j	80000574 <printf+0x7a>
      consputc(va_arg(ap, uint));
    8000074a:	f8843783          	ld	a5,-120(s0)
    8000074e:	00878713          	addi	a4,a5,8
    80000752:	f8e43423          	sd	a4,-120(s0)
    80000756:	4388                	lw	a0,0(a5)
    80000758:	b21ff0ef          	jal	80000278 <consputc>
    8000075c:	bd21                	j	80000574 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    8000075e:	f8843783          	ld	a5,-120(s0)
    80000762:	00878713          	addi	a4,a5,8
    80000766:	f8e43423          	sd	a4,-120(s0)
    8000076a:	0007b903          	ld	s2,0(a5)
    8000076e:	00090d63          	beqz	s2,80000788 <printf+0x28e>
      for(; *s; s++)
    80000772:	00094503          	lbu	a0,0(s2)
    80000776:	de050fe3          	beqz	a0,80000574 <printf+0x7a>
        consputc(*s);
    8000077a:	affff0ef          	jal	80000278 <consputc>
      for(; *s; s++)
    8000077e:	0905                	addi	s2,s2,1
    80000780:	00094503          	lbu	a0,0(s2)
    80000784:	f97d                	bnez	a0,8000077a <printf+0x280>
    80000786:	b3fd                	j	80000574 <printf+0x7a>
        s = "(null)";
    80000788:	00007917          	auipc	s2,0x7
    8000078c:	88090913          	addi	s2,s2,-1920 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000790:	02800513          	li	a0,40
    80000794:	b7dd                	j	8000077a <printf+0x280>
    80000796:	74a6                	ld	s1,104(sp)
    80000798:	7906                	ld	s2,96(sp)
    8000079a:	69e6                	ld	s3,88(sp)
    8000079c:	6aa6                	ld	s5,72(sp)
    8000079e:	6b06                	ld	s6,64(sp)
    800007a0:	7c42                	ld	s8,48(sp)
    800007a2:	7ca2                	ld	s9,40(sp)
    800007a4:	7d02                	ld	s10,32(sp)
    800007a6:	6de2                	ld	s11,24(sp)
    800007a8:	a811                	j	800007bc <printf+0x2c2>
    800007aa:	74a6                	ld	s1,104(sp)
    800007ac:	7906                	ld	s2,96(sp)
    800007ae:	69e6                	ld	s3,88(sp)
    800007b0:	6aa6                	ld	s5,72(sp)
    800007b2:	6b06                	ld	s6,64(sp)
    800007b4:	7c42                	ld	s8,48(sp)
    800007b6:	7ca2                	ld	s9,40(sp)
    800007b8:	7d02                	ld	s10,32(sp)
    800007ba:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    800007bc:	00007797          	auipc	a5,0x7
    800007c0:	0a87a783          	lw	a5,168(a5) # 80007864 <panicking>
    800007c4:	c799                	beqz	a5,800007d2 <printf+0x2d8>
    release(&pr.lock);

  return 0;
}
    800007c6:	4501                	li	a0,0
    800007c8:	70e6                	ld	ra,120(sp)
    800007ca:	7446                	ld	s0,112(sp)
    800007cc:	6a46                	ld	s4,80(sp)
    800007ce:	6129                	addi	sp,sp,192
    800007d0:	8082                	ret
    release(&pr.lock);
    800007d2:	0000f517          	auipc	a0,0xf
    800007d6:	16650513          	addi	a0,a0,358 # 8000f938 <pr>
    800007da:	48c000ef          	jal	80000c66 <release>
  return 0;
    800007de:	b7e5                	j	800007c6 <printf+0x2cc>

00000000800007e0 <panic>:

void
panic(char *s)
{
    800007e0:	1101                	addi	sp,sp,-32
    800007e2:	ec06                	sd	ra,24(sp)
    800007e4:	e822                	sd	s0,16(sp)
    800007e6:	e426                	sd	s1,8(sp)
    800007e8:	e04a                	sd	s2,0(sp)
    800007ea:	1000                	addi	s0,sp,32
    800007ec:	84aa                	mv	s1,a0
  panicking = 1;
    800007ee:	4905                	li	s2,1
    800007f0:	00007797          	auipc	a5,0x7
    800007f4:	0727aa23          	sw	s2,116(a5) # 80007864 <panicking>
  printf("panic: ");
    800007f8:	00007517          	auipc	a0,0x7
    800007fc:	82050513          	addi	a0,a0,-2016 # 80007018 <etext+0x18>
    80000800:	cfbff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000804:	85a6                	mv	a1,s1
    80000806:	00007517          	auipc	a0,0x7
    8000080a:	81a50513          	addi	a0,a0,-2022 # 80007020 <etext+0x20>
    8000080e:	cedff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000812:	00007797          	auipc	a5,0x7
    80000816:	0527a723          	sw	s2,78(a5) # 80007860 <panicked>
  for(;;)
    8000081a:	a001                	j	8000081a <panic+0x3a>

000000008000081c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000081c:	1141                	addi	sp,sp,-16
    8000081e:	e406                	sd	ra,8(sp)
    80000820:	e022                	sd	s0,0(sp)
    80000822:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000824:	00007597          	auipc	a1,0x7
    80000828:	80458593          	addi	a1,a1,-2044 # 80007028 <etext+0x28>
    8000082c:	0000f517          	auipc	a0,0xf
    80000830:	10c50513          	addi	a0,a0,268 # 8000f938 <pr>
    80000834:	31a000ef          	jal	80000b4e <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	addi	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000840:	1141                	addi	sp,sp,-16
    80000842:	e406                	sd	ra,8(sp)
    80000844:	e022                	sd	s0,0(sp)
    80000846:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000848:	100007b7          	lui	a5,0x10000
    8000084c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000850:	10000737          	lui	a4,0x10000
    80000854:	f8000693          	li	a3,-128
    80000858:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000085c:	468d                	li	a3,3
    8000085e:	10000637          	lui	a2,0x10000
    80000862:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000866:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000086a:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	461d                	li	a2,7
    80000874:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000878:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    8000087c:	00006597          	auipc	a1,0x6
    80000880:	7b458593          	addi	a1,a1,1972 # 80007030 <etext+0x30>
    80000884:	0000f517          	auipc	a0,0xf
    80000888:	0cc50513          	addi	a0,a0,204 # 8000f950 <tx_lock>
    8000088c:	2c2000ef          	jal	80000b4e <initlock>
}
    80000890:	60a2                	ld	ra,8(sp)
    80000892:	6402                	ld	s0,0(sp)
    80000894:	0141                	addi	sp,sp,16
    80000896:	8082                	ret

0000000080000898 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80000898:	715d                	addi	sp,sp,-80
    8000089a:	e486                	sd	ra,72(sp)
    8000089c:	e0a2                	sd	s0,64(sp)
    8000089e:	fc26                	sd	s1,56(sp)
    800008a0:	ec56                	sd	s5,24(sp)
    800008a2:	0880                	addi	s0,sp,80
    800008a4:	8aaa                	mv	s5,a0
    800008a6:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008a8:	0000f517          	auipc	a0,0xf
    800008ac:	0a850513          	addi	a0,a0,168 # 8000f950 <tx_lock>
    800008b0:	31e000ef          	jal	80000bce <acquire>

  int i = 0;
  while(i < n){ 
    800008b4:	06905063          	blez	s1,80000914 <uartwrite+0x7c>
    800008b8:	f84a                	sd	s2,48(sp)
    800008ba:	f44e                	sd	s3,40(sp)
    800008bc:	f052                	sd	s4,32(sp)
    800008be:	e85a                	sd	s6,16(sp)
    800008c0:	e45e                	sd	s7,8(sp)
    800008c2:	8a56                	mv	s4,s5
    800008c4:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    800008c6:	00007497          	auipc	s1,0x7
    800008ca:	fa648493          	addi	s1,s1,-90 # 8000786c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800008ce:	0000f997          	auipc	s3,0xf
    800008d2:	08298993          	addi	s3,s3,130 # 8000f950 <tx_lock>
    800008d6:	00007917          	auipc	s2,0x7
    800008da:	f9290913          	addi	s2,s2,-110 # 80007868 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    800008de:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    800008e2:	4b05                	li	s6,1
    800008e4:	a005                	j	80000904 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    800008e6:	85ce                	mv	a1,s3
    800008e8:	854a                	mv	a0,s2
    800008ea:	7ca010ef          	jal	800020b4 <sleep>
    while(tx_busy != 0){
    800008ee:	409c                	lw	a5,0(s1)
    800008f0:	fbfd                	bnez	a5,800008e6 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    800008f2:	000a4783          	lbu	a5,0(s4)
    800008f6:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008fa:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800008fe:	0a05                	addi	s4,s4,1
    80000900:	015a0563          	beq	s4,s5,8000090a <uartwrite+0x72>
    while(tx_busy != 0){
    80000904:	409c                	lw	a5,0(s1)
    80000906:	f3e5                	bnez	a5,800008e6 <uartwrite+0x4e>
    80000908:	b7ed                	j	800008f2 <uartwrite+0x5a>
    8000090a:	7942                	ld	s2,48(sp)
    8000090c:	79a2                	ld	s3,40(sp)
    8000090e:	7a02                	ld	s4,32(sp)
    80000910:	6b42                	ld	s6,16(sp)
    80000912:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000914:	0000f517          	auipc	a0,0xf
    80000918:	03c50513          	addi	a0,a0,60 # 8000f950 <tx_lock>
    8000091c:	34a000ef          	jal	80000c66 <release>
}
    80000920:	60a6                	ld	ra,72(sp)
    80000922:	6406                	ld	s0,64(sp)
    80000924:	74e2                	ld	s1,56(sp)
    80000926:	6ae2                	ld	s5,24(sp)
    80000928:	6161                	addi	sp,sp,80
    8000092a:	8082                	ret

000000008000092c <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000092c:	1101                	addi	sp,sp,-32
    8000092e:	ec06                	sd	ra,24(sp)
    80000930:	e822                	sd	s0,16(sp)
    80000932:	e426                	sd	s1,8(sp)
    80000934:	1000                	addi	s0,sp,32
    80000936:	84aa                	mv	s1,a0
  if(panicking == 0)
    80000938:	00007797          	auipc	a5,0x7
    8000093c:	f2c7a783          	lw	a5,-212(a5) # 80007864 <panicking>
    80000940:	cf95                	beqz	a5,8000097c <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000942:	00007797          	auipc	a5,0x7
    80000946:	f1e7a783          	lw	a5,-226(a5) # 80007860 <panicked>
    8000094a:	ef85                	bnez	a5,80000982 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000094c:	10000737          	lui	a4,0x10000
    80000950:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000952:	00074783          	lbu	a5,0(a4)
    80000956:	0207f793          	andi	a5,a5,32
    8000095a:	dfe5                	beqz	a5,80000952 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000095c:	0ff4f513          	zext.b	a0,s1
    80000960:	100007b7          	lui	a5,0x10000
    80000964:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000968:	00007797          	auipc	a5,0x7
    8000096c:	efc7a783          	lw	a5,-260(a5) # 80007864 <panicking>
    80000970:	cb91                	beqz	a5,80000984 <uartputc_sync+0x58>
    pop_off();
}
    80000972:	60e2                	ld	ra,24(sp)
    80000974:	6442                	ld	s0,16(sp)
    80000976:	64a2                	ld	s1,8(sp)
    80000978:	6105                	addi	sp,sp,32
    8000097a:	8082                	ret
    push_off();
    8000097c:	212000ef          	jal	80000b8e <push_off>
    80000980:	b7c9                	j	80000942 <uartputc_sync+0x16>
    for(;;)
    80000982:	a001                	j	80000982 <uartputc_sync+0x56>
    pop_off();
    80000984:	28e000ef          	jal	80000c12 <pop_off>
}
    80000988:	b7ed                	j	80000972 <uartputc_sync+0x46>

000000008000098a <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000098a:	1141                	addi	sp,sp,-16
    8000098c:	e422                	sd	s0,8(sp)
    8000098e:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80000990:	100007b7          	lui	a5,0x10000
    80000994:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80000996:	0007c783          	lbu	a5,0(a5)
    8000099a:	8b85                	andi	a5,a5,1
    8000099c:	cb81                	beqz	a5,800009ac <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    8000099e:	100007b7          	lui	a5,0x10000
    800009a2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009a6:	6422                	ld	s0,8(sp)
    800009a8:	0141                	addi	sp,sp,16
    800009aa:	8082                	ret
    return -1;
    800009ac:	557d                	li	a0,-1
    800009ae:	bfe5                	j	800009a6 <uartgetc+0x1c>

00000000800009b0 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009b0:	1101                	addi	sp,sp,-32
    800009b2:	ec06                	sd	ra,24(sp)
    800009b4:	e822                	sd	s0,16(sp)
    800009b6:	e426                	sd	s1,8(sp)
    800009b8:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009ba:	100007b7          	lui	a5,0x10000
    800009be:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    800009c0:	0007c783          	lbu	a5,0(a5)

  acquire(&tx_lock);
    800009c4:	0000f517          	auipc	a0,0xf
    800009c8:	f8c50513          	addi	a0,a0,-116 # 8000f950 <tx_lock>
    800009cc:	202000ef          	jal	80000bce <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    800009d0:	100007b7          	lui	a5,0x10000
    800009d4:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009d6:	0007c783          	lbu	a5,0(a5)
    800009da:	0207f793          	andi	a5,a5,32
    800009de:	eb89                	bnez	a5,800009f0 <uartintr+0x40>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    800009e0:	0000f517          	auipc	a0,0xf
    800009e4:	f7050513          	addi	a0,a0,-144 # 8000f950 <tx_lock>
    800009e8:	27e000ef          	jal	80000c66 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009ec:	54fd                	li	s1,-1
    800009ee:	a831                	j	80000a0a <uartintr+0x5a>
    tx_busy = 0;
    800009f0:	00007797          	auipc	a5,0x7
    800009f4:	e607ae23          	sw	zero,-388(a5) # 8000786c <tx_busy>
    wakeup(&tx_chan);
    800009f8:	00007517          	auipc	a0,0x7
    800009fc:	e7050513          	addi	a0,a0,-400 # 80007868 <tx_chan>
    80000a00:	700010ef          	jal	80002100 <wakeup>
    80000a04:	bff1                	j	800009e0 <uartintr+0x30>
      break;
    consoleintr(c);
    80000a06:	8a5ff0ef          	jal	800002aa <consoleintr>
    int c = uartgetc();
    80000a0a:	f81ff0ef          	jal	8000098a <uartgetc>
    if(c == -1)
    80000a0e:	fe951ce3          	bne	a0,s1,80000a06 <uartintr+0x56>
  }
}
    80000a12:	60e2                	ld	ra,24(sp)
    80000a14:	6442                	ld	s0,16(sp)
    80000a16:	64a2                	ld	s1,8(sp)
    80000a18:	6105                	addi	sp,sp,32
    80000a1a:	8082                	ret

0000000080000a1c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a1c:	1101                	addi	sp,sp,-32
    80000a1e:	ec06                	sd	ra,24(sp)
    80000a20:	e822                	sd	s0,16(sp)
    80000a22:	e426                	sd	s1,8(sp)
    80000a24:	e04a                	sd	s2,0(sp)
    80000a26:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a28:	03451793          	slli	a5,a0,0x34
    80000a2c:	e7a9                	bnez	a5,80000a76 <kfree+0x5a>
    80000a2e:	84aa                	mv	s1,a0
    80000a30:	00020797          	auipc	a5,0x20
    80000a34:	3a878793          	addi	a5,a5,936 # 80020dd8 <end>
    80000a38:	02f56f63          	bltu	a0,a5,80000a76 <kfree+0x5a>
    80000a3c:	47c5                	li	a5,17
    80000a3e:	07ee                	slli	a5,a5,0x1b
    80000a40:	02f57b63          	bgeu	a0,a5,80000a76 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a44:	6605                	lui	a2,0x1
    80000a46:	4585                	li	a1,1
    80000a48:	25a000ef          	jal	80000ca2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a4c:	0000f917          	auipc	s2,0xf
    80000a50:	f1c90913          	addi	s2,s2,-228 # 8000f968 <kmem>
    80000a54:	854a                	mv	a0,s2
    80000a56:	178000ef          	jal	80000bce <acquire>
  r->next = kmem.freelist;
    80000a5a:	01893783          	ld	a5,24(s2)
    80000a5e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a60:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a64:	854a                	mv	a0,s2
    80000a66:	200000ef          	jal	80000c66 <release>
}
    80000a6a:	60e2                	ld	ra,24(sp)
    80000a6c:	6442                	ld	s0,16(sp)
    80000a6e:	64a2                	ld	s1,8(sp)
    80000a70:	6902                	ld	s2,0(sp)
    80000a72:	6105                	addi	sp,sp,32
    80000a74:	8082                	ret
    panic("kfree");
    80000a76:	00006517          	auipc	a0,0x6
    80000a7a:	5c250513          	addi	a0,a0,1474 # 80007038 <etext+0x38>
    80000a7e:	d63ff0ef          	jal	800007e0 <panic>

0000000080000a82 <freerange>:
{
    80000a82:	7179                	addi	sp,sp,-48
    80000a84:	f406                	sd	ra,40(sp)
    80000a86:	f022                	sd	s0,32(sp)
    80000a88:	ec26                	sd	s1,24(sp)
    80000a8a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a8c:	6785                	lui	a5,0x1
    80000a8e:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a92:	00e504b3          	add	s1,a0,a4
    80000a96:	777d                	lui	a4,0xfffff
    80000a98:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a9a:	94be                	add	s1,s1,a5
    80000a9c:	0295e263          	bltu	a1,s1,80000ac0 <freerange+0x3e>
    80000aa0:	e84a                	sd	s2,16(sp)
    80000aa2:	e44e                	sd	s3,8(sp)
    80000aa4:	e052                	sd	s4,0(sp)
    80000aa6:	892e                	mv	s2,a1
    kfree(p);
    80000aa8:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aaa:	6985                	lui	s3,0x1
    kfree(p);
    80000aac:	01448533          	add	a0,s1,s4
    80000ab0:	f6dff0ef          	jal	80000a1c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ab4:	94ce                	add	s1,s1,s3
    80000ab6:	fe997be3          	bgeu	s2,s1,80000aac <freerange+0x2a>
    80000aba:	6942                	ld	s2,16(sp)
    80000abc:	69a2                	ld	s3,8(sp)
    80000abe:	6a02                	ld	s4,0(sp)
}
    80000ac0:	70a2                	ld	ra,40(sp)
    80000ac2:	7402                	ld	s0,32(sp)
    80000ac4:	64e2                	ld	s1,24(sp)
    80000ac6:	6145                	addi	sp,sp,48
    80000ac8:	8082                	ret

0000000080000aca <kinit>:
{
    80000aca:	1141                	addi	sp,sp,-16
    80000acc:	e406                	sd	ra,8(sp)
    80000ace:	e022                	sd	s0,0(sp)
    80000ad0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ad2:	00006597          	auipc	a1,0x6
    80000ad6:	56e58593          	addi	a1,a1,1390 # 80007040 <etext+0x40>
    80000ada:	0000f517          	auipc	a0,0xf
    80000ade:	e8e50513          	addi	a0,a0,-370 # 8000f968 <kmem>
    80000ae2:	06c000ef          	jal	80000b4e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ae6:	45c5                	li	a1,17
    80000ae8:	05ee                	slli	a1,a1,0x1b
    80000aea:	00020517          	auipc	a0,0x20
    80000aee:	2ee50513          	addi	a0,a0,750 # 80020dd8 <end>
    80000af2:	f91ff0ef          	jal	80000a82 <freerange>
}
    80000af6:	60a2                	ld	ra,8(sp)
    80000af8:	6402                	ld	s0,0(sp)
    80000afa:	0141                	addi	sp,sp,16
    80000afc:	8082                	ret

0000000080000afe <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000afe:	1101                	addi	sp,sp,-32
    80000b00:	ec06                	sd	ra,24(sp)
    80000b02:	e822                	sd	s0,16(sp)
    80000b04:	e426                	sd	s1,8(sp)
    80000b06:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b08:	0000f497          	auipc	s1,0xf
    80000b0c:	e6048493          	addi	s1,s1,-416 # 8000f968 <kmem>
    80000b10:	8526                	mv	a0,s1
    80000b12:	0bc000ef          	jal	80000bce <acquire>
  r = kmem.freelist;
    80000b16:	6c84                	ld	s1,24(s1)
  if(r)
    80000b18:	c485                	beqz	s1,80000b40 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b1a:	609c                	ld	a5,0(s1)
    80000b1c:	0000f517          	auipc	a0,0xf
    80000b20:	e4c50513          	addi	a0,a0,-436 # 8000f968 <kmem>
    80000b24:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b26:	140000ef          	jal	80000c66 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b2a:	6605                	lui	a2,0x1
    80000b2c:	4595                	li	a1,5
    80000b2e:	8526                	mv	a0,s1
    80000b30:	172000ef          	jal	80000ca2 <memset>
  return (void*)r;
}
    80000b34:	8526                	mv	a0,s1
    80000b36:	60e2                	ld	ra,24(sp)
    80000b38:	6442                	ld	s0,16(sp)
    80000b3a:	64a2                	ld	s1,8(sp)
    80000b3c:	6105                	addi	sp,sp,32
    80000b3e:	8082                	ret
  release(&kmem.lock);
    80000b40:	0000f517          	auipc	a0,0xf
    80000b44:	e2850513          	addi	a0,a0,-472 # 8000f968 <kmem>
    80000b48:	11e000ef          	jal	80000c66 <release>
  if(r)
    80000b4c:	b7e5                	j	80000b34 <kalloc+0x36>

0000000080000b4e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b4e:	1141                	addi	sp,sp,-16
    80000b50:	e422                	sd	s0,8(sp)
    80000b52:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b54:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b56:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b5a:	00053823          	sd	zero,16(a0)
}
    80000b5e:	6422                	ld	s0,8(sp)
    80000b60:	0141                	addi	sp,sp,16
    80000b62:	8082                	ret

0000000080000b64 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b64:	411c                	lw	a5,0(a0)
    80000b66:	e399                	bnez	a5,80000b6c <holding+0x8>
    80000b68:	4501                	li	a0,0
  return r;
}
    80000b6a:	8082                	ret
{
    80000b6c:	1101                	addi	sp,sp,-32
    80000b6e:	ec06                	sd	ra,24(sp)
    80000b70:	e822                	sd	s0,16(sp)
    80000b72:	e426                	sd	s1,8(sp)
    80000b74:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b76:	6904                	ld	s1,16(a0)
    80000b78:	6b3000ef          	jal	80001a2a <mycpu>
    80000b7c:	40a48533          	sub	a0,s1,a0
    80000b80:	00153513          	seqz	a0,a0
}
    80000b84:	60e2                	ld	ra,24(sp)
    80000b86:	6442                	ld	s0,16(sp)
    80000b88:	64a2                	ld	s1,8(sp)
    80000b8a:	6105                	addi	sp,sp,32
    80000b8c:	8082                	ret

0000000080000b8e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8e:	1101                	addi	sp,sp,-32
    80000b90:	ec06                	sd	ra,24(sp)
    80000b92:	e822                	sd	s0,16(sp)
    80000b94:	e426                	sd	s1,8(sp)
    80000b96:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b98:	100024f3          	csrr	s1,sstatus
    80000b9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000ba0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ba2:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000ba6:	685000ef          	jal	80001a2a <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cb99                	beqz	a5,80000bc2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	67d000ef          	jal	80001a2a <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addiw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	669000ef          	jal	80001a2a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bc6:	8085                	srli	s1,s1,0x1
    80000bc8:	8885                	andi	s1,s1,1
    80000bca:	dd64                	sw	s1,124(a0)
    80000bcc:	b7cd                	j	80000bae <push_off+0x20>

0000000080000bce <acquire>:
{
    80000bce:	1101                	addi	sp,sp,-32
    80000bd0:	ec06                	sd	ra,24(sp)
    80000bd2:	e822                	sd	s0,16(sp)
    80000bd4:	e426                	sd	s1,8(sp)
    80000bd6:	1000                	addi	s0,sp,32
    80000bd8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bda:	fb5ff0ef          	jal	80000b8e <push_off>
  if(holding(lk))
    80000bde:	8526                	mv	a0,s1
    80000be0:	f85ff0ef          	jal	80000b64 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	4705                	li	a4,1
  if(holding(lk))
    80000be6:	e105                	bnez	a0,80000c06 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be8:	87ba                	mv	a5,a4
    80000bea:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bee:	2781                	sext.w	a5,a5
    80000bf0:	ffe5                	bnez	a5,80000be8 <acquire+0x1a>
  __sync_synchronize();
    80000bf2:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bf6:	635000ef          	jal	80001a2a <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00006517          	auipc	a0,0x6
    80000c0a:	44250513          	addi	a0,a0,1090 # 80007048 <etext+0x48>
    80000c0e:	bd3ff0ef          	jal	800007e0 <panic>

0000000080000c12 <pop_off>:

void
pop_off(void)
{
    80000c12:	1141                	addi	sp,sp,-16
    80000c14:	e406                	sd	ra,8(sp)
    80000c16:	e022                	sd	s0,0(sp)
    80000c18:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1a:	611000ef          	jal	80001a2a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c1e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c22:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c24:	e78d                	bnez	a5,80000c4e <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c26:	5d3c                	lw	a5,120(a0)
    80000c28:	02f05963          	blez	a5,80000c5a <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c2c:	37fd                	addiw	a5,a5,-1
    80000c2e:	0007871b          	sext.w	a4,a5
    80000c32:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c34:	eb09                	bnez	a4,80000c46 <pop_off+0x34>
    80000c36:	5d7c                	lw	a5,124(a0)
    80000c38:	c799                	beqz	a5,80000c46 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c3e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c42:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c46:	60a2                	ld	ra,8(sp)
    80000c48:	6402                	ld	s0,0(sp)
    80000c4a:	0141                	addi	sp,sp,16
    80000c4c:	8082                	ret
    panic("pop_off - interruptible");
    80000c4e:	00006517          	auipc	a0,0x6
    80000c52:	40250513          	addi	a0,a0,1026 # 80007050 <etext+0x50>
    80000c56:	b8bff0ef          	jal	800007e0 <panic>
    panic("pop_off");
    80000c5a:	00006517          	auipc	a0,0x6
    80000c5e:	40e50513          	addi	a0,a0,1038 # 80007068 <etext+0x68>
    80000c62:	b7fff0ef          	jal	800007e0 <panic>

0000000080000c66 <release>:
{
    80000c66:	1101                	addi	sp,sp,-32
    80000c68:	ec06                	sd	ra,24(sp)
    80000c6a:	e822                	sd	s0,16(sp)
    80000c6c:	e426                	sd	s1,8(sp)
    80000c6e:	1000                	addi	s0,sp,32
    80000c70:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c72:	ef3ff0ef          	jal	80000b64 <holding>
    80000c76:	c105                	beqz	a0,80000c96 <release+0x30>
  lk->cpu = 0;
    80000c78:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c7c:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c80:	0f50000f          	fence	iorw,ow
    80000c84:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c88:	f8bff0ef          	jal	80000c12 <pop_off>
}
    80000c8c:	60e2                	ld	ra,24(sp)
    80000c8e:	6442                	ld	s0,16(sp)
    80000c90:	64a2                	ld	s1,8(sp)
    80000c92:	6105                	addi	sp,sp,32
    80000c94:	8082                	ret
    panic("release");
    80000c96:	00006517          	auipc	a0,0x6
    80000c9a:	3da50513          	addi	a0,a0,986 # 80007070 <etext+0x70>
    80000c9e:	b43ff0ef          	jal	800007e0 <panic>

0000000080000ca2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ca2:	1141                	addi	sp,sp,-16
    80000ca4:	e422                	sd	s0,8(sp)
    80000ca6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ca8:	ca19                	beqz	a2,80000cbe <memset+0x1c>
    80000caa:	87aa                	mv	a5,a0
    80000cac:	1602                	slli	a2,a2,0x20
    80000cae:	9201                	srli	a2,a2,0x20
    80000cb0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cb4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cb8:	0785                	addi	a5,a5,1
    80000cba:	fee79de3          	bne	a5,a4,80000cb4 <memset+0x12>
  }
  return dst;
}
    80000cbe:	6422                	ld	s0,8(sp)
    80000cc0:	0141                	addi	sp,sp,16
    80000cc2:	8082                	ret

0000000080000cc4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cc4:	1141                	addi	sp,sp,-16
    80000cc6:	e422                	sd	s0,8(sp)
    80000cc8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cca:	ca05                	beqz	a2,80000cfa <memcmp+0x36>
    80000ccc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cd0:	1682                	slli	a3,a3,0x20
    80000cd2:	9281                	srli	a3,a3,0x20
    80000cd4:	0685                	addi	a3,a3,1
    80000cd6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cd8:	00054783          	lbu	a5,0(a0)
    80000cdc:	0005c703          	lbu	a4,0(a1)
    80000ce0:	00e79863          	bne	a5,a4,80000cf0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000ce4:	0505                	addi	a0,a0,1
    80000ce6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000ce8:	fed518e3          	bne	a0,a3,80000cd8 <memcmp+0x14>
  }

  return 0;
    80000cec:	4501                	li	a0,0
    80000cee:	a019                	j	80000cf4 <memcmp+0x30>
      return *s1 - *s2;
    80000cf0:	40e7853b          	subw	a0,a5,a4
}
    80000cf4:	6422                	ld	s0,8(sp)
    80000cf6:	0141                	addi	sp,sp,16
    80000cf8:	8082                	ret
  return 0;
    80000cfa:	4501                	li	a0,0
    80000cfc:	bfe5                	j	80000cf4 <memcmp+0x30>

0000000080000cfe <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000cfe:	1141                	addi	sp,sp,-16
    80000d00:	e422                	sd	s0,8(sp)
    80000d02:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d04:	c205                	beqz	a2,80000d24 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d06:	02a5e263          	bltu	a1,a0,80000d2a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d0a:	1602                	slli	a2,a2,0x20
    80000d0c:	9201                	srli	a2,a2,0x20
    80000d0e:	00c587b3          	add	a5,a1,a2
{
    80000d12:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d14:	0585                	addi	a1,a1,1
    80000d16:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde229>
    80000d18:	fff5c683          	lbu	a3,-1(a1)
    80000d1c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d20:	feb79ae3          	bne	a5,a1,80000d14 <memmove+0x16>

  return dst;
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  if(s < d && s + n > d){
    80000d2a:	02061693          	slli	a3,a2,0x20
    80000d2e:	9281                	srli	a3,a3,0x20
    80000d30:	00d58733          	add	a4,a1,a3
    80000d34:	fce57be3          	bgeu	a0,a4,80000d0a <memmove+0xc>
    d += n;
    80000d38:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d3a:	fff6079b          	addiw	a5,a2,-1
    80000d3e:	1782                	slli	a5,a5,0x20
    80000d40:	9381                	srli	a5,a5,0x20
    80000d42:	fff7c793          	not	a5,a5
    80000d46:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d48:	177d                	addi	a4,a4,-1
    80000d4a:	16fd                	addi	a3,a3,-1
    80000d4c:	00074603          	lbu	a2,0(a4)
    80000d50:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d54:	fef71ae3          	bne	a4,a5,80000d48 <memmove+0x4a>
    80000d58:	b7f1                	j	80000d24 <memmove+0x26>

0000000080000d5a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d5a:	1141                	addi	sp,sp,-16
    80000d5c:	e406                	sd	ra,8(sp)
    80000d5e:	e022                	sd	s0,0(sp)
    80000d60:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d62:	f9dff0ef          	jal	80000cfe <memmove>
}
    80000d66:	60a2                	ld	ra,8(sp)
    80000d68:	6402                	ld	s0,0(sp)
    80000d6a:	0141                	addi	sp,sp,16
    80000d6c:	8082                	ret

0000000080000d6e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d6e:	1141                	addi	sp,sp,-16
    80000d70:	e422                	sd	s0,8(sp)
    80000d72:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d74:	ce11                	beqz	a2,80000d90 <strncmp+0x22>
    80000d76:	00054783          	lbu	a5,0(a0)
    80000d7a:	cf89                	beqz	a5,80000d94 <strncmp+0x26>
    80000d7c:	0005c703          	lbu	a4,0(a1)
    80000d80:	00f71a63          	bne	a4,a5,80000d94 <strncmp+0x26>
    n--, p++, q++;
    80000d84:	367d                	addiw	a2,a2,-1
    80000d86:	0505                	addi	a0,a0,1
    80000d88:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d8a:	f675                	bnez	a2,80000d76 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000d8c:	4501                	li	a0,0
    80000d8e:	a801                	j	80000d9e <strncmp+0x30>
    80000d90:	4501                	li	a0,0
    80000d92:	a031                	j	80000d9e <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000d94:	00054503          	lbu	a0,0(a0)
    80000d98:	0005c783          	lbu	a5,0(a1)
    80000d9c:	9d1d                	subw	a0,a0,a5
}
    80000d9e:	6422                	ld	s0,8(sp)
    80000da0:	0141                	addi	sp,sp,16
    80000da2:	8082                	ret

0000000080000da4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000da4:	1141                	addi	sp,sp,-16
    80000da6:	e422                	sd	s0,8(sp)
    80000da8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000daa:	87aa                	mv	a5,a0
    80000dac:	86b2                	mv	a3,a2
    80000dae:	367d                	addiw	a2,a2,-1
    80000db0:	02d05563          	blez	a3,80000dda <strncpy+0x36>
    80000db4:	0785                	addi	a5,a5,1
    80000db6:	0005c703          	lbu	a4,0(a1)
    80000dba:	fee78fa3          	sb	a4,-1(a5)
    80000dbe:	0585                	addi	a1,a1,1
    80000dc0:	f775                	bnez	a4,80000dac <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dc2:	873e                	mv	a4,a5
    80000dc4:	9fb5                	addw	a5,a5,a3
    80000dc6:	37fd                	addiw	a5,a5,-1
    80000dc8:	00c05963          	blez	a2,80000dda <strncpy+0x36>
    *s++ = 0;
    80000dcc:	0705                	addi	a4,a4,1
    80000dce:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000dd2:	40e786bb          	subw	a3,a5,a4
    80000dd6:	fed04be3          	bgtz	a3,80000dcc <strncpy+0x28>
  return os;
}
    80000dda:	6422                	ld	s0,8(sp)
    80000ddc:	0141                	addi	sp,sp,16
    80000dde:	8082                	ret

0000000080000de0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000de0:	1141                	addi	sp,sp,-16
    80000de2:	e422                	sd	s0,8(sp)
    80000de4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000de6:	02c05363          	blez	a2,80000e0c <safestrcpy+0x2c>
    80000dea:	fff6069b          	addiw	a3,a2,-1
    80000dee:	1682                	slli	a3,a3,0x20
    80000df0:	9281                	srli	a3,a3,0x20
    80000df2:	96ae                	add	a3,a3,a1
    80000df4:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000df6:	00d58963          	beq	a1,a3,80000e08 <safestrcpy+0x28>
    80000dfa:	0585                	addi	a1,a1,1
    80000dfc:	0785                	addi	a5,a5,1
    80000dfe:	fff5c703          	lbu	a4,-1(a1)
    80000e02:	fee78fa3          	sb	a4,-1(a5)
    80000e06:	fb65                	bnez	a4,80000df6 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e08:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e0c:	6422                	ld	s0,8(sp)
    80000e0e:	0141                	addi	sp,sp,16
    80000e10:	8082                	ret

0000000080000e12 <strlen>:

int
strlen(const char *s)
{
    80000e12:	1141                	addi	sp,sp,-16
    80000e14:	e422                	sd	s0,8(sp)
    80000e16:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e18:	00054783          	lbu	a5,0(a0)
    80000e1c:	cf91                	beqz	a5,80000e38 <strlen+0x26>
    80000e1e:	0505                	addi	a0,a0,1
    80000e20:	87aa                	mv	a5,a0
    80000e22:	86be                	mv	a3,a5
    80000e24:	0785                	addi	a5,a5,1
    80000e26:	fff7c703          	lbu	a4,-1(a5)
    80000e2a:	ff65                	bnez	a4,80000e22 <strlen+0x10>
    80000e2c:	40a6853b          	subw	a0,a3,a0
    80000e30:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e38:	4501                	li	a0,0
    80000e3a:	bfe5                	j	80000e32 <strlen+0x20>

0000000080000e3c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e3c:	1141                	addi	sp,sp,-16
    80000e3e:	e406                	sd	ra,8(sp)
    80000e40:	e022                	sd	s0,0(sp)
    80000e42:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e44:	3d7000ef          	jal	80001a1a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e48:	00007717          	auipc	a4,0x7
    80000e4c:	a2870713          	addi	a4,a4,-1496 # 80007870 <started>
  if(cpuid() == 0){
    80000e50:	c51d                	beqz	a0,80000e7e <main+0x42>
    while(started == 0)
    80000e52:	431c                	lw	a5,0(a4)
    80000e54:	2781                	sext.w	a5,a5
    80000e56:	dff5                	beqz	a5,80000e52 <main+0x16>
      ;
    __sync_synchronize();
    80000e58:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e5c:	3bf000ef          	jal	80001a1a <cpuid>
    80000e60:	85aa                	mv	a1,a0
    80000e62:	00006517          	auipc	a0,0x6
    80000e66:	23650513          	addi	a0,a0,566 # 80007098 <etext+0x98>
    80000e6a:	e90ff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000e6e:	088000ef          	jal	80000ef6 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e72:	7c2010ef          	jal	80002634 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e76:	7c2040ef          	jal	80005638 <plicinithart>
  }

  scheduler();        
    80000e7a:	04c010ef          	jal	80001ec6 <scheduler>
    consoleinit();
    80000e7e:	da6ff0ef          	jal	80000424 <consoleinit>
    printfinit();
    80000e82:	99bff0ef          	jal	8000081c <printfinit>
    printf("\n");
    80000e86:	00006517          	auipc	a0,0x6
    80000e8a:	1f250513          	addi	a0,a0,498 # 80007078 <etext+0x78>
    80000e8e:	e6cff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000e92:	00006517          	auipc	a0,0x6
    80000e96:	1ee50513          	addi	a0,a0,494 # 80007080 <etext+0x80>
    80000e9a:	e60ff0ef          	jal	800004fa <printf>
    rng_seed(get_current_time());
    80000e9e:	0d1000ef          	jal	8000176e <get_current_time>
    80000ea2:	0f7000ef          	jal	80001798 <rng_seed>
    printf("\n");
    80000ea6:	00006517          	auipc	a0,0x6
    80000eaa:	1d250513          	addi	a0,a0,466 # 80007078 <etext+0x78>
    80000eae:	e4cff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000eb2:	c19ff0ef          	jal	80000aca <kinit>
    kvminit();       // create kernel page table
    80000eb6:	2dc000ef          	jal	80001192 <kvminit>
    kvminithart();   // turn on paging
    80000eba:	03c000ef          	jal	80000ef6 <kvminithart>
    procinit();      // process table
    80000ebe:	2a7000ef          	jal	80001964 <procinit>
    trapinit();      // trap vectors
    80000ec2:	74e010ef          	jal	80002610 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ec6:	76e010ef          	jal	80002634 <trapinithart>
    plicinit();      // set up interrupt controller
    80000eca:	754040ef          	jal	8000561e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ece:	76a040ef          	jal	80005638 <plicinithart>
    binit();         // buffer cache
    80000ed2:	62f010ef          	jal	80002d00 <binit>
    iinit();         // inode table
    80000ed6:	3b4020ef          	jal	8000328a <iinit>
    fileinit();      // file table
    80000eda:	2a6030ef          	jal	80004180 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ede:	04b040ef          	jal	80005728 <virtio_disk_init>
    userinit();      // first user process
    80000ee2:	631000ef          	jal	80001d12 <userinit>
    __sync_synchronize();
    80000ee6:	0ff0000f          	fence
    started = 1;
    80000eea:	4785                	li	a5,1
    80000eec:	00007717          	auipc	a4,0x7
    80000ef0:	98f72223          	sw	a5,-1660(a4) # 80007870 <started>
    80000ef4:	b759                	j	80000e7a <main+0x3e>

0000000080000ef6 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000ef6:	1141                	addi	sp,sp,-16
    80000ef8:	e422                	sd	s0,8(sp)
    80000efa:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000efc:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f00:	00007797          	auipc	a5,0x7
    80000f04:	9787b783          	ld	a5,-1672(a5) # 80007878 <kernel_pagetable>
    80000f08:	83b1                	srli	a5,a5,0xc
    80000f0a:	577d                	li	a4,-1
    80000f0c:	177e                	slli	a4,a4,0x3f
    80000f0e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f10:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f14:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f18:	6422                	ld	s0,8(sp)
    80000f1a:	0141                	addi	sp,sp,16
    80000f1c:	8082                	ret

0000000080000f1e <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f1e:	7139                	addi	sp,sp,-64
    80000f20:	fc06                	sd	ra,56(sp)
    80000f22:	f822                	sd	s0,48(sp)
    80000f24:	f426                	sd	s1,40(sp)
    80000f26:	f04a                	sd	s2,32(sp)
    80000f28:	ec4e                	sd	s3,24(sp)
    80000f2a:	e852                	sd	s4,16(sp)
    80000f2c:	e456                	sd	s5,8(sp)
    80000f2e:	e05a                	sd	s6,0(sp)
    80000f30:	0080                	addi	s0,sp,64
    80000f32:	84aa                	mv	s1,a0
    80000f34:	89ae                	mv	s3,a1
    80000f36:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f38:	57fd                	li	a5,-1
    80000f3a:	83e9                	srli	a5,a5,0x1a
    80000f3c:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f3e:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f40:	02b7fc63          	bgeu	a5,a1,80000f78 <walk+0x5a>
    panic("walk");
    80000f44:	00006517          	auipc	a0,0x6
    80000f48:	16c50513          	addi	a0,a0,364 # 800070b0 <etext+0xb0>
    80000f4c:	895ff0ef          	jal	800007e0 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f50:	060a8263          	beqz	s5,80000fb4 <walk+0x96>
    80000f54:	babff0ef          	jal	80000afe <kalloc>
    80000f58:	84aa                	mv	s1,a0
    80000f5a:	c139                	beqz	a0,80000fa0 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f5c:	6605                	lui	a2,0x1
    80000f5e:	4581                	li	a1,0
    80000f60:	d43ff0ef          	jal	80000ca2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f64:	00c4d793          	srli	a5,s1,0xc
    80000f68:	07aa                	slli	a5,a5,0xa
    80000f6a:	0017e793          	ori	a5,a5,1
    80000f6e:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f72:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde21f>
    80000f74:	036a0063          	beq	s4,s6,80000f94 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f78:	0149d933          	srl	s2,s3,s4
    80000f7c:	1ff97913          	andi	s2,s2,511
    80000f80:	090e                	slli	s2,s2,0x3
    80000f82:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f84:	00093483          	ld	s1,0(s2)
    80000f88:	0014f793          	andi	a5,s1,1
    80000f8c:	d3f1                	beqz	a5,80000f50 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f8e:	80a9                	srli	s1,s1,0xa
    80000f90:	04b2                	slli	s1,s1,0xc
    80000f92:	b7c5                	j	80000f72 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f94:	00c9d513          	srli	a0,s3,0xc
    80000f98:	1ff57513          	andi	a0,a0,511
    80000f9c:	050e                	slli	a0,a0,0x3
    80000f9e:	9526                	add	a0,a0,s1
}
    80000fa0:	70e2                	ld	ra,56(sp)
    80000fa2:	7442                	ld	s0,48(sp)
    80000fa4:	74a2                	ld	s1,40(sp)
    80000fa6:	7902                	ld	s2,32(sp)
    80000fa8:	69e2                	ld	s3,24(sp)
    80000faa:	6a42                	ld	s4,16(sp)
    80000fac:	6aa2                	ld	s5,8(sp)
    80000fae:	6b02                	ld	s6,0(sp)
    80000fb0:	6121                	addi	sp,sp,64
    80000fb2:	8082                	ret
        return 0;
    80000fb4:	4501                	li	a0,0
    80000fb6:	b7ed                	j	80000fa0 <walk+0x82>

0000000080000fb8 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fb8:	57fd                	li	a5,-1
    80000fba:	83e9                	srli	a5,a5,0x1a
    80000fbc:	00b7f463          	bgeu	a5,a1,80000fc4 <walkaddr+0xc>
    return 0;
    80000fc0:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fc2:	8082                	ret
{
    80000fc4:	1141                	addi	sp,sp,-16
    80000fc6:	e406                	sd	ra,8(sp)
    80000fc8:	e022                	sd	s0,0(sp)
    80000fca:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fcc:	4601                	li	a2,0
    80000fce:	f51ff0ef          	jal	80000f1e <walk>
  if(pte == 0)
    80000fd2:	c105                	beqz	a0,80000ff2 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000fd4:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000fd6:	0117f693          	andi	a3,a5,17
    80000fda:	4745                	li	a4,17
    return 0;
    80000fdc:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000fde:	00e68663          	beq	a3,a4,80000fea <walkaddr+0x32>
}
    80000fe2:	60a2                	ld	ra,8(sp)
    80000fe4:	6402                	ld	s0,0(sp)
    80000fe6:	0141                	addi	sp,sp,16
    80000fe8:	8082                	ret
  pa = PTE2PA(*pte);
    80000fea:	83a9                	srli	a5,a5,0xa
    80000fec:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000ff0:	bfcd                	j	80000fe2 <walkaddr+0x2a>
    return 0;
    80000ff2:	4501                	li	a0,0
    80000ff4:	b7fd                	j	80000fe2 <walkaddr+0x2a>

0000000080000ff6 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000ff6:	715d                	addi	sp,sp,-80
    80000ff8:	e486                	sd	ra,72(sp)
    80000ffa:	e0a2                	sd	s0,64(sp)
    80000ffc:	fc26                	sd	s1,56(sp)
    80000ffe:	f84a                	sd	s2,48(sp)
    80001000:	f44e                	sd	s3,40(sp)
    80001002:	f052                	sd	s4,32(sp)
    80001004:	ec56                	sd	s5,24(sp)
    80001006:	e85a                	sd	s6,16(sp)
    80001008:	e45e                	sd	s7,8(sp)
    8000100a:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000100c:	03459793          	slli	a5,a1,0x34
    80001010:	e7a9                	bnez	a5,8000105a <mappages+0x64>
    80001012:	8aaa                	mv	s5,a0
    80001014:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001016:	03461793          	slli	a5,a2,0x34
    8000101a:	e7b1                	bnez	a5,80001066 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    8000101c:	ca39                	beqz	a2,80001072 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000101e:	77fd                	lui	a5,0xfffff
    80001020:	963e                	add	a2,a2,a5
    80001022:	00b609b3          	add	s3,a2,a1
  a = va;
    80001026:	892e                	mv	s2,a1
    80001028:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000102c:	6b85                	lui	s7,0x1
    8000102e:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001032:	4605                	li	a2,1
    80001034:	85ca                	mv	a1,s2
    80001036:	8556                	mv	a0,s5
    80001038:	ee7ff0ef          	jal	80000f1e <walk>
    8000103c:	c539                	beqz	a0,8000108a <mappages+0x94>
    if(*pte & PTE_V)
    8000103e:	611c                	ld	a5,0(a0)
    80001040:	8b85                	andi	a5,a5,1
    80001042:	ef95                	bnez	a5,8000107e <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001044:	80b1                	srli	s1,s1,0xc
    80001046:	04aa                	slli	s1,s1,0xa
    80001048:	0164e4b3          	or	s1,s1,s6
    8000104c:	0014e493          	ori	s1,s1,1
    80001050:	e104                	sd	s1,0(a0)
    if(a == last)
    80001052:	05390863          	beq	s2,s3,800010a2 <mappages+0xac>
    a += PGSIZE;
    80001056:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001058:	bfd9                	j	8000102e <mappages+0x38>
    panic("mappages: va not aligned");
    8000105a:	00006517          	auipc	a0,0x6
    8000105e:	05e50513          	addi	a0,a0,94 # 800070b8 <etext+0xb8>
    80001062:	f7eff0ef          	jal	800007e0 <panic>
    panic("mappages: size not aligned");
    80001066:	00006517          	auipc	a0,0x6
    8000106a:	07250513          	addi	a0,a0,114 # 800070d8 <etext+0xd8>
    8000106e:	f72ff0ef          	jal	800007e0 <panic>
    panic("mappages: size");
    80001072:	00006517          	auipc	a0,0x6
    80001076:	08650513          	addi	a0,a0,134 # 800070f8 <etext+0xf8>
    8000107a:	f66ff0ef          	jal	800007e0 <panic>
      panic("mappages: remap");
    8000107e:	00006517          	auipc	a0,0x6
    80001082:	08a50513          	addi	a0,a0,138 # 80007108 <etext+0x108>
    80001086:	f5aff0ef          	jal	800007e0 <panic>
      return -1;
    8000108a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000108c:	60a6                	ld	ra,72(sp)
    8000108e:	6406                	ld	s0,64(sp)
    80001090:	74e2                	ld	s1,56(sp)
    80001092:	7942                	ld	s2,48(sp)
    80001094:	79a2                	ld	s3,40(sp)
    80001096:	7a02                	ld	s4,32(sp)
    80001098:	6ae2                	ld	s5,24(sp)
    8000109a:	6b42                	ld	s6,16(sp)
    8000109c:	6ba2                	ld	s7,8(sp)
    8000109e:	6161                	addi	sp,sp,80
    800010a0:	8082                	ret
  return 0;
    800010a2:	4501                	li	a0,0
    800010a4:	b7e5                	j	8000108c <mappages+0x96>

00000000800010a6 <kvmmap>:
{
    800010a6:	1141                	addi	sp,sp,-16
    800010a8:	e406                	sd	ra,8(sp)
    800010aa:	e022                	sd	s0,0(sp)
    800010ac:	0800                	addi	s0,sp,16
    800010ae:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010b0:	86b2                	mv	a3,a2
    800010b2:	863e                	mv	a2,a5
    800010b4:	f43ff0ef          	jal	80000ff6 <mappages>
    800010b8:	e509                	bnez	a0,800010c2 <kvmmap+0x1c>
}
    800010ba:	60a2                	ld	ra,8(sp)
    800010bc:	6402                	ld	s0,0(sp)
    800010be:	0141                	addi	sp,sp,16
    800010c0:	8082                	ret
    panic("kvmmap");
    800010c2:	00006517          	auipc	a0,0x6
    800010c6:	05650513          	addi	a0,a0,86 # 80007118 <etext+0x118>
    800010ca:	f16ff0ef          	jal	800007e0 <panic>

00000000800010ce <kvmmake>:
{
    800010ce:	1101                	addi	sp,sp,-32
    800010d0:	ec06                	sd	ra,24(sp)
    800010d2:	e822                	sd	s0,16(sp)
    800010d4:	e426                	sd	s1,8(sp)
    800010d6:	e04a                	sd	s2,0(sp)
    800010d8:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010da:	a25ff0ef          	jal	80000afe <kalloc>
    800010de:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010e0:	6605                	lui	a2,0x1
    800010e2:	4581                	li	a1,0
    800010e4:	bbfff0ef          	jal	80000ca2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800010e8:	4719                	li	a4,6
    800010ea:	6685                	lui	a3,0x1
    800010ec:	10000637          	lui	a2,0x10000
    800010f0:	100005b7          	lui	a1,0x10000
    800010f4:	8526                	mv	a0,s1
    800010f6:	fb1ff0ef          	jal	800010a6 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800010fa:	4719                	li	a4,6
    800010fc:	6685                	lui	a3,0x1
    800010fe:	10001637          	lui	a2,0x10001
    80001102:	100015b7          	lui	a1,0x10001
    80001106:	8526                	mv	a0,s1
    80001108:	f9fff0ef          	jal	800010a6 <kvmmap>
  kvmmap(kpgtbl, GOLDFISH_RTC, GOLDFISH_RTC, PGSIZE, PTE_R | PTE_W);
    8000110c:	4719                	li	a4,6
    8000110e:	6685                	lui	a3,0x1
    80001110:	00101637          	lui	a2,0x101
    80001114:	001015b7          	lui	a1,0x101
    80001118:	8526                	mv	a0,s1
    8000111a:	f8dff0ef          	jal	800010a6 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000111e:	4719                	li	a4,6
    80001120:	040006b7          	lui	a3,0x4000
    80001124:	0c000637          	lui	a2,0xc000
    80001128:	0c0005b7          	lui	a1,0xc000
    8000112c:	8526                	mv	a0,s1
    8000112e:	f79ff0ef          	jal	800010a6 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001132:	00006917          	auipc	s2,0x6
    80001136:	ece90913          	addi	s2,s2,-306 # 80007000 <etext>
    8000113a:	4729                	li	a4,10
    8000113c:	80006697          	auipc	a3,0x80006
    80001140:	ec468693          	addi	a3,a3,-316 # 7000 <_entry-0x7fff9000>
    80001144:	4605                	li	a2,1
    80001146:	067e                	slli	a2,a2,0x1f
    80001148:	85b2                	mv	a1,a2
    8000114a:	8526                	mv	a0,s1
    8000114c:	f5bff0ef          	jal	800010a6 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001150:	46c5                	li	a3,17
    80001152:	06ee                	slli	a3,a3,0x1b
    80001154:	4719                	li	a4,6
    80001156:	412686b3          	sub	a3,a3,s2
    8000115a:	864a                	mv	a2,s2
    8000115c:	85ca                	mv	a1,s2
    8000115e:	8526                	mv	a0,s1
    80001160:	f47ff0ef          	jal	800010a6 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001164:	4729                	li	a4,10
    80001166:	6685                	lui	a3,0x1
    80001168:	00005617          	auipc	a2,0x5
    8000116c:	e9860613          	addi	a2,a2,-360 # 80006000 <_trampoline>
    80001170:	040005b7          	lui	a1,0x4000
    80001174:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001176:	05b2                	slli	a1,a1,0xc
    80001178:	8526                	mv	a0,s1
    8000117a:	f2dff0ef          	jal	800010a6 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000117e:	8526                	mv	a0,s1
    80001180:	74c000ef          	jal	800018cc <proc_mapstacks>
}
    80001184:	8526                	mv	a0,s1
    80001186:	60e2                	ld	ra,24(sp)
    80001188:	6442                	ld	s0,16(sp)
    8000118a:	64a2                	ld	s1,8(sp)
    8000118c:	6902                	ld	s2,0(sp)
    8000118e:	6105                	addi	sp,sp,32
    80001190:	8082                	ret

0000000080001192 <kvminit>:
{
    80001192:	1141                	addi	sp,sp,-16
    80001194:	e406                	sd	ra,8(sp)
    80001196:	e022                	sd	s0,0(sp)
    80001198:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000119a:	f35ff0ef          	jal	800010ce <kvmmake>
    8000119e:	00006797          	auipc	a5,0x6
    800011a2:	6ca7bd23          	sd	a0,1754(a5) # 80007878 <kernel_pagetable>
}
    800011a6:	60a2                	ld	ra,8(sp)
    800011a8:	6402                	ld	s0,0(sp)
    800011aa:	0141                	addi	sp,sp,16
    800011ac:	8082                	ret

00000000800011ae <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800011ae:	1101                	addi	sp,sp,-32
    800011b0:	ec06                	sd	ra,24(sp)
    800011b2:	e822                	sd	s0,16(sp)
    800011b4:	e426                	sd	s1,8(sp)
    800011b6:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800011b8:	947ff0ef          	jal	80000afe <kalloc>
    800011bc:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800011be:	c509                	beqz	a0,800011c8 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800011c0:	6605                	lui	a2,0x1
    800011c2:	4581                	li	a1,0
    800011c4:	adfff0ef          	jal	80000ca2 <memset>
  return pagetable;
}
    800011c8:	8526                	mv	a0,s1
    800011ca:	60e2                	ld	ra,24(sp)
    800011cc:	6442                	ld	s0,16(sp)
    800011ce:	64a2                	ld	s1,8(sp)
    800011d0:	6105                	addi	sp,sp,32
    800011d2:	8082                	ret

00000000800011d4 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011d4:	7139                	addi	sp,sp,-64
    800011d6:	fc06                	sd	ra,56(sp)
    800011d8:	f822                	sd	s0,48(sp)
    800011da:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011dc:	03459793          	slli	a5,a1,0x34
    800011e0:	e38d                	bnez	a5,80001202 <uvmunmap+0x2e>
    800011e2:	f04a                	sd	s2,32(sp)
    800011e4:	ec4e                	sd	s3,24(sp)
    800011e6:	e852                	sd	s4,16(sp)
    800011e8:	e456                	sd	s5,8(sp)
    800011ea:	e05a                	sd	s6,0(sp)
    800011ec:	8a2a                	mv	s4,a0
    800011ee:	892e                	mv	s2,a1
    800011f0:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011f2:	0632                	slli	a2,a2,0xc
    800011f4:	00b609b3          	add	s3,a2,a1
    800011f8:	6b05                	lui	s6,0x1
    800011fa:	0535f963          	bgeu	a1,s3,8000124c <uvmunmap+0x78>
    800011fe:	f426                	sd	s1,40(sp)
    80001200:	a015                	j	80001224 <uvmunmap+0x50>
    80001202:	f426                	sd	s1,40(sp)
    80001204:	f04a                	sd	s2,32(sp)
    80001206:	ec4e                	sd	s3,24(sp)
    80001208:	e852                	sd	s4,16(sp)
    8000120a:	e456                	sd	s5,8(sp)
    8000120c:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    8000120e:	00006517          	auipc	a0,0x6
    80001212:	f1250513          	addi	a0,a0,-238 # 80007120 <etext+0x120>
    80001216:	dcaff0ef          	jal	800007e0 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000121a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000121e:	995a                	add	s2,s2,s6
    80001220:	03397563          	bgeu	s2,s3,8000124a <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001224:	4601                	li	a2,0
    80001226:	85ca                	mv	a1,s2
    80001228:	8552                	mv	a0,s4
    8000122a:	cf5ff0ef          	jal	80000f1e <walk>
    8000122e:	84aa                	mv	s1,a0
    80001230:	d57d                	beqz	a0,8000121e <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    80001232:	611c                	ld	a5,0(a0)
    80001234:	0017f713          	andi	a4,a5,1
    80001238:	d37d                	beqz	a4,8000121e <uvmunmap+0x4a>
    if(do_free){
    8000123a:	fe0a80e3          	beqz	s5,8000121a <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    8000123e:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    80001240:	00c79513          	slli	a0,a5,0xc
    80001244:	fd8ff0ef          	jal	80000a1c <kfree>
    80001248:	bfc9                	j	8000121a <uvmunmap+0x46>
    8000124a:	74a2                	ld	s1,40(sp)
    8000124c:	7902                	ld	s2,32(sp)
    8000124e:	69e2                	ld	s3,24(sp)
    80001250:	6a42                	ld	s4,16(sp)
    80001252:	6aa2                	ld	s5,8(sp)
    80001254:	6b02                	ld	s6,0(sp)
  }
}
    80001256:	70e2                	ld	ra,56(sp)
    80001258:	7442                	ld	s0,48(sp)
    8000125a:	6121                	addi	sp,sp,64
    8000125c:	8082                	ret

000000008000125e <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000125e:	1101                	addi	sp,sp,-32
    80001260:	ec06                	sd	ra,24(sp)
    80001262:	e822                	sd	s0,16(sp)
    80001264:	e426                	sd	s1,8(sp)
    80001266:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001268:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000126a:	00b67d63          	bgeu	a2,a1,80001284 <uvmdealloc+0x26>
    8000126e:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001270:	6785                	lui	a5,0x1
    80001272:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001274:	00f60733          	add	a4,a2,a5
    80001278:	76fd                	lui	a3,0xfffff
    8000127a:	8f75                	and	a4,a4,a3
    8000127c:	97ae                	add	a5,a5,a1
    8000127e:	8ff5                	and	a5,a5,a3
    80001280:	00f76863          	bltu	a4,a5,80001290 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001284:	8526                	mv	a0,s1
    80001286:	60e2                	ld	ra,24(sp)
    80001288:	6442                	ld	s0,16(sp)
    8000128a:	64a2                	ld	s1,8(sp)
    8000128c:	6105                	addi	sp,sp,32
    8000128e:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001290:	8f99                	sub	a5,a5,a4
    80001292:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001294:	4685                	li	a3,1
    80001296:	0007861b          	sext.w	a2,a5
    8000129a:	85ba                	mv	a1,a4
    8000129c:	f39ff0ef          	jal	800011d4 <uvmunmap>
    800012a0:	b7d5                	j	80001284 <uvmdealloc+0x26>

00000000800012a2 <uvmalloc>:
  if(newsz < oldsz)
    800012a2:	08b66f63          	bltu	a2,a1,80001340 <uvmalloc+0x9e>
{
    800012a6:	7139                	addi	sp,sp,-64
    800012a8:	fc06                	sd	ra,56(sp)
    800012aa:	f822                	sd	s0,48(sp)
    800012ac:	ec4e                	sd	s3,24(sp)
    800012ae:	e852                	sd	s4,16(sp)
    800012b0:	e456                	sd	s5,8(sp)
    800012b2:	0080                	addi	s0,sp,64
    800012b4:	8aaa                	mv	s5,a0
    800012b6:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800012b8:	6785                	lui	a5,0x1
    800012ba:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012bc:	95be                	add	a1,a1,a5
    800012be:	77fd                	lui	a5,0xfffff
    800012c0:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012c4:	08c9f063          	bgeu	s3,a2,80001344 <uvmalloc+0xa2>
    800012c8:	f426                	sd	s1,40(sp)
    800012ca:	f04a                	sd	s2,32(sp)
    800012cc:	e05a                	sd	s6,0(sp)
    800012ce:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012d0:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800012d4:	82bff0ef          	jal	80000afe <kalloc>
    800012d8:	84aa                	mv	s1,a0
    if(mem == 0){
    800012da:	c515                	beqz	a0,80001306 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800012dc:	6605                	lui	a2,0x1
    800012de:	4581                	li	a1,0
    800012e0:	9c3ff0ef          	jal	80000ca2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012e4:	875a                	mv	a4,s6
    800012e6:	86a6                	mv	a3,s1
    800012e8:	6605                	lui	a2,0x1
    800012ea:	85ca                	mv	a1,s2
    800012ec:	8556                	mv	a0,s5
    800012ee:	d09ff0ef          	jal	80000ff6 <mappages>
    800012f2:	e915                	bnez	a0,80001326 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012f4:	6785                	lui	a5,0x1
    800012f6:	993e                	add	s2,s2,a5
    800012f8:	fd496ee3          	bltu	s2,s4,800012d4 <uvmalloc+0x32>
  return newsz;
    800012fc:	8552                	mv	a0,s4
    800012fe:	74a2                	ld	s1,40(sp)
    80001300:	7902                	ld	s2,32(sp)
    80001302:	6b02                	ld	s6,0(sp)
    80001304:	a811                	j	80001318 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    80001306:	864e                	mv	a2,s3
    80001308:	85ca                	mv	a1,s2
    8000130a:	8556                	mv	a0,s5
    8000130c:	f53ff0ef          	jal	8000125e <uvmdealloc>
      return 0;
    80001310:	4501                	li	a0,0
    80001312:	74a2                	ld	s1,40(sp)
    80001314:	7902                	ld	s2,32(sp)
    80001316:	6b02                	ld	s6,0(sp)
}
    80001318:	70e2                	ld	ra,56(sp)
    8000131a:	7442                	ld	s0,48(sp)
    8000131c:	69e2                	ld	s3,24(sp)
    8000131e:	6a42                	ld	s4,16(sp)
    80001320:	6aa2                	ld	s5,8(sp)
    80001322:	6121                	addi	sp,sp,64
    80001324:	8082                	ret
      kfree(mem);
    80001326:	8526                	mv	a0,s1
    80001328:	ef4ff0ef          	jal	80000a1c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000132c:	864e                	mv	a2,s3
    8000132e:	85ca                	mv	a1,s2
    80001330:	8556                	mv	a0,s5
    80001332:	f2dff0ef          	jal	8000125e <uvmdealloc>
      return 0;
    80001336:	4501                	li	a0,0
    80001338:	74a2                	ld	s1,40(sp)
    8000133a:	7902                	ld	s2,32(sp)
    8000133c:	6b02                	ld	s6,0(sp)
    8000133e:	bfe9                	j	80001318 <uvmalloc+0x76>
    return oldsz;
    80001340:	852e                	mv	a0,a1
}
    80001342:	8082                	ret
  return newsz;
    80001344:	8532                	mv	a0,a2
    80001346:	bfc9                	j	80001318 <uvmalloc+0x76>

0000000080001348 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001348:	7179                	addi	sp,sp,-48
    8000134a:	f406                	sd	ra,40(sp)
    8000134c:	f022                	sd	s0,32(sp)
    8000134e:	ec26                	sd	s1,24(sp)
    80001350:	e84a                	sd	s2,16(sp)
    80001352:	e44e                	sd	s3,8(sp)
    80001354:	e052                	sd	s4,0(sp)
    80001356:	1800                	addi	s0,sp,48
    80001358:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000135a:	84aa                	mv	s1,a0
    8000135c:	6905                	lui	s2,0x1
    8000135e:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001360:	4985                	li	s3,1
    80001362:	a819                	j	80001378 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001364:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001366:	00c79513          	slli	a0,a5,0xc
    8000136a:	fdfff0ef          	jal	80001348 <freewalk>
      pagetable[i] = 0;
    8000136e:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001372:	04a1                	addi	s1,s1,8
    80001374:	01248f63          	beq	s1,s2,80001392 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001378:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000137a:	00f7f713          	andi	a4,a5,15
    8000137e:	ff3703e3          	beq	a4,s3,80001364 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001382:	8b85                	andi	a5,a5,1
    80001384:	d7fd                	beqz	a5,80001372 <freewalk+0x2a>
      panic("freewalk: leaf");
    80001386:	00006517          	auipc	a0,0x6
    8000138a:	db250513          	addi	a0,a0,-590 # 80007138 <etext+0x138>
    8000138e:	c52ff0ef          	jal	800007e0 <panic>
    }
  }
  kfree((void*)pagetable);
    80001392:	8552                	mv	a0,s4
    80001394:	e88ff0ef          	jal	80000a1c <kfree>
}
    80001398:	70a2                	ld	ra,40(sp)
    8000139a:	7402                	ld	s0,32(sp)
    8000139c:	64e2                	ld	s1,24(sp)
    8000139e:	6942                	ld	s2,16(sp)
    800013a0:	69a2                	ld	s3,8(sp)
    800013a2:	6a02                	ld	s4,0(sp)
    800013a4:	6145                	addi	sp,sp,48
    800013a6:	8082                	ret

00000000800013a8 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800013a8:	1101                	addi	sp,sp,-32
    800013aa:	ec06                	sd	ra,24(sp)
    800013ac:	e822                	sd	s0,16(sp)
    800013ae:	e426                	sd	s1,8(sp)
    800013b0:	1000                	addi	s0,sp,32
    800013b2:	84aa                	mv	s1,a0
  if(sz > 0)
    800013b4:	e989                	bnez	a1,800013c6 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800013b6:	8526                	mv	a0,s1
    800013b8:	f91ff0ef          	jal	80001348 <freewalk>
}
    800013bc:	60e2                	ld	ra,24(sp)
    800013be:	6442                	ld	s0,16(sp)
    800013c0:	64a2                	ld	s1,8(sp)
    800013c2:	6105                	addi	sp,sp,32
    800013c4:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800013c6:	6785                	lui	a5,0x1
    800013c8:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013ca:	95be                	add	a1,a1,a5
    800013cc:	4685                	li	a3,1
    800013ce:	00c5d613          	srli	a2,a1,0xc
    800013d2:	4581                	li	a1,0
    800013d4:	e01ff0ef          	jal	800011d4 <uvmunmap>
    800013d8:	bff9                	j	800013b6 <uvmfree+0xe>

00000000800013da <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800013da:	ce49                	beqz	a2,80001474 <uvmcopy+0x9a>
{
    800013dc:	715d                	addi	sp,sp,-80
    800013de:	e486                	sd	ra,72(sp)
    800013e0:	e0a2                	sd	s0,64(sp)
    800013e2:	fc26                	sd	s1,56(sp)
    800013e4:	f84a                	sd	s2,48(sp)
    800013e6:	f44e                	sd	s3,40(sp)
    800013e8:	f052                	sd	s4,32(sp)
    800013ea:	ec56                	sd	s5,24(sp)
    800013ec:	e85a                	sd	s6,16(sp)
    800013ee:	e45e                	sd	s7,8(sp)
    800013f0:	0880                	addi	s0,sp,80
    800013f2:	8aaa                	mv	s5,a0
    800013f4:	8b2e                	mv	s6,a1
    800013f6:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800013f8:	4481                	li	s1,0
    800013fa:	a029                	j	80001404 <uvmcopy+0x2a>
    800013fc:	6785                	lui	a5,0x1
    800013fe:	94be                	add	s1,s1,a5
    80001400:	0544fe63          	bgeu	s1,s4,8000145c <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    80001404:	4601                	li	a2,0
    80001406:	85a6                	mv	a1,s1
    80001408:	8556                	mv	a0,s5
    8000140a:	b15ff0ef          	jal	80000f1e <walk>
    8000140e:	d57d                	beqz	a0,800013fc <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    80001410:	6118                	ld	a4,0(a0)
    80001412:	00177793          	andi	a5,a4,1
    80001416:	d3fd                	beqz	a5,800013fc <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    80001418:	00a75593          	srli	a1,a4,0xa
    8000141c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001420:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    80001424:	edaff0ef          	jal	80000afe <kalloc>
    80001428:	89aa                	mv	s3,a0
    8000142a:	c105                	beqz	a0,8000144a <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000142c:	6605                	lui	a2,0x1
    8000142e:	85de                	mv	a1,s7
    80001430:	8cfff0ef          	jal	80000cfe <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001434:	874a                	mv	a4,s2
    80001436:	86ce                	mv	a3,s3
    80001438:	6605                	lui	a2,0x1
    8000143a:	85a6                	mv	a1,s1
    8000143c:	855a                	mv	a0,s6
    8000143e:	bb9ff0ef          	jal	80000ff6 <mappages>
    80001442:	dd4d                	beqz	a0,800013fc <uvmcopy+0x22>
      kfree(mem);
    80001444:	854e                	mv	a0,s3
    80001446:	dd6ff0ef          	jal	80000a1c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000144a:	4685                	li	a3,1
    8000144c:	00c4d613          	srli	a2,s1,0xc
    80001450:	4581                	li	a1,0
    80001452:	855a                	mv	a0,s6
    80001454:	d81ff0ef          	jal	800011d4 <uvmunmap>
  return -1;
    80001458:	557d                	li	a0,-1
    8000145a:	a011                	j	8000145e <uvmcopy+0x84>
  return 0;
    8000145c:	4501                	li	a0,0
}
    8000145e:	60a6                	ld	ra,72(sp)
    80001460:	6406                	ld	s0,64(sp)
    80001462:	74e2                	ld	s1,56(sp)
    80001464:	7942                	ld	s2,48(sp)
    80001466:	79a2                	ld	s3,40(sp)
    80001468:	7a02                	ld	s4,32(sp)
    8000146a:	6ae2                	ld	s5,24(sp)
    8000146c:	6b42                	ld	s6,16(sp)
    8000146e:	6ba2                	ld	s7,8(sp)
    80001470:	6161                	addi	sp,sp,80
    80001472:	8082                	ret
  return 0;
    80001474:	4501                	li	a0,0
}
    80001476:	8082                	ret

0000000080001478 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001478:	1141                	addi	sp,sp,-16
    8000147a:	e406                	sd	ra,8(sp)
    8000147c:	e022                	sd	s0,0(sp)
    8000147e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001480:	4601                	li	a2,0
    80001482:	a9dff0ef          	jal	80000f1e <walk>
  if(pte == 0)
    80001486:	c901                	beqz	a0,80001496 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001488:	611c                	ld	a5,0(a0)
    8000148a:	9bbd                	andi	a5,a5,-17
    8000148c:	e11c                	sd	a5,0(a0)
}
    8000148e:	60a2                	ld	ra,8(sp)
    80001490:	6402                	ld	s0,0(sp)
    80001492:	0141                	addi	sp,sp,16
    80001494:	8082                	ret
    panic("uvmclear");
    80001496:	00006517          	auipc	a0,0x6
    8000149a:	cb250513          	addi	a0,a0,-846 # 80007148 <etext+0x148>
    8000149e:	b42ff0ef          	jal	800007e0 <panic>

00000000800014a2 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800014a2:	c6dd                	beqz	a3,80001550 <copyinstr+0xae>
{
    800014a4:	715d                	addi	sp,sp,-80
    800014a6:	e486                	sd	ra,72(sp)
    800014a8:	e0a2                	sd	s0,64(sp)
    800014aa:	fc26                	sd	s1,56(sp)
    800014ac:	f84a                	sd	s2,48(sp)
    800014ae:	f44e                	sd	s3,40(sp)
    800014b0:	f052                	sd	s4,32(sp)
    800014b2:	ec56                	sd	s5,24(sp)
    800014b4:	e85a                	sd	s6,16(sp)
    800014b6:	e45e                	sd	s7,8(sp)
    800014b8:	0880                	addi	s0,sp,80
    800014ba:	8a2a                	mv	s4,a0
    800014bc:	8b2e                	mv	s6,a1
    800014be:	8bb2                	mv	s7,a2
    800014c0:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800014c2:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800014c4:	6985                	lui	s3,0x1
    800014c6:	a825                	j	800014fe <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800014c8:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800014cc:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800014ce:	37fd                	addiw	a5,a5,-1
    800014d0:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800014d4:	60a6                	ld	ra,72(sp)
    800014d6:	6406                	ld	s0,64(sp)
    800014d8:	74e2                	ld	s1,56(sp)
    800014da:	7942                	ld	s2,48(sp)
    800014dc:	79a2                	ld	s3,40(sp)
    800014de:	7a02                	ld	s4,32(sp)
    800014e0:	6ae2                	ld	s5,24(sp)
    800014e2:	6b42                	ld	s6,16(sp)
    800014e4:	6ba2                	ld	s7,8(sp)
    800014e6:	6161                	addi	sp,sp,80
    800014e8:	8082                	ret
    800014ea:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800014ee:	9742                	add	a4,a4,a6
      --max;
    800014f0:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    800014f4:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    800014f8:	04e58463          	beq	a1,a4,80001540 <copyinstr+0x9e>
{
    800014fc:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    800014fe:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001502:	85a6                	mv	a1,s1
    80001504:	8552                	mv	a0,s4
    80001506:	ab3ff0ef          	jal	80000fb8 <walkaddr>
    if(pa0 == 0)
    8000150a:	cd0d                	beqz	a0,80001544 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    8000150c:	417486b3          	sub	a3,s1,s7
    80001510:	96ce                	add	a3,a3,s3
    if(n > max)
    80001512:	00d97363          	bgeu	s2,a3,80001518 <copyinstr+0x76>
    80001516:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001518:	955e                	add	a0,a0,s7
    8000151a:	8d05                	sub	a0,a0,s1
    while(n > 0){
    8000151c:	c695                	beqz	a3,80001548 <copyinstr+0xa6>
    8000151e:	87da                	mv	a5,s6
    80001520:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001522:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001526:	96da                	add	a3,a3,s6
    80001528:	85be                	mv	a1,a5
      if(*p == '\0'){
    8000152a:	00f60733          	add	a4,a2,a5
    8000152e:	00074703          	lbu	a4,0(a4)
    80001532:	db59                	beqz	a4,800014c8 <copyinstr+0x26>
        *dst = *p;
    80001534:	00e78023          	sb	a4,0(a5)
      dst++;
    80001538:	0785                	addi	a5,a5,1
    while(n > 0){
    8000153a:	fed797e3          	bne	a5,a3,80001528 <copyinstr+0x86>
    8000153e:	b775                	j	800014ea <copyinstr+0x48>
    80001540:	4781                	li	a5,0
    80001542:	b771                	j	800014ce <copyinstr+0x2c>
      return -1;
    80001544:	557d                	li	a0,-1
    80001546:	b779                	j	800014d4 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001548:	6b85                	lui	s7,0x1
    8000154a:	9ba6                	add	s7,s7,s1
    8000154c:	87da                	mv	a5,s6
    8000154e:	b77d                	j	800014fc <copyinstr+0x5a>
  int got_null = 0;
    80001550:	4781                	li	a5,0
  if(got_null){
    80001552:	37fd                	addiw	a5,a5,-1
    80001554:	0007851b          	sext.w	a0,a5
}
    80001558:	8082                	ret

000000008000155a <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    8000155a:	1141                	addi	sp,sp,-16
    8000155c:	e406                	sd	ra,8(sp)
    8000155e:	e022                	sd	s0,0(sp)
    80001560:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001562:	4601                	li	a2,0
    80001564:	9bbff0ef          	jal	80000f1e <walk>
  if (pte == 0) {
    80001568:	c519                	beqz	a0,80001576 <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    8000156a:	6108                	ld	a0,0(a0)
    8000156c:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    8000156e:	60a2                	ld	ra,8(sp)
    80001570:	6402                	ld	s0,0(sp)
    80001572:	0141                	addi	sp,sp,16
    80001574:	8082                	ret
    return 0;
    80001576:	4501                	li	a0,0
    80001578:	bfdd                	j	8000156e <ismapped+0x14>

000000008000157a <vmfault>:
{
    8000157a:	7179                	addi	sp,sp,-48
    8000157c:	f406                	sd	ra,40(sp)
    8000157e:	f022                	sd	s0,32(sp)
    80001580:	ec26                	sd	s1,24(sp)
    80001582:	e44e                	sd	s3,8(sp)
    80001584:	1800                	addi	s0,sp,48
    80001586:	89aa                	mv	s3,a0
    80001588:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    8000158a:	4bc000ef          	jal	80001a46 <myproc>
  if (va >= p->sz)
    8000158e:	653c                	ld	a5,72(a0)
    80001590:	00f4ea63          	bltu	s1,a5,800015a4 <vmfault+0x2a>
    return 0;
    80001594:	4981                	li	s3,0
}
    80001596:	854e                	mv	a0,s3
    80001598:	70a2                	ld	ra,40(sp)
    8000159a:	7402                	ld	s0,32(sp)
    8000159c:	64e2                	ld	s1,24(sp)
    8000159e:	69a2                	ld	s3,8(sp)
    800015a0:	6145                	addi	sp,sp,48
    800015a2:	8082                	ret
    800015a4:	e84a                	sd	s2,16(sp)
    800015a6:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    800015a8:	77fd                	lui	a5,0xfffff
    800015aa:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    800015ac:	85a6                	mv	a1,s1
    800015ae:	854e                	mv	a0,s3
    800015b0:	fabff0ef          	jal	8000155a <ismapped>
    return 0;
    800015b4:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    800015b6:	c119                	beqz	a0,800015bc <vmfault+0x42>
    800015b8:	6942                	ld	s2,16(sp)
    800015ba:	bff1                	j	80001596 <vmfault+0x1c>
    800015bc:	e052                	sd	s4,0(sp)
  mem = (uint64) kalloc();
    800015be:	d40ff0ef          	jal	80000afe <kalloc>
    800015c2:	8a2a                	mv	s4,a0
  if(mem == 0)
    800015c4:	c90d                	beqz	a0,800015f6 <vmfault+0x7c>
  mem = (uint64) kalloc();
    800015c6:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    800015c8:	6605                	lui	a2,0x1
    800015ca:	4581                	li	a1,0
    800015cc:	ed6ff0ef          	jal	80000ca2 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    800015d0:	4759                	li	a4,22
    800015d2:	86d2                	mv	a3,s4
    800015d4:	6605                	lui	a2,0x1
    800015d6:	85a6                	mv	a1,s1
    800015d8:	05093503          	ld	a0,80(s2)
    800015dc:	a1bff0ef          	jal	80000ff6 <mappages>
    800015e0:	e501                	bnez	a0,800015e8 <vmfault+0x6e>
    800015e2:	6942                	ld	s2,16(sp)
    800015e4:	6a02                	ld	s4,0(sp)
    800015e6:	bf45                	j	80001596 <vmfault+0x1c>
    kfree((void *)mem);
    800015e8:	8552                	mv	a0,s4
    800015ea:	c32ff0ef          	jal	80000a1c <kfree>
    return 0;
    800015ee:	4981                	li	s3,0
    800015f0:	6942                	ld	s2,16(sp)
    800015f2:	6a02                	ld	s4,0(sp)
    800015f4:	b74d                	j	80001596 <vmfault+0x1c>
    800015f6:	6942                	ld	s2,16(sp)
    800015f8:	6a02                	ld	s4,0(sp)
    800015fa:	bf71                	j	80001596 <vmfault+0x1c>

00000000800015fc <copyout>:
  while(len > 0){
    800015fc:	c2cd                	beqz	a3,8000169e <copyout+0xa2>
{
    800015fe:	711d                	addi	sp,sp,-96
    80001600:	ec86                	sd	ra,88(sp)
    80001602:	e8a2                	sd	s0,80(sp)
    80001604:	e4a6                	sd	s1,72(sp)
    80001606:	f852                	sd	s4,48(sp)
    80001608:	f05a                	sd	s6,32(sp)
    8000160a:	ec5e                	sd	s7,24(sp)
    8000160c:	e862                	sd	s8,16(sp)
    8000160e:	1080                	addi	s0,sp,96
    80001610:	8c2a                	mv	s8,a0
    80001612:	8b2e                	mv	s6,a1
    80001614:	8bb2                	mv	s7,a2
    80001616:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    80001618:	74fd                	lui	s1,0xfffff
    8000161a:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    8000161c:	57fd                	li	a5,-1
    8000161e:	83e9                	srli	a5,a5,0x1a
    80001620:	0897e163          	bltu	a5,s1,800016a2 <copyout+0xa6>
    80001624:	e0ca                	sd	s2,64(sp)
    80001626:	fc4e                	sd	s3,56(sp)
    80001628:	f456                	sd	s5,40(sp)
    8000162a:	e466                	sd	s9,8(sp)
    8000162c:	e06a                	sd	s10,0(sp)
    8000162e:	6d05                	lui	s10,0x1
    80001630:	8cbe                	mv	s9,a5
    80001632:	a015                	j	80001656 <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001634:	409b0533          	sub	a0,s6,s1
    80001638:	0009861b          	sext.w	a2,s3
    8000163c:	85de                	mv	a1,s7
    8000163e:	954a                	add	a0,a0,s2
    80001640:	ebeff0ef          	jal	80000cfe <memmove>
    len -= n;
    80001644:	413a0a33          	sub	s4,s4,s3
    src += n;
    80001648:	9bce                	add	s7,s7,s3
  while(len > 0){
    8000164a:	040a0363          	beqz	s4,80001690 <copyout+0x94>
    if(va0 >= MAXVA)
    8000164e:	055cec63          	bltu	s9,s5,800016a6 <copyout+0xaa>
    80001652:	84d6                	mv	s1,s5
    80001654:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    80001656:	85a6                	mv	a1,s1
    80001658:	8562                	mv	a0,s8
    8000165a:	95fff0ef          	jal	80000fb8 <walkaddr>
    8000165e:	892a                	mv	s2,a0
    if(pa0 == 0) {
    80001660:	e901                	bnez	a0,80001670 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001662:	4601                	li	a2,0
    80001664:	85a6                	mv	a1,s1
    80001666:	8562                	mv	a0,s8
    80001668:	f13ff0ef          	jal	8000157a <vmfault>
    8000166c:	892a                	mv	s2,a0
    8000166e:	c139                	beqz	a0,800016b4 <copyout+0xb8>
    pte = walk(pagetable, va0, 0);
    80001670:	4601                	li	a2,0
    80001672:	85a6                	mv	a1,s1
    80001674:	8562                	mv	a0,s8
    80001676:	8a9ff0ef          	jal	80000f1e <walk>
    if((*pte & PTE_W) == 0)
    8000167a:	611c                	ld	a5,0(a0)
    8000167c:	8b91                	andi	a5,a5,4
    8000167e:	c3b1                	beqz	a5,800016c2 <copyout+0xc6>
    n = PGSIZE - (dstva - va0);
    80001680:	01a48ab3          	add	s5,s1,s10
    80001684:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    80001688:	fb3a76e3          	bgeu	s4,s3,80001634 <copyout+0x38>
    8000168c:	89d2                	mv	s3,s4
    8000168e:	b75d                	j	80001634 <copyout+0x38>
  return 0;
    80001690:	4501                	li	a0,0
    80001692:	6906                	ld	s2,64(sp)
    80001694:	79e2                	ld	s3,56(sp)
    80001696:	7aa2                	ld	s5,40(sp)
    80001698:	6ca2                	ld	s9,8(sp)
    8000169a:	6d02                	ld	s10,0(sp)
    8000169c:	a80d                	j	800016ce <copyout+0xd2>
    8000169e:	4501                	li	a0,0
}
    800016a0:	8082                	ret
      return -1;
    800016a2:	557d                	li	a0,-1
    800016a4:	a02d                	j	800016ce <copyout+0xd2>
    800016a6:	557d                	li	a0,-1
    800016a8:	6906                	ld	s2,64(sp)
    800016aa:	79e2                	ld	s3,56(sp)
    800016ac:	7aa2                	ld	s5,40(sp)
    800016ae:	6ca2                	ld	s9,8(sp)
    800016b0:	6d02                	ld	s10,0(sp)
    800016b2:	a831                	j	800016ce <copyout+0xd2>
        return -1;
    800016b4:	557d                	li	a0,-1
    800016b6:	6906                	ld	s2,64(sp)
    800016b8:	79e2                	ld	s3,56(sp)
    800016ba:	7aa2                	ld	s5,40(sp)
    800016bc:	6ca2                	ld	s9,8(sp)
    800016be:	6d02                	ld	s10,0(sp)
    800016c0:	a039                	j	800016ce <copyout+0xd2>
      return -1;
    800016c2:	557d                	li	a0,-1
    800016c4:	6906                	ld	s2,64(sp)
    800016c6:	79e2                	ld	s3,56(sp)
    800016c8:	7aa2                	ld	s5,40(sp)
    800016ca:	6ca2                	ld	s9,8(sp)
    800016cc:	6d02                	ld	s10,0(sp)
}
    800016ce:	60e6                	ld	ra,88(sp)
    800016d0:	6446                	ld	s0,80(sp)
    800016d2:	64a6                	ld	s1,72(sp)
    800016d4:	7a42                	ld	s4,48(sp)
    800016d6:	7b02                	ld	s6,32(sp)
    800016d8:	6be2                	ld	s7,24(sp)
    800016da:	6c42                	ld	s8,16(sp)
    800016dc:	6125                	addi	sp,sp,96
    800016de:	8082                	ret

00000000800016e0 <copyin>:
  while(len > 0){
    800016e0:	c6c9                	beqz	a3,8000176a <copyin+0x8a>
{
    800016e2:	715d                	addi	sp,sp,-80
    800016e4:	e486                	sd	ra,72(sp)
    800016e6:	e0a2                	sd	s0,64(sp)
    800016e8:	fc26                	sd	s1,56(sp)
    800016ea:	f84a                	sd	s2,48(sp)
    800016ec:	f44e                	sd	s3,40(sp)
    800016ee:	f052                	sd	s4,32(sp)
    800016f0:	ec56                	sd	s5,24(sp)
    800016f2:	e85a                	sd	s6,16(sp)
    800016f4:	e45e                	sd	s7,8(sp)
    800016f6:	e062                	sd	s8,0(sp)
    800016f8:	0880                	addi	s0,sp,80
    800016fa:	8baa                	mv	s7,a0
    800016fc:	8aae                	mv	s5,a1
    800016fe:	8932                	mv	s2,a2
    80001700:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001702:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001704:	6b05                	lui	s6,0x1
    80001706:	a035                	j	80001732 <copyin+0x52>
    80001708:	412984b3          	sub	s1,s3,s2
    8000170c:	94da                	add	s1,s1,s6
    if(n > len)
    8000170e:	009a7363          	bgeu	s4,s1,80001714 <copyin+0x34>
    80001712:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001714:	413905b3          	sub	a1,s2,s3
    80001718:	0004861b          	sext.w	a2,s1
    8000171c:	95aa                	add	a1,a1,a0
    8000171e:	8556                	mv	a0,s5
    80001720:	ddeff0ef          	jal	80000cfe <memmove>
    len -= n;
    80001724:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001728:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    8000172a:	01698933          	add	s2,s3,s6
  while(len > 0){
    8000172e:	020a0163          	beqz	s4,80001750 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001732:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001736:	85ce                	mv	a1,s3
    80001738:	855e                	mv	a0,s7
    8000173a:	87fff0ef          	jal	80000fb8 <walkaddr>
    if(pa0 == 0) {
    8000173e:	f569                	bnez	a0,80001708 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001740:	4601                	li	a2,0
    80001742:	85ce                	mv	a1,s3
    80001744:	855e                	mv	a0,s7
    80001746:	e35ff0ef          	jal	8000157a <vmfault>
    8000174a:	fd5d                	bnez	a0,80001708 <copyin+0x28>
        return -1;
    8000174c:	557d                	li	a0,-1
    8000174e:	a011                	j	80001752 <copyin+0x72>
  return 0;
    80001750:	4501                	li	a0,0
}
    80001752:	60a6                	ld	ra,72(sp)
    80001754:	6406                	ld	s0,64(sp)
    80001756:	74e2                	ld	s1,56(sp)
    80001758:	7942                	ld	s2,48(sp)
    8000175a:	79a2                	ld	s3,40(sp)
    8000175c:	7a02                	ld	s4,32(sp)
    8000175e:	6ae2                	ld	s5,24(sp)
    80001760:	6b42                	ld	s6,16(sp)
    80001762:	6ba2                	ld	s7,8(sp)
    80001764:	6c02                	ld	s8,0(sp)
    80001766:	6161                	addi	sp,sp,80
    80001768:	8082                	ret
  return 0;
    8000176a:	4501                	li	a0,0
}
    8000176c:	8082                	ret

000000008000176e <get_current_time>:
#define TIMER_TIME_LOW  0x00
#define TIMER_TIME_HIGH 0x04

// Gets the current time in unix epoch
uint64
get_current_time(void) {
    8000176e:	1141                	addi	sp,sp,-16
    80001770:	e422                	sd	s0,8(sp)
    80001772:	0800                	addi	s0,sp,16
  uint64 low, high, nsec;

  low = ReadReg(TIMER_TIME_LOW);
    80001774:	001017b7          	lui	a5,0x101
    80001778:	4398                	lw	a4,0(a5)
  high = ReadReg(TIMER_TIME_HIGH);
    8000177a:	0791                	addi	a5,a5,4 # 101004 <_entry-0x7fefeffc>
    8000177c:	439c                	lw	a5,0(a5)
  nsec = (high << 32) | low;
    8000177e:	1782                	slli	a5,a5,0x20
  low = ReadReg(TIMER_TIME_LOW);
    80001780:	1702                	slli	a4,a4,0x20
    80001782:	9301                	srli	a4,a4,0x20
  nsec = (high << 32) | low;
    80001784:	8fd9                	or	a5,a5,a4

  return nsec / 1000000000;
    80001786:	3b9ad537          	lui	a0,0x3b9ad
    8000178a:	a0050513          	addi	a0,a0,-1536 # 3b9aca00 <_entry-0x44653600>
    8000178e:	02a7d533          	divu	a0,a5,a0
    80001792:	6422                	ld	s0,8(sp)
    80001794:	0141                	addi	sp,sp,16
    80001796:	8082                	ret

0000000080001798 <rng_seed>:
    return z ^ (z >> 31);
}

// Seed the random number generator
void
rng_seed(uint64 seed) {
    80001798:	1101                	addi	sp,sp,-32
    8000179a:	ec06                	sd	ra,24(sp)
    8000179c:	e822                	sd	s0,16(sp)
    8000179e:	e426                	sd	s1,8(sp)
    800017a0:	e04a                	sd	s2,0(sp)
    800017a2:	1000                	addi	s0,sp,32
    800017a4:	892a                	mv	s2,a0
  initlock(&next_lock, "next_lock");
    800017a6:	0000e497          	auipc	s1,0xe
    800017aa:	1e248493          	addi	s1,s1,482 # 8000f988 <next_lock>
    800017ae:	00006597          	auipc	a1,0x6
    800017b2:	9aa58593          	addi	a1,a1,-1622 # 80007158 <etext+0x158>
    800017b6:	8526                	mv	a0,s1
    800017b8:	b96ff0ef          	jal	80000b4e <initlock>
  initlock(&next_byte_lock, "next_byte_lock");
    800017bc:	00006597          	auipc	a1,0x6
    800017c0:	9ac58593          	addi	a1,a1,-1620 # 80007168 <etext+0x168>
    800017c4:	0000e517          	auipc	a0,0xe
    800017c8:	1dc50513          	addi	a0,a0,476 # 8000f9a0 <next_byte_lock>
    800017cc:	b82ff0ef          	jal	80000b4e <initlock>
    uint64 z = (x + 0x9e3779b97f4a7c15);
    800017d0:	fff3c6b7          	lui	a3,0xfff3c
    800017d4:	6ef68693          	addi	a3,a3,1775 # fffffffffff3c6ef <end+0xffffffff7ff1b917>
    800017d8:	06b2                	slli	a3,a3,0xc
    800017da:	37368693          	addi	a3,a3,883
    800017de:	06c2                	slli	a3,a3,0x10
    800017e0:	e9568693          	addi	a3,a3,-363
    800017e4:	06be                	slli	a3,a3,0xf
    800017e6:	c1568693          	addi	a3,a3,-1003
    800017ea:	00d90533          	add	a0,s2,a3
    z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9;
    800017ee:	01e55793          	srli	a5,a0,0x1e
    800017f2:	8fa9                	xor	a5,a5,a0
    800017f4:	ff7eb737          	lui	a4,0xff7eb
    800017f8:	08f70713          	addi	a4,a4,143 # ffffffffff7eb08f <end+0xffffffff7f7ca2b7>
    800017fc:	0736                	slli	a4,a4,0xd
    800017fe:	b4770713          	addi	a4,a4,-1209
    80001802:	0736                	slli	a4,a4,0xd
    80001804:	72770713          	addi	a4,a4,1831
    80001808:	0736                	slli	a4,a4,0xd
    8000180a:	5b970713          	addi	a4,a4,1465
    8000180e:	02e787b3          	mul	a5,a5,a4
    z = (z ^ (z >> 27)) * 0x94d049bb133111eb;
    80001812:	01b7d593          	srli	a1,a5,0x1b
    80001816:	8dbd                	xor	a1,a1,a5
    80001818:	fe5347b7          	lui	a5,0xfe534
    8000181c:	12778793          	addi	a5,a5,295 # fffffffffe534127 <end+0xffffffff7e51334f>
    80001820:	07ba                	slli	a5,a5,0xe
    80001822:	b1378793          	addi	a5,a5,-1261
    80001826:	07b2                	slli	a5,a5,0xc
    80001828:	31178793          	addi	a5,a5,785
    8000182c:	07b2                	slli	a5,a5,0xc
    8000182e:	1eb78793          	addi	a5,a5,491
    80001832:	02f585b3          	mul	a1,a1,a5
    return z ^ (z >> 31);
    80001836:	01f5d613          	srli	a2,a1,0x1f
    8000183a:	8e2d                	xor	a2,a2,a1
  s[0] = splitmix64next(seed);
    8000183c:	f890                	sd	a2,48(s1)
    uint64 z = (x + 0x9e3779b97f4a7c15);
    8000183e:	96b2                	add	a3,a3,a2
    z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9;
    80001840:	01e6d613          	srli	a2,a3,0x1e
    80001844:	8eb1                	xor	a3,a3,a2
    80001846:	02e686b3          	mul	a3,a3,a4
    z = (z ^ (z >> 27)) * 0x94d049bb133111eb;
    8000184a:	01b6d713          	srli	a4,a3,0x1b
    8000184e:	8f35                	xor	a4,a4,a3
    80001850:	02f707b3          	mul	a5,a4,a5
    return z ^ (z >> 31);
    80001854:	01f7d713          	srli	a4,a5,0x1f
    80001858:	8fb9                	xor	a5,a5,a4
  s[1] = splitmix64next(s[0]);
    8000185a:	fc9c                	sd	a5,56(s1)
}
    8000185c:	60e2                	ld	ra,24(sp)
    8000185e:	6442                	ld	s0,16(sp)
    80001860:	64a2                	ld	s1,8(sp)
    80001862:	6902                	ld	s2,0(sp)
    80001864:	6105                	addi	sp,sp,32
    80001866:	8082                	ret

0000000080001868 <rand_int>:

// Get a uint64 as a random number
int
rand_int(void) {
    80001868:	7179                	addi	sp,sp,-48
    8000186a:	f406                	sd	ra,40(sp)
    8000186c:	f022                	sd	s0,32(sp)
    8000186e:	ec26                	sd	s1,24(sp)
    80001870:	e84a                	sd	s2,16(sp)
    80001872:	e44e                	sd	s3,8(sp)
    80001874:	1800                	addi	s0,sp,48
  acquire(&next_lock);
    80001876:	0000e917          	auipc	s2,0xe
    8000187a:	11290913          	addi	s2,s2,274 # 8000f988 <next_lock>
    8000187e:	854a                	mv	a0,s2
    80001880:	b4eff0ef          	jal	80000bce <acquire>
  const uint64 s0 = s[0];
    80001884:	03093483          	ld	s1,48(s2)
  uint64 s1 = s[1];
    80001888:	03893983          	ld	s3,56(s2)
  release(&next_lock);
    8000188c:	854a                	mv	a0,s2
    8000188e:	bd8ff0ef          	jal	80000c66 <release>
  const uint64 result = s0 + s1;
  
  s1 ^= s0;
    80001892:	0134c733          	xor	a4,s1,s3
  return (x << k) | (x >> (64 - k));
    80001896:	01849793          	slli	a5,s1,0x18
    8000189a:	0284d693          	srli	a3,s1,0x28
    8000189e:	8fd5                	or	a5,a5,a3
  s[0] = rotl(s0, 24) ^ s1 ^ (s1 << 16); // a, b
    800018a0:	8fb9                	xor	a5,a5,a4
    800018a2:	01071693          	slli	a3,a4,0x10
    800018a6:	8fb5                	xor	a5,a5,a3
    800018a8:	02f93823          	sd	a5,48(s2)
  return (x << k) | (x >> (64 - k));
    800018ac:	01b75793          	srli	a5,a4,0x1b
    800018b0:	1716                	slli	a4,a4,0x25
    800018b2:	8fd9                	or	a5,a5,a4
  s[1] = rotl(s1, 37); // c
    800018b4:	02f93c23          	sd	a5,56(s2)
  const uint64 result = s0 + s1;
    800018b8:	01348533          	add	a0,s1,s3
  
  return (int) (result >> 32);
    800018bc:	9501                	srai	a0,a0,0x20
    800018be:	70a2                	ld	ra,40(sp)
    800018c0:	7402                	ld	s0,32(sp)
    800018c2:	64e2                	ld	s1,24(sp)
    800018c4:	6942                	ld	s2,16(sp)
    800018c6:	69a2                	ld	s3,8(sp)
    800018c8:	6145                	addi	sp,sp,48
    800018ca:	8082                	ret

00000000800018cc <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800018cc:	7139                	addi	sp,sp,-64
    800018ce:	fc06                	sd	ra,56(sp)
    800018d0:	f822                	sd	s0,48(sp)
    800018d2:	f426                	sd	s1,40(sp)
    800018d4:	f04a                	sd	s2,32(sp)
    800018d6:	ec4e                	sd	s3,24(sp)
    800018d8:	e852                	sd	s4,16(sp)
    800018da:	e456                	sd	s5,8(sp)
    800018dc:	e05a                	sd	s6,0(sp)
    800018de:	0080                	addi	s0,sp,64
    800018e0:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800018e2:	0000e497          	auipc	s1,0xe
    800018e6:	51648493          	addi	s1,s1,1302 # 8000fdf8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800018ea:	8b26                	mv	s6,s1
    800018ec:	ff4df937          	lui	s2,0xff4df
    800018f0:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bdbe5>
    800018f4:	0936                	slli	s2,s2,0xd
    800018f6:	6f590913          	addi	s2,s2,1781
    800018fa:	0936                	slli	s2,s2,0xd
    800018fc:	bd390913          	addi	s2,s2,-1069
    80001900:	0932                	slli	s2,s2,0xc
    80001902:	7a790913          	addi	s2,s2,1959
    80001906:	040009b7          	lui	s3,0x4000
    8000190a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000190c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000190e:	00014a97          	auipc	s5,0x14
    80001912:	0eaa8a93          	addi	s5,s5,234 # 800159f8 <tickslock>
    char *pa = kalloc();
    80001916:	9e8ff0ef          	jal	80000afe <kalloc>
    8000191a:	862a                	mv	a2,a0
    if(pa == 0)
    8000191c:	cd15                	beqz	a0,80001958 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    8000191e:	416485b3          	sub	a1,s1,s6
    80001922:	8591                	srai	a1,a1,0x4
    80001924:	032585b3          	mul	a1,a1,s2
    80001928:	2585                	addiw	a1,a1,1
    8000192a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000192e:	4719                	li	a4,6
    80001930:	6685                	lui	a3,0x1
    80001932:	40b985b3          	sub	a1,s3,a1
    80001936:	8552                	mv	a0,s4
    80001938:	f6eff0ef          	jal	800010a6 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000193c:	17048493          	addi	s1,s1,368
    80001940:	fd549be3          	bne	s1,s5,80001916 <proc_mapstacks+0x4a>
  }
}
    80001944:	70e2                	ld	ra,56(sp)
    80001946:	7442                	ld	s0,48(sp)
    80001948:	74a2                	ld	s1,40(sp)
    8000194a:	7902                	ld	s2,32(sp)
    8000194c:	69e2                	ld	s3,24(sp)
    8000194e:	6a42                	ld	s4,16(sp)
    80001950:	6aa2                	ld	s5,8(sp)
    80001952:	6b02                	ld	s6,0(sp)
    80001954:	6121                	addi	sp,sp,64
    80001956:	8082                	ret
      panic("kalloc");
    80001958:	00006517          	auipc	a0,0x6
    8000195c:	82050513          	addi	a0,a0,-2016 # 80007178 <etext+0x178>
    80001960:	e81fe0ef          	jal	800007e0 <panic>

0000000080001964 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001964:	7139                	addi	sp,sp,-64
    80001966:	fc06                	sd	ra,56(sp)
    80001968:	f822                	sd	s0,48(sp)
    8000196a:	f426                	sd	s1,40(sp)
    8000196c:	f04a                	sd	s2,32(sp)
    8000196e:	ec4e                	sd	s3,24(sp)
    80001970:	e852                	sd	s4,16(sp)
    80001972:	e456                	sd	s5,8(sp)
    80001974:	e05a                	sd	s6,0(sp)
    80001976:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001978:	00006597          	auipc	a1,0x6
    8000197c:	80858593          	addi	a1,a1,-2040 # 80007180 <etext+0x180>
    80001980:	0000e517          	auipc	a0,0xe
    80001984:	04850513          	addi	a0,a0,72 # 8000f9c8 <pid_lock>
    80001988:	9c6ff0ef          	jal	80000b4e <initlock>
  initlock(&wait_lock, "wait_lock");
    8000198c:	00005597          	auipc	a1,0x5
    80001990:	7fc58593          	addi	a1,a1,2044 # 80007188 <etext+0x188>
    80001994:	0000e517          	auipc	a0,0xe
    80001998:	04c50513          	addi	a0,a0,76 # 8000f9e0 <wait_lock>
    8000199c:	9b2ff0ef          	jal	80000b4e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019a0:	0000e497          	auipc	s1,0xe
    800019a4:	45848493          	addi	s1,s1,1112 # 8000fdf8 <proc>
      initlock(&p->lock, "proc");
    800019a8:	00005b17          	auipc	s6,0x5
    800019ac:	7f0b0b13          	addi	s6,s6,2032 # 80007198 <etext+0x198>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    800019b0:	8aa6                	mv	s5,s1
    800019b2:	ff4df937          	lui	s2,0xff4df
    800019b6:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bdbe5>
    800019ba:	0936                	slli	s2,s2,0xd
    800019bc:	6f590913          	addi	s2,s2,1781
    800019c0:	0936                	slli	s2,s2,0xd
    800019c2:	bd390913          	addi	s2,s2,-1069
    800019c6:	0932                	slli	s2,s2,0xc
    800019c8:	7a790913          	addi	s2,s2,1959
    800019cc:	040009b7          	lui	s3,0x4000
    800019d0:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019d2:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019d4:	00014a17          	auipc	s4,0x14
    800019d8:	024a0a13          	addi	s4,s4,36 # 800159f8 <tickslock>
      initlock(&p->lock, "proc");
    800019dc:	85da                	mv	a1,s6
    800019de:	8526                	mv	a0,s1
    800019e0:	96eff0ef          	jal	80000b4e <initlock>
      p->state = UNUSED;
    800019e4:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800019e8:	415487b3          	sub	a5,s1,s5
    800019ec:	8791                	srai	a5,a5,0x4
    800019ee:	032787b3          	mul	a5,a5,s2
    800019f2:	2785                	addiw	a5,a5,1
    800019f4:	00d7979b          	slliw	a5,a5,0xd
    800019f8:	40f987b3          	sub	a5,s3,a5
    800019fc:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019fe:	17048493          	addi	s1,s1,368
    80001a02:	fd449de3          	bne	s1,s4,800019dc <procinit+0x78>
  }
}
    80001a06:	70e2                	ld	ra,56(sp)
    80001a08:	7442                	ld	s0,48(sp)
    80001a0a:	74a2                	ld	s1,40(sp)
    80001a0c:	7902                	ld	s2,32(sp)
    80001a0e:	69e2                	ld	s3,24(sp)
    80001a10:	6a42                	ld	s4,16(sp)
    80001a12:	6aa2                	ld	s5,8(sp)
    80001a14:	6b02                	ld	s6,0(sp)
    80001a16:	6121                	addi	sp,sp,64
    80001a18:	8082                	ret

0000000080001a1a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a1a:	1141                	addi	sp,sp,-16
    80001a1c:	e422                	sd	s0,8(sp)
    80001a1e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a20:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a22:	2501                	sext.w	a0,a0
    80001a24:	6422                	ld	s0,8(sp)
    80001a26:	0141                	addi	sp,sp,16
    80001a28:	8082                	ret

0000000080001a2a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001a2a:	1141                	addi	sp,sp,-16
    80001a2c:	e422                	sd	s0,8(sp)
    80001a2e:	0800                	addi	s0,sp,16
    80001a30:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a32:	2781                	sext.w	a5,a5
    80001a34:	079e                	slli	a5,a5,0x7
  return c;
}
    80001a36:	0000e517          	auipc	a0,0xe
    80001a3a:	fc250513          	addi	a0,a0,-62 # 8000f9f8 <cpus>
    80001a3e:	953e                	add	a0,a0,a5
    80001a40:	6422                	ld	s0,8(sp)
    80001a42:	0141                	addi	sp,sp,16
    80001a44:	8082                	ret

0000000080001a46 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001a46:	1101                	addi	sp,sp,-32
    80001a48:	ec06                	sd	ra,24(sp)
    80001a4a:	e822                	sd	s0,16(sp)
    80001a4c:	e426                	sd	s1,8(sp)
    80001a4e:	1000                	addi	s0,sp,32
  push_off();
    80001a50:	93eff0ef          	jal	80000b8e <push_off>
    80001a54:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a56:	2781                	sext.w	a5,a5
    80001a58:	079e                	slli	a5,a5,0x7
    80001a5a:	0000e717          	auipc	a4,0xe
    80001a5e:	f6e70713          	addi	a4,a4,-146 # 8000f9c8 <pid_lock>
    80001a62:	97ba                	add	a5,a5,a4
    80001a64:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a66:	9acff0ef          	jal	80000c12 <pop_off>
  return p;
}
    80001a6a:	8526                	mv	a0,s1
    80001a6c:	60e2                	ld	ra,24(sp)
    80001a6e:	6442                	ld	s0,16(sp)
    80001a70:	64a2                	ld	s1,8(sp)
    80001a72:	6105                	addi	sp,sp,32
    80001a74:	8082                	ret

0000000080001a76 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a76:	7179                	addi	sp,sp,-48
    80001a78:	f406                	sd	ra,40(sp)
    80001a7a:	f022                	sd	s0,32(sp)
    80001a7c:	ec26                	sd	s1,24(sp)
    80001a7e:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001a80:	fc7ff0ef          	jal	80001a46 <myproc>
    80001a84:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001a86:	9e0ff0ef          	jal	80000c66 <release>

  if (first) {
    80001a8a:	00006797          	auipc	a5,0x6
    80001a8e:	dc67a783          	lw	a5,-570(a5) # 80007850 <first.1>
    80001a92:	cf8d                	beqz	a5,80001acc <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001a94:	4505                	li	a0,1
    80001a96:	4b1010ef          	jal	80003746 <fsinit>

    first = 0;
    80001a9a:	00006797          	auipc	a5,0x6
    80001a9e:	da07ab23          	sw	zero,-586(a5) # 80007850 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001aa2:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001aa6:	00005517          	auipc	a0,0x5
    80001aaa:	6fa50513          	addi	a0,a0,1786 # 800071a0 <etext+0x1a0>
    80001aae:	fca43823          	sd	a0,-48(s0)
    80001ab2:	fc043c23          	sd	zero,-40(s0)
    80001ab6:	fd040593          	addi	a1,s0,-48
    80001aba:	597020ef          	jal	80004850 <kexec>
    80001abe:	6cbc                	ld	a5,88(s1)
    80001ac0:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001ac2:	6cbc                	ld	a5,88(s1)
    80001ac4:	7bb8                	ld	a4,112(a5)
    80001ac6:	57fd                	li	a5,-1
    80001ac8:	02f70d63          	beq	a4,a5,80001b02 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001acc:	381000ef          	jal	8000264c <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001ad0:	68a8                	ld	a0,80(s1)
    80001ad2:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001ad4:	04000737          	lui	a4,0x4000
    80001ad8:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001ada:	0732                	slli	a4,a4,0xc
    80001adc:	00004797          	auipc	a5,0x4
    80001ae0:	5c078793          	addi	a5,a5,1472 # 8000609c <userret>
    80001ae4:	00004697          	auipc	a3,0x4
    80001ae8:	51c68693          	addi	a3,a3,1308 # 80006000 <_trampoline>
    80001aec:	8f95                	sub	a5,a5,a3
    80001aee:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001af0:	577d                	li	a4,-1
    80001af2:	177e                	slli	a4,a4,0x3f
    80001af4:	8d59                	or	a0,a0,a4
    80001af6:	9782                	jalr	a5
}
    80001af8:	70a2                	ld	ra,40(sp)
    80001afa:	7402                	ld	s0,32(sp)
    80001afc:	64e2                	ld	s1,24(sp)
    80001afe:	6145                	addi	sp,sp,48
    80001b00:	8082                	ret
      panic("exec");
    80001b02:	00005517          	auipc	a0,0x5
    80001b06:	6a650513          	addi	a0,a0,1702 # 800071a8 <etext+0x1a8>
    80001b0a:	cd7fe0ef          	jal	800007e0 <panic>

0000000080001b0e <allocpid>:
{
    80001b0e:	1101                	addi	sp,sp,-32
    80001b10:	ec06                	sd	ra,24(sp)
    80001b12:	e822                	sd	s0,16(sp)
    80001b14:	e426                	sd	s1,8(sp)
    80001b16:	e04a                	sd	s2,0(sp)
    80001b18:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b1a:	0000e917          	auipc	s2,0xe
    80001b1e:	eae90913          	addi	s2,s2,-338 # 8000f9c8 <pid_lock>
    80001b22:	854a                	mv	a0,s2
    80001b24:	8aaff0ef          	jal	80000bce <acquire>
  pid = nextpid;
    80001b28:	00006797          	auipc	a5,0x6
    80001b2c:	d2c78793          	addi	a5,a5,-724 # 80007854 <nextpid>
    80001b30:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b32:	0014871b          	addiw	a4,s1,1
    80001b36:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b38:	854a                	mv	a0,s2
    80001b3a:	92cff0ef          	jal	80000c66 <release>
}
    80001b3e:	8526                	mv	a0,s1
    80001b40:	60e2                	ld	ra,24(sp)
    80001b42:	6442                	ld	s0,16(sp)
    80001b44:	64a2                	ld	s1,8(sp)
    80001b46:	6902                	ld	s2,0(sp)
    80001b48:	6105                	addi	sp,sp,32
    80001b4a:	8082                	ret

0000000080001b4c <proc_pagetable>:
{
    80001b4c:	1101                	addi	sp,sp,-32
    80001b4e:	ec06                	sd	ra,24(sp)
    80001b50:	e822                	sd	s0,16(sp)
    80001b52:	e426                	sd	s1,8(sp)
    80001b54:	e04a                	sd	s2,0(sp)
    80001b56:	1000                	addi	s0,sp,32
    80001b58:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b5a:	e54ff0ef          	jal	800011ae <uvmcreate>
    80001b5e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b60:	cd05                	beqz	a0,80001b98 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b62:	4729                	li	a4,10
    80001b64:	00004697          	auipc	a3,0x4
    80001b68:	49c68693          	addi	a3,a3,1180 # 80006000 <_trampoline>
    80001b6c:	6605                	lui	a2,0x1
    80001b6e:	040005b7          	lui	a1,0x4000
    80001b72:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b74:	05b2                	slli	a1,a1,0xc
    80001b76:	c80ff0ef          	jal	80000ff6 <mappages>
    80001b7a:	02054663          	bltz	a0,80001ba6 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b7e:	4719                	li	a4,6
    80001b80:	05893683          	ld	a3,88(s2)
    80001b84:	6605                	lui	a2,0x1
    80001b86:	020005b7          	lui	a1,0x2000
    80001b8a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b8c:	05b6                	slli	a1,a1,0xd
    80001b8e:	8526                	mv	a0,s1
    80001b90:	c66ff0ef          	jal	80000ff6 <mappages>
    80001b94:	00054f63          	bltz	a0,80001bb2 <proc_pagetable+0x66>
}
    80001b98:	8526                	mv	a0,s1
    80001b9a:	60e2                	ld	ra,24(sp)
    80001b9c:	6442                	ld	s0,16(sp)
    80001b9e:	64a2                	ld	s1,8(sp)
    80001ba0:	6902                	ld	s2,0(sp)
    80001ba2:	6105                	addi	sp,sp,32
    80001ba4:	8082                	ret
    uvmfree(pagetable, 0);
    80001ba6:	4581                	li	a1,0
    80001ba8:	8526                	mv	a0,s1
    80001baa:	ffeff0ef          	jal	800013a8 <uvmfree>
    return 0;
    80001bae:	4481                	li	s1,0
    80001bb0:	b7e5                	j	80001b98 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bb2:	4681                	li	a3,0
    80001bb4:	4605                	li	a2,1
    80001bb6:	040005b7          	lui	a1,0x4000
    80001bba:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bbc:	05b2                	slli	a1,a1,0xc
    80001bbe:	8526                	mv	a0,s1
    80001bc0:	e14ff0ef          	jal	800011d4 <uvmunmap>
    uvmfree(pagetable, 0);
    80001bc4:	4581                	li	a1,0
    80001bc6:	8526                	mv	a0,s1
    80001bc8:	fe0ff0ef          	jal	800013a8 <uvmfree>
    return 0;
    80001bcc:	4481                	li	s1,0
    80001bce:	b7e9                	j	80001b98 <proc_pagetable+0x4c>

0000000080001bd0 <proc_freepagetable>:
{
    80001bd0:	1101                	addi	sp,sp,-32
    80001bd2:	ec06                	sd	ra,24(sp)
    80001bd4:	e822                	sd	s0,16(sp)
    80001bd6:	e426                	sd	s1,8(sp)
    80001bd8:	e04a                	sd	s2,0(sp)
    80001bda:	1000                	addi	s0,sp,32
    80001bdc:	84aa                	mv	s1,a0
    80001bde:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001be0:	4681                	li	a3,0
    80001be2:	4605                	li	a2,1
    80001be4:	040005b7          	lui	a1,0x4000
    80001be8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bea:	05b2                	slli	a1,a1,0xc
    80001bec:	de8ff0ef          	jal	800011d4 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bf0:	4681                	li	a3,0
    80001bf2:	4605                	li	a2,1
    80001bf4:	020005b7          	lui	a1,0x2000
    80001bf8:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bfa:	05b6                	slli	a1,a1,0xd
    80001bfc:	8526                	mv	a0,s1
    80001bfe:	dd6ff0ef          	jal	800011d4 <uvmunmap>
  uvmfree(pagetable, sz);
    80001c02:	85ca                	mv	a1,s2
    80001c04:	8526                	mv	a0,s1
    80001c06:	fa2ff0ef          	jal	800013a8 <uvmfree>
}
    80001c0a:	60e2                	ld	ra,24(sp)
    80001c0c:	6442                	ld	s0,16(sp)
    80001c0e:	64a2                	ld	s1,8(sp)
    80001c10:	6902                	ld	s2,0(sp)
    80001c12:	6105                	addi	sp,sp,32
    80001c14:	8082                	ret

0000000080001c16 <freeproc>:
{
    80001c16:	1101                	addi	sp,sp,-32
    80001c18:	ec06                	sd	ra,24(sp)
    80001c1a:	e822                	sd	s0,16(sp)
    80001c1c:	e426                	sd	s1,8(sp)
    80001c1e:	1000                	addi	s0,sp,32
    80001c20:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c22:	6d28                	ld	a0,88(a0)
    80001c24:	c119                	beqz	a0,80001c2a <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001c26:	df7fe0ef          	jal	80000a1c <kfree>
  p->trapframe = 0;
    80001c2a:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c2e:	68a8                	ld	a0,80(s1)
    80001c30:	c501                	beqz	a0,80001c38 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001c32:	64ac                	ld	a1,72(s1)
    80001c34:	f9dff0ef          	jal	80001bd0 <proc_freepagetable>
  p->pagetable = 0;
    80001c38:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c3c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c40:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c44:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c48:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c4c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c50:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c54:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c58:	0004ac23          	sw	zero,24(s1)
}
    80001c5c:	60e2                	ld	ra,24(sp)
    80001c5e:	6442                	ld	s0,16(sp)
    80001c60:	64a2                	ld	s1,8(sp)
    80001c62:	6105                	addi	sp,sp,32
    80001c64:	8082                	ret

0000000080001c66 <allocproc>:
{
    80001c66:	1101                	addi	sp,sp,-32
    80001c68:	ec06                	sd	ra,24(sp)
    80001c6a:	e822                	sd	s0,16(sp)
    80001c6c:	e426                	sd	s1,8(sp)
    80001c6e:	e04a                	sd	s2,0(sp)
    80001c70:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c72:	0000e497          	auipc	s1,0xe
    80001c76:	18648493          	addi	s1,s1,390 # 8000fdf8 <proc>
    80001c7a:	00014917          	auipc	s2,0x14
    80001c7e:	d7e90913          	addi	s2,s2,-642 # 800159f8 <tickslock>
    acquire(&p->lock);
    80001c82:	8526                	mv	a0,s1
    80001c84:	f4bfe0ef          	jal	80000bce <acquire>
    if(p->state == UNUSED) {
    80001c88:	4c9c                	lw	a5,24(s1)
    80001c8a:	cb91                	beqz	a5,80001c9e <allocproc+0x38>
      release(&p->lock);
    80001c8c:	8526                	mv	a0,s1
    80001c8e:	fd9fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c92:	17048493          	addi	s1,s1,368
    80001c96:	ff2496e3          	bne	s1,s2,80001c82 <allocproc+0x1c>
  return 0;
    80001c9a:	4481                	li	s1,0
    80001c9c:	a0a1                	j	80001ce4 <allocproc+0x7e>
  p->pid = allocpid();
    80001c9e:	e71ff0ef          	jal	80001b0e <allocpid>
    80001ca2:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ca4:	4785                	li	a5,1
    80001ca6:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ca8:	e57fe0ef          	jal	80000afe <kalloc>
    80001cac:	892a                	mv	s2,a0
    80001cae:	eca8                	sd	a0,88(s1)
    80001cb0:	c129                	beqz	a0,80001cf2 <allocproc+0x8c>
  p->pagetable = proc_pagetable(p);
    80001cb2:	8526                	mv	a0,s1
    80001cb4:	e99ff0ef          	jal	80001b4c <proc_pagetable>
    80001cb8:	892a                	mv	s2,a0
    80001cba:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001cbc:	c139                	beqz	a0,80001d02 <allocproc+0x9c>
  memset(&p->context, 0, sizeof(p->context));
    80001cbe:	07000613          	li	a2,112
    80001cc2:	4581                	li	a1,0
    80001cc4:	06048513          	addi	a0,s1,96
    80001cc8:	fdbfe0ef          	jal	80000ca2 <memset>
  p->context.ra = (uint64)forkret;
    80001ccc:	00000797          	auipc	a5,0x0
    80001cd0:	daa78793          	addi	a5,a5,-598 # 80001a76 <forkret>
    80001cd4:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cd6:	60bc                	ld	a5,64(s1)
    80001cd8:	6705                	lui	a4,0x1
    80001cda:	97ba                	add	a5,a5,a4
    80001cdc:	f4bc                	sd	a5,104(s1)
  p->ticket = 10;
    80001cde:	47a9                	li	a5,10
    80001ce0:	16f4a423          	sw	a5,360(s1)
}
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	60e2                	ld	ra,24(sp)
    80001ce8:	6442                	ld	s0,16(sp)
    80001cea:	64a2                	ld	s1,8(sp)
    80001cec:	6902                	ld	s2,0(sp)
    80001cee:	6105                	addi	sp,sp,32
    80001cf0:	8082                	ret
    freeproc(p);
    80001cf2:	8526                	mv	a0,s1
    80001cf4:	f23ff0ef          	jal	80001c16 <freeproc>
    release(&p->lock);
    80001cf8:	8526                	mv	a0,s1
    80001cfa:	f6dfe0ef          	jal	80000c66 <release>
    return 0;
    80001cfe:	84ca                	mv	s1,s2
    80001d00:	b7d5                	j	80001ce4 <allocproc+0x7e>
    freeproc(p);
    80001d02:	8526                	mv	a0,s1
    80001d04:	f13ff0ef          	jal	80001c16 <freeproc>
    release(&p->lock);
    80001d08:	8526                	mv	a0,s1
    80001d0a:	f5dfe0ef          	jal	80000c66 <release>
    return 0;
    80001d0e:	84ca                	mv	s1,s2
    80001d10:	bfd1                	j	80001ce4 <allocproc+0x7e>

0000000080001d12 <userinit>:
{
    80001d12:	1101                	addi	sp,sp,-32
    80001d14:	ec06                	sd	ra,24(sp)
    80001d16:	e822                	sd	s0,16(sp)
    80001d18:	e426                	sd	s1,8(sp)
    80001d1a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d1c:	f4bff0ef          	jal	80001c66 <allocproc>
    80001d20:	84aa                	mv	s1,a0
  initproc = p;
    80001d22:	00006797          	auipc	a5,0x6
    80001d26:	b4a7bf23          	sd	a0,-1186(a5) # 80007880 <initproc>
  p->cwd = namei("/");
    80001d2a:	00005517          	auipc	a0,0x5
    80001d2e:	48650513          	addi	a0,a0,1158 # 800071b0 <etext+0x1b0>
    80001d32:	737010ef          	jal	80003c68 <namei>
    80001d36:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d3a:	478d                	li	a5,3
    80001d3c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d3e:	8526                	mv	a0,s1
    80001d40:	f27fe0ef          	jal	80000c66 <release>
}
    80001d44:	60e2                	ld	ra,24(sp)
    80001d46:	6442                	ld	s0,16(sp)
    80001d48:	64a2                	ld	s1,8(sp)
    80001d4a:	6105                	addi	sp,sp,32
    80001d4c:	8082                	ret

0000000080001d4e <growproc>:
{
    80001d4e:	1101                	addi	sp,sp,-32
    80001d50:	ec06                	sd	ra,24(sp)
    80001d52:	e822                	sd	s0,16(sp)
    80001d54:	e426                	sd	s1,8(sp)
    80001d56:	e04a                	sd	s2,0(sp)
    80001d58:	1000                	addi	s0,sp,32
    80001d5a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d5c:	cebff0ef          	jal	80001a46 <myproc>
    80001d60:	892a                	mv	s2,a0
  sz = p->sz;
    80001d62:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d64:	02905963          	blez	s1,80001d96 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001d68:	00b48633          	add	a2,s1,a1
    80001d6c:	020007b7          	lui	a5,0x2000
    80001d70:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001d72:	07b6                	slli	a5,a5,0xd
    80001d74:	02c7ea63          	bltu	a5,a2,80001da8 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d78:	4691                	li	a3,4
    80001d7a:	6928                	ld	a0,80(a0)
    80001d7c:	d26ff0ef          	jal	800012a2 <uvmalloc>
    80001d80:	85aa                	mv	a1,a0
    80001d82:	c50d                	beqz	a0,80001dac <growproc+0x5e>
  p->sz = sz;
    80001d84:	04b93423          	sd	a1,72(s2)
  return 0;
    80001d88:	4501                	li	a0,0
}
    80001d8a:	60e2                	ld	ra,24(sp)
    80001d8c:	6442                	ld	s0,16(sp)
    80001d8e:	64a2                	ld	s1,8(sp)
    80001d90:	6902                	ld	s2,0(sp)
    80001d92:	6105                	addi	sp,sp,32
    80001d94:	8082                	ret
  } else if(n < 0){
    80001d96:	fe04d7e3          	bgez	s1,80001d84 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d9a:	00b48633          	add	a2,s1,a1
    80001d9e:	6928                	ld	a0,80(a0)
    80001da0:	cbeff0ef          	jal	8000125e <uvmdealloc>
    80001da4:	85aa                	mv	a1,a0
    80001da6:	bff9                	j	80001d84 <growproc+0x36>
      return -1;
    80001da8:	557d                	li	a0,-1
    80001daa:	b7c5                	j	80001d8a <growproc+0x3c>
      return -1;
    80001dac:	557d                	li	a0,-1
    80001dae:	bff1                	j	80001d8a <growproc+0x3c>

0000000080001db0 <kfork>:
{
    80001db0:	7139                	addi	sp,sp,-64
    80001db2:	fc06                	sd	ra,56(sp)
    80001db4:	f822                	sd	s0,48(sp)
    80001db6:	f04a                	sd	s2,32(sp)
    80001db8:	e456                	sd	s5,8(sp)
    80001dba:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001dbc:	c8bff0ef          	jal	80001a46 <myproc>
    80001dc0:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001dc2:	ea5ff0ef          	jal	80001c66 <allocproc>
    80001dc6:	0e050e63          	beqz	a0,80001ec2 <kfork+0x112>
    80001dca:	ec4e                	sd	s3,24(sp)
    80001dcc:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dce:	048ab603          	ld	a2,72(s5)
    80001dd2:	692c                	ld	a1,80(a0)
    80001dd4:	050ab503          	ld	a0,80(s5)
    80001dd8:	e02ff0ef          	jal	800013da <uvmcopy>
    80001ddc:	04054a63          	bltz	a0,80001e30 <kfork+0x80>
    80001de0:	f426                	sd	s1,40(sp)
    80001de2:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001de4:	048ab783          	ld	a5,72(s5)
    80001de8:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001dec:	058ab683          	ld	a3,88(s5)
    80001df0:	87b6                	mv	a5,a3
    80001df2:	0589b703          	ld	a4,88(s3)
    80001df6:	12068693          	addi	a3,a3,288
    80001dfa:	0007b803          	ld	a6,0(a5)
    80001dfe:	6788                	ld	a0,8(a5)
    80001e00:	6b8c                	ld	a1,16(a5)
    80001e02:	6f90                	ld	a2,24(a5)
    80001e04:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001e08:	e708                	sd	a0,8(a4)
    80001e0a:	eb0c                	sd	a1,16(a4)
    80001e0c:	ef10                	sd	a2,24(a4)
    80001e0e:	02078793          	addi	a5,a5,32
    80001e12:	02070713          	addi	a4,a4,32
    80001e16:	fed792e3          	bne	a5,a3,80001dfa <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001e1a:	0589b783          	ld	a5,88(s3)
    80001e1e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e22:	0d0a8493          	addi	s1,s5,208
    80001e26:	0d098913          	addi	s2,s3,208
    80001e2a:	150a8a13          	addi	s4,s5,336
    80001e2e:	a831                	j	80001e4a <kfork+0x9a>
    freeproc(np);
    80001e30:	854e                	mv	a0,s3
    80001e32:	de5ff0ef          	jal	80001c16 <freeproc>
    release(&np->lock);
    80001e36:	854e                	mv	a0,s3
    80001e38:	e2ffe0ef          	jal	80000c66 <release>
    return -1;
    80001e3c:	597d                	li	s2,-1
    80001e3e:	69e2                	ld	s3,24(sp)
    80001e40:	a895                	j	80001eb4 <kfork+0x104>
  for(i = 0; i < NOFILE; i++)
    80001e42:	04a1                	addi	s1,s1,8
    80001e44:	0921                	addi	s2,s2,8
    80001e46:	01448963          	beq	s1,s4,80001e58 <kfork+0xa8>
    if(p->ofile[i])
    80001e4a:	6088                	ld	a0,0(s1)
    80001e4c:	d97d                	beqz	a0,80001e42 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e4e:	3b4020ef          	jal	80004202 <filedup>
    80001e52:	00a93023          	sd	a0,0(s2)
    80001e56:	b7f5                	j	80001e42 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001e58:	150ab503          	ld	a0,336(s5)
    80001e5c:	5c0010ef          	jal	8000341c <idup>
    80001e60:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e64:	4641                	li	a2,16
    80001e66:	158a8593          	addi	a1,s5,344
    80001e6a:	15898513          	addi	a0,s3,344
    80001e6e:	f73fe0ef          	jal	80000de0 <safestrcpy>
  np->ticket = p->ticket;
    80001e72:	168aa783          	lw	a5,360(s5)
    80001e76:	16f9a423          	sw	a5,360(s3)
  pid = np->pid;
    80001e7a:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001e7e:	854e                	mv	a0,s3
    80001e80:	de7fe0ef          	jal	80000c66 <release>
  acquire(&wait_lock);
    80001e84:	0000e497          	auipc	s1,0xe
    80001e88:	b5c48493          	addi	s1,s1,-1188 # 8000f9e0 <wait_lock>
    80001e8c:	8526                	mv	a0,s1
    80001e8e:	d41fe0ef          	jal	80000bce <acquire>
  np->parent = p;
    80001e92:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001e96:	8526                	mv	a0,s1
    80001e98:	dcffe0ef          	jal	80000c66 <release>
  acquire(&np->lock);
    80001e9c:	854e                	mv	a0,s3
    80001e9e:	d31fe0ef          	jal	80000bce <acquire>
  np->state = RUNNABLE;
    80001ea2:	478d                	li	a5,3
    80001ea4:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001ea8:	854e                	mv	a0,s3
    80001eaa:	dbdfe0ef          	jal	80000c66 <release>
  return pid;
    80001eae:	74a2                	ld	s1,40(sp)
    80001eb0:	69e2                	ld	s3,24(sp)
    80001eb2:	6a42                	ld	s4,16(sp)
}
    80001eb4:	854a                	mv	a0,s2
    80001eb6:	70e2                	ld	ra,56(sp)
    80001eb8:	7442                	ld	s0,48(sp)
    80001eba:	7902                	ld	s2,32(sp)
    80001ebc:	6aa2                	ld	s5,8(sp)
    80001ebe:	6121                	addi	sp,sp,64
    80001ec0:	8082                	ret
    return -1;
    80001ec2:	597d                	li	s2,-1
    80001ec4:	bfc5                	j	80001eb4 <kfork+0x104>

0000000080001ec6 <scheduler>:
{
    80001ec6:	711d                	addi	sp,sp,-96
    80001ec8:	ec86                	sd	ra,88(sp)
    80001eca:	e8a2                	sd	s0,80(sp)
    80001ecc:	e4a6                	sd	s1,72(sp)
    80001ece:	e0ca                	sd	s2,64(sp)
    80001ed0:	fc4e                	sd	s3,56(sp)
    80001ed2:	f852                	sd	s4,48(sp)
    80001ed4:	f456                	sd	s5,40(sp)
    80001ed6:	f05a                	sd	s6,32(sp)
    80001ed8:	ec5e                	sd	s7,24(sp)
    80001eda:	e862                	sd	s8,16(sp)
    80001edc:	e466                	sd	s9,8(sp)
    80001ede:	1080                	addi	s0,sp,96
    80001ee0:	8792                	mv	a5,tp
  int id = r_tp();
    80001ee2:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ee4:	00779693          	slli	a3,a5,0x7
    80001ee8:	0000e717          	auipc	a4,0xe
    80001eec:	ae070713          	addi	a4,a4,-1312 # 8000f9c8 <pid_lock>
    80001ef0:	9736                	add	a4,a4,a3
    80001ef2:	02073823          	sd	zero,48(a4)
          swtch(&c->context, &p->context);
    80001ef6:	0000e717          	auipc	a4,0xe
    80001efa:	b0a70713          	addi	a4,a4,-1270 # 8000fa00 <cpus+0x8>
    80001efe:	00e68cb3          	add	s9,a3,a4
    int total_tickets = 0;
    80001f02:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f04:	00014917          	auipc	s2,0x14
    80001f08:	af490913          	addi	s2,s2,-1292 # 800159f8 <tickslock>
    int winner = (rand_int() & 0x7FFFFFFF) % total_tickets;
    80001f0c:	80000bb7          	lui	s7,0x80000
    80001f10:	fffbcb93          	not	s7,s7
          c->proc = p;
    80001f14:	0000eb17          	auipc	s6,0xe
    80001f18:	ab4b0b13          	addi	s6,s6,-1356 # 8000f9c8 <pid_lock>
    80001f1c:	9b36                	add	s6,s6,a3
    80001f1e:	a03d                	j	80001f4c <scheduler+0x86>
      release(&p->lock);
    80001f20:	8526                	mv	a0,s1
    80001f22:	d45fe0ef          	jal	80000c66 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f26:	17048493          	addi	s1,s1,368
    80001f2a:	01248d63          	beq	s1,s2,80001f44 <scheduler+0x7e>
      acquire(&p->lock);
    80001f2e:	8526                	mv	a0,s1
    80001f30:	c9ffe0ef          	jal	80000bce <acquire>
      if(p->state == RUNNABLE) {
    80001f34:	4c9c                	lw	a5,24(s1)
    80001f36:	ff3795e3          	bne	a5,s3,80001f20 <scheduler+0x5a>
        total_tickets += p->ticket;
    80001f3a:	1684a783          	lw	a5,360(s1)
    80001f3e:	01478a3b          	addw	s4,a5,s4
    80001f42:	bff9                	j	80001f20 <scheduler+0x5a>
    if(total_tickets == 0) {
    80001f44:	020a1663          	bnez	s4,80001f70 <scheduler+0xaa>
      asm volatile("wfi");
    80001f48:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f4c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f50:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f54:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f58:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001f5c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f5e:	10079073          	csrw	sstatus,a5
    int total_tickets = 0;
    80001f62:	8a56                	mv	s4,s5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f64:	0000e497          	auipc	s1,0xe
    80001f68:	e9448493          	addi	s1,s1,-364 # 8000fdf8 <proc>
      if(p->state == RUNNABLE) {
    80001f6c:	498d                	li	s3,3
    80001f6e:	b7c1                	j	80001f2e <scheduler+0x68>
    int winner = (rand_int() & 0x7FFFFFFF) % total_tickets;
    80001f70:	8f9ff0ef          	jal	80001868 <rand_int>
    80001f74:	01757c33          	and	s8,a0,s7
    80001f78:	034c6c3b          	remw	s8,s8,s4
    int counter = 0;
    80001f7c:	89d6                	mv	s3,s5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f7e:	0000e497          	auipc	s1,0xe
    80001f82:	e7a48493          	addi	s1,s1,-390 # 8000fdf8 <proc>
      if(p->state == RUNNABLE) {
    80001f86:	4a0d                	li	s4,3
    80001f88:	a801                	j	80001f98 <scheduler+0xd2>
      release(&p->lock);
    80001f8a:	8526                	mv	a0,s1
    80001f8c:	cdbfe0ef          	jal	80000c66 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f90:	17048493          	addi	s1,s1,368
    80001f94:	fb248ce3          	beq	s1,s2,80001f4c <scheduler+0x86>
      acquire(&p->lock);
    80001f98:	8526                	mv	a0,s1
    80001f9a:	c35fe0ef          	jal	80000bce <acquire>
      if(p->state == RUNNABLE) {
    80001f9e:	4c9c                	lw	a5,24(s1)
    80001fa0:	ff4795e3          	bne	a5,s4,80001f8a <scheduler+0xc4>
        counter += p->ticket;
    80001fa4:	1684a783          	lw	a5,360(s1)
    80001fa8:	013789bb          	addw	s3,a5,s3
        if(counter > winner) {
    80001fac:	fd3c5fe3          	bge	s8,s3,80001f8a <scheduler+0xc4>
          p->state = RUNNING;
    80001fb0:	4791                	li	a5,4
    80001fb2:	cc9c                	sw	a5,24(s1)
          c->proc = p;
    80001fb4:	029b3823          	sd	s1,48(s6)
          swtch(&c->context, &p->context);
    80001fb8:	06048593          	addi	a1,s1,96
    80001fbc:	8566                	mv	a0,s9
    80001fbe:	5e8000ef          	jal	800025a6 <swtch>
          c->proc = 0;
    80001fc2:	020b3823          	sd	zero,48(s6)
          release(&p->lock);
    80001fc6:	8526                	mv	a0,s1
    80001fc8:	c9ffe0ef          	jal	80000c66 <release>
          break;
    80001fcc:	b741                	j	80001f4c <scheduler+0x86>

0000000080001fce <sched>:
{
    80001fce:	7179                	addi	sp,sp,-48
    80001fd0:	f406                	sd	ra,40(sp)
    80001fd2:	f022                	sd	s0,32(sp)
    80001fd4:	ec26                	sd	s1,24(sp)
    80001fd6:	e84a                	sd	s2,16(sp)
    80001fd8:	e44e                	sd	s3,8(sp)
    80001fda:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fdc:	a6bff0ef          	jal	80001a46 <myproc>
    80001fe0:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001fe2:	b83fe0ef          	jal	80000b64 <holding>
    80001fe6:	c92d                	beqz	a0,80002058 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fe8:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001fea:	2781                	sext.w	a5,a5
    80001fec:	079e                	slli	a5,a5,0x7
    80001fee:	0000e717          	auipc	a4,0xe
    80001ff2:	9da70713          	addi	a4,a4,-1574 # 8000f9c8 <pid_lock>
    80001ff6:	97ba                	add	a5,a5,a4
    80001ff8:	0a87a703          	lw	a4,168(a5)
    80001ffc:	4785                	li	a5,1
    80001ffe:	06f71363          	bne	a4,a5,80002064 <sched+0x96>
  if(p->state == RUNNING)
    80002002:	4c98                	lw	a4,24(s1)
    80002004:	4791                	li	a5,4
    80002006:	06f70563          	beq	a4,a5,80002070 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000200a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000200e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002010:	e7b5                	bnez	a5,8000207c <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002012:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002014:	0000e917          	auipc	s2,0xe
    80002018:	9b490913          	addi	s2,s2,-1612 # 8000f9c8 <pid_lock>
    8000201c:	2781                	sext.w	a5,a5
    8000201e:	079e                	slli	a5,a5,0x7
    80002020:	97ca                	add	a5,a5,s2
    80002022:	0ac7a983          	lw	s3,172(a5)
    80002026:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002028:	2781                	sext.w	a5,a5
    8000202a:	079e                	slli	a5,a5,0x7
    8000202c:	0000e597          	auipc	a1,0xe
    80002030:	9d458593          	addi	a1,a1,-1580 # 8000fa00 <cpus+0x8>
    80002034:	95be                	add	a1,a1,a5
    80002036:	06048513          	addi	a0,s1,96
    8000203a:	56c000ef          	jal	800025a6 <swtch>
    8000203e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002040:	2781                	sext.w	a5,a5
    80002042:	079e                	slli	a5,a5,0x7
    80002044:	993e                	add	s2,s2,a5
    80002046:	0b392623          	sw	s3,172(s2)
}
    8000204a:	70a2                	ld	ra,40(sp)
    8000204c:	7402                	ld	s0,32(sp)
    8000204e:	64e2                	ld	s1,24(sp)
    80002050:	6942                	ld	s2,16(sp)
    80002052:	69a2                	ld	s3,8(sp)
    80002054:	6145                	addi	sp,sp,48
    80002056:	8082                	ret
    panic("sched p->lock");
    80002058:	00005517          	auipc	a0,0x5
    8000205c:	16050513          	addi	a0,a0,352 # 800071b8 <etext+0x1b8>
    80002060:	f80fe0ef          	jal	800007e0 <panic>
    panic("sched locks");
    80002064:	00005517          	auipc	a0,0x5
    80002068:	16450513          	addi	a0,a0,356 # 800071c8 <etext+0x1c8>
    8000206c:	f74fe0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    80002070:	00005517          	auipc	a0,0x5
    80002074:	16850513          	addi	a0,a0,360 # 800071d8 <etext+0x1d8>
    80002078:	f68fe0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    8000207c:	00005517          	auipc	a0,0x5
    80002080:	16c50513          	addi	a0,a0,364 # 800071e8 <etext+0x1e8>
    80002084:	f5cfe0ef          	jal	800007e0 <panic>

0000000080002088 <yield>:
{
    80002088:	1101                	addi	sp,sp,-32
    8000208a:	ec06                	sd	ra,24(sp)
    8000208c:	e822                	sd	s0,16(sp)
    8000208e:	e426                	sd	s1,8(sp)
    80002090:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002092:	9b5ff0ef          	jal	80001a46 <myproc>
    80002096:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002098:	b37fe0ef          	jal	80000bce <acquire>
  p->state = RUNNABLE;
    8000209c:	478d                	li	a5,3
    8000209e:	cc9c                	sw	a5,24(s1)
  sched();
    800020a0:	f2fff0ef          	jal	80001fce <sched>
  release(&p->lock);
    800020a4:	8526                	mv	a0,s1
    800020a6:	bc1fe0ef          	jal	80000c66 <release>
}
    800020aa:	60e2                	ld	ra,24(sp)
    800020ac:	6442                	ld	s0,16(sp)
    800020ae:	64a2                	ld	s1,8(sp)
    800020b0:	6105                	addi	sp,sp,32
    800020b2:	8082                	ret

00000000800020b4 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020b4:	7179                	addi	sp,sp,-48
    800020b6:	f406                	sd	ra,40(sp)
    800020b8:	f022                	sd	s0,32(sp)
    800020ba:	ec26                	sd	s1,24(sp)
    800020bc:	e84a                	sd	s2,16(sp)
    800020be:	e44e                	sd	s3,8(sp)
    800020c0:	1800                	addi	s0,sp,48
    800020c2:	89aa                	mv	s3,a0
    800020c4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020c6:	981ff0ef          	jal	80001a46 <myproc>
    800020ca:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800020cc:	b03fe0ef          	jal	80000bce <acquire>
  release(lk);
    800020d0:	854a                	mv	a0,s2
    800020d2:	b95fe0ef          	jal	80000c66 <release>

  // Go to sleep.
  p->chan = chan;
    800020d6:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800020da:	4789                	li	a5,2
    800020dc:	cc9c                	sw	a5,24(s1)

  sched();
    800020de:	ef1ff0ef          	jal	80001fce <sched>

  // Tidy up.
  p->chan = 0;
    800020e2:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800020e6:	8526                	mv	a0,s1
    800020e8:	b7ffe0ef          	jal	80000c66 <release>
  acquire(lk);
    800020ec:	854a                	mv	a0,s2
    800020ee:	ae1fe0ef          	jal	80000bce <acquire>
}
    800020f2:	70a2                	ld	ra,40(sp)
    800020f4:	7402                	ld	s0,32(sp)
    800020f6:	64e2                	ld	s1,24(sp)
    800020f8:	6942                	ld	s2,16(sp)
    800020fa:	69a2                	ld	s3,8(sp)
    800020fc:	6145                	addi	sp,sp,48
    800020fe:	8082                	ret

0000000080002100 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80002100:	7139                	addi	sp,sp,-64
    80002102:	fc06                	sd	ra,56(sp)
    80002104:	f822                	sd	s0,48(sp)
    80002106:	f426                	sd	s1,40(sp)
    80002108:	f04a                	sd	s2,32(sp)
    8000210a:	ec4e                	sd	s3,24(sp)
    8000210c:	e852                	sd	s4,16(sp)
    8000210e:	e456                	sd	s5,8(sp)
    80002110:	0080                	addi	s0,sp,64
    80002112:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002114:	0000e497          	auipc	s1,0xe
    80002118:	ce448493          	addi	s1,s1,-796 # 8000fdf8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000211c:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000211e:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002120:	00014917          	auipc	s2,0x14
    80002124:	8d890913          	addi	s2,s2,-1832 # 800159f8 <tickslock>
    80002128:	a801                	j	80002138 <wakeup+0x38>
      }
      release(&p->lock);
    8000212a:	8526                	mv	a0,s1
    8000212c:	b3bfe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002130:	17048493          	addi	s1,s1,368
    80002134:	03248263          	beq	s1,s2,80002158 <wakeup+0x58>
    if(p != myproc()){
    80002138:	90fff0ef          	jal	80001a46 <myproc>
    8000213c:	fea48ae3          	beq	s1,a0,80002130 <wakeup+0x30>
      acquire(&p->lock);
    80002140:	8526                	mv	a0,s1
    80002142:	a8dfe0ef          	jal	80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002146:	4c9c                	lw	a5,24(s1)
    80002148:	ff3791e3          	bne	a5,s3,8000212a <wakeup+0x2a>
    8000214c:	709c                	ld	a5,32(s1)
    8000214e:	fd479ee3          	bne	a5,s4,8000212a <wakeup+0x2a>
        p->state = RUNNABLE;
    80002152:	0154ac23          	sw	s5,24(s1)
    80002156:	bfd1                	j	8000212a <wakeup+0x2a>
    }
  }
}
    80002158:	70e2                	ld	ra,56(sp)
    8000215a:	7442                	ld	s0,48(sp)
    8000215c:	74a2                	ld	s1,40(sp)
    8000215e:	7902                	ld	s2,32(sp)
    80002160:	69e2                	ld	s3,24(sp)
    80002162:	6a42                	ld	s4,16(sp)
    80002164:	6aa2                	ld	s5,8(sp)
    80002166:	6121                	addi	sp,sp,64
    80002168:	8082                	ret

000000008000216a <reparent>:
{
    8000216a:	7179                	addi	sp,sp,-48
    8000216c:	f406                	sd	ra,40(sp)
    8000216e:	f022                	sd	s0,32(sp)
    80002170:	ec26                	sd	s1,24(sp)
    80002172:	e84a                	sd	s2,16(sp)
    80002174:	e44e                	sd	s3,8(sp)
    80002176:	e052                	sd	s4,0(sp)
    80002178:	1800                	addi	s0,sp,48
    8000217a:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000217c:	0000e497          	auipc	s1,0xe
    80002180:	c7c48493          	addi	s1,s1,-900 # 8000fdf8 <proc>
      pp->parent = initproc;
    80002184:	00005a17          	auipc	s4,0x5
    80002188:	6fca0a13          	addi	s4,s4,1788 # 80007880 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000218c:	00014997          	auipc	s3,0x14
    80002190:	86c98993          	addi	s3,s3,-1940 # 800159f8 <tickslock>
    80002194:	a029                	j	8000219e <reparent+0x34>
    80002196:	17048493          	addi	s1,s1,368
    8000219a:	01348b63          	beq	s1,s3,800021b0 <reparent+0x46>
    if(pp->parent == p){
    8000219e:	7c9c                	ld	a5,56(s1)
    800021a0:	ff279be3          	bne	a5,s2,80002196 <reparent+0x2c>
      pp->parent = initproc;
    800021a4:	000a3503          	ld	a0,0(s4)
    800021a8:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800021aa:	f57ff0ef          	jal	80002100 <wakeup>
    800021ae:	b7e5                	j	80002196 <reparent+0x2c>
}
    800021b0:	70a2                	ld	ra,40(sp)
    800021b2:	7402                	ld	s0,32(sp)
    800021b4:	64e2                	ld	s1,24(sp)
    800021b6:	6942                	ld	s2,16(sp)
    800021b8:	69a2                	ld	s3,8(sp)
    800021ba:	6a02                	ld	s4,0(sp)
    800021bc:	6145                	addi	sp,sp,48
    800021be:	8082                	ret

00000000800021c0 <kexit>:
{
    800021c0:	7179                	addi	sp,sp,-48
    800021c2:	f406                	sd	ra,40(sp)
    800021c4:	f022                	sd	s0,32(sp)
    800021c6:	ec26                	sd	s1,24(sp)
    800021c8:	e84a                	sd	s2,16(sp)
    800021ca:	e44e                	sd	s3,8(sp)
    800021cc:	e052                	sd	s4,0(sp)
    800021ce:	1800                	addi	s0,sp,48
    800021d0:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021d2:	875ff0ef          	jal	80001a46 <myproc>
    800021d6:	89aa                	mv	s3,a0
  if(p == initproc)
    800021d8:	00005797          	auipc	a5,0x5
    800021dc:	6a87b783          	ld	a5,1704(a5) # 80007880 <initproc>
    800021e0:	0d050493          	addi	s1,a0,208
    800021e4:	15050913          	addi	s2,a0,336
    800021e8:	00a79f63          	bne	a5,a0,80002206 <kexit+0x46>
    panic("init exiting");
    800021ec:	00005517          	auipc	a0,0x5
    800021f0:	01450513          	addi	a0,a0,20 # 80007200 <etext+0x200>
    800021f4:	decfe0ef          	jal	800007e0 <panic>
      fileclose(f);
    800021f8:	050020ef          	jal	80004248 <fileclose>
      p->ofile[fd] = 0;
    800021fc:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002200:	04a1                	addi	s1,s1,8
    80002202:	01248563          	beq	s1,s2,8000220c <kexit+0x4c>
    if(p->ofile[fd]){
    80002206:	6088                	ld	a0,0(s1)
    80002208:	f965                	bnez	a0,800021f8 <kexit+0x38>
    8000220a:	bfdd                	j	80002200 <kexit+0x40>
  begin_op();
    8000220c:	431010ef          	jal	80003e3c <begin_op>
  iput(p->cwd);
    80002210:	1509b503          	ld	a0,336(s3)
    80002214:	3c0010ef          	jal	800035d4 <iput>
  end_op();
    80002218:	48f010ef          	jal	80003ea6 <end_op>
  p->cwd = 0;
    8000221c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002220:	0000d497          	auipc	s1,0xd
    80002224:	7c048493          	addi	s1,s1,1984 # 8000f9e0 <wait_lock>
    80002228:	8526                	mv	a0,s1
    8000222a:	9a5fe0ef          	jal	80000bce <acquire>
  reparent(p);
    8000222e:	854e                	mv	a0,s3
    80002230:	f3bff0ef          	jal	8000216a <reparent>
  wakeup(p->parent);
    80002234:	0389b503          	ld	a0,56(s3)
    80002238:	ec9ff0ef          	jal	80002100 <wakeup>
  acquire(&p->lock);
    8000223c:	854e                	mv	a0,s3
    8000223e:	991fe0ef          	jal	80000bce <acquire>
  p->xstate = status;
    80002242:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002246:	4795                	li	a5,5
    80002248:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000224c:	8526                	mv	a0,s1
    8000224e:	a19fe0ef          	jal	80000c66 <release>
  sched();
    80002252:	d7dff0ef          	jal	80001fce <sched>
  panic("zombie exit");
    80002256:	00005517          	auipc	a0,0x5
    8000225a:	fba50513          	addi	a0,a0,-70 # 80007210 <etext+0x210>
    8000225e:	d82fe0ef          	jal	800007e0 <panic>

0000000080002262 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002262:	7179                	addi	sp,sp,-48
    80002264:	f406                	sd	ra,40(sp)
    80002266:	f022                	sd	s0,32(sp)
    80002268:	ec26                	sd	s1,24(sp)
    8000226a:	e84a                	sd	s2,16(sp)
    8000226c:	e44e                	sd	s3,8(sp)
    8000226e:	1800                	addi	s0,sp,48
    80002270:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002272:	0000e497          	auipc	s1,0xe
    80002276:	b8648493          	addi	s1,s1,-1146 # 8000fdf8 <proc>
    8000227a:	00013997          	auipc	s3,0x13
    8000227e:	77e98993          	addi	s3,s3,1918 # 800159f8 <tickslock>
    acquire(&p->lock);
    80002282:	8526                	mv	a0,s1
    80002284:	94bfe0ef          	jal	80000bce <acquire>
    if(p->pid == pid){
    80002288:	589c                	lw	a5,48(s1)
    8000228a:	01278b63          	beq	a5,s2,800022a0 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000228e:	8526                	mv	a0,s1
    80002290:	9d7fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002294:	17048493          	addi	s1,s1,368
    80002298:	ff3495e3          	bne	s1,s3,80002282 <kkill+0x20>
  }
  return -1;
    8000229c:	557d                	li	a0,-1
    8000229e:	a819                	j	800022b4 <kkill+0x52>
      p->killed = 1;
    800022a0:	4785                	li	a5,1
    800022a2:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022a4:	4c98                	lw	a4,24(s1)
    800022a6:	4789                	li	a5,2
    800022a8:	00f70d63          	beq	a4,a5,800022c2 <kkill+0x60>
      release(&p->lock);
    800022ac:	8526                	mv	a0,s1
    800022ae:	9b9fe0ef          	jal	80000c66 <release>
      return 0;
    800022b2:	4501                	li	a0,0
}
    800022b4:	70a2                	ld	ra,40(sp)
    800022b6:	7402                	ld	s0,32(sp)
    800022b8:	64e2                	ld	s1,24(sp)
    800022ba:	6942                	ld	s2,16(sp)
    800022bc:	69a2                	ld	s3,8(sp)
    800022be:	6145                	addi	sp,sp,48
    800022c0:	8082                	ret
        p->state = RUNNABLE;
    800022c2:	478d                	li	a5,3
    800022c4:	cc9c                	sw	a5,24(s1)
    800022c6:	b7dd                	j	800022ac <kkill+0x4a>

00000000800022c8 <setkilled>:

void
setkilled(struct proc *p)
{
    800022c8:	1101                	addi	sp,sp,-32
    800022ca:	ec06                	sd	ra,24(sp)
    800022cc:	e822                	sd	s0,16(sp)
    800022ce:	e426                	sd	s1,8(sp)
    800022d0:	1000                	addi	s0,sp,32
    800022d2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022d4:	8fbfe0ef          	jal	80000bce <acquire>
  p->killed = 1;
    800022d8:	4785                	li	a5,1
    800022da:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022dc:	8526                	mv	a0,s1
    800022de:	989fe0ef          	jal	80000c66 <release>
}
    800022e2:	60e2                	ld	ra,24(sp)
    800022e4:	6442                	ld	s0,16(sp)
    800022e6:	64a2                	ld	s1,8(sp)
    800022e8:	6105                	addi	sp,sp,32
    800022ea:	8082                	ret

00000000800022ec <killed>:

int
killed(struct proc *p)
{
    800022ec:	1101                	addi	sp,sp,-32
    800022ee:	ec06                	sd	ra,24(sp)
    800022f0:	e822                	sd	s0,16(sp)
    800022f2:	e426                	sd	s1,8(sp)
    800022f4:	e04a                	sd	s2,0(sp)
    800022f6:	1000                	addi	s0,sp,32
    800022f8:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800022fa:	8d5fe0ef          	jal	80000bce <acquire>
  k = p->killed;
    800022fe:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002302:	8526                	mv	a0,s1
    80002304:	963fe0ef          	jal	80000c66 <release>
  return k;
}
    80002308:	854a                	mv	a0,s2
    8000230a:	60e2                	ld	ra,24(sp)
    8000230c:	6442                	ld	s0,16(sp)
    8000230e:	64a2                	ld	s1,8(sp)
    80002310:	6902                	ld	s2,0(sp)
    80002312:	6105                	addi	sp,sp,32
    80002314:	8082                	ret

0000000080002316 <kwait>:
{
    80002316:	715d                	addi	sp,sp,-80
    80002318:	e486                	sd	ra,72(sp)
    8000231a:	e0a2                	sd	s0,64(sp)
    8000231c:	fc26                	sd	s1,56(sp)
    8000231e:	f84a                	sd	s2,48(sp)
    80002320:	f44e                	sd	s3,40(sp)
    80002322:	f052                	sd	s4,32(sp)
    80002324:	ec56                	sd	s5,24(sp)
    80002326:	e85a                	sd	s6,16(sp)
    80002328:	e45e                	sd	s7,8(sp)
    8000232a:	e062                	sd	s8,0(sp)
    8000232c:	0880                	addi	s0,sp,80
    8000232e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002330:	f16ff0ef          	jal	80001a46 <myproc>
    80002334:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002336:	0000d517          	auipc	a0,0xd
    8000233a:	6aa50513          	addi	a0,a0,1706 # 8000f9e0 <wait_lock>
    8000233e:	891fe0ef          	jal	80000bce <acquire>
    havekids = 0;
    80002342:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002344:	4a15                	li	s4,5
        havekids = 1;
    80002346:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002348:	00013997          	auipc	s3,0x13
    8000234c:	6b098993          	addi	s3,s3,1712 # 800159f8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002350:	0000dc17          	auipc	s8,0xd
    80002354:	690c0c13          	addi	s8,s8,1680 # 8000f9e0 <wait_lock>
    80002358:	a871                	j	800023f4 <kwait+0xde>
          pid = pp->pid;
    8000235a:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000235e:	000b0c63          	beqz	s6,80002376 <kwait+0x60>
    80002362:	4691                	li	a3,4
    80002364:	02c48613          	addi	a2,s1,44
    80002368:	85da                	mv	a1,s6
    8000236a:	05093503          	ld	a0,80(s2)
    8000236e:	a8eff0ef          	jal	800015fc <copyout>
    80002372:	02054b63          	bltz	a0,800023a8 <kwait+0x92>
          freeproc(pp);
    80002376:	8526                	mv	a0,s1
    80002378:	89fff0ef          	jal	80001c16 <freeproc>
          release(&pp->lock);
    8000237c:	8526                	mv	a0,s1
    8000237e:	8e9fe0ef          	jal	80000c66 <release>
          release(&wait_lock);
    80002382:	0000d517          	auipc	a0,0xd
    80002386:	65e50513          	addi	a0,a0,1630 # 8000f9e0 <wait_lock>
    8000238a:	8ddfe0ef          	jal	80000c66 <release>
}
    8000238e:	854e                	mv	a0,s3
    80002390:	60a6                	ld	ra,72(sp)
    80002392:	6406                	ld	s0,64(sp)
    80002394:	74e2                	ld	s1,56(sp)
    80002396:	7942                	ld	s2,48(sp)
    80002398:	79a2                	ld	s3,40(sp)
    8000239a:	7a02                	ld	s4,32(sp)
    8000239c:	6ae2                	ld	s5,24(sp)
    8000239e:	6b42                	ld	s6,16(sp)
    800023a0:	6ba2                	ld	s7,8(sp)
    800023a2:	6c02                	ld	s8,0(sp)
    800023a4:	6161                	addi	sp,sp,80
    800023a6:	8082                	ret
            release(&pp->lock);
    800023a8:	8526                	mv	a0,s1
    800023aa:	8bdfe0ef          	jal	80000c66 <release>
            release(&wait_lock);
    800023ae:	0000d517          	auipc	a0,0xd
    800023b2:	63250513          	addi	a0,a0,1586 # 8000f9e0 <wait_lock>
    800023b6:	8b1fe0ef          	jal	80000c66 <release>
            return -1;
    800023ba:	59fd                	li	s3,-1
    800023bc:	bfc9                	j	8000238e <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023be:	17048493          	addi	s1,s1,368
    800023c2:	03348063          	beq	s1,s3,800023e2 <kwait+0xcc>
      if(pp->parent == p){
    800023c6:	7c9c                	ld	a5,56(s1)
    800023c8:	ff279be3          	bne	a5,s2,800023be <kwait+0xa8>
        acquire(&pp->lock);
    800023cc:	8526                	mv	a0,s1
    800023ce:	801fe0ef          	jal	80000bce <acquire>
        if(pp->state == ZOMBIE){
    800023d2:	4c9c                	lw	a5,24(s1)
    800023d4:	f94783e3          	beq	a5,s4,8000235a <kwait+0x44>
        release(&pp->lock);
    800023d8:	8526                	mv	a0,s1
    800023da:	88dfe0ef          	jal	80000c66 <release>
        havekids = 1;
    800023de:	8756                	mv	a4,s5
    800023e0:	bff9                	j	800023be <kwait+0xa8>
    if(!havekids || killed(p)){
    800023e2:	cf19                	beqz	a4,80002400 <kwait+0xea>
    800023e4:	854a                	mv	a0,s2
    800023e6:	f07ff0ef          	jal	800022ec <killed>
    800023ea:	e919                	bnez	a0,80002400 <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023ec:	85e2                	mv	a1,s8
    800023ee:	854a                	mv	a0,s2
    800023f0:	cc5ff0ef          	jal	800020b4 <sleep>
    havekids = 0;
    800023f4:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023f6:	0000e497          	auipc	s1,0xe
    800023fa:	a0248493          	addi	s1,s1,-1534 # 8000fdf8 <proc>
    800023fe:	b7e1                	j	800023c6 <kwait+0xb0>
      release(&wait_lock);
    80002400:	0000d517          	auipc	a0,0xd
    80002404:	5e050513          	addi	a0,a0,1504 # 8000f9e0 <wait_lock>
    80002408:	85ffe0ef          	jal	80000c66 <release>
      return -1;
    8000240c:	59fd                	li	s3,-1
    8000240e:	b741                	j	8000238e <kwait+0x78>

0000000080002410 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002410:	7179                	addi	sp,sp,-48
    80002412:	f406                	sd	ra,40(sp)
    80002414:	f022                	sd	s0,32(sp)
    80002416:	ec26                	sd	s1,24(sp)
    80002418:	e84a                	sd	s2,16(sp)
    8000241a:	e44e                	sd	s3,8(sp)
    8000241c:	e052                	sd	s4,0(sp)
    8000241e:	1800                	addi	s0,sp,48
    80002420:	84aa                	mv	s1,a0
    80002422:	892e                	mv	s2,a1
    80002424:	89b2                	mv	s3,a2
    80002426:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002428:	e1eff0ef          	jal	80001a46 <myproc>
  if(user_dst){
    8000242c:	cc99                	beqz	s1,8000244a <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000242e:	86d2                	mv	a3,s4
    80002430:	864e                	mv	a2,s3
    80002432:	85ca                	mv	a1,s2
    80002434:	6928                	ld	a0,80(a0)
    80002436:	9c6ff0ef          	jal	800015fc <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000243a:	70a2                	ld	ra,40(sp)
    8000243c:	7402                	ld	s0,32(sp)
    8000243e:	64e2                	ld	s1,24(sp)
    80002440:	6942                	ld	s2,16(sp)
    80002442:	69a2                	ld	s3,8(sp)
    80002444:	6a02                	ld	s4,0(sp)
    80002446:	6145                	addi	sp,sp,48
    80002448:	8082                	ret
    memmove((char *)dst, src, len);
    8000244a:	000a061b          	sext.w	a2,s4
    8000244e:	85ce                	mv	a1,s3
    80002450:	854a                	mv	a0,s2
    80002452:	8adfe0ef          	jal	80000cfe <memmove>
    return 0;
    80002456:	8526                	mv	a0,s1
    80002458:	b7cd                	j	8000243a <either_copyout+0x2a>

000000008000245a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000245a:	7179                	addi	sp,sp,-48
    8000245c:	f406                	sd	ra,40(sp)
    8000245e:	f022                	sd	s0,32(sp)
    80002460:	ec26                	sd	s1,24(sp)
    80002462:	e84a                	sd	s2,16(sp)
    80002464:	e44e                	sd	s3,8(sp)
    80002466:	e052                	sd	s4,0(sp)
    80002468:	1800                	addi	s0,sp,48
    8000246a:	892a                	mv	s2,a0
    8000246c:	84ae                	mv	s1,a1
    8000246e:	89b2                	mv	s3,a2
    80002470:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002472:	dd4ff0ef          	jal	80001a46 <myproc>
  if(user_src){
    80002476:	cc99                	beqz	s1,80002494 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002478:	86d2                	mv	a3,s4
    8000247a:	864e                	mv	a2,s3
    8000247c:	85ca                	mv	a1,s2
    8000247e:	6928                	ld	a0,80(a0)
    80002480:	a60ff0ef          	jal	800016e0 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002484:	70a2                	ld	ra,40(sp)
    80002486:	7402                	ld	s0,32(sp)
    80002488:	64e2                	ld	s1,24(sp)
    8000248a:	6942                	ld	s2,16(sp)
    8000248c:	69a2                	ld	s3,8(sp)
    8000248e:	6a02                	ld	s4,0(sp)
    80002490:	6145                	addi	sp,sp,48
    80002492:	8082                	ret
    memmove(dst, (char*)src, len);
    80002494:	000a061b          	sext.w	a2,s4
    80002498:	85ce                	mv	a1,s3
    8000249a:	854a                	mv	a0,s2
    8000249c:	863fe0ef          	jal	80000cfe <memmove>
    return 0;
    800024a0:	8526                	mv	a0,s1
    800024a2:	b7cd                	j	80002484 <either_copyin+0x2a>

00000000800024a4 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800024a4:	715d                	addi	sp,sp,-80
    800024a6:	e486                	sd	ra,72(sp)
    800024a8:	e0a2                	sd	s0,64(sp)
    800024aa:	fc26                	sd	s1,56(sp)
    800024ac:	f84a                	sd	s2,48(sp)
    800024ae:	f44e                	sd	s3,40(sp)
    800024b0:	f052                	sd	s4,32(sp)
    800024b2:	ec56                	sd	s5,24(sp)
    800024b4:	e85a                	sd	s6,16(sp)
    800024b6:	e45e                	sd	s7,8(sp)
    800024b8:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800024ba:	00005517          	auipc	a0,0x5
    800024be:	bbe50513          	addi	a0,a0,-1090 # 80007078 <etext+0x78>
    800024c2:	838fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800024c6:	0000e497          	auipc	s1,0xe
    800024ca:	a8a48493          	addi	s1,s1,-1398 # 8000ff50 <proc+0x158>
    800024ce:	00013917          	auipc	s2,0x13
    800024d2:	68290913          	addi	s2,s2,1666 # 80015b50 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024d6:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800024d8:	00005997          	auipc	s3,0x5
    800024dc:	d4898993          	addi	s3,s3,-696 # 80007220 <etext+0x220>
    printf("%d %s %s", p->pid, state, p->name);
    800024e0:	00005a97          	auipc	s5,0x5
    800024e4:	d48a8a93          	addi	s5,s5,-696 # 80007228 <etext+0x228>
    printf("\n");
    800024e8:	00005a17          	auipc	s4,0x5
    800024ec:	b90a0a13          	addi	s4,s4,-1136 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024f0:	00005b97          	auipc	s7,0x5
    800024f4:	258b8b93          	addi	s7,s7,600 # 80007748 <states.0>
    800024f8:	a829                	j	80002512 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800024fa:	ed86a583          	lw	a1,-296(a3)
    800024fe:	8556                	mv	a0,s5
    80002500:	ffbfd0ef          	jal	800004fa <printf>
    printf("\n");
    80002504:	8552                	mv	a0,s4
    80002506:	ff5fd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000250a:	17048493          	addi	s1,s1,368
    8000250e:	03248263          	beq	s1,s2,80002532 <procdump+0x8e>
    if(p->state == UNUSED)
    80002512:	86a6                	mv	a3,s1
    80002514:	ec04a783          	lw	a5,-320(s1)
    80002518:	dbed                	beqz	a5,8000250a <procdump+0x66>
      state = "???";
    8000251a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000251c:	fcfb6fe3          	bltu	s6,a5,800024fa <procdump+0x56>
    80002520:	02079713          	slli	a4,a5,0x20
    80002524:	01d75793          	srli	a5,a4,0x1d
    80002528:	97de                	add	a5,a5,s7
    8000252a:	6390                	ld	a2,0(a5)
    8000252c:	f679                	bnez	a2,800024fa <procdump+0x56>
      state = "???";
    8000252e:	864e                	mv	a2,s3
    80002530:	b7e9                	j	800024fa <procdump+0x56>
  }
}
    80002532:	60a6                	ld	ra,72(sp)
    80002534:	6406                	ld	s0,64(sp)
    80002536:	74e2                	ld	s1,56(sp)
    80002538:	7942                	ld	s2,48(sp)
    8000253a:	79a2                	ld	s3,40(sp)
    8000253c:	7a02                	ld	s4,32(sp)
    8000253e:	6ae2                	ld	s5,24(sp)
    80002540:	6b42                	ld	s6,16(sp)
    80002542:	6ba2                	ld	s7,8(sp)
    80002544:	6161                	addi	sp,sp,80
    80002546:	8082                	ret

0000000080002548 <settickets>:

// Set lottery tickets for a process with given pid
int
settickets(int pid, int tickets)
{
    80002548:	7179                	addi	sp,sp,-48
    8000254a:	f406                	sd	ra,40(sp)
    8000254c:	f022                	sd	s0,32(sp)
    8000254e:	ec26                	sd	s1,24(sp)
    80002550:	e84a                	sd	s2,16(sp)
    80002552:	e44e                	sd	s3,8(sp)
    80002554:	e052                	sd	s4,0(sp)
    80002556:	1800                	addi	s0,sp,48
    80002558:	892a                	mv	s2,a0
    8000255a:	8a2e                	mv	s4,a1
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++){
    8000255c:	0000e497          	auipc	s1,0xe
    80002560:	89c48493          	addi	s1,s1,-1892 # 8000fdf8 <proc>
    80002564:	00013997          	auipc	s3,0x13
    80002568:	49498993          	addi	s3,s3,1172 # 800159f8 <tickslock>
    acquire(&p->lock);
    8000256c:	8526                	mv	a0,s1
    8000256e:	e60fe0ef          	jal	80000bce <acquire>
    if(p->pid == pid){
    80002572:	589c                	lw	a5,48(s1)
    80002574:	01278b63          	beq	a5,s2,8000258a <settickets+0x42>
      p->ticket = tickets;
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002578:	8526                	mv	a0,s1
    8000257a:	eecfe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000257e:	17048493          	addi	s1,s1,368
    80002582:	ff3495e3          	bne	s1,s3,8000256c <settickets+0x24>
  }
  return -1;  // PID not found
    80002586:	557d                	li	a0,-1
    80002588:	a039                	j	80002596 <settickets+0x4e>
      p->ticket = tickets;
    8000258a:	1744a423          	sw	s4,360(s1)
      release(&p->lock);
    8000258e:	8526                	mv	a0,s1
    80002590:	ed6fe0ef          	jal	80000c66 <release>
      return 0;
    80002594:	4501                	li	a0,0
}
    80002596:	70a2                	ld	ra,40(sp)
    80002598:	7402                	ld	s0,32(sp)
    8000259a:	64e2                	ld	s1,24(sp)
    8000259c:	6942                	ld	s2,16(sp)
    8000259e:	69a2                	ld	s3,8(sp)
    800025a0:	6a02                	ld	s4,0(sp)
    800025a2:	6145                	addi	sp,sp,48
    800025a4:	8082                	ret

00000000800025a6 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800025a6:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800025aa:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800025ae:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800025b0:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800025b2:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800025b6:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800025ba:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800025be:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800025c2:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800025c6:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800025ca:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800025ce:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800025d2:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800025d6:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800025da:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800025de:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800025e2:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800025e4:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800025e6:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800025ea:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800025ee:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800025f2:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800025f6:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800025fa:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800025fe:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002602:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002606:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    8000260a:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000260e:	8082                	ret

0000000080002610 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002610:	1141                	addi	sp,sp,-16
    80002612:	e406                	sd	ra,8(sp)
    80002614:	e022                	sd	s0,0(sp)
    80002616:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002618:	00005597          	auipc	a1,0x5
    8000261c:	c5058593          	addi	a1,a1,-944 # 80007268 <etext+0x268>
    80002620:	00013517          	auipc	a0,0x13
    80002624:	3d850513          	addi	a0,a0,984 # 800159f8 <tickslock>
    80002628:	d26fe0ef          	jal	80000b4e <initlock>
}
    8000262c:	60a2                	ld	ra,8(sp)
    8000262e:	6402                	ld	s0,0(sp)
    80002630:	0141                	addi	sp,sp,16
    80002632:	8082                	ret

0000000080002634 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002634:	1141                	addi	sp,sp,-16
    80002636:	e422                	sd	s0,8(sp)
    80002638:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000263a:	00003797          	auipc	a5,0x3
    8000263e:	f8678793          	addi	a5,a5,-122 # 800055c0 <kernelvec>
    80002642:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002646:	6422                	ld	s0,8(sp)
    80002648:	0141                	addi	sp,sp,16
    8000264a:	8082                	ret

000000008000264c <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000264c:	1141                	addi	sp,sp,-16
    8000264e:	e406                	sd	ra,8(sp)
    80002650:	e022                	sd	s0,0(sp)
    80002652:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002654:	bf2ff0ef          	jal	80001a46 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002658:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000265c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000265e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002662:	04000737          	lui	a4,0x4000
    80002666:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002668:	0732                	slli	a4,a4,0xc
    8000266a:	00004797          	auipc	a5,0x4
    8000266e:	99678793          	addi	a5,a5,-1642 # 80006000 <_trampoline>
    80002672:	00004697          	auipc	a3,0x4
    80002676:	98e68693          	addi	a3,a3,-1650 # 80006000 <_trampoline>
    8000267a:	8f95                	sub	a5,a5,a3
    8000267c:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000267e:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002682:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002684:	18002773          	csrr	a4,satp
    80002688:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000268a:	6d38                	ld	a4,88(a0)
    8000268c:	613c                	ld	a5,64(a0)
    8000268e:	6685                	lui	a3,0x1
    80002690:	97b6                	add	a5,a5,a3
    80002692:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002694:	6d3c                	ld	a5,88(a0)
    80002696:	00000717          	auipc	a4,0x0
    8000269a:	0f870713          	addi	a4,a4,248 # 8000278e <usertrap>
    8000269e:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026a0:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026a2:	8712                	mv	a4,tp
    800026a4:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026a6:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026aa:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026ae:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026b2:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026b6:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026b8:	6f9c                	ld	a5,24(a5)
    800026ba:	14179073          	csrw	sepc,a5
}
    800026be:	60a2                	ld	ra,8(sp)
    800026c0:	6402                	ld	s0,0(sp)
    800026c2:	0141                	addi	sp,sp,16
    800026c4:	8082                	ret

00000000800026c6 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026c6:	1101                	addi	sp,sp,-32
    800026c8:	ec06                	sd	ra,24(sp)
    800026ca:	e822                	sd	s0,16(sp)
    800026cc:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800026ce:	b4cff0ef          	jal	80001a1a <cpuid>
    800026d2:	cd11                	beqz	a0,800026ee <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800026d4:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800026d8:	000f4737          	lui	a4,0xf4
    800026dc:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800026e0:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800026e2:	14d79073          	csrw	stimecmp,a5
}
    800026e6:	60e2                	ld	ra,24(sp)
    800026e8:	6442                	ld	s0,16(sp)
    800026ea:	6105                	addi	sp,sp,32
    800026ec:	8082                	ret
    800026ee:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800026f0:	00013497          	auipc	s1,0x13
    800026f4:	30848493          	addi	s1,s1,776 # 800159f8 <tickslock>
    800026f8:	8526                	mv	a0,s1
    800026fa:	cd4fe0ef          	jal	80000bce <acquire>
    ticks++;
    800026fe:	00005517          	auipc	a0,0x5
    80002702:	18a50513          	addi	a0,a0,394 # 80007888 <ticks>
    80002706:	411c                	lw	a5,0(a0)
    80002708:	2785                	addiw	a5,a5,1
    8000270a:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000270c:	9f5ff0ef          	jal	80002100 <wakeup>
    release(&tickslock);
    80002710:	8526                	mv	a0,s1
    80002712:	d54fe0ef          	jal	80000c66 <release>
    80002716:	64a2                	ld	s1,8(sp)
    80002718:	bf75                	j	800026d4 <clockintr+0xe>

000000008000271a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000271a:	1101                	addi	sp,sp,-32
    8000271c:	ec06                	sd	ra,24(sp)
    8000271e:	e822                	sd	s0,16(sp)
    80002720:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002722:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002726:	57fd                	li	a5,-1
    80002728:	17fe                	slli	a5,a5,0x3f
    8000272a:	07a5                	addi	a5,a5,9
    8000272c:	00f70c63          	beq	a4,a5,80002744 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002730:	57fd                	li	a5,-1
    80002732:	17fe                	slli	a5,a5,0x3f
    80002734:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002736:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002738:	04f70763          	beq	a4,a5,80002786 <devintr+0x6c>
  }
}
    8000273c:	60e2                	ld	ra,24(sp)
    8000273e:	6442                	ld	s0,16(sp)
    80002740:	6105                	addi	sp,sp,32
    80002742:	8082                	ret
    80002744:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002746:	727020ef          	jal	8000566c <plic_claim>
    8000274a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000274c:	47a9                	li	a5,10
    8000274e:	00f50963          	beq	a0,a5,80002760 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002752:	4785                	li	a5,1
    80002754:	00f50963          	beq	a0,a5,80002766 <devintr+0x4c>
    return 1;
    80002758:	4505                	li	a0,1
    } else if(irq){
    8000275a:	e889                	bnez	s1,8000276c <devintr+0x52>
    8000275c:	64a2                	ld	s1,8(sp)
    8000275e:	bff9                	j	8000273c <devintr+0x22>
      uartintr();
    80002760:	a50fe0ef          	jal	800009b0 <uartintr>
    if(irq)
    80002764:	a819                	j	8000277a <devintr+0x60>
      virtio_disk_intr();
    80002766:	3cc030ef          	jal	80005b32 <virtio_disk_intr>
    if(irq)
    8000276a:	a801                	j	8000277a <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    8000276c:	85a6                	mv	a1,s1
    8000276e:	00005517          	auipc	a0,0x5
    80002772:	b0250513          	addi	a0,a0,-1278 # 80007270 <etext+0x270>
    80002776:	d85fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    8000277a:	8526                	mv	a0,s1
    8000277c:	711020ef          	jal	8000568c <plic_complete>
    return 1;
    80002780:	4505                	li	a0,1
    80002782:	64a2                	ld	s1,8(sp)
    80002784:	bf65                	j	8000273c <devintr+0x22>
    clockintr();
    80002786:	f41ff0ef          	jal	800026c6 <clockintr>
    return 2;
    8000278a:	4509                	li	a0,2
    8000278c:	bf45                	j	8000273c <devintr+0x22>

000000008000278e <usertrap>:
{
    8000278e:	1101                	addi	sp,sp,-32
    80002790:	ec06                	sd	ra,24(sp)
    80002792:	e822                	sd	s0,16(sp)
    80002794:	e426                	sd	s1,8(sp)
    80002796:	e04a                	sd	s2,0(sp)
    80002798:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000279a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000279e:	1007f793          	andi	a5,a5,256
    800027a2:	eba5                	bnez	a5,80002812 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027a4:	00003797          	auipc	a5,0x3
    800027a8:	e1c78793          	addi	a5,a5,-484 # 800055c0 <kernelvec>
    800027ac:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800027b0:	a96ff0ef          	jal	80001a46 <myproc>
    800027b4:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800027b6:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027b8:	14102773          	csrr	a4,sepc
    800027bc:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027be:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800027c2:	47a1                	li	a5,8
    800027c4:	04f70d63          	beq	a4,a5,8000281e <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    800027c8:	f53ff0ef          	jal	8000271a <devintr>
    800027cc:	892a                	mv	s2,a0
    800027ce:	e945                	bnez	a0,8000287e <usertrap+0xf0>
    800027d0:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800027d4:	47bd                	li	a5,15
    800027d6:	08f70863          	beq	a4,a5,80002866 <usertrap+0xd8>
    800027da:	14202773          	csrr	a4,scause
    800027de:	47b5                	li	a5,13
    800027e0:	08f70363          	beq	a4,a5,80002866 <usertrap+0xd8>
    800027e4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800027e8:	5890                	lw	a2,48(s1)
    800027ea:	00005517          	auipc	a0,0x5
    800027ee:	ac650513          	addi	a0,a0,-1338 # 800072b0 <etext+0x2b0>
    800027f2:	d09fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027f6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800027fa:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800027fe:	00005517          	auipc	a0,0x5
    80002802:	ae250513          	addi	a0,a0,-1310 # 800072e0 <etext+0x2e0>
    80002806:	cf5fd0ef          	jal	800004fa <printf>
    setkilled(p);
    8000280a:	8526                	mv	a0,s1
    8000280c:	abdff0ef          	jal	800022c8 <setkilled>
    80002810:	a035                	j	8000283c <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002812:	00005517          	auipc	a0,0x5
    80002816:	a7e50513          	addi	a0,a0,-1410 # 80007290 <etext+0x290>
    8000281a:	fc7fd0ef          	jal	800007e0 <panic>
    if(killed(p))
    8000281e:	acfff0ef          	jal	800022ec <killed>
    80002822:	ed15                	bnez	a0,8000285e <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002824:	6cb8                	ld	a4,88(s1)
    80002826:	6f1c                	ld	a5,24(a4)
    80002828:	0791                	addi	a5,a5,4
    8000282a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000282c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002830:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002834:	10079073          	csrw	sstatus,a5
    syscall();
    80002838:	246000ef          	jal	80002a7e <syscall>
  if(killed(p))
    8000283c:	8526                	mv	a0,s1
    8000283e:	aafff0ef          	jal	800022ec <killed>
    80002842:	e139                	bnez	a0,80002888 <usertrap+0xfa>
  prepare_return();
    80002844:	e09ff0ef          	jal	8000264c <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002848:	68a8                	ld	a0,80(s1)
    8000284a:	8131                	srli	a0,a0,0xc
    8000284c:	57fd                	li	a5,-1
    8000284e:	17fe                	slli	a5,a5,0x3f
    80002850:	8d5d                	or	a0,a0,a5
}
    80002852:	60e2                	ld	ra,24(sp)
    80002854:	6442                	ld	s0,16(sp)
    80002856:	64a2                	ld	s1,8(sp)
    80002858:	6902                	ld	s2,0(sp)
    8000285a:	6105                	addi	sp,sp,32
    8000285c:	8082                	ret
      kexit(-1);
    8000285e:	557d                	li	a0,-1
    80002860:	961ff0ef          	jal	800021c0 <kexit>
    80002864:	b7c1                	j	80002824 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002866:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000286a:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    8000286e:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002870:	00163613          	seqz	a2,a2
    80002874:	68a8                	ld	a0,80(s1)
    80002876:	d05fe0ef          	jal	8000157a <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000287a:	f169                	bnez	a0,8000283c <usertrap+0xae>
    8000287c:	b7a5                	j	800027e4 <usertrap+0x56>
  if(killed(p))
    8000287e:	8526                	mv	a0,s1
    80002880:	a6dff0ef          	jal	800022ec <killed>
    80002884:	c511                	beqz	a0,80002890 <usertrap+0x102>
    80002886:	a011                	j	8000288a <usertrap+0xfc>
    80002888:	4901                	li	s2,0
    kexit(-1);
    8000288a:	557d                	li	a0,-1
    8000288c:	935ff0ef          	jal	800021c0 <kexit>
  if(which_dev == 2)
    80002890:	4789                	li	a5,2
    80002892:	faf919e3          	bne	s2,a5,80002844 <usertrap+0xb6>
    yield();
    80002896:	ff2ff0ef          	jal	80002088 <yield>
    8000289a:	b76d                	j	80002844 <usertrap+0xb6>

000000008000289c <kerneltrap>:
{
    8000289c:	7179                	addi	sp,sp,-48
    8000289e:	f406                	sd	ra,40(sp)
    800028a0:	f022                	sd	s0,32(sp)
    800028a2:	ec26                	sd	s1,24(sp)
    800028a4:	e84a                	sd	s2,16(sp)
    800028a6:	e44e                	sd	s3,8(sp)
    800028a8:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028aa:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028ae:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028b2:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800028b6:	1004f793          	andi	a5,s1,256
    800028ba:	c795                	beqz	a5,800028e6 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028bc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800028c0:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800028c2:	eb85                	bnez	a5,800028f2 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800028c4:	e57ff0ef          	jal	8000271a <devintr>
    800028c8:	c91d                	beqz	a0,800028fe <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800028ca:	4789                	li	a5,2
    800028cc:	04f50a63          	beq	a0,a5,80002920 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028d0:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028d4:	10049073          	csrw	sstatus,s1
}
    800028d8:	70a2                	ld	ra,40(sp)
    800028da:	7402                	ld	s0,32(sp)
    800028dc:	64e2                	ld	s1,24(sp)
    800028de:	6942                	ld	s2,16(sp)
    800028e0:	69a2                	ld	s3,8(sp)
    800028e2:	6145                	addi	sp,sp,48
    800028e4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800028e6:	00005517          	auipc	a0,0x5
    800028ea:	a2250513          	addi	a0,a0,-1502 # 80007308 <etext+0x308>
    800028ee:	ef3fd0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    800028f2:	00005517          	auipc	a0,0x5
    800028f6:	a3e50513          	addi	a0,a0,-1474 # 80007330 <etext+0x330>
    800028fa:	ee7fd0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028fe:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002902:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002906:	85ce                	mv	a1,s3
    80002908:	00005517          	auipc	a0,0x5
    8000290c:	a4850513          	addi	a0,a0,-1464 # 80007350 <etext+0x350>
    80002910:	bebfd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    80002914:	00005517          	auipc	a0,0x5
    80002918:	a6450513          	addi	a0,a0,-1436 # 80007378 <etext+0x378>
    8000291c:	ec5fd0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002920:	926ff0ef          	jal	80001a46 <myproc>
    80002924:	d555                	beqz	a0,800028d0 <kerneltrap+0x34>
    yield();
    80002926:	f62ff0ef          	jal	80002088 <yield>
    8000292a:	b75d                	j	800028d0 <kerneltrap+0x34>

000000008000292c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000292c:	1101                	addi	sp,sp,-32
    8000292e:	ec06                	sd	ra,24(sp)
    80002930:	e822                	sd	s0,16(sp)
    80002932:	e426                	sd	s1,8(sp)
    80002934:	1000                	addi	s0,sp,32
    80002936:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002938:	90eff0ef          	jal	80001a46 <myproc>
  switch (n) {
    8000293c:	4795                	li	a5,5
    8000293e:	0497e163          	bltu	a5,s1,80002980 <argraw+0x54>
    80002942:	048a                	slli	s1,s1,0x2
    80002944:	00005717          	auipc	a4,0x5
    80002948:	e3470713          	addi	a4,a4,-460 # 80007778 <states.0+0x30>
    8000294c:	94ba                	add	s1,s1,a4
    8000294e:	409c                	lw	a5,0(s1)
    80002950:	97ba                	add	a5,a5,a4
    80002952:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002954:	6d3c                	ld	a5,88(a0)
    80002956:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002958:	60e2                	ld	ra,24(sp)
    8000295a:	6442                	ld	s0,16(sp)
    8000295c:	64a2                	ld	s1,8(sp)
    8000295e:	6105                	addi	sp,sp,32
    80002960:	8082                	ret
    return p->trapframe->a1;
    80002962:	6d3c                	ld	a5,88(a0)
    80002964:	7fa8                	ld	a0,120(a5)
    80002966:	bfcd                	j	80002958 <argraw+0x2c>
    return p->trapframe->a2;
    80002968:	6d3c                	ld	a5,88(a0)
    8000296a:	63c8                	ld	a0,128(a5)
    8000296c:	b7f5                	j	80002958 <argraw+0x2c>
    return p->trapframe->a3;
    8000296e:	6d3c                	ld	a5,88(a0)
    80002970:	67c8                	ld	a0,136(a5)
    80002972:	b7dd                	j	80002958 <argraw+0x2c>
    return p->trapframe->a4;
    80002974:	6d3c                	ld	a5,88(a0)
    80002976:	6bc8                	ld	a0,144(a5)
    80002978:	b7c5                	j	80002958 <argraw+0x2c>
    return p->trapframe->a5;
    8000297a:	6d3c                	ld	a5,88(a0)
    8000297c:	6fc8                	ld	a0,152(a5)
    8000297e:	bfe9                	j	80002958 <argraw+0x2c>
  panic("argraw");
    80002980:	00005517          	auipc	a0,0x5
    80002984:	a0850513          	addi	a0,a0,-1528 # 80007388 <etext+0x388>
    80002988:	e59fd0ef          	jal	800007e0 <panic>

000000008000298c <fetchaddr>:
{
    8000298c:	1101                	addi	sp,sp,-32
    8000298e:	ec06                	sd	ra,24(sp)
    80002990:	e822                	sd	s0,16(sp)
    80002992:	e426                	sd	s1,8(sp)
    80002994:	e04a                	sd	s2,0(sp)
    80002996:	1000                	addi	s0,sp,32
    80002998:	84aa                	mv	s1,a0
    8000299a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000299c:	8aaff0ef          	jal	80001a46 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800029a0:	653c                	ld	a5,72(a0)
    800029a2:	02f4f663          	bgeu	s1,a5,800029ce <fetchaddr+0x42>
    800029a6:	00848713          	addi	a4,s1,8
    800029aa:	02e7e463          	bltu	a5,a4,800029d2 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800029ae:	46a1                	li	a3,8
    800029b0:	8626                	mv	a2,s1
    800029b2:	85ca                	mv	a1,s2
    800029b4:	6928                	ld	a0,80(a0)
    800029b6:	d2bfe0ef          	jal	800016e0 <copyin>
    800029ba:	00a03533          	snez	a0,a0
    800029be:	40a00533          	neg	a0,a0
}
    800029c2:	60e2                	ld	ra,24(sp)
    800029c4:	6442                	ld	s0,16(sp)
    800029c6:	64a2                	ld	s1,8(sp)
    800029c8:	6902                	ld	s2,0(sp)
    800029ca:	6105                	addi	sp,sp,32
    800029cc:	8082                	ret
    return -1;
    800029ce:	557d                	li	a0,-1
    800029d0:	bfcd                	j	800029c2 <fetchaddr+0x36>
    800029d2:	557d                	li	a0,-1
    800029d4:	b7fd                	j	800029c2 <fetchaddr+0x36>

00000000800029d6 <fetchstr>:
{
    800029d6:	7179                	addi	sp,sp,-48
    800029d8:	f406                	sd	ra,40(sp)
    800029da:	f022                	sd	s0,32(sp)
    800029dc:	ec26                	sd	s1,24(sp)
    800029de:	e84a                	sd	s2,16(sp)
    800029e0:	e44e                	sd	s3,8(sp)
    800029e2:	1800                	addi	s0,sp,48
    800029e4:	892a                	mv	s2,a0
    800029e6:	84ae                	mv	s1,a1
    800029e8:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800029ea:	85cff0ef          	jal	80001a46 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800029ee:	86ce                	mv	a3,s3
    800029f0:	864a                	mv	a2,s2
    800029f2:	85a6                	mv	a1,s1
    800029f4:	6928                	ld	a0,80(a0)
    800029f6:	aadfe0ef          	jal	800014a2 <copyinstr>
    800029fa:	00054c63          	bltz	a0,80002a12 <fetchstr+0x3c>
  return strlen(buf);
    800029fe:	8526                	mv	a0,s1
    80002a00:	c12fe0ef          	jal	80000e12 <strlen>
}
    80002a04:	70a2                	ld	ra,40(sp)
    80002a06:	7402                	ld	s0,32(sp)
    80002a08:	64e2                	ld	s1,24(sp)
    80002a0a:	6942                	ld	s2,16(sp)
    80002a0c:	69a2                	ld	s3,8(sp)
    80002a0e:	6145                	addi	sp,sp,48
    80002a10:	8082                	ret
    return -1;
    80002a12:	557d                	li	a0,-1
    80002a14:	bfc5                	j	80002a04 <fetchstr+0x2e>

0000000080002a16 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002a16:	1101                	addi	sp,sp,-32
    80002a18:	ec06                	sd	ra,24(sp)
    80002a1a:	e822                	sd	s0,16(sp)
    80002a1c:	e426                	sd	s1,8(sp)
    80002a1e:	1000                	addi	s0,sp,32
    80002a20:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a22:	f0bff0ef          	jal	8000292c <argraw>
    80002a26:	c088                	sw	a0,0(s1)
}
    80002a28:	60e2                	ld	ra,24(sp)
    80002a2a:	6442                	ld	s0,16(sp)
    80002a2c:	64a2                	ld	s1,8(sp)
    80002a2e:	6105                	addi	sp,sp,32
    80002a30:	8082                	ret

0000000080002a32 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002a32:	1101                	addi	sp,sp,-32
    80002a34:	ec06                	sd	ra,24(sp)
    80002a36:	e822                	sd	s0,16(sp)
    80002a38:	e426                	sd	s1,8(sp)
    80002a3a:	1000                	addi	s0,sp,32
    80002a3c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a3e:	eefff0ef          	jal	8000292c <argraw>
    80002a42:	e088                	sd	a0,0(s1)
}
    80002a44:	60e2                	ld	ra,24(sp)
    80002a46:	6442                	ld	s0,16(sp)
    80002a48:	64a2                	ld	s1,8(sp)
    80002a4a:	6105                	addi	sp,sp,32
    80002a4c:	8082                	ret

0000000080002a4e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002a4e:	7179                	addi	sp,sp,-48
    80002a50:	f406                	sd	ra,40(sp)
    80002a52:	f022                	sd	s0,32(sp)
    80002a54:	ec26                	sd	s1,24(sp)
    80002a56:	e84a                	sd	s2,16(sp)
    80002a58:	1800                	addi	s0,sp,48
    80002a5a:	84ae                	mv	s1,a1
    80002a5c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002a5e:	fd840593          	addi	a1,s0,-40
    80002a62:	fd1ff0ef          	jal	80002a32 <argaddr>
  return fetchstr(addr, buf, max);
    80002a66:	864a                	mv	a2,s2
    80002a68:	85a6                	mv	a1,s1
    80002a6a:	fd843503          	ld	a0,-40(s0)
    80002a6e:	f69ff0ef          	jal	800029d6 <fetchstr>
}
    80002a72:	70a2                	ld	ra,40(sp)
    80002a74:	7402                	ld	s0,32(sp)
    80002a76:	64e2                	ld	s1,24(sp)
    80002a78:	6942                	ld	s2,16(sp)
    80002a7a:	6145                	addi	sp,sp,48
    80002a7c:	8082                	ret

0000000080002a7e <syscall>:
[SYS_settickets] sys_settickets,
};

void
syscall(void)
{
    80002a7e:	1101                	addi	sp,sp,-32
    80002a80:	ec06                	sd	ra,24(sp)
    80002a82:	e822                	sd	s0,16(sp)
    80002a84:	e426                	sd	s1,8(sp)
    80002a86:	e04a                	sd	s2,0(sp)
    80002a88:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002a8a:	fbdfe0ef          	jal	80001a46 <myproc>
    80002a8e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002a90:	05853903          	ld	s2,88(a0)
    80002a94:	0a893783          	ld	a5,168(s2)
    80002a98:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002a9c:	37fd                	addiw	a5,a5,-1
    80002a9e:	4755                	li	a4,21
    80002aa0:	00f76f63          	bltu	a4,a5,80002abe <syscall+0x40>
    80002aa4:	00369713          	slli	a4,a3,0x3
    80002aa8:	00005797          	auipc	a5,0x5
    80002aac:	ce878793          	addi	a5,a5,-792 # 80007790 <syscalls>
    80002ab0:	97ba                	add	a5,a5,a4
    80002ab2:	639c                	ld	a5,0(a5)
    80002ab4:	c789                	beqz	a5,80002abe <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002ab6:	9782                	jalr	a5
    80002ab8:	06a93823          	sd	a0,112(s2)
    80002abc:	a829                	j	80002ad6 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002abe:	15848613          	addi	a2,s1,344
    80002ac2:	588c                	lw	a1,48(s1)
    80002ac4:	00005517          	auipc	a0,0x5
    80002ac8:	8cc50513          	addi	a0,a0,-1844 # 80007390 <etext+0x390>
    80002acc:	a2ffd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ad0:	6cbc                	ld	a5,88(s1)
    80002ad2:	577d                	li	a4,-1
    80002ad4:	fbb8                	sd	a4,112(a5)
  }
}
    80002ad6:	60e2                	ld	ra,24(sp)
    80002ad8:	6442                	ld	s0,16(sp)
    80002ada:	64a2                	ld	s1,8(sp)
    80002adc:	6902                	ld	s2,0(sp)
    80002ade:	6105                	addi	sp,sp,32
    80002ae0:	8082                	ret

0000000080002ae2 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002ae2:	1101                	addi	sp,sp,-32
    80002ae4:	ec06                	sd	ra,24(sp)
    80002ae6:	e822                	sd	s0,16(sp)
    80002ae8:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002aea:	fec40593          	addi	a1,s0,-20
    80002aee:	4501                	li	a0,0
    80002af0:	f27ff0ef          	jal	80002a16 <argint>
  kexit(n);
    80002af4:	fec42503          	lw	a0,-20(s0)
    80002af8:	ec8ff0ef          	jal	800021c0 <kexit>
  return 0;  // not reached
}
    80002afc:	4501                	li	a0,0
    80002afe:	60e2                	ld	ra,24(sp)
    80002b00:	6442                	ld	s0,16(sp)
    80002b02:	6105                	addi	sp,sp,32
    80002b04:	8082                	ret

0000000080002b06 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002b06:	1141                	addi	sp,sp,-16
    80002b08:	e406                	sd	ra,8(sp)
    80002b0a:	e022                	sd	s0,0(sp)
    80002b0c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002b0e:	f39fe0ef          	jal	80001a46 <myproc>
}
    80002b12:	5908                	lw	a0,48(a0)
    80002b14:	60a2                	ld	ra,8(sp)
    80002b16:	6402                	ld	s0,0(sp)
    80002b18:	0141                	addi	sp,sp,16
    80002b1a:	8082                	ret

0000000080002b1c <sys_fork>:

uint64
sys_fork(void)
{
    80002b1c:	1141                	addi	sp,sp,-16
    80002b1e:	e406                	sd	ra,8(sp)
    80002b20:	e022                	sd	s0,0(sp)
    80002b22:	0800                	addi	s0,sp,16
  return kfork();
    80002b24:	a8cff0ef          	jal	80001db0 <kfork>
}
    80002b28:	60a2                	ld	ra,8(sp)
    80002b2a:	6402                	ld	s0,0(sp)
    80002b2c:	0141                	addi	sp,sp,16
    80002b2e:	8082                	ret

0000000080002b30 <sys_wait>:

uint64
sys_wait(void)
{
    80002b30:	1101                	addi	sp,sp,-32
    80002b32:	ec06                	sd	ra,24(sp)
    80002b34:	e822                	sd	s0,16(sp)
    80002b36:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002b38:	fe840593          	addi	a1,s0,-24
    80002b3c:	4501                	li	a0,0
    80002b3e:	ef5ff0ef          	jal	80002a32 <argaddr>
  return kwait(p);
    80002b42:	fe843503          	ld	a0,-24(s0)
    80002b46:	fd0ff0ef          	jal	80002316 <kwait>
}
    80002b4a:	60e2                	ld	ra,24(sp)
    80002b4c:	6442                	ld	s0,16(sp)
    80002b4e:	6105                	addi	sp,sp,32
    80002b50:	8082                	ret

0000000080002b52 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002b52:	7179                	addi	sp,sp,-48
    80002b54:	f406                	sd	ra,40(sp)
    80002b56:	f022                	sd	s0,32(sp)
    80002b58:	ec26                	sd	s1,24(sp)
    80002b5a:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002b5c:	fd840593          	addi	a1,s0,-40
    80002b60:	4501                	li	a0,0
    80002b62:	eb5ff0ef          	jal	80002a16 <argint>
  argint(1, &t);
    80002b66:	fdc40593          	addi	a1,s0,-36
    80002b6a:	4505                	li	a0,1
    80002b6c:	eabff0ef          	jal	80002a16 <argint>
  addr = myproc()->sz;
    80002b70:	ed7fe0ef          	jal	80001a46 <myproc>
    80002b74:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002b76:	fdc42703          	lw	a4,-36(s0)
    80002b7a:	4785                	li	a5,1
    80002b7c:	02f70763          	beq	a4,a5,80002baa <sys_sbrk+0x58>
    80002b80:	fd842783          	lw	a5,-40(s0)
    80002b84:	0207c363          	bltz	a5,80002baa <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002b88:	97a6                	add	a5,a5,s1
    80002b8a:	0297ee63          	bltu	a5,s1,80002bc6 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002b8e:	02000737          	lui	a4,0x2000
    80002b92:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002b94:	0736                	slli	a4,a4,0xd
    80002b96:	02f76a63          	bltu	a4,a5,80002bca <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002b9a:	eadfe0ef          	jal	80001a46 <myproc>
    80002b9e:	fd842703          	lw	a4,-40(s0)
    80002ba2:	653c                	ld	a5,72(a0)
    80002ba4:	97ba                	add	a5,a5,a4
    80002ba6:	e53c                	sd	a5,72(a0)
    80002ba8:	a039                	j	80002bb6 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002baa:	fd842503          	lw	a0,-40(s0)
    80002bae:	9a0ff0ef          	jal	80001d4e <growproc>
    80002bb2:	00054863          	bltz	a0,80002bc2 <sys_sbrk+0x70>
  }
  return addr;
}
    80002bb6:	8526                	mv	a0,s1
    80002bb8:	70a2                	ld	ra,40(sp)
    80002bba:	7402                	ld	s0,32(sp)
    80002bbc:	64e2                	ld	s1,24(sp)
    80002bbe:	6145                	addi	sp,sp,48
    80002bc0:	8082                	ret
      return -1;
    80002bc2:	54fd                	li	s1,-1
    80002bc4:	bfcd                	j	80002bb6 <sys_sbrk+0x64>
      return -1;
    80002bc6:	54fd                	li	s1,-1
    80002bc8:	b7fd                	j	80002bb6 <sys_sbrk+0x64>
      return -1;
    80002bca:	54fd                	li	s1,-1
    80002bcc:	b7ed                	j	80002bb6 <sys_sbrk+0x64>

0000000080002bce <sys_pause>:

uint64
sys_pause(void)
{
    80002bce:	7139                	addi	sp,sp,-64
    80002bd0:	fc06                	sd	ra,56(sp)
    80002bd2:	f822                	sd	s0,48(sp)
    80002bd4:	f04a                	sd	s2,32(sp)
    80002bd6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002bd8:	fcc40593          	addi	a1,s0,-52
    80002bdc:	4501                	li	a0,0
    80002bde:	e39ff0ef          	jal	80002a16 <argint>
  if(n < 0)
    80002be2:	fcc42783          	lw	a5,-52(s0)
    80002be6:	0607c763          	bltz	a5,80002c54 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002bea:	00013517          	auipc	a0,0x13
    80002bee:	e0e50513          	addi	a0,a0,-498 # 800159f8 <tickslock>
    80002bf2:	fddfd0ef          	jal	80000bce <acquire>
  ticks0 = ticks;
    80002bf6:	00005917          	auipc	s2,0x5
    80002bfa:	c9292903          	lw	s2,-878(s2) # 80007888 <ticks>
  while(ticks - ticks0 < n){
    80002bfe:	fcc42783          	lw	a5,-52(s0)
    80002c02:	cf8d                	beqz	a5,80002c3c <sys_pause+0x6e>
    80002c04:	f426                	sd	s1,40(sp)
    80002c06:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002c08:	00013997          	auipc	s3,0x13
    80002c0c:	df098993          	addi	s3,s3,-528 # 800159f8 <tickslock>
    80002c10:	00005497          	auipc	s1,0x5
    80002c14:	c7848493          	addi	s1,s1,-904 # 80007888 <ticks>
    if(killed(myproc())){
    80002c18:	e2ffe0ef          	jal	80001a46 <myproc>
    80002c1c:	ed0ff0ef          	jal	800022ec <killed>
    80002c20:	ed0d                	bnez	a0,80002c5a <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002c22:	85ce                	mv	a1,s3
    80002c24:	8526                	mv	a0,s1
    80002c26:	c8eff0ef          	jal	800020b4 <sleep>
  while(ticks - ticks0 < n){
    80002c2a:	409c                	lw	a5,0(s1)
    80002c2c:	412787bb          	subw	a5,a5,s2
    80002c30:	fcc42703          	lw	a4,-52(s0)
    80002c34:	fee7e2e3          	bltu	a5,a4,80002c18 <sys_pause+0x4a>
    80002c38:	74a2                	ld	s1,40(sp)
    80002c3a:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002c3c:	00013517          	auipc	a0,0x13
    80002c40:	dbc50513          	addi	a0,a0,-580 # 800159f8 <tickslock>
    80002c44:	822fe0ef          	jal	80000c66 <release>
  return 0;
    80002c48:	4501                	li	a0,0
}
    80002c4a:	70e2                	ld	ra,56(sp)
    80002c4c:	7442                	ld	s0,48(sp)
    80002c4e:	7902                	ld	s2,32(sp)
    80002c50:	6121                	addi	sp,sp,64
    80002c52:	8082                	ret
    n = 0;
    80002c54:	fc042623          	sw	zero,-52(s0)
    80002c58:	bf49                	j	80002bea <sys_pause+0x1c>
      release(&tickslock);
    80002c5a:	00013517          	auipc	a0,0x13
    80002c5e:	d9e50513          	addi	a0,a0,-610 # 800159f8 <tickslock>
    80002c62:	804fe0ef          	jal	80000c66 <release>
      return -1;
    80002c66:	557d                	li	a0,-1
    80002c68:	74a2                	ld	s1,40(sp)
    80002c6a:	69e2                	ld	s3,24(sp)
    80002c6c:	bff9                	j	80002c4a <sys_pause+0x7c>

0000000080002c6e <sys_kill>:

uint64
sys_kill(void)
{
    80002c6e:	1101                	addi	sp,sp,-32
    80002c70:	ec06                	sd	ra,24(sp)
    80002c72:	e822                	sd	s0,16(sp)
    80002c74:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002c76:	fec40593          	addi	a1,s0,-20
    80002c7a:	4501                	li	a0,0
    80002c7c:	d9bff0ef          	jal	80002a16 <argint>
  return kkill(pid);
    80002c80:	fec42503          	lw	a0,-20(s0)
    80002c84:	ddeff0ef          	jal	80002262 <kkill>
}
    80002c88:	60e2                	ld	ra,24(sp)
    80002c8a:	6442                	ld	s0,16(sp)
    80002c8c:	6105                	addi	sp,sp,32
    80002c8e:	8082                	ret

0000000080002c90 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002c90:	1101                	addi	sp,sp,-32
    80002c92:	ec06                	sd	ra,24(sp)
    80002c94:	e822                	sd	s0,16(sp)
    80002c96:	e426                	sd	s1,8(sp)
    80002c98:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002c9a:	00013517          	auipc	a0,0x13
    80002c9e:	d5e50513          	addi	a0,a0,-674 # 800159f8 <tickslock>
    80002ca2:	f2dfd0ef          	jal	80000bce <acquire>
  xticks = ticks;
    80002ca6:	00005497          	auipc	s1,0x5
    80002caa:	be24a483          	lw	s1,-1054(s1) # 80007888 <ticks>
  release(&tickslock);
    80002cae:	00013517          	auipc	a0,0x13
    80002cb2:	d4a50513          	addi	a0,a0,-694 # 800159f8 <tickslock>
    80002cb6:	fb1fd0ef          	jal	80000c66 <release>
  return xticks;
}
    80002cba:	02049513          	slli	a0,s1,0x20
    80002cbe:	9101                	srli	a0,a0,0x20
    80002cc0:	60e2                	ld	ra,24(sp)
    80002cc2:	6442                	ld	s0,16(sp)
    80002cc4:	64a2                	ld	s1,8(sp)
    80002cc6:	6105                	addi	sp,sp,32
    80002cc8:	8082                	ret

0000000080002cca <sys_settickets>:

// Set lottery tickets for a process
uint64
sys_settickets(void)
{
    80002cca:	1101                	addi	sp,sp,-32
    80002ccc:	ec06                	sd	ra,24(sp)
    80002cce:	e822                	sd	s0,16(sp)
    80002cd0:	1000                	addi	s0,sp,32
  int pid, tickets;
  
  argint(0, &pid);
    80002cd2:	fec40593          	addi	a1,s0,-20
    80002cd6:	4501                	li	a0,0
    80002cd8:	d3fff0ef          	jal	80002a16 <argint>
  argint(1, &tickets);
    80002cdc:	fe840593          	addi	a1,s0,-24
    80002ce0:	4505                	li	a0,1
    80002ce2:	d35ff0ef          	jal	80002a16 <argint>
  
  // Validate ticket count (must be positive)
  if(tickets <= 0)
    80002ce6:	fe842583          	lw	a1,-24(s0)
    return -1;
    80002cea:	557d                	li	a0,-1
  if(tickets <= 0)
    80002cec:	00b05663          	blez	a1,80002cf8 <sys_settickets+0x2e>
  
  return settickets(pid, tickets);
    80002cf0:	fec42503          	lw	a0,-20(s0)
    80002cf4:	855ff0ef          	jal	80002548 <settickets>
}
    80002cf8:	60e2                	ld	ra,24(sp)
    80002cfa:	6442                	ld	s0,16(sp)
    80002cfc:	6105                	addi	sp,sp,32
    80002cfe:	8082                	ret

0000000080002d00 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d00:	7179                	addi	sp,sp,-48
    80002d02:	f406                	sd	ra,40(sp)
    80002d04:	f022                	sd	s0,32(sp)
    80002d06:	ec26                	sd	s1,24(sp)
    80002d08:	e84a                	sd	s2,16(sp)
    80002d0a:	e44e                	sd	s3,8(sp)
    80002d0c:	e052                	sd	s4,0(sp)
    80002d0e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002d10:	00004597          	auipc	a1,0x4
    80002d14:	6a058593          	addi	a1,a1,1696 # 800073b0 <etext+0x3b0>
    80002d18:	00013517          	auipc	a0,0x13
    80002d1c:	cf850513          	addi	a0,a0,-776 # 80015a10 <bcache>
    80002d20:	e2ffd0ef          	jal	80000b4e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002d24:	0001b797          	auipc	a5,0x1b
    80002d28:	cec78793          	addi	a5,a5,-788 # 8001da10 <bcache+0x8000>
    80002d2c:	0001b717          	auipc	a4,0x1b
    80002d30:	f4c70713          	addi	a4,a4,-180 # 8001dc78 <bcache+0x8268>
    80002d34:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002d38:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d3c:	00013497          	auipc	s1,0x13
    80002d40:	cec48493          	addi	s1,s1,-788 # 80015a28 <bcache+0x18>
    b->next = bcache.head.next;
    80002d44:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002d46:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002d48:	00004a17          	auipc	s4,0x4
    80002d4c:	670a0a13          	addi	s4,s4,1648 # 800073b8 <etext+0x3b8>
    b->next = bcache.head.next;
    80002d50:	2b893783          	ld	a5,696(s2)
    80002d54:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002d56:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002d5a:	85d2                	mv	a1,s4
    80002d5c:	01048513          	addi	a0,s1,16
    80002d60:	322010ef          	jal	80004082 <initsleeplock>
    bcache.head.next->prev = b;
    80002d64:	2b893783          	ld	a5,696(s2)
    80002d68:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002d6a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d6e:	45848493          	addi	s1,s1,1112
    80002d72:	fd349fe3          	bne	s1,s3,80002d50 <binit+0x50>
  }
}
    80002d76:	70a2                	ld	ra,40(sp)
    80002d78:	7402                	ld	s0,32(sp)
    80002d7a:	64e2                	ld	s1,24(sp)
    80002d7c:	6942                	ld	s2,16(sp)
    80002d7e:	69a2                	ld	s3,8(sp)
    80002d80:	6a02                	ld	s4,0(sp)
    80002d82:	6145                	addi	sp,sp,48
    80002d84:	8082                	ret

0000000080002d86 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002d86:	7179                	addi	sp,sp,-48
    80002d88:	f406                	sd	ra,40(sp)
    80002d8a:	f022                	sd	s0,32(sp)
    80002d8c:	ec26                	sd	s1,24(sp)
    80002d8e:	e84a                	sd	s2,16(sp)
    80002d90:	e44e                	sd	s3,8(sp)
    80002d92:	1800                	addi	s0,sp,48
    80002d94:	892a                	mv	s2,a0
    80002d96:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002d98:	00013517          	auipc	a0,0x13
    80002d9c:	c7850513          	addi	a0,a0,-904 # 80015a10 <bcache>
    80002da0:	e2ffd0ef          	jal	80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002da4:	0001b497          	auipc	s1,0x1b
    80002da8:	f244b483          	ld	s1,-220(s1) # 8001dcc8 <bcache+0x82b8>
    80002dac:	0001b797          	auipc	a5,0x1b
    80002db0:	ecc78793          	addi	a5,a5,-308 # 8001dc78 <bcache+0x8268>
    80002db4:	02f48b63          	beq	s1,a5,80002dea <bread+0x64>
    80002db8:	873e                	mv	a4,a5
    80002dba:	a021                	j	80002dc2 <bread+0x3c>
    80002dbc:	68a4                	ld	s1,80(s1)
    80002dbe:	02e48663          	beq	s1,a4,80002dea <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002dc2:	449c                	lw	a5,8(s1)
    80002dc4:	ff279ce3          	bne	a5,s2,80002dbc <bread+0x36>
    80002dc8:	44dc                	lw	a5,12(s1)
    80002dca:	ff3799e3          	bne	a5,s3,80002dbc <bread+0x36>
      b->refcnt++;
    80002dce:	40bc                	lw	a5,64(s1)
    80002dd0:	2785                	addiw	a5,a5,1
    80002dd2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002dd4:	00013517          	auipc	a0,0x13
    80002dd8:	c3c50513          	addi	a0,a0,-964 # 80015a10 <bcache>
    80002ddc:	e8bfd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002de0:	01048513          	addi	a0,s1,16
    80002de4:	2d4010ef          	jal	800040b8 <acquiresleep>
      return b;
    80002de8:	a889                	j	80002e3a <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002dea:	0001b497          	auipc	s1,0x1b
    80002dee:	ed64b483          	ld	s1,-298(s1) # 8001dcc0 <bcache+0x82b0>
    80002df2:	0001b797          	auipc	a5,0x1b
    80002df6:	e8678793          	addi	a5,a5,-378 # 8001dc78 <bcache+0x8268>
    80002dfa:	00f48863          	beq	s1,a5,80002e0a <bread+0x84>
    80002dfe:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002e00:	40bc                	lw	a5,64(s1)
    80002e02:	cb91                	beqz	a5,80002e16 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e04:	64a4                	ld	s1,72(s1)
    80002e06:	fee49de3          	bne	s1,a4,80002e00 <bread+0x7a>
  panic("bget: no buffers");
    80002e0a:	00004517          	auipc	a0,0x4
    80002e0e:	5b650513          	addi	a0,a0,1462 # 800073c0 <etext+0x3c0>
    80002e12:	9cffd0ef          	jal	800007e0 <panic>
      b->dev = dev;
    80002e16:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002e1a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002e1e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002e22:	4785                	li	a5,1
    80002e24:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e26:	00013517          	auipc	a0,0x13
    80002e2a:	bea50513          	addi	a0,a0,-1046 # 80015a10 <bcache>
    80002e2e:	e39fd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002e32:	01048513          	addi	a0,s1,16
    80002e36:	282010ef          	jal	800040b8 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002e3a:	409c                	lw	a5,0(s1)
    80002e3c:	cb89                	beqz	a5,80002e4e <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002e3e:	8526                	mv	a0,s1
    80002e40:	70a2                	ld	ra,40(sp)
    80002e42:	7402                	ld	s0,32(sp)
    80002e44:	64e2                	ld	s1,24(sp)
    80002e46:	6942                	ld	s2,16(sp)
    80002e48:	69a2                	ld	s3,8(sp)
    80002e4a:	6145                	addi	sp,sp,48
    80002e4c:	8082                	ret
    virtio_disk_rw(b, 0);
    80002e4e:	4581                	li	a1,0
    80002e50:	8526                	mv	a0,s1
    80002e52:	2cf020ef          	jal	80005920 <virtio_disk_rw>
    b->valid = 1;
    80002e56:	4785                	li	a5,1
    80002e58:	c09c                	sw	a5,0(s1)
  return b;
    80002e5a:	b7d5                	j	80002e3e <bread+0xb8>

0000000080002e5c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002e5c:	1101                	addi	sp,sp,-32
    80002e5e:	ec06                	sd	ra,24(sp)
    80002e60:	e822                	sd	s0,16(sp)
    80002e62:	e426                	sd	s1,8(sp)
    80002e64:	1000                	addi	s0,sp,32
    80002e66:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e68:	0541                	addi	a0,a0,16
    80002e6a:	2cc010ef          	jal	80004136 <holdingsleep>
    80002e6e:	c911                	beqz	a0,80002e82 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002e70:	4585                	li	a1,1
    80002e72:	8526                	mv	a0,s1
    80002e74:	2ad020ef          	jal	80005920 <virtio_disk_rw>
}
    80002e78:	60e2                	ld	ra,24(sp)
    80002e7a:	6442                	ld	s0,16(sp)
    80002e7c:	64a2                	ld	s1,8(sp)
    80002e7e:	6105                	addi	sp,sp,32
    80002e80:	8082                	ret
    panic("bwrite");
    80002e82:	00004517          	auipc	a0,0x4
    80002e86:	55650513          	addi	a0,a0,1366 # 800073d8 <etext+0x3d8>
    80002e8a:	957fd0ef          	jal	800007e0 <panic>

0000000080002e8e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002e8e:	1101                	addi	sp,sp,-32
    80002e90:	ec06                	sd	ra,24(sp)
    80002e92:	e822                	sd	s0,16(sp)
    80002e94:	e426                	sd	s1,8(sp)
    80002e96:	e04a                	sd	s2,0(sp)
    80002e98:	1000                	addi	s0,sp,32
    80002e9a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e9c:	01050913          	addi	s2,a0,16
    80002ea0:	854a                	mv	a0,s2
    80002ea2:	294010ef          	jal	80004136 <holdingsleep>
    80002ea6:	c135                	beqz	a0,80002f0a <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002ea8:	854a                	mv	a0,s2
    80002eaa:	254010ef          	jal	800040fe <releasesleep>

  acquire(&bcache.lock);
    80002eae:	00013517          	auipc	a0,0x13
    80002eb2:	b6250513          	addi	a0,a0,-1182 # 80015a10 <bcache>
    80002eb6:	d19fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002eba:	40bc                	lw	a5,64(s1)
    80002ebc:	37fd                	addiw	a5,a5,-1
    80002ebe:	0007871b          	sext.w	a4,a5
    80002ec2:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002ec4:	e71d                	bnez	a4,80002ef2 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002ec6:	68b8                	ld	a4,80(s1)
    80002ec8:	64bc                	ld	a5,72(s1)
    80002eca:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002ecc:	68b8                	ld	a4,80(s1)
    80002ece:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002ed0:	0001b797          	auipc	a5,0x1b
    80002ed4:	b4078793          	addi	a5,a5,-1216 # 8001da10 <bcache+0x8000>
    80002ed8:	2b87b703          	ld	a4,696(a5)
    80002edc:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002ede:	0001b717          	auipc	a4,0x1b
    80002ee2:	d9a70713          	addi	a4,a4,-614 # 8001dc78 <bcache+0x8268>
    80002ee6:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002ee8:	2b87b703          	ld	a4,696(a5)
    80002eec:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002eee:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002ef2:	00013517          	auipc	a0,0x13
    80002ef6:	b1e50513          	addi	a0,a0,-1250 # 80015a10 <bcache>
    80002efa:	d6dfd0ef          	jal	80000c66 <release>
}
    80002efe:	60e2                	ld	ra,24(sp)
    80002f00:	6442                	ld	s0,16(sp)
    80002f02:	64a2                	ld	s1,8(sp)
    80002f04:	6902                	ld	s2,0(sp)
    80002f06:	6105                	addi	sp,sp,32
    80002f08:	8082                	ret
    panic("brelse");
    80002f0a:	00004517          	auipc	a0,0x4
    80002f0e:	4d650513          	addi	a0,a0,1238 # 800073e0 <etext+0x3e0>
    80002f12:	8cffd0ef          	jal	800007e0 <panic>

0000000080002f16 <bpin>:

void
bpin(struct buf *b) {
    80002f16:	1101                	addi	sp,sp,-32
    80002f18:	ec06                	sd	ra,24(sp)
    80002f1a:	e822                	sd	s0,16(sp)
    80002f1c:	e426                	sd	s1,8(sp)
    80002f1e:	1000                	addi	s0,sp,32
    80002f20:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f22:	00013517          	auipc	a0,0x13
    80002f26:	aee50513          	addi	a0,a0,-1298 # 80015a10 <bcache>
    80002f2a:	ca5fd0ef          	jal	80000bce <acquire>
  b->refcnt++;
    80002f2e:	40bc                	lw	a5,64(s1)
    80002f30:	2785                	addiw	a5,a5,1
    80002f32:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f34:	00013517          	auipc	a0,0x13
    80002f38:	adc50513          	addi	a0,a0,-1316 # 80015a10 <bcache>
    80002f3c:	d2bfd0ef          	jal	80000c66 <release>
}
    80002f40:	60e2                	ld	ra,24(sp)
    80002f42:	6442                	ld	s0,16(sp)
    80002f44:	64a2                	ld	s1,8(sp)
    80002f46:	6105                	addi	sp,sp,32
    80002f48:	8082                	ret

0000000080002f4a <bunpin>:

void
bunpin(struct buf *b) {
    80002f4a:	1101                	addi	sp,sp,-32
    80002f4c:	ec06                	sd	ra,24(sp)
    80002f4e:	e822                	sd	s0,16(sp)
    80002f50:	e426                	sd	s1,8(sp)
    80002f52:	1000                	addi	s0,sp,32
    80002f54:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f56:	00013517          	auipc	a0,0x13
    80002f5a:	aba50513          	addi	a0,a0,-1350 # 80015a10 <bcache>
    80002f5e:	c71fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002f62:	40bc                	lw	a5,64(s1)
    80002f64:	37fd                	addiw	a5,a5,-1
    80002f66:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f68:	00013517          	auipc	a0,0x13
    80002f6c:	aa850513          	addi	a0,a0,-1368 # 80015a10 <bcache>
    80002f70:	cf7fd0ef          	jal	80000c66 <release>
}
    80002f74:	60e2                	ld	ra,24(sp)
    80002f76:	6442                	ld	s0,16(sp)
    80002f78:	64a2                	ld	s1,8(sp)
    80002f7a:	6105                	addi	sp,sp,32
    80002f7c:	8082                	ret

0000000080002f7e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002f7e:	1101                	addi	sp,sp,-32
    80002f80:	ec06                	sd	ra,24(sp)
    80002f82:	e822                	sd	s0,16(sp)
    80002f84:	e426                	sd	s1,8(sp)
    80002f86:	e04a                	sd	s2,0(sp)
    80002f88:	1000                	addi	s0,sp,32
    80002f8a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002f8c:	00d5d59b          	srliw	a1,a1,0xd
    80002f90:	0001b797          	auipc	a5,0x1b
    80002f94:	15c7a783          	lw	a5,348(a5) # 8001e0ec <sb+0x1c>
    80002f98:	9dbd                	addw	a1,a1,a5
    80002f9a:	dedff0ef          	jal	80002d86 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002f9e:	0074f713          	andi	a4,s1,7
    80002fa2:	4785                	li	a5,1
    80002fa4:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002fa8:	14ce                	slli	s1,s1,0x33
    80002faa:	90d9                	srli	s1,s1,0x36
    80002fac:	00950733          	add	a4,a0,s1
    80002fb0:	05874703          	lbu	a4,88(a4)
    80002fb4:	00e7f6b3          	and	a3,a5,a4
    80002fb8:	c29d                	beqz	a3,80002fde <bfree+0x60>
    80002fba:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002fbc:	94aa                	add	s1,s1,a0
    80002fbe:	fff7c793          	not	a5,a5
    80002fc2:	8f7d                	and	a4,a4,a5
    80002fc4:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002fc8:	7f9000ef          	jal	80003fc0 <log_write>
  brelse(bp);
    80002fcc:	854a                	mv	a0,s2
    80002fce:	ec1ff0ef          	jal	80002e8e <brelse>
}
    80002fd2:	60e2                	ld	ra,24(sp)
    80002fd4:	6442                	ld	s0,16(sp)
    80002fd6:	64a2                	ld	s1,8(sp)
    80002fd8:	6902                	ld	s2,0(sp)
    80002fda:	6105                	addi	sp,sp,32
    80002fdc:	8082                	ret
    panic("freeing free block");
    80002fde:	00004517          	auipc	a0,0x4
    80002fe2:	40a50513          	addi	a0,a0,1034 # 800073e8 <etext+0x3e8>
    80002fe6:	ffafd0ef          	jal	800007e0 <panic>

0000000080002fea <balloc>:
{
    80002fea:	711d                	addi	sp,sp,-96
    80002fec:	ec86                	sd	ra,88(sp)
    80002fee:	e8a2                	sd	s0,80(sp)
    80002ff0:	e4a6                	sd	s1,72(sp)
    80002ff2:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002ff4:	0001b797          	auipc	a5,0x1b
    80002ff8:	0e07a783          	lw	a5,224(a5) # 8001e0d4 <sb+0x4>
    80002ffc:	0e078f63          	beqz	a5,800030fa <balloc+0x110>
    80003000:	e0ca                	sd	s2,64(sp)
    80003002:	fc4e                	sd	s3,56(sp)
    80003004:	f852                	sd	s4,48(sp)
    80003006:	f456                	sd	s5,40(sp)
    80003008:	f05a                	sd	s6,32(sp)
    8000300a:	ec5e                	sd	s7,24(sp)
    8000300c:	e862                	sd	s8,16(sp)
    8000300e:	e466                	sd	s9,8(sp)
    80003010:	8baa                	mv	s7,a0
    80003012:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003014:	0001bb17          	auipc	s6,0x1b
    80003018:	0bcb0b13          	addi	s6,s6,188 # 8001e0d0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000301c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000301e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003020:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003022:	6c89                	lui	s9,0x2
    80003024:	a0b5                	j	80003090 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003026:	97ca                	add	a5,a5,s2
    80003028:	8e55                	or	a2,a2,a3
    8000302a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000302e:	854a                	mv	a0,s2
    80003030:	791000ef          	jal	80003fc0 <log_write>
        brelse(bp);
    80003034:	854a                	mv	a0,s2
    80003036:	e59ff0ef          	jal	80002e8e <brelse>
  bp = bread(dev, bno);
    8000303a:	85a6                	mv	a1,s1
    8000303c:	855e                	mv	a0,s7
    8000303e:	d49ff0ef          	jal	80002d86 <bread>
    80003042:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003044:	40000613          	li	a2,1024
    80003048:	4581                	li	a1,0
    8000304a:	05850513          	addi	a0,a0,88
    8000304e:	c55fd0ef          	jal	80000ca2 <memset>
  log_write(bp);
    80003052:	854a                	mv	a0,s2
    80003054:	76d000ef          	jal	80003fc0 <log_write>
  brelse(bp);
    80003058:	854a                	mv	a0,s2
    8000305a:	e35ff0ef          	jal	80002e8e <brelse>
}
    8000305e:	6906                	ld	s2,64(sp)
    80003060:	79e2                	ld	s3,56(sp)
    80003062:	7a42                	ld	s4,48(sp)
    80003064:	7aa2                	ld	s5,40(sp)
    80003066:	7b02                	ld	s6,32(sp)
    80003068:	6be2                	ld	s7,24(sp)
    8000306a:	6c42                	ld	s8,16(sp)
    8000306c:	6ca2                	ld	s9,8(sp)
}
    8000306e:	8526                	mv	a0,s1
    80003070:	60e6                	ld	ra,88(sp)
    80003072:	6446                	ld	s0,80(sp)
    80003074:	64a6                	ld	s1,72(sp)
    80003076:	6125                	addi	sp,sp,96
    80003078:	8082                	ret
    brelse(bp);
    8000307a:	854a                	mv	a0,s2
    8000307c:	e13ff0ef          	jal	80002e8e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003080:	015c87bb          	addw	a5,s9,s5
    80003084:	00078a9b          	sext.w	s5,a5
    80003088:	004b2703          	lw	a4,4(s6)
    8000308c:	04eaff63          	bgeu	s5,a4,800030ea <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80003090:	41fad79b          	sraiw	a5,s5,0x1f
    80003094:	0137d79b          	srliw	a5,a5,0x13
    80003098:	015787bb          	addw	a5,a5,s5
    8000309c:	40d7d79b          	sraiw	a5,a5,0xd
    800030a0:	01cb2583          	lw	a1,28(s6)
    800030a4:	9dbd                	addw	a1,a1,a5
    800030a6:	855e                	mv	a0,s7
    800030a8:	cdfff0ef          	jal	80002d86 <bread>
    800030ac:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030ae:	004b2503          	lw	a0,4(s6)
    800030b2:	000a849b          	sext.w	s1,s5
    800030b6:	8762                	mv	a4,s8
    800030b8:	fca4f1e3          	bgeu	s1,a0,8000307a <balloc+0x90>
      m = 1 << (bi % 8);
    800030bc:	00777693          	andi	a3,a4,7
    800030c0:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800030c4:	41f7579b          	sraiw	a5,a4,0x1f
    800030c8:	01d7d79b          	srliw	a5,a5,0x1d
    800030cc:	9fb9                	addw	a5,a5,a4
    800030ce:	4037d79b          	sraiw	a5,a5,0x3
    800030d2:	00f90633          	add	a2,s2,a5
    800030d6:	05864603          	lbu	a2,88(a2)
    800030da:	00c6f5b3          	and	a1,a3,a2
    800030de:	d5a1                	beqz	a1,80003026 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030e0:	2705                	addiw	a4,a4,1
    800030e2:	2485                	addiw	s1,s1,1
    800030e4:	fd471ae3          	bne	a4,s4,800030b8 <balloc+0xce>
    800030e8:	bf49                	j	8000307a <balloc+0x90>
    800030ea:	6906                	ld	s2,64(sp)
    800030ec:	79e2                	ld	s3,56(sp)
    800030ee:	7a42                	ld	s4,48(sp)
    800030f0:	7aa2                	ld	s5,40(sp)
    800030f2:	7b02                	ld	s6,32(sp)
    800030f4:	6be2                	ld	s7,24(sp)
    800030f6:	6c42                	ld	s8,16(sp)
    800030f8:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800030fa:	00004517          	auipc	a0,0x4
    800030fe:	30650513          	addi	a0,a0,774 # 80007400 <etext+0x400>
    80003102:	bf8fd0ef          	jal	800004fa <printf>
  return 0;
    80003106:	4481                	li	s1,0
    80003108:	b79d                	j	8000306e <balloc+0x84>

000000008000310a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000310a:	7179                	addi	sp,sp,-48
    8000310c:	f406                	sd	ra,40(sp)
    8000310e:	f022                	sd	s0,32(sp)
    80003110:	ec26                	sd	s1,24(sp)
    80003112:	e84a                	sd	s2,16(sp)
    80003114:	e44e                	sd	s3,8(sp)
    80003116:	1800                	addi	s0,sp,48
    80003118:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000311a:	47ad                	li	a5,11
    8000311c:	02b7e663          	bltu	a5,a1,80003148 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80003120:	02059793          	slli	a5,a1,0x20
    80003124:	01e7d593          	srli	a1,a5,0x1e
    80003128:	00b504b3          	add	s1,a0,a1
    8000312c:	0504a903          	lw	s2,80(s1)
    80003130:	06091a63          	bnez	s2,800031a4 <bmap+0x9a>
      addr = balloc(ip->dev);
    80003134:	4108                	lw	a0,0(a0)
    80003136:	eb5ff0ef          	jal	80002fea <balloc>
    8000313a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000313e:	06090363          	beqz	s2,800031a4 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80003142:	0524a823          	sw	s2,80(s1)
    80003146:	a8b9                	j	800031a4 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003148:	ff45849b          	addiw	s1,a1,-12
    8000314c:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003150:	0ff00793          	li	a5,255
    80003154:	06e7ee63          	bltu	a5,a4,800031d0 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003158:	08052903          	lw	s2,128(a0)
    8000315c:	00091d63          	bnez	s2,80003176 <bmap+0x6c>
      addr = balloc(ip->dev);
    80003160:	4108                	lw	a0,0(a0)
    80003162:	e89ff0ef          	jal	80002fea <balloc>
    80003166:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000316a:	02090d63          	beqz	s2,800031a4 <bmap+0x9a>
    8000316e:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003170:	0929a023          	sw	s2,128(s3)
    80003174:	a011                	j	80003178 <bmap+0x6e>
    80003176:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003178:	85ca                	mv	a1,s2
    8000317a:	0009a503          	lw	a0,0(s3)
    8000317e:	c09ff0ef          	jal	80002d86 <bread>
    80003182:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003184:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003188:	02049713          	slli	a4,s1,0x20
    8000318c:	01e75593          	srli	a1,a4,0x1e
    80003190:	00b784b3          	add	s1,a5,a1
    80003194:	0004a903          	lw	s2,0(s1)
    80003198:	00090e63          	beqz	s2,800031b4 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000319c:	8552                	mv	a0,s4
    8000319e:	cf1ff0ef          	jal	80002e8e <brelse>
    return addr;
    800031a2:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800031a4:	854a                	mv	a0,s2
    800031a6:	70a2                	ld	ra,40(sp)
    800031a8:	7402                	ld	s0,32(sp)
    800031aa:	64e2                	ld	s1,24(sp)
    800031ac:	6942                	ld	s2,16(sp)
    800031ae:	69a2                	ld	s3,8(sp)
    800031b0:	6145                	addi	sp,sp,48
    800031b2:	8082                	ret
      addr = balloc(ip->dev);
    800031b4:	0009a503          	lw	a0,0(s3)
    800031b8:	e33ff0ef          	jal	80002fea <balloc>
    800031bc:	0005091b          	sext.w	s2,a0
      if(addr){
    800031c0:	fc090ee3          	beqz	s2,8000319c <bmap+0x92>
        a[bn] = addr;
    800031c4:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800031c8:	8552                	mv	a0,s4
    800031ca:	5f7000ef          	jal	80003fc0 <log_write>
    800031ce:	b7f9                	j	8000319c <bmap+0x92>
    800031d0:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800031d2:	00004517          	auipc	a0,0x4
    800031d6:	24650513          	addi	a0,a0,582 # 80007418 <etext+0x418>
    800031da:	e06fd0ef          	jal	800007e0 <panic>

00000000800031de <iget>:
{
    800031de:	7179                	addi	sp,sp,-48
    800031e0:	f406                	sd	ra,40(sp)
    800031e2:	f022                	sd	s0,32(sp)
    800031e4:	ec26                	sd	s1,24(sp)
    800031e6:	e84a                	sd	s2,16(sp)
    800031e8:	e44e                	sd	s3,8(sp)
    800031ea:	e052                	sd	s4,0(sp)
    800031ec:	1800                	addi	s0,sp,48
    800031ee:	89aa                	mv	s3,a0
    800031f0:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800031f2:	0001b517          	auipc	a0,0x1b
    800031f6:	efe50513          	addi	a0,a0,-258 # 8001e0f0 <itable>
    800031fa:	9d5fd0ef          	jal	80000bce <acquire>
  empty = 0;
    800031fe:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003200:	0001b497          	auipc	s1,0x1b
    80003204:	f0848493          	addi	s1,s1,-248 # 8001e108 <itable+0x18>
    80003208:	0001d697          	auipc	a3,0x1d
    8000320c:	99068693          	addi	a3,a3,-1648 # 8001fb98 <log>
    80003210:	a039                	j	8000321e <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003212:	02090963          	beqz	s2,80003244 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003216:	08848493          	addi	s1,s1,136
    8000321a:	02d48863          	beq	s1,a3,8000324a <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000321e:	449c                	lw	a5,8(s1)
    80003220:	fef059e3          	blez	a5,80003212 <iget+0x34>
    80003224:	4098                	lw	a4,0(s1)
    80003226:	ff3716e3          	bne	a4,s3,80003212 <iget+0x34>
    8000322a:	40d8                	lw	a4,4(s1)
    8000322c:	ff4713e3          	bne	a4,s4,80003212 <iget+0x34>
      ip->ref++;
    80003230:	2785                	addiw	a5,a5,1
    80003232:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003234:	0001b517          	auipc	a0,0x1b
    80003238:	ebc50513          	addi	a0,a0,-324 # 8001e0f0 <itable>
    8000323c:	a2bfd0ef          	jal	80000c66 <release>
      return ip;
    80003240:	8926                	mv	s2,s1
    80003242:	a02d                	j	8000326c <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003244:	fbe9                	bnez	a5,80003216 <iget+0x38>
      empty = ip;
    80003246:	8926                	mv	s2,s1
    80003248:	b7f9                	j	80003216 <iget+0x38>
  if(empty == 0)
    8000324a:	02090a63          	beqz	s2,8000327e <iget+0xa0>
  ip->dev = dev;
    8000324e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003252:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003256:	4785                	li	a5,1
    80003258:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000325c:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003260:	0001b517          	auipc	a0,0x1b
    80003264:	e9050513          	addi	a0,a0,-368 # 8001e0f0 <itable>
    80003268:	9fffd0ef          	jal	80000c66 <release>
}
    8000326c:	854a                	mv	a0,s2
    8000326e:	70a2                	ld	ra,40(sp)
    80003270:	7402                	ld	s0,32(sp)
    80003272:	64e2                	ld	s1,24(sp)
    80003274:	6942                	ld	s2,16(sp)
    80003276:	69a2                	ld	s3,8(sp)
    80003278:	6a02                	ld	s4,0(sp)
    8000327a:	6145                	addi	sp,sp,48
    8000327c:	8082                	ret
    panic("iget: no inodes");
    8000327e:	00004517          	auipc	a0,0x4
    80003282:	1b250513          	addi	a0,a0,434 # 80007430 <etext+0x430>
    80003286:	d5afd0ef          	jal	800007e0 <panic>

000000008000328a <iinit>:
{
    8000328a:	7179                	addi	sp,sp,-48
    8000328c:	f406                	sd	ra,40(sp)
    8000328e:	f022                	sd	s0,32(sp)
    80003290:	ec26                	sd	s1,24(sp)
    80003292:	e84a                	sd	s2,16(sp)
    80003294:	e44e                	sd	s3,8(sp)
    80003296:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003298:	00004597          	auipc	a1,0x4
    8000329c:	1a858593          	addi	a1,a1,424 # 80007440 <etext+0x440>
    800032a0:	0001b517          	auipc	a0,0x1b
    800032a4:	e5050513          	addi	a0,a0,-432 # 8001e0f0 <itable>
    800032a8:	8a7fd0ef          	jal	80000b4e <initlock>
  for(i = 0; i < NINODE; i++) {
    800032ac:	0001b497          	auipc	s1,0x1b
    800032b0:	e6c48493          	addi	s1,s1,-404 # 8001e118 <itable+0x28>
    800032b4:	0001d997          	auipc	s3,0x1d
    800032b8:	8f498993          	addi	s3,s3,-1804 # 8001fba8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800032bc:	00004917          	auipc	s2,0x4
    800032c0:	18c90913          	addi	s2,s2,396 # 80007448 <etext+0x448>
    800032c4:	85ca                	mv	a1,s2
    800032c6:	8526                	mv	a0,s1
    800032c8:	5bb000ef          	jal	80004082 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800032cc:	08848493          	addi	s1,s1,136
    800032d0:	ff349ae3          	bne	s1,s3,800032c4 <iinit+0x3a>
}
    800032d4:	70a2                	ld	ra,40(sp)
    800032d6:	7402                	ld	s0,32(sp)
    800032d8:	64e2                	ld	s1,24(sp)
    800032da:	6942                	ld	s2,16(sp)
    800032dc:	69a2                	ld	s3,8(sp)
    800032de:	6145                	addi	sp,sp,48
    800032e0:	8082                	ret

00000000800032e2 <ialloc>:
{
    800032e2:	7139                	addi	sp,sp,-64
    800032e4:	fc06                	sd	ra,56(sp)
    800032e6:	f822                	sd	s0,48(sp)
    800032e8:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800032ea:	0001b717          	auipc	a4,0x1b
    800032ee:	df272703          	lw	a4,-526(a4) # 8001e0dc <sb+0xc>
    800032f2:	4785                	li	a5,1
    800032f4:	06e7f063          	bgeu	a5,a4,80003354 <ialloc+0x72>
    800032f8:	f426                	sd	s1,40(sp)
    800032fa:	f04a                	sd	s2,32(sp)
    800032fc:	ec4e                	sd	s3,24(sp)
    800032fe:	e852                	sd	s4,16(sp)
    80003300:	e456                	sd	s5,8(sp)
    80003302:	e05a                	sd	s6,0(sp)
    80003304:	8aaa                	mv	s5,a0
    80003306:	8b2e                	mv	s6,a1
    80003308:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000330a:	0001ba17          	auipc	s4,0x1b
    8000330e:	dc6a0a13          	addi	s4,s4,-570 # 8001e0d0 <sb>
    80003312:	00495593          	srli	a1,s2,0x4
    80003316:	018a2783          	lw	a5,24(s4)
    8000331a:	9dbd                	addw	a1,a1,a5
    8000331c:	8556                	mv	a0,s5
    8000331e:	a69ff0ef          	jal	80002d86 <bread>
    80003322:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003324:	05850993          	addi	s3,a0,88
    80003328:	00f97793          	andi	a5,s2,15
    8000332c:	079a                	slli	a5,a5,0x6
    8000332e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003330:	00099783          	lh	a5,0(s3)
    80003334:	cb9d                	beqz	a5,8000336a <ialloc+0x88>
    brelse(bp);
    80003336:	b59ff0ef          	jal	80002e8e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000333a:	0905                	addi	s2,s2,1
    8000333c:	00ca2703          	lw	a4,12(s4)
    80003340:	0009079b          	sext.w	a5,s2
    80003344:	fce7e7e3          	bltu	a5,a4,80003312 <ialloc+0x30>
    80003348:	74a2                	ld	s1,40(sp)
    8000334a:	7902                	ld	s2,32(sp)
    8000334c:	69e2                	ld	s3,24(sp)
    8000334e:	6a42                	ld	s4,16(sp)
    80003350:	6aa2                	ld	s5,8(sp)
    80003352:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003354:	00004517          	auipc	a0,0x4
    80003358:	0fc50513          	addi	a0,a0,252 # 80007450 <etext+0x450>
    8000335c:	99efd0ef          	jal	800004fa <printf>
  return 0;
    80003360:	4501                	li	a0,0
}
    80003362:	70e2                	ld	ra,56(sp)
    80003364:	7442                	ld	s0,48(sp)
    80003366:	6121                	addi	sp,sp,64
    80003368:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000336a:	04000613          	li	a2,64
    8000336e:	4581                	li	a1,0
    80003370:	854e                	mv	a0,s3
    80003372:	931fd0ef          	jal	80000ca2 <memset>
      dip->type = type;
    80003376:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000337a:	8526                	mv	a0,s1
    8000337c:	445000ef          	jal	80003fc0 <log_write>
      brelse(bp);
    80003380:	8526                	mv	a0,s1
    80003382:	b0dff0ef          	jal	80002e8e <brelse>
      return iget(dev, inum);
    80003386:	0009059b          	sext.w	a1,s2
    8000338a:	8556                	mv	a0,s5
    8000338c:	e53ff0ef          	jal	800031de <iget>
    80003390:	74a2                	ld	s1,40(sp)
    80003392:	7902                	ld	s2,32(sp)
    80003394:	69e2                	ld	s3,24(sp)
    80003396:	6a42                	ld	s4,16(sp)
    80003398:	6aa2                	ld	s5,8(sp)
    8000339a:	6b02                	ld	s6,0(sp)
    8000339c:	b7d9                	j	80003362 <ialloc+0x80>

000000008000339e <iupdate>:
{
    8000339e:	1101                	addi	sp,sp,-32
    800033a0:	ec06                	sd	ra,24(sp)
    800033a2:	e822                	sd	s0,16(sp)
    800033a4:	e426                	sd	s1,8(sp)
    800033a6:	e04a                	sd	s2,0(sp)
    800033a8:	1000                	addi	s0,sp,32
    800033aa:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800033ac:	415c                	lw	a5,4(a0)
    800033ae:	0047d79b          	srliw	a5,a5,0x4
    800033b2:	0001b597          	auipc	a1,0x1b
    800033b6:	d365a583          	lw	a1,-714(a1) # 8001e0e8 <sb+0x18>
    800033ba:	9dbd                	addw	a1,a1,a5
    800033bc:	4108                	lw	a0,0(a0)
    800033be:	9c9ff0ef          	jal	80002d86 <bread>
    800033c2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800033c4:	05850793          	addi	a5,a0,88
    800033c8:	40d8                	lw	a4,4(s1)
    800033ca:	8b3d                	andi	a4,a4,15
    800033cc:	071a                	slli	a4,a4,0x6
    800033ce:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800033d0:	04449703          	lh	a4,68(s1)
    800033d4:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800033d8:	04649703          	lh	a4,70(s1)
    800033dc:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800033e0:	04849703          	lh	a4,72(s1)
    800033e4:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800033e8:	04a49703          	lh	a4,74(s1)
    800033ec:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800033f0:	44f8                	lw	a4,76(s1)
    800033f2:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800033f4:	03400613          	li	a2,52
    800033f8:	05048593          	addi	a1,s1,80
    800033fc:	00c78513          	addi	a0,a5,12
    80003400:	8fffd0ef          	jal	80000cfe <memmove>
  log_write(bp);
    80003404:	854a                	mv	a0,s2
    80003406:	3bb000ef          	jal	80003fc0 <log_write>
  brelse(bp);
    8000340a:	854a                	mv	a0,s2
    8000340c:	a83ff0ef          	jal	80002e8e <brelse>
}
    80003410:	60e2                	ld	ra,24(sp)
    80003412:	6442                	ld	s0,16(sp)
    80003414:	64a2                	ld	s1,8(sp)
    80003416:	6902                	ld	s2,0(sp)
    80003418:	6105                	addi	sp,sp,32
    8000341a:	8082                	ret

000000008000341c <idup>:
{
    8000341c:	1101                	addi	sp,sp,-32
    8000341e:	ec06                	sd	ra,24(sp)
    80003420:	e822                	sd	s0,16(sp)
    80003422:	e426                	sd	s1,8(sp)
    80003424:	1000                	addi	s0,sp,32
    80003426:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003428:	0001b517          	auipc	a0,0x1b
    8000342c:	cc850513          	addi	a0,a0,-824 # 8001e0f0 <itable>
    80003430:	f9efd0ef          	jal	80000bce <acquire>
  ip->ref++;
    80003434:	449c                	lw	a5,8(s1)
    80003436:	2785                	addiw	a5,a5,1
    80003438:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000343a:	0001b517          	auipc	a0,0x1b
    8000343e:	cb650513          	addi	a0,a0,-842 # 8001e0f0 <itable>
    80003442:	825fd0ef          	jal	80000c66 <release>
}
    80003446:	8526                	mv	a0,s1
    80003448:	60e2                	ld	ra,24(sp)
    8000344a:	6442                	ld	s0,16(sp)
    8000344c:	64a2                	ld	s1,8(sp)
    8000344e:	6105                	addi	sp,sp,32
    80003450:	8082                	ret

0000000080003452 <ilock>:
{
    80003452:	1101                	addi	sp,sp,-32
    80003454:	ec06                	sd	ra,24(sp)
    80003456:	e822                	sd	s0,16(sp)
    80003458:	e426                	sd	s1,8(sp)
    8000345a:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000345c:	cd19                	beqz	a0,8000347a <ilock+0x28>
    8000345e:	84aa                	mv	s1,a0
    80003460:	451c                	lw	a5,8(a0)
    80003462:	00f05c63          	blez	a5,8000347a <ilock+0x28>
  acquiresleep(&ip->lock);
    80003466:	0541                	addi	a0,a0,16
    80003468:	451000ef          	jal	800040b8 <acquiresleep>
  if(ip->valid == 0){
    8000346c:	40bc                	lw	a5,64(s1)
    8000346e:	cf89                	beqz	a5,80003488 <ilock+0x36>
}
    80003470:	60e2                	ld	ra,24(sp)
    80003472:	6442                	ld	s0,16(sp)
    80003474:	64a2                	ld	s1,8(sp)
    80003476:	6105                	addi	sp,sp,32
    80003478:	8082                	ret
    8000347a:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000347c:	00004517          	auipc	a0,0x4
    80003480:	fec50513          	addi	a0,a0,-20 # 80007468 <etext+0x468>
    80003484:	b5cfd0ef          	jal	800007e0 <panic>
    80003488:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000348a:	40dc                	lw	a5,4(s1)
    8000348c:	0047d79b          	srliw	a5,a5,0x4
    80003490:	0001b597          	auipc	a1,0x1b
    80003494:	c585a583          	lw	a1,-936(a1) # 8001e0e8 <sb+0x18>
    80003498:	9dbd                	addw	a1,a1,a5
    8000349a:	4088                	lw	a0,0(s1)
    8000349c:	8ebff0ef          	jal	80002d86 <bread>
    800034a0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800034a2:	05850593          	addi	a1,a0,88
    800034a6:	40dc                	lw	a5,4(s1)
    800034a8:	8bbd                	andi	a5,a5,15
    800034aa:	079a                	slli	a5,a5,0x6
    800034ac:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800034ae:	00059783          	lh	a5,0(a1)
    800034b2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800034b6:	00259783          	lh	a5,2(a1)
    800034ba:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800034be:	00459783          	lh	a5,4(a1)
    800034c2:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800034c6:	00659783          	lh	a5,6(a1)
    800034ca:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800034ce:	459c                	lw	a5,8(a1)
    800034d0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800034d2:	03400613          	li	a2,52
    800034d6:	05b1                	addi	a1,a1,12
    800034d8:	05048513          	addi	a0,s1,80
    800034dc:	823fd0ef          	jal	80000cfe <memmove>
    brelse(bp);
    800034e0:	854a                	mv	a0,s2
    800034e2:	9adff0ef          	jal	80002e8e <brelse>
    ip->valid = 1;
    800034e6:	4785                	li	a5,1
    800034e8:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800034ea:	04449783          	lh	a5,68(s1)
    800034ee:	c399                	beqz	a5,800034f4 <ilock+0xa2>
    800034f0:	6902                	ld	s2,0(sp)
    800034f2:	bfbd                	j	80003470 <ilock+0x1e>
      panic("ilock: no type");
    800034f4:	00004517          	auipc	a0,0x4
    800034f8:	f7c50513          	addi	a0,a0,-132 # 80007470 <etext+0x470>
    800034fc:	ae4fd0ef          	jal	800007e0 <panic>

0000000080003500 <iunlock>:
{
    80003500:	1101                	addi	sp,sp,-32
    80003502:	ec06                	sd	ra,24(sp)
    80003504:	e822                	sd	s0,16(sp)
    80003506:	e426                	sd	s1,8(sp)
    80003508:	e04a                	sd	s2,0(sp)
    8000350a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000350c:	c505                	beqz	a0,80003534 <iunlock+0x34>
    8000350e:	84aa                	mv	s1,a0
    80003510:	01050913          	addi	s2,a0,16
    80003514:	854a                	mv	a0,s2
    80003516:	421000ef          	jal	80004136 <holdingsleep>
    8000351a:	cd09                	beqz	a0,80003534 <iunlock+0x34>
    8000351c:	449c                	lw	a5,8(s1)
    8000351e:	00f05b63          	blez	a5,80003534 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003522:	854a                	mv	a0,s2
    80003524:	3db000ef          	jal	800040fe <releasesleep>
}
    80003528:	60e2                	ld	ra,24(sp)
    8000352a:	6442                	ld	s0,16(sp)
    8000352c:	64a2                	ld	s1,8(sp)
    8000352e:	6902                	ld	s2,0(sp)
    80003530:	6105                	addi	sp,sp,32
    80003532:	8082                	ret
    panic("iunlock");
    80003534:	00004517          	auipc	a0,0x4
    80003538:	f4c50513          	addi	a0,a0,-180 # 80007480 <etext+0x480>
    8000353c:	aa4fd0ef          	jal	800007e0 <panic>

0000000080003540 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003540:	7179                	addi	sp,sp,-48
    80003542:	f406                	sd	ra,40(sp)
    80003544:	f022                	sd	s0,32(sp)
    80003546:	ec26                	sd	s1,24(sp)
    80003548:	e84a                	sd	s2,16(sp)
    8000354a:	e44e                	sd	s3,8(sp)
    8000354c:	1800                	addi	s0,sp,48
    8000354e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003550:	05050493          	addi	s1,a0,80
    80003554:	08050913          	addi	s2,a0,128
    80003558:	a021                	j	80003560 <itrunc+0x20>
    8000355a:	0491                	addi	s1,s1,4
    8000355c:	01248b63          	beq	s1,s2,80003572 <itrunc+0x32>
    if(ip->addrs[i]){
    80003560:	408c                	lw	a1,0(s1)
    80003562:	dde5                	beqz	a1,8000355a <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003564:	0009a503          	lw	a0,0(s3)
    80003568:	a17ff0ef          	jal	80002f7e <bfree>
      ip->addrs[i] = 0;
    8000356c:	0004a023          	sw	zero,0(s1)
    80003570:	b7ed                	j	8000355a <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003572:	0809a583          	lw	a1,128(s3)
    80003576:	ed89                	bnez	a1,80003590 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003578:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000357c:	854e                	mv	a0,s3
    8000357e:	e21ff0ef          	jal	8000339e <iupdate>
}
    80003582:	70a2                	ld	ra,40(sp)
    80003584:	7402                	ld	s0,32(sp)
    80003586:	64e2                	ld	s1,24(sp)
    80003588:	6942                	ld	s2,16(sp)
    8000358a:	69a2                	ld	s3,8(sp)
    8000358c:	6145                	addi	sp,sp,48
    8000358e:	8082                	ret
    80003590:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003592:	0009a503          	lw	a0,0(s3)
    80003596:	ff0ff0ef          	jal	80002d86 <bread>
    8000359a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000359c:	05850493          	addi	s1,a0,88
    800035a0:	45850913          	addi	s2,a0,1112
    800035a4:	a021                	j	800035ac <itrunc+0x6c>
    800035a6:	0491                	addi	s1,s1,4
    800035a8:	01248963          	beq	s1,s2,800035ba <itrunc+0x7a>
      if(a[j])
    800035ac:	408c                	lw	a1,0(s1)
    800035ae:	dde5                	beqz	a1,800035a6 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800035b0:	0009a503          	lw	a0,0(s3)
    800035b4:	9cbff0ef          	jal	80002f7e <bfree>
    800035b8:	b7fd                	j	800035a6 <itrunc+0x66>
    brelse(bp);
    800035ba:	8552                	mv	a0,s4
    800035bc:	8d3ff0ef          	jal	80002e8e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800035c0:	0809a583          	lw	a1,128(s3)
    800035c4:	0009a503          	lw	a0,0(s3)
    800035c8:	9b7ff0ef          	jal	80002f7e <bfree>
    ip->addrs[NDIRECT] = 0;
    800035cc:	0809a023          	sw	zero,128(s3)
    800035d0:	6a02                	ld	s4,0(sp)
    800035d2:	b75d                	j	80003578 <itrunc+0x38>

00000000800035d4 <iput>:
{
    800035d4:	1101                	addi	sp,sp,-32
    800035d6:	ec06                	sd	ra,24(sp)
    800035d8:	e822                	sd	s0,16(sp)
    800035da:	e426                	sd	s1,8(sp)
    800035dc:	1000                	addi	s0,sp,32
    800035de:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800035e0:	0001b517          	auipc	a0,0x1b
    800035e4:	b1050513          	addi	a0,a0,-1264 # 8001e0f0 <itable>
    800035e8:	de6fd0ef          	jal	80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800035ec:	4498                	lw	a4,8(s1)
    800035ee:	4785                	li	a5,1
    800035f0:	02f70063          	beq	a4,a5,80003610 <iput+0x3c>
  ip->ref--;
    800035f4:	449c                	lw	a5,8(s1)
    800035f6:	37fd                	addiw	a5,a5,-1
    800035f8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800035fa:	0001b517          	auipc	a0,0x1b
    800035fe:	af650513          	addi	a0,a0,-1290 # 8001e0f0 <itable>
    80003602:	e64fd0ef          	jal	80000c66 <release>
}
    80003606:	60e2                	ld	ra,24(sp)
    80003608:	6442                	ld	s0,16(sp)
    8000360a:	64a2                	ld	s1,8(sp)
    8000360c:	6105                	addi	sp,sp,32
    8000360e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003610:	40bc                	lw	a5,64(s1)
    80003612:	d3ed                	beqz	a5,800035f4 <iput+0x20>
    80003614:	04a49783          	lh	a5,74(s1)
    80003618:	fff1                	bnez	a5,800035f4 <iput+0x20>
    8000361a:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000361c:	01048913          	addi	s2,s1,16
    80003620:	854a                	mv	a0,s2
    80003622:	297000ef          	jal	800040b8 <acquiresleep>
    release(&itable.lock);
    80003626:	0001b517          	auipc	a0,0x1b
    8000362a:	aca50513          	addi	a0,a0,-1334 # 8001e0f0 <itable>
    8000362e:	e38fd0ef          	jal	80000c66 <release>
    itrunc(ip);
    80003632:	8526                	mv	a0,s1
    80003634:	f0dff0ef          	jal	80003540 <itrunc>
    ip->type = 0;
    80003638:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000363c:	8526                	mv	a0,s1
    8000363e:	d61ff0ef          	jal	8000339e <iupdate>
    ip->valid = 0;
    80003642:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003646:	854a                	mv	a0,s2
    80003648:	2b7000ef          	jal	800040fe <releasesleep>
    acquire(&itable.lock);
    8000364c:	0001b517          	auipc	a0,0x1b
    80003650:	aa450513          	addi	a0,a0,-1372 # 8001e0f0 <itable>
    80003654:	d7afd0ef          	jal	80000bce <acquire>
    80003658:	6902                	ld	s2,0(sp)
    8000365a:	bf69                	j	800035f4 <iput+0x20>

000000008000365c <iunlockput>:
{
    8000365c:	1101                	addi	sp,sp,-32
    8000365e:	ec06                	sd	ra,24(sp)
    80003660:	e822                	sd	s0,16(sp)
    80003662:	e426                	sd	s1,8(sp)
    80003664:	1000                	addi	s0,sp,32
    80003666:	84aa                	mv	s1,a0
  iunlock(ip);
    80003668:	e99ff0ef          	jal	80003500 <iunlock>
  iput(ip);
    8000366c:	8526                	mv	a0,s1
    8000366e:	f67ff0ef          	jal	800035d4 <iput>
}
    80003672:	60e2                	ld	ra,24(sp)
    80003674:	6442                	ld	s0,16(sp)
    80003676:	64a2                	ld	s1,8(sp)
    80003678:	6105                	addi	sp,sp,32
    8000367a:	8082                	ret

000000008000367c <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000367c:	0001b717          	auipc	a4,0x1b
    80003680:	a6072703          	lw	a4,-1440(a4) # 8001e0dc <sb+0xc>
    80003684:	4785                	li	a5,1
    80003686:	0ae7ff63          	bgeu	a5,a4,80003744 <ireclaim+0xc8>
{
    8000368a:	7139                	addi	sp,sp,-64
    8000368c:	fc06                	sd	ra,56(sp)
    8000368e:	f822                	sd	s0,48(sp)
    80003690:	f426                	sd	s1,40(sp)
    80003692:	f04a                	sd	s2,32(sp)
    80003694:	ec4e                	sd	s3,24(sp)
    80003696:	e852                	sd	s4,16(sp)
    80003698:	e456                	sd	s5,8(sp)
    8000369a:	e05a                	sd	s6,0(sp)
    8000369c:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000369e:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800036a0:	00050a1b          	sext.w	s4,a0
    800036a4:	0001ba97          	auipc	s5,0x1b
    800036a8:	a2ca8a93          	addi	s5,s5,-1492 # 8001e0d0 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800036ac:	00004b17          	auipc	s6,0x4
    800036b0:	ddcb0b13          	addi	s6,s6,-548 # 80007488 <etext+0x488>
    800036b4:	a099                	j	800036fa <ireclaim+0x7e>
    800036b6:	85ce                	mv	a1,s3
    800036b8:	855a                	mv	a0,s6
    800036ba:	e41fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    800036be:	85ce                	mv	a1,s3
    800036c0:	8552                	mv	a0,s4
    800036c2:	b1dff0ef          	jal	800031de <iget>
    800036c6:	89aa                	mv	s3,a0
    brelse(bp);
    800036c8:	854a                	mv	a0,s2
    800036ca:	fc4ff0ef          	jal	80002e8e <brelse>
    if (ip) {
    800036ce:	00098f63          	beqz	s3,800036ec <ireclaim+0x70>
      begin_op();
    800036d2:	76a000ef          	jal	80003e3c <begin_op>
      ilock(ip);
    800036d6:	854e                	mv	a0,s3
    800036d8:	d7bff0ef          	jal	80003452 <ilock>
      iunlock(ip);
    800036dc:	854e                	mv	a0,s3
    800036de:	e23ff0ef          	jal	80003500 <iunlock>
      iput(ip);
    800036e2:	854e                	mv	a0,s3
    800036e4:	ef1ff0ef          	jal	800035d4 <iput>
      end_op();
    800036e8:	7be000ef          	jal	80003ea6 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800036ec:	0485                	addi	s1,s1,1
    800036ee:	00caa703          	lw	a4,12(s5)
    800036f2:	0004879b          	sext.w	a5,s1
    800036f6:	02e7fd63          	bgeu	a5,a4,80003730 <ireclaim+0xb4>
    800036fa:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800036fe:	0044d593          	srli	a1,s1,0x4
    80003702:	018aa783          	lw	a5,24(s5)
    80003706:	9dbd                	addw	a1,a1,a5
    80003708:	8552                	mv	a0,s4
    8000370a:	e7cff0ef          	jal	80002d86 <bread>
    8000370e:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003710:	05850793          	addi	a5,a0,88
    80003714:	00f9f713          	andi	a4,s3,15
    80003718:	071a                	slli	a4,a4,0x6
    8000371a:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    8000371c:	00079703          	lh	a4,0(a5)
    80003720:	c701                	beqz	a4,80003728 <ireclaim+0xac>
    80003722:	00679783          	lh	a5,6(a5)
    80003726:	dbc1                	beqz	a5,800036b6 <ireclaim+0x3a>
    brelse(bp);
    80003728:	854a                	mv	a0,s2
    8000372a:	f64ff0ef          	jal	80002e8e <brelse>
    if (ip) {
    8000372e:	bf7d                	j	800036ec <ireclaim+0x70>
}
    80003730:	70e2                	ld	ra,56(sp)
    80003732:	7442                	ld	s0,48(sp)
    80003734:	74a2                	ld	s1,40(sp)
    80003736:	7902                	ld	s2,32(sp)
    80003738:	69e2                	ld	s3,24(sp)
    8000373a:	6a42                	ld	s4,16(sp)
    8000373c:	6aa2                	ld	s5,8(sp)
    8000373e:	6b02                	ld	s6,0(sp)
    80003740:	6121                	addi	sp,sp,64
    80003742:	8082                	ret
    80003744:	8082                	ret

0000000080003746 <fsinit>:
fsinit(int dev) {
    80003746:	7179                	addi	sp,sp,-48
    80003748:	f406                	sd	ra,40(sp)
    8000374a:	f022                	sd	s0,32(sp)
    8000374c:	ec26                	sd	s1,24(sp)
    8000374e:	e84a                	sd	s2,16(sp)
    80003750:	e44e                	sd	s3,8(sp)
    80003752:	1800                	addi	s0,sp,48
    80003754:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003756:	4585                	li	a1,1
    80003758:	e2eff0ef          	jal	80002d86 <bread>
    8000375c:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000375e:	0001b997          	auipc	s3,0x1b
    80003762:	97298993          	addi	s3,s3,-1678 # 8001e0d0 <sb>
    80003766:	02000613          	li	a2,32
    8000376a:	05850593          	addi	a1,a0,88
    8000376e:	854e                	mv	a0,s3
    80003770:	d8efd0ef          	jal	80000cfe <memmove>
  brelse(bp);
    80003774:	854a                	mv	a0,s2
    80003776:	f18ff0ef          	jal	80002e8e <brelse>
  if(sb.magic != FSMAGIC)
    8000377a:	0009a703          	lw	a4,0(s3)
    8000377e:	102037b7          	lui	a5,0x10203
    80003782:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003786:	02f71363          	bne	a4,a5,800037ac <fsinit+0x66>
  initlog(dev, &sb);
    8000378a:	0001b597          	auipc	a1,0x1b
    8000378e:	94658593          	addi	a1,a1,-1722 # 8001e0d0 <sb>
    80003792:	8526                	mv	a0,s1
    80003794:	62a000ef          	jal	80003dbe <initlog>
  ireclaim(dev);
    80003798:	8526                	mv	a0,s1
    8000379a:	ee3ff0ef          	jal	8000367c <ireclaim>
}
    8000379e:	70a2                	ld	ra,40(sp)
    800037a0:	7402                	ld	s0,32(sp)
    800037a2:	64e2                	ld	s1,24(sp)
    800037a4:	6942                	ld	s2,16(sp)
    800037a6:	69a2                	ld	s3,8(sp)
    800037a8:	6145                	addi	sp,sp,48
    800037aa:	8082                	ret
    panic("invalid file system");
    800037ac:	00004517          	auipc	a0,0x4
    800037b0:	cfc50513          	addi	a0,a0,-772 # 800074a8 <etext+0x4a8>
    800037b4:	82cfd0ef          	jal	800007e0 <panic>

00000000800037b8 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800037b8:	1141                	addi	sp,sp,-16
    800037ba:	e422                	sd	s0,8(sp)
    800037bc:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800037be:	411c                	lw	a5,0(a0)
    800037c0:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800037c2:	415c                	lw	a5,4(a0)
    800037c4:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800037c6:	04451783          	lh	a5,68(a0)
    800037ca:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800037ce:	04a51783          	lh	a5,74(a0)
    800037d2:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800037d6:	04c56783          	lwu	a5,76(a0)
    800037da:	e99c                	sd	a5,16(a1)
}
    800037dc:	6422                	ld	s0,8(sp)
    800037de:	0141                	addi	sp,sp,16
    800037e0:	8082                	ret

00000000800037e2 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800037e2:	457c                	lw	a5,76(a0)
    800037e4:	0ed7eb63          	bltu	a5,a3,800038da <readi+0xf8>
{
    800037e8:	7159                	addi	sp,sp,-112
    800037ea:	f486                	sd	ra,104(sp)
    800037ec:	f0a2                	sd	s0,96(sp)
    800037ee:	eca6                	sd	s1,88(sp)
    800037f0:	e0d2                	sd	s4,64(sp)
    800037f2:	fc56                	sd	s5,56(sp)
    800037f4:	f85a                	sd	s6,48(sp)
    800037f6:	f45e                	sd	s7,40(sp)
    800037f8:	1880                	addi	s0,sp,112
    800037fa:	8b2a                	mv	s6,a0
    800037fc:	8bae                	mv	s7,a1
    800037fe:	8a32                	mv	s4,a2
    80003800:	84b6                	mv	s1,a3
    80003802:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003804:	9f35                	addw	a4,a4,a3
    return 0;
    80003806:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003808:	0cd76063          	bltu	a4,a3,800038c8 <readi+0xe6>
    8000380c:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    8000380e:	00e7f463          	bgeu	a5,a4,80003816 <readi+0x34>
    n = ip->size - off;
    80003812:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003816:	080a8f63          	beqz	s5,800038b4 <readi+0xd2>
    8000381a:	e8ca                	sd	s2,80(sp)
    8000381c:	f062                	sd	s8,32(sp)
    8000381e:	ec66                	sd	s9,24(sp)
    80003820:	e86a                	sd	s10,16(sp)
    80003822:	e46e                	sd	s11,8(sp)
    80003824:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003826:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000382a:	5c7d                	li	s8,-1
    8000382c:	a80d                	j	8000385e <readi+0x7c>
    8000382e:	020d1d93          	slli	s11,s10,0x20
    80003832:	020ddd93          	srli	s11,s11,0x20
    80003836:	05890613          	addi	a2,s2,88
    8000383a:	86ee                	mv	a3,s11
    8000383c:	963a                	add	a2,a2,a4
    8000383e:	85d2                	mv	a1,s4
    80003840:	855e                	mv	a0,s7
    80003842:	bcffe0ef          	jal	80002410 <either_copyout>
    80003846:	05850763          	beq	a0,s8,80003894 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000384a:	854a                	mv	a0,s2
    8000384c:	e42ff0ef          	jal	80002e8e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003850:	013d09bb          	addw	s3,s10,s3
    80003854:	009d04bb          	addw	s1,s10,s1
    80003858:	9a6e                	add	s4,s4,s11
    8000385a:	0559f763          	bgeu	s3,s5,800038a8 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    8000385e:	00a4d59b          	srliw	a1,s1,0xa
    80003862:	855a                	mv	a0,s6
    80003864:	8a7ff0ef          	jal	8000310a <bmap>
    80003868:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000386c:	c5b1                	beqz	a1,800038b8 <readi+0xd6>
    bp = bread(ip->dev, addr);
    8000386e:	000b2503          	lw	a0,0(s6)
    80003872:	d14ff0ef          	jal	80002d86 <bread>
    80003876:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003878:	3ff4f713          	andi	a4,s1,1023
    8000387c:	40ec87bb          	subw	a5,s9,a4
    80003880:	413a86bb          	subw	a3,s5,s3
    80003884:	8d3e                	mv	s10,a5
    80003886:	2781                	sext.w	a5,a5
    80003888:	0006861b          	sext.w	a2,a3
    8000388c:	faf671e3          	bgeu	a2,a5,8000382e <readi+0x4c>
    80003890:	8d36                	mv	s10,a3
    80003892:	bf71                	j	8000382e <readi+0x4c>
      brelse(bp);
    80003894:	854a                	mv	a0,s2
    80003896:	df8ff0ef          	jal	80002e8e <brelse>
      tot = -1;
    8000389a:	59fd                	li	s3,-1
      break;
    8000389c:	6946                	ld	s2,80(sp)
    8000389e:	7c02                	ld	s8,32(sp)
    800038a0:	6ce2                	ld	s9,24(sp)
    800038a2:	6d42                	ld	s10,16(sp)
    800038a4:	6da2                	ld	s11,8(sp)
    800038a6:	a831                	j	800038c2 <readi+0xe0>
    800038a8:	6946                	ld	s2,80(sp)
    800038aa:	7c02                	ld	s8,32(sp)
    800038ac:	6ce2                	ld	s9,24(sp)
    800038ae:	6d42                	ld	s10,16(sp)
    800038b0:	6da2                	ld	s11,8(sp)
    800038b2:	a801                	j	800038c2 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038b4:	89d6                	mv	s3,s5
    800038b6:	a031                	j	800038c2 <readi+0xe0>
    800038b8:	6946                	ld	s2,80(sp)
    800038ba:	7c02                	ld	s8,32(sp)
    800038bc:	6ce2                	ld	s9,24(sp)
    800038be:	6d42                	ld	s10,16(sp)
    800038c0:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800038c2:	0009851b          	sext.w	a0,s3
    800038c6:	69a6                	ld	s3,72(sp)
}
    800038c8:	70a6                	ld	ra,104(sp)
    800038ca:	7406                	ld	s0,96(sp)
    800038cc:	64e6                	ld	s1,88(sp)
    800038ce:	6a06                	ld	s4,64(sp)
    800038d0:	7ae2                	ld	s5,56(sp)
    800038d2:	7b42                	ld	s6,48(sp)
    800038d4:	7ba2                	ld	s7,40(sp)
    800038d6:	6165                	addi	sp,sp,112
    800038d8:	8082                	ret
    return 0;
    800038da:	4501                	li	a0,0
}
    800038dc:	8082                	ret

00000000800038de <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800038de:	457c                	lw	a5,76(a0)
    800038e0:	10d7e063          	bltu	a5,a3,800039e0 <writei+0x102>
{
    800038e4:	7159                	addi	sp,sp,-112
    800038e6:	f486                	sd	ra,104(sp)
    800038e8:	f0a2                	sd	s0,96(sp)
    800038ea:	e8ca                	sd	s2,80(sp)
    800038ec:	e0d2                	sd	s4,64(sp)
    800038ee:	fc56                	sd	s5,56(sp)
    800038f0:	f85a                	sd	s6,48(sp)
    800038f2:	f45e                	sd	s7,40(sp)
    800038f4:	1880                	addi	s0,sp,112
    800038f6:	8aaa                	mv	s5,a0
    800038f8:	8bae                	mv	s7,a1
    800038fa:	8a32                	mv	s4,a2
    800038fc:	8936                	mv	s2,a3
    800038fe:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003900:	00e687bb          	addw	a5,a3,a4
    80003904:	0ed7e063          	bltu	a5,a3,800039e4 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003908:	00043737          	lui	a4,0x43
    8000390c:	0cf76e63          	bltu	a4,a5,800039e8 <writei+0x10a>
    80003910:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003912:	0a0b0f63          	beqz	s6,800039d0 <writei+0xf2>
    80003916:	eca6                	sd	s1,88(sp)
    80003918:	f062                	sd	s8,32(sp)
    8000391a:	ec66                	sd	s9,24(sp)
    8000391c:	e86a                	sd	s10,16(sp)
    8000391e:	e46e                	sd	s11,8(sp)
    80003920:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003922:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003926:	5c7d                	li	s8,-1
    80003928:	a825                	j	80003960 <writei+0x82>
    8000392a:	020d1d93          	slli	s11,s10,0x20
    8000392e:	020ddd93          	srli	s11,s11,0x20
    80003932:	05848513          	addi	a0,s1,88
    80003936:	86ee                	mv	a3,s11
    80003938:	8652                	mv	a2,s4
    8000393a:	85de                	mv	a1,s7
    8000393c:	953a                	add	a0,a0,a4
    8000393e:	b1dfe0ef          	jal	8000245a <either_copyin>
    80003942:	05850a63          	beq	a0,s8,80003996 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003946:	8526                	mv	a0,s1
    80003948:	678000ef          	jal	80003fc0 <log_write>
    brelse(bp);
    8000394c:	8526                	mv	a0,s1
    8000394e:	d40ff0ef          	jal	80002e8e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003952:	013d09bb          	addw	s3,s10,s3
    80003956:	012d093b          	addw	s2,s10,s2
    8000395a:	9a6e                	add	s4,s4,s11
    8000395c:	0569f063          	bgeu	s3,s6,8000399c <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003960:	00a9559b          	srliw	a1,s2,0xa
    80003964:	8556                	mv	a0,s5
    80003966:	fa4ff0ef          	jal	8000310a <bmap>
    8000396a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000396e:	c59d                	beqz	a1,8000399c <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003970:	000aa503          	lw	a0,0(s5)
    80003974:	c12ff0ef          	jal	80002d86 <bread>
    80003978:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000397a:	3ff97713          	andi	a4,s2,1023
    8000397e:	40ec87bb          	subw	a5,s9,a4
    80003982:	413b06bb          	subw	a3,s6,s3
    80003986:	8d3e                	mv	s10,a5
    80003988:	2781                	sext.w	a5,a5
    8000398a:	0006861b          	sext.w	a2,a3
    8000398e:	f8f67ee3          	bgeu	a2,a5,8000392a <writei+0x4c>
    80003992:	8d36                	mv	s10,a3
    80003994:	bf59                	j	8000392a <writei+0x4c>
      brelse(bp);
    80003996:	8526                	mv	a0,s1
    80003998:	cf6ff0ef          	jal	80002e8e <brelse>
  }

  if(off > ip->size)
    8000399c:	04caa783          	lw	a5,76(s5)
    800039a0:	0327fa63          	bgeu	a5,s2,800039d4 <writei+0xf6>
    ip->size = off;
    800039a4:	052aa623          	sw	s2,76(s5)
    800039a8:	64e6                	ld	s1,88(sp)
    800039aa:	7c02                	ld	s8,32(sp)
    800039ac:	6ce2                	ld	s9,24(sp)
    800039ae:	6d42                	ld	s10,16(sp)
    800039b0:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800039b2:	8556                	mv	a0,s5
    800039b4:	9ebff0ef          	jal	8000339e <iupdate>

  return tot;
    800039b8:	0009851b          	sext.w	a0,s3
    800039bc:	69a6                	ld	s3,72(sp)
}
    800039be:	70a6                	ld	ra,104(sp)
    800039c0:	7406                	ld	s0,96(sp)
    800039c2:	6946                	ld	s2,80(sp)
    800039c4:	6a06                	ld	s4,64(sp)
    800039c6:	7ae2                	ld	s5,56(sp)
    800039c8:	7b42                	ld	s6,48(sp)
    800039ca:	7ba2                	ld	s7,40(sp)
    800039cc:	6165                	addi	sp,sp,112
    800039ce:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039d0:	89da                	mv	s3,s6
    800039d2:	b7c5                	j	800039b2 <writei+0xd4>
    800039d4:	64e6                	ld	s1,88(sp)
    800039d6:	7c02                	ld	s8,32(sp)
    800039d8:	6ce2                	ld	s9,24(sp)
    800039da:	6d42                	ld	s10,16(sp)
    800039dc:	6da2                	ld	s11,8(sp)
    800039de:	bfd1                	j	800039b2 <writei+0xd4>
    return -1;
    800039e0:	557d                	li	a0,-1
}
    800039e2:	8082                	ret
    return -1;
    800039e4:	557d                	li	a0,-1
    800039e6:	bfe1                	j	800039be <writei+0xe0>
    return -1;
    800039e8:	557d                	li	a0,-1
    800039ea:	bfd1                	j	800039be <writei+0xe0>

00000000800039ec <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800039ec:	1141                	addi	sp,sp,-16
    800039ee:	e406                	sd	ra,8(sp)
    800039f0:	e022                	sd	s0,0(sp)
    800039f2:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800039f4:	4639                	li	a2,14
    800039f6:	b78fd0ef          	jal	80000d6e <strncmp>
}
    800039fa:	60a2                	ld	ra,8(sp)
    800039fc:	6402                	ld	s0,0(sp)
    800039fe:	0141                	addi	sp,sp,16
    80003a00:	8082                	ret

0000000080003a02 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003a02:	7139                	addi	sp,sp,-64
    80003a04:	fc06                	sd	ra,56(sp)
    80003a06:	f822                	sd	s0,48(sp)
    80003a08:	f426                	sd	s1,40(sp)
    80003a0a:	f04a                	sd	s2,32(sp)
    80003a0c:	ec4e                	sd	s3,24(sp)
    80003a0e:	e852                	sd	s4,16(sp)
    80003a10:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003a12:	04451703          	lh	a4,68(a0)
    80003a16:	4785                	li	a5,1
    80003a18:	00f71a63          	bne	a4,a5,80003a2c <dirlookup+0x2a>
    80003a1c:	892a                	mv	s2,a0
    80003a1e:	89ae                	mv	s3,a1
    80003a20:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a22:	457c                	lw	a5,76(a0)
    80003a24:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003a26:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a28:	e39d                	bnez	a5,80003a4e <dirlookup+0x4c>
    80003a2a:	a095                	j	80003a8e <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003a2c:	00004517          	auipc	a0,0x4
    80003a30:	a9450513          	addi	a0,a0,-1388 # 800074c0 <etext+0x4c0>
    80003a34:	dadfc0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    80003a38:	00004517          	auipc	a0,0x4
    80003a3c:	aa050513          	addi	a0,a0,-1376 # 800074d8 <etext+0x4d8>
    80003a40:	da1fc0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a44:	24c1                	addiw	s1,s1,16
    80003a46:	04c92783          	lw	a5,76(s2)
    80003a4a:	04f4f163          	bgeu	s1,a5,80003a8c <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a4e:	4741                	li	a4,16
    80003a50:	86a6                	mv	a3,s1
    80003a52:	fc040613          	addi	a2,s0,-64
    80003a56:	4581                	li	a1,0
    80003a58:	854a                	mv	a0,s2
    80003a5a:	d89ff0ef          	jal	800037e2 <readi>
    80003a5e:	47c1                	li	a5,16
    80003a60:	fcf51ce3          	bne	a0,a5,80003a38 <dirlookup+0x36>
    if(de.inum == 0)
    80003a64:	fc045783          	lhu	a5,-64(s0)
    80003a68:	dff1                	beqz	a5,80003a44 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003a6a:	fc240593          	addi	a1,s0,-62
    80003a6e:	854e                	mv	a0,s3
    80003a70:	f7dff0ef          	jal	800039ec <namecmp>
    80003a74:	f961                	bnez	a0,80003a44 <dirlookup+0x42>
      if(poff)
    80003a76:	000a0463          	beqz	s4,80003a7e <dirlookup+0x7c>
        *poff = off;
    80003a7a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003a7e:	fc045583          	lhu	a1,-64(s0)
    80003a82:	00092503          	lw	a0,0(s2)
    80003a86:	f58ff0ef          	jal	800031de <iget>
    80003a8a:	a011                	j	80003a8e <dirlookup+0x8c>
  return 0;
    80003a8c:	4501                	li	a0,0
}
    80003a8e:	70e2                	ld	ra,56(sp)
    80003a90:	7442                	ld	s0,48(sp)
    80003a92:	74a2                	ld	s1,40(sp)
    80003a94:	7902                	ld	s2,32(sp)
    80003a96:	69e2                	ld	s3,24(sp)
    80003a98:	6a42                	ld	s4,16(sp)
    80003a9a:	6121                	addi	sp,sp,64
    80003a9c:	8082                	ret

0000000080003a9e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003a9e:	711d                	addi	sp,sp,-96
    80003aa0:	ec86                	sd	ra,88(sp)
    80003aa2:	e8a2                	sd	s0,80(sp)
    80003aa4:	e4a6                	sd	s1,72(sp)
    80003aa6:	e0ca                	sd	s2,64(sp)
    80003aa8:	fc4e                	sd	s3,56(sp)
    80003aaa:	f852                	sd	s4,48(sp)
    80003aac:	f456                	sd	s5,40(sp)
    80003aae:	f05a                	sd	s6,32(sp)
    80003ab0:	ec5e                	sd	s7,24(sp)
    80003ab2:	e862                	sd	s8,16(sp)
    80003ab4:	e466                	sd	s9,8(sp)
    80003ab6:	1080                	addi	s0,sp,96
    80003ab8:	84aa                	mv	s1,a0
    80003aba:	8b2e                	mv	s6,a1
    80003abc:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003abe:	00054703          	lbu	a4,0(a0)
    80003ac2:	02f00793          	li	a5,47
    80003ac6:	00f70e63          	beq	a4,a5,80003ae2 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003aca:	f7dfd0ef          	jal	80001a46 <myproc>
    80003ace:	15053503          	ld	a0,336(a0)
    80003ad2:	94bff0ef          	jal	8000341c <idup>
    80003ad6:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003ad8:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003adc:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ade:	4b85                	li	s7,1
    80003ae0:	a871                	j	80003b7c <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003ae2:	4585                	li	a1,1
    80003ae4:	4505                	li	a0,1
    80003ae6:	ef8ff0ef          	jal	800031de <iget>
    80003aea:	8a2a                	mv	s4,a0
    80003aec:	b7f5                	j	80003ad8 <namex+0x3a>
      iunlockput(ip);
    80003aee:	8552                	mv	a0,s4
    80003af0:	b6dff0ef          	jal	8000365c <iunlockput>
      return 0;
    80003af4:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003af6:	8552                	mv	a0,s4
    80003af8:	60e6                	ld	ra,88(sp)
    80003afa:	6446                	ld	s0,80(sp)
    80003afc:	64a6                	ld	s1,72(sp)
    80003afe:	6906                	ld	s2,64(sp)
    80003b00:	79e2                	ld	s3,56(sp)
    80003b02:	7a42                	ld	s4,48(sp)
    80003b04:	7aa2                	ld	s5,40(sp)
    80003b06:	7b02                	ld	s6,32(sp)
    80003b08:	6be2                	ld	s7,24(sp)
    80003b0a:	6c42                	ld	s8,16(sp)
    80003b0c:	6ca2                	ld	s9,8(sp)
    80003b0e:	6125                	addi	sp,sp,96
    80003b10:	8082                	ret
      iunlock(ip);
    80003b12:	8552                	mv	a0,s4
    80003b14:	9edff0ef          	jal	80003500 <iunlock>
      return ip;
    80003b18:	bff9                	j	80003af6 <namex+0x58>
      iunlockput(ip);
    80003b1a:	8552                	mv	a0,s4
    80003b1c:	b41ff0ef          	jal	8000365c <iunlockput>
      return 0;
    80003b20:	8a4e                	mv	s4,s3
    80003b22:	bfd1                	j	80003af6 <namex+0x58>
  len = path - s;
    80003b24:	40998633          	sub	a2,s3,s1
    80003b28:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003b2c:	099c5063          	bge	s8,s9,80003bac <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003b30:	4639                	li	a2,14
    80003b32:	85a6                	mv	a1,s1
    80003b34:	8556                	mv	a0,s5
    80003b36:	9c8fd0ef          	jal	80000cfe <memmove>
    80003b3a:	84ce                	mv	s1,s3
  while(*path == '/')
    80003b3c:	0004c783          	lbu	a5,0(s1)
    80003b40:	01279763          	bne	a5,s2,80003b4e <namex+0xb0>
    path++;
    80003b44:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003b46:	0004c783          	lbu	a5,0(s1)
    80003b4a:	ff278de3          	beq	a5,s2,80003b44 <namex+0xa6>
    ilock(ip);
    80003b4e:	8552                	mv	a0,s4
    80003b50:	903ff0ef          	jal	80003452 <ilock>
    if(ip->type != T_DIR){
    80003b54:	044a1783          	lh	a5,68(s4)
    80003b58:	f9779be3          	bne	a5,s7,80003aee <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003b5c:	000b0563          	beqz	s6,80003b66 <namex+0xc8>
    80003b60:	0004c783          	lbu	a5,0(s1)
    80003b64:	d7dd                	beqz	a5,80003b12 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003b66:	4601                	li	a2,0
    80003b68:	85d6                	mv	a1,s5
    80003b6a:	8552                	mv	a0,s4
    80003b6c:	e97ff0ef          	jal	80003a02 <dirlookup>
    80003b70:	89aa                	mv	s3,a0
    80003b72:	d545                	beqz	a0,80003b1a <namex+0x7c>
    iunlockput(ip);
    80003b74:	8552                	mv	a0,s4
    80003b76:	ae7ff0ef          	jal	8000365c <iunlockput>
    ip = next;
    80003b7a:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003b7c:	0004c783          	lbu	a5,0(s1)
    80003b80:	01279763          	bne	a5,s2,80003b8e <namex+0xf0>
    path++;
    80003b84:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003b86:	0004c783          	lbu	a5,0(s1)
    80003b8a:	ff278de3          	beq	a5,s2,80003b84 <namex+0xe6>
  if(*path == 0)
    80003b8e:	cb8d                	beqz	a5,80003bc0 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003b90:	0004c783          	lbu	a5,0(s1)
    80003b94:	89a6                	mv	s3,s1
  len = path - s;
    80003b96:	4c81                	li	s9,0
    80003b98:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003b9a:	01278963          	beq	a5,s2,80003bac <namex+0x10e>
    80003b9e:	d3d9                	beqz	a5,80003b24 <namex+0x86>
    path++;
    80003ba0:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003ba2:	0009c783          	lbu	a5,0(s3)
    80003ba6:	ff279ce3          	bne	a5,s2,80003b9e <namex+0x100>
    80003baa:	bfad                	j	80003b24 <namex+0x86>
    memmove(name, s, len);
    80003bac:	2601                	sext.w	a2,a2
    80003bae:	85a6                	mv	a1,s1
    80003bb0:	8556                	mv	a0,s5
    80003bb2:	94cfd0ef          	jal	80000cfe <memmove>
    name[len] = 0;
    80003bb6:	9cd6                	add	s9,s9,s5
    80003bb8:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003bbc:	84ce                	mv	s1,s3
    80003bbe:	bfbd                	j	80003b3c <namex+0x9e>
  if(nameiparent){
    80003bc0:	f20b0be3          	beqz	s6,80003af6 <namex+0x58>
    iput(ip);
    80003bc4:	8552                	mv	a0,s4
    80003bc6:	a0fff0ef          	jal	800035d4 <iput>
    return 0;
    80003bca:	4a01                	li	s4,0
    80003bcc:	b72d                	j	80003af6 <namex+0x58>

0000000080003bce <dirlink>:
{
    80003bce:	7139                	addi	sp,sp,-64
    80003bd0:	fc06                	sd	ra,56(sp)
    80003bd2:	f822                	sd	s0,48(sp)
    80003bd4:	f04a                	sd	s2,32(sp)
    80003bd6:	ec4e                	sd	s3,24(sp)
    80003bd8:	e852                	sd	s4,16(sp)
    80003bda:	0080                	addi	s0,sp,64
    80003bdc:	892a                	mv	s2,a0
    80003bde:	8a2e                	mv	s4,a1
    80003be0:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003be2:	4601                	li	a2,0
    80003be4:	e1fff0ef          	jal	80003a02 <dirlookup>
    80003be8:	e535                	bnez	a0,80003c54 <dirlink+0x86>
    80003bea:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bec:	04c92483          	lw	s1,76(s2)
    80003bf0:	c48d                	beqz	s1,80003c1a <dirlink+0x4c>
    80003bf2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bf4:	4741                	li	a4,16
    80003bf6:	86a6                	mv	a3,s1
    80003bf8:	fc040613          	addi	a2,s0,-64
    80003bfc:	4581                	li	a1,0
    80003bfe:	854a                	mv	a0,s2
    80003c00:	be3ff0ef          	jal	800037e2 <readi>
    80003c04:	47c1                	li	a5,16
    80003c06:	04f51b63          	bne	a0,a5,80003c5c <dirlink+0x8e>
    if(de.inum == 0)
    80003c0a:	fc045783          	lhu	a5,-64(s0)
    80003c0e:	c791                	beqz	a5,80003c1a <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c10:	24c1                	addiw	s1,s1,16
    80003c12:	04c92783          	lw	a5,76(s2)
    80003c16:	fcf4efe3          	bltu	s1,a5,80003bf4 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003c1a:	4639                	li	a2,14
    80003c1c:	85d2                	mv	a1,s4
    80003c1e:	fc240513          	addi	a0,s0,-62
    80003c22:	982fd0ef          	jal	80000da4 <strncpy>
  de.inum = inum;
    80003c26:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c2a:	4741                	li	a4,16
    80003c2c:	86a6                	mv	a3,s1
    80003c2e:	fc040613          	addi	a2,s0,-64
    80003c32:	4581                	li	a1,0
    80003c34:	854a                	mv	a0,s2
    80003c36:	ca9ff0ef          	jal	800038de <writei>
    80003c3a:	1541                	addi	a0,a0,-16
    80003c3c:	00a03533          	snez	a0,a0
    80003c40:	40a00533          	neg	a0,a0
    80003c44:	74a2                	ld	s1,40(sp)
}
    80003c46:	70e2                	ld	ra,56(sp)
    80003c48:	7442                	ld	s0,48(sp)
    80003c4a:	7902                	ld	s2,32(sp)
    80003c4c:	69e2                	ld	s3,24(sp)
    80003c4e:	6a42                	ld	s4,16(sp)
    80003c50:	6121                	addi	sp,sp,64
    80003c52:	8082                	ret
    iput(ip);
    80003c54:	981ff0ef          	jal	800035d4 <iput>
    return -1;
    80003c58:	557d                	li	a0,-1
    80003c5a:	b7f5                	j	80003c46 <dirlink+0x78>
      panic("dirlink read");
    80003c5c:	00004517          	auipc	a0,0x4
    80003c60:	88c50513          	addi	a0,a0,-1908 # 800074e8 <etext+0x4e8>
    80003c64:	b7dfc0ef          	jal	800007e0 <panic>

0000000080003c68 <namei>:

struct inode*
namei(char *path)
{
    80003c68:	1101                	addi	sp,sp,-32
    80003c6a:	ec06                	sd	ra,24(sp)
    80003c6c:	e822                	sd	s0,16(sp)
    80003c6e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003c70:	fe040613          	addi	a2,s0,-32
    80003c74:	4581                	li	a1,0
    80003c76:	e29ff0ef          	jal	80003a9e <namex>
}
    80003c7a:	60e2                	ld	ra,24(sp)
    80003c7c:	6442                	ld	s0,16(sp)
    80003c7e:	6105                	addi	sp,sp,32
    80003c80:	8082                	ret

0000000080003c82 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003c82:	1141                	addi	sp,sp,-16
    80003c84:	e406                	sd	ra,8(sp)
    80003c86:	e022                	sd	s0,0(sp)
    80003c88:	0800                	addi	s0,sp,16
    80003c8a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003c8c:	4585                	li	a1,1
    80003c8e:	e11ff0ef          	jal	80003a9e <namex>
}
    80003c92:	60a2                	ld	ra,8(sp)
    80003c94:	6402                	ld	s0,0(sp)
    80003c96:	0141                	addi	sp,sp,16
    80003c98:	8082                	ret

0000000080003c9a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003c9a:	1101                	addi	sp,sp,-32
    80003c9c:	ec06                	sd	ra,24(sp)
    80003c9e:	e822                	sd	s0,16(sp)
    80003ca0:	e426                	sd	s1,8(sp)
    80003ca2:	e04a                	sd	s2,0(sp)
    80003ca4:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003ca6:	0001c917          	auipc	s2,0x1c
    80003caa:	ef290913          	addi	s2,s2,-270 # 8001fb98 <log>
    80003cae:	01892583          	lw	a1,24(s2)
    80003cb2:	02492503          	lw	a0,36(s2)
    80003cb6:	8d0ff0ef          	jal	80002d86 <bread>
    80003cba:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003cbc:	02892603          	lw	a2,40(s2)
    80003cc0:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003cc2:	00c05f63          	blez	a2,80003ce0 <write_head+0x46>
    80003cc6:	0001c717          	auipc	a4,0x1c
    80003cca:	efe70713          	addi	a4,a4,-258 # 8001fbc4 <log+0x2c>
    80003cce:	87aa                	mv	a5,a0
    80003cd0:	060a                	slli	a2,a2,0x2
    80003cd2:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003cd4:	4314                	lw	a3,0(a4)
    80003cd6:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003cd8:	0711                	addi	a4,a4,4
    80003cda:	0791                	addi	a5,a5,4
    80003cdc:	fec79ce3          	bne	a5,a2,80003cd4 <write_head+0x3a>
  }
  bwrite(buf);
    80003ce0:	8526                	mv	a0,s1
    80003ce2:	97aff0ef          	jal	80002e5c <bwrite>
  brelse(buf);
    80003ce6:	8526                	mv	a0,s1
    80003ce8:	9a6ff0ef          	jal	80002e8e <brelse>
}
    80003cec:	60e2                	ld	ra,24(sp)
    80003cee:	6442                	ld	s0,16(sp)
    80003cf0:	64a2                	ld	s1,8(sp)
    80003cf2:	6902                	ld	s2,0(sp)
    80003cf4:	6105                	addi	sp,sp,32
    80003cf6:	8082                	ret

0000000080003cf8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cf8:	0001c797          	auipc	a5,0x1c
    80003cfc:	ec87a783          	lw	a5,-312(a5) # 8001fbc0 <log+0x28>
    80003d00:	0af05e63          	blez	a5,80003dbc <install_trans+0xc4>
{
    80003d04:	715d                	addi	sp,sp,-80
    80003d06:	e486                	sd	ra,72(sp)
    80003d08:	e0a2                	sd	s0,64(sp)
    80003d0a:	fc26                	sd	s1,56(sp)
    80003d0c:	f84a                	sd	s2,48(sp)
    80003d0e:	f44e                	sd	s3,40(sp)
    80003d10:	f052                	sd	s4,32(sp)
    80003d12:	ec56                	sd	s5,24(sp)
    80003d14:	e85a                	sd	s6,16(sp)
    80003d16:	e45e                	sd	s7,8(sp)
    80003d18:	0880                	addi	s0,sp,80
    80003d1a:	8b2a                	mv	s6,a0
    80003d1c:	0001ca97          	auipc	s5,0x1c
    80003d20:	ea8a8a93          	addi	s5,s5,-344 # 8001fbc4 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d24:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d26:	00003b97          	auipc	s7,0x3
    80003d2a:	7d2b8b93          	addi	s7,s7,2002 # 800074f8 <etext+0x4f8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d2e:	0001ca17          	auipc	s4,0x1c
    80003d32:	e6aa0a13          	addi	s4,s4,-406 # 8001fb98 <log>
    80003d36:	a025                	j	80003d5e <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d38:	000aa603          	lw	a2,0(s5)
    80003d3c:	85ce                	mv	a1,s3
    80003d3e:	855e                	mv	a0,s7
    80003d40:	fbafc0ef          	jal	800004fa <printf>
    80003d44:	a839                	j	80003d62 <install_trans+0x6a>
    brelse(lbuf);
    80003d46:	854a                	mv	a0,s2
    80003d48:	946ff0ef          	jal	80002e8e <brelse>
    brelse(dbuf);
    80003d4c:	8526                	mv	a0,s1
    80003d4e:	940ff0ef          	jal	80002e8e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d52:	2985                	addiw	s3,s3,1
    80003d54:	0a91                	addi	s5,s5,4
    80003d56:	028a2783          	lw	a5,40(s4)
    80003d5a:	04f9d663          	bge	s3,a5,80003da6 <install_trans+0xae>
    if(recovering) {
    80003d5e:	fc0b1de3          	bnez	s6,80003d38 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d62:	018a2583          	lw	a1,24(s4)
    80003d66:	013585bb          	addw	a1,a1,s3
    80003d6a:	2585                	addiw	a1,a1,1
    80003d6c:	024a2503          	lw	a0,36(s4)
    80003d70:	816ff0ef          	jal	80002d86 <bread>
    80003d74:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003d76:	000aa583          	lw	a1,0(s5)
    80003d7a:	024a2503          	lw	a0,36(s4)
    80003d7e:	808ff0ef          	jal	80002d86 <bread>
    80003d82:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003d84:	40000613          	li	a2,1024
    80003d88:	05890593          	addi	a1,s2,88
    80003d8c:	05850513          	addi	a0,a0,88
    80003d90:	f6ffc0ef          	jal	80000cfe <memmove>
    bwrite(dbuf);  // write dst to disk
    80003d94:	8526                	mv	a0,s1
    80003d96:	8c6ff0ef          	jal	80002e5c <bwrite>
    if(recovering == 0)
    80003d9a:	fa0b16e3          	bnez	s6,80003d46 <install_trans+0x4e>
      bunpin(dbuf);
    80003d9e:	8526                	mv	a0,s1
    80003da0:	9aaff0ef          	jal	80002f4a <bunpin>
    80003da4:	b74d                	j	80003d46 <install_trans+0x4e>
}
    80003da6:	60a6                	ld	ra,72(sp)
    80003da8:	6406                	ld	s0,64(sp)
    80003daa:	74e2                	ld	s1,56(sp)
    80003dac:	7942                	ld	s2,48(sp)
    80003dae:	79a2                	ld	s3,40(sp)
    80003db0:	7a02                	ld	s4,32(sp)
    80003db2:	6ae2                	ld	s5,24(sp)
    80003db4:	6b42                	ld	s6,16(sp)
    80003db6:	6ba2                	ld	s7,8(sp)
    80003db8:	6161                	addi	sp,sp,80
    80003dba:	8082                	ret
    80003dbc:	8082                	ret

0000000080003dbe <initlog>:
{
    80003dbe:	7179                	addi	sp,sp,-48
    80003dc0:	f406                	sd	ra,40(sp)
    80003dc2:	f022                	sd	s0,32(sp)
    80003dc4:	ec26                	sd	s1,24(sp)
    80003dc6:	e84a                	sd	s2,16(sp)
    80003dc8:	e44e                	sd	s3,8(sp)
    80003dca:	1800                	addi	s0,sp,48
    80003dcc:	892a                	mv	s2,a0
    80003dce:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003dd0:	0001c497          	auipc	s1,0x1c
    80003dd4:	dc848493          	addi	s1,s1,-568 # 8001fb98 <log>
    80003dd8:	00003597          	auipc	a1,0x3
    80003ddc:	74058593          	addi	a1,a1,1856 # 80007518 <etext+0x518>
    80003de0:	8526                	mv	a0,s1
    80003de2:	d6dfc0ef          	jal	80000b4e <initlock>
  log.start = sb->logstart;
    80003de6:	0149a583          	lw	a1,20(s3)
    80003dea:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003dec:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003df0:	854a                	mv	a0,s2
    80003df2:	f95fe0ef          	jal	80002d86 <bread>
  log.lh.n = lh->n;
    80003df6:	4d30                	lw	a2,88(a0)
    80003df8:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003dfa:	00c05f63          	blez	a2,80003e18 <initlog+0x5a>
    80003dfe:	87aa                	mv	a5,a0
    80003e00:	0001c717          	auipc	a4,0x1c
    80003e04:	dc470713          	addi	a4,a4,-572 # 8001fbc4 <log+0x2c>
    80003e08:	060a                	slli	a2,a2,0x2
    80003e0a:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003e0c:	4ff4                	lw	a3,92(a5)
    80003e0e:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e10:	0791                	addi	a5,a5,4
    80003e12:	0711                	addi	a4,a4,4
    80003e14:	fec79ce3          	bne	a5,a2,80003e0c <initlog+0x4e>
  brelse(buf);
    80003e18:	876ff0ef          	jal	80002e8e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003e1c:	4505                	li	a0,1
    80003e1e:	edbff0ef          	jal	80003cf8 <install_trans>
  log.lh.n = 0;
    80003e22:	0001c797          	auipc	a5,0x1c
    80003e26:	d807af23          	sw	zero,-610(a5) # 8001fbc0 <log+0x28>
  write_head(); // clear the log
    80003e2a:	e71ff0ef          	jal	80003c9a <write_head>
}
    80003e2e:	70a2                	ld	ra,40(sp)
    80003e30:	7402                	ld	s0,32(sp)
    80003e32:	64e2                	ld	s1,24(sp)
    80003e34:	6942                	ld	s2,16(sp)
    80003e36:	69a2                	ld	s3,8(sp)
    80003e38:	6145                	addi	sp,sp,48
    80003e3a:	8082                	ret

0000000080003e3c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003e3c:	1101                	addi	sp,sp,-32
    80003e3e:	ec06                	sd	ra,24(sp)
    80003e40:	e822                	sd	s0,16(sp)
    80003e42:	e426                	sd	s1,8(sp)
    80003e44:	e04a                	sd	s2,0(sp)
    80003e46:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003e48:	0001c517          	auipc	a0,0x1c
    80003e4c:	d5050513          	addi	a0,a0,-688 # 8001fb98 <log>
    80003e50:	d7ffc0ef          	jal	80000bce <acquire>
  while(1){
    if(log.committing){
    80003e54:	0001c497          	auipc	s1,0x1c
    80003e58:	d4448493          	addi	s1,s1,-700 # 8001fb98 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003e5c:	4979                	li	s2,30
    80003e5e:	a029                	j	80003e68 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003e60:	85a6                	mv	a1,s1
    80003e62:	8526                	mv	a0,s1
    80003e64:	a50fe0ef          	jal	800020b4 <sleep>
    if(log.committing){
    80003e68:	509c                	lw	a5,32(s1)
    80003e6a:	fbfd                	bnez	a5,80003e60 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003e6c:	4cd8                	lw	a4,28(s1)
    80003e6e:	2705                	addiw	a4,a4,1
    80003e70:	0027179b          	slliw	a5,a4,0x2
    80003e74:	9fb9                	addw	a5,a5,a4
    80003e76:	0017979b          	slliw	a5,a5,0x1
    80003e7a:	5494                	lw	a3,40(s1)
    80003e7c:	9fb5                	addw	a5,a5,a3
    80003e7e:	00f95763          	bge	s2,a5,80003e8c <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003e82:	85a6                	mv	a1,s1
    80003e84:	8526                	mv	a0,s1
    80003e86:	a2efe0ef          	jal	800020b4 <sleep>
    80003e8a:	bff9                	j	80003e68 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003e8c:	0001c517          	auipc	a0,0x1c
    80003e90:	d0c50513          	addi	a0,a0,-756 # 8001fb98 <log>
    80003e94:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003e96:	dd1fc0ef          	jal	80000c66 <release>
      break;
    }
  }
}
    80003e9a:	60e2                	ld	ra,24(sp)
    80003e9c:	6442                	ld	s0,16(sp)
    80003e9e:	64a2                	ld	s1,8(sp)
    80003ea0:	6902                	ld	s2,0(sp)
    80003ea2:	6105                	addi	sp,sp,32
    80003ea4:	8082                	ret

0000000080003ea6 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003ea6:	7139                	addi	sp,sp,-64
    80003ea8:	fc06                	sd	ra,56(sp)
    80003eaa:	f822                	sd	s0,48(sp)
    80003eac:	f426                	sd	s1,40(sp)
    80003eae:	f04a                	sd	s2,32(sp)
    80003eb0:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003eb2:	0001c497          	auipc	s1,0x1c
    80003eb6:	ce648493          	addi	s1,s1,-794 # 8001fb98 <log>
    80003eba:	8526                	mv	a0,s1
    80003ebc:	d13fc0ef          	jal	80000bce <acquire>
  log.outstanding -= 1;
    80003ec0:	4cdc                	lw	a5,28(s1)
    80003ec2:	37fd                	addiw	a5,a5,-1
    80003ec4:	0007891b          	sext.w	s2,a5
    80003ec8:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003eca:	509c                	lw	a5,32(s1)
    80003ecc:	ef9d                	bnez	a5,80003f0a <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003ece:	04091763          	bnez	s2,80003f1c <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003ed2:	0001c497          	auipc	s1,0x1c
    80003ed6:	cc648493          	addi	s1,s1,-826 # 8001fb98 <log>
    80003eda:	4785                	li	a5,1
    80003edc:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003ede:	8526                	mv	a0,s1
    80003ee0:	d87fc0ef          	jal	80000c66 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003ee4:	549c                	lw	a5,40(s1)
    80003ee6:	04f04b63          	bgtz	a5,80003f3c <end_op+0x96>
    acquire(&log.lock);
    80003eea:	0001c497          	auipc	s1,0x1c
    80003eee:	cae48493          	addi	s1,s1,-850 # 8001fb98 <log>
    80003ef2:	8526                	mv	a0,s1
    80003ef4:	cdbfc0ef          	jal	80000bce <acquire>
    log.committing = 0;
    80003ef8:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003efc:	8526                	mv	a0,s1
    80003efe:	a02fe0ef          	jal	80002100 <wakeup>
    release(&log.lock);
    80003f02:	8526                	mv	a0,s1
    80003f04:	d63fc0ef          	jal	80000c66 <release>
}
    80003f08:	a025                	j	80003f30 <end_op+0x8a>
    80003f0a:	ec4e                	sd	s3,24(sp)
    80003f0c:	e852                	sd	s4,16(sp)
    80003f0e:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003f10:	00003517          	auipc	a0,0x3
    80003f14:	61050513          	addi	a0,a0,1552 # 80007520 <etext+0x520>
    80003f18:	8c9fc0ef          	jal	800007e0 <panic>
    wakeup(&log);
    80003f1c:	0001c497          	auipc	s1,0x1c
    80003f20:	c7c48493          	addi	s1,s1,-900 # 8001fb98 <log>
    80003f24:	8526                	mv	a0,s1
    80003f26:	9dafe0ef          	jal	80002100 <wakeup>
  release(&log.lock);
    80003f2a:	8526                	mv	a0,s1
    80003f2c:	d3bfc0ef          	jal	80000c66 <release>
}
    80003f30:	70e2                	ld	ra,56(sp)
    80003f32:	7442                	ld	s0,48(sp)
    80003f34:	74a2                	ld	s1,40(sp)
    80003f36:	7902                	ld	s2,32(sp)
    80003f38:	6121                	addi	sp,sp,64
    80003f3a:	8082                	ret
    80003f3c:	ec4e                	sd	s3,24(sp)
    80003f3e:	e852                	sd	s4,16(sp)
    80003f40:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f42:	0001ca97          	auipc	s5,0x1c
    80003f46:	c82a8a93          	addi	s5,s5,-894 # 8001fbc4 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003f4a:	0001ca17          	auipc	s4,0x1c
    80003f4e:	c4ea0a13          	addi	s4,s4,-946 # 8001fb98 <log>
    80003f52:	018a2583          	lw	a1,24(s4)
    80003f56:	012585bb          	addw	a1,a1,s2
    80003f5a:	2585                	addiw	a1,a1,1
    80003f5c:	024a2503          	lw	a0,36(s4)
    80003f60:	e27fe0ef          	jal	80002d86 <bread>
    80003f64:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003f66:	000aa583          	lw	a1,0(s5)
    80003f6a:	024a2503          	lw	a0,36(s4)
    80003f6e:	e19fe0ef          	jal	80002d86 <bread>
    80003f72:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003f74:	40000613          	li	a2,1024
    80003f78:	05850593          	addi	a1,a0,88
    80003f7c:	05848513          	addi	a0,s1,88
    80003f80:	d7ffc0ef          	jal	80000cfe <memmove>
    bwrite(to);  // write the log
    80003f84:	8526                	mv	a0,s1
    80003f86:	ed7fe0ef          	jal	80002e5c <bwrite>
    brelse(from);
    80003f8a:	854e                	mv	a0,s3
    80003f8c:	f03fe0ef          	jal	80002e8e <brelse>
    brelse(to);
    80003f90:	8526                	mv	a0,s1
    80003f92:	efdfe0ef          	jal	80002e8e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f96:	2905                	addiw	s2,s2,1
    80003f98:	0a91                	addi	s5,s5,4
    80003f9a:	028a2783          	lw	a5,40(s4)
    80003f9e:	faf94ae3          	blt	s2,a5,80003f52 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003fa2:	cf9ff0ef          	jal	80003c9a <write_head>
    install_trans(0); // Now install writes to home locations
    80003fa6:	4501                	li	a0,0
    80003fa8:	d51ff0ef          	jal	80003cf8 <install_trans>
    log.lh.n = 0;
    80003fac:	0001c797          	auipc	a5,0x1c
    80003fb0:	c007aa23          	sw	zero,-1004(a5) # 8001fbc0 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003fb4:	ce7ff0ef          	jal	80003c9a <write_head>
    80003fb8:	69e2                	ld	s3,24(sp)
    80003fba:	6a42                	ld	s4,16(sp)
    80003fbc:	6aa2                	ld	s5,8(sp)
    80003fbe:	b735                	j	80003eea <end_op+0x44>

0000000080003fc0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003fc0:	1101                	addi	sp,sp,-32
    80003fc2:	ec06                	sd	ra,24(sp)
    80003fc4:	e822                	sd	s0,16(sp)
    80003fc6:	e426                	sd	s1,8(sp)
    80003fc8:	e04a                	sd	s2,0(sp)
    80003fca:	1000                	addi	s0,sp,32
    80003fcc:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003fce:	0001c917          	auipc	s2,0x1c
    80003fd2:	bca90913          	addi	s2,s2,-1078 # 8001fb98 <log>
    80003fd6:	854a                	mv	a0,s2
    80003fd8:	bf7fc0ef          	jal	80000bce <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003fdc:	02892603          	lw	a2,40(s2)
    80003fe0:	47f5                	li	a5,29
    80003fe2:	04c7cc63          	blt	a5,a2,8000403a <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003fe6:	0001c797          	auipc	a5,0x1c
    80003fea:	bce7a783          	lw	a5,-1074(a5) # 8001fbb4 <log+0x1c>
    80003fee:	04f05c63          	blez	a5,80004046 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003ff2:	4781                	li	a5,0
    80003ff4:	04c05f63          	blez	a2,80004052 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003ff8:	44cc                	lw	a1,12(s1)
    80003ffa:	0001c717          	auipc	a4,0x1c
    80003ffe:	bca70713          	addi	a4,a4,-1078 # 8001fbc4 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004002:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004004:	4314                	lw	a3,0(a4)
    80004006:	04b68663          	beq	a3,a1,80004052 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    8000400a:	2785                	addiw	a5,a5,1
    8000400c:	0711                	addi	a4,a4,4
    8000400e:	fef61be3          	bne	a2,a5,80004004 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004012:	0621                	addi	a2,a2,8
    80004014:	060a                	slli	a2,a2,0x2
    80004016:	0001c797          	auipc	a5,0x1c
    8000401a:	b8278793          	addi	a5,a5,-1150 # 8001fb98 <log>
    8000401e:	97b2                	add	a5,a5,a2
    80004020:	44d8                	lw	a4,12(s1)
    80004022:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004024:	8526                	mv	a0,s1
    80004026:	ef1fe0ef          	jal	80002f16 <bpin>
    log.lh.n++;
    8000402a:	0001c717          	auipc	a4,0x1c
    8000402e:	b6e70713          	addi	a4,a4,-1170 # 8001fb98 <log>
    80004032:	571c                	lw	a5,40(a4)
    80004034:	2785                	addiw	a5,a5,1
    80004036:	d71c                	sw	a5,40(a4)
    80004038:	a80d                	j	8000406a <log_write+0xaa>
    panic("too big a transaction");
    8000403a:	00003517          	auipc	a0,0x3
    8000403e:	4f650513          	addi	a0,a0,1270 # 80007530 <etext+0x530>
    80004042:	f9efc0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    80004046:	00003517          	auipc	a0,0x3
    8000404a:	50250513          	addi	a0,a0,1282 # 80007548 <etext+0x548>
    8000404e:	f92fc0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    80004052:	00878693          	addi	a3,a5,8
    80004056:	068a                	slli	a3,a3,0x2
    80004058:	0001c717          	auipc	a4,0x1c
    8000405c:	b4070713          	addi	a4,a4,-1216 # 8001fb98 <log>
    80004060:	9736                	add	a4,a4,a3
    80004062:	44d4                	lw	a3,12(s1)
    80004064:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004066:	faf60fe3          	beq	a2,a5,80004024 <log_write+0x64>
  }
  release(&log.lock);
    8000406a:	0001c517          	auipc	a0,0x1c
    8000406e:	b2e50513          	addi	a0,a0,-1234 # 8001fb98 <log>
    80004072:	bf5fc0ef          	jal	80000c66 <release>
}
    80004076:	60e2                	ld	ra,24(sp)
    80004078:	6442                	ld	s0,16(sp)
    8000407a:	64a2                	ld	s1,8(sp)
    8000407c:	6902                	ld	s2,0(sp)
    8000407e:	6105                	addi	sp,sp,32
    80004080:	8082                	ret

0000000080004082 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004082:	1101                	addi	sp,sp,-32
    80004084:	ec06                	sd	ra,24(sp)
    80004086:	e822                	sd	s0,16(sp)
    80004088:	e426                	sd	s1,8(sp)
    8000408a:	e04a                	sd	s2,0(sp)
    8000408c:	1000                	addi	s0,sp,32
    8000408e:	84aa                	mv	s1,a0
    80004090:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004092:	00003597          	auipc	a1,0x3
    80004096:	4d658593          	addi	a1,a1,1238 # 80007568 <etext+0x568>
    8000409a:	0521                	addi	a0,a0,8
    8000409c:	ab3fc0ef          	jal	80000b4e <initlock>
  lk->name = name;
    800040a0:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800040a4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800040a8:	0204a423          	sw	zero,40(s1)
}
    800040ac:	60e2                	ld	ra,24(sp)
    800040ae:	6442                	ld	s0,16(sp)
    800040b0:	64a2                	ld	s1,8(sp)
    800040b2:	6902                	ld	s2,0(sp)
    800040b4:	6105                	addi	sp,sp,32
    800040b6:	8082                	ret

00000000800040b8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800040b8:	1101                	addi	sp,sp,-32
    800040ba:	ec06                	sd	ra,24(sp)
    800040bc:	e822                	sd	s0,16(sp)
    800040be:	e426                	sd	s1,8(sp)
    800040c0:	e04a                	sd	s2,0(sp)
    800040c2:	1000                	addi	s0,sp,32
    800040c4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800040c6:	00850913          	addi	s2,a0,8
    800040ca:	854a                	mv	a0,s2
    800040cc:	b03fc0ef          	jal	80000bce <acquire>
  while (lk->locked) {
    800040d0:	409c                	lw	a5,0(s1)
    800040d2:	c799                	beqz	a5,800040e0 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800040d4:	85ca                	mv	a1,s2
    800040d6:	8526                	mv	a0,s1
    800040d8:	fddfd0ef          	jal	800020b4 <sleep>
  while (lk->locked) {
    800040dc:	409c                	lw	a5,0(s1)
    800040de:	fbfd                	bnez	a5,800040d4 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800040e0:	4785                	li	a5,1
    800040e2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800040e4:	963fd0ef          	jal	80001a46 <myproc>
    800040e8:	591c                	lw	a5,48(a0)
    800040ea:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800040ec:	854a                	mv	a0,s2
    800040ee:	b79fc0ef          	jal	80000c66 <release>
}
    800040f2:	60e2                	ld	ra,24(sp)
    800040f4:	6442                	ld	s0,16(sp)
    800040f6:	64a2                	ld	s1,8(sp)
    800040f8:	6902                	ld	s2,0(sp)
    800040fa:	6105                	addi	sp,sp,32
    800040fc:	8082                	ret

00000000800040fe <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800040fe:	1101                	addi	sp,sp,-32
    80004100:	ec06                	sd	ra,24(sp)
    80004102:	e822                	sd	s0,16(sp)
    80004104:	e426                	sd	s1,8(sp)
    80004106:	e04a                	sd	s2,0(sp)
    80004108:	1000                	addi	s0,sp,32
    8000410a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000410c:	00850913          	addi	s2,a0,8
    80004110:	854a                	mv	a0,s2
    80004112:	abdfc0ef          	jal	80000bce <acquire>
  lk->locked = 0;
    80004116:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000411a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000411e:	8526                	mv	a0,s1
    80004120:	fe1fd0ef          	jal	80002100 <wakeup>
  release(&lk->lk);
    80004124:	854a                	mv	a0,s2
    80004126:	b41fc0ef          	jal	80000c66 <release>
}
    8000412a:	60e2                	ld	ra,24(sp)
    8000412c:	6442                	ld	s0,16(sp)
    8000412e:	64a2                	ld	s1,8(sp)
    80004130:	6902                	ld	s2,0(sp)
    80004132:	6105                	addi	sp,sp,32
    80004134:	8082                	ret

0000000080004136 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004136:	7179                	addi	sp,sp,-48
    80004138:	f406                	sd	ra,40(sp)
    8000413a:	f022                	sd	s0,32(sp)
    8000413c:	ec26                	sd	s1,24(sp)
    8000413e:	e84a                	sd	s2,16(sp)
    80004140:	1800                	addi	s0,sp,48
    80004142:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004144:	00850913          	addi	s2,a0,8
    80004148:	854a                	mv	a0,s2
    8000414a:	a85fc0ef          	jal	80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000414e:	409c                	lw	a5,0(s1)
    80004150:	ef81                	bnez	a5,80004168 <holdingsleep+0x32>
    80004152:	4481                	li	s1,0
  release(&lk->lk);
    80004154:	854a                	mv	a0,s2
    80004156:	b11fc0ef          	jal	80000c66 <release>
  return r;
}
    8000415a:	8526                	mv	a0,s1
    8000415c:	70a2                	ld	ra,40(sp)
    8000415e:	7402                	ld	s0,32(sp)
    80004160:	64e2                	ld	s1,24(sp)
    80004162:	6942                	ld	s2,16(sp)
    80004164:	6145                	addi	sp,sp,48
    80004166:	8082                	ret
    80004168:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000416a:	0284a983          	lw	s3,40(s1)
    8000416e:	8d9fd0ef          	jal	80001a46 <myproc>
    80004172:	5904                	lw	s1,48(a0)
    80004174:	413484b3          	sub	s1,s1,s3
    80004178:	0014b493          	seqz	s1,s1
    8000417c:	69a2                	ld	s3,8(sp)
    8000417e:	bfd9                	j	80004154 <holdingsleep+0x1e>

0000000080004180 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004180:	1141                	addi	sp,sp,-16
    80004182:	e406                	sd	ra,8(sp)
    80004184:	e022                	sd	s0,0(sp)
    80004186:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004188:	00003597          	auipc	a1,0x3
    8000418c:	3f058593          	addi	a1,a1,1008 # 80007578 <etext+0x578>
    80004190:	0001c517          	auipc	a0,0x1c
    80004194:	b5050513          	addi	a0,a0,-1200 # 8001fce0 <ftable>
    80004198:	9b7fc0ef          	jal	80000b4e <initlock>
}
    8000419c:	60a2                	ld	ra,8(sp)
    8000419e:	6402                	ld	s0,0(sp)
    800041a0:	0141                	addi	sp,sp,16
    800041a2:	8082                	ret

00000000800041a4 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800041a4:	1101                	addi	sp,sp,-32
    800041a6:	ec06                	sd	ra,24(sp)
    800041a8:	e822                	sd	s0,16(sp)
    800041aa:	e426                	sd	s1,8(sp)
    800041ac:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800041ae:	0001c517          	auipc	a0,0x1c
    800041b2:	b3250513          	addi	a0,a0,-1230 # 8001fce0 <ftable>
    800041b6:	a19fc0ef          	jal	80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800041ba:	0001c497          	auipc	s1,0x1c
    800041be:	b3e48493          	addi	s1,s1,-1218 # 8001fcf8 <ftable+0x18>
    800041c2:	0001d717          	auipc	a4,0x1d
    800041c6:	ad670713          	addi	a4,a4,-1322 # 80020c98 <disk>
    if(f->ref == 0){
    800041ca:	40dc                	lw	a5,4(s1)
    800041cc:	cf89                	beqz	a5,800041e6 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800041ce:	02848493          	addi	s1,s1,40
    800041d2:	fee49ce3          	bne	s1,a4,800041ca <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800041d6:	0001c517          	auipc	a0,0x1c
    800041da:	b0a50513          	addi	a0,a0,-1270 # 8001fce0 <ftable>
    800041de:	a89fc0ef          	jal	80000c66 <release>
  return 0;
    800041e2:	4481                	li	s1,0
    800041e4:	a809                	j	800041f6 <filealloc+0x52>
      f->ref = 1;
    800041e6:	4785                	li	a5,1
    800041e8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800041ea:	0001c517          	auipc	a0,0x1c
    800041ee:	af650513          	addi	a0,a0,-1290 # 8001fce0 <ftable>
    800041f2:	a75fc0ef          	jal	80000c66 <release>
}
    800041f6:	8526                	mv	a0,s1
    800041f8:	60e2                	ld	ra,24(sp)
    800041fa:	6442                	ld	s0,16(sp)
    800041fc:	64a2                	ld	s1,8(sp)
    800041fe:	6105                	addi	sp,sp,32
    80004200:	8082                	ret

0000000080004202 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004202:	1101                	addi	sp,sp,-32
    80004204:	ec06                	sd	ra,24(sp)
    80004206:	e822                	sd	s0,16(sp)
    80004208:	e426                	sd	s1,8(sp)
    8000420a:	1000                	addi	s0,sp,32
    8000420c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000420e:	0001c517          	auipc	a0,0x1c
    80004212:	ad250513          	addi	a0,a0,-1326 # 8001fce0 <ftable>
    80004216:	9b9fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    8000421a:	40dc                	lw	a5,4(s1)
    8000421c:	02f05063          	blez	a5,8000423c <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004220:	2785                	addiw	a5,a5,1
    80004222:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004224:	0001c517          	auipc	a0,0x1c
    80004228:	abc50513          	addi	a0,a0,-1348 # 8001fce0 <ftable>
    8000422c:	a3bfc0ef          	jal	80000c66 <release>
  return f;
}
    80004230:	8526                	mv	a0,s1
    80004232:	60e2                	ld	ra,24(sp)
    80004234:	6442                	ld	s0,16(sp)
    80004236:	64a2                	ld	s1,8(sp)
    80004238:	6105                	addi	sp,sp,32
    8000423a:	8082                	ret
    panic("filedup");
    8000423c:	00003517          	auipc	a0,0x3
    80004240:	34450513          	addi	a0,a0,836 # 80007580 <etext+0x580>
    80004244:	d9cfc0ef          	jal	800007e0 <panic>

0000000080004248 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004248:	7139                	addi	sp,sp,-64
    8000424a:	fc06                	sd	ra,56(sp)
    8000424c:	f822                	sd	s0,48(sp)
    8000424e:	f426                	sd	s1,40(sp)
    80004250:	0080                	addi	s0,sp,64
    80004252:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004254:	0001c517          	auipc	a0,0x1c
    80004258:	a8c50513          	addi	a0,a0,-1396 # 8001fce0 <ftable>
    8000425c:	973fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    80004260:	40dc                	lw	a5,4(s1)
    80004262:	04f05a63          	blez	a5,800042b6 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004266:	37fd                	addiw	a5,a5,-1
    80004268:	0007871b          	sext.w	a4,a5
    8000426c:	c0dc                	sw	a5,4(s1)
    8000426e:	04e04e63          	bgtz	a4,800042ca <fileclose+0x82>
    80004272:	f04a                	sd	s2,32(sp)
    80004274:	ec4e                	sd	s3,24(sp)
    80004276:	e852                	sd	s4,16(sp)
    80004278:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000427a:	0004a903          	lw	s2,0(s1)
    8000427e:	0094ca83          	lbu	s5,9(s1)
    80004282:	0104ba03          	ld	s4,16(s1)
    80004286:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000428a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000428e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004292:	0001c517          	auipc	a0,0x1c
    80004296:	a4e50513          	addi	a0,a0,-1458 # 8001fce0 <ftable>
    8000429a:	9cdfc0ef          	jal	80000c66 <release>

  if(ff.type == FD_PIPE){
    8000429e:	4785                	li	a5,1
    800042a0:	04f90063          	beq	s2,a5,800042e0 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800042a4:	3979                	addiw	s2,s2,-2
    800042a6:	4785                	li	a5,1
    800042a8:	0527f563          	bgeu	a5,s2,800042f2 <fileclose+0xaa>
    800042ac:	7902                	ld	s2,32(sp)
    800042ae:	69e2                	ld	s3,24(sp)
    800042b0:	6a42                	ld	s4,16(sp)
    800042b2:	6aa2                	ld	s5,8(sp)
    800042b4:	a00d                	j	800042d6 <fileclose+0x8e>
    800042b6:	f04a                	sd	s2,32(sp)
    800042b8:	ec4e                	sd	s3,24(sp)
    800042ba:	e852                	sd	s4,16(sp)
    800042bc:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800042be:	00003517          	auipc	a0,0x3
    800042c2:	2ca50513          	addi	a0,a0,714 # 80007588 <etext+0x588>
    800042c6:	d1afc0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    800042ca:	0001c517          	auipc	a0,0x1c
    800042ce:	a1650513          	addi	a0,a0,-1514 # 8001fce0 <ftable>
    800042d2:	995fc0ef          	jal	80000c66 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800042d6:	70e2                	ld	ra,56(sp)
    800042d8:	7442                	ld	s0,48(sp)
    800042da:	74a2                	ld	s1,40(sp)
    800042dc:	6121                	addi	sp,sp,64
    800042de:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800042e0:	85d6                	mv	a1,s5
    800042e2:	8552                	mv	a0,s4
    800042e4:	336000ef          	jal	8000461a <pipeclose>
    800042e8:	7902                	ld	s2,32(sp)
    800042ea:	69e2                	ld	s3,24(sp)
    800042ec:	6a42                	ld	s4,16(sp)
    800042ee:	6aa2                	ld	s5,8(sp)
    800042f0:	b7dd                	j	800042d6 <fileclose+0x8e>
    begin_op();
    800042f2:	b4bff0ef          	jal	80003e3c <begin_op>
    iput(ff.ip);
    800042f6:	854e                	mv	a0,s3
    800042f8:	adcff0ef          	jal	800035d4 <iput>
    end_op();
    800042fc:	babff0ef          	jal	80003ea6 <end_op>
    80004300:	7902                	ld	s2,32(sp)
    80004302:	69e2                	ld	s3,24(sp)
    80004304:	6a42                	ld	s4,16(sp)
    80004306:	6aa2                	ld	s5,8(sp)
    80004308:	b7f9                	j	800042d6 <fileclose+0x8e>

000000008000430a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000430a:	715d                	addi	sp,sp,-80
    8000430c:	e486                	sd	ra,72(sp)
    8000430e:	e0a2                	sd	s0,64(sp)
    80004310:	fc26                	sd	s1,56(sp)
    80004312:	f44e                	sd	s3,40(sp)
    80004314:	0880                	addi	s0,sp,80
    80004316:	84aa                	mv	s1,a0
    80004318:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000431a:	f2cfd0ef          	jal	80001a46 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000431e:	409c                	lw	a5,0(s1)
    80004320:	37f9                	addiw	a5,a5,-2
    80004322:	4705                	li	a4,1
    80004324:	04f76063          	bltu	a4,a5,80004364 <filestat+0x5a>
    80004328:	f84a                	sd	s2,48(sp)
    8000432a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000432c:	6c88                	ld	a0,24(s1)
    8000432e:	924ff0ef          	jal	80003452 <ilock>
    stati(f->ip, &st);
    80004332:	fb840593          	addi	a1,s0,-72
    80004336:	6c88                	ld	a0,24(s1)
    80004338:	c80ff0ef          	jal	800037b8 <stati>
    iunlock(f->ip);
    8000433c:	6c88                	ld	a0,24(s1)
    8000433e:	9c2ff0ef          	jal	80003500 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004342:	46e1                	li	a3,24
    80004344:	fb840613          	addi	a2,s0,-72
    80004348:	85ce                	mv	a1,s3
    8000434a:	05093503          	ld	a0,80(s2)
    8000434e:	aaefd0ef          	jal	800015fc <copyout>
    80004352:	41f5551b          	sraiw	a0,a0,0x1f
    80004356:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004358:	60a6                	ld	ra,72(sp)
    8000435a:	6406                	ld	s0,64(sp)
    8000435c:	74e2                	ld	s1,56(sp)
    8000435e:	79a2                	ld	s3,40(sp)
    80004360:	6161                	addi	sp,sp,80
    80004362:	8082                	ret
  return -1;
    80004364:	557d                	li	a0,-1
    80004366:	bfcd                	j	80004358 <filestat+0x4e>

0000000080004368 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004368:	7179                	addi	sp,sp,-48
    8000436a:	f406                	sd	ra,40(sp)
    8000436c:	f022                	sd	s0,32(sp)
    8000436e:	e84a                	sd	s2,16(sp)
    80004370:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004372:	00854783          	lbu	a5,8(a0)
    80004376:	cfd1                	beqz	a5,80004412 <fileread+0xaa>
    80004378:	ec26                	sd	s1,24(sp)
    8000437a:	e44e                	sd	s3,8(sp)
    8000437c:	84aa                	mv	s1,a0
    8000437e:	89ae                	mv	s3,a1
    80004380:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004382:	411c                	lw	a5,0(a0)
    80004384:	4705                	li	a4,1
    80004386:	04e78363          	beq	a5,a4,800043cc <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000438a:	470d                	li	a4,3
    8000438c:	04e78763          	beq	a5,a4,800043da <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004390:	4709                	li	a4,2
    80004392:	06e79a63          	bne	a5,a4,80004406 <fileread+0x9e>
    ilock(f->ip);
    80004396:	6d08                	ld	a0,24(a0)
    80004398:	8baff0ef          	jal	80003452 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000439c:	874a                	mv	a4,s2
    8000439e:	5094                	lw	a3,32(s1)
    800043a0:	864e                	mv	a2,s3
    800043a2:	4585                	li	a1,1
    800043a4:	6c88                	ld	a0,24(s1)
    800043a6:	c3cff0ef          	jal	800037e2 <readi>
    800043aa:	892a                	mv	s2,a0
    800043ac:	00a05563          	blez	a0,800043b6 <fileread+0x4e>
      f->off += r;
    800043b0:	509c                	lw	a5,32(s1)
    800043b2:	9fa9                	addw	a5,a5,a0
    800043b4:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800043b6:	6c88                	ld	a0,24(s1)
    800043b8:	948ff0ef          	jal	80003500 <iunlock>
    800043bc:	64e2                	ld	s1,24(sp)
    800043be:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800043c0:	854a                	mv	a0,s2
    800043c2:	70a2                	ld	ra,40(sp)
    800043c4:	7402                	ld	s0,32(sp)
    800043c6:	6942                	ld	s2,16(sp)
    800043c8:	6145                	addi	sp,sp,48
    800043ca:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800043cc:	6908                	ld	a0,16(a0)
    800043ce:	388000ef          	jal	80004756 <piperead>
    800043d2:	892a                	mv	s2,a0
    800043d4:	64e2                	ld	s1,24(sp)
    800043d6:	69a2                	ld	s3,8(sp)
    800043d8:	b7e5                	j	800043c0 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800043da:	02451783          	lh	a5,36(a0)
    800043de:	03079693          	slli	a3,a5,0x30
    800043e2:	92c1                	srli	a3,a3,0x30
    800043e4:	4725                	li	a4,9
    800043e6:	02d76863          	bltu	a4,a3,80004416 <fileread+0xae>
    800043ea:	0792                	slli	a5,a5,0x4
    800043ec:	0001c717          	auipc	a4,0x1c
    800043f0:	85470713          	addi	a4,a4,-1964 # 8001fc40 <devsw>
    800043f4:	97ba                	add	a5,a5,a4
    800043f6:	639c                	ld	a5,0(a5)
    800043f8:	c39d                	beqz	a5,8000441e <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800043fa:	4505                	li	a0,1
    800043fc:	9782                	jalr	a5
    800043fe:	892a                	mv	s2,a0
    80004400:	64e2                	ld	s1,24(sp)
    80004402:	69a2                	ld	s3,8(sp)
    80004404:	bf75                	j	800043c0 <fileread+0x58>
    panic("fileread");
    80004406:	00003517          	auipc	a0,0x3
    8000440a:	19250513          	addi	a0,a0,402 # 80007598 <etext+0x598>
    8000440e:	bd2fc0ef          	jal	800007e0 <panic>
    return -1;
    80004412:	597d                	li	s2,-1
    80004414:	b775                	j	800043c0 <fileread+0x58>
      return -1;
    80004416:	597d                	li	s2,-1
    80004418:	64e2                	ld	s1,24(sp)
    8000441a:	69a2                	ld	s3,8(sp)
    8000441c:	b755                	j	800043c0 <fileread+0x58>
    8000441e:	597d                	li	s2,-1
    80004420:	64e2                	ld	s1,24(sp)
    80004422:	69a2                	ld	s3,8(sp)
    80004424:	bf71                	j	800043c0 <fileread+0x58>

0000000080004426 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004426:	00954783          	lbu	a5,9(a0)
    8000442a:	10078b63          	beqz	a5,80004540 <filewrite+0x11a>
{
    8000442e:	715d                	addi	sp,sp,-80
    80004430:	e486                	sd	ra,72(sp)
    80004432:	e0a2                	sd	s0,64(sp)
    80004434:	f84a                	sd	s2,48(sp)
    80004436:	f052                	sd	s4,32(sp)
    80004438:	e85a                	sd	s6,16(sp)
    8000443a:	0880                	addi	s0,sp,80
    8000443c:	892a                	mv	s2,a0
    8000443e:	8b2e                	mv	s6,a1
    80004440:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004442:	411c                	lw	a5,0(a0)
    80004444:	4705                	li	a4,1
    80004446:	02e78763          	beq	a5,a4,80004474 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000444a:	470d                	li	a4,3
    8000444c:	02e78863          	beq	a5,a4,8000447c <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004450:	4709                	li	a4,2
    80004452:	0ce79c63          	bne	a5,a4,8000452a <filewrite+0x104>
    80004456:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004458:	0ac05863          	blez	a2,80004508 <filewrite+0xe2>
    8000445c:	fc26                	sd	s1,56(sp)
    8000445e:	ec56                	sd	s5,24(sp)
    80004460:	e45e                	sd	s7,8(sp)
    80004462:	e062                	sd	s8,0(sp)
    int i = 0;
    80004464:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004466:	6b85                	lui	s7,0x1
    80004468:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000446c:	6c05                	lui	s8,0x1
    8000446e:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004472:	a8b5                	j	800044ee <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004474:	6908                	ld	a0,16(a0)
    80004476:	1fc000ef          	jal	80004672 <pipewrite>
    8000447a:	a04d                	j	8000451c <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000447c:	02451783          	lh	a5,36(a0)
    80004480:	03079693          	slli	a3,a5,0x30
    80004484:	92c1                	srli	a3,a3,0x30
    80004486:	4725                	li	a4,9
    80004488:	0ad76e63          	bltu	a4,a3,80004544 <filewrite+0x11e>
    8000448c:	0792                	slli	a5,a5,0x4
    8000448e:	0001b717          	auipc	a4,0x1b
    80004492:	7b270713          	addi	a4,a4,1970 # 8001fc40 <devsw>
    80004496:	97ba                	add	a5,a5,a4
    80004498:	679c                	ld	a5,8(a5)
    8000449a:	c7dd                	beqz	a5,80004548 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000449c:	4505                	li	a0,1
    8000449e:	9782                	jalr	a5
    800044a0:	a8b5                	j	8000451c <filewrite+0xf6>
      if(n1 > max)
    800044a2:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800044a6:	997ff0ef          	jal	80003e3c <begin_op>
      ilock(f->ip);
    800044aa:	01893503          	ld	a0,24(s2)
    800044ae:	fa5fe0ef          	jal	80003452 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800044b2:	8756                	mv	a4,s5
    800044b4:	02092683          	lw	a3,32(s2)
    800044b8:	01698633          	add	a2,s3,s6
    800044bc:	4585                	li	a1,1
    800044be:	01893503          	ld	a0,24(s2)
    800044c2:	c1cff0ef          	jal	800038de <writei>
    800044c6:	84aa                	mv	s1,a0
    800044c8:	00a05763          	blez	a0,800044d6 <filewrite+0xb0>
        f->off += r;
    800044cc:	02092783          	lw	a5,32(s2)
    800044d0:	9fa9                	addw	a5,a5,a0
    800044d2:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800044d6:	01893503          	ld	a0,24(s2)
    800044da:	826ff0ef          	jal	80003500 <iunlock>
      end_op();
    800044de:	9c9ff0ef          	jal	80003ea6 <end_op>

      if(r != n1){
    800044e2:	029a9563          	bne	s5,s1,8000450c <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    800044e6:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800044ea:	0149da63          	bge	s3,s4,800044fe <filewrite+0xd8>
      int n1 = n - i;
    800044ee:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800044f2:	0004879b          	sext.w	a5,s1
    800044f6:	fafbd6e3          	bge	s7,a5,800044a2 <filewrite+0x7c>
    800044fa:	84e2                	mv	s1,s8
    800044fc:	b75d                	j	800044a2 <filewrite+0x7c>
    800044fe:	74e2                	ld	s1,56(sp)
    80004500:	6ae2                	ld	s5,24(sp)
    80004502:	6ba2                	ld	s7,8(sp)
    80004504:	6c02                	ld	s8,0(sp)
    80004506:	a039                	j	80004514 <filewrite+0xee>
    int i = 0;
    80004508:	4981                	li	s3,0
    8000450a:	a029                	j	80004514 <filewrite+0xee>
    8000450c:	74e2                	ld	s1,56(sp)
    8000450e:	6ae2                	ld	s5,24(sp)
    80004510:	6ba2                	ld	s7,8(sp)
    80004512:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004514:	033a1c63          	bne	s4,s3,8000454c <filewrite+0x126>
    80004518:	8552                	mv	a0,s4
    8000451a:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000451c:	60a6                	ld	ra,72(sp)
    8000451e:	6406                	ld	s0,64(sp)
    80004520:	7942                	ld	s2,48(sp)
    80004522:	7a02                	ld	s4,32(sp)
    80004524:	6b42                	ld	s6,16(sp)
    80004526:	6161                	addi	sp,sp,80
    80004528:	8082                	ret
    8000452a:	fc26                	sd	s1,56(sp)
    8000452c:	f44e                	sd	s3,40(sp)
    8000452e:	ec56                	sd	s5,24(sp)
    80004530:	e45e                	sd	s7,8(sp)
    80004532:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004534:	00003517          	auipc	a0,0x3
    80004538:	07450513          	addi	a0,a0,116 # 800075a8 <etext+0x5a8>
    8000453c:	aa4fc0ef          	jal	800007e0 <panic>
    return -1;
    80004540:	557d                	li	a0,-1
}
    80004542:	8082                	ret
      return -1;
    80004544:	557d                	li	a0,-1
    80004546:	bfd9                	j	8000451c <filewrite+0xf6>
    80004548:	557d                	li	a0,-1
    8000454a:	bfc9                	j	8000451c <filewrite+0xf6>
    ret = (i == n ? n : -1);
    8000454c:	557d                	li	a0,-1
    8000454e:	79a2                	ld	s3,40(sp)
    80004550:	b7f1                	j	8000451c <filewrite+0xf6>

0000000080004552 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004552:	7179                	addi	sp,sp,-48
    80004554:	f406                	sd	ra,40(sp)
    80004556:	f022                	sd	s0,32(sp)
    80004558:	ec26                	sd	s1,24(sp)
    8000455a:	e052                	sd	s4,0(sp)
    8000455c:	1800                	addi	s0,sp,48
    8000455e:	84aa                	mv	s1,a0
    80004560:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004562:	0005b023          	sd	zero,0(a1)
    80004566:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000456a:	c3bff0ef          	jal	800041a4 <filealloc>
    8000456e:	e088                	sd	a0,0(s1)
    80004570:	c549                	beqz	a0,800045fa <pipealloc+0xa8>
    80004572:	c33ff0ef          	jal	800041a4 <filealloc>
    80004576:	00aa3023          	sd	a0,0(s4)
    8000457a:	cd25                	beqz	a0,800045f2 <pipealloc+0xa0>
    8000457c:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000457e:	d80fc0ef          	jal	80000afe <kalloc>
    80004582:	892a                	mv	s2,a0
    80004584:	c12d                	beqz	a0,800045e6 <pipealloc+0x94>
    80004586:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004588:	4985                	li	s3,1
    8000458a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000458e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004592:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004596:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000459a:	00003597          	auipc	a1,0x3
    8000459e:	01e58593          	addi	a1,a1,30 # 800075b8 <etext+0x5b8>
    800045a2:	dacfc0ef          	jal	80000b4e <initlock>
  (*f0)->type = FD_PIPE;
    800045a6:	609c                	ld	a5,0(s1)
    800045a8:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800045ac:	609c                	ld	a5,0(s1)
    800045ae:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800045b2:	609c                	ld	a5,0(s1)
    800045b4:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800045b8:	609c                	ld	a5,0(s1)
    800045ba:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800045be:	000a3783          	ld	a5,0(s4)
    800045c2:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800045c6:	000a3783          	ld	a5,0(s4)
    800045ca:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800045ce:	000a3783          	ld	a5,0(s4)
    800045d2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800045d6:	000a3783          	ld	a5,0(s4)
    800045da:	0127b823          	sd	s2,16(a5)
  return 0;
    800045de:	4501                	li	a0,0
    800045e0:	6942                	ld	s2,16(sp)
    800045e2:	69a2                	ld	s3,8(sp)
    800045e4:	a01d                	j	8000460a <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800045e6:	6088                	ld	a0,0(s1)
    800045e8:	c119                	beqz	a0,800045ee <pipealloc+0x9c>
    800045ea:	6942                	ld	s2,16(sp)
    800045ec:	a029                	j	800045f6 <pipealloc+0xa4>
    800045ee:	6942                	ld	s2,16(sp)
    800045f0:	a029                	j	800045fa <pipealloc+0xa8>
    800045f2:	6088                	ld	a0,0(s1)
    800045f4:	c10d                	beqz	a0,80004616 <pipealloc+0xc4>
    fileclose(*f0);
    800045f6:	c53ff0ef          	jal	80004248 <fileclose>
  if(*f1)
    800045fa:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800045fe:	557d                	li	a0,-1
  if(*f1)
    80004600:	c789                	beqz	a5,8000460a <pipealloc+0xb8>
    fileclose(*f1);
    80004602:	853e                	mv	a0,a5
    80004604:	c45ff0ef          	jal	80004248 <fileclose>
  return -1;
    80004608:	557d                	li	a0,-1
}
    8000460a:	70a2                	ld	ra,40(sp)
    8000460c:	7402                	ld	s0,32(sp)
    8000460e:	64e2                	ld	s1,24(sp)
    80004610:	6a02                	ld	s4,0(sp)
    80004612:	6145                	addi	sp,sp,48
    80004614:	8082                	ret
  return -1;
    80004616:	557d                	li	a0,-1
    80004618:	bfcd                	j	8000460a <pipealloc+0xb8>

000000008000461a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000461a:	1101                	addi	sp,sp,-32
    8000461c:	ec06                	sd	ra,24(sp)
    8000461e:	e822                	sd	s0,16(sp)
    80004620:	e426                	sd	s1,8(sp)
    80004622:	e04a                	sd	s2,0(sp)
    80004624:	1000                	addi	s0,sp,32
    80004626:	84aa                	mv	s1,a0
    80004628:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000462a:	da4fc0ef          	jal	80000bce <acquire>
  if(writable){
    8000462e:	02090763          	beqz	s2,8000465c <pipeclose+0x42>
    pi->writeopen = 0;
    80004632:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004636:	21848513          	addi	a0,s1,536
    8000463a:	ac7fd0ef          	jal	80002100 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000463e:	2204b783          	ld	a5,544(s1)
    80004642:	e785                	bnez	a5,8000466a <pipeclose+0x50>
    release(&pi->lock);
    80004644:	8526                	mv	a0,s1
    80004646:	e20fc0ef          	jal	80000c66 <release>
    kfree((char*)pi);
    8000464a:	8526                	mv	a0,s1
    8000464c:	bd0fc0ef          	jal	80000a1c <kfree>
  } else
    release(&pi->lock);
}
    80004650:	60e2                	ld	ra,24(sp)
    80004652:	6442                	ld	s0,16(sp)
    80004654:	64a2                	ld	s1,8(sp)
    80004656:	6902                	ld	s2,0(sp)
    80004658:	6105                	addi	sp,sp,32
    8000465a:	8082                	ret
    pi->readopen = 0;
    8000465c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004660:	21c48513          	addi	a0,s1,540
    80004664:	a9dfd0ef          	jal	80002100 <wakeup>
    80004668:	bfd9                	j	8000463e <pipeclose+0x24>
    release(&pi->lock);
    8000466a:	8526                	mv	a0,s1
    8000466c:	dfafc0ef          	jal	80000c66 <release>
}
    80004670:	b7c5                	j	80004650 <pipeclose+0x36>

0000000080004672 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004672:	711d                	addi	sp,sp,-96
    80004674:	ec86                	sd	ra,88(sp)
    80004676:	e8a2                	sd	s0,80(sp)
    80004678:	e4a6                	sd	s1,72(sp)
    8000467a:	e0ca                	sd	s2,64(sp)
    8000467c:	fc4e                	sd	s3,56(sp)
    8000467e:	f852                	sd	s4,48(sp)
    80004680:	f456                	sd	s5,40(sp)
    80004682:	1080                	addi	s0,sp,96
    80004684:	84aa                	mv	s1,a0
    80004686:	8aae                	mv	s5,a1
    80004688:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000468a:	bbcfd0ef          	jal	80001a46 <myproc>
    8000468e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004690:	8526                	mv	a0,s1
    80004692:	d3cfc0ef          	jal	80000bce <acquire>
  while(i < n){
    80004696:	0b405a63          	blez	s4,8000474a <pipewrite+0xd8>
    8000469a:	f05a                	sd	s6,32(sp)
    8000469c:	ec5e                	sd	s7,24(sp)
    8000469e:	e862                	sd	s8,16(sp)
  int i = 0;
    800046a0:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800046a2:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800046a4:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800046a8:	21c48b93          	addi	s7,s1,540
    800046ac:	a81d                	j	800046e2 <pipewrite+0x70>
      release(&pi->lock);
    800046ae:	8526                	mv	a0,s1
    800046b0:	db6fc0ef          	jal	80000c66 <release>
      return -1;
    800046b4:	597d                	li	s2,-1
    800046b6:	7b02                	ld	s6,32(sp)
    800046b8:	6be2                	ld	s7,24(sp)
    800046ba:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800046bc:	854a                	mv	a0,s2
    800046be:	60e6                	ld	ra,88(sp)
    800046c0:	6446                	ld	s0,80(sp)
    800046c2:	64a6                	ld	s1,72(sp)
    800046c4:	6906                	ld	s2,64(sp)
    800046c6:	79e2                	ld	s3,56(sp)
    800046c8:	7a42                	ld	s4,48(sp)
    800046ca:	7aa2                	ld	s5,40(sp)
    800046cc:	6125                	addi	sp,sp,96
    800046ce:	8082                	ret
      wakeup(&pi->nread);
    800046d0:	8562                	mv	a0,s8
    800046d2:	a2ffd0ef          	jal	80002100 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800046d6:	85a6                	mv	a1,s1
    800046d8:	855e                	mv	a0,s7
    800046da:	9dbfd0ef          	jal	800020b4 <sleep>
  while(i < n){
    800046de:	05495b63          	bge	s2,s4,80004734 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    800046e2:	2204a783          	lw	a5,544(s1)
    800046e6:	d7e1                	beqz	a5,800046ae <pipewrite+0x3c>
    800046e8:	854e                	mv	a0,s3
    800046ea:	c03fd0ef          	jal	800022ec <killed>
    800046ee:	f161                	bnez	a0,800046ae <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800046f0:	2184a783          	lw	a5,536(s1)
    800046f4:	21c4a703          	lw	a4,540(s1)
    800046f8:	2007879b          	addiw	a5,a5,512
    800046fc:	fcf70ae3          	beq	a4,a5,800046d0 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004700:	4685                	li	a3,1
    80004702:	01590633          	add	a2,s2,s5
    80004706:	faf40593          	addi	a1,s0,-81
    8000470a:	0509b503          	ld	a0,80(s3)
    8000470e:	fd3fc0ef          	jal	800016e0 <copyin>
    80004712:	03650e63          	beq	a0,s6,8000474e <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004716:	21c4a783          	lw	a5,540(s1)
    8000471a:	0017871b          	addiw	a4,a5,1
    8000471e:	20e4ae23          	sw	a4,540(s1)
    80004722:	1ff7f793          	andi	a5,a5,511
    80004726:	97a6                	add	a5,a5,s1
    80004728:	faf44703          	lbu	a4,-81(s0)
    8000472c:	00e78c23          	sb	a4,24(a5)
      i++;
    80004730:	2905                	addiw	s2,s2,1
    80004732:	b775                	j	800046de <pipewrite+0x6c>
    80004734:	7b02                	ld	s6,32(sp)
    80004736:	6be2                	ld	s7,24(sp)
    80004738:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    8000473a:	21848513          	addi	a0,s1,536
    8000473e:	9c3fd0ef          	jal	80002100 <wakeup>
  release(&pi->lock);
    80004742:	8526                	mv	a0,s1
    80004744:	d22fc0ef          	jal	80000c66 <release>
  return i;
    80004748:	bf95                	j	800046bc <pipewrite+0x4a>
  int i = 0;
    8000474a:	4901                	li	s2,0
    8000474c:	b7fd                	j	8000473a <pipewrite+0xc8>
    8000474e:	7b02                	ld	s6,32(sp)
    80004750:	6be2                	ld	s7,24(sp)
    80004752:	6c42                	ld	s8,16(sp)
    80004754:	b7dd                	j	8000473a <pipewrite+0xc8>

0000000080004756 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004756:	715d                	addi	sp,sp,-80
    80004758:	e486                	sd	ra,72(sp)
    8000475a:	e0a2                	sd	s0,64(sp)
    8000475c:	fc26                	sd	s1,56(sp)
    8000475e:	f84a                	sd	s2,48(sp)
    80004760:	f44e                	sd	s3,40(sp)
    80004762:	f052                	sd	s4,32(sp)
    80004764:	ec56                	sd	s5,24(sp)
    80004766:	0880                	addi	s0,sp,80
    80004768:	84aa                	mv	s1,a0
    8000476a:	892e                	mv	s2,a1
    8000476c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000476e:	ad8fd0ef          	jal	80001a46 <myproc>
    80004772:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004774:	8526                	mv	a0,s1
    80004776:	c58fc0ef          	jal	80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000477a:	2184a703          	lw	a4,536(s1)
    8000477e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004782:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004786:	02f71563          	bne	a4,a5,800047b0 <piperead+0x5a>
    8000478a:	2244a783          	lw	a5,548(s1)
    8000478e:	cb85                	beqz	a5,800047be <piperead+0x68>
    if(killed(pr)){
    80004790:	8552                	mv	a0,s4
    80004792:	b5bfd0ef          	jal	800022ec <killed>
    80004796:	ed19                	bnez	a0,800047b4 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004798:	85a6                	mv	a1,s1
    8000479a:	854e                	mv	a0,s3
    8000479c:	919fd0ef          	jal	800020b4 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047a0:	2184a703          	lw	a4,536(s1)
    800047a4:	21c4a783          	lw	a5,540(s1)
    800047a8:	fef701e3          	beq	a4,a5,8000478a <piperead+0x34>
    800047ac:	e85a                	sd	s6,16(sp)
    800047ae:	a809                	j	800047c0 <piperead+0x6a>
    800047b0:	e85a                	sd	s6,16(sp)
    800047b2:	a039                	j	800047c0 <piperead+0x6a>
      release(&pi->lock);
    800047b4:	8526                	mv	a0,s1
    800047b6:	cb0fc0ef          	jal	80000c66 <release>
      return -1;
    800047ba:	59fd                	li	s3,-1
    800047bc:	a8b9                	j	8000481a <piperead+0xc4>
    800047be:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800047c0:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800047c2:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800047c4:	05505363          	blez	s5,8000480a <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    800047c8:	2184a783          	lw	a5,536(s1)
    800047cc:	21c4a703          	lw	a4,540(s1)
    800047d0:	02f70d63          	beq	a4,a5,8000480a <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    800047d4:	1ff7f793          	andi	a5,a5,511
    800047d8:	97a6                	add	a5,a5,s1
    800047da:	0187c783          	lbu	a5,24(a5)
    800047de:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800047e2:	4685                	li	a3,1
    800047e4:	fbf40613          	addi	a2,s0,-65
    800047e8:	85ca                	mv	a1,s2
    800047ea:	050a3503          	ld	a0,80(s4)
    800047ee:	e0ffc0ef          	jal	800015fc <copyout>
    800047f2:	03650e63          	beq	a0,s6,8000482e <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800047f6:	2184a783          	lw	a5,536(s1)
    800047fa:	2785                	addiw	a5,a5,1
    800047fc:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004800:	2985                	addiw	s3,s3,1
    80004802:	0905                	addi	s2,s2,1
    80004804:	fd3a92e3          	bne	s5,s3,800047c8 <piperead+0x72>
    80004808:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000480a:	21c48513          	addi	a0,s1,540
    8000480e:	8f3fd0ef          	jal	80002100 <wakeup>
  release(&pi->lock);
    80004812:	8526                	mv	a0,s1
    80004814:	c52fc0ef          	jal	80000c66 <release>
    80004818:	6b42                	ld	s6,16(sp)
  return i;
}
    8000481a:	854e                	mv	a0,s3
    8000481c:	60a6                	ld	ra,72(sp)
    8000481e:	6406                	ld	s0,64(sp)
    80004820:	74e2                	ld	s1,56(sp)
    80004822:	7942                	ld	s2,48(sp)
    80004824:	79a2                	ld	s3,40(sp)
    80004826:	7a02                	ld	s4,32(sp)
    80004828:	6ae2                	ld	s5,24(sp)
    8000482a:	6161                	addi	sp,sp,80
    8000482c:	8082                	ret
      if(i == 0)
    8000482e:	fc099ee3          	bnez	s3,8000480a <piperead+0xb4>
        i = -1;
    80004832:	89aa                	mv	s3,a0
    80004834:	bfd9                	j	8000480a <piperead+0xb4>

0000000080004836 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004836:	1141                	addi	sp,sp,-16
    80004838:	e422                	sd	s0,8(sp)
    8000483a:	0800                	addi	s0,sp,16
    8000483c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000483e:	8905                	andi	a0,a0,1
    80004840:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004842:	8b89                	andi	a5,a5,2
    80004844:	c399                	beqz	a5,8000484a <flags2perm+0x14>
      perm |= PTE_W;
    80004846:	00456513          	ori	a0,a0,4
    return perm;
}
    8000484a:	6422                	ld	s0,8(sp)
    8000484c:	0141                	addi	sp,sp,16
    8000484e:	8082                	ret

0000000080004850 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004850:	df010113          	addi	sp,sp,-528
    80004854:	20113423          	sd	ra,520(sp)
    80004858:	20813023          	sd	s0,512(sp)
    8000485c:	ffa6                	sd	s1,504(sp)
    8000485e:	fbca                	sd	s2,496(sp)
    80004860:	0c00                	addi	s0,sp,528
    80004862:	892a                	mv	s2,a0
    80004864:	dea43c23          	sd	a0,-520(s0)
    80004868:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000486c:	9dafd0ef          	jal	80001a46 <myproc>
    80004870:	84aa                	mv	s1,a0

  begin_op();
    80004872:	dcaff0ef          	jal	80003e3c <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004876:	854a                	mv	a0,s2
    80004878:	bf0ff0ef          	jal	80003c68 <namei>
    8000487c:	c931                	beqz	a0,800048d0 <kexec+0x80>
    8000487e:	f3d2                	sd	s4,480(sp)
    80004880:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004882:	bd1fe0ef          	jal	80003452 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004886:	04000713          	li	a4,64
    8000488a:	4681                	li	a3,0
    8000488c:	e5040613          	addi	a2,s0,-432
    80004890:	4581                	li	a1,0
    80004892:	8552                	mv	a0,s4
    80004894:	f4ffe0ef          	jal	800037e2 <readi>
    80004898:	04000793          	li	a5,64
    8000489c:	00f51a63          	bne	a0,a5,800048b0 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800048a0:	e5042703          	lw	a4,-432(s0)
    800048a4:	464c47b7          	lui	a5,0x464c4
    800048a8:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800048ac:	02f70663          	beq	a4,a5,800048d8 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800048b0:	8552                	mv	a0,s4
    800048b2:	dabfe0ef          	jal	8000365c <iunlockput>
    end_op();
    800048b6:	df0ff0ef          	jal	80003ea6 <end_op>
  }
  return -1;
    800048ba:	557d                	li	a0,-1
    800048bc:	7a1e                	ld	s4,480(sp)
}
    800048be:	20813083          	ld	ra,520(sp)
    800048c2:	20013403          	ld	s0,512(sp)
    800048c6:	74fe                	ld	s1,504(sp)
    800048c8:	795e                	ld	s2,496(sp)
    800048ca:	21010113          	addi	sp,sp,528
    800048ce:	8082                	ret
    end_op();
    800048d0:	dd6ff0ef          	jal	80003ea6 <end_op>
    return -1;
    800048d4:	557d                	li	a0,-1
    800048d6:	b7e5                	j	800048be <kexec+0x6e>
    800048d8:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800048da:	8526                	mv	a0,s1
    800048dc:	a70fd0ef          	jal	80001b4c <proc_pagetable>
    800048e0:	8b2a                	mv	s6,a0
    800048e2:	2c050b63          	beqz	a0,80004bb8 <kexec+0x368>
    800048e6:	f7ce                	sd	s3,488(sp)
    800048e8:	efd6                	sd	s5,472(sp)
    800048ea:	e7de                	sd	s7,456(sp)
    800048ec:	e3e2                	sd	s8,448(sp)
    800048ee:	ff66                	sd	s9,440(sp)
    800048f0:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800048f2:	e7042d03          	lw	s10,-400(s0)
    800048f6:	e8845783          	lhu	a5,-376(s0)
    800048fa:	12078963          	beqz	a5,80004a2c <kexec+0x1dc>
    800048fe:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004900:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004902:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004904:	6c85                	lui	s9,0x1
    80004906:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000490a:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000490e:	6a85                	lui	s5,0x1
    80004910:	a085                	j	80004970 <kexec+0x120>
      panic("loadseg: address should exist");
    80004912:	00003517          	auipc	a0,0x3
    80004916:	cae50513          	addi	a0,a0,-850 # 800075c0 <etext+0x5c0>
    8000491a:	ec7fb0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    8000491e:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004920:	8726                	mv	a4,s1
    80004922:	012c06bb          	addw	a3,s8,s2
    80004926:	4581                	li	a1,0
    80004928:	8552                	mv	a0,s4
    8000492a:	eb9fe0ef          	jal	800037e2 <readi>
    8000492e:	2501                	sext.w	a0,a0
    80004930:	24a49a63          	bne	s1,a0,80004b84 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004934:	012a893b          	addw	s2,s5,s2
    80004938:	03397363          	bgeu	s2,s3,8000495e <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    8000493c:	02091593          	slli	a1,s2,0x20
    80004940:	9181                	srli	a1,a1,0x20
    80004942:	95de                	add	a1,a1,s7
    80004944:	855a                	mv	a0,s6
    80004946:	e72fc0ef          	jal	80000fb8 <walkaddr>
    8000494a:	862a                	mv	a2,a0
    if(pa == 0)
    8000494c:	d179                	beqz	a0,80004912 <kexec+0xc2>
    if(sz - i < PGSIZE)
    8000494e:	412984bb          	subw	s1,s3,s2
    80004952:	0004879b          	sext.w	a5,s1
    80004956:	fcfcf4e3          	bgeu	s9,a5,8000491e <kexec+0xce>
    8000495a:	84d6                	mv	s1,s5
    8000495c:	b7c9                	j	8000491e <kexec+0xce>
    sz = sz1;
    8000495e:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004962:	2d85                	addiw	s11,s11,1
    80004964:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004968:	e8845783          	lhu	a5,-376(s0)
    8000496c:	08fdd063          	bge	s11,a5,800049ec <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004970:	2d01                	sext.w	s10,s10
    80004972:	03800713          	li	a4,56
    80004976:	86ea                	mv	a3,s10
    80004978:	e1840613          	addi	a2,s0,-488
    8000497c:	4581                	li	a1,0
    8000497e:	8552                	mv	a0,s4
    80004980:	e63fe0ef          	jal	800037e2 <readi>
    80004984:	03800793          	li	a5,56
    80004988:	1cf51663          	bne	a0,a5,80004b54 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    8000498c:	e1842783          	lw	a5,-488(s0)
    80004990:	4705                	li	a4,1
    80004992:	fce798e3          	bne	a5,a4,80004962 <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80004996:	e4043483          	ld	s1,-448(s0)
    8000499a:	e3843783          	ld	a5,-456(s0)
    8000499e:	1af4ef63          	bltu	s1,a5,80004b5c <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800049a2:	e2843783          	ld	a5,-472(s0)
    800049a6:	94be                	add	s1,s1,a5
    800049a8:	1af4ee63          	bltu	s1,a5,80004b64 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    800049ac:	df043703          	ld	a4,-528(s0)
    800049b0:	8ff9                	and	a5,a5,a4
    800049b2:	1a079d63          	bnez	a5,80004b6c <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800049b6:	e1c42503          	lw	a0,-484(s0)
    800049ba:	e7dff0ef          	jal	80004836 <flags2perm>
    800049be:	86aa                	mv	a3,a0
    800049c0:	8626                	mv	a2,s1
    800049c2:	85ca                	mv	a1,s2
    800049c4:	855a                	mv	a0,s6
    800049c6:	8ddfc0ef          	jal	800012a2 <uvmalloc>
    800049ca:	e0a43423          	sd	a0,-504(s0)
    800049ce:	1a050363          	beqz	a0,80004b74 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800049d2:	e2843b83          	ld	s7,-472(s0)
    800049d6:	e2042c03          	lw	s8,-480(s0)
    800049da:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800049de:	00098463          	beqz	s3,800049e6 <kexec+0x196>
    800049e2:	4901                	li	s2,0
    800049e4:	bfa1                	j	8000493c <kexec+0xec>
    sz = sz1;
    800049e6:	e0843903          	ld	s2,-504(s0)
    800049ea:	bfa5                	j	80004962 <kexec+0x112>
    800049ec:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800049ee:	8552                	mv	a0,s4
    800049f0:	c6dfe0ef          	jal	8000365c <iunlockput>
  end_op();
    800049f4:	cb2ff0ef          	jal	80003ea6 <end_op>
  p = myproc();
    800049f8:	84efd0ef          	jal	80001a46 <myproc>
    800049fc:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800049fe:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004a02:	6985                	lui	s3,0x1
    80004a04:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004a06:	99ca                	add	s3,s3,s2
    80004a08:	77fd                	lui	a5,0xfffff
    80004a0a:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004a0e:	4691                	li	a3,4
    80004a10:	6609                	lui	a2,0x2
    80004a12:	964e                	add	a2,a2,s3
    80004a14:	85ce                	mv	a1,s3
    80004a16:	855a                	mv	a0,s6
    80004a18:	88bfc0ef          	jal	800012a2 <uvmalloc>
    80004a1c:	892a                	mv	s2,a0
    80004a1e:	e0a43423          	sd	a0,-504(s0)
    80004a22:	e519                	bnez	a0,80004a30 <kexec+0x1e0>
  if(pagetable)
    80004a24:	e1343423          	sd	s3,-504(s0)
    80004a28:	4a01                	li	s4,0
    80004a2a:	aab1                	j	80004b86 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a2c:	4901                	li	s2,0
    80004a2e:	b7c1                	j	800049ee <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004a30:	75f9                	lui	a1,0xffffe
    80004a32:	95aa                	add	a1,a1,a0
    80004a34:	855a                	mv	a0,s6
    80004a36:	a43fc0ef          	jal	80001478 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004a3a:	7bfd                	lui	s7,0xfffff
    80004a3c:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004a3e:	e0043783          	ld	a5,-512(s0)
    80004a42:	6388                	ld	a0,0(a5)
    80004a44:	cd39                	beqz	a0,80004aa2 <kexec+0x252>
    80004a46:	e9040993          	addi	s3,s0,-368
    80004a4a:	f9040c13          	addi	s8,s0,-112
    80004a4e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004a50:	bc2fc0ef          	jal	80000e12 <strlen>
    80004a54:	0015079b          	addiw	a5,a0,1
    80004a58:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004a5c:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004a60:	11796e63          	bltu	s2,s7,80004b7c <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004a64:	e0043d03          	ld	s10,-512(s0)
    80004a68:	000d3a03          	ld	s4,0(s10)
    80004a6c:	8552                	mv	a0,s4
    80004a6e:	ba4fc0ef          	jal	80000e12 <strlen>
    80004a72:	0015069b          	addiw	a3,a0,1
    80004a76:	8652                	mv	a2,s4
    80004a78:	85ca                	mv	a1,s2
    80004a7a:	855a                	mv	a0,s6
    80004a7c:	b81fc0ef          	jal	800015fc <copyout>
    80004a80:	10054063          	bltz	a0,80004b80 <kexec+0x330>
    ustack[argc] = sp;
    80004a84:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004a88:	0485                	addi	s1,s1,1
    80004a8a:	008d0793          	addi	a5,s10,8
    80004a8e:	e0f43023          	sd	a5,-512(s0)
    80004a92:	008d3503          	ld	a0,8(s10)
    80004a96:	c909                	beqz	a0,80004aa8 <kexec+0x258>
    if(argc >= MAXARG)
    80004a98:	09a1                	addi	s3,s3,8
    80004a9a:	fb899be3          	bne	s3,s8,80004a50 <kexec+0x200>
  ip = 0;
    80004a9e:	4a01                	li	s4,0
    80004aa0:	a0dd                	j	80004b86 <kexec+0x336>
  sp = sz;
    80004aa2:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004aa6:	4481                	li	s1,0
  ustack[argc] = 0;
    80004aa8:	00349793          	slli	a5,s1,0x3
    80004aac:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffde1b8>
    80004ab0:	97a2                	add	a5,a5,s0
    80004ab2:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004ab6:	00148693          	addi	a3,s1,1
    80004aba:	068e                	slli	a3,a3,0x3
    80004abc:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004ac0:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004ac4:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004ac8:	f5796ee3          	bltu	s2,s7,80004a24 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004acc:	e9040613          	addi	a2,s0,-368
    80004ad0:	85ca                	mv	a1,s2
    80004ad2:	855a                	mv	a0,s6
    80004ad4:	b29fc0ef          	jal	800015fc <copyout>
    80004ad8:	0e054263          	bltz	a0,80004bbc <kexec+0x36c>
  p->trapframe->a1 = sp;
    80004adc:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004ae0:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004ae4:	df843783          	ld	a5,-520(s0)
    80004ae8:	0007c703          	lbu	a4,0(a5)
    80004aec:	cf11                	beqz	a4,80004b08 <kexec+0x2b8>
    80004aee:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004af0:	02f00693          	li	a3,47
    80004af4:	a039                	j	80004b02 <kexec+0x2b2>
      last = s+1;
    80004af6:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004afa:	0785                	addi	a5,a5,1
    80004afc:	fff7c703          	lbu	a4,-1(a5)
    80004b00:	c701                	beqz	a4,80004b08 <kexec+0x2b8>
    if(*s == '/')
    80004b02:	fed71ce3          	bne	a4,a3,80004afa <kexec+0x2aa>
    80004b06:	bfc5                	j	80004af6 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004b08:	4641                	li	a2,16
    80004b0a:	df843583          	ld	a1,-520(s0)
    80004b0e:	158a8513          	addi	a0,s5,344
    80004b12:	acefc0ef          	jal	80000de0 <safestrcpy>
  oldpagetable = p->pagetable;
    80004b16:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004b1a:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004b1e:	e0843783          	ld	a5,-504(s0)
    80004b22:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004b26:	058ab783          	ld	a5,88(s5)
    80004b2a:	e6843703          	ld	a4,-408(s0)
    80004b2e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004b30:	058ab783          	ld	a5,88(s5)
    80004b34:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004b38:	85e6                	mv	a1,s9
    80004b3a:	896fd0ef          	jal	80001bd0 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004b3e:	0004851b          	sext.w	a0,s1
    80004b42:	79be                	ld	s3,488(sp)
    80004b44:	7a1e                	ld	s4,480(sp)
    80004b46:	6afe                	ld	s5,472(sp)
    80004b48:	6b5e                	ld	s6,464(sp)
    80004b4a:	6bbe                	ld	s7,456(sp)
    80004b4c:	6c1e                	ld	s8,448(sp)
    80004b4e:	7cfa                	ld	s9,440(sp)
    80004b50:	7d5a                	ld	s10,432(sp)
    80004b52:	b3b5                	j	800048be <kexec+0x6e>
    80004b54:	e1243423          	sd	s2,-504(s0)
    80004b58:	7dba                	ld	s11,424(sp)
    80004b5a:	a035                	j	80004b86 <kexec+0x336>
    80004b5c:	e1243423          	sd	s2,-504(s0)
    80004b60:	7dba                	ld	s11,424(sp)
    80004b62:	a015                	j	80004b86 <kexec+0x336>
    80004b64:	e1243423          	sd	s2,-504(s0)
    80004b68:	7dba                	ld	s11,424(sp)
    80004b6a:	a831                	j	80004b86 <kexec+0x336>
    80004b6c:	e1243423          	sd	s2,-504(s0)
    80004b70:	7dba                	ld	s11,424(sp)
    80004b72:	a811                	j	80004b86 <kexec+0x336>
    80004b74:	e1243423          	sd	s2,-504(s0)
    80004b78:	7dba                	ld	s11,424(sp)
    80004b7a:	a031                	j	80004b86 <kexec+0x336>
  ip = 0;
    80004b7c:	4a01                	li	s4,0
    80004b7e:	a021                	j	80004b86 <kexec+0x336>
    80004b80:	4a01                	li	s4,0
  if(pagetable)
    80004b82:	a011                	j	80004b86 <kexec+0x336>
    80004b84:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004b86:	e0843583          	ld	a1,-504(s0)
    80004b8a:	855a                	mv	a0,s6
    80004b8c:	844fd0ef          	jal	80001bd0 <proc_freepagetable>
  return -1;
    80004b90:	557d                	li	a0,-1
  if(ip){
    80004b92:	000a1b63          	bnez	s4,80004ba8 <kexec+0x358>
    80004b96:	79be                	ld	s3,488(sp)
    80004b98:	7a1e                	ld	s4,480(sp)
    80004b9a:	6afe                	ld	s5,472(sp)
    80004b9c:	6b5e                	ld	s6,464(sp)
    80004b9e:	6bbe                	ld	s7,456(sp)
    80004ba0:	6c1e                	ld	s8,448(sp)
    80004ba2:	7cfa                	ld	s9,440(sp)
    80004ba4:	7d5a                	ld	s10,432(sp)
    80004ba6:	bb21                	j	800048be <kexec+0x6e>
    80004ba8:	79be                	ld	s3,488(sp)
    80004baa:	6afe                	ld	s5,472(sp)
    80004bac:	6b5e                	ld	s6,464(sp)
    80004bae:	6bbe                	ld	s7,456(sp)
    80004bb0:	6c1e                	ld	s8,448(sp)
    80004bb2:	7cfa                	ld	s9,440(sp)
    80004bb4:	7d5a                	ld	s10,432(sp)
    80004bb6:	b9ed                	j	800048b0 <kexec+0x60>
    80004bb8:	6b5e                	ld	s6,464(sp)
    80004bba:	b9dd                	j	800048b0 <kexec+0x60>
  sz = sz1;
    80004bbc:	e0843983          	ld	s3,-504(s0)
    80004bc0:	b595                	j	80004a24 <kexec+0x1d4>

0000000080004bc2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004bc2:	7179                	addi	sp,sp,-48
    80004bc4:	f406                	sd	ra,40(sp)
    80004bc6:	f022                	sd	s0,32(sp)
    80004bc8:	ec26                	sd	s1,24(sp)
    80004bca:	e84a                	sd	s2,16(sp)
    80004bcc:	1800                	addi	s0,sp,48
    80004bce:	892e                	mv	s2,a1
    80004bd0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004bd2:	fdc40593          	addi	a1,s0,-36
    80004bd6:	e41fd0ef          	jal	80002a16 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004bda:	fdc42703          	lw	a4,-36(s0)
    80004bde:	47bd                	li	a5,15
    80004be0:	02e7e963          	bltu	a5,a4,80004c12 <argfd+0x50>
    80004be4:	e63fc0ef          	jal	80001a46 <myproc>
    80004be8:	fdc42703          	lw	a4,-36(s0)
    80004bec:	01a70793          	addi	a5,a4,26
    80004bf0:	078e                	slli	a5,a5,0x3
    80004bf2:	953e                	add	a0,a0,a5
    80004bf4:	611c                	ld	a5,0(a0)
    80004bf6:	c385                	beqz	a5,80004c16 <argfd+0x54>
    return -1;
  if(pfd)
    80004bf8:	00090463          	beqz	s2,80004c00 <argfd+0x3e>
    *pfd = fd;
    80004bfc:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004c00:	4501                	li	a0,0
  if(pf)
    80004c02:	c091                	beqz	s1,80004c06 <argfd+0x44>
    *pf = f;
    80004c04:	e09c                	sd	a5,0(s1)
}
    80004c06:	70a2                	ld	ra,40(sp)
    80004c08:	7402                	ld	s0,32(sp)
    80004c0a:	64e2                	ld	s1,24(sp)
    80004c0c:	6942                	ld	s2,16(sp)
    80004c0e:	6145                	addi	sp,sp,48
    80004c10:	8082                	ret
    return -1;
    80004c12:	557d                	li	a0,-1
    80004c14:	bfcd                	j	80004c06 <argfd+0x44>
    80004c16:	557d                	li	a0,-1
    80004c18:	b7fd                	j	80004c06 <argfd+0x44>

0000000080004c1a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004c1a:	1101                	addi	sp,sp,-32
    80004c1c:	ec06                	sd	ra,24(sp)
    80004c1e:	e822                	sd	s0,16(sp)
    80004c20:	e426                	sd	s1,8(sp)
    80004c22:	1000                	addi	s0,sp,32
    80004c24:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004c26:	e21fc0ef          	jal	80001a46 <myproc>
    80004c2a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004c2c:	0d050793          	addi	a5,a0,208
    80004c30:	4501                	li	a0,0
    80004c32:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004c34:	6398                	ld	a4,0(a5)
    80004c36:	cb19                	beqz	a4,80004c4c <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004c38:	2505                	addiw	a0,a0,1
    80004c3a:	07a1                	addi	a5,a5,8
    80004c3c:	fed51ce3          	bne	a0,a3,80004c34 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004c40:	557d                	li	a0,-1
}
    80004c42:	60e2                	ld	ra,24(sp)
    80004c44:	6442                	ld	s0,16(sp)
    80004c46:	64a2                	ld	s1,8(sp)
    80004c48:	6105                	addi	sp,sp,32
    80004c4a:	8082                	ret
      p->ofile[fd] = f;
    80004c4c:	01a50793          	addi	a5,a0,26
    80004c50:	078e                	slli	a5,a5,0x3
    80004c52:	963e                	add	a2,a2,a5
    80004c54:	e204                	sd	s1,0(a2)
      return fd;
    80004c56:	b7f5                	j	80004c42 <fdalloc+0x28>

0000000080004c58 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004c58:	715d                	addi	sp,sp,-80
    80004c5a:	e486                	sd	ra,72(sp)
    80004c5c:	e0a2                	sd	s0,64(sp)
    80004c5e:	fc26                	sd	s1,56(sp)
    80004c60:	f84a                	sd	s2,48(sp)
    80004c62:	f44e                	sd	s3,40(sp)
    80004c64:	ec56                	sd	s5,24(sp)
    80004c66:	e85a                	sd	s6,16(sp)
    80004c68:	0880                	addi	s0,sp,80
    80004c6a:	8b2e                	mv	s6,a1
    80004c6c:	89b2                	mv	s3,a2
    80004c6e:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004c70:	fb040593          	addi	a1,s0,-80
    80004c74:	80eff0ef          	jal	80003c82 <nameiparent>
    80004c78:	84aa                	mv	s1,a0
    80004c7a:	10050a63          	beqz	a0,80004d8e <create+0x136>
    return 0;

  ilock(dp);
    80004c7e:	fd4fe0ef          	jal	80003452 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004c82:	4601                	li	a2,0
    80004c84:	fb040593          	addi	a1,s0,-80
    80004c88:	8526                	mv	a0,s1
    80004c8a:	d79fe0ef          	jal	80003a02 <dirlookup>
    80004c8e:	8aaa                	mv	s5,a0
    80004c90:	c129                	beqz	a0,80004cd2 <create+0x7a>
    iunlockput(dp);
    80004c92:	8526                	mv	a0,s1
    80004c94:	9c9fe0ef          	jal	8000365c <iunlockput>
    ilock(ip);
    80004c98:	8556                	mv	a0,s5
    80004c9a:	fb8fe0ef          	jal	80003452 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004c9e:	4789                	li	a5,2
    80004ca0:	02fb1463          	bne	s6,a5,80004cc8 <create+0x70>
    80004ca4:	044ad783          	lhu	a5,68(s5)
    80004ca8:	37f9                	addiw	a5,a5,-2
    80004caa:	17c2                	slli	a5,a5,0x30
    80004cac:	93c1                	srli	a5,a5,0x30
    80004cae:	4705                	li	a4,1
    80004cb0:	00f76c63          	bltu	a4,a5,80004cc8 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004cb4:	8556                	mv	a0,s5
    80004cb6:	60a6                	ld	ra,72(sp)
    80004cb8:	6406                	ld	s0,64(sp)
    80004cba:	74e2                	ld	s1,56(sp)
    80004cbc:	7942                	ld	s2,48(sp)
    80004cbe:	79a2                	ld	s3,40(sp)
    80004cc0:	6ae2                	ld	s5,24(sp)
    80004cc2:	6b42                	ld	s6,16(sp)
    80004cc4:	6161                	addi	sp,sp,80
    80004cc6:	8082                	ret
    iunlockput(ip);
    80004cc8:	8556                	mv	a0,s5
    80004cca:	993fe0ef          	jal	8000365c <iunlockput>
    return 0;
    80004cce:	4a81                	li	s5,0
    80004cd0:	b7d5                	j	80004cb4 <create+0x5c>
    80004cd2:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004cd4:	85da                	mv	a1,s6
    80004cd6:	4088                	lw	a0,0(s1)
    80004cd8:	e0afe0ef          	jal	800032e2 <ialloc>
    80004cdc:	8a2a                	mv	s4,a0
    80004cde:	cd15                	beqz	a0,80004d1a <create+0xc2>
  ilock(ip);
    80004ce0:	f72fe0ef          	jal	80003452 <ilock>
  ip->major = major;
    80004ce4:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004ce8:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004cec:	4905                	li	s2,1
    80004cee:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004cf2:	8552                	mv	a0,s4
    80004cf4:	eaafe0ef          	jal	8000339e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004cf8:	032b0763          	beq	s6,s2,80004d26 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004cfc:	004a2603          	lw	a2,4(s4)
    80004d00:	fb040593          	addi	a1,s0,-80
    80004d04:	8526                	mv	a0,s1
    80004d06:	ec9fe0ef          	jal	80003bce <dirlink>
    80004d0a:	06054563          	bltz	a0,80004d74 <create+0x11c>
  iunlockput(dp);
    80004d0e:	8526                	mv	a0,s1
    80004d10:	94dfe0ef          	jal	8000365c <iunlockput>
  return ip;
    80004d14:	8ad2                	mv	s5,s4
    80004d16:	7a02                	ld	s4,32(sp)
    80004d18:	bf71                	j	80004cb4 <create+0x5c>
    iunlockput(dp);
    80004d1a:	8526                	mv	a0,s1
    80004d1c:	941fe0ef          	jal	8000365c <iunlockput>
    return 0;
    80004d20:	8ad2                	mv	s5,s4
    80004d22:	7a02                	ld	s4,32(sp)
    80004d24:	bf41                	j	80004cb4 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004d26:	004a2603          	lw	a2,4(s4)
    80004d2a:	00003597          	auipc	a1,0x3
    80004d2e:	8b658593          	addi	a1,a1,-1866 # 800075e0 <etext+0x5e0>
    80004d32:	8552                	mv	a0,s4
    80004d34:	e9bfe0ef          	jal	80003bce <dirlink>
    80004d38:	02054e63          	bltz	a0,80004d74 <create+0x11c>
    80004d3c:	40d0                	lw	a2,4(s1)
    80004d3e:	00003597          	auipc	a1,0x3
    80004d42:	8aa58593          	addi	a1,a1,-1878 # 800075e8 <etext+0x5e8>
    80004d46:	8552                	mv	a0,s4
    80004d48:	e87fe0ef          	jal	80003bce <dirlink>
    80004d4c:	02054463          	bltz	a0,80004d74 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004d50:	004a2603          	lw	a2,4(s4)
    80004d54:	fb040593          	addi	a1,s0,-80
    80004d58:	8526                	mv	a0,s1
    80004d5a:	e75fe0ef          	jal	80003bce <dirlink>
    80004d5e:	00054b63          	bltz	a0,80004d74 <create+0x11c>
    dp->nlink++;  // for ".."
    80004d62:	04a4d783          	lhu	a5,74(s1)
    80004d66:	2785                	addiw	a5,a5,1
    80004d68:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004d6c:	8526                	mv	a0,s1
    80004d6e:	e30fe0ef          	jal	8000339e <iupdate>
    80004d72:	bf71                	j	80004d0e <create+0xb6>
  ip->nlink = 0;
    80004d74:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004d78:	8552                	mv	a0,s4
    80004d7a:	e24fe0ef          	jal	8000339e <iupdate>
  iunlockput(ip);
    80004d7e:	8552                	mv	a0,s4
    80004d80:	8ddfe0ef          	jal	8000365c <iunlockput>
  iunlockput(dp);
    80004d84:	8526                	mv	a0,s1
    80004d86:	8d7fe0ef          	jal	8000365c <iunlockput>
  return 0;
    80004d8a:	7a02                	ld	s4,32(sp)
    80004d8c:	b725                	j	80004cb4 <create+0x5c>
    return 0;
    80004d8e:	8aaa                	mv	s5,a0
    80004d90:	b715                	j	80004cb4 <create+0x5c>

0000000080004d92 <sys_dup>:
{
    80004d92:	7179                	addi	sp,sp,-48
    80004d94:	f406                	sd	ra,40(sp)
    80004d96:	f022                	sd	s0,32(sp)
    80004d98:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004d9a:	fd840613          	addi	a2,s0,-40
    80004d9e:	4581                	li	a1,0
    80004da0:	4501                	li	a0,0
    80004da2:	e21ff0ef          	jal	80004bc2 <argfd>
    return -1;
    80004da6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004da8:	02054363          	bltz	a0,80004dce <sys_dup+0x3c>
    80004dac:	ec26                	sd	s1,24(sp)
    80004dae:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004db0:	fd843903          	ld	s2,-40(s0)
    80004db4:	854a                	mv	a0,s2
    80004db6:	e65ff0ef          	jal	80004c1a <fdalloc>
    80004dba:	84aa                	mv	s1,a0
    return -1;
    80004dbc:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004dbe:	00054d63          	bltz	a0,80004dd8 <sys_dup+0x46>
  filedup(f);
    80004dc2:	854a                	mv	a0,s2
    80004dc4:	c3eff0ef          	jal	80004202 <filedup>
  return fd;
    80004dc8:	87a6                	mv	a5,s1
    80004dca:	64e2                	ld	s1,24(sp)
    80004dcc:	6942                	ld	s2,16(sp)
}
    80004dce:	853e                	mv	a0,a5
    80004dd0:	70a2                	ld	ra,40(sp)
    80004dd2:	7402                	ld	s0,32(sp)
    80004dd4:	6145                	addi	sp,sp,48
    80004dd6:	8082                	ret
    80004dd8:	64e2                	ld	s1,24(sp)
    80004dda:	6942                	ld	s2,16(sp)
    80004ddc:	bfcd                	j	80004dce <sys_dup+0x3c>

0000000080004dde <sys_read>:
{
    80004dde:	7179                	addi	sp,sp,-48
    80004de0:	f406                	sd	ra,40(sp)
    80004de2:	f022                	sd	s0,32(sp)
    80004de4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004de6:	fd840593          	addi	a1,s0,-40
    80004dea:	4505                	li	a0,1
    80004dec:	c47fd0ef          	jal	80002a32 <argaddr>
  argint(2, &n);
    80004df0:	fe440593          	addi	a1,s0,-28
    80004df4:	4509                	li	a0,2
    80004df6:	c21fd0ef          	jal	80002a16 <argint>
  if(argfd(0, 0, &f) < 0)
    80004dfa:	fe840613          	addi	a2,s0,-24
    80004dfe:	4581                	li	a1,0
    80004e00:	4501                	li	a0,0
    80004e02:	dc1ff0ef          	jal	80004bc2 <argfd>
    80004e06:	87aa                	mv	a5,a0
    return -1;
    80004e08:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e0a:	0007ca63          	bltz	a5,80004e1e <sys_read+0x40>
  return fileread(f, p, n);
    80004e0e:	fe442603          	lw	a2,-28(s0)
    80004e12:	fd843583          	ld	a1,-40(s0)
    80004e16:	fe843503          	ld	a0,-24(s0)
    80004e1a:	d4eff0ef          	jal	80004368 <fileread>
}
    80004e1e:	70a2                	ld	ra,40(sp)
    80004e20:	7402                	ld	s0,32(sp)
    80004e22:	6145                	addi	sp,sp,48
    80004e24:	8082                	ret

0000000080004e26 <sys_write>:
{
    80004e26:	7179                	addi	sp,sp,-48
    80004e28:	f406                	sd	ra,40(sp)
    80004e2a:	f022                	sd	s0,32(sp)
    80004e2c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e2e:	fd840593          	addi	a1,s0,-40
    80004e32:	4505                	li	a0,1
    80004e34:	bfffd0ef          	jal	80002a32 <argaddr>
  argint(2, &n);
    80004e38:	fe440593          	addi	a1,s0,-28
    80004e3c:	4509                	li	a0,2
    80004e3e:	bd9fd0ef          	jal	80002a16 <argint>
  if(argfd(0, 0, &f) < 0)
    80004e42:	fe840613          	addi	a2,s0,-24
    80004e46:	4581                	li	a1,0
    80004e48:	4501                	li	a0,0
    80004e4a:	d79ff0ef          	jal	80004bc2 <argfd>
    80004e4e:	87aa                	mv	a5,a0
    return -1;
    80004e50:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e52:	0007ca63          	bltz	a5,80004e66 <sys_write+0x40>
  return filewrite(f, p, n);
    80004e56:	fe442603          	lw	a2,-28(s0)
    80004e5a:	fd843583          	ld	a1,-40(s0)
    80004e5e:	fe843503          	ld	a0,-24(s0)
    80004e62:	dc4ff0ef          	jal	80004426 <filewrite>
}
    80004e66:	70a2                	ld	ra,40(sp)
    80004e68:	7402                	ld	s0,32(sp)
    80004e6a:	6145                	addi	sp,sp,48
    80004e6c:	8082                	ret

0000000080004e6e <sys_close>:
{
    80004e6e:	1101                	addi	sp,sp,-32
    80004e70:	ec06                	sd	ra,24(sp)
    80004e72:	e822                	sd	s0,16(sp)
    80004e74:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004e76:	fe040613          	addi	a2,s0,-32
    80004e7a:	fec40593          	addi	a1,s0,-20
    80004e7e:	4501                	li	a0,0
    80004e80:	d43ff0ef          	jal	80004bc2 <argfd>
    return -1;
    80004e84:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004e86:	02054063          	bltz	a0,80004ea6 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004e8a:	bbdfc0ef          	jal	80001a46 <myproc>
    80004e8e:	fec42783          	lw	a5,-20(s0)
    80004e92:	07e9                	addi	a5,a5,26
    80004e94:	078e                	slli	a5,a5,0x3
    80004e96:	953e                	add	a0,a0,a5
    80004e98:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004e9c:	fe043503          	ld	a0,-32(s0)
    80004ea0:	ba8ff0ef          	jal	80004248 <fileclose>
  return 0;
    80004ea4:	4781                	li	a5,0
}
    80004ea6:	853e                	mv	a0,a5
    80004ea8:	60e2                	ld	ra,24(sp)
    80004eaa:	6442                	ld	s0,16(sp)
    80004eac:	6105                	addi	sp,sp,32
    80004eae:	8082                	ret

0000000080004eb0 <sys_fstat>:
{
    80004eb0:	1101                	addi	sp,sp,-32
    80004eb2:	ec06                	sd	ra,24(sp)
    80004eb4:	e822                	sd	s0,16(sp)
    80004eb6:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004eb8:	fe040593          	addi	a1,s0,-32
    80004ebc:	4505                	li	a0,1
    80004ebe:	b75fd0ef          	jal	80002a32 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004ec2:	fe840613          	addi	a2,s0,-24
    80004ec6:	4581                	li	a1,0
    80004ec8:	4501                	li	a0,0
    80004eca:	cf9ff0ef          	jal	80004bc2 <argfd>
    80004ece:	87aa                	mv	a5,a0
    return -1;
    80004ed0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004ed2:	0007c863          	bltz	a5,80004ee2 <sys_fstat+0x32>
  return filestat(f, st);
    80004ed6:	fe043583          	ld	a1,-32(s0)
    80004eda:	fe843503          	ld	a0,-24(s0)
    80004ede:	c2cff0ef          	jal	8000430a <filestat>
}
    80004ee2:	60e2                	ld	ra,24(sp)
    80004ee4:	6442                	ld	s0,16(sp)
    80004ee6:	6105                	addi	sp,sp,32
    80004ee8:	8082                	ret

0000000080004eea <sys_link>:
{
    80004eea:	7169                	addi	sp,sp,-304
    80004eec:	f606                	sd	ra,296(sp)
    80004eee:	f222                	sd	s0,288(sp)
    80004ef0:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ef2:	08000613          	li	a2,128
    80004ef6:	ed040593          	addi	a1,s0,-304
    80004efa:	4501                	li	a0,0
    80004efc:	b53fd0ef          	jal	80002a4e <argstr>
    return -1;
    80004f00:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f02:	0c054e63          	bltz	a0,80004fde <sys_link+0xf4>
    80004f06:	08000613          	li	a2,128
    80004f0a:	f5040593          	addi	a1,s0,-176
    80004f0e:	4505                	li	a0,1
    80004f10:	b3ffd0ef          	jal	80002a4e <argstr>
    return -1;
    80004f14:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f16:	0c054463          	bltz	a0,80004fde <sys_link+0xf4>
    80004f1a:	ee26                	sd	s1,280(sp)
  begin_op();
    80004f1c:	f21fe0ef          	jal	80003e3c <begin_op>
  if((ip = namei(old)) == 0){
    80004f20:	ed040513          	addi	a0,s0,-304
    80004f24:	d45fe0ef          	jal	80003c68 <namei>
    80004f28:	84aa                	mv	s1,a0
    80004f2a:	c53d                	beqz	a0,80004f98 <sys_link+0xae>
  ilock(ip);
    80004f2c:	d26fe0ef          	jal	80003452 <ilock>
  if(ip->type == T_DIR){
    80004f30:	04449703          	lh	a4,68(s1)
    80004f34:	4785                	li	a5,1
    80004f36:	06f70663          	beq	a4,a5,80004fa2 <sys_link+0xb8>
    80004f3a:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004f3c:	04a4d783          	lhu	a5,74(s1)
    80004f40:	2785                	addiw	a5,a5,1
    80004f42:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004f46:	8526                	mv	a0,s1
    80004f48:	c56fe0ef          	jal	8000339e <iupdate>
  iunlock(ip);
    80004f4c:	8526                	mv	a0,s1
    80004f4e:	db2fe0ef          	jal	80003500 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004f52:	fd040593          	addi	a1,s0,-48
    80004f56:	f5040513          	addi	a0,s0,-176
    80004f5a:	d29fe0ef          	jal	80003c82 <nameiparent>
    80004f5e:	892a                	mv	s2,a0
    80004f60:	cd21                	beqz	a0,80004fb8 <sys_link+0xce>
  ilock(dp);
    80004f62:	cf0fe0ef          	jal	80003452 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004f66:	00092703          	lw	a4,0(s2)
    80004f6a:	409c                	lw	a5,0(s1)
    80004f6c:	04f71363          	bne	a4,a5,80004fb2 <sys_link+0xc8>
    80004f70:	40d0                	lw	a2,4(s1)
    80004f72:	fd040593          	addi	a1,s0,-48
    80004f76:	854a                	mv	a0,s2
    80004f78:	c57fe0ef          	jal	80003bce <dirlink>
    80004f7c:	02054b63          	bltz	a0,80004fb2 <sys_link+0xc8>
  iunlockput(dp);
    80004f80:	854a                	mv	a0,s2
    80004f82:	edafe0ef          	jal	8000365c <iunlockput>
  iput(ip);
    80004f86:	8526                	mv	a0,s1
    80004f88:	e4cfe0ef          	jal	800035d4 <iput>
  end_op();
    80004f8c:	f1bfe0ef          	jal	80003ea6 <end_op>
  return 0;
    80004f90:	4781                	li	a5,0
    80004f92:	64f2                	ld	s1,280(sp)
    80004f94:	6952                	ld	s2,272(sp)
    80004f96:	a0a1                	j	80004fde <sys_link+0xf4>
    end_op();
    80004f98:	f0ffe0ef          	jal	80003ea6 <end_op>
    return -1;
    80004f9c:	57fd                	li	a5,-1
    80004f9e:	64f2                	ld	s1,280(sp)
    80004fa0:	a83d                	j	80004fde <sys_link+0xf4>
    iunlockput(ip);
    80004fa2:	8526                	mv	a0,s1
    80004fa4:	eb8fe0ef          	jal	8000365c <iunlockput>
    end_op();
    80004fa8:	efffe0ef          	jal	80003ea6 <end_op>
    return -1;
    80004fac:	57fd                	li	a5,-1
    80004fae:	64f2                	ld	s1,280(sp)
    80004fb0:	a03d                	j	80004fde <sys_link+0xf4>
    iunlockput(dp);
    80004fb2:	854a                	mv	a0,s2
    80004fb4:	ea8fe0ef          	jal	8000365c <iunlockput>
  ilock(ip);
    80004fb8:	8526                	mv	a0,s1
    80004fba:	c98fe0ef          	jal	80003452 <ilock>
  ip->nlink--;
    80004fbe:	04a4d783          	lhu	a5,74(s1)
    80004fc2:	37fd                	addiw	a5,a5,-1
    80004fc4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004fc8:	8526                	mv	a0,s1
    80004fca:	bd4fe0ef          	jal	8000339e <iupdate>
  iunlockput(ip);
    80004fce:	8526                	mv	a0,s1
    80004fd0:	e8cfe0ef          	jal	8000365c <iunlockput>
  end_op();
    80004fd4:	ed3fe0ef          	jal	80003ea6 <end_op>
  return -1;
    80004fd8:	57fd                	li	a5,-1
    80004fda:	64f2                	ld	s1,280(sp)
    80004fdc:	6952                	ld	s2,272(sp)
}
    80004fde:	853e                	mv	a0,a5
    80004fe0:	70b2                	ld	ra,296(sp)
    80004fe2:	7412                	ld	s0,288(sp)
    80004fe4:	6155                	addi	sp,sp,304
    80004fe6:	8082                	ret

0000000080004fe8 <sys_unlink>:
{
    80004fe8:	7151                	addi	sp,sp,-240
    80004fea:	f586                	sd	ra,232(sp)
    80004fec:	f1a2                	sd	s0,224(sp)
    80004fee:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004ff0:	08000613          	li	a2,128
    80004ff4:	f3040593          	addi	a1,s0,-208
    80004ff8:	4501                	li	a0,0
    80004ffa:	a55fd0ef          	jal	80002a4e <argstr>
    80004ffe:	16054063          	bltz	a0,8000515e <sys_unlink+0x176>
    80005002:	eda6                	sd	s1,216(sp)
  begin_op();
    80005004:	e39fe0ef          	jal	80003e3c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005008:	fb040593          	addi	a1,s0,-80
    8000500c:	f3040513          	addi	a0,s0,-208
    80005010:	c73fe0ef          	jal	80003c82 <nameiparent>
    80005014:	84aa                	mv	s1,a0
    80005016:	c945                	beqz	a0,800050c6 <sys_unlink+0xde>
  ilock(dp);
    80005018:	c3afe0ef          	jal	80003452 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000501c:	00002597          	auipc	a1,0x2
    80005020:	5c458593          	addi	a1,a1,1476 # 800075e0 <etext+0x5e0>
    80005024:	fb040513          	addi	a0,s0,-80
    80005028:	9c5fe0ef          	jal	800039ec <namecmp>
    8000502c:	10050e63          	beqz	a0,80005148 <sys_unlink+0x160>
    80005030:	00002597          	auipc	a1,0x2
    80005034:	5b858593          	addi	a1,a1,1464 # 800075e8 <etext+0x5e8>
    80005038:	fb040513          	addi	a0,s0,-80
    8000503c:	9b1fe0ef          	jal	800039ec <namecmp>
    80005040:	10050463          	beqz	a0,80005148 <sys_unlink+0x160>
    80005044:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005046:	f2c40613          	addi	a2,s0,-212
    8000504a:	fb040593          	addi	a1,s0,-80
    8000504e:	8526                	mv	a0,s1
    80005050:	9b3fe0ef          	jal	80003a02 <dirlookup>
    80005054:	892a                	mv	s2,a0
    80005056:	0e050863          	beqz	a0,80005146 <sys_unlink+0x15e>
  ilock(ip);
    8000505a:	bf8fe0ef          	jal	80003452 <ilock>
  if(ip->nlink < 1)
    8000505e:	04a91783          	lh	a5,74(s2)
    80005062:	06f05763          	blez	a5,800050d0 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005066:	04491703          	lh	a4,68(s2)
    8000506a:	4785                	li	a5,1
    8000506c:	06f70963          	beq	a4,a5,800050de <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80005070:	4641                	li	a2,16
    80005072:	4581                	li	a1,0
    80005074:	fc040513          	addi	a0,s0,-64
    80005078:	c2bfb0ef          	jal	80000ca2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000507c:	4741                	li	a4,16
    8000507e:	f2c42683          	lw	a3,-212(s0)
    80005082:	fc040613          	addi	a2,s0,-64
    80005086:	4581                	li	a1,0
    80005088:	8526                	mv	a0,s1
    8000508a:	855fe0ef          	jal	800038de <writei>
    8000508e:	47c1                	li	a5,16
    80005090:	08f51b63          	bne	a0,a5,80005126 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80005094:	04491703          	lh	a4,68(s2)
    80005098:	4785                	li	a5,1
    8000509a:	08f70d63          	beq	a4,a5,80005134 <sys_unlink+0x14c>
  iunlockput(dp);
    8000509e:	8526                	mv	a0,s1
    800050a0:	dbcfe0ef          	jal	8000365c <iunlockput>
  ip->nlink--;
    800050a4:	04a95783          	lhu	a5,74(s2)
    800050a8:	37fd                	addiw	a5,a5,-1
    800050aa:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800050ae:	854a                	mv	a0,s2
    800050b0:	aeefe0ef          	jal	8000339e <iupdate>
  iunlockput(ip);
    800050b4:	854a                	mv	a0,s2
    800050b6:	da6fe0ef          	jal	8000365c <iunlockput>
  end_op();
    800050ba:	dedfe0ef          	jal	80003ea6 <end_op>
  return 0;
    800050be:	4501                	li	a0,0
    800050c0:	64ee                	ld	s1,216(sp)
    800050c2:	694e                	ld	s2,208(sp)
    800050c4:	a849                	j	80005156 <sys_unlink+0x16e>
    end_op();
    800050c6:	de1fe0ef          	jal	80003ea6 <end_op>
    return -1;
    800050ca:	557d                	li	a0,-1
    800050cc:	64ee                	ld	s1,216(sp)
    800050ce:	a061                	j	80005156 <sys_unlink+0x16e>
    800050d0:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800050d2:	00002517          	auipc	a0,0x2
    800050d6:	51e50513          	addi	a0,a0,1310 # 800075f0 <etext+0x5f0>
    800050da:	f06fb0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800050de:	04c92703          	lw	a4,76(s2)
    800050e2:	02000793          	li	a5,32
    800050e6:	f8e7f5e3          	bgeu	a5,a4,80005070 <sys_unlink+0x88>
    800050ea:	e5ce                	sd	s3,200(sp)
    800050ec:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800050f0:	4741                	li	a4,16
    800050f2:	86ce                	mv	a3,s3
    800050f4:	f1840613          	addi	a2,s0,-232
    800050f8:	4581                	li	a1,0
    800050fa:	854a                	mv	a0,s2
    800050fc:	ee6fe0ef          	jal	800037e2 <readi>
    80005100:	47c1                	li	a5,16
    80005102:	00f51c63          	bne	a0,a5,8000511a <sys_unlink+0x132>
    if(de.inum != 0)
    80005106:	f1845783          	lhu	a5,-232(s0)
    8000510a:	efa1                	bnez	a5,80005162 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000510c:	29c1                	addiw	s3,s3,16
    8000510e:	04c92783          	lw	a5,76(s2)
    80005112:	fcf9efe3          	bltu	s3,a5,800050f0 <sys_unlink+0x108>
    80005116:	69ae                	ld	s3,200(sp)
    80005118:	bfa1                	j	80005070 <sys_unlink+0x88>
      panic("isdirempty: readi");
    8000511a:	00002517          	auipc	a0,0x2
    8000511e:	4ee50513          	addi	a0,a0,1262 # 80007608 <etext+0x608>
    80005122:	ebefb0ef          	jal	800007e0 <panic>
    80005126:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005128:	00002517          	auipc	a0,0x2
    8000512c:	4f850513          	addi	a0,a0,1272 # 80007620 <etext+0x620>
    80005130:	eb0fb0ef          	jal	800007e0 <panic>
    dp->nlink--;
    80005134:	04a4d783          	lhu	a5,74(s1)
    80005138:	37fd                	addiw	a5,a5,-1
    8000513a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000513e:	8526                	mv	a0,s1
    80005140:	a5efe0ef          	jal	8000339e <iupdate>
    80005144:	bfa9                	j	8000509e <sys_unlink+0xb6>
    80005146:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005148:	8526                	mv	a0,s1
    8000514a:	d12fe0ef          	jal	8000365c <iunlockput>
  end_op();
    8000514e:	d59fe0ef          	jal	80003ea6 <end_op>
  return -1;
    80005152:	557d                	li	a0,-1
    80005154:	64ee                	ld	s1,216(sp)
}
    80005156:	70ae                	ld	ra,232(sp)
    80005158:	740e                	ld	s0,224(sp)
    8000515a:	616d                	addi	sp,sp,240
    8000515c:	8082                	ret
    return -1;
    8000515e:	557d                	li	a0,-1
    80005160:	bfdd                	j	80005156 <sys_unlink+0x16e>
    iunlockput(ip);
    80005162:	854a                	mv	a0,s2
    80005164:	cf8fe0ef          	jal	8000365c <iunlockput>
    goto bad;
    80005168:	694e                	ld	s2,208(sp)
    8000516a:	69ae                	ld	s3,200(sp)
    8000516c:	bff1                	j	80005148 <sys_unlink+0x160>

000000008000516e <sys_open>:

uint64
sys_open(void)
{
    8000516e:	7131                	addi	sp,sp,-192
    80005170:	fd06                	sd	ra,184(sp)
    80005172:	f922                	sd	s0,176(sp)
    80005174:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005176:	f4c40593          	addi	a1,s0,-180
    8000517a:	4505                	li	a0,1
    8000517c:	89bfd0ef          	jal	80002a16 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005180:	08000613          	li	a2,128
    80005184:	f5040593          	addi	a1,s0,-176
    80005188:	4501                	li	a0,0
    8000518a:	8c5fd0ef          	jal	80002a4e <argstr>
    8000518e:	87aa                	mv	a5,a0
    return -1;
    80005190:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005192:	0a07c263          	bltz	a5,80005236 <sys_open+0xc8>
    80005196:	f526                	sd	s1,168(sp)

  begin_op();
    80005198:	ca5fe0ef          	jal	80003e3c <begin_op>

  if(omode & O_CREATE){
    8000519c:	f4c42783          	lw	a5,-180(s0)
    800051a0:	2007f793          	andi	a5,a5,512
    800051a4:	c3d5                	beqz	a5,80005248 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800051a6:	4681                	li	a3,0
    800051a8:	4601                	li	a2,0
    800051aa:	4589                	li	a1,2
    800051ac:	f5040513          	addi	a0,s0,-176
    800051b0:	aa9ff0ef          	jal	80004c58 <create>
    800051b4:	84aa                	mv	s1,a0
    if(ip == 0){
    800051b6:	c541                	beqz	a0,8000523e <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800051b8:	04449703          	lh	a4,68(s1)
    800051bc:	478d                	li	a5,3
    800051be:	00f71763          	bne	a4,a5,800051cc <sys_open+0x5e>
    800051c2:	0464d703          	lhu	a4,70(s1)
    800051c6:	47a5                	li	a5,9
    800051c8:	0ae7ed63          	bltu	a5,a4,80005282 <sys_open+0x114>
    800051cc:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800051ce:	fd7fe0ef          	jal	800041a4 <filealloc>
    800051d2:	892a                	mv	s2,a0
    800051d4:	c179                	beqz	a0,8000529a <sys_open+0x12c>
    800051d6:	ed4e                	sd	s3,152(sp)
    800051d8:	a43ff0ef          	jal	80004c1a <fdalloc>
    800051dc:	89aa                	mv	s3,a0
    800051de:	0a054a63          	bltz	a0,80005292 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800051e2:	04449703          	lh	a4,68(s1)
    800051e6:	478d                	li	a5,3
    800051e8:	0cf70263          	beq	a4,a5,800052ac <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800051ec:	4789                	li	a5,2
    800051ee:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800051f2:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800051f6:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800051fa:	f4c42783          	lw	a5,-180(s0)
    800051fe:	0017c713          	xori	a4,a5,1
    80005202:	8b05                	andi	a4,a4,1
    80005204:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005208:	0037f713          	andi	a4,a5,3
    8000520c:	00e03733          	snez	a4,a4
    80005210:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005214:	4007f793          	andi	a5,a5,1024
    80005218:	c791                	beqz	a5,80005224 <sys_open+0xb6>
    8000521a:	04449703          	lh	a4,68(s1)
    8000521e:	4789                	li	a5,2
    80005220:	08f70d63          	beq	a4,a5,800052ba <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005224:	8526                	mv	a0,s1
    80005226:	adafe0ef          	jal	80003500 <iunlock>
  end_op();
    8000522a:	c7dfe0ef          	jal	80003ea6 <end_op>

  return fd;
    8000522e:	854e                	mv	a0,s3
    80005230:	74aa                	ld	s1,168(sp)
    80005232:	790a                	ld	s2,160(sp)
    80005234:	69ea                	ld	s3,152(sp)
}
    80005236:	70ea                	ld	ra,184(sp)
    80005238:	744a                	ld	s0,176(sp)
    8000523a:	6129                	addi	sp,sp,192
    8000523c:	8082                	ret
      end_op();
    8000523e:	c69fe0ef          	jal	80003ea6 <end_op>
      return -1;
    80005242:	557d                	li	a0,-1
    80005244:	74aa                	ld	s1,168(sp)
    80005246:	bfc5                	j	80005236 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80005248:	f5040513          	addi	a0,s0,-176
    8000524c:	a1dfe0ef          	jal	80003c68 <namei>
    80005250:	84aa                	mv	s1,a0
    80005252:	c11d                	beqz	a0,80005278 <sys_open+0x10a>
    ilock(ip);
    80005254:	9fefe0ef          	jal	80003452 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005258:	04449703          	lh	a4,68(s1)
    8000525c:	4785                	li	a5,1
    8000525e:	f4f71de3          	bne	a4,a5,800051b8 <sys_open+0x4a>
    80005262:	f4c42783          	lw	a5,-180(s0)
    80005266:	d3bd                	beqz	a5,800051cc <sys_open+0x5e>
      iunlockput(ip);
    80005268:	8526                	mv	a0,s1
    8000526a:	bf2fe0ef          	jal	8000365c <iunlockput>
      end_op();
    8000526e:	c39fe0ef          	jal	80003ea6 <end_op>
      return -1;
    80005272:	557d                	li	a0,-1
    80005274:	74aa                	ld	s1,168(sp)
    80005276:	b7c1                	j	80005236 <sys_open+0xc8>
      end_op();
    80005278:	c2ffe0ef          	jal	80003ea6 <end_op>
      return -1;
    8000527c:	557d                	li	a0,-1
    8000527e:	74aa                	ld	s1,168(sp)
    80005280:	bf5d                	j	80005236 <sys_open+0xc8>
    iunlockput(ip);
    80005282:	8526                	mv	a0,s1
    80005284:	bd8fe0ef          	jal	8000365c <iunlockput>
    end_op();
    80005288:	c1ffe0ef          	jal	80003ea6 <end_op>
    return -1;
    8000528c:	557d                	li	a0,-1
    8000528e:	74aa                	ld	s1,168(sp)
    80005290:	b75d                	j	80005236 <sys_open+0xc8>
      fileclose(f);
    80005292:	854a                	mv	a0,s2
    80005294:	fb5fe0ef          	jal	80004248 <fileclose>
    80005298:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000529a:	8526                	mv	a0,s1
    8000529c:	bc0fe0ef          	jal	8000365c <iunlockput>
    end_op();
    800052a0:	c07fe0ef          	jal	80003ea6 <end_op>
    return -1;
    800052a4:	557d                	li	a0,-1
    800052a6:	74aa                	ld	s1,168(sp)
    800052a8:	790a                	ld	s2,160(sp)
    800052aa:	b771                	j	80005236 <sys_open+0xc8>
    f->type = FD_DEVICE;
    800052ac:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800052b0:	04649783          	lh	a5,70(s1)
    800052b4:	02f91223          	sh	a5,36(s2)
    800052b8:	bf3d                	j	800051f6 <sys_open+0x88>
    itrunc(ip);
    800052ba:	8526                	mv	a0,s1
    800052bc:	a84fe0ef          	jal	80003540 <itrunc>
    800052c0:	b795                	j	80005224 <sys_open+0xb6>

00000000800052c2 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800052c2:	7175                	addi	sp,sp,-144
    800052c4:	e506                	sd	ra,136(sp)
    800052c6:	e122                	sd	s0,128(sp)
    800052c8:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800052ca:	b73fe0ef          	jal	80003e3c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800052ce:	08000613          	li	a2,128
    800052d2:	f7040593          	addi	a1,s0,-144
    800052d6:	4501                	li	a0,0
    800052d8:	f76fd0ef          	jal	80002a4e <argstr>
    800052dc:	02054363          	bltz	a0,80005302 <sys_mkdir+0x40>
    800052e0:	4681                	li	a3,0
    800052e2:	4601                	li	a2,0
    800052e4:	4585                	li	a1,1
    800052e6:	f7040513          	addi	a0,s0,-144
    800052ea:	96fff0ef          	jal	80004c58 <create>
    800052ee:	c911                	beqz	a0,80005302 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800052f0:	b6cfe0ef          	jal	8000365c <iunlockput>
  end_op();
    800052f4:	bb3fe0ef          	jal	80003ea6 <end_op>
  return 0;
    800052f8:	4501                	li	a0,0
}
    800052fa:	60aa                	ld	ra,136(sp)
    800052fc:	640a                	ld	s0,128(sp)
    800052fe:	6149                	addi	sp,sp,144
    80005300:	8082                	ret
    end_op();
    80005302:	ba5fe0ef          	jal	80003ea6 <end_op>
    return -1;
    80005306:	557d                	li	a0,-1
    80005308:	bfcd                	j	800052fa <sys_mkdir+0x38>

000000008000530a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000530a:	7135                	addi	sp,sp,-160
    8000530c:	ed06                	sd	ra,152(sp)
    8000530e:	e922                	sd	s0,144(sp)
    80005310:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005312:	b2bfe0ef          	jal	80003e3c <begin_op>
  argint(1, &major);
    80005316:	f6c40593          	addi	a1,s0,-148
    8000531a:	4505                	li	a0,1
    8000531c:	efafd0ef          	jal	80002a16 <argint>
  argint(2, &minor);
    80005320:	f6840593          	addi	a1,s0,-152
    80005324:	4509                	li	a0,2
    80005326:	ef0fd0ef          	jal	80002a16 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000532a:	08000613          	li	a2,128
    8000532e:	f7040593          	addi	a1,s0,-144
    80005332:	4501                	li	a0,0
    80005334:	f1afd0ef          	jal	80002a4e <argstr>
    80005338:	02054563          	bltz	a0,80005362 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000533c:	f6841683          	lh	a3,-152(s0)
    80005340:	f6c41603          	lh	a2,-148(s0)
    80005344:	458d                	li	a1,3
    80005346:	f7040513          	addi	a0,s0,-144
    8000534a:	90fff0ef          	jal	80004c58 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000534e:	c911                	beqz	a0,80005362 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005350:	b0cfe0ef          	jal	8000365c <iunlockput>
  end_op();
    80005354:	b53fe0ef          	jal	80003ea6 <end_op>
  return 0;
    80005358:	4501                	li	a0,0
}
    8000535a:	60ea                	ld	ra,152(sp)
    8000535c:	644a                	ld	s0,144(sp)
    8000535e:	610d                	addi	sp,sp,160
    80005360:	8082                	ret
    end_op();
    80005362:	b45fe0ef          	jal	80003ea6 <end_op>
    return -1;
    80005366:	557d                	li	a0,-1
    80005368:	bfcd                	j	8000535a <sys_mknod+0x50>

000000008000536a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000536a:	7135                	addi	sp,sp,-160
    8000536c:	ed06                	sd	ra,152(sp)
    8000536e:	e922                	sd	s0,144(sp)
    80005370:	e14a                	sd	s2,128(sp)
    80005372:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005374:	ed2fc0ef          	jal	80001a46 <myproc>
    80005378:	892a                	mv	s2,a0
  
  begin_op();
    8000537a:	ac3fe0ef          	jal	80003e3c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000537e:	08000613          	li	a2,128
    80005382:	f6040593          	addi	a1,s0,-160
    80005386:	4501                	li	a0,0
    80005388:	ec6fd0ef          	jal	80002a4e <argstr>
    8000538c:	04054363          	bltz	a0,800053d2 <sys_chdir+0x68>
    80005390:	e526                	sd	s1,136(sp)
    80005392:	f6040513          	addi	a0,s0,-160
    80005396:	8d3fe0ef          	jal	80003c68 <namei>
    8000539a:	84aa                	mv	s1,a0
    8000539c:	c915                	beqz	a0,800053d0 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000539e:	8b4fe0ef          	jal	80003452 <ilock>
  if(ip->type != T_DIR){
    800053a2:	04449703          	lh	a4,68(s1)
    800053a6:	4785                	li	a5,1
    800053a8:	02f71963          	bne	a4,a5,800053da <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800053ac:	8526                	mv	a0,s1
    800053ae:	952fe0ef          	jal	80003500 <iunlock>
  iput(p->cwd);
    800053b2:	15093503          	ld	a0,336(s2)
    800053b6:	a1efe0ef          	jal	800035d4 <iput>
  end_op();
    800053ba:	aedfe0ef          	jal	80003ea6 <end_op>
  p->cwd = ip;
    800053be:	14993823          	sd	s1,336(s2)
  return 0;
    800053c2:	4501                	li	a0,0
    800053c4:	64aa                	ld	s1,136(sp)
}
    800053c6:	60ea                	ld	ra,152(sp)
    800053c8:	644a                	ld	s0,144(sp)
    800053ca:	690a                	ld	s2,128(sp)
    800053cc:	610d                	addi	sp,sp,160
    800053ce:	8082                	ret
    800053d0:	64aa                	ld	s1,136(sp)
    end_op();
    800053d2:	ad5fe0ef          	jal	80003ea6 <end_op>
    return -1;
    800053d6:	557d                	li	a0,-1
    800053d8:	b7fd                	j	800053c6 <sys_chdir+0x5c>
    iunlockput(ip);
    800053da:	8526                	mv	a0,s1
    800053dc:	a80fe0ef          	jal	8000365c <iunlockput>
    end_op();
    800053e0:	ac7fe0ef          	jal	80003ea6 <end_op>
    return -1;
    800053e4:	557d                	li	a0,-1
    800053e6:	64aa                	ld	s1,136(sp)
    800053e8:	bff9                	j	800053c6 <sys_chdir+0x5c>

00000000800053ea <sys_exec>:

uint64
sys_exec(void)
{
    800053ea:	7121                	addi	sp,sp,-448
    800053ec:	ff06                	sd	ra,440(sp)
    800053ee:	fb22                	sd	s0,432(sp)
    800053f0:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800053f2:	e4840593          	addi	a1,s0,-440
    800053f6:	4505                	li	a0,1
    800053f8:	e3afd0ef          	jal	80002a32 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800053fc:	08000613          	li	a2,128
    80005400:	f5040593          	addi	a1,s0,-176
    80005404:	4501                	li	a0,0
    80005406:	e48fd0ef          	jal	80002a4e <argstr>
    8000540a:	87aa                	mv	a5,a0
    return -1;
    8000540c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000540e:	0c07c463          	bltz	a5,800054d6 <sys_exec+0xec>
    80005412:	f726                	sd	s1,424(sp)
    80005414:	f34a                	sd	s2,416(sp)
    80005416:	ef4e                	sd	s3,408(sp)
    80005418:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000541a:	10000613          	li	a2,256
    8000541e:	4581                	li	a1,0
    80005420:	e5040513          	addi	a0,s0,-432
    80005424:	87ffb0ef          	jal	80000ca2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005428:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000542c:	89a6                	mv	s3,s1
    8000542e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005430:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005434:	00391513          	slli	a0,s2,0x3
    80005438:	e4040593          	addi	a1,s0,-448
    8000543c:	e4843783          	ld	a5,-440(s0)
    80005440:	953e                	add	a0,a0,a5
    80005442:	d4afd0ef          	jal	8000298c <fetchaddr>
    80005446:	02054663          	bltz	a0,80005472 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    8000544a:	e4043783          	ld	a5,-448(s0)
    8000544e:	c3a9                	beqz	a5,80005490 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005450:	eaefb0ef          	jal	80000afe <kalloc>
    80005454:	85aa                	mv	a1,a0
    80005456:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000545a:	cd01                	beqz	a0,80005472 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000545c:	6605                	lui	a2,0x1
    8000545e:	e4043503          	ld	a0,-448(s0)
    80005462:	d74fd0ef          	jal	800029d6 <fetchstr>
    80005466:	00054663          	bltz	a0,80005472 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    8000546a:	0905                	addi	s2,s2,1
    8000546c:	09a1                	addi	s3,s3,8
    8000546e:	fd4913e3          	bne	s2,s4,80005434 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005472:	f5040913          	addi	s2,s0,-176
    80005476:	6088                	ld	a0,0(s1)
    80005478:	c931                	beqz	a0,800054cc <sys_exec+0xe2>
    kfree(argv[i]);
    8000547a:	da2fb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000547e:	04a1                	addi	s1,s1,8
    80005480:	ff249be3          	bne	s1,s2,80005476 <sys_exec+0x8c>
  return -1;
    80005484:	557d                	li	a0,-1
    80005486:	74ba                	ld	s1,424(sp)
    80005488:	791a                	ld	s2,416(sp)
    8000548a:	69fa                	ld	s3,408(sp)
    8000548c:	6a5a                	ld	s4,400(sp)
    8000548e:	a0a1                	j	800054d6 <sys_exec+0xec>
      argv[i] = 0;
    80005490:	0009079b          	sext.w	a5,s2
    80005494:	078e                	slli	a5,a5,0x3
    80005496:	fd078793          	addi	a5,a5,-48
    8000549a:	97a2                	add	a5,a5,s0
    8000549c:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    800054a0:	e5040593          	addi	a1,s0,-432
    800054a4:	f5040513          	addi	a0,s0,-176
    800054a8:	ba8ff0ef          	jal	80004850 <kexec>
    800054ac:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054ae:	f5040993          	addi	s3,s0,-176
    800054b2:	6088                	ld	a0,0(s1)
    800054b4:	c511                	beqz	a0,800054c0 <sys_exec+0xd6>
    kfree(argv[i]);
    800054b6:	d66fb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054ba:	04a1                	addi	s1,s1,8
    800054bc:	ff349be3          	bne	s1,s3,800054b2 <sys_exec+0xc8>
  return ret;
    800054c0:	854a                	mv	a0,s2
    800054c2:	74ba                	ld	s1,424(sp)
    800054c4:	791a                	ld	s2,416(sp)
    800054c6:	69fa                	ld	s3,408(sp)
    800054c8:	6a5a                	ld	s4,400(sp)
    800054ca:	a031                	j	800054d6 <sys_exec+0xec>
  return -1;
    800054cc:	557d                	li	a0,-1
    800054ce:	74ba                	ld	s1,424(sp)
    800054d0:	791a                	ld	s2,416(sp)
    800054d2:	69fa                	ld	s3,408(sp)
    800054d4:	6a5a                	ld	s4,400(sp)
}
    800054d6:	70fa                	ld	ra,440(sp)
    800054d8:	745a                	ld	s0,432(sp)
    800054da:	6139                	addi	sp,sp,448
    800054dc:	8082                	ret

00000000800054de <sys_pipe>:

uint64
sys_pipe(void)
{
    800054de:	7139                	addi	sp,sp,-64
    800054e0:	fc06                	sd	ra,56(sp)
    800054e2:	f822                	sd	s0,48(sp)
    800054e4:	f426                	sd	s1,40(sp)
    800054e6:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800054e8:	d5efc0ef          	jal	80001a46 <myproc>
    800054ec:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800054ee:	fd840593          	addi	a1,s0,-40
    800054f2:	4501                	li	a0,0
    800054f4:	d3efd0ef          	jal	80002a32 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800054f8:	fc840593          	addi	a1,s0,-56
    800054fc:	fd040513          	addi	a0,s0,-48
    80005500:	852ff0ef          	jal	80004552 <pipealloc>
    return -1;
    80005504:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005506:	0a054463          	bltz	a0,800055ae <sys_pipe+0xd0>
  fd0 = -1;
    8000550a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000550e:	fd043503          	ld	a0,-48(s0)
    80005512:	f08ff0ef          	jal	80004c1a <fdalloc>
    80005516:	fca42223          	sw	a0,-60(s0)
    8000551a:	08054163          	bltz	a0,8000559c <sys_pipe+0xbe>
    8000551e:	fc843503          	ld	a0,-56(s0)
    80005522:	ef8ff0ef          	jal	80004c1a <fdalloc>
    80005526:	fca42023          	sw	a0,-64(s0)
    8000552a:	06054063          	bltz	a0,8000558a <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000552e:	4691                	li	a3,4
    80005530:	fc440613          	addi	a2,s0,-60
    80005534:	fd843583          	ld	a1,-40(s0)
    80005538:	68a8                	ld	a0,80(s1)
    8000553a:	8c2fc0ef          	jal	800015fc <copyout>
    8000553e:	00054e63          	bltz	a0,8000555a <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005542:	4691                	li	a3,4
    80005544:	fc040613          	addi	a2,s0,-64
    80005548:	fd843583          	ld	a1,-40(s0)
    8000554c:	0591                	addi	a1,a1,4
    8000554e:	68a8                	ld	a0,80(s1)
    80005550:	8acfc0ef          	jal	800015fc <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005554:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005556:	04055c63          	bgez	a0,800055ae <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    8000555a:	fc442783          	lw	a5,-60(s0)
    8000555e:	07e9                	addi	a5,a5,26
    80005560:	078e                	slli	a5,a5,0x3
    80005562:	97a6                	add	a5,a5,s1
    80005564:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005568:	fc042783          	lw	a5,-64(s0)
    8000556c:	07e9                	addi	a5,a5,26
    8000556e:	078e                	slli	a5,a5,0x3
    80005570:	94be                	add	s1,s1,a5
    80005572:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005576:	fd043503          	ld	a0,-48(s0)
    8000557a:	ccffe0ef          	jal	80004248 <fileclose>
    fileclose(wf);
    8000557e:	fc843503          	ld	a0,-56(s0)
    80005582:	cc7fe0ef          	jal	80004248 <fileclose>
    return -1;
    80005586:	57fd                	li	a5,-1
    80005588:	a01d                	j	800055ae <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000558a:	fc442783          	lw	a5,-60(s0)
    8000558e:	0007c763          	bltz	a5,8000559c <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005592:	07e9                	addi	a5,a5,26
    80005594:	078e                	slli	a5,a5,0x3
    80005596:	97a6                	add	a5,a5,s1
    80005598:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000559c:	fd043503          	ld	a0,-48(s0)
    800055a0:	ca9fe0ef          	jal	80004248 <fileclose>
    fileclose(wf);
    800055a4:	fc843503          	ld	a0,-56(s0)
    800055a8:	ca1fe0ef          	jal	80004248 <fileclose>
    return -1;
    800055ac:	57fd                	li	a5,-1
}
    800055ae:	853e                	mv	a0,a5
    800055b0:	70e2                	ld	ra,56(sp)
    800055b2:	7442                	ld	s0,48(sp)
    800055b4:	74a2                	ld	s1,40(sp)
    800055b6:	6121                	addi	sp,sp,64
    800055b8:	8082                	ret
    800055ba:	0000                	unimp
    800055bc:	0000                	unimp
	...

00000000800055c0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800055c0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800055c2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800055c4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    800055c6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    800055c8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800055ca:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800055cc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800055ce:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800055d0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800055d2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800055d4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800055d6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800055d8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800055da:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800055dc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800055de:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800055e0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800055e2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800055e4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800055e6:	ab6fd0ef          	jal	8000289c <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800055ea:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800055ec:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800055ee:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800055f0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800055f2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800055f4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800055f6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800055f8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800055fa:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800055fc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800055fe:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005600:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005602:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005604:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005606:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005608:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000560a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000560c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000560e:	10200073          	sret
	...

000000008000561e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000561e:	1141                	addi	sp,sp,-16
    80005620:	e422                	sd	s0,8(sp)
    80005622:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005624:	0c0007b7          	lui	a5,0xc000
    80005628:	4705                	li	a4,1
    8000562a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000562c:	0c0007b7          	lui	a5,0xc000
    80005630:	c3d8                	sw	a4,4(a5)
}
    80005632:	6422                	ld	s0,8(sp)
    80005634:	0141                	addi	sp,sp,16
    80005636:	8082                	ret

0000000080005638 <plicinithart>:

void
plicinithart(void)
{
    80005638:	1141                	addi	sp,sp,-16
    8000563a:	e406                	sd	ra,8(sp)
    8000563c:	e022                	sd	s0,0(sp)
    8000563e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005640:	bdafc0ef          	jal	80001a1a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005644:	0085171b          	slliw	a4,a0,0x8
    80005648:	0c0027b7          	lui	a5,0xc002
    8000564c:	97ba                	add	a5,a5,a4
    8000564e:	40200713          	li	a4,1026
    80005652:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005656:	00d5151b          	slliw	a0,a0,0xd
    8000565a:	0c2017b7          	lui	a5,0xc201
    8000565e:	97aa                	add	a5,a5,a0
    80005660:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005664:	60a2                	ld	ra,8(sp)
    80005666:	6402                	ld	s0,0(sp)
    80005668:	0141                	addi	sp,sp,16
    8000566a:	8082                	ret

000000008000566c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000566c:	1141                	addi	sp,sp,-16
    8000566e:	e406                	sd	ra,8(sp)
    80005670:	e022                	sd	s0,0(sp)
    80005672:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005674:	ba6fc0ef          	jal	80001a1a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005678:	00d5151b          	slliw	a0,a0,0xd
    8000567c:	0c2017b7          	lui	a5,0xc201
    80005680:	97aa                	add	a5,a5,a0
  return irq;
}
    80005682:	43c8                	lw	a0,4(a5)
    80005684:	60a2                	ld	ra,8(sp)
    80005686:	6402                	ld	s0,0(sp)
    80005688:	0141                	addi	sp,sp,16
    8000568a:	8082                	ret

000000008000568c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000568c:	1101                	addi	sp,sp,-32
    8000568e:	ec06                	sd	ra,24(sp)
    80005690:	e822                	sd	s0,16(sp)
    80005692:	e426                	sd	s1,8(sp)
    80005694:	1000                	addi	s0,sp,32
    80005696:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005698:	b82fc0ef          	jal	80001a1a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000569c:	00d5151b          	slliw	a0,a0,0xd
    800056a0:	0c2017b7          	lui	a5,0xc201
    800056a4:	97aa                	add	a5,a5,a0
    800056a6:	c3c4                	sw	s1,4(a5)
}
    800056a8:	60e2                	ld	ra,24(sp)
    800056aa:	6442                	ld	s0,16(sp)
    800056ac:	64a2                	ld	s1,8(sp)
    800056ae:	6105                	addi	sp,sp,32
    800056b0:	8082                	ret

00000000800056b2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800056b2:	1141                	addi	sp,sp,-16
    800056b4:	e406                	sd	ra,8(sp)
    800056b6:	e022                	sd	s0,0(sp)
    800056b8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800056ba:	479d                	li	a5,7
    800056bc:	04a7ca63          	blt	a5,a0,80005710 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800056c0:	0001b797          	auipc	a5,0x1b
    800056c4:	5d878793          	addi	a5,a5,1496 # 80020c98 <disk>
    800056c8:	97aa                	add	a5,a5,a0
    800056ca:	0187c783          	lbu	a5,24(a5)
    800056ce:	e7b9                	bnez	a5,8000571c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800056d0:	00451693          	slli	a3,a0,0x4
    800056d4:	0001b797          	auipc	a5,0x1b
    800056d8:	5c478793          	addi	a5,a5,1476 # 80020c98 <disk>
    800056dc:	6398                	ld	a4,0(a5)
    800056de:	9736                	add	a4,a4,a3
    800056e0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800056e4:	6398                	ld	a4,0(a5)
    800056e6:	9736                	add	a4,a4,a3
    800056e8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800056ec:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800056f0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800056f4:	97aa                	add	a5,a5,a0
    800056f6:	4705                	li	a4,1
    800056f8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800056fc:	0001b517          	auipc	a0,0x1b
    80005700:	5b450513          	addi	a0,a0,1460 # 80020cb0 <disk+0x18>
    80005704:	9fdfc0ef          	jal	80002100 <wakeup>
}
    80005708:	60a2                	ld	ra,8(sp)
    8000570a:	6402                	ld	s0,0(sp)
    8000570c:	0141                	addi	sp,sp,16
    8000570e:	8082                	ret
    panic("free_desc 1");
    80005710:	00002517          	auipc	a0,0x2
    80005714:	f2050513          	addi	a0,a0,-224 # 80007630 <etext+0x630>
    80005718:	8c8fb0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    8000571c:	00002517          	auipc	a0,0x2
    80005720:	f2450513          	addi	a0,a0,-220 # 80007640 <etext+0x640>
    80005724:	8bcfb0ef          	jal	800007e0 <panic>

0000000080005728 <virtio_disk_init>:
{
    80005728:	1101                	addi	sp,sp,-32
    8000572a:	ec06                	sd	ra,24(sp)
    8000572c:	e822                	sd	s0,16(sp)
    8000572e:	e426                	sd	s1,8(sp)
    80005730:	e04a                	sd	s2,0(sp)
    80005732:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005734:	00002597          	auipc	a1,0x2
    80005738:	f1c58593          	addi	a1,a1,-228 # 80007650 <etext+0x650>
    8000573c:	0001b517          	auipc	a0,0x1b
    80005740:	68450513          	addi	a0,a0,1668 # 80020dc0 <disk+0x128>
    80005744:	c0afb0ef          	jal	80000b4e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005748:	100017b7          	lui	a5,0x10001
    8000574c:	4398                	lw	a4,0(a5)
    8000574e:	2701                	sext.w	a4,a4
    80005750:	747277b7          	lui	a5,0x74727
    80005754:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005758:	18f71063          	bne	a4,a5,800058d8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000575c:	100017b7          	lui	a5,0x10001
    80005760:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005762:	439c                	lw	a5,0(a5)
    80005764:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005766:	4709                	li	a4,2
    80005768:	16e79863          	bne	a5,a4,800058d8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000576c:	100017b7          	lui	a5,0x10001
    80005770:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005772:	439c                	lw	a5,0(a5)
    80005774:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005776:	16e79163          	bne	a5,a4,800058d8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000577a:	100017b7          	lui	a5,0x10001
    8000577e:	47d8                	lw	a4,12(a5)
    80005780:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005782:	554d47b7          	lui	a5,0x554d4
    80005786:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000578a:	14f71763          	bne	a4,a5,800058d8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000578e:	100017b7          	lui	a5,0x10001
    80005792:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005796:	4705                	li	a4,1
    80005798:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000579a:	470d                	li	a4,3
    8000579c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000579e:	10001737          	lui	a4,0x10001
    800057a2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800057a4:	c7ffe737          	lui	a4,0xc7ffe
    800057a8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd987>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800057ac:	8ef9                	and	a3,a3,a4
    800057ae:	10001737          	lui	a4,0x10001
    800057b2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057b4:	472d                	li	a4,11
    800057b6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057b8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800057bc:	439c                	lw	a5,0(a5)
    800057be:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800057c2:	8ba1                	andi	a5,a5,8
    800057c4:	12078063          	beqz	a5,800058e4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800057c8:	100017b7          	lui	a5,0x10001
    800057cc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800057d0:	100017b7          	lui	a5,0x10001
    800057d4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800057d8:	439c                	lw	a5,0(a5)
    800057da:	2781                	sext.w	a5,a5
    800057dc:	10079a63          	bnez	a5,800058f0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800057e0:	100017b7          	lui	a5,0x10001
    800057e4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800057e8:	439c                	lw	a5,0(a5)
    800057ea:	2781                	sext.w	a5,a5
  if(max == 0)
    800057ec:	10078863          	beqz	a5,800058fc <virtio_disk_init+0x1d4>
  if(max < NUM)
    800057f0:	471d                	li	a4,7
    800057f2:	10f77b63          	bgeu	a4,a5,80005908 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    800057f6:	b08fb0ef          	jal	80000afe <kalloc>
    800057fa:	0001b497          	auipc	s1,0x1b
    800057fe:	49e48493          	addi	s1,s1,1182 # 80020c98 <disk>
    80005802:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005804:	afafb0ef          	jal	80000afe <kalloc>
    80005808:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000580a:	af4fb0ef          	jal	80000afe <kalloc>
    8000580e:	87aa                	mv	a5,a0
    80005810:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005812:	6088                	ld	a0,0(s1)
    80005814:	10050063          	beqz	a0,80005914 <virtio_disk_init+0x1ec>
    80005818:	0001b717          	auipc	a4,0x1b
    8000581c:	48873703          	ld	a4,1160(a4) # 80020ca0 <disk+0x8>
    80005820:	0e070a63          	beqz	a4,80005914 <virtio_disk_init+0x1ec>
    80005824:	0e078863          	beqz	a5,80005914 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005828:	6605                	lui	a2,0x1
    8000582a:	4581                	li	a1,0
    8000582c:	c76fb0ef          	jal	80000ca2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005830:	0001b497          	auipc	s1,0x1b
    80005834:	46848493          	addi	s1,s1,1128 # 80020c98 <disk>
    80005838:	6605                	lui	a2,0x1
    8000583a:	4581                	li	a1,0
    8000583c:	6488                	ld	a0,8(s1)
    8000583e:	c64fb0ef          	jal	80000ca2 <memset>
  memset(disk.used, 0, PGSIZE);
    80005842:	6605                	lui	a2,0x1
    80005844:	4581                	li	a1,0
    80005846:	6888                	ld	a0,16(s1)
    80005848:	c5afb0ef          	jal	80000ca2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000584c:	100017b7          	lui	a5,0x10001
    80005850:	4721                	li	a4,8
    80005852:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005854:	4098                	lw	a4,0(s1)
    80005856:	100017b7          	lui	a5,0x10001
    8000585a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000585e:	40d8                	lw	a4,4(s1)
    80005860:	100017b7          	lui	a5,0x10001
    80005864:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005868:	649c                	ld	a5,8(s1)
    8000586a:	0007869b          	sext.w	a3,a5
    8000586e:	10001737          	lui	a4,0x10001
    80005872:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005876:	9781                	srai	a5,a5,0x20
    80005878:	10001737          	lui	a4,0x10001
    8000587c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005880:	689c                	ld	a5,16(s1)
    80005882:	0007869b          	sext.w	a3,a5
    80005886:	10001737          	lui	a4,0x10001
    8000588a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000588e:	9781                	srai	a5,a5,0x20
    80005890:	10001737          	lui	a4,0x10001
    80005894:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005898:	10001737          	lui	a4,0x10001
    8000589c:	4785                	li	a5,1
    8000589e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800058a0:	00f48c23          	sb	a5,24(s1)
    800058a4:	00f48ca3          	sb	a5,25(s1)
    800058a8:	00f48d23          	sb	a5,26(s1)
    800058ac:	00f48da3          	sb	a5,27(s1)
    800058b0:	00f48e23          	sb	a5,28(s1)
    800058b4:	00f48ea3          	sb	a5,29(s1)
    800058b8:	00f48f23          	sb	a5,30(s1)
    800058bc:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800058c0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800058c4:	100017b7          	lui	a5,0x10001
    800058c8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    800058cc:	60e2                	ld	ra,24(sp)
    800058ce:	6442                	ld	s0,16(sp)
    800058d0:	64a2                	ld	s1,8(sp)
    800058d2:	6902                	ld	s2,0(sp)
    800058d4:	6105                	addi	sp,sp,32
    800058d6:	8082                	ret
    panic("could not find virtio disk");
    800058d8:	00002517          	auipc	a0,0x2
    800058dc:	d8850513          	addi	a0,a0,-632 # 80007660 <etext+0x660>
    800058e0:	f01fa0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    800058e4:	00002517          	auipc	a0,0x2
    800058e8:	d9c50513          	addi	a0,a0,-612 # 80007680 <etext+0x680>
    800058ec:	ef5fa0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    800058f0:	00002517          	auipc	a0,0x2
    800058f4:	db050513          	addi	a0,a0,-592 # 800076a0 <etext+0x6a0>
    800058f8:	ee9fa0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    800058fc:	00002517          	auipc	a0,0x2
    80005900:	dc450513          	addi	a0,a0,-572 # 800076c0 <etext+0x6c0>
    80005904:	eddfa0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    80005908:	00002517          	auipc	a0,0x2
    8000590c:	dd850513          	addi	a0,a0,-552 # 800076e0 <etext+0x6e0>
    80005910:	ed1fa0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    80005914:	00002517          	auipc	a0,0x2
    80005918:	dec50513          	addi	a0,a0,-532 # 80007700 <etext+0x700>
    8000591c:	ec5fa0ef          	jal	800007e0 <panic>

0000000080005920 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005920:	7159                	addi	sp,sp,-112
    80005922:	f486                	sd	ra,104(sp)
    80005924:	f0a2                	sd	s0,96(sp)
    80005926:	eca6                	sd	s1,88(sp)
    80005928:	e8ca                	sd	s2,80(sp)
    8000592a:	e4ce                	sd	s3,72(sp)
    8000592c:	e0d2                	sd	s4,64(sp)
    8000592e:	fc56                	sd	s5,56(sp)
    80005930:	f85a                	sd	s6,48(sp)
    80005932:	f45e                	sd	s7,40(sp)
    80005934:	f062                	sd	s8,32(sp)
    80005936:	ec66                	sd	s9,24(sp)
    80005938:	1880                	addi	s0,sp,112
    8000593a:	8a2a                	mv	s4,a0
    8000593c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000593e:	00c52c83          	lw	s9,12(a0)
    80005942:	001c9c9b          	slliw	s9,s9,0x1
    80005946:	1c82                	slli	s9,s9,0x20
    80005948:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000594c:	0001b517          	auipc	a0,0x1b
    80005950:	47450513          	addi	a0,a0,1140 # 80020dc0 <disk+0x128>
    80005954:	a7afb0ef          	jal	80000bce <acquire>
  for(int i = 0; i < 3; i++){
    80005958:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000595a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000595c:	0001bb17          	auipc	s6,0x1b
    80005960:	33cb0b13          	addi	s6,s6,828 # 80020c98 <disk>
  for(int i = 0; i < 3; i++){
    80005964:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005966:	0001bc17          	auipc	s8,0x1b
    8000596a:	45ac0c13          	addi	s8,s8,1114 # 80020dc0 <disk+0x128>
    8000596e:	a8b9                	j	800059cc <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005970:	00fb0733          	add	a4,s6,a5
    80005974:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005978:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000597a:	0207c563          	bltz	a5,800059a4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000597e:	2905                	addiw	s2,s2,1
    80005980:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005982:	05590963          	beq	s2,s5,800059d4 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005986:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005988:	0001b717          	auipc	a4,0x1b
    8000598c:	31070713          	addi	a4,a4,784 # 80020c98 <disk>
    80005990:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005992:	01874683          	lbu	a3,24(a4)
    80005996:	fee9                	bnez	a3,80005970 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005998:	2785                	addiw	a5,a5,1
    8000599a:	0705                	addi	a4,a4,1
    8000599c:	fe979be3          	bne	a5,s1,80005992 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    800059a0:	57fd                	li	a5,-1
    800059a2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800059a4:	01205d63          	blez	s2,800059be <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800059a8:	f9042503          	lw	a0,-112(s0)
    800059ac:	d07ff0ef          	jal	800056b2 <free_desc>
      for(int j = 0; j < i; j++)
    800059b0:	4785                	li	a5,1
    800059b2:	0127d663          	bge	a5,s2,800059be <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800059b6:	f9442503          	lw	a0,-108(s0)
    800059ba:	cf9ff0ef          	jal	800056b2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800059be:	85e2                	mv	a1,s8
    800059c0:	0001b517          	auipc	a0,0x1b
    800059c4:	2f050513          	addi	a0,a0,752 # 80020cb0 <disk+0x18>
    800059c8:	eecfc0ef          	jal	800020b4 <sleep>
  for(int i = 0; i < 3; i++){
    800059cc:	f9040613          	addi	a2,s0,-112
    800059d0:	894e                	mv	s2,s3
    800059d2:	bf55                	j	80005986 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800059d4:	f9042503          	lw	a0,-112(s0)
    800059d8:	00451693          	slli	a3,a0,0x4

  if(write)
    800059dc:	0001b797          	auipc	a5,0x1b
    800059e0:	2bc78793          	addi	a5,a5,700 # 80020c98 <disk>
    800059e4:	00a50713          	addi	a4,a0,10
    800059e8:	0712                	slli	a4,a4,0x4
    800059ea:	973e                	add	a4,a4,a5
    800059ec:	01703633          	snez	a2,s7
    800059f0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800059f2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800059f6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800059fa:	6398                	ld	a4,0(a5)
    800059fc:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800059fe:	0a868613          	addi	a2,a3,168
    80005a02:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005a04:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005a06:	6390                	ld	a2,0(a5)
    80005a08:	00d605b3          	add	a1,a2,a3
    80005a0c:	4741                	li	a4,16
    80005a0e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005a10:	4805                	li	a6,1
    80005a12:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005a16:	f9442703          	lw	a4,-108(s0)
    80005a1a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005a1e:	0712                	slli	a4,a4,0x4
    80005a20:	963a                	add	a2,a2,a4
    80005a22:	058a0593          	addi	a1,s4,88
    80005a26:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005a28:	0007b883          	ld	a7,0(a5)
    80005a2c:	9746                	add	a4,a4,a7
    80005a2e:	40000613          	li	a2,1024
    80005a32:	c710                	sw	a2,8(a4)
  if(write)
    80005a34:	001bb613          	seqz	a2,s7
    80005a38:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005a3c:	00166613          	ori	a2,a2,1
    80005a40:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005a44:	f9842583          	lw	a1,-104(s0)
    80005a48:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005a4c:	00250613          	addi	a2,a0,2
    80005a50:	0612                	slli	a2,a2,0x4
    80005a52:	963e                	add	a2,a2,a5
    80005a54:	577d                	li	a4,-1
    80005a56:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005a5a:	0592                	slli	a1,a1,0x4
    80005a5c:	98ae                	add	a7,a7,a1
    80005a5e:	03068713          	addi	a4,a3,48
    80005a62:	973e                	add	a4,a4,a5
    80005a64:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005a68:	6398                	ld	a4,0(a5)
    80005a6a:	972e                	add	a4,a4,a1
    80005a6c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005a70:	4689                	li	a3,2
    80005a72:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005a76:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005a7a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005a7e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005a82:	6794                	ld	a3,8(a5)
    80005a84:	0026d703          	lhu	a4,2(a3)
    80005a88:	8b1d                	andi	a4,a4,7
    80005a8a:	0706                	slli	a4,a4,0x1
    80005a8c:	96ba                	add	a3,a3,a4
    80005a8e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005a92:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005a96:	6798                	ld	a4,8(a5)
    80005a98:	00275783          	lhu	a5,2(a4)
    80005a9c:	2785                	addiw	a5,a5,1
    80005a9e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005aa2:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005aa6:	100017b7          	lui	a5,0x10001
    80005aaa:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005aae:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005ab2:	0001b917          	auipc	s2,0x1b
    80005ab6:	30e90913          	addi	s2,s2,782 # 80020dc0 <disk+0x128>
  while(b->disk == 1) {
    80005aba:	4485                	li	s1,1
    80005abc:	01079a63          	bne	a5,a6,80005ad0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005ac0:	85ca                	mv	a1,s2
    80005ac2:	8552                	mv	a0,s4
    80005ac4:	df0fc0ef          	jal	800020b4 <sleep>
  while(b->disk == 1) {
    80005ac8:	004a2783          	lw	a5,4(s4)
    80005acc:	fe978ae3          	beq	a5,s1,80005ac0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005ad0:	f9042903          	lw	s2,-112(s0)
    80005ad4:	00290713          	addi	a4,s2,2
    80005ad8:	0712                	slli	a4,a4,0x4
    80005ada:	0001b797          	auipc	a5,0x1b
    80005ade:	1be78793          	addi	a5,a5,446 # 80020c98 <disk>
    80005ae2:	97ba                	add	a5,a5,a4
    80005ae4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005ae8:	0001b997          	auipc	s3,0x1b
    80005aec:	1b098993          	addi	s3,s3,432 # 80020c98 <disk>
    80005af0:	00491713          	slli	a4,s2,0x4
    80005af4:	0009b783          	ld	a5,0(s3)
    80005af8:	97ba                	add	a5,a5,a4
    80005afa:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005afe:	854a                	mv	a0,s2
    80005b00:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005b04:	bafff0ef          	jal	800056b2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005b08:	8885                	andi	s1,s1,1
    80005b0a:	f0fd                	bnez	s1,80005af0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005b0c:	0001b517          	auipc	a0,0x1b
    80005b10:	2b450513          	addi	a0,a0,692 # 80020dc0 <disk+0x128>
    80005b14:	952fb0ef          	jal	80000c66 <release>
}
    80005b18:	70a6                	ld	ra,104(sp)
    80005b1a:	7406                	ld	s0,96(sp)
    80005b1c:	64e6                	ld	s1,88(sp)
    80005b1e:	6946                	ld	s2,80(sp)
    80005b20:	69a6                	ld	s3,72(sp)
    80005b22:	6a06                	ld	s4,64(sp)
    80005b24:	7ae2                	ld	s5,56(sp)
    80005b26:	7b42                	ld	s6,48(sp)
    80005b28:	7ba2                	ld	s7,40(sp)
    80005b2a:	7c02                	ld	s8,32(sp)
    80005b2c:	6ce2                	ld	s9,24(sp)
    80005b2e:	6165                	addi	sp,sp,112
    80005b30:	8082                	ret

0000000080005b32 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005b32:	1101                	addi	sp,sp,-32
    80005b34:	ec06                	sd	ra,24(sp)
    80005b36:	e822                	sd	s0,16(sp)
    80005b38:	e426                	sd	s1,8(sp)
    80005b3a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005b3c:	0001b497          	auipc	s1,0x1b
    80005b40:	15c48493          	addi	s1,s1,348 # 80020c98 <disk>
    80005b44:	0001b517          	auipc	a0,0x1b
    80005b48:	27c50513          	addi	a0,a0,636 # 80020dc0 <disk+0x128>
    80005b4c:	882fb0ef          	jal	80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005b50:	100017b7          	lui	a5,0x10001
    80005b54:	53b8                	lw	a4,96(a5)
    80005b56:	8b0d                	andi	a4,a4,3
    80005b58:	100017b7          	lui	a5,0x10001
    80005b5c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80005b5e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005b62:	689c                	ld	a5,16(s1)
    80005b64:	0204d703          	lhu	a4,32(s1)
    80005b68:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005b6c:	04f70663          	beq	a4,a5,80005bb8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005b70:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005b74:	6898                	ld	a4,16(s1)
    80005b76:	0204d783          	lhu	a5,32(s1)
    80005b7a:	8b9d                	andi	a5,a5,7
    80005b7c:	078e                	slli	a5,a5,0x3
    80005b7e:	97ba                	add	a5,a5,a4
    80005b80:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005b82:	00278713          	addi	a4,a5,2
    80005b86:	0712                	slli	a4,a4,0x4
    80005b88:	9726                	add	a4,a4,s1
    80005b8a:	01074703          	lbu	a4,16(a4)
    80005b8e:	e321                	bnez	a4,80005bce <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005b90:	0789                	addi	a5,a5,2
    80005b92:	0792                	slli	a5,a5,0x4
    80005b94:	97a6                	add	a5,a5,s1
    80005b96:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005b98:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005b9c:	d64fc0ef          	jal	80002100 <wakeup>

    disk.used_idx += 1;
    80005ba0:	0204d783          	lhu	a5,32(s1)
    80005ba4:	2785                	addiw	a5,a5,1
    80005ba6:	17c2                	slli	a5,a5,0x30
    80005ba8:	93c1                	srli	a5,a5,0x30
    80005baa:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005bae:	6898                	ld	a4,16(s1)
    80005bb0:	00275703          	lhu	a4,2(a4)
    80005bb4:	faf71ee3          	bne	a4,a5,80005b70 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005bb8:	0001b517          	auipc	a0,0x1b
    80005bbc:	20850513          	addi	a0,a0,520 # 80020dc0 <disk+0x128>
    80005bc0:	8a6fb0ef          	jal	80000c66 <release>
}
    80005bc4:	60e2                	ld	ra,24(sp)
    80005bc6:	6442                	ld	s0,16(sp)
    80005bc8:	64a2                	ld	s1,8(sp)
    80005bca:	6105                	addi	sp,sp,32
    80005bcc:	8082                	ret
      panic("virtio_disk_intr status");
    80005bce:	00002517          	auipc	a0,0x2
    80005bd2:	b4a50513          	addi	a0,a0,-1206 # 80007718 <etext+0x718>
    80005bd6:	c0bfa0ef          	jal	800007e0 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
