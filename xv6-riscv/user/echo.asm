
user/_echo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	0080                	addi	s0,sp,64
  int i;

  for(i = 1; i < argc; i++){
  12:	4785                	li	a5,1
  14:	06a7d063          	bge	a5,a0,74 <main+0x74>
  18:	00858493          	addi	s1,a1,8
  1c:	3579                	addiw	a0,a0,-2
  1e:	02051793          	slli	a5,a0,0x20
  22:	01d7d513          	srli	a0,a5,0x1d
  26:	00a48a33          	add	s4,s1,a0
  2a:	05c1                	addi	a1,a1,16
  2c:	00a589b3          	add	s3,a1,a0
    write(1, argv[i], strlen(argv[i]));
    if(i + 1 < argc){
      write(1, " ", 1);
  30:	00001a97          	auipc	s5,0x1
  34:	8c0a8a93          	addi	s5,s5,-1856 # 8f0 <malloc+0xfe>
  38:	a809                	j	4a <main+0x4a>
  3a:	4605                	li	a2,1
  3c:	85d6                	mv	a1,s5
  3e:	4505                	li	a0,1
  40:	2ee000ef          	jal	32e <write>
  for(i = 1; i < argc; i++){
  44:	04a1                	addi	s1,s1,8
  46:	03348763          	beq	s1,s3,74 <main+0x74>
    write(1, argv[i], strlen(argv[i]));
  4a:	0004b903          	ld	s2,0(s1)
  4e:	854a                	mv	a0,s2
  50:	082000ef          	jal	d2 <strlen>
  54:	0005061b          	sext.w	a2,a0
  58:	85ca                	mv	a1,s2
  5a:	4505                	li	a0,1
  5c:	2d2000ef          	jal	32e <write>
    if(i + 1 < argc){
  60:	fd449de3          	bne	s1,s4,3a <main+0x3a>
    } else {
      write(1, "\n", 1);
  64:	4605                	li	a2,1
  66:	00001597          	auipc	a1,0x1
  6a:	89258593          	addi	a1,a1,-1902 # 8f8 <malloc+0x106>
  6e:	4505                	li	a0,1
  70:	2be000ef          	jal	32e <write>
    }
  }
  exit(0);
  74:	4501                	li	a0,0
  76:	298000ef          	jal	30e <exit>

000000000000007a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  7a:	1141                	addi	sp,sp,-16
  7c:	e406                	sd	ra,8(sp)
  7e:	e022                	sd	s0,0(sp)
  80:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  82:	f7fff0ef          	jal	0 <main>
  exit(r);
  86:	288000ef          	jal	30e <exit>

000000000000008a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  8a:	1141                	addi	sp,sp,-16
  8c:	e422                	sd	s0,8(sp)
  8e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  90:	87aa                	mv	a5,a0
  92:	0585                	addi	a1,a1,1
  94:	0785                	addi	a5,a5,1
  96:	fff5c703          	lbu	a4,-1(a1)
  9a:	fee78fa3          	sb	a4,-1(a5)
  9e:	fb75                	bnez	a4,92 <strcpy+0x8>
    ;
  return os;
}
  a0:	6422                	ld	s0,8(sp)
  a2:	0141                	addi	sp,sp,16
  a4:	8082                	ret

00000000000000a6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a6:	1141                	addi	sp,sp,-16
  a8:	e422                	sd	s0,8(sp)
  aa:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ac:	00054783          	lbu	a5,0(a0)
  b0:	cb91                	beqz	a5,c4 <strcmp+0x1e>
  b2:	0005c703          	lbu	a4,0(a1)
  b6:	00f71763          	bne	a4,a5,c4 <strcmp+0x1e>
    p++, q++;
  ba:	0505                	addi	a0,a0,1
  bc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  be:	00054783          	lbu	a5,0(a0)
  c2:	fbe5                	bnez	a5,b2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  c4:	0005c503          	lbu	a0,0(a1)
}
  c8:	40a7853b          	subw	a0,a5,a0
  cc:	6422                	ld	s0,8(sp)
  ce:	0141                	addi	sp,sp,16
  d0:	8082                	ret

00000000000000d2 <strlen>:

uint
strlen(const char *s)
{
  d2:	1141                	addi	sp,sp,-16
  d4:	e422                	sd	s0,8(sp)
  d6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  d8:	00054783          	lbu	a5,0(a0)
  dc:	cf91                	beqz	a5,f8 <strlen+0x26>
  de:	0505                	addi	a0,a0,1
  e0:	87aa                	mv	a5,a0
  e2:	86be                	mv	a3,a5
  e4:	0785                	addi	a5,a5,1
  e6:	fff7c703          	lbu	a4,-1(a5)
  ea:	ff65                	bnez	a4,e2 <strlen+0x10>
  ec:	40a6853b          	subw	a0,a3,a0
  f0:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  f2:	6422                	ld	s0,8(sp)
  f4:	0141                	addi	sp,sp,16
  f6:	8082                	ret
  for(n = 0; s[n]; n++)
  f8:	4501                	li	a0,0
  fa:	bfe5                	j	f2 <strlen+0x20>

00000000000000fc <memset>:

void*
memset(void *dst, int c, uint n)
{
  fc:	1141                	addi	sp,sp,-16
  fe:	e422                	sd	s0,8(sp)
 100:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 102:	ca19                	beqz	a2,118 <memset+0x1c>
 104:	87aa                	mv	a5,a0
 106:	1602                	slli	a2,a2,0x20
 108:	9201                	srli	a2,a2,0x20
 10a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 10e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 112:	0785                	addi	a5,a5,1
 114:	fee79de3          	bne	a5,a4,10e <memset+0x12>
  }
  return dst;
}
 118:	6422                	ld	s0,8(sp)
 11a:	0141                	addi	sp,sp,16
 11c:	8082                	ret

