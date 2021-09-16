# arch_spec_orbacus.mk
#
# Support for idl using Orbacus
#
# This file must be included *before* standard.mk!
#
# For documentation, see SoftRelTools/doc/orbacus-instructions.

# all target is included at top so that all remains the default target.
all:

STUBCPPFILES := $(addprefix $(workdir),$(notdir $(patsubst %.idl,%.cpp,$(IDLFILES))))
SKELCPPFILES := $(addprefix $(workdir),$(notdir $(patsubst %.idl,%_skel.cpp,$(IDLFILES))))
codegen:$(STUBCPPFILES)

idl_dirs=$(addprefix $(SRT_PRIVATE_CONTEXT)/,$(sort $(dir $(IDLFILES)))) \
    $(addprefix $(SRT_PUBLIC_CONTEXT)/,$(sort $(dir $(IDLFILES))))

vpath %.cpp $(workdir)
vpath %.idl $(idl_dirs)
override LDFLAGS += -L$(ORBACUS_DIR)/lib
override CPPFLAGS += -I$(ORBACUS_DIR)/include
override CPPFLAGS += -I$(workdir)
override LOADLIBES += -lOB

ifndef IDLHSUFFIX
    IDLHSUFFIX=.hpp
endif

IDLINCLUDES=$(addprefix -I,$(idl_dirs))
IDL=idl
IDLFLAGS=$(CPPFLAGS) --c-suffix .cpp --h-suffix $(IDLHSUFFIX) $(IDLINCLUDES)

# Macro for post-processing cpp files to make them compatible with KCC
define postprocess_cpp
test -f $@ && \
sed -e 's:assert(o):assert(o != 0):g' $@ > \
$(workdir)srt_idl_tmp.$$$$ ; \
mv $(workdir)srt_idl_tmp.$$$$ $@
endef

# There seems to be no standard way for dealing with dependencies
# on idl files that include other files. Invent one...
define idl_generate_depends
cpp -M $(CPPFLAGS) $(IDLINCLUDES) $< > $(workdir)srt_idld_inc_tmp.$$$$ ;\
for file in `cat $(workdir)srt_idld_files_tmp.$$$$` ; \
    do \
        sed -e "s%.*:%$$file:%g" $(workdir)srt_idld_inc_tmp.$$$$  | sed -e 's%//%/%g ' >> $(workdir)$(notdir $<)d; \
    done
endef

# Dependency files for .idl have the suffix .idld
idld_files:=$(wildcard $(workdir)*.idld)
ifdef idld_files
    -include $(wildcard $(workdir)*.idld)
endif

$(workdir)%.cpp: %.idl
	@echo "<**processing idl**> $(<F)"
	$(IDL) $(IDLFLAGS) --file-list $(workdir)srt_idld_files_tmp.$$$$ --output-dir $(workdir) $< ;\
        $(postprocess_cpp) ;\
        $(idl_generate_depends) ;\
        rm -f $(workdir)srt_idld_files_tmp.$$$$ $(workdir)srt_idld_inc_tmp.$$$$


include SoftRelTools/specialize_arch_spec.mk

