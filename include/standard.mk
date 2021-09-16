# This goes first to ensure that "all" is the default target
all:

# common.mk contains elements common to GNUmakefile.main and standard.mk
include SoftRelTools/common.mk

ifeq ($(MAKECMDGOALS),clean)
    NO_GENERATE_DEPENDS:=true
endif
ifeq ($(findstring echo_,$(MAKECMDGOALS)),echo_)
    NO_GENERATE_DEPENDS:=true
endif
define check_dep_dir
    if [ ! -d "$(dir $@)" ]; then srt_int_mkdir "$(dir $@)"; fi
endef

# Eliminate default suffix rules.
.SUFFIXES:

# Allow specialization. See also the end of this file.
-include SRT_$(SRT_PROJECT)/special/pre_standard.mk
-include SRT_SITE/special/pre_standard.mk

ifneq ($(VERBOSE),)
    TRACE=
    MAKEFLAGS += --print-directory
else
    TRACE=@
    ifneq ($(VDIR),)
      MAKEFLAGS += --print-directory
    else
      MAKEFLAGS += --no-print-directory
    endif
    MAKEFLAGS += -s
endif

include SoftRelTools/arch_spec.mk

ifdef SUBDIRS
    ifdef SORT_SUBDIRS
        SUBDIRS := $(sort $(SUBDIRS))
    endif
endif

ifdef SUBPACKAGE
    override tmpdir:=$(tmpdir)$(SUBPACKAGE)/
endif

# Shared library foolishness.
# Make versions previous to 3.78 were broken with respect to understanding
# that -lfoo could mean -libfoo.so as well as -libfoo.a. Newer versions
# support a generalized version of -lfoo through the use of the variable
# .LIBPATTERNS. If .LIBPATTERNS is not present, attempt to work around the
# problem.

ifndef .LIBPATTERNS
# Tell make what -lfoo means for shared libraries.
# The colon is a shell no-op.
-l%: lib%$(SHAREDEXT)
	:

# Tell make where to look for shared libraries. This isn't necessarily
# correct, but it is the same list make uses for static libraries.
vpath %$(SHAREDEXT) /lib /usr/lib /usr/local/lib

endif
# end of shared library foolishness

vpath %.a $(SRT_PRIVATE_CONTEXT)/lib/$(SRT_SUBDIR) \
            $(SRT_PUBLIC_CONTEXT)/lib/$(SRT_SUBDIR) \
            $(patsubst -L%,%,$(filter -L%,$(LDFLAGS)))

vpath %$(SHAREDEXT) $(SRT_PRIVATE_CONTEXT)/lib/$(SRT_SUBDIR) \
           $(SRT_PUBLIC_CONTEXT)/lib/$(SRT_SUBDIR) \
           $(patsubst -L%,%,$(filter -L%,$(LDFLAGS)))
		   

##################################################################################
# Support for compiling libraries
# Decide which libs to build and generate full path name
# LIB can be static, shared, or both. Default is static.
ifdef LIB
    LIBNAME := $(basename $(LIB))
    ifeq ($(LIB_TYPE),shared)
        SHAREDLIBNAME:=$(LIBNAME)
    else
        ifeq ($(LIB_TYPE),both)
            SHAREDLIBNAME:=$(LIBNAME)
            STATICLIBNAME:=$(LIBNAME)
        else
            STATICLIBNAME:=$(LIBNAME)
        endif
    endif
endif

ifdef SHAREDLIB
    SHAREDLIBNAME := $(basename $(SHAREDLIB))
endif

ifdef STATICLIB
    STATICLIBNAME := $(basename $(STATICLIB))
endif

ifdef SHAREDLIBNAME
    SHAREDLIB:=$(shlibdir)$(SHAREDLIBNAME)$(SHAREDEXT)
    sharedlib_o_dir=$(tmpdir)$(SHAREDLIBNAME)-shared/
    dirlist += $(sharedlib_o_dir)
    SRT_PRODUCTS += $(SHAREDLIB)
endif

ifdef STATICLIBNAME
    STATICLIB:=$(libdir)$(STATICLIBNAME)$(STATICEXT)
    staticlib_o_dir=$(tmpdir)$(STATICLIBNAME)-static/
    dirlist += $(staticlib_o_dir)
    SRT_PRODUCTS += $(STATICLIB)
endif

