# arch_spec_cmsim.mk

extpkg:=cmsim

arch_spec_warning:="Using CMS_PATH = $(CMS_PATH) and CMS_VER = $(CMS_VER)"

CMSIM_FCFLAGS = -I$(CMS_PATH)/cmsim/$(CMS_VER)/cmsim \
    -DCERNLIB_TYPE -DLOGTIT -DCMS_TYPE \
    -DCERNLIB_$(ARCH) -DCMS_VERSION -DCMS_GV321 -DCMS_CMAIN \
    -DCMS_CPP -DCMS_CZ -DCMS_BATCH
CMSIM_FCPPMFLAGS = -I$(CMS_PATH)/cmsim/$(CMS_VER)/cmsim \
    -DCERNLIB_TYPE -DLOGTIT -DCMS_TYPE \
    -DCMS_VERSION -DCMS_GV321 -DCMS_CMAIN \
    -DCMS_CPP -DCMS_CZ -DCMS_BATCH
CMSIM_LDFLAGS   = -L$(CMS_PATH)/cmsim/$(CMS_VER)/lib/$(CMS_SYS)
CMSIM_LOADLIBES = -ldetc -lecal -lutil -ldetc -lgeant321 -ljetset74 

include SoftRelTools/specialize_arch_spec.mk

override FCFLAGS += $(CMSIM_FCFLAGS)
override FCPPMFLAGS += $(CMSIM_FCPPMFLAGS)
override LDFLAGS   += $(CMSIM_LDFLAGS)
override LOADLIBES += $(CMSIM_LOADLIBES)
