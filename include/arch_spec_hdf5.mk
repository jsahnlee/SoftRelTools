extpkg := hdf5

include SoftRelTools/specialize_arch_spec.mk

override CPPFLAGS  += $(HDF5_CPPFLAGS)
override LDFLAGS   += $(HDF5_LDFLAGS)
override LOADLIBES += $(HDF5_LINK_LIBRARIES)