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

// User and Group tables
static User user_table[MAX_USERS];
static Group group_table[MAX_GROUPS];
static int current_uid = 0;  // Current logged-in user (default: root)

// =============== توابع کمکی ===============

static int get_meta_blocks() {
    int meta_bytes = sizeof(SuperBlock) + sizeof(FileEntry) * MAX_FILES 
                   + sizeof(User) * MAX_USERS + sizeof(Group) * MAX_GROUPS;
    int meta_blocks = (meta_bytes + BLOCK_SIZE - 1) / BLOCK_SIZE;
    return meta_blocks;
}

// Initialize root user and root group
static void init_users_and_groups() {
    memset(user_table, 0, sizeof(user_table));
    memset(group_table, 0, sizeof(group_table));
    
    // Create root group (gid=0)
    group_table[0].gid = 0;
    strcpy(group_table[0].groupname, "root");
    group_table[0].is_active = 1;
    
    // Create root user (uid=0)
    user_table[0].uid = 0;
    strcpy(user_table[0].username, "root");
    user_table[0].primary_gid = 0;  // root group
    user_table[0].group_count = 0;
    for (int i = 0; i < MAX_GROUPS_PER_USER; i++) {
        user_table[0].groups[i] = -1;
    }
    user_table[0].is_active = 1;
    
    current_uid = 0;  // Start as root
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
    
    // ذخیره user table
    fwrite(user_table, sizeof(User), MAX_USERS, disk_file);
    
    // ذخیره group table
    fwrite(group_table, sizeof(Group), MAX_GROUPS, disk_file);
    
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
    
    // بارگذاری user table و group table
    fread(user_table, sizeof(User), MAX_USERS, disk_file);
    fread(group_table, sizeof(Group), MAX_GROUPS, disk_file);
    
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
        
        // مقداردهی اولیه کاربران و گروه‌ها (ایجاد root)
        init_users_and_groups();
        
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
    file_table[idx].owner_uid = current_uid;  // مالک = کاربر فعلی
    file_table[idx].group_gid = user_table[current_uid].primary_gid;  // گروه = گروه اصلی کاربر
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

int fs_useradd(const char* username) {
    if (current_uid != 0) {
        printf("❌ Permission denied: only root can add users\n");
        return -1;
    }
    
    // Check if username already exists
    for (int i = 0; i < MAX_USERS; i++) {
        if (user_table[i].is_active && strcmp(user_table[i].username, username) == 0) {
            printf("❌ User '%s' already exists\n", username);
            return -1;
        }
    }
    
    // Find empty slot
    int idx = -1;
    int new_uid = 1;  // Start from 1 (0 is root)
    for (int i = 0; i < MAX_USERS; i++) {
        if (!user_table[i].is_active) {
            if (idx == -1) idx = i;
        } else {
            if (user_table[i].uid >= new_uid) {
                new_uid = user_table[i].uid + 1;
            }
        }
    }
    
    if (idx == -1) {
        printf("❌ User table is full\n");
        return -1;
    }
    
    // Create a group with the same name as the user
    int gid = fs_groupadd(username);
    if (gid < 0) {
        printf("❌ Failed to create user group\n");
        return -1;
    }
    
    // Create user
    user_table[idx].uid = new_uid;
    strncpy(user_table[idx].username, username, MAX_USERNAME - 1);
    user_table[idx].primary_gid = gid;
    user_table[idx].group_count = 0;
    for (int i = 0; i < MAX_GROUPS_PER_USER; i++) {
        user_table[idx].groups[i] = -1;
    }
    user_table[idx].is_active = 1;
    
    save_metadata();
    printf("👤 User '%s' created (uid=%d, gid=%d)\n", username, new_uid, gid);
    return new_uid;
}

int fs_userdel(const char* username) {
    if (current_uid != 0) {
        printf("❌ Permission denied: only root can delete users\n");
        return -1;
    }
    
    if (strcmp(username, "root") == 0) {
        printf("❌ Cannot delete root user\n");
        return -1;
    }
    
    for (int i = 0; i < MAX_USERS; i++) {
        if (user_table[i].is_active && strcmp(user_table[i].username, username) == 0) {
            user_table[i].is_active = 0;
            save_metadata();
            printf("🗑️  User '%s' deleted\n", username);
            return 0;
        }
    }
    
    printf("❌ User '%s' not found\n", username);
    return -1;
}

int fs_get_uid(const char* username) {
    for (int i = 0; i < MAX_USERS; i++) {
        if (user_table[i].is_active && strcmp(user_table[i].username, username) == 0) {
            return user_table[i].uid;
        }
    }
    return -1;
}

const char* fs_get_username(int uid) {
    for (int i = 0; i < MAX_USERS; i++) {
        if (user_table[i].is_active && user_table[i].uid == uid) {
            return user_table[i].username;
        }
    }
    return NULL;
}

int fs_user_exists(const char* username) {
    return fs_get_uid(username) >= 0;
}

void fs_list_users() {
    printf("\n👥 Users:\n");
    printf("──────────────────────────────────\n");
    printf("%-8s %-20s %-8s\n", "UID", "Username", "GID");
    printf("──────────────────────────────────\n");
    
    for (int i = 0; i < MAX_USERS; i++) {
        if (user_table[i].is_active) {
            printf("%-8d %-20s %-8d\n", 
                   user_table[i].uid, 
                   user_table[i].username,
                   user_table[i].primary_gid);
        }
    }
    printf("──────────────────────────────────\n");
}

int fs_groupadd(const char* groupname) {
    if (current_uid != 0) {
        printf("❌ Permission denied: only root can add groups\n");
        return -1;
    }
    
    // Check if group already exists
    for (int i = 0; i < MAX_GROUPS; i++) {
        if (group_table[i].is_active && strcmp(group_table[i].groupname, groupname) == 0) {
            printf("❌ Group '%s' already exists\n", groupname);
            return -1;
        }
    }
    
    // Find empty slot
    int idx = -1;
    int new_gid = 1;  // Start from 1 (0 is root)
    for (int i = 0; i < MAX_GROUPS; i++) {
        if (!group_table[i].is_active) {
            if (idx == -1) idx = i;
        } else {
            if (group_table[i].gid >= new_gid) {
                new_gid = group_table[i].gid + 1;
            }
        }
    }
    
    if (idx == -1) {
        printf("❌ Group table is full\n");
        return -1;
    }
    
    // Create group
    group_table[idx].gid = new_gid;
    strncpy(group_table[idx].groupname, groupname, MAX_GROUPNAME - 1);
    group_table[idx].is_active = 1;
    
    save_metadata();
    printf("👥 Group '%s' created (gid=%d)\n", groupname, new_gid);
    return new_gid;
}

int fs_groupdel(const char* groupname) {
    if (current_uid != 0) {
        printf("❌ Permission denied: only root can delete groups\n");
        return -1;
    }
    
    if (strcmp(groupname, "root") == 0) {
        printf("❌ Cannot delete root group\n");
        return -1;
    }
    
    for (int i = 0; i < MAX_GROUPS; i++) {
        if (group_table[i].is_active && strcmp(group_table[i].groupname, groupname) == 0) {
            group_table[i].is_active = 0;
            save_metadata();
            printf("🗑️  Group '%s' deleted\n", groupname);
            return 0;
        }
    }
    
    printf("❌ Group '%s' not found\n", groupname);
    return -1;
}

int fs_get_gid(const char* groupname) {
    for (int i = 0; i < MAX_GROUPS; i++) {
        if (group_table[i].is_active && strcmp(group_table[i].groupname, groupname) == 0) {
            return group_table[i].gid;
        }
    }
    return -1;
}

const char* fs_get_groupname(int gid) {
    for (int i = 0; i < MAX_GROUPS; i++) {
        if (group_table[i].is_active && group_table[i].gid == gid) {
            return group_table[i].groupname;
        }
    }
    return NULL;
}

int fs_group_exists(const char* groupname) {
    return fs_get_gid(groupname) >= 0;
}

void fs_list_groups() {
    printf("\n👥 Groups:\n");
    printf("──────────────────────────────────\n");
    printf("%-8s %-20s\n", "GID", "Groupname");
    printf("──────────────────────────────────\n");
    
    for (int i = 0; i < MAX_GROUPS; i++) {
        if (group_table[i].is_active) {
            printf("%-8d %-20s\n", 
                   group_table[i].gid, 
                   group_table[i].groupname);
        }
    }
    printf("──────────────────────────────────\n");
}

int fs_usermod_add_group(const char* username, const char* groupname) {
    if (current_uid != 0) {
        printf("❌ Permission denied: only root can modify users\n");
        return -1;
    }
    
    int gid = fs_get_gid(groupname);
    if (gid < 0) {
        printf("❌ Group '%s' not found\n", groupname);
        return -1;
    }
    
    // Find user
    for (int i = 0; i < MAX_USERS; i++) {
        if (user_table[i].is_active && strcmp(user_table[i].username, username) == 0) {
            // Check if already in group
            for (int j = 0; j < user_table[i].group_count; j++) {
                if (user_table[i].groups[j] == gid) {
                    printf("⚠️  User '%s' is already in group '%s'\n", username, groupname);
                    return 0;
                }
            }
            
            // Check if already primary group
            if (user_table[i].primary_gid == gid) {
                printf("⚠️  '%s' is already the primary group of '%s'\n", groupname, username);
                return 0;
            }
            
            // Add to groups
            if (user_table[i].group_count >= MAX_GROUPS_PER_USER) {
                printf("❌ User '%s' is already in maximum number of groups\n", username);
                return -1;
            }
            
            user_table[i].groups[user_table[i].group_count] = gid;
            user_table[i].group_count++;
            
            save_metadata();
            printf("✅ User '%s' added to group '%s'\n", username, groupname);
            return 0;
        }
    }
    
    printf("❌ User '%s' not found\n", username);
    return -1;
}

int fs_user_in_group(int uid, int gid) {
    for (int i = 0; i < MAX_USERS; i++) {
        if (user_table[i].is_active && user_table[i].uid == uid) {
            // Check primary group
            if (user_table[i].primary_gid == gid) return 1;
            
            // Check secondary groups
            for (int j = 0; j < user_table[i].group_count; j++) {
                if (user_table[i].groups[j] == gid) return 1;
            }
            return 0;
        }
    }
    return 0;
}

void fs_set_current_user(int uid) {
    current_uid = uid;
}

int fs_get_current_user() {
    return current_uid;
}

void fs_switch_user(const char* username) {
    int uid = fs_get_uid(username);
    if (uid < 0) {
        printf("❌ User '%s' not found\n", username);
        return;
    }
    current_uid = uid;
    printf("🔄 Switched to user '%s' (uid=%d)\n", username, uid);
}

static int find_file_index(const char* path) {
    for (int i = 0; i < MAX_FILES; i++) {
        if (file_table[i].is_used && strcmp(file_table[i].name, path) == 0) {
            return i;
        }
    }
    return -1;
}

int fs_chmod(const char* path, uint32_t mode) {
    int idx = find_file_index(path);
    if (idx < 0) {
        printf("❌ File '%s' not found\n", path);
        return -1;
    }
    
    // Only owner or root can chmod
    if (current_uid != 0 && file_table[idx].owner_uid != current_uid) {
        printf("❌ Permission denied: you are not the owner\n");
        return -1;
    }
    
    file_table[idx].permissions = mode;
    save_metadata();
    printf("✅ Permissions of '%s' changed to %03o\n", path, mode);
    return 0;
}

int fs_chown(const char* path, const char* username) {
    if (current_uid != 0) {
        printf("❌ Permission denied: only root can change owner\n");
        return -1;
    }
    
    int idx = find_file_index(path);
    if (idx < 0) {
        printf("❌ File '%s' not found\n", path);
        return -1;
    }
    
    int new_uid = fs_get_uid(username);
    if (new_uid < 0) {
        printf("❌ User '%s' not found\n", username);
        return -1;
    }
    
    file_table[idx].owner_uid = new_uid;
    save_metadata();
    printf("✅ Owner of '%s' changed to '%s'\n", path, username);
    return 0;
}

int fs_chgrp(const char* path, const char* groupname) {
    int idx = find_file_index(path);
    if (idx < 0) {
        printf("❌ File '%s' not found\n", path);
        return -1;
    }
    
    // Only owner or root can chgrp
    if (current_uid != 0 && file_table[idx].owner_uid != current_uid) {
        printf("❌ Permission denied: you are not the owner\n");
        return -1;
    }
    
    int new_gid = fs_get_gid(groupname);
    if (new_gid < 0) {
        printf("❌ Group '%s' not found\n", groupname);
        return -1;
    }
    
    file_table[idx].group_gid = new_gid;
    save_metadata();
    printf("✅ Group of '%s' changed to '%s'\n", path, groupname);
    return 0;
}

static void permission_to_string(uint32_t perm, char* str) {
    str[0] = (perm & PERM_READ) ? 'r' : '-';
    str[1] = (perm & PERM_WRITE) ? 'w' : '-';
    str[2] = (perm & PERM_EXEC) ? 'x' : '-';
    str[3] = '\0';
}

void fs_getfacl(const char* path) {
    int idx = find_file_index(path);
    if (idx < 0) {
        printf("❌ File '%s' not found\n", path);
        return;
    }
    
    FileEntry* file = &file_table[idx];
    uint32_t perm = file->permissions;
    
    char owner_perm[4], group_perm[4], other_perm[4];
    permission_to_string((perm >> 6) & 0x7, owner_perm);
    permission_to_string((perm >> 3) & 0x7, group_perm);
    permission_to_string(perm & 0x7, other_perm);
    
    const char* owner_name = fs_get_username(file->owner_uid);
    const char* group_name = fs_get_groupname(file->group_gid);
    
    printf("\n📋 Access Control List for '%s':\n", path);
    printf("──────────────────────────────────\n");
    printf("  File:    %s\n", path);
    printf("  Owner:   %s (uid=%d)\n", owner_name ? owner_name : "unknown", file->owner_uid);
    printf("  Group:   %s (gid=%d)\n", group_name ? group_name : "unknown", file->group_gid);
    printf("  Mode:    %03o\n", perm);
    printf("──────────────────────────────────\n");
    printf("  user::%s\n", owner_perm);
    printf("  group::%s\n", group_perm);
    printf("  other::%s\n", other_perm);
    printf("──────────────────────────────────\n");
}

int fs_check_permission(const char* path, int required_perm) {
    int idx = find_file_index(path);
    if (idx < 0) {
        return 0;  // File not found
    }
    
    // Root has all permissions
    if (current_uid == 0) {
        return 1;
    }
    
    FileEntry* file = &file_table[idx];
    uint32_t perm = file->permissions;
    
    int effective_perm;
    
    // Check if current user is owner
    if (file->owner_uid == current_uid) {
        effective_perm = (perm >> 6) & 0x7;
    }
    // Check if current user is in file's group
    else if (fs_user_in_group(current_uid, file->group_gid)) {
        effective_perm = (perm >> 3) & 0x7;
    }
    // Others
    else {
        effective_perm = perm & 0x7;
    }
    
    return (effective_perm & required_perm) == required_perm;
}
