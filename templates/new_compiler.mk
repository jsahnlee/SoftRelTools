CPP:= CCC
CXX:= CCC
CC:= CC
AR:= AR
SHAREDAR:=$(AR)

override CPPFLAGS += -D__STRICT_ANSI__
override CXXCFLAGS += --foo

ifeq ($(SRT_ARCH),Linux2)
    override CXXFLAGS += --backend -m486
endif

ifneq (,$(findstring IRIX6,$(SRT_ARCH)))
    override CXXFLAGS += -n32
    override LDFLAGS += -n32
    override CCFLAGS += -n32
    override CPPMFLAGS += -n32
    ARFLAGS += -n32
endif

override CXXFLAGS += --bar

PICFLAG:= -pic
AROFLAG:=-o

override SHAREDARFLAGS = $(ARFLAGS)
override SHAREDAROFLAG = $(AROFLAG)

INLINE_DEP_CAPABLE=yes
INLINE_DEP = --output_dependencies $(dir $@)/$(basename $(notdir $<)).d
STANDALONE_DEP= -M $< > $(dir $@)/$(basename $<).d
CSTANDALONE_DEP=$(STANDALONE_DEP)

override DEFECTS += -D__STANDARD_CPLUSPLUS

# Support for various qualifiers

ifeq ($(SRT_QUAL),default)
    override CXXFLAGS += -g
endif

ifeq ($(SRT_QUAL),maxopt)
    override CXXFLAGS += -O2
endif

# variables for backward compatibility
override CPPMFLAGS += -M

-include SRT_$(SRT_PROJECT)/special/compilers/new_compiler.mk
-include SRT_SITE/special/compilers/new_compiler.mk
