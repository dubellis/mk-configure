# Copyright (c) 2009-2010 by Aleksey Cheusov
# Copyright (c) 1994-2009 The NetBSD Foundation, Inc.
# Copyright (c) 1988, 1989, 1993 The Regents of the University of California
# Copyright (c) 1988, 1989 by Adam de Boor
# Copyright (c) 1989 by Berkeley Softworks
#
# See COPYRIGHT file in the distribution.
############################################################

.if !defined(_MKC_IMP_LIB_MK)
_MKC_IMP_LIB_MK=1

.PHONY:		libinstall
.if ${MKINSTALL:tl} == "yes"
realinstall:	libinstall
INSTALLDIRS+=	${DESTDIR}${LIBDIR}
UNINSTALLFILES+=${UNINSTALLFILES.lib}
.endif # MKINSTALL

# add additional suffixes not exported.
# .op is used for profiling object files.
# .os is used for PIC object files.
.SUFFIXES: .out .a .so .os .po .op .o .s .S .c .cc .cpp .C .m .F .f .r .y .l .cl .p .h
.SUFFIXES: .sh .m4 .m


# Set PICFLAGS to cc flags for producing position-independent code,
# if not already set.  Includes -DPIC, if required.

# Data-driven table using make variables to control how shared libraries
# are built for different platforms and object formats.
# OBJECT_FMT:		currently either "ELF" or "a.out", from <bsd.own.mk>
# LDFLAGS.soname:	Flags to tell ${LD} to emit shared library.
#			with ELF, also set shared-lib version for ld.so.
#
# FFLAGS.pic:		flags for ${FC} to compile .[fF] files to .os objects.
# CPPICFLAGS:		flags for ${CPP} to preprocess .[sS] files for ${AS}
# CFLAGS.pic:		flags for ${CC} to compile .[cC] files to .os objects.
# CAFLAGS.pic		flags for {$CC} to compiling .[Ss] files
#		 	(usually just ${CPPFLAGS.pic} ${CFLAGS.pic})
# AFLAGS.pic:		flags for ${AS} to assemble .[sS] to .os objects.

CFLAGS+=	${COPTS}
FFLAGS+=	${FOPTS}

.c.o:
	${COMPILE.c} ${.IMPSRC}

.c.op:
	${COMPILE.c} -pg ${.IMPSRC} -o ${.TARGET}

.c.os:
	${COMPILE.c} ${CFLAGS.pic} ${.IMPSRC} -o ${.TARGET}

.cc.o .C.o .cpp.o:
	${COMPILE.cc} ${.IMPSRC}

.cc.op .C.op .cpp.op:
	${COMPILE.cc} -pg ${.IMPSRC} -o ${.TARGET}

.cc.os .C.os .cpp.os:
	${COMPILE.cc} ${CXXFLAGS.pic} ${.IMPSRC} -o ${.TARGET}

.f.o:
	${COMPILE.f} ${.IMPSRC}

.f.op:
	${COMPILE.f} -pg ${.IMPSRC} -o ${.TARGET}

.f.os:
	${COMPILE.f} ${FFLAGS.pic} ${.IMPSRC} -o ${.TARGET}

.m.o:
	${COMPILE.m} ${.IMPSRC}

.m.op:
	${COMPILE.m} -pg ${.IMPSRC} -o ${.TARGET}

.m.os:
	${COMPILE.m} ${CFLAGS.pic} ${.IMPSRC} -o ${.TARGET}

.S.o .s.o:
	${COMPILE.S} ${AINC} ${.IMPSRC} -o ${.TARGET}

.S.op .s.op:
	${COMPILE.S} ${PROFFLAGS} ${AINC} ${.IMPSRC} -o ${.TARGET}

.S.os .s.os:
	${COMPILE.S} ${CAFLAGS.pic} ${AINC} ${.IMPSRC} -o ${.TARGET}

OBJS+=${SRCS:N*.h:N*.sh:T:R:S/$/.o/g}
SOBJS=${OBJS:.o=.os}
POBJS=${OBJS:.o=.op}

.if ${MKSTATICLIB:tl} != "no"
_LIBS+=lib${LIB}.a
.endif

.if ${MKPROFILELIB:tl} != "no"
_LIBS+=lib${LIB}_p.a
.endif

.if ${MKPICLIB:tl} != "no"
_LIBS+=lib${LIB}_pic.a
.endif # MKPICLIB

.if ${MKSHLIB:tl} != "no"
.if ${MKDLL:tl} == "no"
SHLIBFN=	lib${LIB}${SHLIB_EXTFULL}
.else
SHLIBFN=	${LIB}${SHLIB_EXT}
.endif
_LIBS+=		${SHLIBFN}
.endif

.NOPATH: ${_LIBS}

realall: ${SRCS} ${_LIBS}

__archivebuild: .USE
	@rm -f ${.TARGET}
	${MESSAGE.ar}
	${_V} ${AR} cq ${.TARGET} ${.ALLSRC}
	${RANLIB} ${.TARGET}

__archiveinstall: .USE
	${INSTALL} ${RENAME} ${PRESERVE} ${COPY} -o ${LIBOWN} \
	    -g ${LIBGRP} -m ${LIBMODE} ${.ALLSRC} ${.TARGET}

DPSRCS+=	${SRCS:M*.l:.l=.c} ${SRCS:M*.y:.y=.c}
CLEANFILES+=	${DPSRCS}
.if defined(YHEADER)
CLEANFILES+=	${SRCS:M*.y:.y=.h}
.endif

