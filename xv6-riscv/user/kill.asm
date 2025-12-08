
user/_kill:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   8:	4785                	li	a5,1
   a:	02a7d963          	bge	a5,a0,3c <main+0x3c>
   e:	e426                	sd	s1,8(sp)
  10:	e04a                	sd	s2,0(sp)
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	02091793          	slli	a5,s2,0x20
  1e:	01d7d913          	srli	s2,a5,0x1d
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "usage: kill pid...\n");
    exit(1);
  }
  for(i=1; i<argc; i++)
    kill(atoi(argv[i]));
  26:	6088                	ld	a0,0(s1)
  28:	19e000ef          	jal	1c6 <atoi>
  2c:	2ec000ef          	jal	318 <kill>
  for(i=1; i<argc; i++)
  30:	04a1                	addi	s1,s1,8
  32:	ff249ae3          	bne	s1,s2,26 <main+0x26>
  exit(0);
  36:	4501                	li	a0,0
  38:	2b0000ef          	jal	2e8 <exit>
  3c:	e426                	sd	s1,8(sp)
  3e:	e04a                	sd	s2,0(sp)
    fprintf(2, "usage: kill pid...\n");
  40:	00001597          	auipc	a1,0x1
  44:	89058593          	addi	a1,a1,-1904 # 8d0 <malloc+0x104>
  48:	4509                	li	a0,2
  4a:	6a4000ef          	jal	6ee <fprintf>
    exit(1);
  4e:	4505                	li	a0,1
  50:	298000ef          	jal	2e8 <exit>

0000000000000054 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  54:	1141                	addi	sp,sp,-16
  56:	e406                	sd	ra,8(sp)
  58:	e022                	sd	s0,0(sp)
  5a:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  5c:	fa5ff0ef          	jal	0 <main>
  exit(r);
  60:	288000ef          	jal	2e8 <exit>

0000000000000064 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  64:	1141                	addi	sp,sp,-16
  66:	e422                	sd	s0,8(sp)
  68:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  6a:	87aa                	mv	a5,a0
  6c:	0585                	addi	a1,a1,1
  6e:	0785                	addi	a5,a5,1
  70:	fff5c703          	lbu	a4,-1(a1)
  74:	fee78fa3          	sb	a4,-1(a5)
  78:	fb75                	bnez	a4,6c <strcpy+0x8>
    ;
  return os;
}
  7a:	6422                	ld	s0,8(sp)
  7c:	0141                	addi	sp,sp,16
  7e:	8082                	ret

0000000000000080 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80:	1141                	addi	sp,sp,-16
  82:	e422                	sd	s0,8(sp)
  84:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  86:	00054783          	lbu	a5,0(a0)
  8a:	cb91                	beqz	a5,9e <strcmp+0x1e>
  8c:	0005c703          	lbu	a4,0(a1)
  90:	00f71763          	bne	a4,a5,9e <strcmp+0x1e>
    p++, q++;
  94:	0505                	addi	a0,a0,1
  96:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  98:	00054783          	lbu	a5,0(a0)
  9c:	fbe5                	bnez	a5,8c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  9e:	0005c503          	lbu	a0,0(a1)
}
  a2:	40a7853b          	subw	a0,a5,a0
  a6:	6422                	ld	s0,8(sp)
  a8:	0141                	addi	sp,sp,16
  aa:	8082                	ret

00000000000000ac <strlen>:

uint
strlen(const char *s)
{
  ac:	1141                	addi	sp,sp,-16
  ae:	e422                	sd	s0,8(sp)
  b0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  b2:	00054783          	lbu	a5,0(a0)
  b6:	cf91                	beqz	a5,d2 <strlen+0x26>
  b8:	0505                	addi	a0,a0,1
  ba:	87aa                	mv	a5,a0
  bc:	86be                	mv	a3,a5
  be:	0785                	addi	a5,a5,1
  c0:	fff7c703          	lbu	a4,-1(a5)
  c4:	ff65                	bnez	a4,bc <strlen+0x10>
  c6:	40a6853b          	subw	a0,a3,a0
  ca:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  cc:	6422                	ld	s0,8(sp)
  ce:	0141                	addi	sp,sp,16
  d0:	8082                	ret
  for(n = 0; s[n]; n++)
  d2:	4501                	li	a0,0
  d4:	bfe5                	j	cc <strlen+0x20>

00000000000000d6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d6:	1141                	addi	sp,sp,-16
  d8:	e422                	sd	s0,8(sp)
  da:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  dc:	ca19                	beqz	a2,f2 <memset+0x1c>
  de:	87aa                	mv	a5,a0
  e0:	1602                	slli	a2,a2,0x20
  e2:	9201                	srli	a2,a2,0x20
  e4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  e8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  ec:	0785                	addi	a5,a5,1
  ee:	fee79de3          	bne	a5,a4,e8 <memset+0x12>
  }
  return dst;
}
  f2:	6422                	ld	s0,8(sp)
  f4:	0141                	addi	sp,sp,16
  f6:	8082                	ret

00000000000000f8 <strchr>:

