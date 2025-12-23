
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

char*
fmtname(char *path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	1800                	addi	s0,sp,48
   a:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   c:	2b8000ef          	jal	2c4 <strlen>
  10:	02051793          	slli	a5,a0,0x20
  14:	9381                	srli	a5,a5,0x20
  16:	97a6                	add	a5,a5,s1
  18:	02f00693          	li	a3,47
  1c:	0097e963          	bltu	a5,s1,2e <fmtname+0x2e>
  20:	0007c703          	lbu	a4,0(a5)
  24:	00d70563          	beq	a4,a3,2e <fmtname+0x2e>
  28:	17fd                	addi	a5,a5,-1
  2a:	fe97fbe3          	bgeu	a5,s1,20 <fmtname+0x20>
    ;
  p++;
  2e:	00178493          	addi	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  32:	8526                	mv	a0,s1
  34:	290000ef          	jal	2c4 <strlen>
  38:	2501                	sext.w	a0,a0
  3a:	47b5                	li	a5,13
  3c:	00a7f863          	bgeu	a5,a0,4c <fmtname+0x4c>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  buf[sizeof(buf)-1] = '\0';
  return buf;
}
  40:	8526                	mv	a0,s1
  42:	70a2                	ld	ra,40(sp)
  44:	7402                	ld	s0,32(sp)
  46:	64e2                	ld	s1,24(sp)
  48:	6145                	addi	sp,sp,48
  4a:	8082                	ret
  4c:	e84a                	sd	s2,16(sp)
  4e:	e44e                	sd	s3,8(sp)
  memmove(buf, p, strlen(p));
  50:	8526                	mv	a0,s1
  52:	272000ef          	jal	2c4 <strlen>
  56:	00001997          	auipc	s3,0x1
  5a:	fba98993          	addi	s3,s3,-70 # 1010 <buf.0>
  5e:	0005061b          	sext.w	a2,a0
  62:	85a6                	mv	a1,s1
  64:	854e                	mv	a0,s3
  66:	3c0000ef          	jal	426 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  6a:	8526                	mv	a0,s1
  6c:	258000ef          	jal	2c4 <strlen>
  70:	0005091b          	sext.w	s2,a0
  74:	8526                	mv	a0,s1
  76:	24e000ef          	jal	2c4 <strlen>
  7a:	1902                	slli	s2,s2,0x20
  7c:	02095913          	srli	s2,s2,0x20
  80:	4639                	li	a2,14
  82:	9e09                	subw	a2,a2,a0
  84:	02000593          	li	a1,32
  88:	01298533          	add	a0,s3,s2
  8c:	262000ef          	jal	2ee <memset>
  buf[sizeof(buf)-1] = '\0';
  90:	00098723          	sb	zero,14(s3)
  return buf;
  94:	84ce                	mv	s1,s3
  96:	6942                	ld	s2,16(sp)
  98:	69a2                	ld	s3,8(sp)
  9a:	b75d                	j	40 <fmtname+0x40>

000000000000009c <ls>:

void
ls(char *path)
{
  9c:	d9010113          	addi	sp,sp,-624
  a0:	26113423          	sd	ra,616(sp)
  a4:	26813023          	sd	s0,608(sp)
  a8:	25213823          	sd	s2,592(sp)
  ac:	1c80                	addi	s0,sp,624
  ae:	892a                	mv	s2,a0
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, O_RDONLY)) < 0){
  b0:	4581                	li	a1,0
  b2:	48e000ef          	jal	540 <open>
  b6:	06054363          	bltz	a0,11c <ls+0x80>
  ba:	24913c23          	sd	s1,600(sp)
  be:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  c0:	d9840593          	addi	a1,s0,-616
  c4:	494000ef          	jal	558 <fstat>
  c8:	06054363          	bltz	a0,12e <ls+0x92>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  cc:	da041783          	lh	a5,-608(s0)
  d0:	4705                	li	a4,1
  d2:	06e78c63          	beq	a5,a4,14a <ls+0xae>
  d6:	37f9                	addiw	a5,a5,-2
  d8:	17c2                	slli	a5,a5,0x30
  da:	93c1                	srli	a5,a5,0x30
  dc:	02f76263          	bltu	a4,a5,100 <ls+0x64>
  case T_DEVICE:
  case T_FILE:
    printf("%s %d %d %d\n", fmtname(path), st.type, st.ino, (int) st.size);
  e0:	854a                	mv	a0,s2
  e2:	f1fff0ef          	jal	0 <fmtname>
  e6:	85aa                	mv	a1,a0
  e8:	da842703          	lw	a4,-600(s0)
  ec:	d9c42683          	lw	a3,-612(s0)
  f0:	da041603          	lh	a2,-608(s0)
  f4:	00001517          	auipc	a0,0x1
  f8:	afc50513          	addi	a0,a0,-1284 # bf0 <calloc+0x7e>
  fc:	035000ef          	jal	930 <printf>
      }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
    }
    break;
  }
  close(fd);
 100:	8526                	mv	a0,s1
 102:	426000ef          	jal	528 <close>
 106:	25813483          	ld	s1,600(sp)
}
 10a:	26813083          	ld	ra,616(sp)
 10e:	26013403          	ld	s0,608(sp)
 112:	25013903          	ld	s2,592(sp)
 116:	27010113          	addi	sp,sp,624
 11a:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 11c:	864a                	mv	a2,s2
 11e:	00001597          	auipc	a1,0x1
 122:	aa258593          	addi	a1,a1,-1374 # bc0 <calloc+0x4e>
 126:	4509                	li	a0,2
 128:	7de000ef          	jal	906 <fprintf>
    return;
 12c:	bff9                	j	10a <ls+0x6e>
    fprintf(2, "ls: cannot stat %s\n", path);
 12e:	864a                	mv	a2,s2
 130:	00001597          	auipc	a1,0x1
 134:	aa858593          	addi	a1,a1,-1368 # bd8 <calloc+0x66>
 138:	4509                	li	a0,2
 13a:	7cc000ef          	jal	906 <fprintf>
    close(fd);
 13e:	8526                	mv	a0,s1
 140:	3e8000ef          	jal	528 <close>
    return;
 144:	25813483          	ld	s1,600(sp)
 148:	b7c9                	j	10a <ls+0x6e>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 14a:	854a                	mv	a0,s2
 14c:	178000ef          	jal	2c4 <strlen>
 150:	2541                	addiw	a0,a0,16
 152:	20000793          	li	a5,512
 156:	00a7f963          	bgeu	a5,a0,168 <ls+0xcc>
      printf("ls: path too long\n");
 15a:	00001517          	auipc	a0,0x1
 15e:	aa650513          	addi	a0,a0,-1370 # c00 <calloc+0x8e>
 162:	7ce000ef          	jal	930 <printf>
      break;
 166:	bf69                	j	100 <ls+0x64>
 168:	25313423          	sd	s3,584(sp)
 16c:	25413023          	sd	s4,576(sp)
 170:	23513c23          	sd	s5,568(sp)
    strcpy(buf, path);
 174:	85ca                	mv	a1,s2
 176:	dc040513          	addi	a0,s0,-576
 17a:	102000ef          	jal	27c <strcpy>
    p = buf+strlen(buf);
 17e:	dc040513          	addi	a0,s0,-576
 182:	142000ef          	jal	2c4 <strlen>
 186:	1502                	slli	a0,a0,0x20
 188:	9101                	srli	a0,a0,0x20
 18a:	dc040793          	addi	a5,s0,-576
 18e:	00a78933          	add	s2,a5,a0
    *p++ = '/';
 192:	00190993          	addi	s3,s2,1
 196:	02f00793          	li	a5,47
 19a:	00f90023          	sb	a5,0(s2)
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
 19e:	00001a17          	auipc	s4,0x1
 1a2:	a52a0a13          	addi	s4,s4,-1454 # bf0 <calloc+0x7e>
        printf("ls: cannot stat %s\n", buf);
 1a6:	00001a97          	auipc	s5,0x1
 1aa:	a32a8a93          	addi	s5,s5,-1486 # bd8 <calloc+0x66>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1ae:	a031                	j	1ba <ls+0x11e>
        printf("ls: cannot stat %s\n", buf);
 1b0:	dc040593          	addi	a1,s0,-576
 1b4:	8556                	mv	a0,s5
 1b6:	77a000ef          	jal	930 <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1ba:	4641                	li	a2,16
 1bc:	db040593          	addi	a1,s0,-592
 1c0:	8526                	mv	a0,s1
 1c2:	356000ef          	jal	518 <read>
 1c6:	47c1                	li	a5,16
 1c8:	04f51463          	bne	a0,a5,210 <ls+0x174>
      if(de.inum == 0)
 1cc:	db045783          	lhu	a5,-592(s0)
 1d0:	d7ed                	beqz	a5,1ba <ls+0x11e>
      memmove(p, de.name, DIRSIZ);
 1d2:	4639                	li	a2,14
 1d4:	db240593          	addi	a1,s0,-590
 1d8:	854e                	mv	a0,s3
 1da:	24c000ef          	jal	426 <memmove>
      p[DIRSIZ] = 0;
 1de:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 1e2:	d9840593          	addi	a1,s0,-616
 1e6:	dc040513          	addi	a0,s0,-576
 1ea:	1ba000ef          	jal	3a4 <stat>
 1ee:	fc0541e3          	bltz	a0,1b0 <ls+0x114>
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
 1f2:	dc040513          	addi	a0,s0,-576
 1f6:	e0bff0ef          	jal	0 <fmtname>
 1fa:	85aa                	mv	a1,a0
 1fc:	da842703          	lw	a4,-600(s0)
 200:	d9c42683          	lw	a3,-612(s0)
 204:	da041603          	lh	a2,-608(s0)
 208:	8552                	mv	a0,s4
 20a:	726000ef          	jal	930 <printf>
 20e:	b775                	j	1ba <ls+0x11e>
 210:	24813983          	ld	s3,584(sp)
 214:	24013a03          	ld	s4,576(sp)
 218:	23813a83          	ld	s5,568(sp)
 21c:	b5d5                	j	100 <ls+0x64>

