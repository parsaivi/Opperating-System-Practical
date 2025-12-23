#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>

#include "setup.h"

static int setup_bin_dir(const char container_dir[256]);
static int setup_lib_dir(const char container_dir[256]);

int setup_zocker_dir(void) {
  struct stat st;
  char prefix[64];

  if (snprintf(prefix, sizeof(prefix), "%s", ZOCKER_PREFIX) < 0) {
    return 1;
  }

  if (stat(prefix, &st) == -1) {
    if (errno == ENOENT) {
      fprintf(stderr, "[ERR] ZOCKER_PREFIX %s does not exists\n",
              ZOCKER_PREFIX);
    }
    return 1;
  }

  if (!S_ISDIR(st.st_mode)) {
    fprintf(stderr, "[ERR] ZOCKER_PREFIX %s is not a directory\n",
            ZOCKER_PREFIX);
    return 1;
  }

  return 0;
}

int setup_container_dir(const char id[64], char container_dir[256]) {
  struct stat st;
  const size_t buffer_size = 256;

  if (snprintf(container_dir, buffer_size, "%s/%s", ZOCKER_PREFIX, id) < 0) {
    return 1;
  }

  if (stat(container_dir, &st) == -1) {
    if (errno != ENOENT) {
      return 1;
    }

    if (mkdir(container_dir, 0755) == -1) {
      fprintf(stderr, "[ERR] Failed to create container directory %s\n",
              container_dir);
      return 1;
    }
  } else if (!S_ISDIR(st.st_mode)) {
    fprintf(stderr, "[ERR] Path %s is not a directory\n", container_dir);
    return 1;
  }

  if (setup_bin_dir(container_dir) != 0) {
    fprintf(stderr, "[ERR] Failed to setup bin directory for container %s\n",
            id);
    return 1;
  }

  if (setup_lib_dir(container_dir) != 0) {
    fprintf(stderr, "[ERR] Failed to setup lib directory for container %s\n",
            id);
    return 1;
  }

  return 0;
}

static int setup_bin_dir(const char container_dir[256]) {
  char bin_dir[256];
  if (snprintf(bin_dir, sizeof(bin_dir), "%s/bin", container_dir) < 0) {
    return 1;
  }
  if (mkdir(bin_dir, 0755) == -1) {
    fprintf(stderr, "[ERR] Failed to create bin directory %s\n", bin_dir);
    return 1;
  }

  char command[512];
  if (snprintf(command, sizeof(command), "cp /usr/bin/sh %s", bin_dir) < 0) {
    return 1;
  }
  system(command);

  if (snprintf(command, sizeof(command), "cp /usr/bin/ls %s", bin_dir) < 0) {
    return 1;
  }
  system(command);

  return 0;
}

static int setup_lib_dir(const char container_dir[256]) {
  char lib_dir[256];
  char lib64_dir[256];

  if (snprintf(lib_dir, sizeof(lib_dir), "%s/lib", container_dir) < 0) {
    return 1;
  }
  if (mkdir(lib_dir, 0755) == -1) {
    fprintf(stderr, "[ERR] Failed to create lib directory %s\n", lib_dir);
    return 1;
  }

  if (snprintf(lib64_dir, sizeof(lib64_dir), "%s/lib64", container_dir) < 0) {
    return 1;
  }

  if (mkdir(lib64_dir, 0755) == -1) {
    fprintf(stderr, "[ERR] Failed to create lib64 directory %s\n", lib64_dir);
    return 1;
  }

  char command[512];
  if (snprintf(command, sizeof(command),
               "cp /lib/x86_64-linux-gnu/libc.so.6 %s", lib_dir) < 0) {
    return 1;
  }
  system(command);

  if (snprintf(command, sizeof(command), "cp /lib64/ld-linux-x86-64.so.2 %s",
               lib64_dir) < 0) {
    return 1;
  }
  system(command);

  if (snprintf(command, sizeof(command),
               "cp /lib/x86_64-linux-gnu/libselinux.so.1 %s", lib_dir) < 0) {
    return 1;
  }
  system(command);

  if (snprintf(command, sizeof(command),
               "cp /lib/x86_64-linux-gnu/libc.so.6 %s", lib_dir) < 0) {
    return 1;
  }
  system(command);

  if (snprintf(command, sizeof(command),
               "cp /lib/x86_64-linux-gnu/libpcre2-8.so.0 %s", lib_dir) < 0) {
    return 1;
  }
  system(command);

  if (snprintf(command, sizeof(command), "cp /lib64/ld-linux-x86-64.so.2 %s",
               lib64_dir) < 0) {
    return 1;
  }
  system(command);

  return 0;
}
