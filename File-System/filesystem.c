#include "filesystem.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>

static FILE* disk_file = NULL;
static SuperBlock super_block;
static FileEntry file_table[MAX_FILES];
static FreeBlockNode* free_list = NULL;
static int open_files[MAX_FILES];  // file descriptor table

// =============== توابع کمکی ===============

static int get_meta_blocks() {
    int meta_bytes = sizeof(SuperBlock) + sizeof(FileEntry) * MAX_FILES;
    int meta_blocks = (meta_bytes + BLOCK_SIZE - 1) / BLOCK_SIZE;
    return meta_blocks;
}

static void init_free_list() {
    int total_blocks = DISK_SIZE / BLOCK_SIZE;
    int meta_blocks = get_meta_blocks();

    free_list = (FreeBlockNode*)malloc(sizeof(FreeBlockNode));
    free_list->start_block = meta_blocks;  // blocks [0..meta_blocks-1] reserved for metadata
    free_list->end_block = total_blocks - 1;  // آخرین بلاک
    free_list->next = NULL;
}

// تعداد بلاک‌ها در یک ناحیه آزاد
static int get_block_count(FreeBlockNode* node) {
    return node->end_block - node->start_block + 1;
}

// تابع alloc جدید: تخصیص بلاک با اندازه مشخص
int fs_alloc(int size) {
    int needed_blocks = (size + BLOCK_SIZE - 1) / BLOCK_SIZE;
    if (needed_blocks == 0) needed_blocks = 1;
    
    FreeBlockNode* curr = free_list;
    FreeBlockNode* prev = NULL;
    
    while (curr) {
        int available = get_block_count(curr);
        
        if (available >= needed_blocks) {
            int allocated = curr->start_block;
            
            if (available == needed_blocks) {
                // کل ناحیه استفاده شد
                if (prev) prev->next = curr->next;
                else free_list = curr->next;
                free(curr);
            } else {
                // بخشی از ناحیه استفاده شد
                curr->start_block += needed_blocks;
            }
            
            super_block.used_blocks += needed_blocks;
            return allocated;
        }
        prev = curr;
        curr = curr->next;
    }
    
    return -1;  // فضا کافی نیست
}

// تابع کمکی برای سازگاری با کد قبلی
static int allocate_blocks(int count) {
    FreeBlockNode* curr = free_list;
    FreeBlockNode* prev = NULL;
    
    while (curr) {
        int available = get_block_count(curr);
        
        if (available >= count) {
            int allocated = curr->start_block;
            
            if (available == count) {
                if (prev) prev->next = curr->next;
                else free_list = curr->next;
                free(curr);
            } else {
                curr->start_block += count;
            }
            
            super_block.used_blocks += count;
            return allocated;
        }
        prev = curr;
        curr = curr->next;
    }
    
    return -1;
}

// تابع free جدید با ادغام بلاک‌های مجاور
void fs_free(int start, int size) {
    int block_count = (size + BLOCK_SIZE - 1) / BLOCK_SIZE;
    if (block_count == 0) block_count = 1;
    
    int end = start + block_count - 1;
    
    // پیدا کردن جای مناسب در لیست (مرتب بر اساس start_block)
    FreeBlockNode* curr = free_list;
    FreeBlockNode* prev = NULL;
    
    // یافتن موقعیت درست برای درج (لیست مرتب)
    while (curr && curr->start_block < start) {
        prev = curr;
        curr = curr->next;
    }
    
    // بررسی ادغام با بلاک قبلی
    int merged_with_prev = 0;
    if (prev && prev->end_block + 1 == start) {
        // ادغام با بلاک قبلی
        prev->end_block = end;
        merged_with_prev = 1;
    }
    
    // بررسی ادغام با بلاک بعدی
    if (curr && end + 1 == curr->start_block) {
        if (merged_with_prev) {
            // ادغام سه‌گانه: قبلی + جدید + بعدی
            prev->end_block = curr->end_block;
            prev->next = curr->next;
            free(curr);
        } else {
            // فقط ادغام با بلاک بعدی
            curr->start_block = start;
        }
    } else if (!merged_with_prev) {
        // نیاز به ایجاد گره جدید
        FreeBlockNode* new_node = (FreeBlockNode*)malloc(sizeof(FreeBlockNode));
        new_node->start_block = start;
        new_node->end_block = end;
        new_node->next = curr;
        
        if (prev) {
            prev->next = new_node;
        } else {
            free_list = new_node;
        }
    }
    
    super_block.used_blocks -= block_count;
}