000000000000021e <main>:

int
main(int argc, char *argv[])
{
 21e:	1101                	addi	sp,sp,-32
 220:	ec06                	sd	ra,24(sp)
 222:	e822                	sd	s0,16(sp)
 224:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
 226:	4785                	li	a5,1
 228:	02a7d763          	bge	a5,a0,256 <main+0x38>
 22c:	e426                	sd	s1,8(sp)
 22e:	e04a                	sd	s2,0(sp)
 230:	00858493          	addi	s1,a1,8
 234:	ffe5091b          	addiw	s2,a0,-2
 238:	02091793          	slli	a5,s2,0x20
 23c:	01d7d913          	srli	s2,a5,0x1d
 240:	05c1                	addi	a1,a1,16
 242:	992e                	add	s2,s2,a1
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
 244:	6088                	ld	a0,0(s1)
 246:	e57ff0ef          	jal	9c <ls>
  for(i=1; i<argc; i++)
 24a:	04a1                	addi	s1,s1,8
 24c:	ff249ce3          	bne	s1,s2,244 <main+0x26>
  exit(0);
 250:	4501                	li	a0,0
 252:	2ae000ef          	jal	500 <exit>
 256:	e426                	sd	s1,8(sp)
 258:	e04a                	sd	s2,0(sp)
    ls(".");
 25a:	00001517          	auipc	a0,0x1
 25e:	9be50513          	addi	a0,a0,-1602 # c18 <calloc+0xa6>
 262:	e3bff0ef          	jal	9c <ls>
    exit(0);
 266:	4501                	li	a0,0
 268:	298000ef          	jal	500 <exit>

000000000000026c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e406                	sd	ra,8(sp)
 270:	e022                	sd	s0,0(sp)
 272:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 274:	fabff0ef          	jal	21e <main>
  exit(r);
 278:	288000ef          	jal	500 <exit>

000000000000027c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 282:	87aa                	mv	a5,a0
 284:	0585                	addi	a1,a1,1
 286:	0785                	addi	a5,a5,1
 288:	fff5c703          	lbu	a4,-1(a1)
 28c:	fee78fa3          	sb	a4,-1(a5)
 290:	fb75                	bnez	a4,284 <strcpy+0x8>
    ;
  return os;
}
 292:	6422                	ld	s0,8(sp)
 294:	0141                	addi	sp,sp,16
 296:	8082                	ret

0000000000000298 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 29e:	00054783          	lbu	a5,0(a0)
 2a2:	cb91                	beqz	a5,2b6 <strcmp+0x1e>
 2a4:	0005c703          	lbu	a4,0(a1)
 2a8:	00f71763          	bne	a4,a5,2b6 <strcmp+0x1e>
    p++, q++;
 2ac:	0505                	addi	a0,a0,1
 2ae:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2b0:	00054783          	lbu	a5,0(a0)
 2b4:	fbe5                	bnez	a5,2a4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2b6:	0005c503          	lbu	a0,0(a1)
}
 2ba:	40a7853b          	subw	a0,a5,a0
 2be:	6422                	ld	s0,8(sp)
 2c0:	0141                	addi	sp,sp,16
 2c2:	8082                	ret

00000000000002c4 <strlen>:

uint
strlen(const char *s)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e422                	sd	s0,8(sp)
 2c8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2ca:	00054783          	lbu	a5,0(a0)
 2ce:	cf91                	beqz	a5,2ea <strlen+0x26>
 2d0:	0505                	addi	a0,a0,1
 2d2:	87aa                	mv	a5,a0
 2d4:	86be                	mv	a3,a5
 2d6:	0785                	addi	a5,a5,1
 2d8:	fff7c703          	lbu	a4,-1(a5)
 2dc:	ff65                	bnez	a4,2d4 <strlen+0x10>
 2de:	40a6853b          	subw	a0,a3,a0
 2e2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 2e4:	6422                	ld	s0,8(sp)
 2e6:	0141                	addi	sp,sp,16
 2e8:	8082                	ret
  for(n = 0; s[n]; n++)
 2ea:	4501                	li	a0,0
 2ec:	bfe5                	j	2e4 <strlen+0x20>

00000000000002ee <memset>:

