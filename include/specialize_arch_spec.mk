# This file provides the correct behavior for arch_spec_*.mk files.
# The inputs are extpkg (required) and (optionally) arch_spec_warning 
# and arch_spec_error

-include SRT_$(SRT_PROJECT)/special/arch_spec_$(extpkg).mk
-include SRT_SITE/special/arch_spec_$(extpkg).mk

ifdef VERBOSE
    MESSAGE := $(shell echo "included arch_spec_$(extpkg).mk" >& 2)
    ifdef arch_spec_warning
        MESSAGE := $(shell echo "arch_spec_$(extpkg) warning: $(arch_spec_warning)">& 2)
    endif
    ifdef arch_spec_error
        MESSAGE := $(shell echo "arch_spec_$(extpkg) error: $(arch_spec_error)" >& 2)
    endif
endif
