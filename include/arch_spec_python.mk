extpkg := python

PYTHON_CPPFLAGS := $(shell python3-config --cflags)
PYTHON_LDFLAGS := $(shell python3-config --ldflags)
# fix me!!! what are libraries for linking python3
PYTHON_LINK_LIBRARIES :=-lModules -lPython -lModules -lPython -lObjects -lParser

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS  += $(PYTHON_CPPFLAGS)
override LDFLAGS   += $(PYTHON_LDFLAGS)
override LOADLIBES += $(PYTHON_LINK_LIBRARIES)