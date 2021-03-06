/********************************************************************\
 Copyright (c) 2014 by Aleksey Cheusov

 See LICENSE file in the distribution.
\********************************************************************/

#ifndef _MKC_PROGNAME_H_
#define _MKC_PROGNAME_H_

#ifdef MKC_PROGNAME_IS_FINE

#include <stdlib.h>

#else

#if !HAVE_FUNC1_SETPROGNAME_STDLIB_H
void setprogname (const char *progname);
#endif

#if !HAVE_FUNC0_GETPROGNAME_STDLIB_H
const char * getprogname (void);
#endif

#endif /* MKC_PROGNAME_IS_FINE */

#endif // _MKC_PROGNAME_H_
