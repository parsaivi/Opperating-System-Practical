#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "user/uthread.h"

struct thread all_thread[MAX_THREAD];
struct thread *current_thread;
extern void thread_switch(struct context*, struct context*);

void 
thread_init(void)
{
  current_thread = &all_thread[0];
  current_thread->state = RUNNING;
}

void 
thread_schedule(void)
{
  // TODO
}

void 
thread_create(void (*func)())
{
  // TODO
}

void 
thread_yield(void)
{
  // TODO
}

volatile int a_started, b_started, c_started;
volatile int a_n, b_n, c_n;

void 
thread_a(void)
{
  // TODO
}

void 
thread_b(void)
{
  // TODO
}

void 
thread_c(void)
{
  // TODO
}

int 
main(int argc, char **argv[]) 
{
  a_started = b_started = c_started = 0;
  a_n = b_n = c_n = 0;
  thread_init();
  thread_create(thread_a);
  thread_create(thread_b);
  thread_create(thread_c);
  thread_schedule();
  exit(0);
}