void*
memset(void *dst, int c, uint n)
{
 2ee:	1141                	addi	sp,sp,-16
 2f0:	e422                	sd	s0,8(sp)
 2f2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2f4:	ca19                	beqz	a2,30a <memset+0x1c>
 2f6:	87aa                	mv	a5,a0
 2f8:	1602                	slli	a2,a2,0x20
 2fa:	9201                	srli	a2,a2,0x20
 2fc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 300:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 304:	0785                	addi	a5,a5,1
 306:	fee79de3          	bne	a5,a4,300 <memset+0x12>
  }
  return dst;
}
 30a:	6422                	ld	s0,8(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret

0000000000000310 <strchr>:

char*
strchr(const char *s, char c)
{
 310:	1141                	addi	sp,sp,-16
 312:	e422                	sd	s0,8(sp)
 314:	0800                	addi	s0,sp,16
  for(; *s; s++)
 316:	00054783          	lbu	a5,0(a0)
 31a:	cb99                	beqz	a5,330 <strchr+0x20>
    if(*s == c)
 31c:	00f58763          	beq	a1,a5,32a <strchr+0x1a>
  for(; *s; s++)
 320:	0505                	addi	a0,a0,1
 322:	00054783          	lbu	a5,0(a0)
 326:	fbfd                	bnez	a5,31c <strchr+0xc>
      return (char*)s;
  return 0;
 328:	4501                	li	a0,0
}
 32a:	6422                	ld	s0,8(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret
  return 0;
 330:	4501                	li	a0,0
 332:	bfe5                	j	32a <strchr+0x1a>

0000000000000334 <gets>:

char*
gets(char *buf, int max)
{
 334:	711d                	addi	sp,sp,-96
 336:	ec86                	sd	ra,88(sp)
 338:	e8a2                	sd	s0,80(sp)
 33a:	e4a6                	sd	s1,72(sp)
 33c:	e0ca                	sd	s2,64(sp)
 33e:	fc4e                	sd	s3,56(sp)
 340:	f852                	sd	s4,48(sp)
 342:	f456                	sd	s5,40(sp)
 344:	f05a                	sd	s6,32(sp)
 346:	ec5e                	sd	s7,24(sp)
 348:	1080                	addi	s0,sp,96
 34a:	8baa                	mv	s7,a0
 34c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 34e:	892a                	mv	s2,a0
 350:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 352:	4aa9                	li	s5,10
 354:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 356:	89a6                	mv	s3,s1
 358:	2485                	addiw	s1,s1,1
 35a:	0344d663          	bge	s1,s4,386 <gets+0x52>
    cc = read(0, &c, 1);
 35e:	4605                	li	a2,1
 360:	faf40593          	addi	a1,s0,-81
 364:	4501                	li	a0,0
 366:	1b2000ef          	jal	518 <read>
    if(cc < 1)
 36a:	00a05e63          	blez	a0,386 <gets+0x52>
    buf[i++] = c;
 36e:	faf44783          	lbu	a5,-81(s0)
 372:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 376:	01578763          	beq	a5,s5,384 <gets+0x50>
 37a:	0905                	addi	s2,s2,1
 37c:	fd679de3          	bne	a5,s6,356 <gets+0x22>
    buf[i++] = c;
 380:	89a6                	mv	s3,s1
 382:	a011                	j	386 <gets+0x52>
 384:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 386:	99de                	add	s3,s3,s7
 388:	00098023          	sb	zero,0(s3)
  return buf;
}
 38c:	855e                	mv	a0,s7
 38e:	60e6                	ld	ra,88(sp)
 390:	6446                	ld	s0,80(sp)
 392:	64a6                	ld	s1,72(sp)
 394:	6906                	ld	s2,64(sp)
 396:	79e2                	ld	s3,56(sp)
 398:	7a42                	ld	s4,48(sp)
 39a:	7aa2                	ld	s5,40(sp)
 39c:	7b02                	ld	s6,32(sp)
 39e:	6be2                	ld	s7,24(sp)
 3a0:	6125                	addi	sp,sp,96
 3a2:	8082                	ret

00000000000003a4 <stat>:

int
stat(const char *n, struct stat *st)
{
 3a4:	1101                	addi	sp,sp,-32
 3a6:	ec06                	sd	ra,24(sp)
 3a8:	e822                	sd	s0,16(sp)
 3aa:	e04a                	sd	s2,0(sp)
 3ac:	1000                	addi	s0,sp,32
 3ae:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3b0:	4581                	li	a1,0
 3b2:	18e000ef          	jal	540 <open>
  if(fd < 0)
 3b6:	02054263          	bltz	a0,3da <stat+0x36>
 3ba:	e426                	sd	s1,8(sp)
 3bc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3be:	85ca                	mv	a1,s2
 3c0:	198000ef          	jal	558 <fstat>
 3c4:	892a                	mv	s2,a0
  close(fd);
 3c6:	8526                	mv	a0,s1
 3c8:	160000ef          	jal	528 <close>
  return r;
 3cc:	64a2                	ld	s1,8(sp)
}
 3ce:	854a                	mv	a0,s2
 3d0:	60e2                	ld	ra,24(sp)
 3d2:	6442                	ld	s0,16(sp)
 3d4:	6902                	ld	s2,0(sp)
 3d6:	6105                	addi	sp,sp,32
 3d8:	8082                	ret
    return -1;
 3da:	597d                	li	s2,-1
 3dc:	bfcd                	j	3ce <stat+0x2a>

00000000000003de <atoi>:

int
atoi(const char *s)
{
 3de:	1141                	addi	sp,sp,-16
 3e0:	e422                	sd	s0,8(sp)
 3e2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3e4:	00054683          	lbu	a3,0(a0)
 3e8:	fd06879b          	addiw	a5,a3,-48
 3ec:	0ff7f793          	zext.b	a5,a5
 3f0:	4625                	li	a2,9
 3f2:	02f66863          	bltu	a2,a5,422 <atoi+0x44>
 3f6:	872a                	mv	a4,a0
  n = 0;
 3f8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3fa:	0705                	addi	a4,a4,1
 3fc:	0025179b          	slliw	a5,a0,0x2
 400:	9fa9                	addw	a5,a5,a0
 402:	0017979b          	slliw	a5,a5,0x1
 406:	9fb5                	addw	a5,a5,a3
 408:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 40c:	00074683          	lbu	a3,0(a4)
 410:	fd06879b          	addiw	a5,a3,-48
 414:	0ff7f793          	zext.b	a5,a5
 418:	fef671e3          	bgeu	a2,a5,3fa <atoi+0x1c>
  return n;
}
 41c:	6422                	ld	s0,8(sp)
 41e:	0141                	addi	sp,sp,16
 420:	8082                	ret
  n = 0;
 422:	4501                	li	a0,0
 424:	bfe5                	j	41c <atoi+0x3e>

0000000000000426 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 426:	1141                	addi	sp,sp,-16
 428:	e422                	sd	s0,8(sp)
 42a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 42c:	02b57463          	bgeu	a0,a1,454 <memmove+0x2e>
    while(n-- > 0)
 430:	00c05f63          	blez	a2,44e <memmove+0x28>
 434:	1602                	slli	a2,a2,0x20
 436:	9201                	srli	a2,a2,0x20
 438:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 43c:	872a                	mv	a4,a0
      *dst++ = *src++;
 43e:	0585                	addi	a1,a1,1
 440:	0705                	addi	a4,a4,1
 442:	fff5c683          	lbu	a3,-1(a1)
 446:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 44a:	fef71ae3          	bne	a4,a5,43e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 44e:	6422                	ld	s0,8(sp)
 450:	0141                	addi	sp,sp,16
 452:	8082                	ret
    dst += n;
 454:	00c50733          	add	a4,a0,a2
    src += n;
 458:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 45a:	fec05ae3          	blez	a2,44e <memmove+0x28>
 45e:	fff6079b          	addiw	a5,a2,-1
 462:	1782                	slli	a5,a5,0x20
 464:	9381                	srli	a5,a5,0x20
 466:	fff7c793          	not	a5,a5
 46a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 46c:	15fd                	addi	a1,a1,-1
 46e:	177d                	addi	a4,a4,-1
 470:	0005c683          	lbu	a3,0(a1)
 474:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 478:	fee79ae3          	bne	a5,a4,46c <memmove+0x46>
 47c:	bfc9                	j	44e <memmove+0x28>

000000000000047e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 47e:	1141                	addi	sp,sp,-16
 480:	e422                	sd	s0,8(sp)
 482:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 484:	ca05                	beqz	a2,4b4 <memcmp+0x36>
 486:	fff6069b          	addiw	a3,a2,-1
 48a:	1682                	slli	a3,a3,0x20
 48c:	9281                	srli	a3,a3,0x20
 48e:	0685                	addi	a3,a3,1
 490:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 492:	00054783          	lbu	a5,0(a0)
 496:	0005c703          	lbu	a4,0(a1)
 49a:	00e79863          	bne	a5,a4,4aa <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 49e:	0505                	addi	a0,a0,1
    p2++;
 4a0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4a2:	fed518e3          	bne	a0,a3,492 <memcmp+0x14>
  }
  return 0;
 4a6:	4501                	li	a0,0
 4a8:	a019                	j	4ae <memcmp+0x30>
      return *p1 - *p2;
 4aa:	40e7853b          	subw	a0,a5,a4
}
 4ae:	6422                	ld	s0,8(sp)
 4b0:	0141                	addi	sp,sp,16
 4b2:	8082                	ret
  return 0;
 4b4:	4501                	li	a0,0
 4b6:	bfe5                	j	4ae <memcmp+0x30>

