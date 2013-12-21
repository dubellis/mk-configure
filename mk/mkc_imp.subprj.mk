# Copyright (c) 2010-2013 by Aleksey Cheusov
# Copyright (c) 1994-2009 The NetBSD Foundation, Inc.
# Copyright (c) 1988, 1989, 1993 The Regents of the University of California
# Copyright (c) 1988, 1989 by Adam de Boor
# Copyright (c) 1989 by Berkeley Softworks
#
# See LICENSE file in the distribution.
############################################################

.if !defined(_MKC_IMP_SUBPRJ_MK)
_MKC_IMP_SUBPRJ_MK := 1

.for dir in ${SUBPRJ:S/:/ /g}
.if empty(NOSUBDIR:U:M${dir})
__REALSUBPRJ += ${dir}
.endif
.endfor

.ifndef SUBDIR
__REALSUBPRJ := ${__REALSUBPRJ:O:u}
.endif

.if !empty(__REALSUBPRJ:M*-*)
.error "Dash symbol is not allowed inside subdir (${__REALSUBPRJ:M*-*})"
.endif

SUBPRJ_DFLT ?=	${__REALSUBPRJ}

.for targ in ${TARGETS}
.for dir in ${__REALSUBPRJ:N.WAIT}
.PHONY: nodeps-${targ}-${dir}   subdir-${targ}-${dir}   ${targ}-${dir} \
        nodeps-${targ}-${dir:T} subdir-${targ}-${dir:T} ${targ}-${dir:T}
nodeps-${targ}-${dir}: .MAKE __recurse
       ${targ}-${dir}: .MAKE __recurse
subdir-${targ}-${dir}: .MAKE __recurse
.if ${dir} != ${dir:T}
nodeps-${targ}-${dir:T}: nodeps-${targ}-${dir}
       ${targ}-${dir:T}:        ${targ}-${dir}
subdir-${targ}-${dir:T}: subdir-${targ}-${dir}
.endif
.endfor # dir

.if !commands(${targ})
. for dir in ${SUBPRJ_DFLT}
dir_ = ${dir}
.  if ${dir_} == ".WAIT"
_SUBDIR_${targ} += .WAIT
.  else
_SUBDIR_${targ} += ${targ}-${dir}:${targ}
.  endif # .WAIT
. endfor # dir
.for excl in ${NODEPS}
_SUBDIR_${targ} :=	${_SUBDIR_${targ}:N${excl}}
.endfor # excl
_ALLTARGDEPS2 += ${_SUBDIR_${targ}}
${targ}: ${_SUBDIR_${targ}:S/:${targ}$//}
.endif #!command(${targ})

.for dep prj in ${SUBPRJ:M*\:*:S/:/ /}
_ALLTARGDEPS += ${targ}-${dep}:${targ}-${prj}
.endfor

.endfor # targ

.for dir in ${__REALSUBPRJ}
.if ${dir:T} != ${dir}
_ALLTARGDEPS += all-${dir}:${dir:T}
.endif
_ALLTARGDEPS += all-${dir}:${dir}
.endfor # dir

.for excl in ${NODEPS}
_ALLTARGDEPS :=	${_ALLTARGDEPS:N${excl}}
.endfor # excl

.for deptarg prjtarg in ${_ALLTARGDEPS:S/:/ /}
.PHONY: ${prjtarg} ${deptarg}
${prjtarg}: ${deptarg}
.endfor

# Make sure all of the standard targets are defined, even if they do nothing.
${TARGETS}:

.PHONY: output_deps
output_deps:
.for i in ${_ALLTARGDEPS} ${_ALLTARGDEPS2}
	@echo ${i}
.endfor

.include <mkc_imp.objdir.mk>

.endif # _MKC_IMP_SUBPRJ_MK
