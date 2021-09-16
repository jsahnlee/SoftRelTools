templdir  :=  $(SRT_TOP)/$(CURPKG)/templates
scriptdir :=  $(SRT_TOP)/$(CURPKG)/scripts
TEMPLFILEL   := $(foreach templf, $(TEMPLFILES),$(templf):)

$(CODEGENFILES) : $(workdir)%.hh : %.idl $(TEMPLEFILES)
	@echo "<**generating from**> $(<F)"
	$(IDLCOMP) $(IDLINC) -w $(workdir) -t $(TEMPLFILEL) $<

include SoftRelTools/arch_spec_idl.mk