00000000000004b8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4b8:	1141                	addi	sp,sp,-16
 4ba:	e406                	sd	ra,8(sp)
 4bc:	e022                	sd	s0,0(sp)
 4be:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4c0:	f67ff0ef          	jal	426 <memmove>
}
 4c4:	60a2                	ld	ra,8(sp)
 4c6:	6402                	ld	s0,0(sp)
 4c8:	0141                	addi	sp,sp,16
 4ca:	8082                	ret

00000000000004cc <sbrk>:

char *
sbrk(int n) {
 4cc:	1141                	addi	sp,sp,-16
 4ce:	e406                	sd	ra,8(sp)
 4d0:	e022                	sd	s0,0(sp)
 4d2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4d4:	4585                	li	a1,1
 4d6:	0b2000ef          	jal	588 <sys_sbrk>
}
 4da:	60a2                	ld	ra,8(sp)
 4dc:	6402                	ld	s0,0(sp)
 4de:	0141                	addi	sp,sp,16
 4e0:	8082                	ret

00000000000004e2 <sbrklazy>:

char *
sbrklazy(int n) {
 4e2:	1141                	addi	sp,sp,-16
 4e4:	e406                	sd	ra,8(sp)
 4e6:	e022                	sd	s0,0(sp)
 4e8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4ea:	4589                	li	a1,2
 4ec:	09c000ef          	jal	588 <sys_sbrk>
}
 4f0:	60a2                	ld	ra,8(sp)
 4f2:	6402                	ld	s0,0(sp)
 4f4:	0141                	addi	sp,sp,16
 4f6:	8082                	ret

00000000000004f8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4f8:	4885                	li	a7,1
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <exit>:
.global exit
exit:
 li a7, SYS_exit
 500:	4889                	li	a7,2
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <wait>:
.global wait
wait:
 li a7, SYS_wait
 508:	488d                	li	a7,3
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 510:	4891                	li	a7,4
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <read>:
.global read
read:
 li a7, SYS_read
 518:	4895                	li	a7,5
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <write>:
.global write
write:
 li a7, SYS_write
 520:	48c1                	li	a7,16
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <close>:
.global close
close:
 li a7, SYS_close
 528:	48d5                	li	a7,21
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <kill>:
.global kill
kill:
 li a7, SYS_kill
 530:	4899                	li	a7,6
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <exec>:
.global exec
exec:
 li a7, SYS_exec
 538:	489d                	li	a7,7
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <open>:
.global open
open:
 li a7, SYS_open
 540:	48bd                	li	a7,15
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 548:	48c5                	li	a7,17
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 550:	48c9                	li	a7,18
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 558:	48a1                	li	a7,8
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <link>:
.global link
link:
 li a7, SYS_link
 560:	48cd                	li	a7,19
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 568:	48d1                	li	a7,20
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 570:	48a5                	li	a7,9
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <dup>:
.global dup
dup:
 li a7, SYS_dup
 578:	48a9                	li	a7,10
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 580:	48ad                	li	a7,11
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 588:	48b1                	li	a7,12
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <pause>:
.global pause
pause:
 li a7, SYS_pause
 590:	48b5                	li	a7,13
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 598:	48b9                	li	a7,14
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 5a0:	48d9                	li	a7,22
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5a8:	1101                	addi	sp,sp,-32
 5aa:	ec06                	sd	ra,24(sp)
 5ac:	e822                	sd	s0,16(sp)
 5ae:	1000                	addi	s0,sp,32
 5b0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5b4:	4605                	li	a2,1
 5b6:	fef40593          	addi	a1,s0,-17
 5ba:	f67ff0ef          	jal	520 <write>
}
 5be:	60e2                	ld	ra,24(sp)
 5c0:	6442                	ld	s0,16(sp)
 5c2:	6105                	addi	sp,sp,32
 5c4:	8082                	ret

00000000000005c6 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 5c6:	715d                	addi	sp,sp,-80
 5c8:	e486                	sd	ra,72(sp)
 5ca:	e0a2                	sd	s0,64(sp)
 5cc:	f84a                	sd	s2,48(sp)
 5ce:	0880                	addi	s0,sp,80
 5d0:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 5d2:	c299                	beqz	a3,5d8 <printint+0x12>
 5d4:	0805c363          	bltz	a1,65a <printint+0x94>
  neg = 0;
 5d8:	4881                	li	a7,0
 5da:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 5de:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 5e0:	00000517          	auipc	a0,0x0
 5e4:	64850513          	addi	a0,a0,1608 # c28 <digits>
 5e8:	883e                	mv	a6,a5
 5ea:	2785                	addiw	a5,a5,1
 5ec:	02c5f733          	remu	a4,a1,a2
 5f0:	972a                	add	a4,a4,a0
 5f2:	00074703          	lbu	a4,0(a4)
 5f6:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 5fa:	872e                	mv	a4,a1
 5fc:	02c5d5b3          	divu	a1,a1,a2
 600:	0685                	addi	a3,a3,1
 602:	fec773e3          	bgeu	a4,a2,5e8 <printint+0x22>
  if(neg)
 606:	00088b63          	beqz	a7,61c <printint+0x56>
    buf[i++] = '-';
 60a:	fd078793          	addi	a5,a5,-48
 60e:	97a2                	add	a5,a5,s0
 610:	02d00713          	li	a4,45
 614:	fee78423          	sb	a4,-24(a5)
 618:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 61c:	02f05a63          	blez	a5,650 <printint+0x8a>
 620:	fc26                	sd	s1,56(sp)
 622:	f44e                	sd	s3,40(sp)
 624:	fb840713          	addi	a4,s0,-72
 628:	00f704b3          	add	s1,a4,a5
 62c:	fff70993          	addi	s3,a4,-1
 630:	99be                	add	s3,s3,a5
 632:	37fd                	addiw	a5,a5,-1
 634:	1782                	slli	a5,a5,0x20
 636:	9381                	srli	a5,a5,0x20
 638:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 63c:	fff4c583          	lbu	a1,-1(s1)
 640:	854a                	mv	a0,s2
 642:	f67ff0ef          	jal	5a8 <putc>
  while(--i >= 0)
 646:	14fd                	addi	s1,s1,-1
 648:	ff349ae3          	bne	s1,s3,63c <printint+0x76>
 64c:	74e2                	ld	s1,56(sp)
 64e:	79a2                	ld	s3,40(sp)
}
 650:	60a6                	ld	ra,72(sp)
 652:	6406                	ld	s0,64(sp)
 654:	7942                	ld	s2,48(sp)
 656:	6161                	addi	sp,sp,80
 658:	8082                	ret
    x = -xx;
 65a:	40b005b3          	neg	a1,a1
    neg = 1;
 65e:	4885                	li	a7,1
    x = -xx;
 660:	bfad                	j	5da <printint+0x14>