char*
strchr(const char *s, char c)
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e422                	sd	s0,8(sp)
  fc:	0800                	addi	s0,sp,16
  for(; *s; s++)
  fe:	00054783          	lbu	a5,0(a0)
 102:	cb99                	beqz	a5,118 <strchr+0x20>
    if(*s == c)
 104:	00f58763          	beq	a1,a5,112 <strchr+0x1a>
  for(; *s; s++)
 108:	0505                	addi	a0,a0,1
 10a:	00054783          	lbu	a5,0(a0)
 10e:	fbfd                	bnez	a5,104 <strchr+0xc>
      return (char*)s;
  return 0;
 110:	4501                	li	a0,0
}
 112:	6422                	ld	s0,8(sp)
 114:	0141                	addi	sp,sp,16
 116:	8082                	ret
  return 0;
 118:	4501                	li	a0,0
 11a:	bfe5                	j	112 <strchr+0x1a>

000000000000011c <gets>:

char*
gets(char *buf, int max)
{
 11c:	711d                	addi	sp,sp,-96
 11e:	ec86                	sd	ra,88(sp)
 120:	e8a2                	sd	s0,80(sp)
 122:	e4a6                	sd	s1,72(sp)
 124:	e0ca                	sd	s2,64(sp)
 126:	fc4e                	sd	s3,56(sp)
 128:	f852                	sd	s4,48(sp)
 12a:	f456                	sd	s5,40(sp)
 12c:	f05a                	sd	s6,32(sp)
 12e:	ec5e                	sd	s7,24(sp)
 130:	1080                	addi	s0,sp,96
 132:	8baa                	mv	s7,a0
 134:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 136:	892a                	mv	s2,a0
 138:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 13a:	4aa9                	li	s5,10
 13c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 13e:	89a6                	mv	s3,s1
 140:	2485                	addiw	s1,s1,1
 142:	0344d663          	bge	s1,s4,16e <gets+0x52>
    cc = read(0, &c, 1);
 146:	4605                	li	a2,1
 148:	faf40593          	addi	a1,s0,-81
 14c:	4501                	li	a0,0
 14e:	1b2000ef          	jal	300 <read>
    if(cc < 1)
 152:	00a05e63          	blez	a0,16e <gets+0x52>
    buf[i++] = c;
 156:	faf44783          	lbu	a5,-81(s0)
 15a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 15e:	01578763          	beq	a5,s5,16c <gets+0x50>
 162:	0905                	addi	s2,s2,1
 164:	fd679de3          	bne	a5,s6,13e <gets+0x22>
    buf[i++] = c;
 168:	89a6                	mv	s3,s1
 16a:	a011                	j	16e <gets+0x52>
 16c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 16e:	99de                	add	s3,s3,s7
 170:	00098023          	sb	zero,0(s3)
  return buf;
}
 174:	855e                	mv	a0,s7
 176:	60e6                	ld	ra,88(sp)
 178:	6446                	ld	s0,80(sp)
 17a:	64a6                	ld	s1,72(sp)
 17c:	6906                	ld	s2,64(sp)
 17e:	79e2                	ld	s3,56(sp)
 180:	7a42                	ld	s4,48(sp)
 182:	7aa2                	ld	s5,40(sp)
 184:	7b02                	ld	s6,32(sp)
 186:	6be2                	ld	s7,24(sp)
 188:	6125                	addi	sp,sp,96
 18a:	8082                	ret

000000000000018c <stat>:

int
stat(const char *n, struct stat *st)
{
 18c:	1101                	addi	sp,sp,-32
 18e:	ec06                	sd	ra,24(sp)
 190:	e822                	sd	s0,16(sp)
 192:	e04a                	sd	s2,0(sp)
 194:	1000                	addi	s0,sp,32
 196:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 198:	4581                	li	a1,0
 19a:	18e000ef          	jal	328 <open>
  if(fd < 0)
 19e:	02054263          	bltz	a0,1c2 <stat+0x36>
 1a2:	e426                	sd	s1,8(sp)
 1a4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1a6:	85ca                	mv	a1,s2
 1a8:	198000ef          	jal	340 <fstat>
 1ac:	892a                	mv	s2,a0
  close(fd);
 1ae:	8526                	mv	a0,s1
 1b0:	160000ef          	jal	310 <close>
  return r;
 1b4:	64a2                	ld	s1,8(sp)
}
 1b6:	854a                	mv	a0,s2
 1b8:	60e2                	ld	ra,24(sp)
 1ba:	6442                	ld	s0,16(sp)
 1bc:	6902                	ld	s2,0(sp)
 1be:	6105                	addi	sp,sp,32
 1c0:	8082                	ret
    return -1;
 1c2:	597d                	li	s2,-1
 1c4:	bfcd                	j	1b6 <stat+0x2a>

00000000000001c6 <atoi>:

