#include "filesystem.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>

#define MAX_COMMAND_LEN 256
#define MAX_ARGS 10

// متغیرهای سراسری برای فایل باز شده
static int current_fd = -1;
static char current_filename[MAX_FILENAME] = "";

// =============== توابع کمکی ===============

void print_help() {
    printf("\n📚 Available commands:\n");
    printf("\n📁 File Operations:\n");
    printf("  create <filename> [permissions]  - create a new file (example: create test.txt 644)\n");
    printf("  open <filename> [flags]          - open a file (flags: r/w/rw/c)\n");
    printf("  read [pos] [bytes]               - read from the opened file\n");
    printf("  write <pos> <text>               - write to the opened file\n");
    printf("  shrink <new_size>                - shrink the opened file\n");
    printf("  size                             - show size of the opened file\n");
    printf("  close                            - close the opened file\n");
    printf("  rm <filename>                    - delete a file\n");
    printf("  ls                               - list files\n");
    printf("  stat                             - show filesystem stats\n");
    printf("  viz                              - visualize free space regions\n");
    printf("  format                           - format the disk\n");
    printf("\n👥 User Management (root only):\n");
    printf("  useradd <username>               - create a new user\n");
    printf("  userdel <username>               - delete a user\n");
    printf("  users                            - list all users\n");
    printf("  groupadd <groupname>             - create a new group\n");
    printf("  groupdel <groupname>             - delete a group\n");
    printf("  groups                           - list all groups\n");
    printf("  usermod -aG <user> <group>       - add user to group\n");
    printf("\n🔐 Permissions:\n");
    printf("  chmod <mode> <file>              - change file permissions (e.g., chmod 755 test.txt)\n");
    printf("  chown <user>:<group> <file>      - change file owner and group\n");
    printf("  chgrp <group> <file>             - change file group\n");
    printf("  getfacl <file>                   - show file access control list\n");
    printf("\n🔄 User Session:\n");
    printf("  su <username>                    - switch user\n");
    printf("  whoami                           - show current user\n");
    printf("\n⚙️  System:\n");
    printf("  help                             - show this help\n");
    printf("  exit                             - exit\n\n");
}

void print_prompt() {
    const char* username = fs_get_username(fs_get_current_user());
    if (!username) username = "?";
    
    if (current_fd >= 0) {
        printf("myfs:%s [%s]> ", username, current_filename);
    } else {
        printf("myfs:%s> ", username);
    }
    fflush(stdout);
}

int parse_command(char* input, char* cmd, char args[][MAX_COMMAND_LEN]) {
    char* token;
    int arg_count = 0;
    
    // حذف newline
    input[strcspn(input, "\n")] = 0;
    
    // اولین کلمه = دستور
    token = strtok(input, " ");
    if (!token) return -1;
    
    strcpy(cmd, token);
    
    // بقیه = آرگومان‌ها
    while ((token = strtok(NULL, " ")) != NULL && arg_count < MAX_ARGS) {
        strcpy(args[arg_count], token);
        arg_count++;
    }
    
    return arg_count;
}

unsigned int parse_permissions(const char* perm_str) {
    if (strlen(perm_str) == 3) {
        // فرمت عددی: 644
        return strtol(perm_str, NULL, 8);
    }
    return 0644;  // پیش‌فرض
}

int parse_open_flags(const char* flag_str) {
    if (!flag_str) return O_RDONLY;
    
    if (strcmp(flag_str, "r") == 0) return O_RDONLY;
    if (strcmp(flag_str, "w") == 0) return O_WRONLY;
    if (strcmp(flag_str, "rw") == 0) return O_RDWR;
    if (strcmp(flag_str, "c") == 0) return O_CREAT | O_RDWR;
    
    return O_RDONLY;
}

// =============== دستورات CLI ===============

void cmd_create(int argc, char args[][MAX_COMMAND_LEN]) {
    if (argc < 1) {
        printf("❌ Usage: create <filename> [permissions]\n");
        return;
    }
    
    unsigned int perms = 0644;
    if (argc >= 2) {
        perms = parse_permissions(args[1]);
    }
    
    if (fs_create(args[0], perms) >= 0) {
        printf("✅ File %s created successfully\n", args[0]);
    }
}