000000000000011e <strchr>:

char*
strchr(const char *s, char c)
{
 11e:	1141                	addi	sp,sp,-16
 120:	e422                	sd	s0,8(sp)
 122:	0800                	addi	s0,sp,16
  for(; *s; s++)
 124:	00054783          	lbu	a5,0(a0)
 128:	cb99                	beqz	a5,13e <strchr+0x20>
    if(*s == c)
 12a:	00f58763          	beq	a1,a5,138 <strchr+0x1a>
  for(; *s; s++)
 12e:	0505                	addi	a0,a0,1
 130:	00054783          	lbu	a5,0(a0)
 134:	fbfd                	bnez	a5,12a <strchr+0xc>
      return (char*)s;
  return 0;
 136:	4501                	li	a0,0
}
 138:	6422                	ld	s0,8(sp)
 13a:	0141                	addi	sp,sp,16
 13c:	8082                	ret
  return 0;
 13e:	4501                	li	a0,0
 140:	bfe5                	j	138 <strchr+0x1a>

0000000000000142 <gets>:

char*
gets(char *buf, int max)
{
 142:	711d                	addi	sp,sp,-96
 144:	ec86                	sd	ra,88(sp)
 146:	e8a2                	sd	s0,80(sp)
 148:	e4a6                	sd	s1,72(sp)
 14a:	e0ca                	sd	s2,64(sp)
 14c:	fc4e                	sd	s3,56(sp)
 14e:	f852                	sd	s4,48(sp)
 150:	f456                	sd	s5,40(sp)
 152:	f05a                	sd	s6,32(sp)
 154:	ec5e                	sd	s7,24(sp)
 156:	1080                	addi	s0,sp,96
 158:	8baa                	mv	s7,a0
 15a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 15c:	892a                	mv	s2,a0
 15e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 160:	4aa9                	li	s5,10
 162:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 164:	89a6                	mv	s3,s1
 166:	2485                	addiw	s1,s1,1
 168:	0344d663          	bge	s1,s4,194 <gets+0x52>
    cc = read(0, &c, 1);
 16c:	4605                	li	a2,1
 16e:	faf40593          	addi	a1,s0,-81
 172:	4501                	li	a0,0
 174:	1b2000ef          	jal	326 <read>
    if(cc < 1)
 178:	00a05e63          	blez	a0,194 <gets+0x52>
    buf[i++] = c;
 17c:	faf44783          	lbu	a5,-81(s0)
 180:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 184:	01578763          	beq	a5,s5,192 <gets+0x50>
 188:	0905                	addi	s2,s2,1
 18a:	fd679de3          	bne	a5,s6,164 <gets+0x22>
    buf[i++] = c;
 18e:	89a6                	mv	s3,s1
 190:	a011                	j	194 <gets+0x52>
 192:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 194:	99de                	add	s3,s3,s7
 196:	00098023          	sb	zero,0(s3)
  return buf;
}
 19a:	855e                	mv	a0,s7
 19c:	60e6                	ld	ra,88(sp)
 19e:	6446                	ld	s0,80(sp)
 1a0:	64a6                	ld	s1,72(sp)
 1a2:	6906                	ld	s2,64(sp)
 1a4:	79e2                	ld	s3,56(sp)
 1a6:	7a42                	ld	s4,48(sp)
 1a8:	7aa2                	ld	s5,40(sp)
 1aa:	7b02                	ld	s6,32(sp)
 1ac:	6be2                	ld	s7,24(sp)
 1ae:	6125                	addi	sp,sp,96
 1b0:	8082                	ret

00000000000001b2 <stat>:

int
stat(const char *n, struct stat *st)
{
 1b2:	1101                	addi	sp,sp,-32
 1b4:	ec06                	sd	ra,24(sp)
 1b6:	e822                	sd	s0,16(sp)
 1b8:	e04a                	sd	s2,0(sp)
 1ba:	1000                	addi	s0,sp,32
 1bc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1be:	4581                	li	a1,0
 1c0:	18e000ef          	jal	34e <open>
  if(fd < 0)
 1c4:	02054263          	bltz	a0,1e8 <stat+0x36>
 1c8:	e426                	sd	s1,8(sp)
 1ca:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1cc:	85ca                	mv	a1,s2
 1ce:	198000ef          	jal	366 <fstat>
 1d2:	892a                	mv	s2,a0
  close(fd);
 1d4:	8526                	mv	a0,s1
 1d6:	160000ef          	jal	336 <close>
  return r;
 1da:	64a2                	ld	s1,8(sp)
}
 1dc:	854a                	mv	a0,s2
 1de:	60e2                	ld	ra,24(sp)
 1e0:	6442                	ld	s0,16(sp)
 1e2:	6902                	ld	s2,0(sp)
 1e4:	6105                	addi	sp,sp,32
 1e6:	8082                	ret
    return -1;
 1e8:	597d                	li	s2,-1
 1ea:	bfcd                	j	1dc <stat+0x2a>