// تابع کمکی برای سازگاری با کد قبلی
static void free_blocks(int start, int count) {
    int end = start + count - 1;
    
    FreeBlockNode* curr = free_list;
    FreeBlockNode* prev = NULL;
    
    while (curr && curr->start_block < start) {
        prev = curr;
        curr = curr->next;
    }
    
    int merged_with_prev = 0;
    if (prev && prev->end_block + 1 == start) {
        prev->end_block = end;
        merged_with_prev = 1;
    }
    
    if (curr && end + 1 == curr->start_block) {
        if (merged_with_prev) {
            prev->end_block = curr->end_block;
            prev->next = curr->next;
            free(curr);
        } else {
            curr->start_block = start;
        }
    } else if (!merged_with_prev) {
        FreeBlockNode* new_node = (FreeBlockNode*)malloc(sizeof(FreeBlockNode));
        new_node->start_block = start;
        new_node->end_block = end;
        new_node->next = curr;
        
        if (prev) {
            prev->next = new_node;
        } else {
            free_list = new_node;
        }
    }
    
    super_block.used_blocks -= count;
}

static void save_metadata() {
    fseek(disk_file, 0, SEEK_SET);
    fwrite(&super_block, sizeof(SuperBlock), 1, disk_file);
    
    // ذخیره file table
    fwrite(file_table, sizeof(FileEntry), MAX_FILES, disk_file);
    
    fflush(disk_file);
}

// حذف یک بازه از free list
static void remove_range_from_freelist(int start, int count) {
    int end = start + count - 1;
    
    FreeBlockNode* curr = free_list;
    FreeBlockNode* prev = NULL;
    
    while (curr) {
        FreeBlockNode* next = curr->next;
        
        // بررسی همپوشانی
        if (curr->end_block >= start && curr->start_block <= end) {
            if (start <= curr->start_block && end >= curr->end_block) {
                // کل گره باید حذف شود
                if (prev) prev->next = next;
                else free_list = next;
                free(curr);
            } else if (start <= curr->start_block) {
                // بخش ابتدایی گره باید حذف شود
                curr->start_block = end + 1;
                prev = curr;
            } else if (end >= curr->end_block) {
                // بخش انتهایی گره باید حذف شود
                curr->end_block = start - 1;
                prev = curr;
            } else {
                // گره باید به دو بخش تقسیم شود
                FreeBlockNode* new_node = (FreeBlockNode*)malloc(sizeof(FreeBlockNode));
                new_node->start_block = end + 1;
                new_node->end_block = curr->end_block;
                new_node->next = next;
                
                curr->end_block = start - 1;
                curr->next = new_node;
                prev = new_node;
            }
        } else {
            prev = curr;
        }
        curr = next;
    }
}

static void load_metadata() {
    fseek(disk_file, 0, SEEK_SET);
    fread(&super_block, sizeof(SuperBlock), 1, disk_file);
    fread(file_table, sizeof(FileEntry), MAX_FILES, disk_file);
    
    // بازسازی free list از روی تعداد بلاک‌ها
    init_free_list();

    // بازسازی used_blocks: متادیتا + بلاک‌های فایل‌ها
    super_block.used_blocks = get_meta_blocks();
    
    for (int i = 0; i < MAX_FILES; i++) {
        if (file_table[i].is_used && file_table[i].start_block != -1 && file_table[i].block_count > 0) {
            super_block.used_blocks += file_table[i].block_count;
            
            // حذف بلاک‌های استفاده شده از free list
            remove_range_from_freelist(file_table[i].start_block, file_table[i].block_count);
        }
    }
}

