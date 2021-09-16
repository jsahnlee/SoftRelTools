# arch_spec_ace.mk
#
# Original version:
# Created by Gordon Watts
#
# Warning: this file violates some SoftRelTools conventions

extpkg := ace

ACE_ROOT_DEFAULT = /d0user/products/ace/IRIXv4_6/ACE_wrappers/build/IRIX6-KCC_3_3

ifndef ACE_ROOT
    arch_spec_warning:=\
    "ACE has not been setup. Using default value ACE_ROOT = $(ACE_ROOT_DEFAULT)"
    ACE_ROOT = $(ACE_ROOT_DEFAULT)
endif

ace_CPPFLAGS = -I$(ACE_ROOT)
ace_LDFLAGS = -L$(ACE_ROOT)/ace 

ace_LOADLIBES = -lACE
ifneq (,$(findstring NT4,$(SRT_ARCH)))
  ace_LOADLIBES = aced.lib
endif

ifneq (,$(findstring OSF,$(SRT_ARCH)))
  ace_LOADLIBES += -lpthread
  ifneq (,$(findstring KCC,$(SRT_CXX)))
    # warning: nested comment is not allowed
    # (one of dec's headers has a nested comment...)
    ace_CXXFLAGS += --diag_suppress 9
  endif

  # Needed on V4.0b in order to get __sigwaitd10 declared.
  ace_CPPFLAGS += -D_REENTRANT

  # On OSF, ace refers to a symbol `__sigwaitd10'.
  # In V4.0b, this is declared, provided that _REENTRANT is defined.
  # But in V4.0, the declaration has gone away.
  # This should really be fixed in the ace sources, but i don't
  # want to rebuild them now.  So do this hack instead: rename
  # __sigwaitd10 to _Psigwait (which is declared in V4.0d).
  ifeq ($(shell uname -rv),V4.0 564)
    # V4.0b -- don't do anything here.
  else
    ace_CPPFLAGS += -D__sigwaitd10=_Psigwait
  endif
endif


# ACE does not build with --strict on for IRIX due to a funny type called
# long long that the OS uses. Bummer.
ifneq (,$(findstring IRIX,$(SRT_ARCH)))
  ace_CPPFLAGS += -D_SGI_SOURCE
  NOSTRICT:=yes
endif

# Same deal on Linux.
ifneq (,$(findstring Linux,$(SRT_ARCH)))
  ace_LOADLIBES += -lpthread
  ace_CPPFLAGS += -D_GNU_SOURCE
  NOSTRICT := yes
endif

include SoftRelTools/specialize_arch_spec.mk


override CPPFLAGS += $(ace_CPPFLAGS)
override CXXFLAGS += $(ace_CXXFLAGS)
override LDFLAGS += $(ace_LDFLAGS)
override LOADLIBES += $(ace_LOADLIBES)

ifdef NOSTRICT
  override CXXFLAGS := $(filter-out --strict,$(CXXFLAGS))
  override CPPFLAGS := $(filter-out -D__KAI_STRICT,$(CPPFLAGS))
  override CPPFLAGS := $(filter-out -D__STRICT_ANSI__,$(CPPFLAGS))
endif  
