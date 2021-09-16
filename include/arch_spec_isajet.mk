# arch_spec_geant.mk
#
# Architecture/site specific makefile fragment
#   for inclusion by packages that use ISAJET
#
#   ISAJET_LIB  is the  environment variable
#   containing (or optionally loaded with) the
#   location of the ISAJET files on the local machine.
#
# Original version:
# Marjorie Shapiro Dec 12 1997:  Initial Version

extpkg := ISAJET

ifndef ISAJET_DIR
    arch_spec_warning:=\
    "Using default value ISAJET_DIR = $(ISAJET_DIR_DEFAULT)"
    ISAJET_DIR = /usr/products/isajet/v7_31
endif

ISAJET_LIB = $(ISAJET_DIR)

include SoftRelTools/specialize_arch_spec.mk

override LOADLIBES += $(ISAJET_LIB)/isajet.a
