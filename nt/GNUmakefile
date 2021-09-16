#
# GNUmakefile
#
#  Copy over the NT subdirectory of scripts and other things
# to the bin area so the user can use them (!).
#
#############################################################
# file lists (standard names, local contents)

# include file products
INC = 

# library product
MYLIB = $(filter-out %_t.pyc,$(patsubst %.py,%.pyc,$(wildcard *.py)))


#library contents
LIBFFILES = 
LIBCFILES  =
LIBCCFILES = 

# subdirectories
SUBDIRS = nt_dummy_lib

# binary products
BINS = 	srt_ntide_project_exe.template \
                srt_ntide_project_lib.template \
                ntide_build \
                srt_ntsetup \
                srt_ntcc \
                srt_ntf77 \
                srt_ntlib
ifeq (D0,$(EXPERIMENT))
  BINS += srt_ntd0cint
endif

MANPAGES =

DOCS = 

#
# Move over the binary and script files and compile them.
#
$(foreach v,$(BINS),$(bindir)$v): $(BINS)
	echo "$(BFPREFIX) Installing Script $(@F)"
	rm -f $@
	cp $(@F) $@
	chmod 555 $@

#
# The lib target -- move the python files over and also make sure
# to compile them so they are faster!
#
#  When we use python to import the files and compile them we have to 
#
# Create a dummy libm file to make sure that when people require the "m" library
# to be present, it is.
#

lib: $(foreach v,$(MYLIB),$(libdir)$v) $(libdir)libm.a $(libdir)dformt.lib $(libdir)dfconsol.lib $(libdir)dfport.lib $(libdir)dfqwin.lib $(libdir)dfqw_sdi.lib $(workdir)/nt/d0nt_math.hpp

$(patsubst %.pyc,$(libdir)%.py,$(MYLIB)): $(patsubst %.pyc,%.py,$(MYLIB))
	echo "$(BFPREFIX) Building script library $(@F)"
	rm -f $@
	cp $(@F) $@

$(foreach v,$(MYLIB),$(libdir)$v): $(patsubst %.pyc,$(libdir)%.py,$(MYLIB))
	cd $(libdir) ; python -c "import $(@F:.pyc=)"

$(libdir)libm.a:
	echo "$(BFPREFIX) creating library $(@F)"
	touch $(libdir)libm.a

DFLIB=$(shell posix2win32 /msvcinc)../../Df98/lib
$(libdir)dformt.lib:
	echo "$(BFPREFIX) creating library $(@F)"
	if test -r "$(DFLIB)/dformt.lib"; then cp "$(DFLIB)/dformt.lib" $@; fi

$(libdir)dfconsol.lib:
	echo "$(BFPREFIX) creating library $(@F)"
	if test -r "$(DFLIB)/dfconsol.lib"; then cp "$(DFLIB)/dfconsol.lib" $@; fi

$(libdir)dfport.lib:
	echo "$(BFPREFIX) creating library $(@F)"
	if test -r "$(DFLIB)/dfport.lib"; then cp "$(DFLIB)/dfport.lib" $@; fi

$(libdir)dfqw_sdi.lib:
	echo "$(BFPREFIX) creating library $(@F)"
	if test -r "$(DFLIB)/dfqw_sdi.lib"; then cp "$(DFLIB)/dfqw_sdi.lib" $@; fi

$(libdir)dfqwin.lib:
	echo "$(BFPREFIX) creating library $(@F)"
	if test -r "$(DFLIB)/dfqwin.lib"; then cp "$(DFLIB)/dfqwin.lib" $@; fi

$(workdir)/nt/d0nt_math.hpp: d0nt_math.hpp
	echo "$(BFPREFIX) creating header $(@F)"
	mkdir -p $(workdir)/nt
	cp d0nt_math.hpp $(workdir)/nt

############################################################
include SoftRelTools/standard.mk

