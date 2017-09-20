#ifndef CO_TI_H_
#define CO_TI_H_

#ifdef _lint /* Make sure no compiler comes this way */

/* Standard library headers typically define the assert macro so that it
   expands to a complicated conditional expression that uses special
   funtions that Lint does not know about by default.  For linting
   purposes, we can simplify things a bit by forcing assert() to expand to
   a call to a special function that has the appropriate 'assert'
   semantics.
 */
//lint -function( __assert, __lint_assert )
void __lint_assert( int );
//lint ++d"assert(e)=__lint_assert(!!(e))" 
//(++d makes this definition permanently immutable for the Lint run.)
//Now that we've made our own 'assert', we need to keep people from being
//punished when the marco in 'assert.h' appears not to be used:
//lint  -efile(766,*assert.h)

/*
   The headers included below must be generated; For C++, generate
   with:

   <c++ compiler> [usual build options] -ppm=lint_cppmac.h t.cpp

   For C, generate with:

   <c compiler> [usual build options] -ppm=lint_cmac.h t.c

   ...where "t.cpp" and "t.c" are empty source files.

   It's important to use the same compiler options used when compiling
   project code because they can affect the existence and precise
   definitions of certain predefined macros.  See ti-readme.txt for
   details and a tutorial.
 */
#if defined(__cplusplus)
#       include "lint_cppmac.h"
#else
#       include "lint_cmac.h"
#endif

#define __COUNTER__ __lint__COUNTER__
//lint +rw( *type_traits ) // Enable type traits support
#endif

/* On some TI compilers the forward declaration for memcpy missing */
namespace std {
  void   *memcpy(void *s1, const void *s2, size_t n);
} // namespace std
//lint -esym(534,std::memcpy,memcpy)

#endif /* _lint      */
#endif /* CO_TI_H_ */