int
atoi(const char *s)
{
 1c6:	1141                	addi	sp,sp,-16
 1c8:	e422                	sd	s0,8(sp)
 1ca:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1cc:	00054683          	lbu	a3,0(a0)
 1d0:	fd06879b          	addiw	a5,a3,-48
 1d4:	0ff7f793          	zext.b	a5,a5
 1d8:	4625                	li	a2,9
 1da:	02f66863          	bltu	a2,a5,20a <atoi+0x44>
 1de:	872a                	mv	a4,a0
  n = 0;
 1e0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1e2:	0705                	addi	a4,a4,1
 1e4:	0025179b          	slliw	a5,a0,0x2
 1e8:	9fa9                	addw	a5,a5,a0
 1ea:	0017979b          	slliw	a5,a5,0x1
 1ee:	9fb5                	addw	a5,a5,a3
 1f0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1f4:	00074683          	lbu	a3,0(a4)
 1f8:	fd06879b          	addiw	a5,a3,-48
 1fc:	0ff7f793          	zext.b	a5,a5
 200:	fef671e3          	bgeu	a2,a5,1e2 <atoi+0x1c>
  return n;
}
 204:	6422                	ld	s0,8(sp)
 206:	0141                	addi	sp,sp,16
 208:	8082                	ret
  n = 0;
 20a:	4501                	li	a0,0
 20c:	bfe5                	j	204 <atoi+0x3e>

000000000000020e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 20e:	1141                	addi	sp,sp,-16
 210:	e422                	sd	s0,8(sp)
 212:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 214:	02b57463          	bgeu	a0,a1,23c <memmove+0x2e>
    while(n-- > 0)
 218:	00c05f63          	blez	a2,236 <memmove+0x28>
 21c:	1602                	slli	a2,a2,0x20
 21e:	9201                	srli	a2,a2,0x20
 220:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 224:	872a                	mv	a4,a0
      *dst++ = *src++;
 226:	0585                	addi	a1,a1,1
 228:	0705                	addi	a4,a4,1
 22a:	fff5c683          	lbu	a3,-1(a1)
 22e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 232:	fef71ae3          	bne	a4,a5,226 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 236:	6422                	ld	s0,8(sp)
 238:	0141                	addi	sp,sp,16
 23a:	8082                	ret
    dst += n;
 23c:	00c50733          	add	a4,a0,a2
    src += n;
 240:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 242:	fec05ae3          	blez	a2,236 <memmove+0x28>
 246:	fff6079b          	addiw	a5,a2,-1
 24a:	1782                	slli	a5,a5,0x20
 24c:	9381                	srli	a5,a5,0x20
 24e:	fff7c793          	not	a5,a5
 252:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 254:	15fd                	addi	a1,a1,-1
 256:	177d                	addi	a4,a4,-1
 258:	0005c683          	lbu	a3,0(a1)
 25c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 260:	fee79ae3          	bne	a5,a4,254 <memmove+0x46>
 264:	bfc9                	j	236 <memmove+0x28>

0000000000000266 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 266:	1141                	addi	sp,sp,-16
 268:	e422                	sd	s0,8(sp)
 26a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 26c:	ca05                	beqz	a2,29c <memcmp+0x36>
 26e:	fff6069b          	addiw	a3,a2,-1
 272:	1682                	slli	a3,a3,0x20
 274:	9281                	srli	a3,a3,0x20
 276:	0685                	addi	a3,a3,1
 278:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 27a:	00054783          	lbu	a5,0(a0)
 27e:	0005c703          	lbu	a4,0(a1)
 282:	00e79863          	bne	a5,a4,292 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 286:	0505                	addi	a0,a0,1
    p2++;
 288:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 28a:	fed518e3          	bne	a0,a3,27a <memcmp+0x14>
  }
  return 0;
 28e:	4501                	li	a0,0
 290:	a019                	j	296 <memcmp+0x30>
      return *p1 - *p2;
 292:	40e7853b          	subw	a0,a5,a4
}
 296:	6422                	ld	s0,8(sp)
 298:	0141                	addi	sp,sp,16
 29a:	8082                	ret
  return 0;
 29c:	4501                	li	a0,0
 29e:	bfe5                	j	296 <memcmp+0x30>

00000000000002a0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2a0:	1141                	addi	sp,sp,-16
 2a2:	e406                	sd	ra,8(sp)
 2a4:	e022                	sd	s0,0(sp)
 2a6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2a8:	f67ff0ef          	jal	20e <memmove>
}
 2ac:	60a2                	ld	ra,8(sp)
 2ae:	6402                	ld	s0,0(sp)
 2b0:	0141                	addi	sp,sp,16
 2b2:	8082                	ret

00000000000002b4 <sbrk>:

char *
sbrk(int n) {
 2b4:	1141                	addi	sp,sp,-16
 2b6:	e406                	sd	ra,8(sp)
 2b8:	e022                	sd	s0,0(sp)
 2ba:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2bc:	4585                	li	a1,1
 2be:	0b2000ef          	jal	370 <sys_sbrk>
}
 2c2:	60a2                	ld	ra,8(sp)
 2c4:	6402                	ld	s0,0(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret

00000000000002ca <sbrklazy>:

char *
sbrklazy(int n) {
 2ca:	1141                	addi	sp,sp,-16
 2cc:	e406                	sd	ra,8(sp)
 2ce:	e022                	sd	s0,0(sp)
 2d0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2d2:	4589                	li	a1,2
 2d4:	09c000ef          	jal	370 <sys_sbrk>
}
 2d8:	60a2                	ld	ra,8(sp)
 2da:	6402                	ld	s0,0(sp)
 2dc:	0141                	addi	sp,sp,16
 2de:	8082                	ret

00000000000002e0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2e0:	4885                	li	a7,1
 ecall
 2e2:	00000073          	ecall
 ret
 2e6:	8082                	ret

00000000000002e8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2e8:	4889                	li	a7,2
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2f0:	488d                	li	a7,3
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2f8:	4891                	li	a7,4
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <read>:
.global read
read:
 li a7, SYS_read
 300:	4895                	li	a7,5
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <write>:
.global write
write:
 li a7, SYS_write
 308:	48c1                	li	a7,16
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <close>:
.global close
close:
 li a7, SYS_close
 310:	48d5                	li	a7,21
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <kill>:
.global kill
kill:
 li a7, SYS_kill
 318:	4899                	li	a7,6
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <exec>:
.global exec
exec:
 li a7, SYS_exec
 320:	489d                	li	a7,7
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <open>:
.global open
open:
 li a7, SYS_open
 328:	48bd                	li	a7,15
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 330:	48c5                	li	a7,17
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 338:	48c9                	li	a7,18
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 340:	48a1                	li	a7,8
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <link>:
.global link
link:
 li a7, SYS_link
 348:	48cd                	li	a7,19
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 350:	48d1                	li	a7,20
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 358:	48a5                	li	a7,9
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <dup>:
.global dup
dup:
 li a7, SYS_dup
 360:	48a9                	li	a7,10
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 368:	48ad                	li	a7,11
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 370:	48b1                	li	a7,12
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <pause>:
.global pause
pause:
 li a7, SYS_pause
 378:	48b5                	li	a7,13
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 380:	48b9                	li	a7,14
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 388:	48d9                	li	a7,22
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 390:	1101                	addi	sp,sp,-32
 392:	ec06                	sd	ra,24(sp)
 394:	e822                	sd	s0,16(sp)
 396:	1000                	addi	s0,sp,32
 398:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 39c:	4605                	li	a2,1
 39e:	fef40593          	addi	a1,s0,-17
 3a2:	f67ff0ef          	jal	308 <write>
}
 3a6:	60e2                	ld	ra,24(sp)
 3a8:	6442                	ld	s0,16(sp)
 3aa:	6105                	addi	sp,sp,32
 3ac:	8082                	ret

00000000000003ae <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3ae:	715d                	addi	sp,sp,-80
 3b0:	e486                	sd	ra,72(sp)
 3b2:	e0a2                	sd	s0,64(sp)
 3b4:	f84a                	sd	s2,48(sp)
 3b6:	0880                	addi	s0,sp,80
 3b8:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3ba:	c299                	beqz	a3,3c0 <printint+0x12>
 3bc:	0805c363          	bltz	a1,442 <printint+0x94>
  neg = 0;
 3c0:	4881                	li	a7,0
 3c2:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3c6:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3c8:	00000517          	auipc	a0,0x0
 3cc:	52850513          	addi	a0,a0,1320 # 8f0 <digits>
 3d0:	883e                	mv	a6,a5
 3d2:	2785                	addiw	a5,a5,1
 3d4:	02c5f733          	remu	a4,a1,a2
 3d8:	972a                	add	a4,a4,a0
 3da:	00074703          	lbu	a4,0(a4)
 3de:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 3e2:	872e                	mv	a4,a1
 3e4:	02c5d5b3          	divu	a1,a1,a2
 3e8:	0685                	addi	a3,a3,1
 3ea:	fec773e3          	bgeu	a4,a2,3d0 <printint+0x22>
  if(neg)
 3ee:	00088b63          	beqz	a7,404 <printint+0x56>
    buf[i++] = '-';
 3f2:	fd078793          	addi	a5,a5,-48
 3f6:	97a2                	add	a5,a5,s0
 3f8:	02d00713          	li	a4,45
 3fc:	fee78423          	sb	a4,-24(a5)
 400:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 404:	02f05a63          	blez	a5,438 <printint+0x8a>
 408:	fc26                	sd	s1,56(sp)
 40a:	f44e                	sd	s3,40(sp)
 40c:	fb840713          	addi	a4,s0,-72
 410:	00f704b3          	add	s1,a4,a5
 414:	fff70993          	addi	s3,a4,-1
 418:	99be                	add	s3,s3,a5
 41a:	37fd                	addiw	a5,a5,-1
 41c:	1782                	slli	a5,a5,0x20
 41e:	9381                	srli	a5,a5,0x20
 420:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 424:	fff4c583          	lbu	a1,-1(s1)
 428:	854a                	mv	a0,s2
 42a:	f67ff0ef          	jal	390 <putc>
  while(--i >= 0)
 42e:	14fd                	addi	s1,s1,-1
 430:	ff349ae3          	bne	s1,s3,424 <printint+0x76>
 434:	74e2                	ld	s1,56(sp)
 436:	79a2                	ld	s3,40(sp)
}
 438:	60a6                	ld	ra,72(sp)
 43a:	6406                	ld	s0,64(sp)
 43c:	7942                	ld	s2,48(sp)
 43e:	6161                	addi	sp,sp,80
 440:	8082                	ret
    x = -xx;
 442:	40b005b3          	neg	a1,a1
    neg = 1;
 446:	4885                	li	a7,1
    x = -xx;
 448:	bfad                	j	3c2 <printint+0x14>