# library objects and dependency files
ifdef STATICLIB
staticlibofiles  += $(patsubst %.cc,$(staticlib_o_dir)%.o, $(notdir $(LIBCCFILES)))
staticlibofiles  += $(patsubst %.cxx,$(staticlib_o_dir)%.o, $(notdir $(LIBCXXFILES)))
staticlibofiles  += $(patsubst %.cpp,$(staticlib_o_dir)%.o, $(notdir $(LIBCPPFILES)))
staticlibofiles  += $(patsubst %.c,$(staticlib_o_dir)%.o, $(notdir $(LIBCFILES)))
staticlibofiles  += $(patsubst %.f,$(staticlib_o_dir)%.o, $(notdir $(filter %.f,$(LIBFFILES))))
staticlibofiles  += $(patsubst %.F,$(staticlib_o_dir)%.o, $(notdir $(filter %.F,$(LIBFFILES))))
staticlibofiles += $(LIBOFILES)
endif

ifdef SHAREDLIB
sharedlibofiles  += $(patsubst %.cc,$(sharedlib_o_dir)%.o, $(notdir $(LIBCCFILES)))
sharedlibofiles  += $(patsubst %.cxx,$(sharedlib_o_dir)%.o, $(notdir $(LIBCXXFILES)))
sharedlibofiles  += $(patsubst %.cpp,$(sharedlib_o_dir)%.o, $(notdir $(LIBCPPFILES)))
sharedlibofiles  += $(patsubst %.c,$(sharedlib_o_dir)%.o, $(notdir $(LIBCFILES)))
sharedlibofiles  += $(patsubst %.f,$(sharedlib_o_dir)%.o, $(notdir $(filter %.f,$(LIBFFILES))))
sharedlibofiles  += $(patsubst %.F,$(sharedlib_o_dir)%.o, $(notdir $(filter %.F,$(LIBFFILES))))
endif

staticlibdepends := $(patsubst %.o,%.d, \
    $(filter $(staticlibofiles),$(wildcard $(staticlib_o_dir)*.o)))
sharedlibdepends := $(patsubst %.o,%.d, \
    $(filter $(sharedlibofiles),$(wildcard $(sharedlib_o_dir)*.o)))
alldepends += $(patsubst %.o,%.d, $(staticlibofiles) $(sharedlibofiles))

ifdef CATCHALL_LIB
    export CATCHALL_LIB
    actual_staticlib_files:=*.o
    actual_sharedlib_files:=*.o
else
    actual_staticlib_files:=$(subst $(staticlib_o_dir),,$(staticlibofiles))
    actual_sharedlib_files:=$(subst $(sharedlib_o_dir),,$(sharedlibofiles))
endif

ifndef NO_SIDE_EFFECTS
    ifneq ("$(staticlibdepends)","")
        -include $(staticlibdepends)
    endif
    ifneq ("$(sharedlibdepends)","")
        -include $(sharedlibdepends)
    endif
endif

# Rules for generating the libraries themselves
$(STATICLIB): $(staticlibofiles) $(LIBDEPENDS)
	@echo "<**building library**> $(LIBNAME)"
	$(build_static_library)
        
$(SHAREDLIB): $(sharedlibofiles) $(LIBDEPENDS)
	@echo "<**building library**> $(LIBNAME)"
	$(build_shared_library)

##################################################################################
# Support for compiling binaries
# BINS lists all binaries to be generated by the bin stage
# TBINS lists all binaries to be generated by the tbin stage
# Rules are supplied for simple (single file) binaries, complex binaries and
# scripts.
ifdef BINS
    BINS_dest = $(foreach v, $(BINS),$(bindir)$v)
    SRT_PRODUCTS += $(BINS_dest)
endif

# Support for test binaries
ifdef TBINS
    TBINS_dest = $(foreach v, $(TBINS),$(tbindir)$v)
    SRT_PRODUCTS += $(TBINS_dest)
endif

# Extended binary support
# Backward compatibility with LOADLIBES
ifndef BINLIBS
    ifdef LOADLIBES
    BINLIBS=$(LOADLIBES)
    endif
endif

ifdef SIMPLEBINS
    ifndef BINEXTENSION
        BINEXTENSION:=$(sort $(suffix $(SIMPLEBINS)))
        ifneq ($(words $(BINEXTENSION)),0)
            ifneq ($(words $(BINEXTENSION)),1)
                $(shell echo "SoftRelTools error: Found $(words $(BINEXTENSION)) extensions ($(BINEXTENSION)) in SIMPLEBINS." >&2)
                $(shell echo "                    Only one extension allowed." >&2)
            endif
        endif    
    endif
    SIMPLEBINS_dest = $(foreach v, $(SIMPLEBINS), \
        $(foreach d, $(bin_dirlist), $d$v))
    simplebinofiles  += $(foreach v,\
                             $(patsubst %$(BINEXTENSION),%,$(SIMPLEBINS)), \
                             $(workdir)$v.o)
    simplebindepends := $(patsubst %.o,%.d, \
        $(filter $(simplebinofiles),$(wildcard $(workdir)*.o)))
    alldepends += $(patsubst %.o,%.d,$(simplebinofiles))
