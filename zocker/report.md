# گزارش تمرین 4 - Docker Container Implementation

**تاریخ انجام**: ۲۳ دسامبر ۲۰۲۵  
**موضوع**: پیاده‌سازی قابلیت اجرای کانتینر بر اساس یک دایرکتوری پایه دلخواه

---

## فهرست مطالب
1. [مقدمه](#مقدمه)
2. [مراحل انجام کار](#مراحل-انجام-کار)
3. [پاسخ به سوالات](#پاسخ-به-سوالات)
4. [تغییرات کد](#تغییرات-کد)
5. [نتایج و تست‌ها](#نتایج-و-تستها)
6. [نتیجه‌گیری](#نتیجهگیری)

---

## مقدمه

در این تمرین، هدف توسعه پروژه Zocker بود تا بتوانیم کانتینرها را بر اساس یک دایرکتوری پایه (base directory) دلخواه اجرا کنیم. این قابلیت به ما اجازه می‌دهد تا از یک فایل سیستم استخراج شده از یک ایمیج Docker استاندارد (مانند Alpine Linux) برای اجرای کانتینرهای Zocker استفاده کنیم.

### اهداف تمرین:
- آشنایی با دستور `docker export`
- درک تفاوت‌های بین فایل سیستم export شده و کانتینر در حال اجرا
- پیاده‌سازی قابلیت `--base-dir` در Zocker
- بررسی محدودیت‌های روش ساده کپی کردن فایل سیستم

---

## مراحل انجام کار

### گام آ: دریافت آخرین نسخه و رفتن به تگ t4

ابتدا آخرین نسخه پروژه را از مخزن دریافت کرده و به تگ `t4` رفتیم:

```bash
cd /home/divar/Documents/OS/zock/zocker
git pull origin master
git checkout t4
```

**نتیجه**: Successfully switched to tag t4 with commit "Add Task 4"

---

### گام ب: دریافت ایمیج Alpine

ایمیج `alpine:3.22.2` را از Docker Hub دریافت کردیم:

```bash
docker pull alpine:3.22.2
```

**نتیجه**: 
```
3.22.2: Pulling from library/alpine
Digest: sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412
Status: Image is up to date for alpine:3.22.2
```

---

### گام ج: اجرای کانتینر با ایمیج Alpine

یک کانتینر بر اساس ایمیج Alpine با دستور زیر اجرا کردیم:

```bash
docker run --rm -d alpine:3.22.2 sleep 1000
```

**نتیجه**: Container ID: `7e9a61c7ca6b3adaefd8cd8271531b6c73c0ef24fdb28cf2ed1aa6a0afc32b8a`

**توضیح پرچم `--rm`**: 
این پرچم به Docker می‌گوید که به محض متوقف شدن کانتینر، آن را به صورت خودکار حذف کند. این کار باعث می‌شود که کانتینرهای متوقف شده در سیستم انباشته نشوند و فضای دیسک را اشغال نکنند.

---

### گام د: Export کردن فایل سیستم کانتینر

با استفاده از دستور زیر، ساختار فایل سیستم کانتینر را در فایل `export.tar` ذخیره کردیم:

```bash
docker export 7e9a61c7ca6b -o export.tar
```

این دستور تمام فایل‌های موجود در فایل سیستم کانتینر (شامل /bin, /etc, /lib و غیره) را در یک فایل tar فشرده ذخیره می‌کند.

---

### گام ه: استخراج و مقایسه محتوای فایل

محتوای فایل `export.tar` را در دایرکتوری موقت استخراج کردیم:

```bash
mkdir -p /tmp/export_test
tar -xf export.tar -C /tmp/export_test
ls -la /tmp/export_test/
```

**نتیجه ساختار دایرکتوری**:
```
drwxr-xr-x   2 bin
drwxr-xr-x   4 dev
-rwxr-xr-x   1 .dockerenv
drwxr-xr-x  17 etc
drwxr-xr-x   2 home
drwxr-xr-x   6 lib
drwxr-xr-x   5 media
drwxr-xr-x   2 mnt
drwxr-xr-x   2 opt
dr-xr-xr-x   2 proc (خالی)
drwx------   2 root
drwxr-xr-x   3 run
drwxr-xr-x   2 sbin
drwxr-xr-x   2 srv
drwxr-xr-x   2 sys
drwxrwxr-x   2 tmp
drwxr-xr-x   7 usr
drwxr-xr-x  11 var
```

#### مقایسه دایرکتوری /proc

**در فایل export شده**:
```bash
ls -la /tmp/export_test/proc/
# نتیجه: خالی (فقط . و ..)
```

**در کانتینر در حال اجرا**:
```bash
docker exec 7e9a61c7ca6b ls -la /proc/ | head -20
# نتیجه: پر از فایل‌ها و دایرکتوری‌های مرتبط با پروسس‌ها
# شامل: 1, 7, acpi, buddyinfo, cmdline, cpuinfo, devices, ...
```

**علت تفاوت**: 
دایرکتوری `/proc` یک filesystem مجازی (pseudo-filesystem) است که توسط کرنل لینوکس در زمان اجرا ایجاد می‌شود و اطلاعات پروسس‌ها و سیستم را نمایش می‌دهد. دستور `docker export` فقط فایل‌های واقعی را export می‌کند و filesystemهای مجازی مانند `/proc`, `/sys`, و `/dev` را شامل نمی‌شود. در کانتینر در حال اجرا، `/proc` توسط کرنل mount شده و پر از اطلاعات است، اما در export شده فقط یک دایرکتوری خالی است.

---

### گام و: استخراج در دایرکتوری نهایی

محتوای فایل را در مسیر `/tmp/zocker/mycontainer` استخراج کردیم:

```bash
mkdir -p /tmp/zocker/mycontainer
tar -xf export.tar -C /tmp/zocker/mycontainer
ls -la /tmp/zocker/mycontainer/
```

---

### گام ز: تغییرات کد

تابع `run_container` در فایل `src/run.c` را تغییر دادیم تا از پارامتر `base_dir` پشتیبانی کند:

#### تغییرات اعمال شده:

1. **بررسی وجود base_dir**: اگر `base_dir` مقداری داشته باشد، از آن به عنوان دایرکتوری کانتینر استفاده می‌کنیم، در غیر این صورت از `setup_container_dir` استفاده می‌کنیم.

2. **مدیریت دایرکتوری /proc**: چون در base_dir مستخرج شده، دایرکتوری /proc از قبل وجود دارد، قبل از ایجاد آن بررسی می‌کنیم که آیا وجود دارد یا خیر.

#### کد قبل از تغییر:
```c
if (pid == 0) {
    char container_dir[256];
    if (setup_container_dir(cont.id, container_dir) != 0) {
      fprintf(stderr, "[ERR] Failed to setup container directory for %s\n",
              cont.id);
      return 1;
    }
    // ...
}
```

#### کد بعد از تغییر:
```c
if (pid == 0) {
    char container_dir[256];
    
    // Use base_dir if provided, otherwise setup container directory
    if (strlen(cont.base_dir) > 0) {
      strncpy(container_dir, cont.base_dir, sizeof(container_dir) - 1);
      container_dir[sizeof(container_dir) - 1] = '\0';
    } else {
      if (setup_container_dir(cont.id, container_dir) != 0) {
        fprintf(stderr, "[ERR] Failed to setup container directory for %s\n",
                cont.id);
        return 1;
      }
    }
    // ...
}
```

و همچنین برای مدیریت /proc:

```c
// Create /proc directory if it doesn't exist (it might exist in base_dir)
struct stat st;
if (stat("/proc", &st) == -1) {
  if (mkdir("/proc", 0555) != 0) {
    fprintf(stderr, "[ERR] Failed to create /proc directory: %s\n",
            strerror(errno));
    return 1;
  }
}
```

---

### گام ح: کامپایل و تست

پروژه را کامپایل کرده و تست کردیم:

```bash
make clean && make
```

**تست 1: اجرای دستورات در کانتینر**
```bash
./zocker run --name my-container --base-dir /tmp/zocker/mycontainer \
    'ls -la / && cat /test.txt && echo "Current hostname:" && hostname'
```

**نتیجه**:
```
Running child with pid: 1
total 76
drwxrwxr-x   19 1000     1000          4096 Dec 23 03:54 .
drwxrwxr-x   19 1000     1000          4096 Dec 23 03:54 ..
-rwxr-xr-x    1 1000     1000             0 Dec 23 03:50 .dockerenv
drwxr-xr-x    2 1000     1000          4096 Oct  8 09:28 bin
...
-rw-rw-r--    1 1000     1000            17 Dec 23 03:54 test.txt
...
Hello from host!
Current hostname:
my-container
[Parent] Stoping...
```

✅ **موفقیت‌آمیز**: کانتینر با موفقیت اجرا شد و تمام قابلیت‌ها از جمله:
- دسترسی به فایل‌های موجود در base_dir
- PID namespace جداگانه (pid=1)
- Hostname تنظیم شده
- دسترسی به /proc mount شده

---

## پاسخ به سوالات

### سوال 1: پرچم `--rm` چه کاربردی دارد؟

**پاسخ**: پرچم `--rm` در دستور `docker run` مشخص می‌کند که کانتینر باید به صورت خودکار پس از متوقف شدن حذف شود. این کار مزایای زیر را دارد:

1. **مدیریت خودکار منابع**: جلوگیری از انباشته شدن کانتینرهای متوقف شده
2. **صرفه‌جویی در فضای دیسک**: کانتینرهای موقت فضای اضافی اشغال نمی‌کنند
3. **تمیزکاری خودکار**: نیازی به اجرای `docker rm` به صورت دستی نیست
4. **مناسب برای تست**: برای اجرای کانتینرهای موقت و یکبار مصرف ایده‌آل است

**مثال کاربردی**:
- بدون `--rm`: `docker run -d alpine sleep 10` → کانتینر پس از اتمام باقی می‌ماند
- با `--rm`: `docker run --rm -d alpine sleep 10` → کانتینر پس از اتمام حذف می‌شود

---

### سوال 2: علت تفاوت محتوای پوشه /proc

**پاسخ**: 

**مشاهده**:
- در فایل export شده: `/proc` یک دایرکتوری خالی است
- در کانتینر در حال اجرا: `/proc` پر از صدها فایل و دایرکتوری است

**علت**:
1. **ماهیت /proc**: `/proc` یک pseudo-filesystem است که توسط کرنل Linux در runtime ایجاد می‌شود و یک interface به اطلاعات کرنل و پروسس‌ها ارائه می‌دهد.

2. **عملکرد docker export**: این دستور فقط فایل‌های واقعی (regular files) روی دیسک را export می‌کند. Filesystemهای مجازی مانند:
   - `/proc` (process information)
   - `/sys` (system information)
   - `/dev` (device files)
   
   در زمان export کپی نمی‌شوند، چون محتوای واقعی ندارند و فقط در runtime توسط کرنل populate می‌شوند.

3. **مکانیزم mount**: در کانتینر در حال اجرا، `/proc` توسط دستور `mount -t proc` mount می‌شود و کرنل به صورت پویا محتوای آن را تولید می‌کند.

**نتیجه**: در پیاده‌سازی Zocker، باید پس از chroot کردن، `/proc` را به صورت دستی mount کنیم تا کانتینر به اطلاعات پروسس دسترسی داشته باشد.

---

### سوال 3: آیا فایل اضافه شده به `/tmp/zocker/mycontainer/test.txt` از داخل کانتینر قابل دسترسی است؟

**پاسخ**: **بله، کاملاً قابل دسترسی است.**

**توضیح**:
1. **مکانیزم chroot**: وقتی با `chroot(/tmp/zocker/mycontainer)` ریشه فایل سیستم را تغییر می‌دهیم، تمام محتوای این دایرکتوری برای پروسس کانتینر به عنوان root filesystem قابل دسترسی می‌شود.

2. **دسترسی مستقیم**: فایل `/tmp/zocker/mycontainer/test.txt` در هاست، از دید کانتینر به صورت `/test.txt` قابل دسترسی است.

3. **اشتراک فایل سیستم**: هر تغییری که در هاست در `/tmp/zocker/mycontainer/` ایجاد شود، بلافاصله در کانتینر نیز قابل مشاهده است (و بالعکس).

**اثبات عملی**:
```bash
# در هاست
echo "Hello from host!" > /tmp/zocker/mycontainer/test.txt

# در کانتینر
./zocker run --name my-container --base-dir /tmp/zocker/mycontainer 'cat /test.txt'
# نتیجه: Hello from host!
```

**نکات امنیتی**:
- این رویکرد می‌تواند خطرات امنیتی داشته باشد اگر permissions درست تنظیم نشوند
- در پیاده‌سازی واقعی Docker، از layered filesystem (overlay/aufs) استفاده می‌شود

---

### سوال 4: آیا در پیاده‌سازی اصلی Docker از همین روش استفاده شده است؟ اگر خیر، یکی از دلایل مهم ناکارآمد بودن این روش را ذکر کنید.

**پاسخ**: **خیر، Docker از این روش ساده استفاده نمی‌کند.**

**دلایل اصلی ناکارآمدی این روش**:

#### 1. **مصرف بالای فضای دیسک (Storage Inefficiency)**
**مشکل**: اگر بخواهیم 100 کانتینر با یک ایمیج یکسان (مثلاً Alpine 3.22.2) اجرا کنیم:
- روش فعلی: هر کانتینر نیاز به کپی کامل فایل سیستم دارد
  ```
  100 کانتینر × 5 MB (اندازه Alpine) = 500 MB
  ```
- روش Docker (با استفاده از layers): فقط یک کپی از base image + تغییرات هر کانتینر
  ```
  1 × 5 MB (base) + 100 × ~کیلوبایت (تغییرات) ≈ 5-10 MB
  ```

**مثال عملی**:
```bash
# روش فعلی (ناکارآمد)
کانتینر 1: /tmp/zocker/container1/ (5 MB)
کانتینر 2: /tmp/zocker/container2/ (5 MB)
کانتینر 3: /tmp/zocker/container3/ (5 MB)
...
کانتینر 100: /tmp/zocker/container100/ (5 MB)
# جمع: 500 MB برای 100 کانتینر یکسان!
```

#### 2. **زمان راه‌اندازی طولانی**
- کپی کردن کل فایل سیستم برای هر کانتینر زمان‌بر است
- در روش Docker با استفاده از Copy-on-Write، فقط تغییرات کپی می‌شوند

#### 3. **عدم اشتراک‌گذاری بین کانتینرها**
- هر کانتینر نسخه مجزای خود را از فایل‌های مشترک دارد
- Docker از Union Filesystem (OverlayFS, AUFS) استفاده می‌کند که:
  - Layers پایه read-only هستند و بین همه کانتینرها مشترک
  - فقط تغییرات در layer بالایی ذخیره می‌شوند

#### 4. **مدیریت نسخه‌ها و به‌روزرسانی**
- اگر بخواهیم ایمیج پایه را به‌روزرسانی کنیم، باید تمام کانتینرها را دوباره کپی کنیم
- در Docker: فقط base layer را یکبار update می‌کنیم

**راه‌حل Docker**: استفاده از **Layered Filesystem**

Docker از یک سیستم لایه‌ای استفاده می‌کند که شامل:
1. **Base Layer(s)**: Read-only, مشترک بین همه کانتینرها
2. **Container Layer**: Read-write, منحصر به هر کانتینر
3. **Union Filesystem**: ترکیب لایه‌ها به صورت یک view واحد

```
[Container 1 Layer (R/W)] ←─ تغییرات کانتینر 1
[Container 2 Layer (R/W)] ←─ تغییرات کانتینر 2
         ↓                           ↓
[Alpine Base Layer (R/O)] ←─ مشترک (یک کپی)
```

**مزایا**:
- ✅ صرفه‌جویی در فضا
- ✅ سرعت بالا در راه‌اندازی
- ✅ اشتراک منابع
- ✅ عزل‌سازی تغییرات

---

## تغییرات کد

### فایل: `src/run.c`

تغییرات اصلی در تابع `run_container` انجام شد:

```c
int run_container(struct container cont) {
  pid_t pid;

  if (unshare(CLONE_NEWPID | CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWTIME) != 0) {
    return 1;
  }

  pid = fork();
  if (pid < 0) {
    return 1;
  }

  if (pid == 0) {
    char container_dir[256];
    
    // ✨ تغییر 1: پشتیبانی از base_dir
    // Use base_dir if provided, otherwise setup container directory
    if (strlen(cont.base_dir) > 0) {
      strncpy(container_dir, cont.base_dir, sizeof(container_dir) - 1);
      container_dir[sizeof(container_dir) - 1] = '\0';
    } else {
      if (setup_container_dir(cont.id, container_dir) != 0) {
        fprintf(stderr, "[ERR] Failed to setup container directory for %s\n",
                cont.id);
        return 1;
      }
    }

    if (mount(NULL, "/", NULL, MS_REC | MS_PRIVATE, NULL) != 0) {
      fprintf(stderr, "[ERR] Failed to change mount to private: %s\n",
              strerror(errno));
      return 1;
    }

    if (chroot(container_dir) != 0) {
      fprintf(stderr,
              "[ERR] Failed to chroot into container directory for %s: %s\n",
              cont.id, strerror(errno));
      return 1;
    }

    if (chdir("/") != 0) {
      fprintf(stderr, "[ERR] Failed to change directory to root: %s\n",
              strerror(errno));
      return 1;
    }

    // ✨ تغییر 2: بررسی وجود /proc قبل از ایجاد
    // Create /proc directory if it doesn't exist (it might exist in base_dir)
    struct stat st;
    if (stat("/proc", &st) == -1) {
      if (mkdir("/proc", 0555) != 0) {
        fprintf(stderr, "[ERR] Failed to create /proc directory: %s\n",
                strerror(errno));
        return 1;
      }
    }

    if (mount(NULL, "/proc", "proc", 0, NULL) != 0) {
      fprintf(stderr, "[ERR] Failed to remount /proc: %s\n", strerror(errno));
      return 1;
    }

    if (sethostname(cont.id, 64) != 0) {
      fprintf(stderr, "[ERR] Failed to set hostname\n");
      return 1;
    }

    printf("Running child with pid: %d\n", getpid());
    if (execl("/bin/sh", "sh", "-c", cont.command, NULL) != 0) {
      fprintf(stderr, "[ERR] Failed to call create container process: %s\n",
              strerror(errno));
      return 1;
    }
  } else {
    sleep(2);
    waitpid(pid, NULL, 0);
    printf("[Parent] Stoping...\n");
  }
  return 0;
}
```

### توضیح تغییرات:

#### تغییر 1: پشتیبانی از `base_dir`
قبلاً همیشه از `setup_container_dir` استفاده می‌شد که یک دایرکتوری جدید می‌ساخت. حالا:
- اگر `cont.base_dir` مقداری داشته باشد، مستقیماً از آن استفاده می‌کنیم
- در غیر این صورت، رفتار قبلی (setup_container_dir) را حفظ می‌کنیم
- این backward compatibility را حفظ می‌کند

#### تغییر 2: مدیریت هوشمند `/proc`
چون در base_dir استخراج شده، دایرکتوری `/proc` از قبل وجود دارد:
- با `stat` وجود `/proc` را بررسی می‌کنیم
- فقط در صورت عدم وجود، آن را ایجاد می‌کنیم
- این از خطای "Directory exists" جلوگیری می‌کند

---

## نتایج و تست‌ها

### تست 1: اجرای دستورات متعدد
```bash
./zocker run --name my-container --base-dir /tmp/zocker/mycontainer \
    'ls -la / && cat /test.txt && hostname'
```

**نتیجه**: ✅ موفقیت‌آمیز
- تمام دایرکتوری‌های Alpine نمایش داده شدند
- فایل test.txt خوانده شد: "Hello from host!"
- Hostname صحیح نمایش داده شد: "my-container"
- PID فرزند: 1 (نشان‌دهنده PID namespace جداگانه)

### تست 2: بررسی /proc
```bash
./zocker run --name my-container --base-dir /tmp/zocker/mycontainer 'ls /proc/ | head'
```

**نتیجه**: ✅ /proc به درستی mount شده و حاوی اطلاعات پروسس است

### تست 3: اجرای Shell تعاملی
```bash
timeout 5 ./zocker run --name my-container --base-dir /tmp/zocker/mycontainer 'sh'
```

**نتیجه**: ✅ Shell اجرا شد و به درستی کار می‌کند

### تست 4: Backward Compatibility
```bash
./zocker run --name test 'echo "Old method still works"'
```

**نتیجه**: ✅ روش قدیمی (بدون --base-dir) همچنان کار می‌کند

---

## نتیجه‌گیری

### دستاوردها:
1. ✅ پیاده‌سازی موفق قابلیت `--base-dir` در Zocker
2. ✅ امکان استفاده از فایل سیستم‌های export شده از Docker
3. ✅ درک عمیق از تفاوت‌های `/proc` در حالت‌های مختلف
4. ✅ آشنایی با محدودیت‌های روش ساده و مزایای layered filesystem

### نکات آموخته شده:
1. **Docker Export**: فقط فایل‌های واقعی را export می‌کند نه filesystemهای مجازی
2. **Pseudo-filesystems**: `/proc`, `/sys`, `/dev` باید در runtime mount شوند
3. **Efficiency**: روش ساده برای production کارآمد نیست، Docker از layered approach استفاده می‌کند
4. **Chroot Security**: باید با دقت پیاده‌سازی شود تا امنیت حفظ شود

### بهبودهای آتی:
1. پیاده‌سازی copy-on-write filesystem
2. استفاده از OverlayFS برای layering
3. مدیریت بهتر منابع و isolation
4. افزودن قابلیت caching برای base images

### خلاصه پاسخ سوالات:
1. **`--rm` flag**: حذف خودکار کانتینر پس از اتمام
2. **تفاوت `/proc`**: pseudo-filesystem که در runtime توسط کرنل populate می‌شود
3. **دسترسی به فایل**: بله، کاملاً قابل دسترسی از طریق chroot
4. **Docker implementation**: خیر، Docker از layered filesystem استفاده می‌کند برای کارایی بهتر

---

## منابع و مراجع

1. [Docker Export Documentation](https://docs.docker.com/reference/cli/docker/container/export/)
2. [Linux /proc Filesystem](https://man7.org/linux/man-pages/man5/proc.5.html)
3. [Chroot Manual](https://man7.org/linux/man-pages/man2/chroot.2.html)
4. [Docker Storage Drivers](https://docs.docker.com/storage/storagedriver/)
5. [OverlayFS Documentation](https://www.kernel.org/doc/Documentation/filesystems/overlayfs.txt)

---

**پایان گزارش**
