#define FREE        0x0
#define RUNNING     0x1
#define RUNNABLE    0x2

#define STACK_SIZE  8192
#define MAX_THREAD  4

struct context {
  uint64 ra;
  uint64 sp;

  uint64 s0;
  uint64 s1;
  uint64 s2;
  uint64 s3;
  uint64 s4;
  uint64 s5;
  uint64 s6;
  uint64 s7;
  uint64 s8;
  uint64 s9;
  uint64 s10;
  uint64 s11;
};

struct thread {
  char       stack[STACK_SIZE];     // the thread's stack
  int        state;                 // FREE, RUNNING, RUNNABLE
  struct context context;           // swtch() here to run process
};

void create_thread(void (*fn)(void));
void init_threads(void);
void schedule_thread(void);
void yield_thread(void);
void uthread_switch(struct context *old, struct context *new);