endif

ifdef COMPLEXBIN
    COMPLEXBIN_dest=$(foreach d, $(bin_dirlist), $d$(COMPLEXBIN))
    complexbin_o_dir=$(tmpdir)$(COMPLEXBIN)/
    dirlist += $(complexbin_o_dir)
endif

ifdef SCRIPTS
    SCRIPTS_dest = $(foreach v, $(SCRIPTS),\
            $(foreach d, $(bin_dirlist), $d$v))
endif

# Objects for complex binaries
binofiles  += $(patsubst %.cc,$(complexbin_o_dir)%.o, $(notdir $(BINCCFILES)))
binofiles  += $(patsubst %.cxx,$(complexbin_o_dir)%.o, $(notdir $(BINCXXFILES)))
binofiles  += $(patsubst %.cpp,$(complexbin_o_dir)%.o, $(notdir $(BINCPPFILES)))
binofiles  += $(patsubst %.c,$(complexbin_o_dir)%.o, $(notdir $(BINCFILES)))
binofiles  += $(patsubst %.f,$(complexbin_o_dir)%.o, $(notdir $(filter %.f,$(BINFFILES))))
binofiles  += $(patsubst %.F,$(complexbin_o_dir)%.o, $(notdir $(filter %.F,$(BINFFILES))))
binofiles += $(BINSTANDALONEOFILES)

complexbindepends := $(patsubst %.o,%.d, \
    $(filter $(binofiles),$(wildcard $(complexbin_o_dir)*.o)))
alldepends += $(patsubst %.o,%.d, $(binofiles))

ifndef NO_SIDE_EFFECTS
    ifneq ("$(simplebindepends)","")
        -include $(simplebindepends)
    endif
    ifneq ("$(complexbindepends)","")
        -include $(complexbindepends)
    endif
endif

# Rules for generating the binaries themselves

# The following line needs to be duplicated for each bin directory
$(filter $(tbindir)%, $(SIMPLEBINS_dest)):	$(tbindir)%$(BINEXTENSION) :\
    $(workdir)%.o

$(filter $(bindir)%, $(SIMPLEBINS_dest)):	$(bindir)%$(BINEXTENSION) :\
    $(workdir)%.o

# GNU Make cannot handle the dependency relationship between SIMPLEBINS
# and SIMPLEBIN_LIB without writing and reading a file
simplebinlibdep := $(workdir)simplebinlibdep-$(shell pwd | sed -e 's%$(SRT_PRIVATE_CONTEXT)/%%' | sed -e 's%/%-%g').mk
ifndef NO_SIDE_EFFECTS
    ifneq ("$(SIMPLEBINS)","")
        -include $(simplebinlibdep)
    endif
endif

ifndef NO_GENERATE_DEPENDS
# We don't have a way for getting full dependencies on GNUmakefiles.
# To be safe, always build $(simplebinlibdep)
.PHONY: $(simplebinlibdep)
$(simplebinlibdep):
	$(check_dep_dir)
	rm -f $@
	( :; $(foreach sb, $(SIMPLEBINS_dest), \
		test -z "$($(basename $(notdir $(sb)))_LIBS)" || \
		echo "$(sb): $($(basename $(notdir $(sb)))_LIBS)";)) > $@
endif

# The treatment of binofiles below allows BINSTANDALONEOFILES to
# be found via vpath
$(SIMPLEBINS_dest): $(BINSTANDALONEOFILES)
$(SIMPLEBINS_dest): $(filter-out $(NODEP_LIBS), $(BINLIBS))
$(SIMPLEBINS_dest):
	@echo "<**building**> $(@F)"
	$(build_simplebin)

$(COMPLEXBIN_dest):$(filter-out $(NODEP_LIBS), $(BINLIBS))
$(COMPLEXBIN_dest): $(binofiles)
	@echo "<**building**> $(@F)"
	$(build_complexbin)

# These lines need to be duplicated for each bin directory
$(filter $(tbindir)%, $(SCRIPTS_dest)): $(tbindir)% : %
$(filter $(bindir)%, $(SCRIPTS_dest)): $(bindir)% : %