0000000000000662 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 662:	711d                	addi	sp,sp,-96
 664:	ec86                	sd	ra,88(sp)
 666:	e8a2                	sd	s0,80(sp)
 668:	e0ca                	sd	s2,64(sp)
 66a:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 66c:	0005c903          	lbu	s2,0(a1)
 670:	28090663          	beqz	s2,8fc <vprintf+0x29a>
 674:	e4a6                	sd	s1,72(sp)
 676:	fc4e                	sd	s3,56(sp)
 678:	f852                	sd	s4,48(sp)
 67a:	f456                	sd	s5,40(sp)
 67c:	f05a                	sd	s6,32(sp)
 67e:	ec5e                	sd	s7,24(sp)
 680:	e862                	sd	s8,16(sp)
 682:	e466                	sd	s9,8(sp)
 684:	8b2a                	mv	s6,a0
 686:	8a2e                	mv	s4,a1
 688:	8bb2                	mv	s7,a2
  state = 0;
 68a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 68c:	4481                	li	s1,0
 68e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 690:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 694:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 698:	06c00c93          	li	s9,108
 69c:	a005                	j	6bc <vprintf+0x5a>
        putc(fd, c0);
 69e:	85ca                	mv	a1,s2
 6a0:	855a                	mv	a0,s6
 6a2:	f07ff0ef          	jal	5a8 <putc>
 6a6:	a019                	j	6ac <vprintf+0x4a>
    } else if(state == '%'){
 6a8:	03598263          	beq	s3,s5,6cc <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 6ac:	2485                	addiw	s1,s1,1
 6ae:	8726                	mv	a4,s1
 6b0:	009a07b3          	add	a5,s4,s1
 6b4:	0007c903          	lbu	s2,0(a5)
 6b8:	22090a63          	beqz	s2,8ec <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 6bc:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6c0:	fe0994e3          	bnez	s3,6a8 <vprintf+0x46>
      if(c0 == '%'){
 6c4:	fd579de3          	bne	a5,s5,69e <vprintf+0x3c>
        state = '%';
 6c8:	89be                	mv	s3,a5
 6ca:	b7cd                	j	6ac <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 6cc:	00ea06b3          	add	a3,s4,a4
 6d0:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 6d4:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 6d6:	c681                	beqz	a3,6de <vprintf+0x7c>
 6d8:	9752                	add	a4,a4,s4
 6da:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 6de:	05878363          	beq	a5,s8,724 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 6e2:	05978d63          	beq	a5,s9,73c <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 6e6:	07500713          	li	a4,117
 6ea:	0ee78763          	beq	a5,a4,7d8 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 6ee:	07800713          	li	a4,120
 6f2:	12e78963          	beq	a5,a4,824 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 6f6:	07000713          	li	a4,112
 6fa:	14e78e63          	beq	a5,a4,856 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 6fe:	06300713          	li	a4,99
 702:	18e78e63          	beq	a5,a4,89e <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 706:	07300713          	li	a4,115
 70a:	1ae78463          	beq	a5,a4,8b2 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 70e:	02500713          	li	a4,37
 712:	04e79563          	bne	a5,a4,75c <vprintf+0xfa>
        putc(fd, '%');
 716:	02500593          	li	a1,37
 71a:	855a                	mv	a0,s6
 71c:	e8dff0ef          	jal	5a8 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 720:	4981                	li	s3,0
 722:	b769                	j	6ac <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 724:	008b8913          	addi	s2,s7,8
 728:	4685                	li	a3,1
 72a:	4629                	li	a2,10
 72c:	000ba583          	lw	a1,0(s7)
 730:	855a                	mv	a0,s6
 732:	e95ff0ef          	jal	5c6 <printint>
 736:	8bca                	mv	s7,s2
      state = 0;
 738:	4981                	li	s3,0
 73a:	bf8d                	j	6ac <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 73c:	06400793          	li	a5,100
 740:	02f68963          	beq	a3,a5,772 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 744:	06c00793          	li	a5,108
 748:	04f68263          	beq	a3,a5,78c <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 74c:	07500793          	li	a5,117
 750:	0af68063          	beq	a3,a5,7f0 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 754:	07800793          	li	a5,120
 758:	0ef68263          	beq	a3,a5,83c <vprintf+0x1da>
        putc(fd, '%');
 75c:	02500593          	li	a1,37
 760:	855a                	mv	a0,s6
 762:	e47ff0ef          	jal	5a8 <putc>
        putc(fd, c0);
 766:	85ca                	mv	a1,s2
 768:	855a                	mv	a0,s6
 76a:	e3fff0ef          	jal	5a8 <putc>
      state = 0;
 76e:	4981                	li	s3,0
 770:	bf35                	j	6ac <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 772:	008b8913          	addi	s2,s7,8
 776:	4685                	li	a3,1
 778:	4629                	li	a2,10
 77a:	000bb583          	ld	a1,0(s7)
 77e:	855a                	mv	a0,s6
 780:	e47ff0ef          	jal	5c6 <printint>
        i += 1;
 784:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 786:	8bca                	mv	s7,s2
      state = 0;
 788:	4981                	li	s3,0
        i += 1;
 78a:	b70d                	j	6ac <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 78c:	06400793          	li	a5,100
 790:	02f60763          	beq	a2,a5,7be <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 794:	07500793          	li	a5,117
 798:	06f60963          	beq	a2,a5,80a <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 79c:	07800793          	li	a5,120
 7a0:	faf61ee3          	bne	a2,a5,75c <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7a4:	008b8913          	addi	s2,s7,8
 7a8:	4681                	li	a3,0
 7aa:	4641                	li	a2,16
 7ac:	000bb583          	ld	a1,0(s7)
 7b0:	855a                	mv	a0,s6
 7b2:	e15ff0ef          	jal	5c6 <printint>
        i += 2;
 7b6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7b8:	8bca                	mv	s7,s2
      state = 0;
 7ba:	4981                	li	s3,0
        i += 2;
 7bc:	bdc5                	j	6ac <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7be:	008b8913          	addi	s2,s7,8
 7c2:	4685                	li	a3,1
 7c4:	4629                	li	a2,10
 7c6:	000bb583          	ld	a1,0(s7)
 7ca:	855a                	mv	a0,s6
 7cc:	dfbff0ef          	jal	5c6 <printint>
        i += 2;
 7d0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7d2:	8bca                	mv	s7,s2
      state = 0;
 7d4:	4981                	li	s3,0
        i += 2;
 7d6:	bdd9                	j	6ac <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 7d8:	008b8913          	addi	s2,s7,8
 7dc:	4681                	li	a3,0
 7de:	4629                	li	a2,10
 7e0:	000be583          	lwu	a1,0(s7)
 7e4:	855a                	mv	a0,s6
 7e6:	de1ff0ef          	jal	5c6 <printint>
 7ea:	8bca                	mv	s7,s2
      state = 0;
 7ec:	4981                	li	s3,0
 7ee:	bd7d                	j	6ac <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7f0:	008b8913          	addi	s2,s7,8
 7f4:	4681                	li	a3,0
 7f6:	4629                	li	a2,10
 7f8:	000bb583          	ld	a1,0(s7)
 7fc:	855a                	mv	a0,s6
 7fe:	dc9ff0ef          	jal	5c6 <printint>
        i += 1;
 802:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 804:	8bca                	mv	s7,s2
      state = 0;
 806:	4981                	li	s3,0
        i += 1;
 808:	b555                	j	6ac <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 80a:	008b8913          	addi	s2,s7,8
 80e:	4681                	li	a3,0
 810:	4629                	li	a2,10
 812:	000bb583          	ld	a1,0(s7)
 816:	855a                	mv	a0,s6
 818:	dafff0ef          	jal	5c6 <printint>
        i += 2;
 81c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 81e:	8bca                	mv	s7,s2
      state = 0;
 820:	4981                	li	s3,0
        i += 2;
 822:	b569                	j	6ac <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 824:	008b8913          	addi	s2,s7,8
 828:	4681                	li	a3,0
 82a:	4641                	li	a2,16
 82c:	000be583          	lwu	a1,0(s7)
 830:	855a                	mv	a0,s6
 832:	d95ff0ef          	jal	5c6 <printint>
 836:	8bca                	mv	s7,s2
      state = 0;
 838:	4981                	li	s3,0
 83a:	bd8d                	j	6ac <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 83c:	008b8913          	addi	s2,s7,8
 840:	4681                	li	a3,0
 842:	4641                	li	a2,16
 844:	000bb583          	ld	a1,0(s7)
 848:	855a                	mv	a0,s6
 84a:	d7dff0ef          	jal	5c6 <printint>
        i += 1;
 84e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 850:	8bca                	mv	s7,s2
      state = 0;
 852:	4981                	li	s3,0
        i += 1;
 854:	bda1                	j	6ac <vprintf+0x4a>
 856:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 858:	008b8d13          	addi	s10,s7,8
 85c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 860:	03000593          	li	a1,48
 864:	855a                	mv	a0,s6
 866:	d43ff0ef          	jal	5a8 <putc>
  putc(fd, 'x');
 86a:	07800593          	li	a1,120
 86e:	855a                	mv	a0,s6
 870:	d39ff0ef          	jal	5a8 <putc>
 874:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 876:	00000b97          	auipc	s7,0x0
 87a:	3b2b8b93          	addi	s7,s7,946 # c28 <digits>
 87e:	03c9d793          	srli	a5,s3,0x3c
 882:	97de                	add	a5,a5,s7
 884:	0007c583          	lbu	a1,0(a5)
 888:	855a                	mv	a0,s6
 88a:	d1fff0ef          	jal	5a8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 88e:	0992                	slli	s3,s3,0x4
 890:	397d                	addiw	s2,s2,-1
 892:	fe0916e3          	bnez	s2,87e <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 896:	8bea                	mv	s7,s10
      state = 0;
 898:	4981                	li	s3,0
 89a:	6d02                	ld	s10,0(sp)
 89c:	bd01                	j	6ac <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 89e:	008b8913          	addi	s2,s7,8
 8a2:	000bc583          	lbu	a1,0(s7)
 8a6:	855a                	mv	a0,s6
 8a8:	d01ff0ef          	jal	5a8 <putc>
 8ac:	8bca                	mv	s7,s2
      state = 0;
 8ae:	4981                	li	s3,0
 8b0:	bbf5                	j	6ac <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 8b2:	008b8993          	addi	s3,s7,8
 8b6:	000bb903          	ld	s2,0(s7)
 8ba:	00090f63          	beqz	s2,8d8 <vprintf+0x276>
        for(; *s; s++)
 8be:	00094583          	lbu	a1,0(s2)
 8c2:	c195                	beqz	a1,8e6 <vprintf+0x284>
          putc(fd, *s);
 8c4:	855a                	mv	a0,s6
 8c6:	ce3ff0ef          	jal	5a8 <putc>
        for(; *s; s++)
 8ca:	0905                	addi	s2,s2,1
 8cc:	00094583          	lbu	a1,0(s2)
 8d0:	f9f5                	bnez	a1,8c4 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 8d2:	8bce                	mv	s7,s3
      state = 0;
 8d4:	4981                	li	s3,0
 8d6:	bbd9                	j	6ac <vprintf+0x4a>
          s = "(null)";
 8d8:	00000917          	auipc	s2,0x0
 8dc:	34890913          	addi	s2,s2,840 # c20 <calloc+0xae>
        for(; *s; s++)
 8e0:	02800593          	li	a1,40
 8e4:	b7c5                	j	8c4 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 8e6:	8bce                	mv	s7,s3
      state = 0;
 8e8:	4981                	li	s3,0
 8ea:	b3c9                	j	6ac <vprintf+0x4a>
 8ec:	64a6                	ld	s1,72(sp)
 8ee:	79e2                	ld	s3,56(sp)
 8f0:	7a42                	ld	s4,48(sp)
 8f2:	7aa2                	ld	s5,40(sp)
 8f4:	7b02                	ld	s6,32(sp)
 8f6:	6be2                	ld	s7,24(sp)
 8f8:	6c42                	ld	s8,16(sp)
 8fa:	6ca2                	ld	s9,8(sp)
    }
  }
}
 8fc:	60e6                	ld	ra,88(sp)
 8fe:	6446                	ld	s0,80(sp)
 900:	6906                	ld	s2,64(sp)
 902:	6125                	addi	sp,sp,96
 904:	8082                	ret