void cmd_open(int argc, char args[][MAX_COMMAND_LEN]) {
    if (argc < 1) {
        printf("❌ Usage: open <filename> [flags]\n");
        printf("   flags: r=read only, w=write only, rw=read+write, c=create+read+write\n");
        return;
    }
    
    if (current_fd >= 0) {
        printf("⚠️  File %s is already open. Close it first (close)\n", current_filename);
        return;
    }
    
    int flags = O_RDONLY;
    if (argc >= 2) {
        flags = parse_open_flags(args[1]);
    }
    
    // Check read permission for existing files
    if (!(flags & O_CREAT)) {
        int required_perm = PERM_READ;
        if (flags & O_WRONLY || flags & O_RDWR) {
            required_perm |= PERM_WRITE;
        }
        if (!fs_check_permission(args[0], required_perm)) {
            printf("❌ Permission denied\n");
            return;
        }
    }
    
    current_fd = fs_open(args[0], flags);
    if (current_fd >= 0) {
        strncpy(current_filename, args[0], MAX_FILENAME - 1);
        printf("✅ File %s opened (fd=%d)\n", args[0], current_fd);
    }
}

void cmd_read(int argc, char args[][MAX_COMMAND_LEN]) {
    if (current_fd < 0) {
        printf("❌ No file is open. Use open first\n");
        return;
    }
    
    // Check read permission
    if (!fs_check_permission(current_filename, PERM_READ)) {
        printf("❌ Permission denied: no read access\n");
        return;
    }
    
    int pos = 0;
    int bytes = 1024;
    
    if (argc >= 1) pos = atoi(args[0]);
    if (argc >= 2) bytes = atoi(args[1]);
    
    char* buffer = (char*)malloc(bytes + 1);
    if (!buffer) {
        printf("❌ Memory allocation failed\n");
        return;
    }
    
    int read_bytes = fs_read(current_fd, pos, buffer, bytes);
    if (read_bytes > 0) {
        buffer[read_bytes] = '\0';
        printf("\n📖 Content (%d bytes):\n", read_bytes);
        printf("─────────────────────────────────\n");
        printf("%s\n", buffer);
        printf("─────────────────────────────────\n");
    } else if (read_bytes == 0) {
        printf("⚠️  File is empty or reached end of file\n");
    }
    
    free(buffer);
}

void cmd_write(int argc, char args[][MAX_COMMAND_LEN]) {
    if (current_fd < 0) {
        printf("❌ No file is open. Use open first\n");
        return;
    }
    
    // Check write permission
    if (!fs_check_permission(current_filename, PERM_WRITE)) {
        printf("❌ Permission denied: no write access\n");
        return;
    }
    
    if (argc < 2) {
        printf("❌ Usage: write <pos> <text>\n");
        printf("   Example: write 0 \"Hello World\"\n");
        return;
    }
    
    int pos = atoi(args[0]);
    
    // ترکیب تمام آرگومان‌های بعدی به عنوان متن
    char text[MAX_COMMAND_LEN * MAX_ARGS] = "";
    for (int i = 1; i < argc; i++) {
        strcat(text, args[i]);
        if (i < argc - 1) strcat(text, " ");
    }
    
    int written = fs_write(current_fd, pos, text, strlen(text));
    if (written > 0) {
        printf("✅ %d bytes written\n", written);
    }
}

void cmd_shrink(int argc, char args[][MAX_COMMAND_LEN]) {
    if (current_fd < 0) {
        printf("❌ No file is open\n");
        return;
    }
    
    if (argc < 1) {
        printf("❌ Usage: shrink <new_size>\n");
        return;
    }
    
    int new_size = atoi(args[0]);
    if (fs_shrink(current_fd, new_size) == 0) {
        printf("✅ File shrunk to %d bytes\n", new_size);
    }
}

void cmd_size() {
    if (current_fd < 0) {
        printf("❌ No file is open\n");
        return;
    }
    
    int size = fs_get_file_size(current_fd);
    printf("📏 File size: %d bytes (%.2f KB)\n", size, size / 1024.0);
}

void cmd_close() {
    if (current_fd < 0) {
        printf("⚠️  No file is open\n");
        return;
    }
    
    fs_close_file(current_fd);
    printf("✅ File %s closed\n", current_filename);
    current_fd = -1;
    current_filename[0] = '\0';
}

void cmd_rm(int argc, char args[][MAX_COMMAND_LEN]) {
    if (argc < 1) {
        printf("❌ Usage: rm <filename>\n");
        return;
    }
    
    if (current_fd >= 0 && strcmp(current_filename, args[0]) == 0) {
        printf("⚠️  File is open. Close it first\n");
        return;
    }
    
    // Check write permission (needed to delete)
    if (!fs_check_permission(args[0], PERM_WRITE)) {
        printf("❌ Permission denied: no write access\n");
        return;
    }
    
    if (fs_delete(args[0]) == 0) {
        printf("✅ File %s deleted\n", args[0]);
    }
}

