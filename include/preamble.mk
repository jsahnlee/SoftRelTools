ifndef PACKAGE
    ifndef PACKAGE_fromabove
        PACKAGE:=$(shell srt_int_info --name 2>/dev/null)
        PACKAGE_fromabove=$(PACKAGE)
        export PACKAGE_fromabove
    else
        PACKAGE:=$(PACKAGE_fromabove)
    endif
endif

ifeq ("$(SRT_PRIVATE_CONTEXT)",".")
    ifneq ($(VERBOSE),)
        debug:=$(shell echo "Overriding SRT_LOCAL=. setting" >&2 )
    endif
    SRT_PRIVATE_CONTEXT:=$(shell srt_int_info --local 2>/dev/null)
   
    export SRT_PRIVATE_CONTEXT
    SRT_LOCAL=$(SRT_PRIVATE_CONTEXT)
    export SRT_LOCAL
    extra_include_flags=-I$(SRT_PRIVATE_CONTEXT)/include
endif

ifndef BIN_DIR
    BIN_DIR=$(SRT_PRIVATE_CONTEXT)/bin/$(SRT_SUBDIR)/
endif

ifndef TBIN_DIR
    TBIN_DIR=$(SRT_PRIVATE_CONTEXT)/bin/$(SRT_SUBDIR)/
endif

ifndef LIB_DIR
    LIB_DIR=$(SRT_PRIVATE_CONTEXT)/lib/$(SRT_SUBDIR)/
endif

ifndef SHLIB_DIR
    SHLIB_DIR=$(SRT_PRIVATE_CONTEXT)/lib/$(SRT_SUBDIR)/
endif

# standard directories
bindir=$(BIN_DIR)
tbindir=$(TBIN_DIR)
libdir=$(LIB_DIR)
shlibdir=$(SHLIB_DIR)
tmpdir=$(SRT_PRIVATE_CONTEXT)/tmp/$(SRT_SUBDIR)/$(PACKAGE)/
mandir=$(SRT_PRIVATE_CONTEXT)/man/
docdir=$(SRT_PRIVATE_CONTEXT)/doc/
curdir=$(shell pwd)/
o_dir=$(tmpdir)
workdir=$(tmpdir)
# sort has the side effect of removing duplicates, which is why it
# is used here.
bin_dirlist=$(sort $(bindir) $(tbindir))
lib_dirlist=$(sort $(libdir) $(shlibdir))
dirlist=$(bin_dirlist) $(lib_dirlist) $(tmpdir)

# Backward compatability
# This could be an environment variable. It is here because it was not
# an environment variable in the original, and because of namespace isssues.
EXPERIMENT = $(SRT_PROJECT)
CURPKG=$(PACKAGE)
export SRT_TOP=$(SRT_PRIVATE_CONTEXT)
workdir_o=$(staticlib_o_dir)

# Just in case someone needs to check:
SRT_VERSION=2

-include SRT_$(SRT_PROJECT)/special/preamble.mk
-include SRT_SITE/special/preamble.mk
