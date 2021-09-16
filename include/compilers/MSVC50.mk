# Warning! NT flags are significantly different from the Unix platforms
#
# Defects
#

override DEFECTS  += -D__STANDARD_CPLUSPLUS -DDEFECT_STANDARD_CPLUSPLUS
override DEFECTS  += -DDEFECT_NO_VIRTUAL_COVARIANCE
override DEFECTS  += -DDEFECT_TYPE_INFO_GLOBAL
override DEFECTS  += -DDEFECT_CERNLIB_UPPERCASE
override DEFECTS  += -DDEFECT_NO_MEMBER_TEMPLATES
override DEFECTS  += -DDEFECT_NO_DELETE_CONST
override DEFECTS  += -DDEFECT_CMATH_NOT_STD

#
# Work around for some weirdnesses in the standard library
# and how MSVC does C++. The extra quotes on the for def are
# required because the shell removes one everytime through. Sigh.
#

override CXXDEFECTS = -Dmin=_cpp_min
override CXXDEFECTS  += -Dmax=_cpp_max

#
# Standard defines
#
#  Note that _MT must be defined to bring in the multi-threaded versions
# of some of the libraries...
#

#-D_DEBUG
override DEFINE_FLAGS := -DWIN32 -D_DEBUG -D_WINDOWS -D_WIN32_WINNT=0x0400 -D_M_IX86 -DDATAREP_LITTLE_ENDIAN -D_MT -DD0

#
# Standard debug flags for the C/C++ compiler:
#           Od -- no optimizations
#           MTd -- Use the multithreaded dll, debug version
#           nologo -- We hate MS, after all, right?
#           GX -- turn on exceptions processing
#           Z7 -- Put all debug info in the .obj file
#           Zi -- Put all debug info in the program database
#           Gm -- Enable minimal rebuild feature
#           W3 -- Warnings level 3
#           YX -- Use precompiled headers.
#           GR -- Turn RTTI on
#           Fd -- Location of the program database. This is a filename 
#                 that must be translated, so we don't pass it directly 
#                 through...
#           TP -- Force source file to be C++.
#			nodefaultlib -- Tell the linker to ignore the libraries
#				specified in the obj files. Instead we will force load
#				our own.
#	    Ob1 -- Inline only functions that are marked "inline" rather than anything
#			suitable (Ob2).
#	    O2 -- Optimize for speed (rather than size).
#
#  Note -- the "-NTxxxx" tells the srt_ntcc script to pass the option 
#          straight through to the command line as "/xxxx" 
#          (where xxxx can be any length).
#

override qual_flags=
#-NTMTd
ifeq ($(SRT_QUAL),default)
    override qual_flags = -NTOd -NTMTd -NTZi -Fd$(libdir)/$(CURPKG).pbd 
endif

ifeq ($(SRT_QUAL),maxopt)
    override qual_flags = -NTOb1 -NTO2
endif

override base_build = $(qual_flags) -NTnologo -NTGX -NTGm -NTW3 -NTGR -NTZm400 -FI$(firstword $(wildcard $(SRT_PRIVATE_CONTEXT)/SoftRelTools/nt/msvc_pragmas.h $(SRT_PUBLIC_CONTEXT)/SoftRelTools/nt/msvc_pragmas.h))

override CPPFLAGS += $(DEFINE_FLAGS)
override CXXFLAGS += $(base_build) $(CXXDEFECTS)
override CCFLAGS  += $(base_build)

#
# Do the preprocessing correctly
#

override CPPMFLAGS := -M

#
# Flags for the linker
#
#           nologo -- Don't print out logo
#
# Because different libs have been built with different settings of the compiler, we have to make sure that
# we only pull in those libraries that are approved: the static link, multi-threaded libraries. All the
# rest we explicitly disallow.
#
# Also, make sure the subsystem is built correctly!
#

#  -NTLnodefaultlib:libcmt.lib \
override bad_libs= \
  -NTLnodefaultlib:libc.lib \
  -NTLnodefaultlib:libcd.lib \
  -NTLnodefaultlib:libcmtd.lib \
  -NTLnodefaultlib:msvcrt.lib 
  -NTLnodefaultlib:msvcrtd.lib

#  -NTLnodefaultlib:libcpmt.lib \
override bad_libs += \
  -NTLnodefaultlib:libcp.lib \
  -NTLnodefaultlib:libcpd.lib \
  -NTLnodefaultlib:libcpmtd.lib \
  -NTLnodefaultlib:msvcprt.lib \
  -NTLnodefaultlib:msvcprtd.lib

override bad_libs += \
  -NTLnodefaultlib:libci.lib \
  -NTLnodefaultlib:libcid.lib \
  -NTLnodefaultlib:libcimt.lib \
  -NTLnodefaultlib:libcimtd.lib \
  -NTLnodefaultlib:msvcirt.lib \
  -NTLnodefaultlib:msvcirtd.lib

override win32_libs = \
  ws2_32.lib \
  kernel32.lib \
  user32.lib \
  gdi32.lib \
  winspool.lib \
  comdlg32.lib \
  advapi32.lib \
  shell32.lib \
  ole32.lib \
  oleaut32.lib \
  uuid.lib \
  odbc32.lib \
  odbccp32.lib


#
# The actual commands
#
#  Note -- since we use gcc for dependency generation, we have to pass it some
# special flags to make it look like MSVC so it seems to take the same course
# as MSVC's cl does (i.e. those flags should not be in CPPM or CPPFlags).
#

CC := srt_ntcc
CXX := srt_ntcc
CPP := gcc -E -U__GNUG__ -D_MSC_VER=1100 -nostdinc -isystem /msvcinc $(DEFINE_FLAGS)
LD := echo "*********WARNING: LD NOT SUPPORTED ON THIS ARCHITECTURE"
override LDFLAGS += -NTLnologo $(bad_libs) $(win32_libs)
AR := srt_ntlib
override ARFLAGS := r
SHAREDAR := srt_ntlib
override SHAREDARFLAGS := $(ARFLAGS)
override DEFINES  += -DNT_MSVCPP

STANDALONE_DEP= -M $< > $(dir $@)/$(basename $(notdir $<)).d
CSTANDALONE_DEP=$(STANDALONE_DEP)