$(SCRIPTS_dest):
	@echo "<**installing script**> $(@F)"
	$(TRACE)rm -f $@
	$(TRACE)cp $< $@
	$(TRACE)chmod 755 $@

# Binary rules for backward compatility with old SoftRelTools
ifdef OLD_BIN_RULES
$(bindir)%:     %.cc
	@echo "<**building **> $(@F)"
	$(build_old_binary)
 
$(bindir)%:     %.cxx
	@echo "<**building**> $(@F)"
	$(build_old_binary)
 
$(bindir)%:     %.cpp
	@echo "<**building**> $(@F)"
	$(build_old_binary)
endif

##################################################################################
# Support for .o files in the library directory
#
objofiles  += $(patsubst %.cc,$(libdir)%.o, $(notdir $(OBJCCFILES)))
objofiles  += $(patsubst %.cxx,$(libdir)%.o, $(notdir $(OBJCXXFILES)))
objofiles  += $(patsubst %.cpp,$(libdir)%.o, $(notdir $(OBJCPPFILES)))
objofiles  += $(patsubst %.c,$(libdir)%.o, $(notdir $(OBJCFILES)))
objofiles  += $(patsubst %.f,$(libdir)%.o, $(notdir $(filter %.f,$(OBJFFILES))))
objofiles  += $(patsubst %.F,$(libdir)%.o, $(notdir $(filter %.F,$(OBJFFILES))))
SRT_PRODUCTS += $(objofiles)

objdepends := $(patsubst $(libdir)%.o,$(workdir)%.d, \
    $(filter $(objofiles),$(wildcard $(libdir)*.o)))
alldepends += $(patsubst $(libdir)%.o,$(workdir)%.d, $(objofiles))

ifndef NO_SIDE_EFFECTS
    ifneq ("$(objdepends)","")
        -include $(objdepends)
    endif
endif

##################################################################################
# Rules for generating object files

# Rules for generating library object files
$(staticlib_o_dir)%.o: %.cc
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(cxx_compile_with_depends)

$(staticlib_o_dir)%.o: %.cxx
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(cxx_compile_with_depends)

$(staticlib_o_dir)%.o: %.cpp
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(cxx_compile_with_depends)

$(staticlib_o_dir)%.o: %.c
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(c_compile_with_depends)

$(staticlib_o_dir)%.o: %.f
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(f_compile)

$(staticlib_o_dir)%.o: %.F
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(ff_compile_with_depends)

$(sharedlib_o_dir)%.o: %.cc
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(cxx_compile_pic_with_depends)

$(sharedlib_o_dir)%.o: %.cxx
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(cxx_compile_pic_with_depends)

$(sharedlib_o_dir)%.o: %.cpp
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(cxx_compile_pic_with_depends)

$(sharedlib_o_dir)%.o: %.c
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(c_compile_pic_with_depends)

$(sharedlib_o_dir)%.o: %.f
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(f_compile)

$(sharedlib_o_dir)%.o: %.F
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(ff_compile_pic_with_depends)

ifndef NO_GENERATE_DEPENDS
$(staticlib_o_dir)%.d: %.cc
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(cxx_generate_depends)
	$(postprocess_d)

$(staticlib_o_dir)%.d: %.cxx
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(cxx_generate_depends)
	$(postprocess_d)

$(staticlib_o_dir)%.d: %.cpp 
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(cxx_generate_depends)
	$(postprocess_d)

$(staticlib_o_dir)%.d: %.c
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(c_generate_depends)
	$(postprocess_d)

$(staticlib_o_dir)%.d: %.F
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(ff_generate_depends)
	$(postprocess_d)

$(sharedlib_o_dir)%.d: %.cc
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(cxx_generate_depends)
	$(postprocess_d)

$(sharedlib_o_dir)%.d: %.cxx
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(cxx_generate_depends)
	$(postprocess_d)

$(sharedlib_o_dir)%.d: %.cpp
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(cxx_generate_depends)
	$(postprocess_d)

$(sharedlib_o_dir)%.d: %.c
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(c_generate_depends)
	$(postprocess_d)

$(sharedlib_o_dir)%.d: %.F
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(ff_generate_depends)
	$(postprocess_d)

endif #NO_GENERATE_DEPENDS

# Rules for generating complex binary object files
$(complexbin_o_dir)%.o: %.cc
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(cxx_compile_for_binary_with_depends)

