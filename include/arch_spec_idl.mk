# arch_spec_idl.mk
#
extpkg:=idl
IDLCOMP:=codegen.pl
IDLINC += -I $(SRT_TOP)/$(CURPKG)/idl

include SoftRelTools/specialize_arch_spec.mk
