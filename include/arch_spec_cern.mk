# arch_spec_cern.mk
#
#   CERN_INC and CERN_LIB are environment variables
#   containing (or optionally loaded with) the
#   location of the cern files on the local machine.
#
# Original version:
# Robert Harris, Jan 9  97, point cern at upgrade disk

extpkg:=CERN
CERN_DIR_DEFAULT := /usr/local
ifndef CERN_DIR
    arch_spec_warning:=\
    "Using default value CERN_DIR = $(CERN_DIR_DEFAULT)"
    CERN_DIR := $(CERN_DIR_DEFAULT)
endif
ifndef CERN_INC
    CERN_INC = $(CERN_DIR)/inc
endif
ifndef CERN_LIB
    CERN_LIB = $(CERN_DIR)/lib
endif

# deal with CERN 2001 having different libraries (& dependencies)
#arch_spec_warning:= "check for CERN 2001"
ifeq ($(LIBPDFLIB),)
  ifeq ($(shell /bin/ls ${CERN_LIB}/libpdflib.a 2> /dev/null),)
    # CERNLIB 2001 replaces pdflib w/ pdflib804
    LIBPDFLIB = -lpdflib804
  else
    LIBPDFLIB = -lpdflib
  endif
endif

ifeq ($(PAWLIBS),)
  ifeq ($(shell /bin/ls ${CERN_LIB}/liblapack3.a 2> /dev/null),)
    PAWLIBS = -lpawlib
  else
    # CERNLIB 2001 pawlib depends on lapack3 and blas
    # if they exist link them in with pawlib
    PAWLIBS = -lpawlib -llapack3 -lblas
  endif
endif

#if using PACKAGELIST be more picky so we don't get lots of 84,85 warnings
ifdef PACKAGELIST
  CERNPAK :=
  ifneq ($(LINK_pawlib),)
    override CERNPAK += ${PAWLIBS}
  endif
  ifneq ($(LINK_graflib),)
    override CERNPAK += -lgraflib
  endif
  ifneq ($(LINK_grafX11lib),)
    override CERNPAK   += -lgrafX11
    override LINK_X11  += grafX11lib
  endif
  ifneq ($(LINK_pdflib),)
    override CERNPAK += ${LIBPDFLIB}
  endif
  ifneq ($(LINK_packlib),)
    override CERNPAK += -lpacklib
    ifneq (,$(findstring CYGWIN,$(SRT_ARCH)))
      override CERNPAK += -lnt_dummy
      override LDFLAGS += -NTLinclude:__matherr
    endif
  endif
  ifneq ($(LINK_mathlib),)
    override CERNPAK += -lmathlib
  endif
  ifneq ($(LINK_kernlib),)
    override CERNPAK += -lkernlib
  endif
else
 CERNPAK := ${PAWLIBS} -lgraflib -lgrafX11 ${LIBPDFLIB} -lpacklib -lmathlib -lkernlib
endif

ifneq (,$(findstring IRIX6,$(SRT_ARCH)))
  override CERNPAK += -lgen
endif

ifneq (,$(findstring Linux,$(SRT_ARCH)))
    override CERNPAK += -lcrypt -ldl -lnsl
endif

ifneq (,$(findstring SunOS5,$(SRT_ARCH)))
  override CERNPAK += -lsocket -lnsl
endif

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS  += -I$(CERN_INC) -DCERNLIB_TYPE
override LDFLAGS   += -L$(CERN_LIB)
override LOADLIBES += $(CERNPAK)

