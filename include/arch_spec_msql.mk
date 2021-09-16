#
# arch_spec_msql.mk
#
# MSQL_LIB and MSQL_INC are environment variables
#   containing (or optionally loaded with) the
#   location of the msql files on the local machine.
#
# Liz Sexton-Kennedy, 26-Jun-98

extpkg:=msql

MSQL_DIR_DEFAULT := /usr/local

ifndef MSQL_DIR
    arch_spec_warning:=\
    "Using default value MSQL_DIR = $(MSQL_DIR_DEFAULT)"
    MSQL_DIR = $(MSQL_DIR_DEFAULT)
endif
ifndef MSQL_INC
    MSQL_INC = $(MSQL_DIR)/include
endif
ifndef MSQL_LIB
    MSQL_LIB = $(MSQL_DIR)/lib
endif

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS  += -I$(MSQL_INC)
override LDFLAGS   += -L$(MSQL_LIB)
override LOADLIBES += -lmsql