00000000000001ec <atoi>:

int
atoi(const char *s)
{
 1ec:	1141                	addi	sp,sp,-16
 1ee:	e422                	sd	s0,8(sp)
 1f0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1f2:	00054683          	lbu	a3,0(a0)
 1f6:	fd06879b          	addiw	a5,a3,-48
 1fa:	0ff7f793          	zext.b	a5,a5
 1fe:	4625                	li	a2,9
 200:	02f66863          	bltu	a2,a5,230 <atoi+0x44>
 204:	872a                	mv	a4,a0
  n = 0;
 206:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 208:	0705                	addi	a4,a4,1
 20a:	0025179b          	slliw	a5,a0,0x2
 20e:	9fa9                	addw	a5,a5,a0
 210:	0017979b          	slliw	a5,a5,0x1
 214:	9fb5                	addw	a5,a5,a3
 216:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 21a:	00074683          	lbu	a3,0(a4)
 21e:	fd06879b          	addiw	a5,a3,-48
 222:	0ff7f793          	zext.b	a5,a5
 226:	fef671e3          	bgeu	a2,a5,208 <atoi+0x1c>
  return n;
}
 22a:	6422                	ld	s0,8(sp)
 22c:	0141                	addi	sp,sp,16
 22e:	8082                	ret
  n = 0;
 230:	4501                	li	a0,0
 232:	bfe5                	j	22a <atoi+0x3e>

0000000000000234 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 234:	1141                	addi	sp,sp,-16
 236:	e422                	sd	s0,8(sp)
 238:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 23a:	02b57463          	bgeu	a0,a1,262 <memmove+0x2e>
    while(n-- > 0)
 23e:	00c05f63          	blez	a2,25c <memmove+0x28>
 242:	1602                	slli	a2,a2,0x20
 244:	9201                	srli	a2,a2,0x20
 246:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 24a:	872a                	mv	a4,a0
      *dst++ = *src++;
 24c:	0585                	addi	a1,a1,1
 24e:	0705                	addi	a4,a4,1
 250:	fff5c683          	lbu	a3,-1(a1)
 254:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 258:	fef71ae3          	bne	a4,a5,24c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 25c:	6422                	ld	s0,8(sp)
 25e:	0141                	addi	sp,sp,16
 260:	8082                	ret
    dst += n;
 262:	00c50733          	add	a4,a0,a2
    src += n;
 266:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 268:	fec05ae3          	blez	a2,25c <memmove+0x28>
 26c:	fff6079b          	addiw	a5,a2,-1
 270:	1782                	slli	a5,a5,0x20
 272:	9381                	srli	a5,a5,0x20
 274:	fff7c793          	not	a5,a5
 278:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 27a:	15fd                	addi	a1,a1,-1
 27c:	177d                	addi	a4,a4,-1
 27e:	0005c683          	lbu	a3,0(a1)
 282:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 286:	fee79ae3          	bne	a5,a4,27a <memmove+0x46>
 28a:	bfc9                	j	25c <memmove+0x28>

000000000000028c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 28c:	1141                	addi	sp,sp,-16
 28e:	e422                	sd	s0,8(sp)
 290:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 292:	ca05                	beqz	a2,2c2 <memcmp+0x36>
 294:	fff6069b          	addiw	a3,a2,-1
 298:	1682                	slli	a3,a3,0x20
 29a:	9281                	srli	a3,a3,0x20
 29c:	0685                	addi	a3,a3,1
 29e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2a0:	00054783          	lbu	a5,0(a0)
 2a4:	0005c703          	lbu	a4,0(a1)
 2a8:	00e79863          	bne	a5,a4,2b8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2ac:	0505                	addi	a0,a0,1
    p2++;
 2ae:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2b0:	fed518e3          	bne	a0,a3,2a0 <memcmp+0x14>
  }
  return 0;
 2b4:	4501                	li	a0,0
 2b6:	a019                	j	2bc <memcmp+0x30>
      return *p1 - *p2;
 2b8:	40e7853b          	subw	a0,a5,a4
}
 2bc:	6422                	ld	s0,8(sp)
 2be:	0141                	addi	sp,sp,16
 2c0:	8082                	ret
  return 0;
 2c2:	4501                	li	a0,0
 2c4:	bfe5                	j	2bc <memcmp+0x30>

