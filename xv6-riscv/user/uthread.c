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
  int i, next = -1;
  int indx = current_thread - all_thread;
  // find a runnable thread
  for (i = indx; i < indx + MAX_THREAD ; i++) {
    if ((all_thread[i % (MAX_THREAD - 1) + 1].state == RUNNABLE)) {
      next = i % (MAX_THREAD - 1) + 1;
      break;
    }
  }

  // no runnable threads, nothing to schedule right now
  if (next == -1) {
      printf("thread_schedule: no runnable threads\n");
      all_thread->state = RUNNING;
      thread_switch(&current_thread->context, &all_thread->context);
      current_thread = all_thread;
      return;
  }

  struct thread *told = current_thread;
  struct thread *tnext =  &all_thread[next];

  told->state = (told->state == RUNNING) ? RUNNABLE : told->state;
  tnext->state = RUNNING;
  current_thread = tnext;
  thread_switch(&told->context, &tnext->context);
}

void 
thread_create(void (*func)())
{
  int tid;

  for (tid = 0; tid < MAX_THREAD; tid++) {
    if (all_thread[tid].state == FREE) break;
  }

  if (tid == MAX_THREAD) {
    printf("create_thread: no free thread\n");
    return;
  }

  struct thread *t = &all_thread[tid];

  // allocate space to the context
  int sz = sizeof(struct context);
  memset(&t->context, 0, sz);

  // allocate space to the stack
  uint64 sp = (uint64)(t->stack + STACK_SIZE);
  t->context.sp = sp;

  // runnable
  t->context.ra = (uint64)func;
  t->state = RUNNABLE;
}

void 
thread_yield(void)
{
  if (current_thread->state == RUNNING) current_thread->state = RUNNABLE;
  thread_schedule();
}

volatile int a_started, b_started, c_started;
volatile int a_n, b_n, c_n;

void 
thread_a(void)
{
  a_started = 1;
  printf("thread_a started\n");
  while (!(a_started && b_started && c_started)) {
    thread_yield();
  }

  for (; a_n < 100; a_n++) {
    printf("thread_a %d\n", a_n);
    // let others run
    thread_yield();
  }
  current_thread->state = FREE;
  printf("thread_a: exit after 100\n");
  thread_schedule();
}

void 
thread_b(void)
{
  b_started = 1;
  printf("thread_b started\n");
  while (!(a_started && b_started && c_started)) {
    thread_yield();
  }

  for (; b_n < 100; b_n++) {
    printf("thread_b %d\n", b_n);
    // let others run
    thread_yield();
  }
  current_thread->state = FREE;
  printf("thread_b: exit after 100\n");
  thread_schedule();
}

void 
thread_c(void)
{
  c_started = 1;
  printf("thread_c started\n");
  while (!(a_started && b_started && c_started)) {
    thread_yield();
  }

  for (; c_n < 100; c_n++) {
    printf("thread_c %d\n", c_n);
    // let others run
    thread_yield();
  }

  current_thread->state = FREE;
  printf("thread_c: exit after 100\n");
  thread_schedule();
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