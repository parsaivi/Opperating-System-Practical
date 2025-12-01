# MyFileSystem

A simple block-based filesystem implementation in C for Operating Systems course.

## Features

- 10MB virtual disk with 512-byte blocks
- File create, read, write, shrink, and delete operations
- Free space management with block coalescing
- Interactive CLI shell
- Persistent storage (survives restarts)

## Build & Run

```bash
make          # Build the project
make run      # Build and launch the CLI shell
make clean    # Remove build artifacts
```

## CLI Commands

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

## API

```c
int fs_init(const char* disk_path);   // Initialize/load disk
int fs_create(const char* name, uint32_t permissions);
int fs_open(const char* name, int flags);
int fs_read(int fd, int pos, char* buffer, int n_bytes);
int fs_write(int fd, int pos, const char* buffer, int n_bytes);
int fs_shrink(int fd, int new_size);
int fs_delete(const char* name);
void fs_close();                      // Save and close disk
```
