#debug:=$(shell echo "Included srt super">&2)

local_packages:=$(shell /bin/ls $(SRT_PRIVATE_CONTEXT)/include)

super_dirlist:=$(SRT_PRIVATE_CONTEXT)/super/include/
super_dirlist+=$(SRT_PRIVATE_CONTEXT)/super/tmp/$(SRT_SUBDIR)
super_dirlist+=$(SRT_PRIVATE_CONTEXT)/super/lib/$(SRT_SUBDIR)
super_dirlist+=$(SRT_PRIVATE_CONTEXT)/super/bin/$(SRT_SUBDIR)

super_srt_pkgs:=$(shell pkg=$(SRT_DIST)/releases/$(SRT_BASE_RELEASE)/include/SoftRelTools;\
 test -d $$pkg && echo $$pkg)
super_srt_pkgs+=$(shell pkg=$(SRT_DIST)/releases/$(SRT_BASE_RELEASE)/include/SRT_$(SRT_PROJECT);\
 test -d $$pkg && echo $$pkg)
super_srt_pkgs+=$(shell pkg=$(SRT_DIST)/releases/$(SRT_BASE_RELEASE)/include/SRT_SITE;\
 test -d $$pkg && echo $$pkg)
super_srt_pkgs:=$(filter-out $(addprefix $(SRT_DIST)/releases/$(SRT_BASE_RELEASE)/include/,$(local_packages)),$(super_srt_pkgs))

super_inc_deps:=$(shell /bin/ls $(SRT_DIST)/releases/$(SRT_BASE_RELEASE)/include)
super_inc_deps:=$(filter-out $(local_packages),$(super_inc_deps))
super_inc_deps:=$(addprefix $(SRT_PRIVATE_CONTEXT)/super/include/,$(super_inc_deps))

local_products:=$(shell for p in $(local_packages) ; do test -d $(SRT_DIST)/releases/$(SRT_BASE_RELEASE)/$$p && srt_int_querypkg --products $$p ; done)
local_products:=$(subst $(SRT_PRIVATE_CONTEXT)/,,$(local_products))

super_bin_deps:=$(shell /bin/ls $(SRT_DIST)/releases/$(SRT_BASE_RELEASE)/bin/$(SRT_SUBDIR))
super_bin_deps:=$(addprefix bin/$(SRT_SUBDIR)/,$(super_bin_deps))
super_bin_deps:=$(filter-out $(local_products),$(super_bin_deps))
super_bin_deps:=$(addprefix $(SRT_PRIVATE_CONTEXT)/super/,$(super_bin_deps))

super_lib_deps:=$(shell /bin/ls $(SRT_DIST)/releases/$(SRT_BASE_RELEASE)/lib/$(SRT_SUBDIR))
super_lib_deps:=$(addprefix lib/$(SRT_SUBDIR)/,$(super_lib_deps))
super_lib_deps:=$(filter-out $(local_products),$(super_lib_deps))
super_lib_deps:=$(addprefix $(SRT_PRIVATE_CONTEXT)/super/,$(super_lib_deps))

super_tmp_deps:=$(shell /bin/ls $(SRT_DIST)/releases/$(SRT_BASE_RELEASE)/tmp/$(SRT_SUBDIR))
super_tmp_deps:=$(filter-out $(local_packages),$(super_tmp_deps))
super_tmp_deps:=$(addprefix tmp/$(SRT_SUBDIR)/,$(super_tmp_deps))
super_tmp_deps:=$(filter-out $(local_products),$(super_tmp_deps))
super_tmp_deps:=$(addprefix $(SRT_PRIVATE_CONTEXT)/super/,$(super_tmp_deps))

.PHONY: super-initial
$(all_deps): super-initial $(super_lib_deps) $(super_bin_deps)

# Support for ISOcxx
ifneq (,$(wildcard ${SRT_PRIVATE_CONTEXT}/ISOcxx))
    # Do nothing if ISOcxx exists in test release
else
    ifneq (,$(wildcard $(SRT_DIST)/releases/$(SRT_BASE_RELEASE)/ISOcxx))
        # If ISOcxx is not in test release, but it is in the base release
        # create a link in the super area.       
        $(all_deps): $(SRT_PRIVATE_CONTEXT)/super/ISOcxx
    endif
endif

super-initial: $(super_dirlist) $(super_inc_deps) $(super_tmp_deps)
lib: $(super_dirlist) $(super_lib_deps)
bin: $(super_dirlist) $(super_bin_deps)

$(super_dirlist):
	@srt_int_mkdir $@

$(SRT_PRIVATE_CONTEXT)/super/%: $(SRT_DIST)/releases/$(SRT_BASE_RELEASE)/%
	@/bin/rm -f $@
	@ln -s $< $@

super_refresh:
	@/bin/rm -rf $(SRT_PRIVATE_CONTEXT)/super
	@srt_super_init

$(SRT_DIST)/releases/$(SRT_BASE_RELEASE)/include/%:
	@echo "Problem in base release:"
	@echo "    $@"
	@echo "appears to be a broken link."

# For debugging super test releases only
superecho_%:
	@echo "$(subst superecho_,,$@)=$($(subst superecho_,,$@))"
	@echo "origin $(subst superecho_,,$@) returns $(origin $(subst superecho_,,$@))"