// =============== توابع اصلی ===============

int fs_init(const char* disk_path) {
    disk_file = fopen(disk_path, "r+b");
    
    if (!disk_file) {
        // فرمت جدید
        disk_file = fopen(disk_path, "w+b");
        if (!disk_file) {
            perror("Error creating disk");
            return -1;
        }
        
        // پر کردن با صفر
        char zero[BLOCK_SIZE] = {0};
        for (int i = 0; i < DISK_SIZE / BLOCK_SIZE; i++) {
            fwrite(zero, BLOCK_SIZE, 1, disk_file);
        }
        
        // مقداردهی superblock
        super_block.magic = MAGIC_NUMBER;
        super_block.version = 1;
        super_block.file_count = 0;
        super_block.total_blocks = DISK_SIZE / BLOCK_SIZE;
        super_block.used_blocks = get_meta_blocks();  // all metadata blocks are considered used
        
        // مقداردهی file table
        memset(file_table, 0, sizeof(file_table));
        
        init_free_list();
        save_metadata();
        
        printf("✅ New disk formatted (%d blocks)\n", super_block.total_blocks);
    } else {
        // بارگذاری دیسک موجود
        load_metadata();
        
        if (super_block.magic != MAGIC_NUMBER) {
            printf("❌ Disk file is not valid!\n");
            fclose(disk_file);
            return -1;
        }
        
        printf("✅ Disk loaded (version %d, %d files)\n", 
               super_block.version, super_block.file_count);
    }
    
    // مقداردهی open_files
    for (int i = 0; i < MAX_FILES; i++) {
        open_files[i] = -1;
    }
    
    return 0;
}

void fs_close() {
    if (disk_file) {
        save_metadata();
        fclose(disk_file);
        disk_file = NULL;
    }
    
    // آزاد کردن free list
    while (free_list) {
        FreeBlockNode* temp = free_list;
        free_list = free_list->next;
        free(temp);
    }
}

int fs_format() {
    memset(file_table, 0, sizeof(file_table));
    super_block.file_count = 0;
    super_block.used_blocks = get_meta_blocks();
    
    // بازسازی free list
    while (free_list) {
        FreeBlockNode* temp = free_list;
        free_list = free_list->next;
        free(temp);
    }
    init_free_list();
    
    save_metadata();
    printf("🔄 Disk formatted\n");
    return 0;
}

int fs_create(const char* name, uint32_t permissions) {
    // چک کردن وجود فایل
    for (int i = 0; i < MAX_FILES; i++) {
        if (file_table[i].is_used && strcmp(file_table[i].name, name) == 0) {
            printf("❌ File %s already exists\n", name);
            return -1;
        }
    }
    
    // پیدا کردن جای خالی
    int idx = -1;
    for (int i = 0; i < MAX_FILES; i++) {
        if (!file_table[i].is_used) {
            idx = i;
            break;
        }
    }
    
    if (idx == -1) {
        printf("❌ File table is full\n");
        return -1;
    }
    
    // ساخت فایل
    strncpy(file_table[idx].name, name, MAX_FILENAME - 1);
    file_table[idx].size = 0;
    file_table[idx].start_block = -1;
    file_table[idx].block_count = 0;
    file_table[idx].permissions = permissions;
    file_table[idx].create_time = time(NULL);
    file_table[idx].modify_time = time(NULL);
    file_table[idx].is_used = 1;
    
    super_block.file_count++;
    save_metadata();
    
    printf("📄 File %s created\n", name);
    return idx;
}

