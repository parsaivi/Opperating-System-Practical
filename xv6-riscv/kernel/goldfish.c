// Goldfish RTC interface

#include "param.h"
#include "types.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "fs.h"

// the goldfish control registers are memory-mapped
// at address GOLDFISH_RTC. this macro returns the
// address of one of the registers.
#define Reg(reg) ((volatile uint32 *)(GOLDFISH_RTC + reg))
#define ReadReg(reg) (*(Reg(reg)))

// From https://github.com/torvalds/linux/blob/7ba2090ca64ea1aa435744884124387db1fac70f/include/clocksource/timer-goldfish.h#L20
// and https://cgit.freebsd.org/src/commit/sys/dev/goldfish/goldfish_rtc.c?id=d63a631e72441687910b8ec4a9396ac5d05029fb
#define TIMER_TIME_LOW  0x00
#define TIMER_TIME_HIGH 0x04

// Gets the current time in unix epoch
uint64
get_current_time(void) {
  uint64 low, high, nsec;

  low = ReadReg(TIMER_TIME_LOW);
  high = ReadReg(TIMER_TIME_HIGH);
  nsec = (high << 32) | low;

  return nsec / 1000000000;
}