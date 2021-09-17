ifndef have_included_arch_spec
have_included_arch_spec=true

override CPPFLAGS += -I. -I$(SRT_PRIVATE_CONTEXT)/tmp/$(SRT_SUBDIR) \
            -I$(SRT_PUBLIC_CONTEXT)/tmp/$(SRT_SUBDIR) \
            -I$(SRT_PRIVATE_CONTEXT)/include \
            -I$(SRT_PUBLIC_CONTEXT)/include

override LDFLAGS +=-L. -L$(SRT_PRIVATE_CONTEXT)/lib/$(SRT_SUBDIR) \
            -L$(SRT_PUBLIC_CONTEXT)/lib/$(SRT_SUBDIR) 
ARFLAGS =
FCPP:=cc -E
include SoftRelTools/compilers/$(SRT_CXX).mk

ifndef CXXFLAGS_BINARY
    CXXFLAGS_BINARY = $(CXXFLAGS)
endif

# Macro for post-processing dependency files
define postprocess_d
test -f $(dir $@)/$(basename $(notdir $<)).d && \
cat $(dir $@)/$(basename $(notdir $<)).d | \
sed 's?$*\.o?$(dir $@)$*.o ?g' > \
$(workdir)srt_dep_tmp.$$$$ ; \
mv $(workdir)srt_dep_tmp.$$$$ $(dir $@)/$(basename $(notdir $<)).d
endef

# Compilation macros
# All permutations of 
#    (C++, c, Fortran, Preprocessed Fortran) +
#    (pic, non-pic, for_binary)
#    (with depends, without depends)
# Additionally, include both on-the-fly and separate dependency generation
#

