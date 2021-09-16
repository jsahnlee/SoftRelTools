# This file is included by both GNUmakefile.main and standard.mk
# Any common functionality should go here.

all_deps=codegen include lib bin
extra_stages=test tbin
all_stages=$(all_deps) $(extra_stages)

-include SRT_$(SRT_PROJECT)/special/common.mk
-include SRT_SITE/special/common.mk
