SHAREDEXT:=.so
STATICEXT:=.a

DATAREP  = -DDATAREP_LITTLE_IEEE -DDATAREP_LITTLE_ENDIAN

override DEFINES  += -Dosf1 -DUNIX -DOSF1
override DEFINES  += -D__UNIX__ -D__OSF1__

# Fortran
FC=f77
FPP=$(FC)

override FCPPFLAGS += -C -P -DOSF1 -DUNIX -extend_source

-include SRT_$(SRT_PROJECT)/special/platforms/OSF1V4.mk
-include SRT_SITE/special/platforms/OSF1V4.mk