000000000000044a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 44a:	711d                	addi	sp,sp,-96
 44c:	ec86                	sd	ra,88(sp)
 44e:	e8a2                	sd	s0,80(sp)
 450:	e0ca                	sd	s2,64(sp)
 452:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 454:	0005c903          	lbu	s2,0(a1)
 458:	28090663          	beqz	s2,6e4 <vprintf+0x29a>
 45c:	e4a6                	sd	s1,72(sp)
 45e:	fc4e                	sd	s3,56(sp)
 460:	f852                	sd	s4,48(sp)
 462:	f456                	sd	s5,40(sp)
 464:	f05a                	sd	s6,32(sp)
 466:	ec5e                	sd	s7,24(sp)
 468:	e862                	sd	s8,16(sp)
 46a:	e466                	sd	s9,8(sp)
 46c:	8b2a                	mv	s6,a0
 46e:	8a2e                	mv	s4,a1
 470:	8bb2                	mv	s7,a2
  state = 0;
 472:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 474:	4481                	li	s1,0
 476:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 478:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 47c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 480:	06c00c93          	li	s9,108
 484:	a005                	j	4a4 <vprintf+0x5a>
        putc(fd, c0);
 486:	85ca                	mv	a1,s2
 488:	855a                	mv	a0,s6
 48a:	f07ff0ef          	jal	390 <putc>
 48e:	a019                	j	494 <vprintf+0x4a>
    } else if(state == '%'){
 490:	03598263          	beq	s3,s5,4b4 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 494:	2485                	addiw	s1,s1,1
 496:	8726                	mv	a4,s1
 498:	009a07b3          	add	a5,s4,s1
 49c:	0007c903          	lbu	s2,0(a5)
 4a0:	22090a63          	beqz	s2,6d4 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 4a4:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4a8:	fe0994e3          	bnez	s3,490 <vprintf+0x46>
      if(c0 == '%'){
 4ac:	fd579de3          	bne	a5,s5,486 <vprintf+0x3c>
        state = '%';
 4b0:	89be                	mv	s3,a5
 4b2:	b7cd                	j	494 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4b4:	00ea06b3          	add	a3,s4,a4
 4b8:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4bc:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4be:	c681                	beqz	a3,4c6 <vprintf+0x7c>
 4c0:	9752                	add	a4,a4,s4
 4c2:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4c6:	05878363          	beq	a5,s8,50c <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 4ca:	05978d63          	beq	a5,s9,524 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4ce:	07500713          	li	a4,117
 4d2:	0ee78763          	beq	a5,a4,5c0 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4d6:	07800713          	li	a4,120
 4da:	12e78963          	beq	a5,a4,60c <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4de:	07000713          	li	a4,112
 4e2:	14e78e63          	beq	a5,a4,63e <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 4e6:	06300713          	li	a4,99
 4ea:	18e78e63          	beq	a5,a4,686 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 4ee:	07300713          	li	a4,115
 4f2:	1ae78463          	beq	a5,a4,69a <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 4f6:	02500713          	li	a4,37
 4fa:	04e79563          	bne	a5,a4,544 <vprintf+0xfa>
        putc(fd, '%');
 4fe:	02500593          	li	a1,37
 502:	855a                	mv	a0,s6
 504:	e8dff0ef          	jal	390 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 508:	4981                	li	s3,0
 50a:	b769                	j	494 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 50c:	008b8913          	addi	s2,s7,8
 510:	4685                	li	a3,1
 512:	4629                	li	a2,10
 514:	000ba583          	lw	a1,0(s7)
 518:	855a                	mv	a0,s6
 51a:	e95ff0ef          	jal	3ae <printint>
 51e:	8bca                	mv	s7,s2
      state = 0;
 520:	4981                	li	s3,0
 522:	bf8d                	j	494 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 524:	06400793          	li	a5,100
 528:	02f68963          	beq	a3,a5,55a <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 52c:	06c00793          	li	a5,108
 530:	04f68263          	beq	a3,a5,574 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 534:	07500793          	li	a5,117
 538:	0af68063          	beq	a3,a5,5d8 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 53c:	07800793          	li	a5,120
 540:	0ef68263          	beq	a3,a5,624 <vprintf+0x1da>
        putc(fd, '%');
 544:	02500593          	li	a1,37
 548:	855a                	mv	a0,s6
 54a:	e47ff0ef          	jal	390 <putc>
        putc(fd, c0);
 54e:	85ca                	mv	a1,s2
 550:	855a                	mv	a0,s6
 552:	e3fff0ef          	jal	390 <putc>
      state = 0;
 556:	4981                	li	s3,0
 558:	bf35                	j	494 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 55a:	008b8913          	addi	s2,s7,8
 55e:	4685                	li	a3,1
 560:	4629                	li	a2,10
 562:	000bb583          	ld	a1,0(s7)
 566:	855a                	mv	a0,s6
 568:	e47ff0ef          	jal	3ae <printint>
        i += 1;
 56c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 56e:	8bca                	mv	s7,s2
      state = 0;
 570:	4981                	li	s3,0
        i += 1;
 572:	b70d                	j	494 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 574:	06400793          	li	a5,100
 578:	02f60763          	beq	a2,a5,5a6 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 57c:	07500793          	li	a5,117
 580:	06f60963          	beq	a2,a5,5f2 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 584:	07800793          	li	a5,120
 588:	faf61ee3          	bne	a2,a5,544 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 58c:	008b8913          	addi	s2,s7,8
 590:	4681                	li	a3,0
 592:	4641                	li	a2,16
 594:	000bb583          	ld	a1,0(s7)
 598:	855a                	mv	a0,s6
 59a:	e15ff0ef          	jal	3ae <printint>
        i += 2;
 59e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5a0:	8bca                	mv	s7,s2
      state = 0;
 5a2:	4981                	li	s3,0
        i += 2;
 5a4:	bdc5                	j	494 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a6:	008b8913          	addi	s2,s7,8
 5aa:	4685                	li	a3,1
 5ac:	4629                	li	a2,10
 5ae:	000bb583          	ld	a1,0(s7)
 5b2:	855a                	mv	a0,s6
 5b4:	dfbff0ef          	jal	3ae <printint>
        i += 2;
 5b8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ba:	8bca                	mv	s7,s2
      state = 0;
 5bc:	4981                	li	s3,0
        i += 2;
 5be:	bdd9                	j	494 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5c0:	008b8913          	addi	s2,s7,8
 5c4:	4681                	li	a3,0
 5c6:	4629                	li	a2,10
 5c8:	000be583          	lwu	a1,0(s7)
 5cc:	855a                	mv	a0,s6
 5ce:	de1ff0ef          	jal	3ae <printint>
 5d2:	8bca                	mv	s7,s2
      state = 0;
 5d4:	4981                	li	s3,0
 5d6:	bd7d                	j	494 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d8:	008b8913          	addi	s2,s7,8
 5dc:	4681                	li	a3,0
 5de:	4629                	li	a2,10
 5e0:	000bb583          	ld	a1,0(s7)
 5e4:	855a                	mv	a0,s6
 5e6:	dc9ff0ef          	jal	3ae <printint>
        i += 1;
 5ea:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ec:	8bca                	mv	s7,s2
      state = 0;
 5ee:	4981                	li	s3,0
        i += 1;
 5f0:	b555                	j	494 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f2:	008b8913          	addi	s2,s7,8
 5f6:	4681                	li	a3,0
 5f8:	4629                	li	a2,10
 5fa:	000bb583          	ld	a1,0(s7)
 5fe:	855a                	mv	a0,s6
 600:	dafff0ef          	jal	3ae <printint>
        i += 2;
 604:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 606:	8bca                	mv	s7,s2
      state = 0;
 608:	4981                	li	s3,0
        i += 2;
 60a:	b569                	j	494 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 60c:	008b8913          	addi	s2,s7,8
 610:	4681                	li	a3,0
 612:	4641                	li	a2,16
 614:	000be583          	lwu	a1,0(s7)
 618:	855a                	mv	a0,s6
 61a:	d95ff0ef          	jal	3ae <printint>
 61e:	8bca                	mv	s7,s2
      state = 0;
 620:	4981                	li	s3,0
 622:	bd8d                	j	494 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 624:	008b8913          	addi	s2,s7,8
 628:	4681                	li	a3,0
 62a:	4641                	li	a2,16
 62c:	000bb583          	ld	a1,0(s7)
 630:	855a                	mv	a0,s6
 632:	d7dff0ef          	jal	3ae <printint>
        i += 1;
 636:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 638:	8bca                	mv	s7,s2
      state = 0;
 63a:	4981                	li	s3,0
        i += 1;
 63c:	bda1                	j	494 <vprintf+0x4a>
 63e:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 640:	008b8d13          	addi	s10,s7,8
 644:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 648:	03000593          	li	a1,48
 64c:	855a                	mv	a0,s6
 64e:	d43ff0ef          	jal	390 <putc>
  putc(fd, 'x');
 652:	07800593          	li	a1,120
 656:	855a                	mv	a0,s6
 658:	d39ff0ef          	jal	390 <putc>
 65c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 65e:	00000b97          	auipc	s7,0x0
 662:	292b8b93          	addi	s7,s7,658 # 8f0 <digits>
 666:	03c9d793          	srli	a5,s3,0x3c
 66a:	97de                	add	a5,a5,s7
 66c:	0007c583          	lbu	a1,0(a5)
 670:	855a                	mv	a0,s6
 672:	d1fff0ef          	jal	390 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 676:	0992                	slli	s3,s3,0x4
 678:	397d                	addiw	s2,s2,-1
 67a:	fe0916e3          	bnez	s2,666 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 67e:	8bea                	mv	s7,s10
      state = 0;
 680:	4981                	li	s3,0
 682:	6d02                	ld	s10,0(sp)
 684:	bd01                	j	494 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 686:	008b8913          	addi	s2,s7,8
 68a:	000bc583          	lbu	a1,0(s7)
 68e:	855a                	mv	a0,s6
 690:	d01ff0ef          	jal	390 <putc>
 694:	8bca                	mv	s7,s2
      state = 0;
 696:	4981                	li	s3,0
 698:	bbf5                	j	494 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 69a:	008b8993          	addi	s3,s7,8
 69e:	000bb903          	ld	s2,0(s7)
 6a2:	00090f63          	beqz	s2,6c0 <vprintf+0x276>
        for(; *s; s++)
 6a6:	00094583          	lbu	a1,0(s2)
 6aa:	c195                	beqz	a1,6ce <vprintf+0x284>
          putc(fd, *s);
 6ac:	855a                	mv	a0,s6
 6ae:	ce3ff0ef          	jal	390 <putc>
        for(; *s; s++)
 6b2:	0905                	addi	s2,s2,1
 6b4:	00094583          	lbu	a1,0(s2)
 6b8:	f9f5                	bnez	a1,6ac <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6ba:	8bce                	mv	s7,s3
      state = 0;
 6bc:	4981                	li	s3,0
 6be:	bbd9                	j	494 <vprintf+0x4a>
          s = "(null)";
 6c0:	00000917          	auipc	s2,0x0
 6c4:	22890913          	addi	s2,s2,552 # 8e8 <malloc+0x11c>
        for(; *s; s++)
 6c8:	02800593          	li	a1,40
 6cc:	b7c5                	j	6ac <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6ce:	8bce                	mv	s7,s3
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	b3c9                	j	494 <vprintf+0x4a>
 6d4:	64a6                	ld	s1,72(sp)
 6d6:	79e2                	ld	s3,56(sp)
 6d8:	7a42                	ld	s4,48(sp)
 6da:	7aa2                	ld	s5,40(sp)
 6dc:	7b02                	ld	s6,32(sp)
 6de:	6be2                	ld	s7,24(sp)
 6e0:	6c42                	ld	s8,16(sp)
 6e2:	6ca2                	ld	s9,8(sp)
    }
  }
}
 6e4:	60e6                	ld	ra,88(sp)
 6e6:	6446                	ld	s0,80(sp)
 6e8:	6906                	ld	s2,64(sp)
 6ea:	6125                	addi	sp,sp,96
 6ec:	8082                	ret

