
user/_uthread:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <thread_init>:
struct thread *current_thread;
extern void thread_switch(struct context*, struct context*);

void 
thread_init(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  current_thread = &all_thread[0];
   6:	00002797          	auipc	a5,0x2
   a:	02a78793          	addi	a5,a5,42 # 2030 <all_thread>
   e:	00002717          	auipc	a4,0x2
  12:	00f73523          	sd	a5,10(a4) # 2018 <current_thread>
  current_thread->state = RUNNING;
  16:	4785                	li	a5,1
  18:	00004717          	auipc	a4,0x4
  1c:	00f72c23          	sw	a5,24(a4) # 4030 <all_thread+0x2000>
}
  20:	6422                	ld	s0,8(sp)
  22:	0141                	addi	sp,sp,16
  24:	8082                	ret

0000000000000026 <thread_schedule>:

void 
thread_schedule(void)
{
  26:	1101                	addi	sp,sp,-32
  28:	ec06                	sd	ra,24(sp)
  2a:	e822                	sd	s0,16(sp)
  2c:	1000                	addi	s0,sp,32
  int i, next = -1;
  int indx = current_thread - all_thread;
  2e:	00002517          	auipc	a0,0x2
  32:	fea53503          	ld	a0,-22(a0) # 2018 <current_thread>
  36:	00002717          	auipc	a4,0x2
  3a:	ffa70713          	addi	a4,a4,-6 # 2030 <all_thread>
  3e:	40e50733          	sub	a4,a0,a4
  42:	870d                	srai	a4,a4,0x3
  44:	006887b7          	lui	a5,0x688
  48:	83d78793          	addi	a5,a5,-1987 # 68783d <base+0x67d62d>
  4c:	07ba                	slli	a5,a5,0xe
  4e:	6b778793          	addi	a5,a5,1719
  52:	07b2                	slli	a5,a5,0xc
  54:	d2778793          	addi	a5,a5,-729
  58:	07b2                	slli	a5,a5,0xc
  5a:	aef78793          	addi	a5,a5,-1297
  5e:	02f7073b          	mulw	a4,a4,a5
  // find a runnable thread
  for (i = indx; i < indx + MAX_THREAD ; i++) {
  62:	00370e1b          	addiw	t3,a4,3
    if ((all_thread[i % (MAX_THREAD - 1) + 1].state == RUNNABLE)) {
  66:	430d                	li	t1,3
  68:	00002897          	auipc	a7,0x2
  6c:	fc888893          	addi	a7,a7,-56 # 2030 <all_thread>
  70:	6809                	lui	a6,0x2
  72:	6609                	lui	a2,0x2
  74:	07860613          	addi	a2,a2,120 # 2078 <all_thread+0x48>
  78:	4589                	li	a1,2
  7a:	026766bb          	remw	a3,a4,t1
  7e:	2685                	addiw	a3,a3,1
  80:	02c687b3          	mul	a5,a3,a2
  84:	97c6                	add	a5,a5,a7
  86:	97c2                	add	a5,a5,a6
  88:	439c                	lw	a5,0(a5)
  8a:	04b78663          	beq	a5,a1,d6 <thread_schedule+0xb0>
  for (i = indx; i < indx + MAX_THREAD ; i++) {
  8e:	2705                	addiw	a4,a4,1
  90:	feee55e3          	bge	t3,a4,7a <thread_schedule+0x54>
  94:	e426                	sd	s1,8(sp)
    }
  }

  // no runnable threads, nothing to schedule right now
  if (next == -1) {
      printf("thread_schedule: no runnable threads\n");
  96:	00001517          	auipc	a0,0x1
  9a:	d0a50513          	addi	a0,a0,-758 # da0 <malloc+0xfc>
  9e:	353000ef          	jal	bf0 <printf>
      all_thread->state = RUNNING;
  a2:	4785                	li	a5,1
  a4:	00004717          	auipc	a4,0x4
  a8:	f8f72623          	sw	a5,-116(a4) # 4030 <all_thread+0x2000>
      thread_switch(&current_thread->context, &all_thread->context);
  ac:	00002497          	auipc	s1,0x2
  b0:	f6c48493          	addi	s1,s1,-148 # 2018 <current_thread>
  b4:	6088                	ld	a0,0(s1)
  b6:	6789                	lui	a5,0x2
  b8:	07a1                	addi	a5,a5,8 # 2008 <a_n>
  ba:	00004597          	auipc	a1,0x4
  be:	f7e58593          	addi	a1,a1,-130 # 4038 <all_thread+0x2008>
  c2:	953e                	add	a0,a0,a5
  c4:	406000ef          	jal	4ca <thread_switch>
      current_thread = all_thread;
  c8:	00002797          	auipc	a5,0x2
  cc:	f6878793          	addi	a5,a5,-152 # 2030 <all_thread>
  d0:	e09c                	sd	a5,0(s1)
      return;
  d2:	64a2                	ld	s1,8(sp)
  d4:	a08d                	j	136 <thread_schedule+0x110>
  if (next == -1) {
  d6:	577d                	li	a4,-1
  d8:	06e68363          	beq	a3,a4,13e <thread_schedule+0x118>
  }

  struct thread *told = current_thread;
  struct thread *tnext =  &all_thread[next];
  dc:	6589                	lui	a1,0x2
  de:	07858593          	addi	a1,a1,120 # 2078 <all_thread+0x48>
  e2:	02b685b3          	mul	a1,a3,a1
  e6:	00002717          	auipc	a4,0x2
  ea:	f4a70713          	addi	a4,a4,-182 # 2030 <all_thread>
  ee:	972e                	add	a4,a4,a1

  told->state = (told->state == RUNNING) ? RUNNABLE : told->state;
  f0:	6609                	lui	a2,0x2
  f2:	962a                	add	a2,a2,a0
  f4:	4210                	lw	a2,0(a2)
  f6:	4805                	li	a6,1
  f8:	05060563          	beq	a2,a6,142 <thread_schedule+0x11c>
  fc:	6789                	lui	a5,0x2
  fe:	00f50833          	add	a6,a0,a5
 102:	00c82023          	sw	a2,0(a6) # 2000 <c_n>
  tnext->state = RUNNING;
 106:	00002817          	auipc	a6,0x2
 10a:	f2a80813          	addi	a6,a6,-214 # 2030 <all_thread>
 10e:	6609                	lui	a2,0x2
 110:	07860613          	addi	a2,a2,120 # 2078 <all_thread+0x48>
 114:	02c686b3          	mul	a3,a3,a2
 118:	96c2                	add	a3,a3,a6
 11a:	97b6                	add	a5,a5,a3
 11c:	4685                	li	a3,1
 11e:	c394                	sw	a3,0(a5)
  current_thread = tnext;
 120:	00002797          	auipc	a5,0x2
 124:	eee7bc23          	sd	a4,-264(a5) # 2018 <current_thread>
  thread_switch(&told->context, &tnext->context);
 128:	6789                	lui	a5,0x2
 12a:	07a1                	addi	a5,a5,8 # 2008 <a_n>
 12c:	95be                	add	a1,a1,a5
 12e:	95c2                	add	a1,a1,a6
 130:	953e                	add	a0,a0,a5
 132:	398000ef          	jal	4ca <thread_switch>
}
 136:	60e2                	ld	ra,24(sp)
 138:	6442                	ld	s0,16(sp)
 13a:	6105                	addi	sp,sp,32
 13c:	8082                	ret
 13e:	e426                	sd	s1,8(sp)
 140:	bf99                	j	96 <thread_schedule+0x70>
  told->state = (told->state == RUNNING) ? RUNNABLE : told->state;
 142:	863e                	mv	a2,a5
 144:	bf65                	j	fc <thread_schedule+0xd6>

0000000000000146 <thread_create>:

void 
thread_create(void (*func)())
{
 146:	7179                	addi	sp,sp,-48
 148:	f406                	sd	ra,40(sp)
 14a:	f022                	sd	s0,32(sp)
 14c:	e84a                	sd	s2,16(sp)
 14e:	1800                	addi	s0,sp,48
 150:	892a                	mv	s2,a0
  int tid;

  for (tid = 0; tid < MAX_THREAD; tid++) {
 152:	00004717          	auipc	a4,0x4
 156:	ede70713          	addi	a4,a4,-290 # 4030 <all_thread+0x2000>
 15a:	4781                	li	a5,0
 15c:	6609                	lui	a2,0x2
 15e:	07860613          	addi	a2,a2,120 # 2078 <all_thread+0x48>
 162:	4591                	li	a1,4
    if (all_thread[tid].state == FREE) break;
 164:	4314                	lw	a3,0(a4)
 166:	ce81                	beqz	a3,17e <thread_create+0x38>
  for (tid = 0; tid < MAX_THREAD; tid++) {
 168:	2785                	addiw	a5,a5,1
 16a:	9732                	add	a4,a4,a2
 16c:	feb79ce3          	bne	a5,a1,164 <thread_create+0x1e>
  }

  if (tid == MAX_THREAD) {
    printf("create_thread: no free thread\n");
 170:	00001517          	auipc	a0,0x1
 174:	c6050513          	addi	a0,a0,-928 # dd0 <malloc+0x12c>
 178:	279000ef          	jal	bf0 <printf>
    return;
 17c:	a0b1                	j	1c8 <thread_create+0x82>
 17e:	ec26                	sd	s1,24(sp)
 180:	e44e                	sd	s3,8(sp)
 182:	e052                	sd	s4,0(sp)

  struct thread *t = &all_thread[tid];

  // allocate space to the context
  int sz = sizeof(struct context);
  memset(&t->context, 0, sz);
 184:	6a09                	lui	s4,0x2
 186:	6709                	lui	a4,0x2
 188:	07870713          	addi	a4,a4,120 # 2078 <all_thread+0x48>
 18c:	02e784b3          	mul	s1,a5,a4
 190:	6789                	lui	a5,0x2
 192:	07a1                	addi	a5,a5,8 # 2008 <a_n>
 194:	00f48533          	add	a0,s1,a5
 198:	00002997          	auipc	s3,0x2
 19c:	e9898993          	addi	s3,s3,-360 # 2030 <all_thread>
 1a0:	07000613          	li	a2,112
 1a4:	4581                	li	a1,0
 1a6:	954e                	add	a0,a0,s3
 1a8:	40e000ef          	jal	5b6 <memset>

  // allocate space to the stack
  uint64 sp = (uint64)(t->stack + STACK_SIZE);
  t->context.sp = sp;
 1ac:	00998733          	add	a4,s3,s1
 1b0:	9752                	add	a4,a4,s4
  uint64 sp = (uint64)(t->stack + STACK_SIZE);
 1b2:	014487b3          	add	a5,s1,s4
 1b6:	97ce                	add	a5,a5,s3
  t->context.sp = sp;
 1b8:	eb1c                	sd	a5,16(a4)

  // runnable
  t->context.ra = (uint64)func;
 1ba:	01273423          	sd	s2,8(a4)
  t->state = RUNNABLE;
 1be:	4789                	li	a5,2
 1c0:	c31c                	sw	a5,0(a4)
 1c2:	64e2                	ld	s1,24(sp)
 1c4:	69a2                	ld	s3,8(sp)
 1c6:	6a02                	ld	s4,0(sp)
}
 1c8:	70a2                	ld	ra,40(sp)
 1ca:	7402                	ld	s0,32(sp)
 1cc:	6942                	ld	s2,16(sp)
 1ce:	6145                	addi	sp,sp,48
 1d0:	8082                	ret

00000000000001d2 <thread_yield>:

void 
thread_yield(void)
{
 1d2:	1141                	addi	sp,sp,-16
 1d4:	e406                	sd	ra,8(sp)
 1d6:	e022                	sd	s0,0(sp)
 1d8:	0800                	addi	s0,sp,16
  if (current_thread->state == RUNNING) current_thread->state = RUNNABLE;
 1da:	00002717          	auipc	a4,0x2
 1de:	e3e73703          	ld	a4,-450(a4) # 2018 <current_thread>
 1e2:	6789                	lui	a5,0x2
 1e4:	97ba                	add	a5,a5,a4
 1e6:	4394                	lw	a3,0(a5)
 1e8:	4785                	li	a5,1
 1ea:	00f68863          	beq	a3,a5,1fa <thread_yield+0x28>
  thread_schedule();
 1ee:	e39ff0ef          	jal	26 <thread_schedule>
}
 1f2:	60a2                	ld	ra,8(sp)
 1f4:	6402                	ld	s0,0(sp)
 1f6:	0141                	addi	sp,sp,16
 1f8:	8082                	ret
  if (current_thread->state == RUNNING) current_thread->state = RUNNABLE;
 1fa:	6789                	lui	a5,0x2
 1fc:	973e                	add	a4,a4,a5
 1fe:	4789                	li	a5,2
 200:	c31c                	sw	a5,0(a4)
 202:	b7f5                	j	1ee <thread_yield+0x1c>

0000000000000204 <thread_a>:
volatile int a_started, b_started, c_started;
volatile int a_n, b_n, c_n;

void 
thread_a(void)
{
 204:	7179                	addi	sp,sp,-48
 206:	f406                	sd	ra,40(sp)
 208:	f022                	sd	s0,32(sp)
 20a:	ec26                	sd	s1,24(sp)
 20c:	e84a                	sd	s2,16(sp)
 20e:	e44e                	sd	s3,8(sp)
 210:	1800                	addi	s0,sp,48
  a_started = 1;
 212:	4785                	li	a5,1
 214:	00002717          	auipc	a4,0x2
 218:	e0f72023          	sw	a5,-512(a4) # 2014 <a_started>
  printf("thread_a started\n");
 21c:	00001517          	auipc	a0,0x1
 220:	bd450513          	addi	a0,a0,-1068 # df0 <malloc+0x14c>
 224:	1cd000ef          	jal	bf0 <printf>
  while (!(a_started && b_started && c_started)) {
 228:	00002497          	auipc	s1,0x2
 22c:	dec48493          	addi	s1,s1,-532 # 2014 <a_started>
 230:	00002917          	auipc	s2,0x2
 234:	de090913          	addi	s2,s2,-544 # 2010 <b_started>
 238:	00002997          	auipc	s3,0x2
 23c:	dd498993          	addi	s3,s3,-556 # 200c <c_started>
 240:	a019                	j	246 <thread_a+0x42>
    thread_yield();
 242:	f91ff0ef          	jal	1d2 <thread_yield>
  while (!(a_started && b_started && c_started)) {
 246:	409c                	lw	a5,0(s1)
 248:	2781                	sext.w	a5,a5
 24a:	dfe5                	beqz	a5,242 <thread_a+0x3e>
 24c:	00092783          	lw	a5,0(s2)
 250:	2781                	sext.w	a5,a5
 252:	dbe5                	beqz	a5,242 <thread_a+0x3e>
 254:	0009a783          	lw	a5,0(s3)
 258:	2781                	sext.w	a5,a5
 25a:	d7e5                	beqz	a5,242 <thread_a+0x3e>
  }

  for (a_n = 0; a_n < 100; a_n++) {
 25c:	00002797          	auipc	a5,0x2
 260:	dac78793          	addi	a5,a5,-596 # 2008 <a_n>
 264:	0007a023          	sw	zero,0(a5)
 268:	439c                	lw	a5,0(a5)
 26a:	2781                	sext.w	a5,a5
 26c:	06300713          	li	a4,99
 270:	02f74963          	blt	a4,a5,2a2 <thread_a+0x9e>
    printf("thread_a %d\n", a_n);
 274:	00002497          	auipc	s1,0x2
 278:	d9448493          	addi	s1,s1,-620 # 2008 <a_n>
 27c:	00001997          	auipc	s3,0x1
 280:	b8c98993          	addi	s3,s3,-1140 # e08 <malloc+0x164>
  for (a_n = 0; a_n < 100; a_n++) {
 284:	06300913          	li	s2,99
    printf("thread_a %d\n", a_n);
 288:	408c                	lw	a1,0(s1)
 28a:	854e                	mv	a0,s3
 28c:	165000ef          	jal	bf0 <printf>
    // let others run
    thread_yield();
 290:	f43ff0ef          	jal	1d2 <thread_yield>
  for (a_n = 0; a_n < 100; a_n++) {
 294:	409c                	lw	a5,0(s1)
 296:	2785                	addiw	a5,a5,1
 298:	c09c                	sw	a5,0(s1)
 29a:	409c                	lw	a5,0(s1)
 29c:	2781                	sext.w	a5,a5
 29e:	fef955e3          	bge	s2,a5,288 <thread_a+0x84>
  }
  current_thread->state = FREE;
 2a2:	00002797          	auipc	a5,0x2
 2a6:	d767b783          	ld	a5,-650(a5) # 2018 <current_thread>
 2aa:	6709                	lui	a4,0x2
 2ac:	97ba                	add	a5,a5,a4
 2ae:	0007a023          	sw	zero,0(a5)
  printf("thread_a: exit after 100\n");
 2b2:	00001517          	auipc	a0,0x1
 2b6:	b6650513          	addi	a0,a0,-1178 # e18 <malloc+0x174>
 2ba:	137000ef          	jal	bf0 <printf>
  thread_schedule();
 2be:	d69ff0ef          	jal	26 <thread_schedule>
}
 2c2:	70a2                	ld	ra,40(sp)
 2c4:	7402                	ld	s0,32(sp)
 2c6:	64e2                	ld	s1,24(sp)
 2c8:	6942                	ld	s2,16(sp)
 2ca:	69a2                	ld	s3,8(sp)
 2cc:	6145                	addi	sp,sp,48
 2ce:	8082                	ret

00000000000002d0 <thread_b>:

void 
thread_b(void)
{
 2d0:	7179                	addi	sp,sp,-48
 2d2:	f406                	sd	ra,40(sp)
 2d4:	f022                	sd	s0,32(sp)
 2d6:	ec26                	sd	s1,24(sp)
 2d8:	e84a                	sd	s2,16(sp)
 2da:	e44e                	sd	s3,8(sp)
 2dc:	1800                	addi	s0,sp,48
  b_started = 1;
 2de:	4785                	li	a5,1
 2e0:	00002717          	auipc	a4,0x2
 2e4:	d2f72823          	sw	a5,-720(a4) # 2010 <b_started>
  printf("thread_b started\n");
 2e8:	00001517          	auipc	a0,0x1
 2ec:	b5050513          	addi	a0,a0,-1200 # e38 <malloc+0x194>
 2f0:	101000ef          	jal	bf0 <printf>
  while (!(a_started && b_started && c_started)) {
 2f4:	00002497          	auipc	s1,0x2
 2f8:	d2048493          	addi	s1,s1,-736 # 2014 <a_started>
 2fc:	00002917          	auipc	s2,0x2
 300:	d1490913          	addi	s2,s2,-748 # 2010 <b_started>
 304:	00002997          	auipc	s3,0x2
 308:	d0898993          	addi	s3,s3,-760 # 200c <c_started>
 30c:	a019                	j	312 <thread_b+0x42>
    thread_yield();
 30e:	ec5ff0ef          	jal	1d2 <thread_yield>
  while (!(a_started && b_started && c_started)) {
 312:	409c                	lw	a5,0(s1)
 314:	2781                	sext.w	a5,a5
 316:	dfe5                	beqz	a5,30e <thread_b+0x3e>
 318:	00092783          	lw	a5,0(s2)
 31c:	2781                	sext.w	a5,a5
 31e:	dbe5                	beqz	a5,30e <thread_b+0x3e>
 320:	0009a783          	lw	a5,0(s3)
 324:	2781                	sext.w	a5,a5
 326:	d7e5                	beqz	a5,30e <thread_b+0x3e>
  }

  for (b_n = 0; b_n < 100; b_n++) {
 328:	00002797          	auipc	a5,0x2
 32c:	cdc78793          	addi	a5,a5,-804 # 2004 <b_n>
 330:	0007a023          	sw	zero,0(a5)
 334:	439c                	lw	a5,0(a5)
 336:	2781                	sext.w	a5,a5
 338:	06300713          	li	a4,99
 33c:	02f74963          	blt	a4,a5,36e <thread_b+0x9e>
    printf("thread_b %d\n", b_n);
 340:	00002497          	auipc	s1,0x2
 344:	cc448493          	addi	s1,s1,-828 # 2004 <b_n>
 348:	00001997          	auipc	s3,0x1
 34c:	b0898993          	addi	s3,s3,-1272 # e50 <malloc+0x1ac>
  for (b_n = 0; b_n < 100; b_n++) {
 350:	06300913          	li	s2,99
    printf("thread_b %d\n", b_n);
 354:	408c                	lw	a1,0(s1)
 356:	854e                	mv	a0,s3
 358:	099000ef          	jal	bf0 <printf>
    // let others run
    thread_yield();
 35c:	e77ff0ef          	jal	1d2 <thread_yield>
  for (b_n = 0; b_n < 100; b_n++) {
 360:	409c                	lw	a5,0(s1)
 362:	2785                	addiw	a5,a5,1
 364:	c09c                	sw	a5,0(s1)
 366:	409c                	lw	a5,0(s1)
 368:	2781                	sext.w	a5,a5
 36a:	fef955e3          	bge	s2,a5,354 <thread_b+0x84>
  }
  current_thread->state = FREE;
 36e:	00002797          	auipc	a5,0x2
 372:	caa7b783          	ld	a5,-854(a5) # 2018 <current_thread>
 376:	6709                	lui	a4,0x2
 378:	97ba                	add	a5,a5,a4
 37a:	0007a023          	sw	zero,0(a5)
  printf("thread_b: exit after 100\n");
 37e:	00001517          	auipc	a0,0x1
 382:	ae250513          	addi	a0,a0,-1310 # e60 <malloc+0x1bc>
 386:	06b000ef          	jal	bf0 <printf>
  thread_schedule();
 38a:	c9dff0ef          	jal	26 <thread_schedule>
}
 38e:	70a2                	ld	ra,40(sp)
 390:	7402                	ld	s0,32(sp)
 392:	64e2                	ld	s1,24(sp)
 394:	6942                	ld	s2,16(sp)
 396:	69a2                	ld	s3,8(sp)
 398:	6145                	addi	sp,sp,48
 39a:	8082                	ret

000000000000039c <thread_c>:

void 
thread_c(void)
{
 39c:	7179                	addi	sp,sp,-48
 39e:	f406                	sd	ra,40(sp)
 3a0:	f022                	sd	s0,32(sp)
 3a2:	ec26                	sd	s1,24(sp)
 3a4:	e84a                	sd	s2,16(sp)
 3a6:	e44e                	sd	s3,8(sp)
 3a8:	1800                	addi	s0,sp,48
  c_started = 1;
 3aa:	4785                	li	a5,1
 3ac:	00002717          	auipc	a4,0x2
 3b0:	c6f72023          	sw	a5,-928(a4) # 200c <c_started>
  printf("thread_c started\n");
 3b4:	00001517          	auipc	a0,0x1
 3b8:	acc50513          	addi	a0,a0,-1332 # e80 <malloc+0x1dc>
 3bc:	035000ef          	jal	bf0 <printf>
  while (!(a_started && b_started && c_started)) {
 3c0:	00002497          	auipc	s1,0x2
 3c4:	c5448493          	addi	s1,s1,-940 # 2014 <a_started>
 3c8:	00002917          	auipc	s2,0x2
 3cc:	c4890913          	addi	s2,s2,-952 # 2010 <b_started>
 3d0:	00002997          	auipc	s3,0x2
 3d4:	c3c98993          	addi	s3,s3,-964 # 200c <c_started>
 3d8:	a019                	j	3de <thread_c+0x42>
    thread_yield();
 3da:	df9ff0ef          	jal	1d2 <thread_yield>
  while (!(a_started && b_started && c_started)) {
 3de:	409c                	lw	a5,0(s1)
 3e0:	2781                	sext.w	a5,a5
 3e2:	dfe5                	beqz	a5,3da <thread_c+0x3e>
 3e4:	00092783          	lw	a5,0(s2)
 3e8:	2781                	sext.w	a5,a5
 3ea:	dbe5                	beqz	a5,3da <thread_c+0x3e>
 3ec:	0009a783          	lw	a5,0(s3)
 3f0:	2781                	sext.w	a5,a5
 3f2:	d7e5                	beqz	a5,3da <thread_c+0x3e>
  }

  for (; c_n < 100; c_n++) {
 3f4:	00002717          	auipc	a4,0x2
 3f8:	c0c72703          	lw	a4,-1012(a4) # 2000 <c_n>
 3fc:	06300793          	li	a5,99
 400:	02e7c963          	blt	a5,a4,432 <thread_c+0x96>
    printf("thread_c %d\n", c_n);
 404:	00002497          	auipc	s1,0x2
 408:	bfc48493          	addi	s1,s1,-1028 # 2000 <c_n>
 40c:	00001997          	auipc	s3,0x1
 410:	a8c98993          	addi	s3,s3,-1396 # e98 <malloc+0x1f4>
  for (; c_n < 100; c_n++) {
 414:	06300913          	li	s2,99
    printf("thread_c %d\n", c_n);
 418:	408c                	lw	a1,0(s1)
 41a:	854e                	mv	a0,s3
 41c:	7d4000ef          	jal	bf0 <printf>
    // let others run
    thread_yield();
 420:	db3ff0ef          	jal	1d2 <thread_yield>
  for (; c_n < 100; c_n++) {
 424:	409c                	lw	a5,0(s1)
 426:	2785                	addiw	a5,a5,1
 428:	c09c                	sw	a5,0(s1)
 42a:	409c                	lw	a5,0(s1)
 42c:	2781                	sext.w	a5,a5
 42e:	fef955e3          	bge	s2,a5,418 <thread_c+0x7c>
  }

  current_thread->state = FREE;
 432:	00002797          	auipc	a5,0x2
 436:	be67b783          	ld	a5,-1050(a5) # 2018 <current_thread>
 43a:	6709                	lui	a4,0x2
 43c:	97ba                	add	a5,a5,a4
 43e:	0007a023          	sw	zero,0(a5)
  printf("thread_c: exit after 100\n");
 442:	00001517          	auipc	a0,0x1
 446:	a6650513          	addi	a0,a0,-1434 # ea8 <malloc+0x204>
 44a:	7a6000ef          	jal	bf0 <printf>
  thread_schedule();
 44e:	bd9ff0ef          	jal	26 <thread_schedule>
}
 452:	70a2                	ld	ra,40(sp)
 454:	7402                	ld	s0,32(sp)
 456:	64e2                	ld	s1,24(sp)
 458:	6942                	ld	s2,16(sp)
 45a:	69a2                	ld	s3,8(sp)
 45c:	6145                	addi	sp,sp,48
 45e:	8082                	ret

0000000000000460 <main>:

int 
main(int argc, char **argv[]) 
{
 460:	1141                	addi	sp,sp,-16
 462:	e406                	sd	ra,8(sp)
 464:	e022                	sd	s0,0(sp)
 466:	0800                	addi	s0,sp,16
  a_started = b_started = c_started = 0;
 468:	00002797          	auipc	a5,0x2
 46c:	ba07a223          	sw	zero,-1116(a5) # 200c <c_started>
 470:	00002797          	auipc	a5,0x2
 474:	ba07a023          	sw	zero,-1120(a5) # 2010 <b_started>
 478:	00002797          	auipc	a5,0x2
 47c:	b807ae23          	sw	zero,-1124(a5) # 2014 <a_started>
  a_n = b_n = c_n = 0;
 480:	00002797          	auipc	a5,0x2
 484:	b807a023          	sw	zero,-1152(a5) # 2000 <c_n>
 488:	00002797          	auipc	a5,0x2
 48c:	b607ae23          	sw	zero,-1156(a5) # 2004 <b_n>
 490:	00002797          	auipc	a5,0x2
 494:	b607ac23          	sw	zero,-1160(a5) # 2008 <a_n>
  thread_init();
 498:	b69ff0ef          	jal	0 <thread_init>
  thread_create(thread_a);
 49c:	00000517          	auipc	a0,0x0
 4a0:	d6850513          	addi	a0,a0,-664 # 204 <thread_a>
 4a4:	ca3ff0ef          	jal	146 <thread_create>
  thread_create(thread_b);
 4a8:	00000517          	auipc	a0,0x0
 4ac:	e2850513          	addi	a0,a0,-472 # 2d0 <thread_b>
 4b0:	c97ff0ef          	jal	146 <thread_create>
  thread_create(thread_c);
 4b4:	00000517          	auipc	a0,0x0
 4b8:	ee850513          	addi	a0,a0,-280 # 39c <thread_c>
 4bc:	c8bff0ef          	jal	146 <thread_create>
  thread_schedule();
 4c0:	b67ff0ef          	jal	26 <thread_schedule>
  exit(0);
 4c4:	4501                	li	a0,0
 4c6:	302000ef          	jal	7c8 <exit>

00000000000004ca <thread_switch>:
 4ca:	00153023          	sd	ra,0(a0)
 4ce:	00253423          	sd	sp,8(a0)
 4d2:	e900                	sd	s0,16(a0)
 4d4:	ed04                	sd	s1,24(a0)
 4d6:	03253023          	sd	s2,32(a0)
 4da:	03353423          	sd	s3,40(a0)
 4de:	03453823          	sd	s4,48(a0)
 4e2:	03553c23          	sd	s5,56(a0)
 4e6:	05653023          	sd	s6,64(a0)
 4ea:	05753423          	sd	s7,72(a0)
 4ee:	05853823          	sd	s8,80(a0)
 4f2:	05953c23          	sd	s9,88(a0)
 4f6:	07a53023          	sd	s10,96(a0)
 4fa:	07b53423          	sd	s11,104(a0)
 4fe:	0005b083          	ld	ra,0(a1)
 502:	0085b103          	ld	sp,8(a1)
 506:	6980                	ld	s0,16(a1)
 508:	6d84                	ld	s1,24(a1)
 50a:	0205b903          	ld	s2,32(a1)
 50e:	0285b983          	ld	s3,40(a1)
 512:	0305ba03          	ld	s4,48(a1)
 516:	0385ba83          	ld	s5,56(a1)
 51a:	0405bb03          	ld	s6,64(a1)
 51e:	0485bb83          	ld	s7,72(a1)
 522:	0505bc03          	ld	s8,80(a1)
 526:	0585bc83          	ld	s9,88(a1)
 52a:	0605bd03          	ld	s10,96(a1)
 52e:	0685bd83          	ld	s11,104(a1)
 532:	8082                	ret

0000000000000534 <start>:
 534:	1141                	addi	sp,sp,-16
 536:	e406                	sd	ra,8(sp)
 538:	e022                	sd	s0,0(sp)
 53a:	0800                	addi	s0,sp,16
 53c:	f25ff0ef          	jal	460 <main>
 540:	288000ef          	jal	7c8 <exit>

0000000000000544 <strcpy>:
 544:	1141                	addi	sp,sp,-16
 546:	e422                	sd	s0,8(sp)
 548:	0800                	addi	s0,sp,16
 54a:	87aa                	mv	a5,a0
 54c:	0585                	addi	a1,a1,1
 54e:	0785                	addi	a5,a5,1
 550:	fff5c703          	lbu	a4,-1(a1)
 554:	fee78fa3          	sb	a4,-1(a5)
 558:	fb75                	bnez	a4,54c <strcpy+0x8>
 55a:	6422                	ld	s0,8(sp)
 55c:	0141                	addi	sp,sp,16
 55e:	8082                	ret

0000000000000560 <strcmp>:
 560:	1141                	addi	sp,sp,-16
 562:	e422                	sd	s0,8(sp)
 564:	0800                	addi	s0,sp,16
 566:	00054783          	lbu	a5,0(a0)
 56a:	cb91                	beqz	a5,57e <strcmp+0x1e>
 56c:	0005c703          	lbu	a4,0(a1)
 570:	00f71763          	bne	a4,a5,57e <strcmp+0x1e>
 574:	0505                	addi	a0,a0,1
 576:	0585                	addi	a1,a1,1
 578:	00054783          	lbu	a5,0(a0)
 57c:	fbe5                	bnez	a5,56c <strcmp+0xc>
 57e:	0005c503          	lbu	a0,0(a1)
 582:	40a7853b          	subw	a0,a5,a0
 586:	6422                	ld	s0,8(sp)
 588:	0141                	addi	sp,sp,16
 58a:	8082                	ret

000000000000058c <strlen>:
 58c:	1141                	addi	sp,sp,-16
 58e:	e422                	sd	s0,8(sp)
 590:	0800                	addi	s0,sp,16
 592:	00054783          	lbu	a5,0(a0)
 596:	cf91                	beqz	a5,5b2 <strlen+0x26>
 598:	0505                	addi	a0,a0,1
 59a:	87aa                	mv	a5,a0
 59c:	86be                	mv	a3,a5
 59e:	0785                	addi	a5,a5,1
 5a0:	fff7c703          	lbu	a4,-1(a5)
 5a4:	ff65                	bnez	a4,59c <strlen+0x10>
 5a6:	40a6853b          	subw	a0,a3,a0
 5aa:	2505                	addiw	a0,a0,1
 5ac:	6422                	ld	s0,8(sp)
 5ae:	0141                	addi	sp,sp,16
 5b0:	8082                	ret
 5b2:	4501                	li	a0,0
 5b4:	bfe5                	j	5ac <strlen+0x20>

00000000000005b6 <memset>:
 5b6:	1141                	addi	sp,sp,-16
 5b8:	e422                	sd	s0,8(sp)
 5ba:	0800                	addi	s0,sp,16
 5bc:	ca19                	beqz	a2,5d2 <memset+0x1c>
 5be:	87aa                	mv	a5,a0
 5c0:	1602                	slli	a2,a2,0x20
 5c2:	9201                	srli	a2,a2,0x20
 5c4:	00a60733          	add	a4,a2,a0
 5c8:	00b78023          	sb	a1,0(a5)
 5cc:	0785                	addi	a5,a5,1
 5ce:	fee79de3          	bne	a5,a4,5c8 <memset+0x12>
 5d2:	6422                	ld	s0,8(sp)
 5d4:	0141                	addi	sp,sp,16
 5d6:	8082                	ret

00000000000005d8 <strchr>:
 5d8:	1141                	addi	sp,sp,-16
 5da:	e422                	sd	s0,8(sp)
 5dc:	0800                	addi	s0,sp,16
 5de:	00054783          	lbu	a5,0(a0)
 5e2:	cb99                	beqz	a5,5f8 <strchr+0x20>
 5e4:	00f58763          	beq	a1,a5,5f2 <strchr+0x1a>
 5e8:	0505                	addi	a0,a0,1
 5ea:	00054783          	lbu	a5,0(a0)
 5ee:	fbfd                	bnez	a5,5e4 <strchr+0xc>
 5f0:	4501                	li	a0,0
 5f2:	6422                	ld	s0,8(sp)
 5f4:	0141                	addi	sp,sp,16
 5f6:	8082                	ret
 5f8:	4501                	li	a0,0
 5fa:	bfe5                	j	5f2 <strchr+0x1a>

00000000000005fc <gets>:
 5fc:	711d                	addi	sp,sp,-96
 5fe:	ec86                	sd	ra,88(sp)
 600:	e8a2                	sd	s0,80(sp)
 602:	e4a6                	sd	s1,72(sp)
 604:	e0ca                	sd	s2,64(sp)
 606:	fc4e                	sd	s3,56(sp)
 608:	f852                	sd	s4,48(sp)
 60a:	f456                	sd	s5,40(sp)
 60c:	f05a                	sd	s6,32(sp)
 60e:	ec5e                	sd	s7,24(sp)
 610:	1080                	addi	s0,sp,96
 612:	8baa                	mv	s7,a0
 614:	8a2e                	mv	s4,a1
 616:	892a                	mv	s2,a0
 618:	4481                	li	s1,0
 61a:	4aa9                	li	s5,10
 61c:	4b35                	li	s6,13
 61e:	89a6                	mv	s3,s1
 620:	2485                	addiw	s1,s1,1
 622:	0344d663          	bge	s1,s4,64e <gets+0x52>
 626:	4605                	li	a2,1
 628:	faf40593          	addi	a1,s0,-81
 62c:	4501                	li	a0,0
 62e:	1b2000ef          	jal	7e0 <read>
 632:	00a05e63          	blez	a0,64e <gets+0x52>
 636:	faf44783          	lbu	a5,-81(s0)
 63a:	00f90023          	sb	a5,0(s2)
 63e:	01578763          	beq	a5,s5,64c <gets+0x50>
 642:	0905                	addi	s2,s2,1
 644:	fd679de3          	bne	a5,s6,61e <gets+0x22>
 648:	89a6                	mv	s3,s1
 64a:	a011                	j	64e <gets+0x52>
 64c:	89a6                	mv	s3,s1
 64e:	99de                	add	s3,s3,s7
 650:	00098023          	sb	zero,0(s3)
 654:	855e                	mv	a0,s7
 656:	60e6                	ld	ra,88(sp)
 658:	6446                	ld	s0,80(sp)
 65a:	64a6                	ld	s1,72(sp)
 65c:	6906                	ld	s2,64(sp)
 65e:	79e2                	ld	s3,56(sp)
 660:	7a42                	ld	s4,48(sp)
 662:	7aa2                	ld	s5,40(sp)
 664:	7b02                	ld	s6,32(sp)
 666:	6be2                	ld	s7,24(sp)
 668:	6125                	addi	sp,sp,96
 66a:	8082                	ret

000000000000066c <stat>:
 66c:	1101                	addi	sp,sp,-32
 66e:	ec06                	sd	ra,24(sp)
 670:	e822                	sd	s0,16(sp)
 672:	e04a                	sd	s2,0(sp)
 674:	1000                	addi	s0,sp,32
 676:	892e                	mv	s2,a1
 678:	4581                	li	a1,0
 67a:	18e000ef          	jal	808 <open>
 67e:	02054263          	bltz	a0,6a2 <stat+0x36>
 682:	e426                	sd	s1,8(sp)
 684:	84aa                	mv	s1,a0
 686:	85ca                	mv	a1,s2
 688:	198000ef          	jal	820 <fstat>
 68c:	892a                	mv	s2,a0
 68e:	8526                	mv	a0,s1
 690:	160000ef          	jal	7f0 <close>
 694:	64a2                	ld	s1,8(sp)
 696:	854a                	mv	a0,s2
 698:	60e2                	ld	ra,24(sp)
 69a:	6442                	ld	s0,16(sp)
 69c:	6902                	ld	s2,0(sp)
 69e:	6105                	addi	sp,sp,32
 6a0:	8082                	ret
 6a2:	597d                	li	s2,-1
 6a4:	bfcd                	j	696 <stat+0x2a>

00000000000006a6 <atoi>:
 6a6:	1141                	addi	sp,sp,-16
 6a8:	e422                	sd	s0,8(sp)
 6aa:	0800                	addi	s0,sp,16
 6ac:	00054683          	lbu	a3,0(a0)
 6b0:	fd06879b          	addiw	a5,a3,-48
 6b4:	0ff7f793          	zext.b	a5,a5
 6b8:	4625                	li	a2,9
 6ba:	02f66863          	bltu	a2,a5,6ea <atoi+0x44>
 6be:	872a                	mv	a4,a0
 6c0:	4501                	li	a0,0
 6c2:	0705                	addi	a4,a4,1 # 2001 <c_n+0x1>
 6c4:	0025179b          	slliw	a5,a0,0x2
 6c8:	9fa9                	addw	a5,a5,a0
 6ca:	0017979b          	slliw	a5,a5,0x1
 6ce:	9fb5                	addw	a5,a5,a3
 6d0:	fd07851b          	addiw	a0,a5,-48
 6d4:	00074683          	lbu	a3,0(a4)
 6d8:	fd06879b          	addiw	a5,a3,-48
 6dc:	0ff7f793          	zext.b	a5,a5
 6e0:	fef671e3          	bgeu	a2,a5,6c2 <atoi+0x1c>
 6e4:	6422                	ld	s0,8(sp)
 6e6:	0141                	addi	sp,sp,16
 6e8:	8082                	ret
 6ea:	4501                	li	a0,0
 6ec:	bfe5                	j	6e4 <atoi+0x3e>

00000000000006ee <memmove>:
 6ee:	1141                	addi	sp,sp,-16
 6f0:	e422                	sd	s0,8(sp)
 6f2:	0800                	addi	s0,sp,16
 6f4:	02b57463          	bgeu	a0,a1,71c <memmove+0x2e>
 6f8:	00c05f63          	blez	a2,716 <memmove+0x28>
 6fc:	1602                	slli	a2,a2,0x20
 6fe:	9201                	srli	a2,a2,0x20
 700:	00c507b3          	add	a5,a0,a2
 704:	872a                	mv	a4,a0
 706:	0585                	addi	a1,a1,1
 708:	0705                	addi	a4,a4,1
 70a:	fff5c683          	lbu	a3,-1(a1)
 70e:	fed70fa3          	sb	a3,-1(a4)
 712:	fef71ae3          	bne	a4,a5,706 <memmove+0x18>
 716:	6422                	ld	s0,8(sp)
 718:	0141                	addi	sp,sp,16
 71a:	8082                	ret
 71c:	00c50733          	add	a4,a0,a2
 720:	95b2                	add	a1,a1,a2
 722:	fec05ae3          	blez	a2,716 <memmove+0x28>
 726:	fff6079b          	addiw	a5,a2,-1
 72a:	1782                	slli	a5,a5,0x20
 72c:	9381                	srli	a5,a5,0x20
 72e:	fff7c793          	not	a5,a5
 732:	97ba                	add	a5,a5,a4
 734:	15fd                	addi	a1,a1,-1
 736:	177d                	addi	a4,a4,-1
 738:	0005c683          	lbu	a3,0(a1)
 73c:	00d70023          	sb	a3,0(a4)
 740:	fee79ae3          	bne	a5,a4,734 <memmove+0x46>
 744:	bfc9                	j	716 <memmove+0x28>

0000000000000746 <memcmp>:
 746:	1141                	addi	sp,sp,-16
 748:	e422                	sd	s0,8(sp)
 74a:	0800                	addi	s0,sp,16
 74c:	ca05                	beqz	a2,77c <memcmp+0x36>
 74e:	fff6069b          	addiw	a3,a2,-1
 752:	1682                	slli	a3,a3,0x20
 754:	9281                	srli	a3,a3,0x20
 756:	0685                	addi	a3,a3,1
 758:	96aa                	add	a3,a3,a0
 75a:	00054783          	lbu	a5,0(a0)
 75e:	0005c703          	lbu	a4,0(a1)
 762:	00e79863          	bne	a5,a4,772 <memcmp+0x2c>
 766:	0505                	addi	a0,a0,1
 768:	0585                	addi	a1,a1,1
 76a:	fed518e3          	bne	a0,a3,75a <memcmp+0x14>
 76e:	4501                	li	a0,0
 770:	a019                	j	776 <memcmp+0x30>
 772:	40e7853b          	subw	a0,a5,a4
 776:	6422                	ld	s0,8(sp)
 778:	0141                	addi	sp,sp,16
 77a:	8082                	ret
 77c:	4501                	li	a0,0
 77e:	bfe5                	j	776 <memcmp+0x30>

0000000000000780 <memcpy>:
 780:	1141                	addi	sp,sp,-16
 782:	e406                	sd	ra,8(sp)
 784:	e022                	sd	s0,0(sp)
 786:	0800                	addi	s0,sp,16
 788:	f67ff0ef          	jal	6ee <memmove>
 78c:	60a2                	ld	ra,8(sp)
 78e:	6402                	ld	s0,0(sp)
 790:	0141                	addi	sp,sp,16
 792:	8082                	ret

0000000000000794 <sbrk>:
 794:	1141                	addi	sp,sp,-16
 796:	e406                	sd	ra,8(sp)
 798:	e022                	sd	s0,0(sp)
 79a:	0800                	addi	s0,sp,16
 79c:	4585                	li	a1,1
 79e:	0b2000ef          	jal	850 <sys_sbrk>
 7a2:	60a2                	ld	ra,8(sp)
 7a4:	6402                	ld	s0,0(sp)
 7a6:	0141                	addi	sp,sp,16
 7a8:	8082                	ret

00000000000007aa <sbrklazy>:
 7aa:	1141                	addi	sp,sp,-16
 7ac:	e406                	sd	ra,8(sp)
 7ae:	e022                	sd	s0,0(sp)
 7b0:	0800                	addi	s0,sp,16
 7b2:	4589                	li	a1,2
 7b4:	09c000ef          	jal	850 <sys_sbrk>
 7b8:	60a2                	ld	ra,8(sp)
 7ba:	6402                	ld	s0,0(sp)
 7bc:	0141                	addi	sp,sp,16
 7be:	8082                	ret

00000000000007c0 <fork>:
 7c0:	4885                	li	a7,1
 7c2:	00000073          	ecall
 7c6:	8082                	ret

00000000000007c8 <exit>:
 7c8:	4889                	li	a7,2
 7ca:	00000073          	ecall
 7ce:	8082                	ret

00000000000007d0 <wait>:
 7d0:	488d                	li	a7,3
 7d2:	00000073          	ecall
 7d6:	8082                	ret

00000000000007d8 <pipe>:
 7d8:	4891                	li	a7,4
 7da:	00000073          	ecall
 7de:	8082                	ret

00000000000007e0 <read>:
 7e0:	4895                	li	a7,5
 7e2:	00000073          	ecall
 7e6:	8082                	ret

00000000000007e8 <write>:
 7e8:	48c1                	li	a7,16
 7ea:	00000073          	ecall
 7ee:	8082                	ret

00000000000007f0 <close>:
 7f0:	48d5                	li	a7,21
 7f2:	00000073          	ecall
 7f6:	8082                	ret

00000000000007f8 <kill>:
 7f8:	4899                	li	a7,6
 7fa:	00000073          	ecall
 7fe:	8082                	ret

0000000000000800 <exec>:
 800:	489d                	li	a7,7
 802:	00000073          	ecall
 806:	8082                	ret

0000000000000808 <open>:
 808:	48bd                	li	a7,15
 80a:	00000073          	ecall
 80e:	8082                	ret

0000000000000810 <mknod>:
 810:	48c5                	li	a7,17
 812:	00000073          	ecall
 816:	8082                	ret

0000000000000818 <unlink>:
 818:	48c9                	li	a7,18
 81a:	00000073          	ecall
 81e:	8082                	ret

0000000000000820 <fstat>:
 820:	48a1                	li	a7,8
 822:	00000073          	ecall
 826:	8082                	ret

0000000000000828 <link>:
 828:	48cd                	li	a7,19
 82a:	00000073          	ecall
 82e:	8082                	ret

0000000000000830 <mkdir>:
 830:	48d1                	li	a7,20
 832:	00000073          	ecall
 836:	8082                	ret

0000000000000838 <chdir>:
 838:	48a5                	li	a7,9
 83a:	00000073          	ecall
 83e:	8082                	ret

0000000000000840 <dup>:
 840:	48a9                	li	a7,10
 842:	00000073          	ecall
 846:	8082                	ret

0000000000000848 <getpid>:
 848:	48ad                	li	a7,11
 84a:	00000073          	ecall
 84e:	8082                	ret

0000000000000850 <sys_sbrk>:
 850:	48b1                	li	a7,12
 852:	00000073          	ecall
 856:	8082                	ret

0000000000000858 <pause>:
 858:	48b5                	li	a7,13
 85a:	00000073          	ecall
 85e:	8082                	ret

0000000000000860 <uptime>:
 860:	48b9                	li	a7,14
 862:	00000073          	ecall
 866:	8082                	ret

0000000000000868 <putc>:
 868:	1101                	addi	sp,sp,-32
 86a:	ec06                	sd	ra,24(sp)
 86c:	e822                	sd	s0,16(sp)
 86e:	1000                	addi	s0,sp,32
 870:	feb407a3          	sb	a1,-17(s0)
 874:	4605                	li	a2,1
 876:	fef40593          	addi	a1,s0,-17
 87a:	f6fff0ef          	jal	7e8 <write>
 87e:	60e2                	ld	ra,24(sp)
 880:	6442                	ld	s0,16(sp)
 882:	6105                	addi	sp,sp,32
 884:	8082                	ret

0000000000000886 <printint>:
 886:	715d                	addi	sp,sp,-80
 888:	e486                	sd	ra,72(sp)
 88a:	e0a2                	sd	s0,64(sp)
 88c:	f84a                	sd	s2,48(sp)
 88e:	0880                	addi	s0,sp,80
 890:	892a                	mv	s2,a0
 892:	c299                	beqz	a3,898 <printint+0x12>
 894:	0805c363          	bltz	a1,91a <printint+0x94>
 898:	4881                	li	a7,0
 89a:	fb840693          	addi	a3,s0,-72
 89e:	4781                	li	a5,0
 8a0:	00000517          	auipc	a0,0x0
 8a4:	63050513          	addi	a0,a0,1584 # ed0 <digits>
 8a8:	883e                	mv	a6,a5
 8aa:	2785                	addiw	a5,a5,1
 8ac:	02c5f733          	remu	a4,a1,a2
 8b0:	972a                	add	a4,a4,a0
 8b2:	00074703          	lbu	a4,0(a4)
 8b6:	00e68023          	sb	a4,0(a3)
 8ba:	872e                	mv	a4,a1
 8bc:	02c5d5b3          	divu	a1,a1,a2
 8c0:	0685                	addi	a3,a3,1
 8c2:	fec773e3          	bgeu	a4,a2,8a8 <printint+0x22>
 8c6:	00088b63          	beqz	a7,8dc <printint+0x56>
 8ca:	fd078793          	addi	a5,a5,-48
 8ce:	97a2                	add	a5,a5,s0
 8d0:	02d00713          	li	a4,45
 8d4:	fee78423          	sb	a4,-24(a5)
 8d8:	0028079b          	addiw	a5,a6,2
 8dc:	02f05a63          	blez	a5,910 <printint+0x8a>
 8e0:	fc26                	sd	s1,56(sp)
 8e2:	f44e                	sd	s3,40(sp)
 8e4:	fb840713          	addi	a4,s0,-72
 8e8:	00f704b3          	add	s1,a4,a5
 8ec:	fff70993          	addi	s3,a4,-1
 8f0:	99be                	add	s3,s3,a5
 8f2:	37fd                	addiw	a5,a5,-1
 8f4:	1782                	slli	a5,a5,0x20
 8f6:	9381                	srli	a5,a5,0x20
 8f8:	40f989b3          	sub	s3,s3,a5
 8fc:	fff4c583          	lbu	a1,-1(s1)
 900:	854a                	mv	a0,s2
 902:	f67ff0ef          	jal	868 <putc>
 906:	14fd                	addi	s1,s1,-1
 908:	ff349ae3          	bne	s1,s3,8fc <printint+0x76>
 90c:	74e2                	ld	s1,56(sp)
 90e:	79a2                	ld	s3,40(sp)
 910:	60a6                	ld	ra,72(sp)
 912:	6406                	ld	s0,64(sp)
 914:	7942                	ld	s2,48(sp)
 916:	6161                	addi	sp,sp,80
 918:	8082                	ret
 91a:	40b005b3          	neg	a1,a1
 91e:	4885                	li	a7,1
 920:	bfad                	j	89a <printint+0x14>

0000000000000922 <vprintf>:
 922:	711d                	addi	sp,sp,-96
 924:	ec86                	sd	ra,88(sp)
 926:	e8a2                	sd	s0,80(sp)
 928:	e0ca                	sd	s2,64(sp)
 92a:	1080                	addi	s0,sp,96
 92c:	0005c903          	lbu	s2,0(a1)
 930:	28090663          	beqz	s2,bbc <vprintf+0x29a>
 934:	e4a6                	sd	s1,72(sp)
 936:	fc4e                	sd	s3,56(sp)
 938:	f852                	sd	s4,48(sp)
 93a:	f456                	sd	s5,40(sp)
 93c:	f05a                	sd	s6,32(sp)
 93e:	ec5e                	sd	s7,24(sp)
 940:	e862                	sd	s8,16(sp)
 942:	e466                	sd	s9,8(sp)
 944:	8b2a                	mv	s6,a0
 946:	8a2e                	mv	s4,a1
 948:	8bb2                	mv	s7,a2
 94a:	4981                	li	s3,0
 94c:	4481                	li	s1,0
 94e:	4701                	li	a4,0
 950:	02500a93          	li	s5,37
 954:	06400c13          	li	s8,100
 958:	06c00c93          	li	s9,108
 95c:	a005                	j	97c <vprintf+0x5a>
 95e:	85ca                	mv	a1,s2
 960:	855a                	mv	a0,s6
 962:	f07ff0ef          	jal	868 <putc>
 966:	a019                	j	96c <vprintf+0x4a>
 968:	03598263          	beq	s3,s5,98c <vprintf+0x6a>
 96c:	2485                	addiw	s1,s1,1
 96e:	8726                	mv	a4,s1
 970:	009a07b3          	add	a5,s4,s1
 974:	0007c903          	lbu	s2,0(a5)
 978:	22090a63          	beqz	s2,bac <vprintf+0x28a>
 97c:	0009079b          	sext.w	a5,s2
 980:	fe0994e3          	bnez	s3,968 <vprintf+0x46>
 984:	fd579de3          	bne	a5,s5,95e <vprintf+0x3c>
 988:	89be                	mv	s3,a5
 98a:	b7cd                	j	96c <vprintf+0x4a>
 98c:	00ea06b3          	add	a3,s4,a4
 990:	0016c683          	lbu	a3,1(a3)
 994:	8636                	mv	a2,a3
 996:	c681                	beqz	a3,99e <vprintf+0x7c>
 998:	9752                	add	a4,a4,s4
 99a:	00274603          	lbu	a2,2(a4)
 99e:	05878363          	beq	a5,s8,9e4 <vprintf+0xc2>
 9a2:	05978d63          	beq	a5,s9,9fc <vprintf+0xda>
 9a6:	07500713          	li	a4,117
 9aa:	0ee78763          	beq	a5,a4,a98 <vprintf+0x176>
 9ae:	07800713          	li	a4,120
 9b2:	12e78963          	beq	a5,a4,ae4 <vprintf+0x1c2>
 9b6:	07000713          	li	a4,112
 9ba:	14e78e63          	beq	a5,a4,b16 <vprintf+0x1f4>
 9be:	06300713          	li	a4,99
 9c2:	18e78e63          	beq	a5,a4,b5e <vprintf+0x23c>
 9c6:	07300713          	li	a4,115
 9ca:	1ae78463          	beq	a5,a4,b72 <vprintf+0x250>
 9ce:	02500713          	li	a4,37
 9d2:	04e79563          	bne	a5,a4,a1c <vprintf+0xfa>
 9d6:	02500593          	li	a1,37
 9da:	855a                	mv	a0,s6
 9dc:	e8dff0ef          	jal	868 <putc>
 9e0:	4981                	li	s3,0
 9e2:	b769                	j	96c <vprintf+0x4a>
 9e4:	008b8913          	addi	s2,s7,8
 9e8:	4685                	li	a3,1
 9ea:	4629                	li	a2,10
 9ec:	000ba583          	lw	a1,0(s7)
 9f0:	855a                	mv	a0,s6
 9f2:	e95ff0ef          	jal	886 <printint>
 9f6:	8bca                	mv	s7,s2
 9f8:	4981                	li	s3,0
 9fa:	bf8d                	j	96c <vprintf+0x4a>
 9fc:	06400793          	li	a5,100
 a00:	02f68963          	beq	a3,a5,a32 <vprintf+0x110>
 a04:	06c00793          	li	a5,108
 a08:	04f68263          	beq	a3,a5,a4c <vprintf+0x12a>
 a0c:	07500793          	li	a5,117
 a10:	0af68063          	beq	a3,a5,ab0 <vprintf+0x18e>
 a14:	07800793          	li	a5,120
 a18:	0ef68263          	beq	a3,a5,afc <vprintf+0x1da>
 a1c:	02500593          	li	a1,37
 a20:	855a                	mv	a0,s6
 a22:	e47ff0ef          	jal	868 <putc>
 a26:	85ca                	mv	a1,s2
 a28:	855a                	mv	a0,s6
 a2a:	e3fff0ef          	jal	868 <putc>
 a2e:	4981                	li	s3,0
 a30:	bf35                	j	96c <vprintf+0x4a>
 a32:	008b8913          	addi	s2,s7,8
 a36:	4685                	li	a3,1
 a38:	4629                	li	a2,10
 a3a:	000bb583          	ld	a1,0(s7)
 a3e:	855a                	mv	a0,s6
 a40:	e47ff0ef          	jal	886 <printint>
 a44:	2485                	addiw	s1,s1,1
 a46:	8bca                	mv	s7,s2
 a48:	4981                	li	s3,0
 a4a:	b70d                	j	96c <vprintf+0x4a>
 a4c:	06400793          	li	a5,100
 a50:	02f60763          	beq	a2,a5,a7e <vprintf+0x15c>
 a54:	07500793          	li	a5,117
 a58:	06f60963          	beq	a2,a5,aca <vprintf+0x1a8>
 a5c:	07800793          	li	a5,120
 a60:	faf61ee3          	bne	a2,a5,a1c <vprintf+0xfa>
 a64:	008b8913          	addi	s2,s7,8
 a68:	4681                	li	a3,0
 a6a:	4641                	li	a2,16
 a6c:	000bb583          	ld	a1,0(s7)
 a70:	855a                	mv	a0,s6
 a72:	e15ff0ef          	jal	886 <printint>
 a76:	2489                	addiw	s1,s1,2
 a78:	8bca                	mv	s7,s2
 a7a:	4981                	li	s3,0
 a7c:	bdc5                	j	96c <vprintf+0x4a>
 a7e:	008b8913          	addi	s2,s7,8
 a82:	4685                	li	a3,1
 a84:	4629                	li	a2,10
 a86:	000bb583          	ld	a1,0(s7)
 a8a:	855a                	mv	a0,s6
 a8c:	dfbff0ef          	jal	886 <printint>
 a90:	2489                	addiw	s1,s1,2
 a92:	8bca                	mv	s7,s2
 a94:	4981                	li	s3,0
 a96:	bdd9                	j	96c <vprintf+0x4a>
 a98:	008b8913          	addi	s2,s7,8
 a9c:	4681                	li	a3,0
 a9e:	4629                	li	a2,10
 aa0:	000be583          	lwu	a1,0(s7)
 aa4:	855a                	mv	a0,s6
 aa6:	de1ff0ef          	jal	886 <printint>
 aaa:	8bca                	mv	s7,s2
 aac:	4981                	li	s3,0
 aae:	bd7d                	j	96c <vprintf+0x4a>
 ab0:	008b8913          	addi	s2,s7,8
 ab4:	4681                	li	a3,0
 ab6:	4629                	li	a2,10
 ab8:	000bb583          	ld	a1,0(s7)
 abc:	855a                	mv	a0,s6
 abe:	dc9ff0ef          	jal	886 <printint>
 ac2:	2485                	addiw	s1,s1,1
 ac4:	8bca                	mv	s7,s2
 ac6:	4981                	li	s3,0
 ac8:	b555                	j	96c <vprintf+0x4a>
 aca:	008b8913          	addi	s2,s7,8
 ace:	4681                	li	a3,0
 ad0:	4629                	li	a2,10
 ad2:	000bb583          	ld	a1,0(s7)
 ad6:	855a                	mv	a0,s6
 ad8:	dafff0ef          	jal	886 <printint>
 adc:	2489                	addiw	s1,s1,2
 ade:	8bca                	mv	s7,s2
 ae0:	4981                	li	s3,0
 ae2:	b569                	j	96c <vprintf+0x4a>
 ae4:	008b8913          	addi	s2,s7,8
 ae8:	4681                	li	a3,0
 aea:	4641                	li	a2,16
 aec:	000be583          	lwu	a1,0(s7)
 af0:	855a                	mv	a0,s6
 af2:	d95ff0ef          	jal	886 <printint>
 af6:	8bca                	mv	s7,s2
 af8:	4981                	li	s3,0
 afa:	bd8d                	j	96c <vprintf+0x4a>
 afc:	008b8913          	addi	s2,s7,8
 b00:	4681                	li	a3,0
 b02:	4641                	li	a2,16
 b04:	000bb583          	ld	a1,0(s7)
 b08:	855a                	mv	a0,s6
 b0a:	d7dff0ef          	jal	886 <printint>
 b0e:	2485                	addiw	s1,s1,1
 b10:	8bca                	mv	s7,s2
 b12:	4981                	li	s3,0
 b14:	bda1                	j	96c <vprintf+0x4a>
 b16:	e06a                	sd	s10,0(sp)
 b18:	008b8d13          	addi	s10,s7,8
 b1c:	000bb983          	ld	s3,0(s7)
 b20:	03000593          	li	a1,48
 b24:	855a                	mv	a0,s6
 b26:	d43ff0ef          	jal	868 <putc>
 b2a:	07800593          	li	a1,120
 b2e:	855a                	mv	a0,s6
 b30:	d39ff0ef          	jal	868 <putc>
 b34:	4941                	li	s2,16
 b36:	00000b97          	auipc	s7,0x0
 b3a:	39ab8b93          	addi	s7,s7,922 # ed0 <digits>
 b3e:	03c9d793          	srli	a5,s3,0x3c
 b42:	97de                	add	a5,a5,s7
 b44:	0007c583          	lbu	a1,0(a5)
 b48:	855a                	mv	a0,s6
 b4a:	d1fff0ef          	jal	868 <putc>
 b4e:	0992                	slli	s3,s3,0x4
 b50:	397d                	addiw	s2,s2,-1
 b52:	fe0916e3          	bnez	s2,b3e <vprintf+0x21c>
 b56:	8bea                	mv	s7,s10
 b58:	4981                	li	s3,0
 b5a:	6d02                	ld	s10,0(sp)
 b5c:	bd01                	j	96c <vprintf+0x4a>
 b5e:	008b8913          	addi	s2,s7,8
 b62:	000bc583          	lbu	a1,0(s7)
 b66:	855a                	mv	a0,s6
 b68:	d01ff0ef          	jal	868 <putc>
 b6c:	8bca                	mv	s7,s2
 b6e:	4981                	li	s3,0
 b70:	bbf5                	j	96c <vprintf+0x4a>
 b72:	008b8993          	addi	s3,s7,8
 b76:	000bb903          	ld	s2,0(s7)
 b7a:	00090f63          	beqz	s2,b98 <vprintf+0x276>
 b7e:	00094583          	lbu	a1,0(s2)
 b82:	c195                	beqz	a1,ba6 <vprintf+0x284>
 b84:	855a                	mv	a0,s6
 b86:	ce3ff0ef          	jal	868 <putc>
 b8a:	0905                	addi	s2,s2,1
 b8c:	00094583          	lbu	a1,0(s2)
 b90:	f9f5                	bnez	a1,b84 <vprintf+0x262>
 b92:	8bce                	mv	s7,s3
 b94:	4981                	li	s3,0
 b96:	bbd9                	j	96c <vprintf+0x4a>
 b98:	00000917          	auipc	s2,0x0
 b9c:	33090913          	addi	s2,s2,816 # ec8 <malloc+0x224>
 ba0:	02800593          	li	a1,40
 ba4:	b7c5                	j	b84 <vprintf+0x262>
 ba6:	8bce                	mv	s7,s3
 ba8:	4981                	li	s3,0
 baa:	b3c9                	j	96c <vprintf+0x4a>
 bac:	64a6                	ld	s1,72(sp)
 bae:	79e2                	ld	s3,56(sp)
 bb0:	7a42                	ld	s4,48(sp)
 bb2:	7aa2                	ld	s5,40(sp)
 bb4:	7b02                	ld	s6,32(sp)
 bb6:	6be2                	ld	s7,24(sp)
 bb8:	6c42                	ld	s8,16(sp)
 bba:	6ca2                	ld	s9,8(sp)
 bbc:	60e6                	ld	ra,88(sp)
 bbe:	6446                	ld	s0,80(sp)
 bc0:	6906                	ld	s2,64(sp)
 bc2:	6125                	addi	sp,sp,96
 bc4:	8082                	ret

0000000000000bc6 <fprintf>:
 bc6:	715d                	addi	sp,sp,-80
 bc8:	ec06                	sd	ra,24(sp)
 bca:	e822                	sd	s0,16(sp)
 bcc:	1000                	addi	s0,sp,32
 bce:	e010                	sd	a2,0(s0)
 bd0:	e414                	sd	a3,8(s0)
 bd2:	e818                	sd	a4,16(s0)
 bd4:	ec1c                	sd	a5,24(s0)
 bd6:	03043023          	sd	a6,32(s0)
 bda:	03143423          	sd	a7,40(s0)
 bde:	fe843423          	sd	s0,-24(s0)
 be2:	8622                	mv	a2,s0
 be4:	d3fff0ef          	jal	922 <vprintf>
 be8:	60e2                	ld	ra,24(sp)
 bea:	6442                	ld	s0,16(sp)
 bec:	6161                	addi	sp,sp,80
 bee:	8082                	ret

0000000000000bf0 <printf>:
 bf0:	711d                	addi	sp,sp,-96
 bf2:	ec06                	sd	ra,24(sp)
 bf4:	e822                	sd	s0,16(sp)
 bf6:	1000                	addi	s0,sp,32
 bf8:	e40c                	sd	a1,8(s0)
 bfa:	e810                	sd	a2,16(s0)
 bfc:	ec14                	sd	a3,24(s0)
 bfe:	f018                	sd	a4,32(s0)
 c00:	f41c                	sd	a5,40(s0)
 c02:	03043823          	sd	a6,48(s0)
 c06:	03143c23          	sd	a7,56(s0)
 c0a:	00840613          	addi	a2,s0,8
 c0e:	fec43423          	sd	a2,-24(s0)
 c12:	85aa                	mv	a1,a0
 c14:	4505                	li	a0,1
 c16:	d0dff0ef          	jal	922 <vprintf>
 c1a:	60e2                	ld	ra,24(sp)
 c1c:	6442                	ld	s0,16(sp)
 c1e:	6125                	addi	sp,sp,96
 c20:	8082                	ret

0000000000000c22 <free>:
 c22:	1141                	addi	sp,sp,-16
 c24:	e422                	sd	s0,8(sp)
 c26:	0800                	addi	s0,sp,16
 c28:	ff050693          	addi	a3,a0,-16
 c2c:	00001797          	auipc	a5,0x1
 c30:	3f47b783          	ld	a5,1012(a5) # 2020 <freep>
 c34:	a02d                	j	c5e <free+0x3c>
 c36:	4618                	lw	a4,8(a2)
 c38:	9f2d                	addw	a4,a4,a1
 c3a:	fee52c23          	sw	a4,-8(a0)
 c3e:	6398                	ld	a4,0(a5)
 c40:	6310                	ld	a2,0(a4)
 c42:	a83d                	j	c80 <free+0x5e>
 c44:	ff852703          	lw	a4,-8(a0)
 c48:	9f31                	addw	a4,a4,a2
 c4a:	c798                	sw	a4,8(a5)
 c4c:	ff053683          	ld	a3,-16(a0)
 c50:	a091                	j	c94 <free+0x72>
 c52:	6398                	ld	a4,0(a5)
 c54:	00e7e463          	bltu	a5,a4,c5c <free+0x3a>
 c58:	00e6ea63          	bltu	a3,a4,c6c <free+0x4a>
 c5c:	87ba                	mv	a5,a4
 c5e:	fed7fae3          	bgeu	a5,a3,c52 <free+0x30>
 c62:	6398                	ld	a4,0(a5)
 c64:	00e6e463          	bltu	a3,a4,c6c <free+0x4a>
 c68:	fee7eae3          	bltu	a5,a4,c5c <free+0x3a>
 c6c:	ff852583          	lw	a1,-8(a0)
 c70:	6390                	ld	a2,0(a5)
 c72:	02059813          	slli	a6,a1,0x20
 c76:	01c85713          	srli	a4,a6,0x1c
 c7a:	9736                	add	a4,a4,a3
 c7c:	fae60de3          	beq	a2,a4,c36 <free+0x14>
 c80:	fec53823          	sd	a2,-16(a0)
 c84:	4790                	lw	a2,8(a5)
 c86:	02061593          	slli	a1,a2,0x20
 c8a:	01c5d713          	srli	a4,a1,0x1c
 c8e:	973e                	add	a4,a4,a5
 c90:	fae68ae3          	beq	a3,a4,c44 <free+0x22>
 c94:	e394                	sd	a3,0(a5)
 c96:	00001717          	auipc	a4,0x1
 c9a:	38f73523          	sd	a5,906(a4) # 2020 <freep>
 c9e:	6422                	ld	s0,8(sp)
 ca0:	0141                	addi	sp,sp,16
 ca2:	8082                	ret

0000000000000ca4 <malloc>:
 ca4:	7139                	addi	sp,sp,-64
 ca6:	fc06                	sd	ra,56(sp)
 ca8:	f822                	sd	s0,48(sp)
 caa:	f426                	sd	s1,40(sp)
 cac:	ec4e                	sd	s3,24(sp)
 cae:	0080                	addi	s0,sp,64
 cb0:	02051493          	slli	s1,a0,0x20
 cb4:	9081                	srli	s1,s1,0x20
 cb6:	04bd                	addi	s1,s1,15
 cb8:	8091                	srli	s1,s1,0x4
 cba:	0014899b          	addiw	s3,s1,1
 cbe:	0485                	addi	s1,s1,1
 cc0:	00001517          	auipc	a0,0x1
 cc4:	36053503          	ld	a0,864(a0) # 2020 <freep>
 cc8:	c915                	beqz	a0,cfc <malloc+0x58>
 cca:	611c                	ld	a5,0(a0)
 ccc:	4798                	lw	a4,8(a5)
 cce:	08977a63          	bgeu	a4,s1,d62 <malloc+0xbe>
 cd2:	f04a                	sd	s2,32(sp)
 cd4:	e852                	sd	s4,16(sp)
 cd6:	e456                	sd	s5,8(sp)
 cd8:	e05a                	sd	s6,0(sp)
 cda:	8a4e                	mv	s4,s3
 cdc:	0009871b          	sext.w	a4,s3
 ce0:	6685                	lui	a3,0x1
 ce2:	00d77363          	bgeu	a4,a3,ce8 <malloc+0x44>
 ce6:	6a05                	lui	s4,0x1
 ce8:	000a0b1b          	sext.w	s6,s4
 cec:	004a1a1b          	slliw	s4,s4,0x4
 cf0:	00001917          	auipc	s2,0x1
 cf4:	33090913          	addi	s2,s2,816 # 2020 <freep>
 cf8:	5afd                	li	s5,-1
 cfa:	a081                	j	d3a <malloc+0x96>
 cfc:	f04a                	sd	s2,32(sp)
 cfe:	e852                	sd	s4,16(sp)
 d00:	e456                	sd	s5,8(sp)
 d02:	e05a                	sd	s6,0(sp)
 d04:	00009797          	auipc	a5,0x9
 d08:	50c78793          	addi	a5,a5,1292 # a210 <base>
 d0c:	00001717          	auipc	a4,0x1
 d10:	30f73a23          	sd	a5,788(a4) # 2020 <freep>
 d14:	e39c                	sd	a5,0(a5)
 d16:	0007a423          	sw	zero,8(a5)
 d1a:	b7c1                	j	cda <malloc+0x36>
 d1c:	6398                	ld	a4,0(a5)
 d1e:	e118                	sd	a4,0(a0)
 d20:	a8a9                	j	d7a <malloc+0xd6>
 d22:	01652423          	sw	s6,8(a0)
 d26:	0541                	addi	a0,a0,16
 d28:	efbff0ef          	jal	c22 <free>
 d2c:	00093503          	ld	a0,0(s2)
 d30:	c12d                	beqz	a0,d92 <malloc+0xee>
 d32:	611c                	ld	a5,0(a0)
 d34:	4798                	lw	a4,8(a5)
 d36:	02977263          	bgeu	a4,s1,d5a <malloc+0xb6>
 d3a:	00093703          	ld	a4,0(s2)
 d3e:	853e                	mv	a0,a5
 d40:	fef719e3          	bne	a4,a5,d32 <malloc+0x8e>
 d44:	8552                	mv	a0,s4
 d46:	a4fff0ef          	jal	794 <sbrk>
 d4a:	fd551ce3          	bne	a0,s5,d22 <malloc+0x7e>
 d4e:	4501                	li	a0,0
 d50:	7902                	ld	s2,32(sp)
 d52:	6a42                	ld	s4,16(sp)
 d54:	6aa2                	ld	s5,8(sp)
 d56:	6b02                	ld	s6,0(sp)
 d58:	a03d                	j	d86 <malloc+0xe2>
 d5a:	7902                	ld	s2,32(sp)
 d5c:	6a42                	ld	s4,16(sp)
 d5e:	6aa2                	ld	s5,8(sp)
 d60:	6b02                	ld	s6,0(sp)
 d62:	fae48de3          	beq	s1,a4,d1c <malloc+0x78>
 d66:	4137073b          	subw	a4,a4,s3
 d6a:	c798                	sw	a4,8(a5)
 d6c:	02071693          	slli	a3,a4,0x20
 d70:	01c6d713          	srli	a4,a3,0x1c
 d74:	97ba                	add	a5,a5,a4
 d76:	0137a423          	sw	s3,8(a5)
 d7a:	00001717          	auipc	a4,0x1
 d7e:	2aa73323          	sd	a0,678(a4) # 2020 <freep>
 d82:	01078513          	addi	a0,a5,16
 d86:	70e2                	ld	ra,56(sp)
 d88:	7442                	ld	s0,48(sp)
 d8a:	74a2                	ld	s1,40(sp)
 d8c:	69e2                	ld	s3,24(sp)
 d8e:	6121                	addi	sp,sp,64
 d90:	8082                	ret
 d92:	7902                	ld	s2,32(sp)
 d94:	6a42                	ld	s4,16(sp)
 d96:	6aa2                	ld	s5,8(sp)
 d98:	6b02                	ld	s6,0(sp)
 d9a:	b7f5                	j	d86 <malloc+0xe2>