00000000000002c6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2c6:	1141                	addi	sp,sp,-16
 2c8:	e406                	sd	ra,8(sp)
 2ca:	e022                	sd	s0,0(sp)
 2cc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2ce:	f67ff0ef          	jal	234 <memmove>
}
 2d2:	60a2                	ld	ra,8(sp)
 2d4:	6402                	ld	s0,0(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret

00000000000002da <sbrk>:

char *
sbrk(int n) {
 2da:	1141                	addi	sp,sp,-16
 2dc:	e406                	sd	ra,8(sp)
 2de:	e022                	sd	s0,0(sp)
 2e0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2e2:	4585                	li	a1,1
 2e4:	0b2000ef          	jal	396 <sys_sbrk>
}
 2e8:	60a2                	ld	ra,8(sp)
 2ea:	6402                	ld	s0,0(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret

00000000000002f0 <sbrklazy>:

char *
sbrklazy(int n) {
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e406                	sd	ra,8(sp)
 2f4:	e022                	sd	s0,0(sp)
 2f6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2f8:	4589                	li	a1,2
 2fa:	09c000ef          	jal	396 <sys_sbrk>
}
 2fe:	60a2                	ld	ra,8(sp)
 300:	6402                	ld	s0,0(sp)
 302:	0141                	addi	sp,sp,16
 304:	8082                	ret

0000000000000306 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 306:	4885                	li	a7,1
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <exit>:
.global exit
exit:
 li a7, SYS_exit
 30e:	4889                	li	a7,2
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <wait>:
.global wait
wait:
 li a7, SYS_wait
 316:	488d                	li	a7,3
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 31e:	4891                	li	a7,4
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <read>:
.global read
read:
 li a7, SYS_read
 326:	4895                	li	a7,5
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <write>:
.global write
write:
 li a7, SYS_write
 32e:	48c1                	li	a7,16
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <close>:
.global close
close:
 li a7, SYS_close
 336:	48d5                	li	a7,21
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <kill>:
.global kill
kill:
 li a7, SYS_kill
 33e:	4899                	li	a7,6
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <exec>:
.global exec
exec:
 li a7, SYS_exec
 346:	489d                	li	a7,7
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <open>:
.global open
open:
 li a7, SYS_open
 34e:	48bd                	li	a7,15
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 356:	48c5                	li	a7,17
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 35e:	48c9                	li	a7,18
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 366:	48a1                	li	a7,8
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <link>:
.global link
link:
 li a7, SYS_link
 36e:	48cd                	li	a7,19
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 376:	48d1                	li	a7,20
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 37e:	48a5                	li	a7,9
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <dup>:
.global dup
dup:
 li a7, SYS_dup
 386:	48a9                	li	a7,10
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 38e:	48ad                	li	a7,11
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 396:	48b1                	li	a7,12
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <pause>:
.global pause
pause:
 li a7, SYS_pause
 39e:	48b5                	li	a7,13
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3a6:	48b9                	li	a7,14
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 3ae:	48d9                	li	a7,22
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3b6:	1101                	addi	sp,sp,-32
 3b8:	ec06                	sd	ra,24(sp)
 3ba:	e822                	sd	s0,16(sp)
 3bc:	1000                	addi	s0,sp,32
 3be:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3c2:	4605                	li	a2,1
 3c4:	fef40593          	addi	a1,s0,-17
 3c8:	f67ff0ef          	jal	32e <write>
}
 3cc:	60e2                	ld	ra,24(sp)
 3ce:	6442                	ld	s0,16(sp)
 3d0:	6105                	addi	sp,sp,32
 3d2:	8082                	ret

00000000000003d4 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3d4:	715d                	addi	sp,sp,-80
 3d6:	e486                	sd	ra,72(sp)
 3d8:	e0a2                	sd	s0,64(sp)
 3da:	f84a                	sd	s2,48(sp)
 3dc:	0880                	addi	s0,sp,80
 3de:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3e0:	c299                	beqz	a3,3e6 <printint+0x12>
 3e2:	0805c363          	bltz	a1,468 <printint+0x94>
  neg = 0;
 3e6:	4881                	li	a7,0
 3e8:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3ec:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3ee:	00000517          	auipc	a0,0x0
 3f2:	51a50513          	addi	a0,a0,1306 # 908 <digits>
 3f6:	883e                	mv	a6,a5
 3f8:	2785                	addiw	a5,a5,1
 3fa:	02c5f733          	remu	a4,a1,a2
 3fe:	972a                	add	a4,a4,a0
 400:	00074703          	lbu	a4,0(a4)
 404:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 408:	872e                	mv	a4,a1
 40a:	02c5d5b3          	divu	a1,a1,a2
 40e:	0685                	addi	a3,a3,1
 410:	fec773e3          	bgeu	a4,a2,3f6 <printint+0x22>
  if(neg)
 414:	00088b63          	beqz	a7,42a <printint+0x56>
    buf[i++] = '-';
 418:	fd078793          	addi	a5,a5,-48
 41c:	97a2                	add	a5,a5,s0
 41e:	02d00713          	li	a4,45
 422:	fee78423          	sb	a4,-24(a5)
 426:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 42a:	02f05a63          	blez	a5,45e <printint+0x8a>
 42e:	fc26                	sd	s1,56(sp)
 430:	f44e                	sd	s3,40(sp)
 432:	fb840713          	addi	a4,s0,-72
 436:	00f704b3          	add	s1,a4,a5
 43a:	fff70993          	addi	s3,a4,-1
 43e:	99be                	add	s3,s3,a5
 440:	37fd                	addiw	a5,a5,-1
 442:	1782                	slli	a5,a5,0x20
 444:	9381                	srli	a5,a5,0x20
 446:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 44a:	fff4c583          	lbu	a1,-1(s1)
 44e:	854a                	mv	a0,s2
 450:	f67ff0ef          	jal	3b6 <putc>
  while(--i >= 0)
 454:	14fd                	addi	s1,s1,-1
 456:	ff349ae3          	bne	s1,s3,44a <printint+0x76>
 45a:	74e2                	ld	s1,56(sp)
 45c:	79a2                	ld	s3,40(sp)
}
 45e:	60a6                	ld	ra,72(sp)
 460:	6406                	ld	s0,64(sp)
 462:	7942                	ld	s2,48(sp)
 464:	6161                	addi	sp,sp,80
 466:	8082                	ret
    x = -xx;
 468:	40b005b3          	neg	a1,a1
    neg = 1;
 46c:	4885                	li	a7,1
    x = -xx;
 46e:	bfad                	j	3e8 <printint+0x14>