0000000000000906 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 906:	715d                	addi	sp,sp,-80
 908:	ec06                	sd	ra,24(sp)
 90a:	e822                	sd	s0,16(sp)
 90c:	1000                	addi	s0,sp,32
 90e:	e010                	sd	a2,0(s0)
 910:	e414                	sd	a3,8(s0)
 912:	e818                	sd	a4,16(s0)
 914:	ec1c                	sd	a5,24(s0)
 916:	03043023          	sd	a6,32(s0)
 91a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 91e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 922:	8622                	mv	a2,s0
 924:	d3fff0ef          	jal	662 <vprintf>
}
 928:	60e2                	ld	ra,24(sp)
 92a:	6442                	ld	s0,16(sp)
 92c:	6161                	addi	sp,sp,80
 92e:	8082                	ret

0000000000000930 <printf>:

void
printf(const char *fmt, ...)
{
 930:	711d                	addi	sp,sp,-96
 932:	ec06                	sd	ra,24(sp)
 934:	e822                	sd	s0,16(sp)
 936:	1000                	addi	s0,sp,32
 938:	e40c                	sd	a1,8(s0)
 93a:	e810                	sd	a2,16(s0)
 93c:	ec14                	sd	a3,24(s0)
 93e:	f018                	sd	a4,32(s0)
 940:	f41c                	sd	a5,40(s0)
 942:	03043823          	sd	a6,48(s0)
 946:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 94a:	00840613          	addi	a2,s0,8
 94e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 952:	85aa                	mv	a1,a0
 954:	4505                	li	a0,1
 956:	d0dff0ef          	jal	662 <vprintf>
}
 95a:	60e2                	ld	ra,24(sp)
 95c:	6442                	ld	s0,16(sp)
 95e:	6125                	addi	sp,sp,96
 960:	8082                	ret

