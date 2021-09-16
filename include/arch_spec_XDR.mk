# arch_spec_XDR.mk
#
# Architecture/site specific makefile fragment
#   for inclusion by packages that use XDR (usually part of RPC).
#
# Original version:
# Bob Jacobsen, Dec 94

extpkg := XDR

XDR_LDFLAGS :=

ifneq (,$(findstring SunOS5,$(BFARCH)))
    XDR_LDFLAGS := -lnsl
endif

include SoftRelTools/specialize_arch_spec.mk

override LDFLAGS  += $(XDR_LDFLAGS)
