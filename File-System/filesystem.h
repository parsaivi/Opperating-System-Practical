#ifndef FILESYSTEM_H
#define FILESYSTEM_H

#include <stdint.h>
#include <time.h>

#define DISK_SIZE (10 * 1024 * 1024)  // 10MB
#define BLOCK_SIZE 512
#define MAX_FILENAME 32
#define MAX_FILES 100
#define MAX_USERS 50
#define MAX_GROUPS 50
#define MAX_USERNAME 32
#define MAX_GROUPNAME 32
#define MAX_GROUPS_PER_USER 10
#define MAGIC_NUMBER ((uint32_t)0xDEADBEEF)

// Permission bits (like Unix)
#define PERM_READ  4
#define PERM_WRITE 2
#define PERM_EXEC  1

// ساختار کاربر
typedef struct {
    int32_t uid;                        // User ID (0 = root)
    char username[MAX_USERNAME];
    int32_t primary_gid;                // Primary group ID
    int32_t groups[MAX_GROUPS_PER_USER]; // Secondary groups (-1 = empty)
    int32_t group_count;                // Number of secondary groups
    int32_t is_active;                  // 1 = active, 0 = deleted
} User;

// ساختار گروه
typedef struct {
    int32_t gid;                        // Group ID
    char groupname[MAX_GROUPNAME];
    int32_t is_active;                  // 1 = active, 0 = deleted
} Group;

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
    uint32_t permissions;  // 0644, etc (owner:group:others, 3 bits each)
    int32_t owner_uid;     // Owner user ID
    int32_t group_gid;     // Owner group ID
    time_t create_time;
    time_t modify_time;
    int32_t is_used;  // 1 = استفاده شده, 0 = پاک شده
} FileEntry;

// ساختار بلاک آزاد - با شروع و پایان بلاک
typedef struct FreeBlockNode {
    int32_t start_block;    // شروع ناحیه آزاد
    int32_t end_block;      // پایان ناحیه آزاد (شامل این بلاک)
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

// مدیریت فضای آزاد
int fs_alloc(int size);
void fs_free(int start, int size);
void fs_visualize_free_list();

// مدیریت کاربران
int fs_useradd(const char* username);
int fs_userdel(const char* username);
int fs_get_uid(const char* username);
const char* fs_get_username(int uid);
int fs_user_exists(const char* username);
void fs_list_users();

// مدیریت گروه‌ها
int fs_groupadd(const char* groupname);
int fs_groupdel(const char* groupname);
int fs_get_gid(const char* groupname);
const char* fs_get_groupname(int gid);
int fs_group_exists(const char* groupname);
void fs_list_groups();

// عضویت کاربر در گروه
int fs_usermod_add_group(const char* username, const char* groupname);
int fs_user_in_group(int uid, int gid);

// کاربر فعلی
void fs_set_current_user(int uid);
int fs_get_current_user();
void fs_switch_user(const char* username);

// سطح دسترسی فایل
int fs_chmod(const char* path, uint32_t mode);
int fs_chown(const char* path, const char* username);
int fs_chgrp(const char* path, const char* groupname);
void fs_getfacl(const char* path);

// بررسی دسترسی
int fs_check_permission(const char* path, int required_perm);

#endif