void cmd_ls() {
    char files[MAX_FILES][MAX_FILENAME];
    int count = fs_list_files(files, MAX_FILES);
    
    if (count == 0) {
        printf("📁 No files found\n");
        return;
    }
    
    printf("\n📋 Files (%d):\n", count);
    printf("─────────────────────────────────\n");
    for (int i = 0; i < count; i++) {
        printf("  %2d. %s", i + 1, files[i]);
        
        // اگر فایل باز است
        if (current_fd >= 0 && strcmp(files[i], current_filename) == 0) {
            printf(" [open]");
        }
        printf("\n");
    }
    printf("─────────────────────────────────\n");
}

void cmd_stat() {
    int total, used, free_space, file_count;
    fs_get_stats(&total, &used, &free_space, &file_count);
    
    printf("\n💾 Filesystem status:\n");
    printf("─────────────────────────────────\n");
    printf("  Total space:   %8d KB (%d MB)\n", total / 1024, total / (1024 * 1024));
    printf("  Used:          %8d KB (%.1f%%)\n", used / 1024, (used * 100.0) / total);
    printf("  Free:          %8d KB (%.1f%%)\n", free_space / 1024, (free_space * 100.0) / total);
    printf("  File count:    %8d\n", file_count);
    printf("─────────────────────────────────\n");
}

void cmd_format() {
    printf("⚠️  Are you sure? All data will be erased! (yes/no): ");
    char confirm[10];
    scanf("%s", confirm);
    getchar(); // خوردن newline
    
    if (strcmp(confirm, "yes") == 0) {
        if (current_fd >= 0) {
            fs_close_file(current_fd);
            current_fd = -1;
            current_filename[0] = '\0';
        }
        fs_format();
        printf("✅ Disk formatted\n");
    } else {
        printf("❌ Operation canceled\n");
    }
}

// =============== دستورات مدیریت کاربران ===============

void cmd_useradd(int argc, char args[][MAX_COMMAND_LEN]) {
    if (argc < 1) {
        printf("❌ Usage: useradd <username>\n");
        return;
    }
    fs_useradd(args[0]);
}

void cmd_userdel(int argc, char args[][MAX_COMMAND_LEN]) {
    if (argc < 1) {
        printf("❌ Usage: userdel <username>\n");
        return;
    }
    fs_userdel(args[0]);
}

void cmd_groupadd(int argc, char args[][MAX_COMMAND_LEN]) {
    if (argc < 1) {
        printf("❌ Usage: groupadd <groupname>\n");
        return;
    }
    fs_groupadd(args[0]);
}

void cmd_groupdel(int argc, char args[][MAX_COMMAND_LEN]) {
    if (argc < 1) {
        printf("❌ Usage: groupdel <groupname>\n");
        return;
    }
    fs_groupdel(args[0]);
}

void cmd_usermod(int argc, char args[][MAX_COMMAND_LEN]) {
    if (argc < 3 || strcmp(args[0], "-aG") != 0) {
        printf("❌ Usage: usermod -aG <user> <group>\n");
        return;
    }
    fs_usermod_add_group(args[1], args[2]);
}

void cmd_su(int argc, char args[][MAX_COMMAND_LEN]) {
    if (argc < 1) {
        printf("❌ Usage: su <username>\n");
        return;
    }
    fs_switch_user(args[0]);
}

void cmd_whoami() {
    int uid = fs_get_current_user();
    const char* username = fs_get_username(uid);
    printf("👤 %s (uid=%d)\n", username ? username : "unknown", uid);
}

// =============== دستورات سطح دسترسی ===============

void cmd_chmod(int argc, char args[][MAX_COMMAND_LEN]) {
    if (argc < 2) {
        printf("❌ Usage: chmod <mode> <file>\n");
        printf("   Example: chmod 755 test.txt\n");
        return;
    }
    
    uint32_t mode = strtol(args[0], NULL, 8);
    fs_chmod(args[1], mode);
}

void cmd_chown(int argc, char args[][MAX_COMMAND_LEN]) {
    if (argc < 2) {
        printf("❌ Usage: chown <user>:<group> <file>\n");
        printf("   Example: chown alice:staff test.txt\n");
        return;
    }
    
    char* colon = strchr(args[0], ':');
    if (colon) {
        *colon = '\0';
        char* user = args[0];
        char* group = colon + 1;
        
        if (strlen(user) > 0) {
            fs_chown(args[1], user);
        }
        if (strlen(group) > 0) {
            fs_chgrp(args[1], group);
        }
    } else {
        fs_chown(args[1], args[0]);
    }
}

void cmd_chgrp(int argc, char args[][MAX_COMMAND_LEN]) {
    if (argc < 2) {
        printf("❌ Usage: chgrp <group> <file>\n");
        return;
    }
    fs_chgrp(args[1], args[0]);
}

