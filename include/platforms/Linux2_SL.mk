SHAREDEXT:=.so
STATICEXT:=.a

DATAREP  = -DDATAREP_LITTLE_IEEE -DDATAREP_LITTLE_ENDIAN

override DEFECTS += -DDEFECT_NO_JZEXT
override DEFECTS  += -DDEFECT_NO_INTHEX
override DEFECTS  += -DDEFECT_NO_INTHOLLERITH
override DEFECTS  += -DDEFECT_NO_READONLY
override DEFECTS  += -DDEFECT_NO_DIRECT_FIXED
override DEFECTS  += -DDEFECT_NO_STRUCTURE

override DEFINES += -DUNIX -DLINUX
override DEFINES += -D__UNIX__ -D__LINUX__
#override DEFINES += -D_FIXED_TYPES_ENV=1

override CPPFLAGS += -D_POSIX_SOURCE -D_SVID_SOURCE -D_BSD_SOURCE
override CPPFLAGS += -D_POSIX_C_SOURCE=2 -D_XOPEN_SOURCE                  

# Fortran
FC=g77
FPP=$(FC)

FCFLAGS += -fdollar-ok -fno-automatic  
FCFLAGS += -fno-second-underscore -ffixed-line-length-132 
FCFLAGS += -fno-globals  -w
FCFLAGS += -fdebug-kludge
FCFLAGS += -DFORTRAN -DLANGUAGE_FORTRAN

FCPPFLAGS += -C -P -DLinux -DUNIX
FCPPFLAGS += -DFORTRAN -DLANGUAGE_FORTRAN

FCPICFLAG =
FCPPMFLAGS=-x none

# Support for various qualifiers

ifeq ($(findstring default,$(SRT_QUAL)),default)
    override FCFLAGS += -g
endif

ifeq ($(findstring debug,$(SRT_QUAL)),debug)
    override FCFLAGS += -g
endif

ifeq ($(findstring maxopt,$(SRT_QUAL)),maxopt)
    override FCFLAGS += -O2
endif

-include SRT_$(SRT_PROJECT)/special/platforms/Linux2.mk
-include SRT_SITE/special/platforms/Linux2.mk
