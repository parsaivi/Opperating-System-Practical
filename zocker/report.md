# گزارش تمرین ۲ - ایزوله‌سازی فایل‌سیستم کانتینرها

## مقدمه

در این تمرین، هدف پیاده‌سازی ایزوله‌سازی فایل‌سیستم برای کانتینرها با استفاده از فراخوان سیستمی `chroot(2)` است. این کار باعث می‌شود کانتینر نتواند به فایل‌های میزبان دسترسی داشته باشد.

---

## بخش اول - بررسی داکر

### گام آ: اجرای کانتینر busybox

```bash
docker run -d --name busybox-test busybox sleep 1000
```

### گام ب: اجرای شل در کانتینر

```bash
docker exec -it busybox-test sh
cd /
ls
```

### گام ج: بررسی MergedDir

```bash
docker inspect busybox-test | jq '.[].GraphDriver.Data.MergedDir'
sudo su
cd <مسیر-بدست-آمده>
ls
```

محتوای این مسیر با ریشه کانتینر یکسان است.

---

## سوال ۱: چگونه ممکن است مسیر ریشه کانتینر داکر از مسیر ریشه میزبان متفاوت باشد؟

### پاسخ:

داکر از فراخوان سیستمی `chroot()` یا `pivot_root()` استفاده می‌کند تا مسیر ریشه را برای پروسه کانتینر تغییر دهد.

وقتی یک کانتینر شروع به کار می‌کند:

1. داکر ایمیج را در یک دایرکتوری استخراج می‌کند (مثلاً `/var/lib/docker/overlay2/.../merged`)
2. با استفاده از `chroot()` یا `pivot_root()`، ریشه کانتینر به آن دایرکتوری تغییر می‌کند
3. از دید کانتینر، `/` همان فایل‌سیستم ایمیج است، نه ریشه واقعی میزبان

به همین دلیل است که با دستور `docker inspect` می‌توان مسیر واقعی میزبان (MergedDir) را که معادل `/` کانتینر است مشاهده کرد.

---

## بخش دوم - پیاده‌سازی در Zocker

### پیش‌نیازها

```bash
mkdir -p /tmp/zocker
git checkout t3
```

### پاکسازی قبل از هر اجرا

```bash
rm -rf /tmp/zocker/test-container
```

---

### گام د: اضافه کردن chroot به src/run.c

تغییرات انجام شده در فایل `src/run.c`:

```c
if (chroot(container_dir) != 0) {
  fprintf(stderr, "[ERR] Failed to chroot to %s: %s\n", container_dir,
          strerror(errno));
  return 1;
}

if (chdir("/") != 0) {
  fprintf(stderr, "[ERR] Failed to chdir to /: %s\n", strerror(errno));
  return 1;
}
```

این کد پس از `setup_container_dir()` و قبل از mount کردن `/proc` اضافه شد.

**نتیجه:** پس از اجرا، با خطای زیر مواجه می‌شویم:

```
[ERR] Failed to remount /proc: No such file or directory
```

---

## سوال ۲: علت بروز خطای /proc چیست؟

### پاسخ:

پس از اجرای `chroot()`، ریشه جدید فایل‌سیستم به مسیر `/tmp/zocker/test-container` تغییر می‌کند. این دایرکتوری خالی است و پوشه `/proc` در آن وجود ندارد.

وقتی می‌خواهیم `procfs` را در `/proc` mount کنیم، چون این پوشه وجود ندارد، عملیات mount با خطای "No such file or directory" شکست می‌خورد.

### راه‌حل:

ایجاد پوشه `/proc` پس از chroot و قبل از mount:

```c
if (mkdir("/proc", 0755) == -1 && errno != EEXIST) {
  fprintf(stderr, "[ERR] Failed to create /proc: %s\n", strerror(errno));
  return 1;
}
```

---

### گام ه و و: خطای بعدی

پس از رفع خطای قبلی، با خطای زیر مواجه می‌شویم:

```
[ERR] Failed to call create container process: No such file or directory
```

---

## سوال ۳: چرا این خطا رخ می‌دهد؟

### پاسخ:

