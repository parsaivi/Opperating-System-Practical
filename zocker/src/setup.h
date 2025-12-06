#ifndef __SETUP_H__
#define __SETUP_H__

#ifndef ZOCKER_PREFIX
#define ZOCKER_PREFIX "/tmp/zocker"
#endif

int setup_zocker_dir(void);
int setup_container_dir(const char id[64], char container_dir[256]);

#endif
