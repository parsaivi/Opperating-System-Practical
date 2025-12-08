#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(void)
{
  int tickets[4] = {10, 20, 30, 40};
  int pids[4];
  int i;
  
  printf("Lottery Scheduling Test\n");
  printf("Tickets: 10, 20, 30, 40 (ratio 1:2:3:4)\n\n");
  
  // Create all children first
  for(i = 0; i < 4; i++) {
    pids[i] = fork();
    if(pids[i] == 0) {
      // Child: set tickets and wait for signal
      settickets(getpid(), tickets[i]);
      pause(50);  // Wait for all children to be created
      
      int counter = 0;
      int start = uptime();
      int duration = 200;  // run for 200 ticks
      
      while(uptime() - start < duration) {
        counter++;
      }
      
      printf("Child %d (%d tickets): %d iterations\n", i+1, tickets[i], counter);
      exit(0);
    }
  }
  
  // Parent waits for all children
  for(i = 0; i < 4; i++) {
    wait(0);
  }
  
  printf("\nExpected ratio: ~1:2:3:4 (10%%:20%%:30%%:40%%)\n");
  exit(0);
}