lib${LIB}.a:: ${OBJS} __archivebuild
	@${_MESSAGE_V} "building standard ${LIB} library"

lib${LIB}_p.a:: ${POBJS} __archivebuild
	@${_MESSAGE_V} "building profiled ${LIB} library"

lib${LIB}_pic.a:: ${SOBJS} __archivebuild
	@${_MESSAGE_V} "building shared object ${LIB} library"

${SHLIBFN}: ${SOBJS} ${DPADD}
.if !commands(${SHLIBFN})
	@${_MESSAGE_V} building shared ${LIB} library \(version ${SHLIB_FULLVERSION}\)
	@rm -f ${.TARGET}
	@${_MESSAGE} "LD: ${.TARGET}"
	${_V} $(LDREAL) ${LDFLAGS.shared} ${LDFLAGS.soname} -o ${.TARGET} \
	    ${SOBJS} ${LDFLAGS} ${LDADD}
.if ${OBJECT_FMT} == "ELF" && ${MKDLL:tl} == "no"
	ln -sf ${SHLIBFN} lib${LIB}${SHLIB_EXT}
	ln -sf ${SHLIBFN} lib${LIB}${SHLIB_EXT1}
.endif # ELF
.endif # !commands(...)

CLEANFILES+= a.out [Ee]rrs mklog core *.core \
	${OBJS} ${POBJS} ${SOBJS} \
	lib${LIB}${SHLIB_EXT} lib${LIB}${SHLIB_EXT1} \
	lib${LIB}${SHLIB_EXT2} lib${LIB}${SHLIB_EXT3} ${SHLIBFN}

.if !target(libinstall)
# Make sure it gets defined
libinstall::

   # MKSTATICLIB
.if ${MKSTATICLIB:tl} != "no"
libinstall:: ${DESTDIR}${LIBDIR}/lib${LIB}.a
.PRECIOUS: ${DESTDIR}${LIBDIR}/lib${LIB}.a
.PHONY: ${DESTDIR}${LIBDIR}/lib${LIB}.a
UNINSTALLFILES.lib+= ${DESTDIR}${LIBDIR}/lib${LIB}.a
CLEANFILES+=lib${LIB}.a

${DESTDIR}${LIBDIR}/lib${LIB}.a: lib${LIB}.a __archiveinstall
.endif

   # MKPROFILELIB
.if ${MKPROFILELIB:tl} != "no"
libinstall:: ${DESTDIR}${LIBDIR}/lib${LIB}_p.a
.PRECIOUS: ${DESTDIR}${LIBDIR}/lib${LIB}_p.a
.PHONY: ${DESTDIR}${LIBDIR}/lib${LIB}_p.a
UNINSTALLFILES.lib+= ${DESTDIR}${LIBDIR}/lib${LIB}_p.a
CLEANFILES+=	lib${LIB}_p.a

${DESTDIR}${LIBDIR}/lib${LIB}_p.a: lib${LIB}_p.a __archiveinstall
.endif

   # MKPICLIB
.if ${MKPICLIB:tl} != "no"
CLEANFILES+=lib${LIB}_pic.a
.endif

.if ${MKPICLIB:tl} != "no"
libinstall:: ${DESTDIR}${LIBDIR}/lib${LIB}_pic.a
.PRECIOUS: ${DESTDIR}${LIBDIR}/lib${LIB}_pic.a
.PHONY: ${DESTDIR}${LIBDIR}/lib${LIB}_pic.a
UNINSTALLFILES.lib+= ${DESTDIR}${LIBDIR}/lib${LIB}_pic.a

${DESTDIR}${LIBDIR}/lib${LIB}_pic.a: lib${LIB}_pic.a __archiveinstall
.endif

   # MKSHLIB
.if ${MKSHLIB:tl} != "no"
libinstall:: ${DESTDIR}${LIBDIR}/${SHLIBFN}
.PRECIOUS: ${DESTDIR}${LIBDIR}/${SHLIBFN}
.PHONY: ${DESTDIR}${LIBDIR}/${SHLIBFN}
UNINSTALLFILES.lib+= ${DESTDIR}${LIBDIR}/${SHLIBFN}
.if ${MKDLL:tl} == "no"
UNINSTALLFILES.lib+=	${DESTDIR}${LIBDIR}/lib${LIB}${SHLIB_EXT} \
			${DESTDIR}${LIBDIR}/lib${LIB}${SHLIB_EXT1}
.endif

${DESTDIR}${LIBDIR}/${SHLIBFN}: ${SHLIBFN}
	${INSTALL} ${RENAME} ${PRESERVE} ${COPY} -o ${LIBOWN} \
	    -g ${LIBGRP} -m ${SHLIBMODE} ${.ALLSRC} ${.TARGET}
.if ${OBJECT_FMT} == "a.out" && !defined(DESTDIR) && ${MKDLL:tl} == "no"
	/sbin/ldconfig -m ${LIBDIR}
.endif
.if ${OBJECT_FMT} == "ELF" && ${MKDLL:tl} == "no"
	ln -sf ${SHLIBFN} \
	    ${DESTDIR}${LIBDIR}/lib${LIB}${SHLIB_EXT1}
	ln -sf ${SHLIBFN} \
	    ${DESTDIR}${LIBDIR}/lib${LIB}${SHLIB_EXT}
.endif
.endif
.endif

.endif #_MKC_IMP_LIB_MK
