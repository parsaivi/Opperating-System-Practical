#define _GNU_SOURCE
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include <libgen.h>

#include "setup.h"

static int copy_file(const char *src, const char *dst) {
  char cmd[512];
  snprintf(cmd, sizeof(cmd), "cp %s %s", src, dst);
  return system(cmd);
}

static int copy_libs_for_binary(const char *binary, const char *container_dir) {
  char cmd[512];
  char line[512];
  FILE *fp;

  snprintf(cmd, sizeof(cmd), "ldd %s 2>/dev/null", binary);
  fp = popen(cmd, "r");
  if (!fp) return 1;

  while (fgets(line, sizeof(line), fp)) {
    char *start = strchr(line, '/');
    if (!start) continue;
    
    char *end = strchr(start, ' ');
    if (end) *end = '\0';
    end = strchr(start, '\n');
    if (end) *end = '\0';

    char dest[512];
    snprintf(dest, sizeof(dest), "%s%s", container_dir, start);

    char dest_dir[512];
    strncpy(dest_dir, dest, sizeof(dest_dir));
    char *dir = dirname(dest_dir);
    
    char mkdir_cmd[512];
    snprintf(mkdir_cmd, sizeof(mkdir_cmd), "mkdir -p %s", dir);
    system(mkdir_cmd);

    if (access(dest, F_OK) != 0) {
      copy_file(start, dest);
    }
  }
  pclose(fp);
  return 0;
}

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
  if (mkdir(bin_dir, 0755) == -1 && errno != EEXIST) {
    fprintf(stderr, "[ERR] Failed to create bin directory %s\n", bin_dir);
    return 1;
  }

  const char *binaries[] = {"/bin/sh", "/bin/ls", "/bin/cat", "/bin/pwd", NULL};
  
  for (int i = 0; binaries[i] != NULL; i++) {
    char dest[512];
    const char *bin_name = strrchr(binaries[i], '/');
    if (!bin_name) continue;
    bin_name++;
    
    snprintf(dest, sizeof(dest), "%s/%s", bin_dir, bin_name);
    
    if (access(dest, F_OK) != 0) {
      copy_file(binaries[i], dest);
      char chmod_cmd[512];
      snprintf(chmod_cmd, sizeof(chmod_cmd), "chmod +x %s", dest);
      system(chmod_cmd);
    }
    
    copy_libs_for_binary(binaries[i], container_dir);
  }

  return 0;
}

static int setup_lib_dir(const char container_dir[256]) {
  char lib_dir[256];
  char lib32_dir[256];
  char lib64_dir[256];

  if (snprintf(lib_dir, sizeof(lib_dir), "%s/lib", container_dir) < 0) {
    return 1;
  }
  if (mkdir(lib_dir, 0755) == -1 && errno != EEXIST) {
    fprintf(stderr, "[ERR] Failed to create lib directory %s\n", lib_dir);
    return 1;
  }

  if (snprintf(lib32_dir, sizeof(lib32_dir), "%s/lib32", container_dir) < 0) {
    return 1;
  }
  if (mkdir(lib32_dir, 0755) == -1 && errno != EEXIST) {
    fprintf(stderr, "[ERR] Failed to create lib32 directory %s\n", lib32_dir);
    return 1;
  }

  if (snprintf(lib64_dir, sizeof(lib64_dir), "%s/lib64", container_dir) < 0) {
    return 1;
  }

  if (mkdir(lib64_dir, 0755) == -1 && errno != EEXIST) {
    fprintf(stderr, "[ERR] Failed to create lib64 directory %s\n", lib64_dir);
    return 1;
  }

  return 0;
}
