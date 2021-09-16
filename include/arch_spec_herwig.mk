# arch_spec_herwig.mk
#
# Architecture/site specific makefile fragment
#   for inclusion by packages that use HERWIG
#
#   HERWIG_LIB  is the  environment variable
#   containing (or optionally loaded with) the
#   location of the HERWIG files on the local machine.
#
# Original version:
# Marjorie Shapiro Nov 22 1998:  Initial Version
#

extpkg := herwig

ifndef HERWIG_DIR
    arch_spec_warning:=\
    "Using default value HERWIG_DIR = $(HERWIG_DIR_DEFAULT)"
    HERWIG_DIR = /usr/products/herwig/v5_9
endif

HERWIG_LIB = $(HERWIG_DIR)/lib

include SoftRelTools/specialize_arch_spec.mk

override LOADLIBES += $(HERWIG_LIB)/libherwig.a
