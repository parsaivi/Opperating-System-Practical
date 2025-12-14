# MyFileSystem

A simple block-based filesystem implementation in C for Operating Systems course.

## Features

- 10MB virtual disk with 512-byte blocks
- File create, read, write, shrink, and delete operations
- Free space management with block coalescing
- Interactive CLI shell
- Persistent storage (survives restarts)
- **User and Group management** with root user
- **Unix-style permissions** (owner/group/others)
- **Access control** with chmod, chown, chgrp, getfacl

## Build & Run

```bash
make          # Build the project
make run      # Build and launch the CLI shell
make clean    # Remove build artifacts
```

## CLI Commands

### File Operations

| Command | Description |
|---------|-------------|
| `create <file> [perms]` | Create a new file (e.g., `create test.txt 644`) |
| `open <file> [flags]` | Open a file (flags: `r`, `w`, `rw`, `c`) |
| `read [pos] [bytes]` | Read from opened file |
| `write <pos> <text>` | Write text to opened file |
| `shrink <size>` | Shrink opened file to new size |
| `size` | Show size of opened file |
| `close` | Close the current file |
| `rm <file>` | Delete a file |
| `ls` | List all files |
| `stat` | Show filesystem statistics |
| `viz` | Visualize free space regions |
| `format` | Format the disk (erases all data) |

### User Management (root only)

| Command | Description |
|---------|-------------|
| `useradd <username>` | Create a new user |
| `userdel <username>` | Delete a user |
| `users` | List all users |
| `groupadd <groupname>` | Create a new group |
| `groupdel <groupname>` | Delete a group |
| `groups` | List all groups |
| `usermod -aG <user> <group>` | Add user to a group |

### Permissions

| Command | Description |
|---------|-------------|
| `chmod <mode> <file>` | Change file permissions (e.g., `chmod 755 test.txt`) |
| `chown <user>:<group> <file>` | Change file owner and group |
| `chgrp <group> <file>` | Change file group |
| `getfacl <file>` | Show file access control list |

### User Session

| Command | Description |
|---------|-------------|
| `su <username>` | Switch user |
| `whoami` | Show current user |

### System

| Command | Description |
|---------|-------------|
| `help` | Show help |
| `exit` | Exit the shell |

## Project Structure

```
├── filesystem.h   # API declarations and data structures
├── filesystem.c   # Core filesystem implementation
├── cli.c          # Interactive shell (main entry point)
├── main.c         # Test suite
├── filesys.db     # Virtual disk image (generated)
└── Makefile
```

## Permission Model

Files have Unix-style permissions with three levels:
- **Owner**: The user who created the file
- **Group**: The group owner of the file
- **Others**: Everyone else

Permissions are specified in octal format (e.g., `755`):
- `7` = read (4) + write (2) + execute (1)
- `6` = read (4) + write (2)
- `5` = read (4) + execute (1)
- `4` = read only

Example:
```
myfs:root> create secret.txt 600
myfs:root> getfacl secret.txt
  File:    secret.txt
  Owner:   root (uid=0)
  Group:   root (gid=0)
  Mode:    600
  user::rw-
  group::---
  other::---
```

## API

```c
// Filesystem
int fs_init(const char* disk_path);
int fs_create(const char* name, uint32_t permissions);
int fs_open(const char* name, int flags);
int fs_read(int fd, int pos, char* buffer, int n_bytes);
int fs_write(int fd, int pos, const char* buffer, int n_bytes);
int fs_shrink(int fd, int new_size);
int fs_delete(const char* name);
void fs_close();

// User Management
int fs_useradd(const char* username);
int fs_userdel(const char* username);
int fs_groupadd(const char* groupname);
int fs_groupdel(const char* groupname);
int fs_usermod_add_group(const char* username, const char* groupname);

// Permissions
int fs_chmod(const char* path, uint32_t mode);
int fs_chown(const char* path, const char* username);
int fs_chgrp(const char* path, const char* groupname);
void fs_getfacl(const char* path);
int fs_check_permission(const char* path, int required_perm);
```

## Example Session

```
$ ./myfs
🔧 Loading disk: filesys.db
✅ New disk formatted (20480 blocks)

myfs:root> useradd alice
👥 Group 'alice' created (gid=1)
👤 User 'alice' created (uid=1, gid=1)

myfs:root> create test.txt 644
📄 File test.txt created

myfs:root> chown alice test.txt
✅ Owner of 'test.txt' changed to 'alice'

myfs:root> su alice
🔄 Switched to user 'alice' (uid=1)

myfs:alice> open test.txt rw
✅ File test.txt opened (fd=0)

myfs:alice [test.txt]> write 0 Hello World
✍️  11 bytes written at position 0

myfs:alice [test.txt]> read
📖 Content (11 bytes):
Hello World

myfs:alice [test.txt]> exit
👋 Goodbye!
```
