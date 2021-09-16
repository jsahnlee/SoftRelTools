# arch_spec_OBJY.mk
#
# Objectivity support

extpkg:=OBJY
OB_DEFAULT:=/usr/object/iris

ifndef OB
    arch_spec_warning:=\
    "Using default value OB = $(OB_DEFAULT)"
    OB := $(OB_DEFAULT)
endif

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS += -I$(OB)/include
override LDFLAGS += -L$(OB)/lib
override LOADLIBES += -loo

