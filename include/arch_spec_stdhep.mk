# arch_spec_stdhep.mk
#
# STDHEP_LIB and STDHEP_INC are environment variables
#   containing (or optionally loaded with) the
#   location of the STDHEP files on the local machine.
#
# Original version:
# Marjorie Shapiro Dec 23 1997:  Initial Version

extpkg := stdhep
STDHEP_DIR_DEFAULT := /usr/products/stdhep/v4_00

ifndef STDHEP_DIR
    arch_spec_warning:=\
    "Using default value STDHEP_DIR = $(STDHEP_DIR_DEFAULT)"
    STDHEP_DIR = $(STDHEP_DIR_DEFAULT)
endif
ifndef STDHEP_INC
    STDHEP_INC = $(STDHEP_DIR)/src/inc
endif
ifndef STDHEP_LIB
    STDHEP_LIB = $(STDHEP_DIR)/lib
endif

STDHEP_LOADLIBES := -lstdhep

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS  += -I$(STDHEP_INC)
override LDFLAGS   += -L$(STDHEP_LIB)
override LOADLIBES += $(STDHEP_LOADLIBES)