00000000000006ee <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6ee:	715d                	addi	sp,sp,-80
 6f0:	ec06                	sd	ra,24(sp)
 6f2:	e822                	sd	s0,16(sp)
 6f4:	1000                	addi	s0,sp,32
 6f6:	e010                	sd	a2,0(s0)
 6f8:	e414                	sd	a3,8(s0)
 6fa:	e818                	sd	a4,16(s0)
 6fc:	ec1c                	sd	a5,24(s0)
 6fe:	03043023          	sd	a6,32(s0)
 702:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 706:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 70a:	8622                	mv	a2,s0
 70c:	d3fff0ef          	jal	44a <vprintf>
}
 710:	60e2                	ld	ra,24(sp)
 712:	6442                	ld	s0,16(sp)
 714:	6161                	addi	sp,sp,80
 716:	8082                	ret

0000000000000718 <printf>:

void
printf(const char *fmt, ...)
{
 718:	711d                	addi	sp,sp,-96
 71a:	ec06                	sd	ra,24(sp)
 71c:	e822                	sd	s0,16(sp)
 71e:	1000                	addi	s0,sp,32
 720:	e40c                	sd	a1,8(s0)
 722:	e810                	sd	a2,16(s0)
 724:	ec14                	sd	a3,24(s0)
 726:	f018                	sd	a4,32(s0)
 728:	f41c                	sd	a5,40(s0)
 72a:	03043823          	sd	a6,48(s0)
 72e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 732:	00840613          	addi	a2,s0,8
 736:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 73a:	85aa                	mv	a1,a0
 73c:	4505                	li	a0,1
 73e:	d0dff0ef          	jal	44a <vprintf>
}
 742:	60e2                	ld	ra,24(sp)
 744:	6442                	ld	s0,16(sp)
 746:	6125                	addi	sp,sp,96
 748:	8082                	ret

