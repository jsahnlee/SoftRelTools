CPP:= bc++
CXX:= bc++
CC:= bc++
AR:= ar
SHAREDAR:=bc++


PICFLAG:= -fpic
ARFLAGS = r

override SHAREDARFLAGS = -shared
override SHAREDAROFLAG = -o

INLINE_DEP_CAPABLE=no

override DEFECTS  += -DDEFECT_NO_IOSTREAM_NAMESPACES

# Support for various qualifiers

ifeq ($(findstring default,$(SRT_QUAL)),default)
    override CXXFLAGS += -v
    override CCFLAGS += -v
endif

ifeq ($(findstring noopt,$(SRT_QUAL)),noopt)
    override CXXFLAGS += -O0
    override CCFLAGS += -O0
endif

ifeq ($(findstring debug,$(SRT_QUAL)),debug)
    override CXXFLAGS += -v
    override CCFLAGS += -v
endif

ifeq ($(findstring maxopt,$(SRT_QUAL)),maxopt)
    override CXXFLAGS += -O2
    override CCFLAGS += -O2
endif

# variables for backward compatibility
override CPPMFLAGS += -M

-include SRT_$(SRT_PROJECT)/special/compilers/BCC.mk
-include SRT_SITE/special/compilers/BCC.mk
