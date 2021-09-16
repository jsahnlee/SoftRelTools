# arch_spec_ocs.mk
#
# OCS_LIB and OCS_INC are environment variables
#   containing (or optionally loaded with) the
#   location of the ocs files on the local machine.
#
# Original version:
# Robert Harris, Dec 17 96

extpkg:=ocs
OCS_DIR_DEFAULT := /usr/local
ifndef OCS_DIR
    arch_spec_warning:=\
    "Using default value OCS_DIR = $(OCS_DIR_DEFAULT)"
    OCS_DIR := $(OCS_DIR_DEFAULT)
endif
ifndef OCS_INC 
    OCS_INC = $(OCS_DIR)/include
endif
ifndef OCS_LIB
    OCS_LIB = $(OCS_DIR)/lib
endif

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS  += -I$(OCS_INC)
override LDFLAGS   += -L$(OCS_LIB)
override LOADLIBES += -locs
