SHAREDEXT:=.so
STATICEXT:=.a

DATAREP  = -DDATAREP_BIG_IEEE -DDATAREP_BIG_ENDIAN


override DEFINES += -Dsgi -D_SVR4_SOURCE -DUNIX -DIRIX5 -DMIPS
override DEFINES += -D__UNIX__ -D__IRIX5__


# Fortran
FC=f77
FPP=$(FC)

override FCFLAGS += -g -G0 -mips2 -static -u -d_lines -Nc32 -Nn30000
override FCFLAGS += -trapuv
override FCFLAGS += -extend_source

override FCPPFLAGS += -C -P -DIRIX

#override FCPPMFLAGS = -x c

-include SRT_$(SRT_PROJECT)/special/platforms/IRIX5.mk
-include SRT_SITE/special/platforms/IRIX5.mk
