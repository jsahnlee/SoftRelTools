# arch_spec_root.mk
#
# Warning: this file violates some SoftRelTools conventions 

extpkg:=root

ROOT_CPPFLAGS := $(shell root-config)



ROOTSYS_DEFAULT := /root-sys-not-defined
ifndef ROOTSYS
    arch_spec_warning:=\
    "Using default value ROOTSYS = $(ROOTSYS_DEFAULT)"
    ROOTSYS = $(ROOTSYS_DEFAULT)
endif

ROOTLIBS  = -lNew -lBase -lRint -lCint -lClib -lCont -lFunc \
            -lGraf -lGraf3d -lHist -lHtml -lMatrix -lMeta -lMinuit -lNet \
            -lPostscript -lProof -lTree -lUnix -lZip
ROOTGLIBS = -lGpad -lGui -lGX11 -lX3d

root_CPPFLAGS = -I$(ROOTSYS)/include
root_LDFLAGS  = -L$(ROOTSYS)/lib

root_LOADLIBES = 
# Linux: don't use ROOT at all with KCC v3.2d
# Linux: don't use libNew.a with either GCC v2.8 or KCC v3.2d
ifneq (,$(findstring Linux,$(BFARCH)))
  ifneq (,$(findstring KCC_3_3,$(SRT_CXX)))
    root_LOADLIBES += $(ROOTLIBS) $(ROOTGLIBS) -lm -ldl
  else
    root_LOADLIBES += $(filter-out -lNew, $(ROOTLIBS) $(ROOTGLIBS) -lm -ldl)
  endif
endif

# IRIX6: don't use libNew.a with either GCC v2.8 or KCC v3.2d
ifneq (,$(findstring IRIX6,$(BFARCH)))
  ifneq (,$(findstring KCC_3_3,$(SRT_CXX)))
    root_LOADLIBES += $(ROOTLIBS) $(ROOTGLIBS) -lm
  else
    root_LOADLIBES += $(filter-out -lNew, $(ROOTLIBS) $(ROOTGLIBS) -lm)
  endif
endif

# OSF1: don't use libNew.a with either GCC v2.8 or KCC v3.2d
ifneq (,$(findstring OSF1,$(BFARCH)))
  ifneq (,$(findstring KCC_3_3,$(SRT_CXX)))
    root_LOADLIBES += $(ROOTLIBS) $(ROOTGLIBS) -lm
  else
    root_LOADLIBES += $(filter-out -lNew, $(ROOTLIBS) $(ROOTGLIBS) -lm)
  endif
endif

# SunOS5: don't use libNew.a with either GCC v2.8 or KCC v3.2d
ifneq (,$(findstring SunOS5,$(BFARCH)))
  ifneq (,$(findstring KCC_3_3,$(SRT_CXX)))
    root_LOADLIBES += $(ROOTLIBS) $(ROOTGLIBS) -lm
  else
    root_LOADLIBES += $(filter-out -lNew, $(ROOTLIBS) $(ROOTGLIBS) -lm)
  endif
endif

#-------------------------------------------------------------------------------
# CINT dictionary (create it with .cxx extention not to mix with the rest of the
# sources) can't be compiled with the standard set of KCC options...
# modify the options to get dictionaries to compile
#-------------------------------------------------------------------------------
ifneq (,$(findstring ROOTSYS,$(CPPFLAGS)))

CINT_FLAGS = $(filter-out --strict -D__KAI_STRICT -D_XOPEN_SOURCE -D_XOPEN_SOURCE_EXTENDED,$(CXXFLAGS) $(CPPFLAGS) $(CXXCFLAGS)) 

CINT_OBJ = $(patsubst %.cxx,%.o,$(CINT_DICT))

cint:   dict lib

dict: $(CINT_INCLUDES)
	@echo \
	rootcint -f $(CINT_DICT) -c -DDEFECT_OLD_STDC_HEADERS -DDEFECT_NO_IOSFWD_HEADER -DDEFECT_OLD_STRINGSTREAM $(CPPFLAGS) $^
	rootcint -f $(CINT_DICT) -c -DDEFECT_OLD_STDC_HEADERS -DDEFECT_NO_IOSFWD_HEADER -DDEFECT_OLD_STRINGSTREAM $(CPPFLAGS) $^
	$(CXX) $(CINT_FLAGS) -c $(curdir)/$(CINT_DICT) -o $(workdir)$(CINT_OBJ)
	$(AR) $(ARFLAGS) $(libdir)$(CINT_LIB) $(workdir)$(CINT_OBJ)
#	$(RM) $(workdir)$(CINT_OBJ)
endif

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS  += $(root_CPPFLAGS)
override LDFLAGS   += $(root_LDFLAGS)
override LOADLIBES += $(root_LOADLIBES)
