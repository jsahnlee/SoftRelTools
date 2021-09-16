# arch_spec_Inventor.mk
#
# Set up for:  GL, Inventor, and Hepvis
# 
# Original version
# Joe Boudreau March 1998.
# Lucas Taylor   4 Dec 1998   
# Modified for CMS (especially on Sun)
# Move Motif stuff to:  arch_spec_X11.mk

extpkg := Inventor

ifndef ARCH_SPEC_INVENTOR
ARCH_SPEC_INVENTOR = ONCE

OGL_DIR_DEFAULT = /opt/opengl
OIV_DIR_DEFAULT = /afs/cern.ch/sw/lhcxx/specific/@sys/OpenInventor/pro
HEPVIS_DIR_DEFAULT = /afs/cern.ch/user/c/cmscan/local_Hepvis

INV_CPPFLAGS = 
INV_LDFLAGS = 
INV_LOADLIBES =

arch_spec_warning:=
ifndef OGL_DIR
    arch_spec_warning +=\
    "Using default value OGL_DIR += $(OGL_DIR_DEFAULT). "
    OGL_DIR = $(OGL_DIR_DEFAULT)
endif
ifndef OIV_DIR
    arch_spec_warning +=\
    "Using default value OIV_DIR += $(OIV_DIR_DEFAULT). "
    OIV_DIR = $(OIV_DIR_DEFAULT)
endif
ifndef HEPVIS_DIR
    arch_spec_warning +=\
    "Using default value HEPVIS_DIR += $(HEPVIS_DIR_DEFAULT). "
    HEPVIS_DIR = $(HEPVIS_DIR_DEFAULT)
endif
ifndef OIVLIBDIR
    arch_spec_warning +=\
    "Using default value OIV_LIB += $(OIV_DIR)/lib."
     OIV_LIB    = $(OIV_DIR)/lib
else 
     OIV_LIB    = $(OIVLIBDIR)	
endif

OGL_INC    =$(OGL_DIR)/include
OGL_LIB    =$(OGL_DIR)/lib

OIV_INC    =$(OIV_DIR)/include


ifneq ($(HEPVISINC),)
  HEPVIS_INC = $(HEPVIS_DIR)/include
else
  HEPVIS_INC = $(HEPVISINC)
endif

ifneq ($(HEPVISLIB),)
  HEPVIS_LIB = $(HEPVISLIB)
else
  HEPVIS_LIB =$(HEPVIS_DIR)/lib
endif

INV_CPPFLAGS = -I$(OGL_INC) -I$(OIV_INC) -I$(HEPVIS_INC)
INV_LDFLAGS =  -L$(OGL_LIB) -L$(OIV_LIB) -L$(HEPVIS_LIB)

INV_LOADLIBES = -lHEPVis -lInventorXt -lInventor -limage 

#  TGS Inventor for KAI has a circular dependency => we need it twice
ifneq (,$(findstring KCC,$(SRT_CXX)))
    INV_LOADLIBES += -lInventor     
endif

INV_LOADLIBES += -lGLU -lGL  

arch_spec_depends:=Motif X11

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS  += $(INV_CPPFLAGS)
override LDFLAGS   += $(INV_LDFLAGS)
override LOADLIBES += $(INV_LOADLIBES)

ifndef NO_AUTO_EXT_DEPENDS
  include $(foreach var,$(arch_spec_depends), SoftRelTools/arch_spec_$(var).mk)
endif

endif