$(complexbin_o_dir)%.o: %.cxx
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(cxx_compile_for_binary_with_depends)

$(complexbin_o_dir)%.o: %.cpp
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(cxx_compile_for_binary_with_depends)

$(complexbin_o_dir)%.o: %.c
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(c_compile_with_depends)

$(complexbin_o_dir)%.o: %.f
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(f_compile)

$(complexbin_o_dir)%.o: %.F
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(ff_compile_with_depends)

ifndef NO_GENERATE_DEPENDS
$(complexbin_o_dir)%.d: %.cc
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(cxx_generate_depends)
	$(postprocess_d)

$(complexbin_o_dir)%.d: %.cxx
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(cxx_generate_depends)
	$(postprocess_d)

$(complexbin_o_dir)%.d: %.cpp
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(cxx_generate_depends)
	$(postprocess_d)

$(complexbin_o_dir)%.d: %.c
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(c_generate_depends)
	$(postprocess_d)

$(complexbin_o_dir)%.d: %.F
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(ff_generate_depends)
	$(postprocess_d)

endif #NO_GENERATE_DEPENDS

# Rules for generating objects in the library directory
define move_libobj_depfile
/bin/mv -f $(patsubst %.o,%.d,$@) $(patsubst $(libdir)%.o,$(workdir)%.d,$@)
endef

$(libdir)%.o: %.cc
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(cxx_compile_with_depends)
	$(move_libobj_depfile)

$(libdir)%.o: %.cxx
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(cxx_compile_with_depends)
	$(move_libobj_depfile)

$(libdir)%.o: %.cpp
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(cxx_compile_with_depends)
	$(move_libobj_depfile)

$(libdir)%.o: %.c
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(c_compile_with_depends)
	$(move_libobj_depfile)

$(libdir)%.o: %.f
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(f_compile)

$(libdir)%.o: %.F
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(ff_compile_with_depends)
	$(move_libobj_depfile)

ifndef NO_GENERATE_DEPENDS
$(libdir)%.d: %.cc
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(cxx_generate_depends)
	$(postprocess_d)

$(libdir)%.d: %.cxx
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(cxx_generate_depends)
	$(postprocess_d)

$(libdir)%.d: %.cpp
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(cxx_generate_depends)
	$(postprocess_d)

$(libdir)%.d: %.c
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(c_generate_depends)
	$(postprocess_d)

$(libdir)%.d: %.F
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(ff_generate_depends)
	$(postprocess_d)

endif #NO_GENERATE_DEPENDS

# Generic rules for generating object files
$(workdir)%.o: %.cc
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(cxx_compile_for_binary_with_depends)

$(workdir)%.o: %.cxx
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(cxx_compile_for_binary_with_depends)

$(workdir)%.o: %.cpp
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(cxx_compile_for_binary_with_depends)

$(workdir)%.o: %.c
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(c_compile_with_depends)

$(workdir)%.o: %.f
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(f_compile)

$(workdir)%.o: %.F
	@echo "<**compiling**> $(<F)"
	$(TRACE)$(ff_compile_with_depends)

ifndef NO_GENERATE_DEPENDS
$(workdir)%.d: %.cc
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(cxx_generate_depends)
	$(postprocess_d)

$(workdir)%.d: %.cxx
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(cxx_generate_depends)
	$(postprocess_d)

$(workdir)%.d: %.cpp
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(cxx_generate_depends)
	$(postprocess_d)

$(workdir)%.d: %.c
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(c_generate_depends)
	$(postprocess_d)

$(workdir)%.d: %.F
	echo "<**depend**> $(@F)"
	$(check_dep_dir)
	$(TRACE)$(ff_generate_depends)
	$(postprocess_d)

endif #NO_GENERATE_DEPENDS

##################################################################################
# Documentation
#
MANPAGES_dest := $(foreach ext,1 2 3 4 5 6 7 8,\
  $(addprefix $(mandir)man$(ext)/,$(filter %.$(ext),$(MANPAGES))))
DOCS_dest := $(foreach v,$(DOCS),$(docdir)$v)
dirlist += $(mandir) $(docdir)
SRT_PRODUCTS += $(MANPAGES_dest) $(DOCS_dest)

man: $(MANPAGES_dest) $(checkdirs)
doc: $(DOCS_dest) $(checkdirs)

$(MANPAGES_dest) : $(MANPAGES)
	rm -f $@
	if [ ! -d $(@D) ] ; then srt_int_mkdir $(@D); fi
	cp $(@F) $@

