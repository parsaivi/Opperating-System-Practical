#ifndef FILESYSTEM_H
#define FILESYSTEM_H

#include <stdint.h>
#include <time.h>

#define DISK_SIZE (10 * 1024 * 1024)  // 10MB
#define BLOCK_SIZE 512
#define MAX_FILENAME 32
#define MAX_FILES 100
#define MAGIC_NUMBER ((uint32_t)0xDEADBEEF)

// ساختار SuperBlock
typedef struct {
    uint32_t magic;
    int32_t version;
    int32_t file_count;
    int32_t total_blocks;
    int32_t used_blocks;
    int32_t first_free_block;
} SuperBlock;

// ساختار فایل
typedef struct {
    char name[MAX_FILENAME];
    int32_t size;
    int32_t start_block;
    int32_t block_count;
    uint32_t permissions;  // 0644, etc
    time_t create_time;
    time_t modify_time;
    int32_t is_used;  // 1 = استفاده شده, 0 = پاک شده
} FileEntry;

// ساختار بلاک آزاد
typedef struct FreeBlockNode {
    int32_t start_block;
    int32_t block_count;
    struct FreeBlockNode* next;
} FreeBlockNode;

// توابع اصلی
int fs_init(const char* disk_path);
void fs_close();
int fs_format();

// عملیات فایل
int fs_create(const char* name, uint32_t permissions);
int fs_open(const char* name, int flags);
int fs_read(int fd, int pos, char* buffer, int n_bytes);
int fs_write(int fd, int pos, const char* buffer, int n_bytes);
int fs_shrink(int fd, int new_size);
int fs_delete(const char* name);
void fs_close_file(int fd);

// اطلاعات
int fs_get_file_size(int fd);
void fs_get_stats(int* total, int* used, int* free, int* file_count);
int fs_list_files(char files[][MAX_FILENAME], int max_count);

#endif
