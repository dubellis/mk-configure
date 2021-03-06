/********************************************************************\
 Copyright (c) 2014 by Aleksey Cheusov

 See LICENSE file in the distribution.
\********************************************************************/

#ifndef _MKC_WARN_H_
#define _MKC_WARN_H_

#include <stdarg.h>

#if HAVE_HEADER_ERR_H
#include <err.h>
#endif

#ifdef MKC_WARN_IS_FINE

#include <err.h>

#else
#if !HAVE_FUNC2_WARN_ERR_H
void warn (const char *, ...);
#endif
#if !HAVE_FUNC2_WARNX_ERR_H
void warnx (const char *, ...);
#endif
#if !HAVE_FUNC2_VWARN_ERR_H
void vwarn (const char *, va_list);
#endif
#if !HAVE_FUNC2_VWARNX_ERR_H
void vwarnx (const char *, va_list);
#endif

#endif /* MKC_WARN_IS_FINE */

#endif // _MKC_WARN_H_