0000000000000470 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 470:	711d                	addi	sp,sp,-96
 472:	ec86                	sd	ra,88(sp)
 474:	e8a2                	sd	s0,80(sp)
 476:	e0ca                	sd	s2,64(sp)
 478:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 47a:	0005c903          	lbu	s2,0(a1)
 47e:	28090663          	beqz	s2,70a <vprintf+0x29a>
 482:	e4a6                	sd	s1,72(sp)
 484:	fc4e                	sd	s3,56(sp)
 486:	f852                	sd	s4,48(sp)
 488:	f456                	sd	s5,40(sp)
 48a:	f05a                	sd	s6,32(sp)
 48c:	ec5e                	sd	s7,24(sp)
 48e:	e862                	sd	s8,16(sp)
 490:	e466                	sd	s9,8(sp)
 492:	8b2a                	mv	s6,a0
 494:	8a2e                	mv	s4,a1
 496:	8bb2                	mv	s7,a2
  state = 0;
 498:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 49a:	4481                	li	s1,0
 49c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 49e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4a2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4a6:	06c00c93          	li	s9,108
 4aa:	a005                	j	4ca <vprintf+0x5a>
        putc(fd, c0);
 4ac:	85ca                	mv	a1,s2
 4ae:	855a                	mv	a0,s6
 4b0:	f07ff0ef          	jal	3b6 <putc>
 4b4:	a019                	j	4ba <vprintf+0x4a>
    } else if(state == '%'){
 4b6:	03598263          	beq	s3,s5,4da <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 4ba:	2485                	addiw	s1,s1,1
 4bc:	8726                	mv	a4,s1
 4be:	009a07b3          	add	a5,s4,s1
 4c2:	0007c903          	lbu	s2,0(a5)
 4c6:	22090a63          	beqz	s2,6fa <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 4ca:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4ce:	fe0994e3          	bnez	s3,4b6 <vprintf+0x46>
      if(c0 == '%'){
 4d2:	fd579de3          	bne	a5,s5,4ac <vprintf+0x3c>
        state = '%';
 4d6:	89be                	mv	s3,a5
 4d8:	b7cd                	j	4ba <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4da:	00ea06b3          	add	a3,s4,a4
 4de:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4e2:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4e4:	c681                	beqz	a3,4ec <vprintf+0x7c>
 4e6:	9752                	add	a4,a4,s4
 4e8:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4ec:	05878363          	beq	a5,s8,532 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 4f0:	05978d63          	beq	a5,s9,54a <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4f4:	07500713          	li	a4,117
 4f8:	0ee78763          	beq	a5,a4,5e6 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4fc:	07800713          	li	a4,120
 500:	12e78963          	beq	a5,a4,632 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 504:	07000713          	li	a4,112
 508:	14e78e63          	beq	a5,a4,664 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 50c:	06300713          	li	a4,99
 510:	18e78e63          	beq	a5,a4,6ac <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 514:	07300713          	li	a4,115
 518:	1ae78463          	beq	a5,a4,6c0 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 51c:	02500713          	li	a4,37
 520:	04e79563          	bne	a5,a4,56a <vprintf+0xfa>
        putc(fd, '%');
 524:	02500593          	li	a1,37
 528:	855a                	mv	a0,s6
 52a:	e8dff0ef          	jal	3b6 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 52e:	4981                	li	s3,0
 530:	b769                	j	4ba <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 532:	008b8913          	addi	s2,s7,8
 536:	4685                	li	a3,1
 538:	4629                	li	a2,10
 53a:	000ba583          	lw	a1,0(s7)
 53e:	855a                	mv	a0,s6
 540:	e95ff0ef          	jal	3d4 <printint>
 544:	8bca                	mv	s7,s2
      state = 0;
 546:	4981                	li	s3,0
 548:	bf8d                	j	4ba <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 54a:	06400793          	li	a5,100
 54e:	02f68963          	beq	a3,a5,580 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 552:	06c00793          	li	a5,108
 556:	04f68263          	beq	a3,a5,59a <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 55a:	07500793          	li	a5,117
 55e:	0af68063          	beq	a3,a5,5fe <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 562:	07800793          	li	a5,120
 566:	0ef68263          	beq	a3,a5,64a <vprintf+0x1da>
        putc(fd, '%');
 56a:	02500593          	li	a1,37
 56e:	855a                	mv	a0,s6
 570:	e47ff0ef          	jal	3b6 <putc>
        putc(fd, c0);
 574:	85ca                	mv	a1,s2
 576:	855a                	mv	a0,s6
 578:	e3fff0ef          	jal	3b6 <putc>
      state = 0;
 57c:	4981                	li	s3,0
 57e:	bf35                	j	4ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 580:	008b8913          	addi	s2,s7,8
 584:	4685                	li	a3,1
 586:	4629                	li	a2,10
 588:	000bb583          	ld	a1,0(s7)
 58c:	855a                	mv	a0,s6
 58e:	e47ff0ef          	jal	3d4 <printint>
        i += 1;
 592:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 594:	8bca                	mv	s7,s2
      state = 0;
 596:	4981                	li	s3,0
        i += 1;
 598:	b70d                	j	4ba <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 59a:	06400793          	li	a5,100
 59e:	02f60763          	beq	a2,a5,5cc <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5a2:	07500793          	li	a5,117
 5a6:	06f60963          	beq	a2,a5,618 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5aa:	07800793          	li	a5,120
 5ae:	faf61ee3          	bne	a2,a5,56a <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5b2:	008b8913          	addi	s2,s7,8
 5b6:	4681                	li	a3,0
 5b8:	4641                	li	a2,16
 5ba:	000bb583          	ld	a1,0(s7)
 5be:	855a                	mv	a0,s6
 5c0:	e15ff0ef          	jal	3d4 <printint>
        i += 2;
 5c4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5c6:	8bca                	mv	s7,s2
      state = 0;
 5c8:	4981                	li	s3,0
        i += 2;
 5ca:	bdc5                	j	4ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5cc:	008b8913          	addi	s2,s7,8
 5d0:	4685                	li	a3,1
 5d2:	4629                	li	a2,10
 5d4:	000bb583          	ld	a1,0(s7)
 5d8:	855a                	mv	a0,s6
 5da:	dfbff0ef          	jal	3d4 <printint>
        i += 2;
 5de:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e0:	8bca                	mv	s7,s2
      state = 0;
 5e2:	4981                	li	s3,0
        i += 2;
 5e4:	bdd9                	j	4ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5e6:	008b8913          	addi	s2,s7,8
 5ea:	4681                	li	a3,0
 5ec:	4629                	li	a2,10
 5ee:	000be583          	lwu	a1,0(s7)
 5f2:	855a                	mv	a0,s6
 5f4:	de1ff0ef          	jal	3d4 <printint>
 5f8:	8bca                	mv	s7,s2
      state = 0;
 5fa:	4981                	li	s3,0
 5fc:	bd7d                	j	4ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5fe:	008b8913          	addi	s2,s7,8
 602:	4681                	li	a3,0
 604:	4629                	li	a2,10
 606:	000bb583          	ld	a1,0(s7)
 60a:	855a                	mv	a0,s6
 60c:	dc9ff0ef          	jal	3d4 <printint>
        i += 1;
 610:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 612:	8bca                	mv	s7,s2
      state = 0;
 614:	4981                	li	s3,0
        i += 1;
 616:	b555                	j	4ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 618:	008b8913          	addi	s2,s7,8
 61c:	4681                	li	a3,0
 61e:	4629                	li	a2,10
 620:	000bb583          	ld	a1,0(s7)
 624:	855a                	mv	a0,s6
 626:	dafff0ef          	jal	3d4 <printint>
        i += 2;
 62a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 62c:	8bca                	mv	s7,s2
      state = 0;
 62e:	4981                	li	s3,0
        i += 2;
 630:	b569                	j	4ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 632:	008b8913          	addi	s2,s7,8
 636:	4681                	li	a3,0
 638:	4641                	li	a2,16
 63a:	000be583          	lwu	a1,0(s7)
 63e:	855a                	mv	a0,s6
 640:	d95ff0ef          	jal	3d4 <printint>
 644:	8bca                	mv	s7,s2
      state = 0;
 646:	4981                	li	s3,0
 648:	bd8d                	j	4ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 64a:	008b8913          	addi	s2,s7,8
 64e:	4681                	li	a3,0
 650:	4641                	li	a2,16
 652:	000bb583          	ld	a1,0(s7)
 656:	855a                	mv	a0,s6
 658:	d7dff0ef          	jal	3d4 <printint>
        i += 1;
 65c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 65e:	8bca                	mv	s7,s2
      state = 0;
 660:	4981                	li	s3,0
        i += 1;
 662:	bda1                	j	4ba <vprintf+0x4a>
 664:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 666:	008b8d13          	addi	s10,s7,8
 66a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 66e:	03000593          	li	a1,48
 672:	855a                	mv	a0,s6
 674:	d43ff0ef          	jal	3b6 <putc>
  putc(fd, 'x');
 678:	07800593          	li	a1,120
 67c:	855a                	mv	a0,s6
 67e:	d39ff0ef          	jal	3b6 <putc>
 682:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 684:	00000b97          	auipc	s7,0x0
 688:	284b8b93          	addi	s7,s7,644 # 908 <digits>
 68c:	03c9d793          	srli	a5,s3,0x3c
 690:	97de                	add	a5,a5,s7
 692:	0007c583          	lbu	a1,0(a5)
 696:	855a                	mv	a0,s6
 698:	d1fff0ef          	jal	3b6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 69c:	0992                	slli	s3,s3,0x4
 69e:	397d                	addiw	s2,s2,-1
 6a0:	fe0916e3          	bnez	s2,68c <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 6a4:	8bea                	mv	s7,s10
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	6d02                	ld	s10,0(sp)
 6aa:	bd01                	j	4ba <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 6ac:	008b8913          	addi	s2,s7,8
 6b0:	000bc583          	lbu	a1,0(s7)
 6b4:	855a                	mv	a0,s6
 6b6:	d01ff0ef          	jal	3b6 <putc>
 6ba:	8bca                	mv	s7,s2
      state = 0;
 6bc:	4981                	li	s3,0
 6be:	bbf5                	j	4ba <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6c0:	008b8993          	addi	s3,s7,8
 6c4:	000bb903          	ld	s2,0(s7)
 6c8:	00090f63          	beqz	s2,6e6 <vprintf+0x276>
        for(; *s; s++)
 6cc:	00094583          	lbu	a1,0(s2)
 6d0:	c195                	beqz	a1,6f4 <vprintf+0x284>
          putc(fd, *s);
 6d2:	855a                	mv	a0,s6
 6d4:	ce3ff0ef          	jal	3b6 <putc>
        for(; *s; s++)
 6d8:	0905                	addi	s2,s2,1
 6da:	00094583          	lbu	a1,0(s2)
 6de:	f9f5                	bnez	a1,6d2 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6e0:	8bce                	mv	s7,s3
      state = 0;
 6e2:	4981                	li	s3,0
 6e4:	bbd9                	j	4ba <vprintf+0x4a>
          s = "(null)";
 6e6:	00000917          	auipc	s2,0x0
 6ea:	21a90913          	addi	s2,s2,538 # 900 <malloc+0x10e>
        for(; *s; s++)
 6ee:	02800593          	li	a1,40
 6f2:	b7c5                	j	6d2 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6f4:	8bce                	mv	s7,s3
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	b3c9                	j	4ba <vprintf+0x4a>
 6fa:	64a6                	ld	s1,72(sp)
 6fc:	79e2                	ld	s3,56(sp)
 6fe:	7a42                	ld	s4,48(sp)
 700:	7aa2                	ld	s5,40(sp)
 702:	7b02                	ld	s6,32(sp)
 704:	6be2                	ld	s7,24(sp)
 706:	6c42                	ld	s8,16(sp)
 708:	6ca2                	ld	s9,8(sp)
    }
  }
}
 70a:	60e6                	ld	ra,88(sp)
 70c:	6446                	ld	s0,80(sp)
 70e:	6906                	ld	s2,64(sp)
 710:	6125                	addi	sp,sp,96
 712:	8082                	ret

