// From https://codereview.stackexchange.com/q/184425

/*  Written in 2016-2018 by David Blackman and Sebastiano Vigna (vigna@acm.org)

To the extent possible under law, the author has dedicated all copyright
and related and neighboring rights to this software to the public domain
worldwide. This software is distributed without any warranty.

See <http://creativecommons.org/publicdomain/zero/1.0/>. */

#include "param.h"
#include "types.h"
#include "spinlock.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "fs.h"

/* This is xoroshiro128+ 1.0, our best and fastest small-state generator
   for floating-point numbers, but its state space is large enough only
   for mild parallelism. We suggest to use its upper bits for
   floating-point generation, as it is slightly faster than
   xoroshiro128++/xoroshiro128**. It passes all tests we are aware of
   except for the four lower bits, which might fail linearity tests (and
   just those), so if low linear complexity is not considered an issue (as
   it is usually the case) it can be used to generate 64-bit outputs, too;
   moreover, this generator has a very mild Hamming-weight dependency
   making our test (http://prng.di.unimi.it/hwd.php) fail after 5 TB of
   output; we believe this slight bias cannot affect any application. If
   you are concerned, use xoroshiro128++, xoroshiro128** or xoshiro256+.

   We suggest to use a sign test to extract a random Boolean value, and
   right shifts to extract subsets of bits.

   The state must be seeded so that it is not everywhere zero. If you have
   a 64-bit seed, we suggest to seed a splitmix64 generator and use its
   output to fill s. 

   NOTE: the parameters (a=24, b=16, b=37) of this version give slightly
   better results in our test than the 2016 version (a=55, b=14, c=36).
*/

static inline
uint64 rotl(const uint64 x, int k) {
  return (x << k) | (x >> (64 - k));
}

static uint64 s[2];
static struct spinlock next_lock, next_byte_lock;

static uint64
splitmix64next(const uint64 x) {
    uint64 z = (x + 0x9e3779b97f4a7c15);
    z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9;
    z = (z ^ (z >> 27)) * 0x94d049bb133111eb;
    return z ^ (z >> 31);
}

// Seed the random number generator
void
rng_seed(uint64 seed) {
  initlock(&next_lock, "next_lock");
  initlock(&next_byte_lock, "next_byte_lock");
  s[0] = splitmix64next(seed);
  s[1] = splitmix64next(s[0]);
}

// Get a uint64 as a random number
int
rand_int(void) {
  acquire(&next_lock);
  const uint64 s0 = s[0];
  uint64 s1 = s[1];
  release(&next_lock);
  const uint64 result = s0 + s1;
  
  s1 ^= s0;
  s[0] = rotl(s0, 24) ^ s1 ^ (s1 << 16); // a, b
  s[1] = rotl(s1, 37); // c
  
  return (int) (result >> 32);
}