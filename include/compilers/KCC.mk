CPP:= KCC
CXX:= KCC
CC:= KCC --c
AR:= KCC
SHAREDAR:=$(AR)

override CPPFLAGS += -D__KAI_STRICT -D__STRICT_ANSI__
override CXXCFLAGS += --no_implicit_include

ifeq ($(SRT_ARCH),Linux2)
    override CXXFLAGS += --backend -m486
endif

ifneq (,$(findstring IRIX6,$(SRT_ARCH)))
    override CXXFLAGS += -n32
    override LDFLAGS += -n32 -Wl,-multigot
    override CCFLAGS += -n32
    override CPPMFLAGS += -n32
    ARFLAGS += -n32
endif

ifeq ($(SRT_ARCH),OSF1V4)
    override LDFLAGS += --backend -taso
endif

override CXXFLAGS += --strict --one_per

# Note the use of '=' instead of ':='
CXXFLAGS_BINARY = $(filter-out --one_per,$(CXXFLAGS))

PICFLAG:=
ARFLAGS += --one_per
AROFLAG:=-o

override SHAREDARFLAGS = $(ARFLAGS)
override SHAREDAROFLAG = $(AROFLAG)

# Inline deps are turned off until I can workaround the recompiling problem
INLINE_DEP_CAPABLE=
INLINE_DEP = --output_dependencies $(dir $@)/$(basename $(notdir $<)).d
STANDALONE_DEP= -M $< > $(dir $@)/$(basename $(notdir $<)).d
CSTANDALONE_DEP=$(STANDALONE_DEP)

override DEFECTS += -D__STANDARD_CPLUSPLUS
override DEFECTS += -DDEFECT_STANDARD_CPLUSPLUS
override DEFECTS += -DDEFECT_NO_EXPLICIT_QUALIFICATION

# JFA: Is this really correct? It was in the old SoftRelTools
ifeq ($(SRT_ARCH),OSF1V4)
    override DEFECTS += -DDEFECT_RECL_WORDS
endif

# Support for various qualifiers
ifeq ($(findstring default,$(SRT_QUAL)),default)
    override CXXFLAGS += +K0
    override CCFLAGS += +K0
endif

ifeq ($(findstring noopt,$(SRT_QUAL)),noopt)
    override CXXFLAGS += -O0
    override CCFLAGS += -O0
endif

ifeq ($(findstring debug,$(SRT_QUAL)),debug)
    override CXXFLAGS += -g
    override CCFLAGS += -g
endif

ifeq ($(findstring maxopt,$(SRT_QUAL)),maxopt)
    override CXXFLAGS += +K3
    override CCFLAGS += +K3
endif

# variables for backward compatibility
override CPPMFLAGS += -M

-include SRT_$(SRT_PROJECT)/special/compilers/KCC.mk
-include SRT_SITE/special/compilers/KCC.mk
