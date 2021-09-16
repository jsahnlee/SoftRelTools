# arch_spec_f77.mk
#
# Architecture/site specific makefile fragment
#   for inclusion by packages that use f77 code with g++.
#
# Original version:
# Bob Jacobsen, Oct 95
#
# uses four internal variables that can be overridden from environment:
#
#   FORTLINKDIR  = base directory for f77 compiler/linker specific stuff
#   FORTLINKVER  = version number for Sun
#   FORTLINKLDFLAGS = flags added to LDFLAGS (except -L)
#   FORTLINKLIBS = -L for the the needed extra libs
#   FORTLINKOBJS = .o filenames or other things, added to LOADLIBES
#   FORTLINKLOADLIBES = -l<lib> flags for the LOADLIBES variable
#
# Warning: this file does not meet the SoftRelTools standard!
#
# Under Linux, the modern libg2c is now used instead of the ancient
# libf2c. To use libf2c under Linux, set the environment variable
# SRT_USE_F2C to any non-null value.
#
extpkg := f77
arch_spec_warning:= "This file does not follow the standard SoftRelTools logic."

ifneq (,$(findstring SunOS5,$(SRT_ARCH)))
   FORTLINKDIR  = /opt/SUNWspro
   FORTLINKVER  = 
   FORTLINKLIBS = -L$(FORTLINKDIR)/lib
   FORTLINKLDFLAGS = 
   FORTLINKOBJS = 
   FORTLINKLOADLIBES = -lM77 -lF77 -lsunmath -lm
else

ifneq (,$(findstring SunOS4,$(SRT_ARCH)))
   FORTLINKDIR  = /usr/lang
   FORTLINKVER  = SC3.0.1
   FORTLINKLIBS = -L$(FORTLINKDIR)/$(FORTLINKVER)/lib
   FORTLINKLDFLAGS = 
   FORTLINKOBJS = $(FORTLINKDIR)/$(FORTLINKVER)/lib/values-Xa.o
   FORTLINKLOADLIBES = -u _fix_libc_ -lM77 -lF77 -lsunmath -lm -lansi -lcx -lc
else

ifneq (,$(findstring AIX,$(SRT_ARCH)))
   FORTLINKDIR  = 
   FORTLINKVER  = 
   FORTLINKLIBS = 
   FORTLINKLDFLAGS = 
   FORTLINKOBJS = 
   FORTLINKLOADLIBES = -lxlf -lxlf90
else

ifneq (,$(findstring HP-UX,$(SRT_ARCH)))
   FORTLINKDIR  = 
   FORTLINKVER  = 
   FORTLINKLIBS = -L/opt/fortran/lib
   FORTLINKLDFLAGS = -Xlinker -a -Xlinker archive
   FORTLINKOBJS = 
   FORTLINKLOADLIBES = -lcl -lisamstub -lU77 /usr/lib/libdld.sl
else

ifneq (,$(findstring OSF,$(SRT_ARCH)))
   FORTLINKDIR  = 
   FORTLINKVER  = 
   FORTLINKLIBS = 
   FORTLINKLDFLAGS = 
   FORTLINKOBJS = 
   FORTLINKLOADLIBES = -lshpf -lUfor -lfor -lFutil -lots -lc -lm
else

ifneq (,$(findstring IRIX5,$(SRT_ARCH)))
   FORTLINKDIR  = 
   FORTLINKVER  = 
   FORTLINKLIBS = 
   FORTLINKLDFLAGS = 
   FORTLINKOBJS = 
   FORTLINKLOADLIBES = -liberty -lftn -lm
else

ifneq (,$(findstring IRIX6,$(SRT_ARCH)))
   FORTLINKDIR  = 
   FORTLINKVER  = 
   ifeq (CC,$(findstring CC,$(SRT_CXX)))
     FORTLINKLIBS = 
   else
     FORTLINKLIBS = -L$(GCC_DIR)/lib
   endif
   FORTLINKLDFLAGS = 
   FORTLINKOBJS = 
   # Search for CC (not -CC), to match either CC or KCC
   ifeq (CC,$(findstring CC,$(SRT_CXX)))
     FORTLINKLOADLIBES = -lftn -lm
   else
     FORTLINKLOADLIBES = -liberty -lftn -lm
   endif
else

ifneq (,$(findstring Linux,$(SRT_ARCH)))
   FORTLINKDIR  = 
   FORTLINKVER  = 
   FORTLINKLIBS = 
   FORTLINKLDFLAGS = 
   FORTLINKOBJS = 
   # This really is not a good idea.
   # It should be replaced by something better.
   ifndef SRT_USE_F2C
       FORTLINKLOADLIBES = -lg2c -lm
   else
       FORTLINKLOADLIBES = -lf2c -lm
   endif
else

ifneq (,$(findstring MSVC,$(SRT_ARCH)))
   FORTLINKDIR  = 
   FORTLINKVER  = 
   FORTLINKLIBS = 
   FORTLINKLDFLAGS = 
   FORTLINKOBJS = 
   FORTLINKLOADLIBES = dformt.lib
else

# Nothing found - complain 

arch_spec_error := "Could not match SRT_ARCH: $(SRT_ARCH) for f77 libs"

endif
endif
endif
endif
endif
endif
endif
endif
endif

include SoftRelTools/specialize_arch_spec.mk

override LDFLAGS +=  $(FORTLINKLIBS) $(FORTLINKLDFLAGS)
override LOADLIBES += $(FORTLINKOBJS) $(FORTLINKLOADLIBES)
