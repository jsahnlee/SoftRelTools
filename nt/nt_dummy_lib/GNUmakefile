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


#library contents
LIBFFILES = 
LIBCFILES  =
LIBCCFILES = 

# subdirectories
SUBDIRS =

# binary products
BINS =

MANPAGES =

DOCS = 


lib: $(libdir)/libnt_dummy.lib

$(libdir)/libnt_dummy.lib: errno.cpp
	cl /nologo /c /Fo`posix2win32 $(workdir)/errno.obj` errno.cpp
	lib /nologo /out:`posix2win32 $(libdir)/libnt_dummy.lib` `posix2win32 $(workdir)/errno.obj`
	touch $(libdir)/libnt_dummy.a

############################################################
include SoftRelTools/standard.mk