0000000000000962 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 962:	1141                	addi	sp,sp,-16
 964:	e422                	sd	s0,8(sp)
 966:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 968:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 96c:	00000797          	auipc	a5,0x0
 970:	6947b783          	ld	a5,1684(a5) # 1000 <freep>
 974:	a02d                	j	99e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 976:	4618                	lw	a4,8(a2)
 978:	9f2d                	addw	a4,a4,a1
 97a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 97e:	6398                	ld	a4,0(a5)
 980:	6310                	ld	a2,0(a4)
 982:	a83d                	j	9c0 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 984:	ff852703          	lw	a4,-8(a0)
 988:	9f31                	addw	a4,a4,a2
 98a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 98c:	ff053683          	ld	a3,-16(a0)
 990:	a091                	j	9d4 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 992:	6398                	ld	a4,0(a5)
 994:	00e7e463          	bltu	a5,a4,99c <free+0x3a>
 998:	00e6ea63          	bltu	a3,a4,9ac <free+0x4a>
{
 99c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 99e:	fed7fae3          	bgeu	a5,a3,992 <free+0x30>
 9a2:	6398                	ld	a4,0(a5)
 9a4:	00e6e463          	bltu	a3,a4,9ac <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9a8:	fee7eae3          	bltu	a5,a4,99c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 9ac:	ff852583          	lw	a1,-8(a0)
 9b0:	6390                	ld	a2,0(a5)
 9b2:	02059813          	slli	a6,a1,0x20
 9b6:	01c85713          	srli	a4,a6,0x1c
 9ba:	9736                	add	a4,a4,a3
 9bc:	fae60de3          	beq	a2,a4,976 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 9c0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9c4:	4790                	lw	a2,8(a5)
 9c6:	02061593          	slli	a1,a2,0x20
 9ca:	01c5d713          	srli	a4,a1,0x1c
 9ce:	973e                	add	a4,a4,a5
 9d0:	fae68ae3          	beq	a3,a4,984 <free+0x22>
    p->s.ptr = bp->s.ptr;
 9d4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9d6:	00000717          	auipc	a4,0x0
 9da:	62f73523          	sd	a5,1578(a4) # 1000 <freep>
}
 9de:	6422                	ld	s0,8(sp)
 9e0:	0141                	addi	sp,sp,16
 9e2:	8082                	ret

00000000000009e4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9e4:	7139                	addi	sp,sp,-64
 9e6:	fc06                	sd	ra,56(sp)
 9e8:	f822                	sd	s0,48(sp)
 9ea:	f426                	sd	s1,40(sp)
 9ec:	ec4e                	sd	s3,24(sp)
 9ee:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9f0:	02051493          	slli	s1,a0,0x20
 9f4:	9081                	srli	s1,s1,0x20
 9f6:	04bd                	addi	s1,s1,15
 9f8:	8091                	srli	s1,s1,0x4
 9fa:	0014899b          	addiw	s3,s1,1
 9fe:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a00:	00000517          	auipc	a0,0x0
 a04:	60053503          	ld	a0,1536(a0) # 1000 <freep>
 a08:	c915                	beqz	a0,a3c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a0a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a0c:	4798                	lw	a4,8(a5)
 a0e:	08977a63          	bgeu	a4,s1,aa2 <malloc+0xbe>
 a12:	f04a                	sd	s2,32(sp)
 a14:	e852                	sd	s4,16(sp)
 a16:	e456                	sd	s5,8(sp)
 a18:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a1a:	8a4e                	mv	s4,s3
 a1c:	0009871b          	sext.w	a4,s3
 a20:	6685                	lui	a3,0x1
 a22:	00d77363          	bgeu	a4,a3,a28 <malloc+0x44>
 a26:	6a05                	lui	s4,0x1
 a28:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a2c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a30:	00000917          	auipc	s2,0x0
 a34:	5d090913          	addi	s2,s2,1488 # 1000 <freep>
  if(p == SBRK_ERROR)
 a38:	5afd                	li	s5,-1
 a3a:	a081                	j	a7a <malloc+0x96>
 a3c:	f04a                	sd	s2,32(sp)
 a3e:	e852                	sd	s4,16(sp)
 a40:	e456                	sd	s5,8(sp)
 a42:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a44:	00000797          	auipc	a5,0x0
 a48:	5dc78793          	addi	a5,a5,1500 # 1020 <base>
 a4c:	00000717          	auipc	a4,0x0
 a50:	5af73a23          	sd	a5,1460(a4) # 1000 <freep>
 a54:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a56:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a5a:	b7c1                	j	a1a <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 a5c:	6398                	ld	a4,0(a5)
 a5e:	e118                	sd	a4,0(a0)
 a60:	a8a9                	j	aba <malloc+0xd6>
  hp->s.size = nu;
 a62:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a66:	0541                	addi	a0,a0,16
 a68:	efbff0ef          	jal	962 <free>
  return freep;
 a6c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a70:	c12d                	beqz	a0,ad2 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a72:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a74:	4798                	lw	a4,8(a5)
 a76:	02977263          	bgeu	a4,s1,a9a <malloc+0xb6>
    if(p == freep)
 a7a:	00093703          	ld	a4,0(s2)
 a7e:	853e                	mv	a0,a5
 a80:	fef719e3          	bne	a4,a5,a72 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a84:	8552                	mv	a0,s4
 a86:	a47ff0ef          	jal	4cc <sbrk>
  if(p == SBRK_ERROR)
 a8a:	fd551ce3          	bne	a0,s5,a62 <malloc+0x7e>
        return 0;
 a8e:	4501                	li	a0,0
 a90:	7902                	ld	s2,32(sp)
 a92:	6a42                	ld	s4,16(sp)
 a94:	6aa2                	ld	s5,8(sp)
 a96:	6b02                	ld	s6,0(sp)
 a98:	a03d                	j	ac6 <malloc+0xe2>
 a9a:	7902                	ld	s2,32(sp)
 a9c:	6a42                	ld	s4,16(sp)
 a9e:	6aa2                	ld	s5,8(sp)
 aa0:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 aa2:	fae48de3          	beq	s1,a4,a5c <malloc+0x78>
        p->s.size -= nunits;
 aa6:	4137073b          	subw	a4,a4,s3
 aaa:	c798                	sw	a4,8(a5)
        p += p->s.size;
 aac:	02071693          	slli	a3,a4,0x20
 ab0:	01c6d713          	srli	a4,a3,0x1c
 ab4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 ab6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 aba:	00000717          	auipc	a4,0x0
 abe:	54a73323          	sd	a0,1350(a4) # 1000 <freep>
      return (void*)(p + 1);
 ac2:	01078513          	addi	a0,a5,16
  }
}
 ac6:	70e2                	ld	ra,56(sp)
 ac8:	7442                	ld	s0,48(sp)
 aca:	74a2                	ld	s1,40(sp)
 acc:	69e2                	ld	s3,24(sp)
 ace:	6121                	addi	sp,sp,64
 ad0:	8082                	ret
 ad2:	7902                	ld	s2,32(sp)
 ad4:	6a42                	ld	s4,16(sp)
 ad6:	6aa2                	ld	s5,8(sp)
 ad8:	6b02                	ld	s6,0(sp)
 ada:	b7f5                	j	ac6 <malloc+0xe2>

