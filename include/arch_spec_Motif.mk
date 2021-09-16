# arch_spec_Motif.mk
#
# Architecture/site specific makefile fragment
#   for inclusion by packages that use Motif.
#
# MOTIF_LIB_NAME, MOTIF_LIB and MOTIF_INC are environment variables
#   containing (or optionally loaded with) the
#   location of the Motif files on the local machine.
#
# Original version:
#  Lucas Taylor   30/11/1998
#   -- first version
#   -- move Motif to this file from: arch_spec_X11   

extpkg:=Motif

ifndef ARCH_SPEC_MOTIF
ARCH_SPEC_MOTIF = ONCE

MOTIF_INC_DIR_DEFAULT := /usr/include/X11
MOTIF_LIB_DIR_DEFAULT := /usr/lib/X11
MOTIF_LIB_NAME_DEFAULT := -lXm

ifndef MOTIF_INC_DIR
    ifneq (,$(findstring SunOS5,$(SRT_ARCH)))
        MOTIF_INC = /usr/dt/include 
    else
    ifneq (,$(findstring SunOS4,$(SRT_ARCH)))
        MOTIF_INC = /usr/dt/include 
    else
    ifneq (,$(findstring Linux2,$(SRT_ARCH)))
        MOTIF_INC = /usr/X11R6/include
    else
    ifneq (,$(findstring HP-UX,$(SRT_ARCH)))
        MOTIF_INC = /usr/dt/include
    else
    ifneq (,$(findstring AIX,$(SRT_ARCH)))
        MOTIF_INC = /usr/include/X11
    else
    ifneq (,$(findstring IRIX6,$(SRT_ARCH)))
        MOTIF_INC = /usr/include/X11
    else
    ifneq (,$(findstring IRIX5,$(SRT_ARCH)))
        MOTIF_INC = /usr/include/X11
    else
    ifneq (,$(findstring OSF,$(SRT_ARCH)))
        MOTIF_INC := /usr/include/X11
    else
        MOTIF_INC := MOTIF_INC_DIR_DEFAULT
        arch_spec_error := "Could not match SRT_ARCH: $(SRT_ARCH)"
    endif
    endif
    endif
    endif
    endif
    endif
    endif
    endif
else
    MOTIF_INC:=$(MOTIF_INC_DIR)
endif


ifndef MOTIF_LIB_DIR
    ifneq (,$(findstring SunOS5,$(SRT_ARCH)))
        MOTIF_LIB = /usr/dt/lib 
    else
    ifneq (,$(findstring SunOS4,$(SRT_ARCH)))
        MOTIF_LIB = /usr/dt/lib 
    else
    ifneq (,$(findstring Linux2,$(SRT_ARCH)))
        MOTIF_LIB = /usr/X11R6/lib
    else
    ifneq (,$(findstring HP-UX,$(SRT_ARCH)))
        MOTIF_LIB = /usr/dt/lib
    else
    ifneq (,$(findstring AIX,$(SRT_ARCH)))
        MOTIF_LIB = /usr/lib/X11
    else
    ifneq (,$(findstring IRIX6,$(SRT_ARCH)))
        MOTIF_LIB = /usr/lib/X11
    else
    ifneq (,$(findstring IRIX5,$(SRT_ARCH)))
        MOTIF_LIB = /usr/lib/X11
    else
    ifneq (,$(findstring OSF,$(SRT_ARCH)))
        MOTIF_LIB := /usr/lib/X11
    else
        MOTIF_LIB := MOTIF_LIB_DIR_DEFAULT
        arch_spec_error := "Could not match SRT_ARCH: $(SRT_ARCH)"
    endif
    endif
    endif
    endif
    endif
    endif
    endif
    endif
else
    MOTIF_LIB:=$(MOTIF_LIB_DIR)
endif

ifeq (YES,$(MOTIF_STATIC))
  ifeq (Linux2,$(SRT_ARCH))
    MOTIF_LIB_NAME := -Wl,-Bstatic $(MOTIF_LIB_NAME_DEFAULT) -Wl,-Bdynamic
  endif
  ifneq (,$(findstring IRIX6,$(SRT_ARCH)))
    MOTIF_LIB_NAME := -Wl,-B,static $(MOTIF_LIB_NAME_DEFAULT) -Wl,-B,dynamic
  endif
else
  MOTIF_LIB_NAME:= $(MOTIF_LIB_NAME_DEFAULT)
endif

arch_spec_depends:=X11

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS += -I$(MOTIF_INC)
override LDFLAGS += -L$(MOTIF_LIB)
override LOADLIBES += $(MOTIF_LIB_NAME)

ifndef NO_AUTO_EXT_DEPENDS
  include $(foreach var,$(arch_spec_depends), SoftRelTools/arch_spec_$(var).mk)
endif

endif