void cmd_getfacl(int argc, char args[][MAX_COMMAND_LEN]) {
    if (argc < 1) {
        printf("❌ Usage: getfacl <file>\n");
        return;
    }
    fs_getfacl(args[0]);
}

// =============== حلقه اصلی ===============

void run_shell() {
    char input[MAX_COMMAND_LEN];
    char cmd[50];
    char args[MAX_ARGS][MAX_COMMAND_LEN];
    
    printf("\n╔═══════════════════════════════════════╗\n");
    printf("║   🎉 Welcome to MyFileSystem 🎉       ║\n");
    printf("╚═══════════════════════════════════════╝\n");
    printf("Type 'help' for commands\n");
    
    while (1) {
        print_prompt();
        
        if (!fgets(input, MAX_COMMAND_LEN, stdin)) {
            break;
        }
        
        int argc = parse_command(input, cmd, args);
        if (argc < 0 || strlen(cmd) == 0) continue;
        
        // پردازش دستورات
        if (strcmp(cmd, "exit") == 0 || strcmp(cmd, "quit") == 0) {
            printf("👋 Goodbye!\n");
            break;
        }
        else if (strcmp(cmd, "help") == 0) {
            print_help();
        }
        else if (strcmp(cmd, "create") == 0) {
            cmd_create(argc, args);
        }
        else if (strcmp(cmd, "open") == 0) {
            cmd_open(argc, args);
        }
        else if (strcmp(cmd, "read") == 0) {
            cmd_read(argc, args);
        }
        else if (strcmp(cmd, "write") == 0) {
            cmd_write(argc, args);
        }
        else if (strcmp(cmd, "shrink") == 0) {
            cmd_shrink(argc, args);
        }
        else if (strcmp(cmd, "size") == 0) {
            cmd_size();
        }
        else if (strcmp(cmd, "close") == 0) {
            cmd_close();
        }
        else if (strcmp(cmd, "rm") == 0) {
            cmd_rm(argc, args);
        }
        else if (strcmp(cmd, "ls") == 0) {
            cmd_ls();
        }
        else if (strcmp(cmd, "stat") == 0) {
            cmd_stat();
        }
        else if (strcmp(cmd, "viz") == 0) {
            fs_visualize_free_list();
        }
        else if (strcmp(cmd, "format") == 0) {
            cmd_format();
        }
        else if (strcmp(cmd, "clear") == 0) {
            system("clear || cls");
        }
        // User management commands
        else if (strcmp(cmd, "useradd") == 0) {
            cmd_useradd(argc, args);
        }
        else if (strcmp(cmd, "userdel") == 0) {
            cmd_userdel(argc, args);
        }
        else if (strcmp(cmd, "users") == 0) {
            fs_list_users();
        }
        else if (strcmp(cmd, "groupadd") == 0) {
            cmd_groupadd(argc, args);
        }
        else if (strcmp(cmd, "groupdel") == 0) {
            cmd_groupdel(argc, args);
        }
        else if (strcmp(cmd, "groups") == 0) {
            fs_list_groups();
        }
        else if (strcmp(cmd, "usermod") == 0) {
            cmd_usermod(argc, args);
        }
        else if (strcmp(cmd, "su") == 0) {
            cmd_su(argc, args);
        }
        else if (strcmp(cmd, "whoami") == 0) {
            cmd_whoami();
        }
        // Permission commands
        else if (strcmp(cmd, "chmod") == 0) {
            cmd_chmod(argc, args);
        }
        else if (strcmp(cmd, "chown") == 0) {
            cmd_chown(argc, args);
        }
        else if (strcmp(cmd, "chgrp") == 0) {
            cmd_chgrp(argc, args);
        }
        else if (strcmp(cmd, "getfacl") == 0) {
            cmd_getfacl(argc, args);
        }
        else {
            printf("❌ Command '%s' not recognized. Type 'help' for help\n", cmd);
        }
        
        printf("\n");
    }
}

// =============== Main ===============

int main(int argc, char* argv[]) {
    const char* disk_path = "filesys.db";
    
    // اگر آرگومان داشت، از آن به عنوان مسیر دیسک استفاده کن
    if (argc > 1) {
        disk_path = argv[1];
    }
    
    printf("🔧 Loading disk: %s\n", disk_path);
    
    if (fs_init(disk_path) < 0) {
        printf("❌ Failed to initialize filesystem\n");
        return 1;
    }
    
    run_shell();
    
    // بستن فایل باز (در صورت وجود)
    if (current_fd >= 0) {
        fs_close_file(current_fd);
    }
    
    fs_close();
    printf("\n💾 Filesystem saved and closed\n");
    
    return 0;
}
