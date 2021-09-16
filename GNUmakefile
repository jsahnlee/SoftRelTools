# SoftRelTools makes itself!

PACKAGE=SoftRelTools
PACKAGE_INCLUDE=include

ifneq ($(findstring CYGWIN,$(SRT_ARCH)),)
    SUBDIRS = nt
else
    SUBDIRS = 
endif
SUBDIRS += scripts doc man

include SoftRelTools/standard.mk