$(DOCS_dest): $(DOCS)
	rm -f $@
	cp $(@F) $@

# Define a rule for missing dependencies from the include directories.
# This rule causes make to ignore the file and rebuild the object(s)
# that depend on it.
$(SRT_PRIVATE_CONTEXT)/include/%:
	echo "Dependency $@ not found. Treating as modified."

$(SRT_PUBLIC_CONTEXT)/include/%:
	echo "Dependency $@ not found. Treating as modified."

##################################################################################
# Standard targets
#

# If necessary, the phony target list can be overriden by
# "override SRT_PHONY=blah"
SRT_PHONY=all checkdirs include depend lib bin clean test

.PHONY: $(SRT_PHONY)

all: checkdirs $(all_deps) 

checkdirs: $(dirlist)

codegen: checkdirs $(CODEGENFILES) $(foreach v,$(SUBDIRS),$v.codegen)

include: checkdirs $(foreach v,$(SUBDIRS),$v.include)

depend: checkdirs $(alldepends) $(foreach v,$(SUBDIRS),$v.depend)

test: checkdirs $(foreach v,$(SUBDIRS),$v.test)

idl:    $(IDLFILES) $(foreach v,$(SUBDIRS),$v.idl)

ifndef lib_deps
    lib_deps=$(SHAREDLIB) $(STATICLIB) $(objofiles)
endif

lib: checkdirs $(lib_deps) $(foreach v,$(SUBDIRS),$v.lib)

ifndef libobjects_deps
    libobjects_deps= $(staticlibofiles) $(sharedlibofiles) $(LIBDEPENDS)
endif

libobjects: checkdirs $(libobjects_deps) $(foreach v,$(SUBDIRS),$v.libobjects)

bin: checkdirs $(BINS_dest) $(foreach v,$(SUBDIRS),$v.bin)
bin: man doc

tbin: checkdirs $(TBINS_dest) $(foreach v,$(SUBDIRS),$v.tbin)

clean: $(foreach v,$(SUBDIRS),$v.clean)
	$(TRACE)if [ ! "$(workdir)" = "/" ]; then \
		rm -rf $(workdir); \
	fi
	$(TRACE)rm -f $(SRT_PRODUCTS)

echo_%:
	$(TRACE)echo "$(subst echo_,,$@)=$($(subst echo_,,$@))"
	$(TRACE)echo "origin $(subst echo_,,$@) returns $(origin $(subst echo_,,$@))"

queryecho_%: $(foreach v,$(SUBDIRS),$v.querecho_%)

queryecho_%:
	if [ ! -z "$($(subst queryecho_,,$@))" ]; then \
		echo "srt_int_query_begin$($(subst queryecho_,,$@))srt_int_query_end";\
	fi
	for v in $(SUBDIRS); \
	do \
		if [ -d "$$v" ]; then \
			$(MAKE) -C $$v $@;\
		fi ;\
	done


sortecho_%:
	$(TRACE)echo "$($(subst sortecho_,,$@))" | perl -pe 's/ +/\n/go;' |sort

# Sort is being used here because it removes duplicates
$(sort $(dirlist)):
	$(TRACE)srt_int_mkdir $@

############################################################################
# Rules for passing stages to subdirs
#
define pass-to-subdirs
if [ -d "$(basename $@)" ]; then \
    $(subdir-message) ; \
    $(MAKE) -C $(basename $@) $(subst $(basename $@).,,$@);\
    else\
    echo "Warning: $@ not made because $(basename $@) is not a directory"; \
    fi
endef

define subdir-message
    if [ -n "$(VERBOSE_DIRS)" ]; then \
        echo "Entering subdirectory $(basename $@)" ;\
    fi
endef

%.codegen:
	$(TRACE)$(pass-to-subdirs)

%.include:
	$(TRACE)$(pass-to-subdirs)

%.lib:
	$(TRACE)$(pass-to-subdirs)

%.libobjects:
	$(TRACE)$(pass-to-subdirs)

%.bin:
	$(TRACE)$(pass-to-subdirs)

%.tbin:
	$(TRACE)$(pass-to-subdirs)

%.test:
	$(TRACE)$(pass-to-subdirs)

%.clean:
	$(TRACE)$(pass-to-subdirs)

%.depend:
	$(TRACE)$(pass-to-subdirs)

%.test:
	$(TRACE)$(pass-to-subdirs)

# Allow specialization. See also the beginning of this file.
-include SRT_$(SRT_PROJECT)/special/post_standard.mk
-include SRT_SITE/special/post_standard.mk
