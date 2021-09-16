# arch_spec_ObjectSpace.mk

extpkg:=ObjectSpace
OSPACE_DIR_DEFAULT := /afs/cern.ch/sw/lhcxx/specific/@sys/ObjectSpace/pro

ifndef OSPACE_DIR
    arch_spec_warning:=\
    "Using default value OSPACE_DIR = $(OB_DEFAULT)"
    OSPACE_DIR := $(OSPACE_DIR_DEFAULT)
endif
STL_DIR = $(OSPACE_DIR)/ospace/stl
STD_DIR = $(OSPACE_DIR)/ospace/std

# Some architecture specifics

ifneq (,$(findstring Linux2,$(BFARCH)))
    NoObjectSpace := True
    arch_spec_error:="Not available on platform $(BFARCH)"
endif

ifneq (,$(findstring Sun,$(BFARCH)))
    OBJECTSPACE_CCDEFS=-DOS_SOLARIS_2_5 -DOS_NEW_CHECK -DOS_STL_ASSERT -DOS_NO_WSTRING -DOS_NO_ALLOCATORS
endif


include SoftRelTools/specialize_arch_spec.mk

ifndef NoObjectSpace
override CPPFLAGS  += -I$(OSPACE_DIR) -I$(STL_DIR) -I$(STD_DIR) $(OBJECTSPACE_CCDEFS)
override LDFLAGS   += -L$(OSPACE_DIR)/lib
override LOADLIBES += -lospace
endif

