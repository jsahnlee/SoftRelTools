# arch_spec_geant.mk
#
# GEANT_LIB and GEANT_INC are environment variables
#   containing (or optionally loaded with) the
#   location of the GEANT files on the local machine.
#
# Original version:
# Robert Harris, Dec 20 96
# Robert Harris, Jan 8  97, point GEANT at upgrade disk
# Robert Harris, Jun 5  97, point GEANT at official area.

extpkg := geant
GEANT_DIR_DEFAULT := /usr/local

ifndef GEANT_DIR
    arch_spec_warning:=\
    "Using default value GEANT_DIR = $(GEANT_DIR_DEFAULT)"
    GEANT_DIR = $(GEANT_DIR_DEFAULT)
endif
ifndef GEANT_INC
    ifneq (,$(findstring v3_21_12,$(GEANT_DIR)))
      GEANT_INC = $(GEANT_DIR)/src/geant321
    else
      GEANT_INC = $(GEANT_DIR)/src
    endif
endif
ifndef GEANT_LIB
    GEANT_LIB = $(GEANT_DIR)/lib
endif

GEANT_LOADLIBES := -lgeant.g
ifneq (,$(findstring AIX,$(SRT_ARCH)))
    GEANT_LOADLIBES := -lgeant
endif

# Use debug if available, 321 name if available
ifneq (,$(wildcard $(GEANT_DIR)/lib/libgeant321_g.a ))
    GEANT_LOADLIBES := -lgeant321_g
else
ifneq (,$(wildcard $(GEANT_DIR)/lib/libgeant321.g.a ))
    GEANT_LOADLIBES := -lgeant321.g
else
ifneq (,$(wildcard $(GEANT_DIR)/lib/libgeant_g.a ))
    GEANT_LOADLIBES := -lgeant_g
else
ifneq (,$(wildcard $(GEANT_DIR)/lib/libgeant.g.a ))
    GEANT_LOADLIBES := -lgeant.g
else
ifneq (,$(wildcard $(GEANT_DIR)/lib/libgeant321.a ))
    GEANT_LOADLIBES := -lgeant321
else
ifneq (,$(wildcard $(GEANT_DIR)/lib/libgeant.a ))
    GEANT_LOADLIBES := -lgeant
endif
endif
endif
endif
endif
endif

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS  += -I$(GEANT_INC) -DCERNLIB_TYPE
override LDFLAGS   += -L$(GEANT_LIB)
override LOADLIBES += $(GEANT_LOADLIBES)
