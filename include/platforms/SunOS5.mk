SHAREDEXT:=.so
STATICEXT:=.a

DATAREP  = -DDATAREP_BIG_IEEE -DDATAREP_BIG_ENDIAN


override DEFINES += -DUNIX -DSunOS
override DEFINES += -D__UNIX__ -D__SUNOS__


# Fortran
FC=f77
FPP=g77

override FCPPFLAGS += -C -P -DSunOS

-include SRT_$(SRT_PROJECT)/special/platforms/SunOS5.mk
-include SRT_SITE/special/platforms/SunOS5.mk