0000000000000714 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 714:	715d                	addi	sp,sp,-80
 716:	ec06                	sd	ra,24(sp)
 718:	e822                	sd	s0,16(sp)
 71a:	1000                	addi	s0,sp,32
 71c:	e010                	sd	a2,0(s0)
 71e:	e414                	sd	a3,8(s0)
 720:	e818                	sd	a4,16(s0)
 722:	ec1c                	sd	a5,24(s0)
 724:	03043023          	sd	a6,32(s0)
 728:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 72c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 730:	8622                	mv	a2,s0
 732:	d3fff0ef          	jal	470 <vprintf>
}
 736:	60e2                	ld	ra,24(sp)
 738:	6442                	ld	s0,16(sp)
 73a:	6161                	addi	sp,sp,80
 73c:	8082                	ret

000000000000073e <printf>:

void
printf(const char *fmt, ...)
{
 73e:	711d                	addi	sp,sp,-96
 740:	ec06                	sd	ra,24(sp)
 742:	e822                	sd	s0,16(sp)
 744:	1000                	addi	s0,sp,32
 746:	e40c                	sd	a1,8(s0)
 748:	e810                	sd	a2,16(s0)
 74a:	ec14                	sd	a3,24(s0)
 74c:	f018                	sd	a4,32(s0)
 74e:	f41c                	sd	a5,40(s0)
 750:	03043823          	sd	a6,48(s0)
 754:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 758:	00840613          	addi	a2,s0,8
 75c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 760:	85aa                	mv	a1,a0
 762:	4505                	li	a0,1
 764:	d0dff0ef          	jal	470 <vprintf>
}
 768:	60e2                	ld	ra,24(sp)
 76a:	6442                	ld	s0,16(sp)
 76c:	6125                	addi	sp,sp,96
 76e:	8082                	ret