# The following macro gets the full pathname of the dependency, whether
# it is given as an absolute path, or relative to curdir.
define get_srt_src
case $< in /*) srt_src=$<;; *) srt_src=$(curdir)$<;; esac
endef

# C++ Macros
define cxx_generate_depends
$(CPP) $(CXXFLAGS) $(CXXCFLAGS) \
$(isocxx_pre_cppflags) $(CPPFLAGS) $(isocxx_post_cppflags) \
$(STANDALONE_DEP) || /bin/rm -f $(dir $@)/$(basename $(notdir $<)).d
endef

define cxx_compile
$(get_srt_src); $(CXX) $(CXXFLAGS) $(CXXCFLAGS) \
$(isocxx_pre_cppflags) $(CPPFLAGS) $(isocxx_post_cppflags) \
-c $$srt_src -o $@
endef

define cxx_compile_for_binary
$(get_srt_src); $(CXX) $(CXXFLAGS_BINARY) $(CXXCFLAGS) \
$(isocxx_pre_cppflags) $(CPPFLAGS) $(isocxx_post_cppflags) \
-c $$srt_src -o $@
endef

define cxx_compile_pic
$(get_srt_src); $(CXX) $(CXXFLAGS) $(CXXCFLAGS) \
$(isocxx_pre_cppflags) $(CPPFLAGS) $(isocxx_post_cppflags) \
$(PICFLAG) -c $$srt_src -o $@
endef

ifdef INLINE_DEP_CAPABLE
define cxx_compile_with_depends
$(get_srt_src); $(CXX) $(CXXFLAGS) $(CXXCFLAGS) \
$(isocxx_pre_cppflags) $(CPPFLAGS) $(isocxx_post_cppflags) \
$(INLINE_DEP) -c $$srt_src -o $@\
|| /bin/rm -f $(dir $@)/$(basename $(notdir $<)).d
$(postprocess_d)
endef
define cxx_compile_for_binary_with_depends
$(get_srt_src); $(CXX) $(CXXFLAGS_BINARY) $(CXXCFLAGS) \
$(isocxx_pre_cppflags) $(CPPFLAGS) $(isocxx_post_cppflags) \
$(INLINE_DEP) -c $$srt_src -o $@\
|| /bin/rm -f $(dir $@)/$(basename $(notdir $<)).d
$(postprocess_d)
endef
define cxx_compile_pic_with_depends
$(get_srt_src); $(CXX) $(CXXFLAGS) $(CXXCFLAGS) \
$(isocxx_pre_cppflags) $(CPPFLAGS) $(isocxx_post_cppflags) \
$(PICFLAG) $(INLINE_DEP) -c $$srt_src -o $@\
|| /bin/rm -f $(dir $@)/$(basename $(notdir $<)).d
$(postprocess_d)
endef
else
define cxx_compile_with_depends
$(cxx_compile)
$(cxx_generate_depends)
$(postprocess_d)
endef
define cxx_compile_for_binary_with_depends
$(cxx_compile_for_binary)
$(cxx_generate_depends)
$(postprocess_d)
endef
define cxx_compile_pic_with_depends
$(cxx_compile_pic)
$(cxx_generate_depends)
$(postprocess_d)
endef
endif

# C Macros
define c_generate_depends
$(CPP) $(CPPFLAGS) $(CSTANDALONE_DEP)\
|| /bin/rm -f $(dir $@)/$(basename $(notdir $<)).d
endef

define c_compile
$(get_srt_src); $(CC) $(CCFLAGS) $(CPPFLAGS) -c $$srt_src -o $@
endef

define c_compile_pic
$(get_srt_src); $(CC) $(CCFLAGS) $(CPPFLAGS) $(PICFLAG) -c $$srt_src -o $@
endef

ifdef INLINE_DEP_CAPABLE
define c_compile_with_depends
$(get_srt_src); $(CC) $(CCFLAGS) $(CPPFLAGS) $(INLINE_DEP) -c $$srt_src -o $@\
|| /bin/rm -f $(dir $@)/$(basename $(notdir $<)).d
$(postprocess_d)
endef
define c_compile_pic_with_depends
$(get_srt_src); $(CC) $(CCFLAGS) $(CPPFLAGS) $(PICFLAG) $(INLINE_DEP) -c $$srt_src -o $@\
|| /bin/rm -f $(dir $@)/$(basename $(notdir $<)).d
$(postprocess_d)
endef
else
define c_compile_with_depends
$(c_compile)
$(c_generate_depends)
$(postprocess_d)
endef
define c_compile_pic_with_depends
$(c_compile_pic)
$(c_generate_depends)
$(postprocess_d)
endef
endif

include SoftRelTools/platforms/$(SRT_ARCH).mk

define build_simplebin
$(CXX) $(workdir)$(patsubst %$(BINEXTENSION),%,$(@F)).o \
$(filter $(foreach v,$(BINSTANDALONEOFILES),%/$(v)),$^) \
$(CXXFLAGS_BINARY) $(CXXCFLAGS) $(CPPFLAGS) $(LDFLAGS) \
-o $@ $($(basename $(@F))_LIBS) $(BINLIBS)
endef

define build_complexbin
$(CXX) $(filter-out $(BINSTANDALONEOFILES),$(binofiles)) \
$(filter $(foreach v,$(BINSTANDALONEOFILES),%/$(v)),$^) \
$(CXXFLAGS_BINARY) $(CXXCFLAGS) $(CPPFLAGS) $(LDFLAGS) \
-o $@ $(BINLIBS)
endef

define build_old_binary
cd $(workdir) ; \
$(CXX) $(curdir)$< $(CXXFLAGS) $(CXXCFLAGS) \
$(isocxx_pre_cppflags) $(CPPFLAGS) $(isocxx_post_cppflags) $(LDFLAGS) \
-o $@ $(LOADLIBES)
endef

define build_static_library
cd $(staticlib_o_dir) ; \
$(AR) $(ARFLAGS) $(AROFLAG) $(STATICLIB) $(actual_staticlib_files) $(LIBLIBS)
endef

define build_shared_library
cd $(sharedlib_o_dir) ; \
$(SHAREDAR) $(SHAREDARFLAGS) $(SHAREDAROFLAG) $(SHAREDLIB) $(actual_sharedlib_files) $(LIBLIBS)
endef

override DEFINES += $(DATAREP) $(DEFECTS)
override CPPFLAGS += $(DEFINES)

-include SRT_$(SRT_PROJECT)/special/arch_spec.mk
-include SRT_SITE/special/arch_spec.mk

endif #have_included_arch_spec
