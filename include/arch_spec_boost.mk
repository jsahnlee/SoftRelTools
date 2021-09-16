# arch_spec_boost.mk
#
# Support for use of the boost library
# http://www.boost.org
#
# This file must be included *before* standard.mk
#

extpkg := boost
BOOST_DIR_DEFAULT := /usr/local

ifndef BOOST_DIR
	arch_spec_warning:=\
	"Using default value BOOST_DIR = $(BOOST_DIR_DEFAULT)"
	BOOST_DIR = $(BOOST_DIR_DEFAULT)
endif
ifndef BOOST_INC
	BOOST_INC = $(BOOST_DIR)/boost
endif
ifndef BOOST_LIB
	BOOST_LIB = $(BOOST_DIR)/lib
endif


# It would be nice to pick up debug or optimized by default
BOOST_LIBES = -lboost_regex
#BOOST_LIBES = -lboost_regex_debug

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS  += -I$(BOOST_INC)
override LDFLAGS   += -L$(BOOST_LIB)
override LOADLIBES += $(BOOST_LIBES)