int fs_open(const char* name, int flags) {
    int idx = -1;
    
    // پیدا کردن فایل
    for (int i = 0; i < MAX_FILES; i++) {
        if (file_table[i].is_used && strcmp(file_table[i].name, name) == 0) {
            idx = i;
            break;
        }
    }
    
    // اگر پیدا نشد و flag CREATE داشت
    if (idx == -1 && (flags & O_CREAT)) {
        idx = fs_create(name, 0644);
        if (idx == -1) return -1;
    }
    
    if (idx == -1) {
        printf("❌ File %s not found\n", name);
        return -1;
    }
    
    // پیدا کردن fd خالی
    int fd = -1;
    for (int i = 0; i < MAX_FILES; i++) {
        if (open_files[i] == -1) {
            open_files[i] = idx;
            fd = i;
            break;
        }
    }
    
    if (fd == -1) {
        printf("❌ Too many open files\n");
        return -1;
    }
    
    printf("📂 File %s opened (fd=%d)\n", name, fd);
    return fd;
}

int fs_read(int fd, int pos, char* buffer, int n_bytes) {
    if (fd < 0 || fd >= MAX_FILES || open_files[fd] == -1) {
        printf("❌ Invalid file descriptor\n");
        return -1;
    }
    
    int idx = open_files[fd];
    FileEntry* file = &file_table[idx];
    
    if (pos >= file->size) {
        return 0;  // EOF
    }
    
    // محدود کردن به سایز فایل
    if (pos + n_bytes > file->size) {
        n_bytes = file->size - pos;
    }
    
    if (file->start_block == -1) {
        return 0;  // فایل خالی
    }
    
    // خواندن از دیسک
    int offset = file->start_block * BLOCK_SIZE + pos;
    fseek(disk_file, offset, SEEK_SET);
    int bytes_read = fread(buffer, 1, n_bytes, disk_file);
    
    printf("📖 %d bytes read from position %d\n", bytes_read, pos);
    return bytes_read;
}

int fs_write(int fd, int pos, const char* buffer, int n_bytes) {
    if (fd < 0 || fd >= MAX_FILES || open_files[fd] == -1) {
        printf("❌ Invalid file descriptor\n");
        return -1;
    }
    
    int idx = open_files[fd];
    FileEntry* file = &file_table[idx];
    
    // محاسبه بلاک‌های مورد نیاز
    int needed_size = pos + n_bytes;
    int needed_blocks = (needed_size + BLOCK_SIZE - 1) / BLOCK_SIZE;
    
    // اگر فایل بلاک نداره، اختصاص بده
    if (file->start_block == -1) {
        file->start_block = allocate_blocks(needed_blocks);
        if (file->start_block == -1) {
            printf("❌ Not enough space\n");
            return -1;
        }
        file->block_count = needed_blocks;
    } else if (needed_blocks > file->block_count) {
        // نیاز به بلاک بیشتر
        int additional = needed_blocks - file->block_count;
        int new_blocks = allocate_blocks(additional);
        
        if (new_blocks == -1) {
            printf("❌ Not enough space\n");
            return -1;
        }
        
        file->block_count = needed_blocks;
    }
    
    // نوشتن در دیسک
    int offset = file->start_block * BLOCK_SIZE + pos;
    fseek(disk_file, offset, SEEK_SET);
    int bytes_written = fwrite(buffer, 1, n_bytes, disk_file);
    fflush(disk_file);
    
    // به‌روزرسانی سایز
    if (pos + bytes_written > file->size) {
        file->size = pos + bytes_written;
    }
    
    file->modify_time = time(NULL);
    save_metadata();
    
    printf("✍️  %d bytes written at position %d\n", bytes_written, pos);
    return bytes_written;
}

