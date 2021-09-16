# arch_spec_Tcl.mk
#
# Architecture/site specific makefile fragment
#   for inclusion by packages that use Tcl.
#
# TCL_LIB and TCL_INC are environment variables
#   containing (or optionally loaded with) the
#   location of the Tcl files on the local machine.
#
# Original version:
# Bob Jacobsen, Dec 94

extpkg := Tcl

TCL_DIR_DEFAULT = /usr/local

ifndef TCL_DIR
    arch_spec_warning:=\
    "Using default value TCL_DIR = $(TCL_DIR_DEFAULT)"
    TCL_DIR = $(TCL_DIR_DEFAULT)
endif

TCL_INC = $(TCL_DIR)/include
TCL_LIB = $(TCL_DIR)/lib
TCL_LIB_LINK = -ltcl

ifneq (,$(findstring OSF,$(BFARCH)))
  TCL_LIB_LINK += -lm
endif
ifneq (,$(findstring SunOS5,$(BFARCH)))
  TCL+LIB_LINK += -lm
endif
ifneq (,$(findstring HP-UX,$(BFARCH)))
  TCL_LIB_LINK += -lm
endif
ifneq (,$(findstring Linux,$(BFARCH)))
  TCL_LIB_LINK += -ldl
endif

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS  += -I$(TCL_INC) 
override LDFLAGS   += -L$(TCL_LIB)
override LOADLIBES += $(TCL_LIB_LINK)

# Warning! the following is nonstandard arch_spec behavior
ifneq (,$(findstring IRIX6,$(BFARCH)))
    ifeq ($(SRT_CXX),"KCC_3_3")
        override LOADLIBES := $(filter-out -lm,$(LOADLIBES)) -lm
    endif
endif
