# arch_spec_pythia.mk
#
#   LUND_LIB  is the  environment variable
#   containing (or optionally loaded with) the
#   location of the LUND files on the local machine.
#
# Original version:
# Chris Green initial version 12 Dec 98

extpkg := pythia

arch_spec_warning := 
LUND_DIR_DEFAULT = /usr/products/lund/v6_115
ifndef LUND_DIR
    arch_spec_warning:=\
    "Using default value LUND_DIR = $(LUND_DIR_DEFAULT)"
   LUND_DIR = $(LUND_DIR_DEFAULT)
endif

arch_spec_warning +=" Linking to PYTHIA. You may resolve links to STRUCTM and PDFSET with the CERN" >&2 )
arch_spec_warning +=" PDFLIB or with the dummy routines in $(LUND_DIR)/lib/pdfdum.o" >&2 )

LUND_LIB = $(LUND_DIR)/lib/liblund.a

include SoftRelTools/specialize_arch_spec.mk

override LOADLIBES += $(LUND_LIB)
