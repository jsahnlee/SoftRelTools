# arch_spec_RW.mk
#
# Architecture/site specific makefile fragment
#   for inclusion by packages that use Rogue Wave libraries.
#
# Original version:
# Bob Jacobsen, Aug 96

extpkg:=RW

ifndef RWROOT
    arch_spec_warning:=\
    "Using default value RWROOT = $(RWROOT)"
    RWROOT = /usr/local/rw
endif
RWSTL = stdlib
RWTOOLS = rogue

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS += -I$(RWROOT)/$(RWSTL)/include -I$(RWROOT)/$(RWTOOLS)/include
override LDFLAGS += -L$(RWROOT)/$(RWSTL)/lib -L$(RWROOT)/$(RWTOOLS)/lib
override LOADLIBES += 

