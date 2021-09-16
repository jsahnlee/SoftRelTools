# arch_spec_Python.mk
#
# Architecture/site specific makefile fragment
#   for inclusion by packages that use Python.
#
# PYTHON_LIB and PYTHON_INC are environment variables
#   containing (or optionally loaded with) the
#   location of the Python files on the local machine.
#
# Original version:
# Bob Jacobsen, Dec 94
# R. Harris Nov 97: CDF Python library organization if EXPERIMENT contains CDF
# s. snyder Nov 98: Fix settings of PYTHON_INC.

extpkg := Python

PYTHON_INC_DEFAULT :=  -I/usr/local/include
PYTHON_LIB_DEFAULT := /usr/local/lib

ifneq (,$(findstring Linux2,$(SRT_ARCH)))
    PYTHON_INC_DEFAULT := -I/usr/include
    PYTHON_LIB_DEFAULT := /usr/lib
endif

ifneq (,$(findstring CYGWIN32,$(SRT_ARCH)))
    PYTHON_INC_DEFAULT := -I/usr/include
    PYTHON_LIB_DEFAULT := /usr/lib
endif

ifndef PYTHON_DIR

    ifndef PYTHON_INC
        arch_spec_warning:=\
        "Using default value PYTHON_INC = $(PYTHON_INC_DEFAULT)"
        PYTHON_INC = $(PYTHON_INC_DEFAULT)
    else
    PYTHON_DIR=used_explicit
    endif

    ifndef PYTHON_LIB
        arch_spec_warning:=\
        "Using default value PYTHON_LIB = $(PYTHON_LIB_DEFAULT)"
        PYTHON_LIB = $(PYTHON_LIB_DEFAULT)
    else
        PYTHON_DIR=used_explicit
    endif

else

    ifndef PYTHON_INC
        PYTHON_INC = -I$(PYTHON_DIR)/include/python1.4 -I$(PYTHON_DIR)
    endif

    ifndef PYTHON_LIB
        PYTHON_LIB = $(PYTHON_DIR)/lib
    endif

#jfa D0 defaults to be set in SRT_D0
#  ifneq (,$(findstring D0,$(EXPERIMENT)))
#    # D0's python installation
#    PYTHON_INC = -I$(PYTHON_DIR)/include -I$(PYTHON_DIR)/lib/python1.4/config
#    PYTHON_LIB = $(PYTHON_DIR)/lib/python1.4/config
#  endif

endif

PYTHON_LINK_LIBRARIES:=-lModules -lPython -lModules -lPython -lObjects -lParser

ifneq (,$(findstring OSF,$(SRT_ARCH)))
    PYTHON_LINK_LIBRARIES += -lm
endif

ifneq (,$(findstring SunOS5,$(SRT_ARCH)))
    PYTHON_LINK_LIBRARIES += -lm
endif

ifneq (,$(findstring HP-UX,$(SRT_ARCH)))
    PYTHON_LINK_LIBRARIES += -lm
endif

ifndef PYTHON_DIR
    arch_spec_error:="Python not added because PYTHON_DIR not set."
endif

include SoftRelTools/specialize_arch_spec.mk

ifdef PYTHON_DIR
    override CPPFLAGS  += $(PYTHON_INC)
    override LDFLAGS   += -L$(PYTHON_LIB)
    override LOADLIBES += $(PYTHON_LINK_LIBRARIES)
endif
