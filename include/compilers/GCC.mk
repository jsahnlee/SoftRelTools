CPP:= g++
CXX:= g++
CC:= gcc
AR:= ar
SHAREDAR:=gcc

ifeq ($(findstring insure,$(SRT_QUAL)),insure)
 CPP:= insure
 CXX:= insure
 CC:= insure
endif

override CXXFLAGS += -march=x86_64 -Wall

PICFLAG:= -fpic
ARFLAGS = r

override SHAREDARFLAGS = -shared
override SHAREDAROFLAG = -o

INLINE_DEP_CAPABLE=no
# Find this in the GCC documentation. I dare you.
INLINE_DEP = -Wp,-MD,$(dir $@)/$(basename $(notdir $<)).d
STANDALONE_DEP= -M $< > $(dir $@)/$(basename $(notdir $<)).d
CSTANDALONE_DEP=$(STANDALONE_DEP)

override DEFECTS  += -DDEFECT_NO_IOSTREAM_NAMESPACES

# Support for various qualifiers

ifeq ($(findstring default,$(SRT_QUAL)),default)
    override CXXFLAGS += -g
    override CCFLAGS += -g
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
    override CXXFLAGS += -O2
    override CCFLAGS += -O2
endif

# variables for backward compatibility
override CPPMFLAGS += -M

-include SRT_$(SRT_PROJECT)/special/compilers/GCC.mk
-include SRT_SITE/special/compilers/GCC.mk