پس از `chroot()`، پروسه سعی می‌کند `/bin/sh` را اجرا کند. اما در ریشه جدید (یعنی `/tmp/zocker/test-container`)، فایل `/bin/sh` وجود ندارد.

توابع `setup_bin_dir` و `setup_lib_dir` فقط پوشه‌های خالی ایجاد می‌کنند و هیچ فایل باینری یا کتابخانه‌ای در آن‌ها کپی نمی‌شود.

### راه‌حل:

تغییر توابع در `src/setup.c` برای:
1. کپی کردن باینری‌های لازم (`/bin/sh`, `/bin/ls`, `/bin/cat`, `/bin/pwd`) به دایرکتوری کانتینر
2. کپی کردن کتابخانه‌های مشترک مورد نیاز (با استفاده از `ldd`)

---

## تغییرات کد

### فایل src/run.c

```c
// اضافه شده پس از mount private
if (chroot(container_dir) != 0) {
  fprintf(stderr, "[ERR] Failed to chroot to %s: %s\n", container_dir,
          strerror(errno));
  return 1;
}

if (chdir("/") != 0) {
  fprintf(stderr, "[ERR] Failed to chdir to /: %s\n", strerror(errno));
  return 1;
}

if (mkdir("/proc", 0755) == -1 && errno != EEXIST) {
  fprintf(stderr, "[ERR] Failed to create /proc: %s\n", strerror(errno));
  return 1;
}
```

### فایل src/setup.c

تابع کمکی برای کپی فایل‌ها و کتابخانه‌ها:

```c
static int copy_file(const char *src, const char *dst) {
  char cmd[512];
  snprintf(cmd, sizeof(cmd), "cp %s %s", src, dst);
  return system(cmd);
}

static int copy_libs_for_binary(const char *binary, const char *container_dir) {
  // استفاده از ldd برای پیدا کردن کتابخانه‌های مشترک
  // و کپی آن‌ها به دایرکتوری کانتینر
}
```

تغییر تابع `setup_bin_dir`:

```c
const char *binaries[] = {"/bin/sh", "/bin/ls", "/bin/cat", "/bin/pwd", NULL};

for (int i = 0; binaries[i] != NULL; i++) {
  // کپی باینری به دایرکتوری کانتینر
  copy_file(binaries[i], dest);
  // کپی کتابخانه‌های مورد نیاز
  copy_libs_for_binary(binaries[i], container_dir);
}
```

---

## گام ز: تأیید عملکرد

### دستورات اجرا:

```bash
make
sudo setcap cap_sys_admin,cap_sys_chroot+ep zocker
rm -rf /tmp/zocker/test-container
./zocker run --name test-container 'sh'
```

### تست داخل کانتینر:

```bash
$ pwd
/

$ ls /
bin  lib  lib32  lib64  proc

$ cd /..
$ pwd
/

$ ls
bin  lib  lib32  lib64  proc

$ cat /etc/passwd
cat: /etc/passwd: No such file or directory
```

### مقایسه با میزبان:

در میزبان:
```bash
$ ls /
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```

**نتیجه:** کانتینر فقط فایل‌های موجود در دایرکتوری ایزوله خود را می‌بیند و دسترسی به فایل‌های میزبان ندارد.

---

## گام ح (اختیاری): دسترسی به فایل‌های میزبان از داخل کانتینر

می‌توان با استفاده از **bind mount** یک دایرکتوری میزبان را قبل از chroot به داخل دایرکتوری کانتینر mount کرد:

```c
char host_mount[512];
snprintf(host_mount, sizeof(host_mount), "%s/host", container_dir);
mkdir(host_mount, 0755);
mount("/home", host_mount, NULL, MS_BIND, NULL);
```

پس از این تغییر، داخل کانتینر می‌توان با `ls /host` به فایل‌های `/home` میزبان دسترسی داشت.

---

## نتیجه‌گیری

با استفاده از فراخوان سیستمی `chroot(2)`:
- ریشه فایل‌سیستم کانتینر تغییر می‌کند
- کانتینر نمی‌تواند به فایل‌های خارج از ریشه جدید دسترسی داشته باشد
- برای عملکرد صحیح، باید باینری‌ها و کتابخانه‌های لازم در ریشه جدید موجود باشند
