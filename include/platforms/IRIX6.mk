SHAREDEXT:=.so
STATICEXT:=.a

DATAREP  = -DDATAREP_BIG_IEEE -DDATAREP_BIG_ENDIAN


override DEFINES += -DUNIX -DMIPS -DIRIX6
override DEFINES += -DIRIX6_2
override DEFINES += -D__UNIX__ -D__IRIX6__

override DEFECTS += -DDEFECT_RECL_WORDS

# Fortran
FC=f77
FPP=$(FC)

override FCFLAGS += -g -G0 -static  -n32 -mips3 -u -d_lines -trapuv
override FCFLAGS += -extend_source

override FCPPFLAGS += -C -P -DIRIX


-include SRT_$(SRT_PROJECT)/special/platforms/IRIX6.mk
-include SRT_SITE/special/platforms/IRIX6.mk
