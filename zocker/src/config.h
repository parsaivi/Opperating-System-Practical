#ifndef __CONFIG_H__
#define __CONFIG_H__

#ifndef DEFAULT_NAME
#define DEFAULT_NAME "bib"
#endif

enum COMMAND {
  NONE = 0,
  RUN = 10,
  EXEC = 11,
};

struct config {
  enum COMMAND subcommand;
  char name[64];
  char command[256];
  char base_dir[512];
};

int validate_config(struct config cfg);
#endif