000000000000074a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 74a:	1141                	addi	sp,sp,-16
 74c:	e422                	sd	s0,8(sp)
 74e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 750:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 754:	00001797          	auipc	a5,0x1
 758:	8ac7b783          	ld	a5,-1876(a5) # 1000 <freep>
 75c:	a02d                	j	786 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 75e:	4618                	lw	a4,8(a2)
 760:	9f2d                	addw	a4,a4,a1
 762:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 766:	6398                	ld	a4,0(a5)
 768:	6310                	ld	a2,0(a4)
 76a:	a83d                	j	7a8 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 76c:	ff852703          	lw	a4,-8(a0)
 770:	9f31                	addw	a4,a4,a2
 772:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 774:	ff053683          	ld	a3,-16(a0)
 778:	a091                	j	7bc <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 77a:	6398                	ld	a4,0(a5)
 77c:	00e7e463          	bltu	a5,a4,784 <free+0x3a>
 780:	00e6ea63          	bltu	a3,a4,794 <free+0x4a>
{
 784:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 786:	fed7fae3          	bgeu	a5,a3,77a <free+0x30>
 78a:	6398                	ld	a4,0(a5)
 78c:	00e6e463          	bltu	a3,a4,794 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 790:	fee7eae3          	bltu	a5,a4,784 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 794:	ff852583          	lw	a1,-8(a0)
 798:	6390                	ld	a2,0(a5)
 79a:	02059813          	slli	a6,a1,0x20
 79e:	01c85713          	srli	a4,a6,0x1c
 7a2:	9736                	add	a4,a4,a3
 7a4:	fae60de3          	beq	a2,a4,75e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7a8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7ac:	4790                	lw	a2,8(a5)
 7ae:	02061593          	slli	a1,a2,0x20
 7b2:	01c5d713          	srli	a4,a1,0x1c
 7b6:	973e                	add	a4,a4,a5
 7b8:	fae68ae3          	beq	a3,a4,76c <free+0x22>
    p->s.ptr = bp->s.ptr;
 7bc:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7be:	00001717          	auipc	a4,0x1
 7c2:	84f73123          	sd	a5,-1982(a4) # 1000 <freep>
}
 7c6:	6422                	ld	s0,8(sp)
 7c8:	0141                	addi	sp,sp,16
 7ca:	8082                	ret