int fs_shrink(int fd, int new_size) {
    if (fd < 0 || fd >= MAX_FILES || open_files[fd] == -1) {
        printf("❌ Invalid file descriptor\n");
        return -1;
    }
    
    int idx = open_files[fd];
    FileEntry* file = &file_table[idx];
    
    if (new_size >= file->size) {
        printf("⚠️  New size is greater than or equal to current size\n");
        return 0;
    }
    
    int new_blocks = (new_size + BLOCK_SIZE - 1) / BLOCK_SIZE;
    int freed_blocks = file->block_count - new_blocks;
    
    if (freed_blocks > 0) {
        free_blocks(file->start_block + new_blocks, freed_blocks);
        file->block_count = new_blocks;
    }
    
    file->size = new_size;
    file->modify_time = time(NULL);
    save_metadata();
    
    printf("✂️  File shrunk to %d bytes\n", new_size);
    return 0;
}

int fs_delete(const char* name) {
    int idx = -1;
    
    for (int i = 0; i < MAX_FILES; i++) {
        if (file_table[i].is_used && strcmp(file_table[i].name, name) == 0) {
            idx = i;
            break;
        }
    }
    
    if (idx == -1) {
        printf("❌ File %s not found\n", name);
        return -1;
    }
    
    // آزاد کردن بلاک‌ها
    if (file_table[idx].start_block != -1) {
        free_blocks(file_table[idx].start_block, file_table[idx].block_count);
    }
    
    // حذف از جدول
    file_table[idx].is_used = 0;
    super_block.file_count--;
    
    // بستن fd های مربوطه
    for (int i = 0; i < MAX_FILES; i++) {
        if (open_files[i] == idx) {
            open_files[i] = -1;
        }
    }
    
    save_metadata();
    printf("🗑️  File %s deleted\n", name);
    return 0;
}

void fs_close_file(int fd) {
    if (fd >= 0 && fd < MAX_FILES && open_files[fd] != -1) {
        printf("📪 File closed (fd=%d)\n", fd);
        open_files[fd] = -1;
    }
}

int fs_get_file_size(int fd) {
    if (fd < 0 || fd >= MAX_FILES || open_files[fd] == -1) {
        return -1;
    }
    return file_table[open_files[fd]].size;
}

void fs_get_stats(int* total, int* used, int* free, int* file_count) {
    *total = super_block.total_blocks * BLOCK_SIZE;
    *used = super_block.used_blocks * BLOCK_SIZE;
    *free = *total - *used;
    *file_count = super_block.file_count;
}

int fs_list_files(char files[][MAX_FILENAME], int max_count) {
    int count = 0;
    for (int i = 0; i < MAX_FILES && count < max_count; i++) {
        if (file_table[i].is_used) {
            strcpy(files[count], file_table[i].name);
            count++;
        }
    }
    return count;
}

// نمایش فضاهای آزاد به صورت مرتب
void fs_visualize_free_list() {
    printf("\n🗂️  Free Space Visualization:\n");
    printf("══════════════════════════════════════════════════════════════════\n");
    printf("%-8s %-10s %-10s %-12s %-12s\n", "Index", "Start", "End", "Blocks", "Size (KB)");
    printf("──────────────────────────────────────────────────────────────────\n");
    
    FreeBlockNode* curr = free_list;
    int index = 0;
    int total_free_blocks = 0;
    
    if (!curr) {
        printf("  (No free space available)\n");
    } else {
        while (curr) {
            int block_count = curr->end_block - curr->start_block + 1;
            total_free_blocks += block_count;
            
            printf("%-8d %-10d %-10d %-12d %-12.2f\n", 
                   index, 
                   curr->start_block, 
                   curr->end_block, 
                   block_count,
                   (block_count * BLOCK_SIZE) / 1024.0);
            
            index++;
            curr = curr->next;
        }
    }
    
    printf("══════════════════════════════════════════════════════════════════\n");
    printf("📊 Summary: %d regions, %d free blocks (%.2f KB / %.2f MB)\n", 
           index, 
           total_free_blocks,
           (total_free_blocks * BLOCK_SIZE) / 1024.0,
           (total_free_blocks * BLOCK_SIZE) / (1024.0 * 1024.0));
    printf("══════════════════════════════════════════════════════════════════\n");
}