0000000000000770 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 770:	1141                	addi	sp,sp,-16
 772:	e422                	sd	s0,8(sp)
 774:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 776:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77a:	00001797          	auipc	a5,0x1
 77e:	8867b783          	ld	a5,-1914(a5) # 1000 <freep>
 782:	a02d                	j	7ac <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 784:	4618                	lw	a4,8(a2)
 786:	9f2d                	addw	a4,a4,a1
 788:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 78c:	6398                	ld	a4,0(a5)
 78e:	6310                	ld	a2,0(a4)
 790:	a83d                	j	7ce <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 792:	ff852703          	lw	a4,-8(a0)
 796:	9f31                	addw	a4,a4,a2
 798:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 79a:	ff053683          	ld	a3,-16(a0)
 79e:	a091                	j	7e2 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a0:	6398                	ld	a4,0(a5)
 7a2:	00e7e463          	bltu	a5,a4,7aa <free+0x3a>
 7a6:	00e6ea63          	bltu	a3,a4,7ba <free+0x4a>
{
 7aa:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ac:	fed7fae3          	bgeu	a5,a3,7a0 <free+0x30>
 7b0:	6398                	ld	a4,0(a5)
 7b2:	00e6e463          	bltu	a3,a4,7ba <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b6:	fee7eae3          	bltu	a5,a4,7aa <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7ba:	ff852583          	lw	a1,-8(a0)
 7be:	6390                	ld	a2,0(a5)
 7c0:	02059813          	slli	a6,a1,0x20
 7c4:	01c85713          	srli	a4,a6,0x1c
 7c8:	9736                	add	a4,a4,a3
 7ca:	fae60de3          	beq	a2,a4,784 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7ce:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7d2:	4790                	lw	a2,8(a5)
 7d4:	02061593          	slli	a1,a2,0x20
 7d8:	01c5d713          	srli	a4,a1,0x1c
 7dc:	973e                	add	a4,a4,a5
 7de:	fae68ae3          	beq	a3,a4,792 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7e2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7e4:	00001717          	auipc	a4,0x1
 7e8:	80f73e23          	sd	a5,-2020(a4) # 1000 <freep>
}
 7ec:	6422                	ld	s0,8(sp)
 7ee:	0141                	addi	sp,sp,16
 7f0:	8082                	ret