0000000000000adc <realloc>:

void*
realloc(void *ptr, uint nbytes)
{
 adc:	7139                	addi	sp,sp,-64
 ade:	fc06                	sd	ra,56(sp)
 ae0:	f822                	sd	s0,48(sp)
 ae2:	f426                	sd	s1,40(sp)
 ae4:	e852                	sd	s4,16(sp)
 ae6:	0080                	addi	s0,sp,64
 ae8:	84ae                	mv	s1,a1
  void *new_ptr;
  char *src, *dst;
  uint i;

  // If ptr is NULL, behave like malloc
  if(ptr == 0)
 aea:	c535                	beqz	a0,b56 <realloc+0x7a>
 aec:	f04a                	sd	s2,32(sp)
 aee:	892a                	mv	s2,a0
    return malloc(nbytes);

  // If nbytes is 0, behave like free and return NULL
  if(nbytes == 0){
 af0:	c9a5                	beqz	a1,b60 <realloc+0x84>
 af2:	ec4e                	sd	s3,24(sp)
 af4:	e456                	sd	s5,8(sp)
    return 0;
  }

  // Get the header of the old block
  bp = (Header*)ptr - 1;
  old_size = (bp->s.size - 1) * sizeof(Header);
 af6:	ff852983          	lw	s3,-8(a0)
 afa:	fff9879b          	addiw	a5,s3,-1
 afe:	00479a9b          	slliw	s5,a5,0x4

  // Allocate new block
  new_ptr = malloc(nbytes);
 b02:	852e                	mv	a0,a1
 b04:	ee1ff0ef          	jal	9e4 <malloc>
 b08:	8a2a                	mv	s4,a0
  if(new_ptr == 0)
 b0a:	c125                	beqz	a0,b6a <realloc+0x8e>
    return 0;

  // Copy old content to new block (copy minimum of old and new sizes)
  src = (char*)ptr;
  dst = (char*)new_ptr;
  for(i = 0; i < old_size && i < nbytes; i++)
 b0c:	020a8863          	beqz	s5,b3c <realloc+0x60>
 b10:	0049961b          	slliw	a2,s3,0x4
 b14:	363d                	addiw	a2,a2,-17
 b16:	1602                	slli	a2,a2,0x20
 b18:	9201                	srli	a2,a2,0x20
 b1a:	02049593          	slli	a1,s1,0x20
 b1e:	9181                	srli	a1,a1,0x20
 b20:	4781                	li	a5,0
    dst[i] = src[i];
 b22:	00f90733          	add	a4,s2,a5
 b26:	00074683          	lbu	a3,0(a4)
 b2a:	00fa0733          	add	a4,s4,a5
 b2e:	00d70023          	sb	a3,0(a4)
  for(i = 0; i < old_size && i < nbytes; i++)
 b32:	00c78563          	beq	a5,a2,b3c <realloc+0x60>
 b36:	0785                	addi	a5,a5,1
 b38:	feb795e3          	bne	a5,a1,b22 <realloc+0x46>

  // Free old block
  free(ptr);
 b3c:	854a                	mv	a0,s2
 b3e:	e25ff0ef          	jal	962 <free>
 b42:	7902                	ld	s2,32(sp)
 b44:	69e2                	ld	s3,24(sp)
 b46:	6aa2                	ld	s5,8(sp)

  return new_ptr;
}
 b48:	8552                	mv	a0,s4
 b4a:	70e2                	ld	ra,56(sp)
 b4c:	7442                	ld	s0,48(sp)
 b4e:	74a2                	ld	s1,40(sp)
 b50:	6a42                	ld	s4,16(sp)
 b52:	6121                	addi	sp,sp,64
 b54:	8082                	ret
    return malloc(nbytes);
 b56:	852e                	mv	a0,a1
 b58:	e8dff0ef          	jal	9e4 <malloc>
 b5c:	8a2a                	mv	s4,a0
 b5e:	b7ed                	j	b48 <realloc+0x6c>
    free(ptr);
 b60:	e03ff0ef          	jal	962 <free>
    return 0;
 b64:	4a01                	li	s4,0
 b66:	7902                	ld	s2,32(sp)
 b68:	b7c5                	j	b48 <realloc+0x6c>
 b6a:	7902                	ld	s2,32(sp)
 b6c:	69e2                	ld	s3,24(sp)
 b6e:	6aa2                	ld	s5,8(sp)
 b70:	bfe1                	j	b48 <realloc+0x6c>

0000000000000b72 <calloc>:

void*
calloc(uint num, uint size)
{
 b72:	1101                	addi	sp,sp,-32
 b74:	ec06                	sd	ra,24(sp)
 b76:	e822                	sd	s0,16(sp)
 b78:	e426                	sd	s1,8(sp)
 b7a:	e04a                	sd	s2,0(sp)
 b7c:	1000                	addi	s0,sp,32
  void *ptr;
  char *p;
  uint i;

  // Calculate total size needed
  total_size = num * size;
 b7e:	02b504bb          	mulw	s1,a0,a1
 b82:	0004891b          	sext.w	s2,s1

  // Allocate memory
  ptr = malloc(total_size);
 b86:	854a                	mv	a0,s2
 b88:	e5dff0ef          	jal	9e4 <malloc>
  if(ptr == 0)
 b8c:	cd09                	beqz	a0,ba6 <calloc+0x34>
    return 0;

  // Initialize all bytes to zero
  p = (char*)ptr;
  for(i = 0; i < total_size; i++)
 b8e:	00090c63          	beqz	s2,ba6 <calloc+0x34>
 b92:	87aa                	mv	a5,a0
 b94:	02049713          	slli	a4,s1,0x20
 b98:	9301                	srli	a4,a4,0x20
 b9a:	972a                	add	a4,a4,a0
    p[i] = 0;
 b9c:	00078023          	sb	zero,0(a5)
  for(i = 0; i < total_size; i++)
 ba0:	0785                	addi	a5,a5,1
 ba2:	fee79de3          	bne	a5,a4,b9c <calloc+0x2a>

  return ptr;
}
 ba6:	60e2                	ld	ra,24(sp)
 ba8:	6442                	ld	s0,16(sp)
 baa:	64a2                	ld	s1,8(sp)
 bac:	6902                	ld	s2,0(sp)
 bae:	6105                	addi	sp,sp,32
 bb0:	8082                	ret
