#define _GNU_SOURCE
#include <sched.h>
#include <stdio.h>
#include <string.h>
#include <sys/mount.h>
#include <sys/wait.h>
#include <unistd.h>

#include "config.h"
#include "run.h"
#include "setup.h"

int main(int argc, char **argv) {
  if (setup_zocker_dir() != 0) {
    return 1;
  }

  struct config cfg = {
      .subcommand = NONE,
      .name = "",
      .command = "",
  };

  int i = 1;
  while (i < argc) {
    if (strcmp(argv[i], "run") == 0) {
      cfg.subcommand = RUN;
      i++;
    } else if (strcmp(argv[i], "exec") == 0) {
      cfg.subcommand = EXEC;
      i++;
    } else if (strcmp(argv[i], "--name") == 0) {
      if (i + 1 >= argc) {
        fprintf(stderr, "[ERR] Missing --name value (e.g. [--name bib]).\n");
        return 1;
      }
      strncpy(cfg.name, argv[++i], sizeof(cfg.name) - 1);
      i++;
    } else if (strcmp(argv[i], "--base-dir") == 0) {
      if (i + 1 >= argc) {
        fprintf(stderr, "[ERR] Missing --base-dir value (e.g. [--base-dir "
                        "/aboslute/path/to/base/dir]).\n");
        return 1;
      }
      strncpy(cfg.base_dir, argv[++i], sizeof(cfg.base_dir) - 1);
      i++;
    } else {
      strncpy(cfg.command, argv[i], sizeof(cfg.command) - 1);
      i++;
    }
  }

  if (validate_config(cfg) != 0) {
    return 1;
  }

  switch (cfg.subcommand) {
  case RUN:
    struct container cont = {};
    container_from_config(cfg, &cont);

    if (run_container(cont) != 0) {
      fprintf(stderr,
              "[ERR] Running container failed due to some internal errors.\n");
      return 1;
    }
    break;
  case EXEC:
    printf("EXEC subcommand have not implemented yet...\n");
    break;
  case NONE:
  default:
    break;
  }
  return 0;
}
