#ifndef __RUN_H__
#define __RUN_H__

struct container {
  char id[64];
  char command[256];
};

int run_container(struct container cont);
void container_from_config(struct config cfg, struct container *c);

#endif