00000000000007f2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7f2:	7139                	addi	sp,sp,-64
 7f4:	fc06                	sd	ra,56(sp)
 7f6:	f822                	sd	s0,48(sp)
 7f8:	f426                	sd	s1,40(sp)
 7fa:	ec4e                	sd	s3,24(sp)
 7fc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7fe:	02051493          	slli	s1,a0,0x20
 802:	9081                	srli	s1,s1,0x20
 804:	04bd                	addi	s1,s1,15
 806:	8091                	srli	s1,s1,0x4
 808:	0014899b          	addiw	s3,s1,1
 80c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 80e:	00000517          	auipc	a0,0x0
 812:	7f253503          	ld	a0,2034(a0) # 1000 <freep>
 816:	c915                	beqz	a0,84a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 818:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 81a:	4798                	lw	a4,8(a5)
 81c:	08977a63          	bgeu	a4,s1,8b0 <malloc+0xbe>
 820:	f04a                	sd	s2,32(sp)
 822:	e852                	sd	s4,16(sp)
 824:	e456                	sd	s5,8(sp)
 826:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 828:	8a4e                	mv	s4,s3
 82a:	0009871b          	sext.w	a4,s3
 82e:	6685                	lui	a3,0x1
 830:	00d77363          	bgeu	a4,a3,836 <malloc+0x44>
 834:	6a05                	lui	s4,0x1
 836:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 83a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 83e:	00000917          	auipc	s2,0x0
 842:	7c290913          	addi	s2,s2,1986 # 1000 <freep>
  if(p == SBRK_ERROR)
 846:	5afd                	li	s5,-1
 848:	a081                	j	888 <malloc+0x96>
 84a:	f04a                	sd	s2,32(sp)
 84c:	e852                	sd	s4,16(sp)
 84e:	e456                	sd	s5,8(sp)
 850:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 852:	00000797          	auipc	a5,0x0
 856:	7be78793          	addi	a5,a5,1982 # 1010 <base>
 85a:	00000717          	auipc	a4,0x0
 85e:	7af73323          	sd	a5,1958(a4) # 1000 <freep>
 862:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 864:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 868:	b7c1                	j	828 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 86a:	6398                	ld	a4,0(a5)
 86c:	e118                	sd	a4,0(a0)
 86e:	a8a9                	j	8c8 <malloc+0xd6>
  hp->s.size = nu;
 870:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 874:	0541                	addi	a0,a0,16
 876:	efbff0ef          	jal	770 <free>
  return freep;
 87a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 87e:	c12d                	beqz	a0,8e0 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 880:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 882:	4798                	lw	a4,8(a5)
 884:	02977263          	bgeu	a4,s1,8a8 <malloc+0xb6>
    if(p == freep)
 888:	00093703          	ld	a4,0(s2)
 88c:	853e                	mv	a0,a5
 88e:	fef719e3          	bne	a4,a5,880 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 892:	8552                	mv	a0,s4
 894:	a47ff0ef          	jal	2da <sbrk>
  if(p == SBRK_ERROR)
 898:	fd551ce3          	bne	a0,s5,870 <malloc+0x7e>
        return 0;
 89c:	4501                	li	a0,0
 89e:	7902                	ld	s2,32(sp)
 8a0:	6a42                	ld	s4,16(sp)
 8a2:	6aa2                	ld	s5,8(sp)
 8a4:	6b02                	ld	s6,0(sp)
 8a6:	a03d                	j	8d4 <malloc+0xe2>
 8a8:	7902                	ld	s2,32(sp)
 8aa:	6a42                	ld	s4,16(sp)
 8ac:	6aa2                	ld	s5,8(sp)
 8ae:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8b0:	fae48de3          	beq	s1,a4,86a <malloc+0x78>
        p->s.size -= nunits;
 8b4:	4137073b          	subw	a4,a4,s3
 8b8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ba:	02071693          	slli	a3,a4,0x20
 8be:	01c6d713          	srli	a4,a3,0x1c
 8c2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8c4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8c8:	00000717          	auipc	a4,0x0
 8cc:	72a73c23          	sd	a0,1848(a4) # 1000 <freep>
      return (void*)(p + 1);
 8d0:	01078513          	addi	a0,a5,16
  }
}
 8d4:	70e2                	ld	ra,56(sp)
 8d6:	7442                	ld	s0,48(sp)
 8d8:	74a2                	ld	s1,40(sp)
 8da:	69e2                	ld	s3,24(sp)
 8dc:	6121                	addi	sp,sp,64
 8de:	8082                	ret
 8e0:	7902                	ld	s2,32(sp)
 8e2:	6a42                	ld	s4,16(sp)
 8e4:	6aa2                	ld	s5,8(sp)
 8e6:	6b02                	ld	s6,0(sp)
 8e8:	b7f5                	j	8d4 <malloc+0xe2>
