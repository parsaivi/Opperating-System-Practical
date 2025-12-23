#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/param.h"

// Memory allocator by Kernighan and Ritchie,
// The C programming Language, 2nd ed.  Section 8.7.

typedef long Align;

union header {
  struct {
    union header *ptr;
    uint size;
  } s;
  Align x;
};

typedef union header Header;

static Header base;
static Header *freep;

void
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
  freep = p;
}

static Header*
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
  if(p == SBRK_ERROR)
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
  free((void*)(hp + 1));
  return freep;
}

void*
malloc(uint nbytes)
{
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}

void*
realloc(void *ptr, uint nbytes)
{
  Header *bp;
  uint old_size;
  void *new_ptr;
  char *src, *dst;
  uint i;

  // If ptr is NULL, behave like malloc
  if(ptr == 0)
    return malloc(nbytes);

  // If nbytes is 0, behave like free and return NULL
  if(nbytes == 0){
    free(ptr);
    return 0;
  }

  // Get the header of the old block
  bp = (Header*)ptr - 1;
  old_size = (bp->s.size - 1) * sizeof(Header);

  // Allocate new block
  new_ptr = malloc(nbytes);
  if(new_ptr == 0)
    return 0;

  // Copy old content to new block (copy minimum of old and new sizes)
  src = (char*)ptr;
  dst = (char*)new_ptr;
  for(i = 0; i < old_size && i < nbytes; i++)
    dst[i] = src[i];

  // Free old block
  free(ptr);

  return new_ptr;
}

void*
calloc(uint num, uint size)
{
  uint total_size;
  void *ptr;
  char *p;
  uint i;

  // Calculate total size needed
  total_size = num * size;

  // Allocate memory
  ptr = malloc(total_size);
  if(ptr == 0)
    return 0;

  // Initialize all bytes to zero
  p = (char*)ptr;
  for(i = 0; i < total_size; i++)
    p[i] = 0;

  return ptr;
}
