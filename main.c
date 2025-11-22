#include "filesystem.h"
#include <stdio.h>
#include <string.h>
#include <fcntl.h>

void print_separator() {
    printf("\n========================================\n");
}

int main() {
    printf("🚀 Starting filesystem tests\n");
    print_separator();
    
    // 1. ایجاد دیسک
    if (fs_init("filesys.db") < 0) {
        return 1;
    }
    
    // 2. نمایش وضعیت
    int total, used, free, file_count;
    fs_get_stats(&total, &used, &free, &file_count);
    printf("💾 Space: %d KB total, %d KB used, %d KB free\n",
           total/1024, used/1024, free/1024);
    printf("📁 File count: %d\n", file_count);
    
    print_separator();
    
    // 3. ساخت و نوشتن فایل
    printf("\n🧪 Test 1: create and write file\n");
    int fd1 = fs_open("test.txt", O_CREAT | O_RDWR);
    if (fd1 >= 0) {
        const char* data = "Salam! Inja filesystem-e khodemone!";
        fs_write(fd1, 0, data, strlen(data));
        fs_close_file(fd1);
    }
    
    print_separator();
    
    // 4. خواندن فایل
    printf("\n🧪 Test 2: read file\n");
    fd1 = fs_open("test.txt", O_RDONLY);
    if (fd1 >= 0) {
        char buffer[100] = {0};
        int bytes = fs_read(fd1, 0, buffer, 100);
        printf("📖 Content: %s\n", buffer);
        printf("📏 Bytes read: %d\n", bytes);
        printf("📏 Size: %d bytes\n", fs_get_file_size(fd1));
        fs_close_file(fd1);
    }
    
    print_separator();
    
    // 5. ساخت فایل دوم
    printf("\n🧪 Test 3: multiple files\n");
    int fd2 = fs_open("data.bin", O_CREAT | O_RDWR);
    if (fd2 >= 0) {
        char data[1000];
        for (int i = 0; i < 1000; i++) data[i] = i % 256;
        fs_write(fd2, 0, data, 1000);
        fs_close_file(fd2);
    }
    
    // لیست فایل‌ها
    char files[MAX_FILES][MAX_FILENAME];
    int count = fs_list_files(files, MAX_FILES);
    printf("\n📋 File list:\n");
    for (int i = 0; i < count; i++) {
        printf("  - %s\n", files[i]);
    }
    
    print_separator();
    
    // 6. تست shrink
    printf("\n🧪 Test 4: shrink file\n");
    fd2 = fs_open("data.bin", O_RDWR);
    if (fd2 >= 0) {
        printf("Size before: %d\n", fs_get_file_size(fd2));
        fs_shrink(fd2, 500);
        printf("Size after: %d\n", fs_get_file_size(fd2));
        fs_close_file(fd2);
    }
    
    print_separator();
    
    // 7. تست delete
    printf("\n🧪 Test 5: delete file\n");
    fs_delete("data.bin");
    
    count = fs_list_files(files, MAX_FILES);
    printf("📋 List after delete:\n");
    for (int i = 0; i < count; i++) {
        printf("  - %s\n", files[i]);
    }
    
    print_separator();
    
    // 8. وضعیت نهایی
    fs_get_stats(&total, &used, &free, &file_count);
    printf("\n💾 Final status:\n");
    printf("   Total: %d KB\n", total/1024);
    printf("   Used:  %d KB\n", used/1024);
    printf("   Free:  %d KB\n", free/1024);
    printf("   Files: %d\n", file_count);
    
    print_separator();
    
    fs_close();
    printf("\n✅ All tests completed successfully!\n");
    
    return 0;
}