00000000000007cc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7cc:	7139                	addi	sp,sp,-64
 7ce:	fc06                	sd	ra,56(sp)
 7d0:	f822                	sd	s0,48(sp)
 7d2:	f426                	sd	s1,40(sp)
 7d4:	ec4e                	sd	s3,24(sp)
 7d6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7d8:	02051493          	slli	s1,a0,0x20
 7dc:	9081                	srli	s1,s1,0x20
 7de:	04bd                	addi	s1,s1,15
 7e0:	8091                	srli	s1,s1,0x4
 7e2:	0014899b          	addiw	s3,s1,1
 7e6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7e8:	00001517          	auipc	a0,0x1
 7ec:	81853503          	ld	a0,-2024(a0) # 1000 <freep>
 7f0:	c915                	beqz	a0,824 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7f4:	4798                	lw	a4,8(a5)
 7f6:	08977a63          	bgeu	a4,s1,88a <malloc+0xbe>
 7fa:	f04a                	sd	s2,32(sp)
 7fc:	e852                	sd	s4,16(sp)
 7fe:	e456                	sd	s5,8(sp)
 800:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 802:	8a4e                	mv	s4,s3
 804:	0009871b          	sext.w	a4,s3
 808:	6685                	lui	a3,0x1
 80a:	00d77363          	bgeu	a4,a3,810 <malloc+0x44>
 80e:	6a05                	lui	s4,0x1
 810:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 814:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 818:	00000917          	auipc	s2,0x0
 81c:	7e890913          	addi	s2,s2,2024 # 1000 <freep>
  if(p == SBRK_ERROR)
 820:	5afd                	li	s5,-1
 822:	a081                	j	862 <malloc+0x96>
 824:	f04a                	sd	s2,32(sp)
 826:	e852                	sd	s4,16(sp)
 828:	e456                	sd	s5,8(sp)
 82a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 82c:	00000797          	auipc	a5,0x0
 830:	7e478793          	addi	a5,a5,2020 # 1010 <base>
 834:	00000717          	auipc	a4,0x0
 838:	7cf73623          	sd	a5,1996(a4) # 1000 <freep>
 83c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 83e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 842:	b7c1                	j	802 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 844:	6398                	ld	a4,0(a5)
 846:	e118                	sd	a4,0(a0)
 848:	a8a9                	j	8a2 <malloc+0xd6>
  hp->s.size = nu;
 84a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 84e:	0541                	addi	a0,a0,16
 850:	efbff0ef          	jal	74a <free>
  return freep;
 854:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 858:	c12d                	beqz	a0,8ba <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 85a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 85c:	4798                	lw	a4,8(a5)
 85e:	02977263          	bgeu	a4,s1,882 <malloc+0xb6>
    if(p == freep)
 862:	00093703          	ld	a4,0(s2)
 866:	853e                	mv	a0,a5
 868:	fef719e3          	bne	a4,a5,85a <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 86c:	8552                	mv	a0,s4
 86e:	a47ff0ef          	jal	2b4 <sbrk>
  if(p == SBRK_ERROR)
 872:	fd551ce3          	bne	a0,s5,84a <malloc+0x7e>
        return 0;
 876:	4501                	li	a0,0
 878:	7902                	ld	s2,32(sp)
 87a:	6a42                	ld	s4,16(sp)
 87c:	6aa2                	ld	s5,8(sp)
 87e:	6b02                	ld	s6,0(sp)
 880:	a03d                	j	8ae <malloc+0xe2>
 882:	7902                	ld	s2,32(sp)
 884:	6a42                	ld	s4,16(sp)
 886:	6aa2                	ld	s5,8(sp)
 888:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 88a:	fae48de3          	beq	s1,a4,844 <malloc+0x78>
        p->s.size -= nunits;
 88e:	4137073b          	subw	a4,a4,s3
 892:	c798                	sw	a4,8(a5)
        p += p->s.size;
 894:	02071693          	slli	a3,a4,0x20
 898:	01c6d713          	srli	a4,a3,0x1c
 89c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 89e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8a2:	00000717          	auipc	a4,0x0
 8a6:	74a73f23          	sd	a0,1886(a4) # 1000 <freep>
      return (void*)(p + 1);
 8aa:	01078513          	addi	a0,a5,16
  }
}
 8ae:	70e2                	ld	ra,56(sp)
 8b0:	7442                	ld	s0,48(sp)
 8b2:	74a2                	ld	s1,40(sp)
 8b4:	69e2                	ld	s3,24(sp)
 8b6:	6121                	addi	sp,sp,64
 8b8:	8082                	ret
 8ba:	7902                	ld	s2,32(sp)
 8bc:	6a42                	ld	s4,16(sp)
 8be:	6aa2                	ld	s5,8(sp)
 8c0:	6b02                	ld	s6,0(sp)
 8c2:	b7f5                	j	8ae <malloc+0xe2>
