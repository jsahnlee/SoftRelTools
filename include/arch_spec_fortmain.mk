# arch_spec_fortmain.mk
#
# Architecture/site specific makefile fragment
#   for inclusion by packages that use a fortran main program with
#   g++ for linking.  
#
# include this to get LOADLIBES extended as needed.  FLOADLIBES is used in
# front of LOADLIBES in the link file for a mixed fortran/C++ link.  This
# file must be followed by an include of 
# arch_spec_f77.mk
#
# Original version:
# Bob Jacobsen, Oct 95

FORTMAIN_FLOADLIBES :=

ifneq (,$(findstring AIX,$(BFARCH)))
# g++ may or may not provide these, esp. crt0.o
    FORTMAIN_FLOADLIBES := /lib/crt0.o /usr/lib/glink.o
endif
ifneq (,$(findstring OSF,$(BFARCH)))
   FORTMAIN_FLOADLIBES := /usr/lib/cmplrs/fort/for_main.o 
endif

include SoftRelTools/specialize_arch_spec.mk

override FLOADLIBES += $(FORTMAIN_FLOADLIBES)
