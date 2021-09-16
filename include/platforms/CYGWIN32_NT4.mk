SHAREDEXT:=.so
STATICEXT:=.a

# Warning! NT flags are significantly different from the Unix platforms
FC := srt_ntf77
FPP := gcc -E -U__GNUG__ -D_MSC_VER=1100 -nostdinc -isystem /msvcinc

#
#  Flags for fortran
#
#           nologo -- Don't print out the Digital Flag banner (but 
#                     digital is almost out of biznez -- don't they need 
#                     the publicity?
#           Od -- No optimizations
#           MTd -- Use the multithreaded static, debug version
#           Z7 -- Full debug info, stuck in the .obj file
#           iface:nomixed_str_len_arg -- Put all the string lengths at 
#               end of arg list
#           assume:underscore -- Append a "_" to all routine names, 
#               just like UNIX (duh)
#           names:lowercase -- All routine names are really lower case.
#           warn:nofileopt -- Don't complain about inability to do 
#               file-to-file optimizations
#           extend_source:132 -- Don't stop looking at source at 72 
#               columns.
#
#-NTMT for non-debug
override FCFLAGS = -NTnologo -NTOd -NTMTd -NTZ7 -NTiface:nomixed_str_len_arg \
-NTassume:underscore -NTnames:lowercase -NTwarn:nofileopt -NTextend_source:132
#
# Files to place the cahce for symbolic link resolution in. We do this 
# because it is so dang slow when trying to connect to a server. This is 
# pretty ugly cause we have to parse this path without the cache the 
# first time, but I don't know how else to do it (esp. if the path 
# involves aliases!).
#
SRT_ALIAS_CACHE_FILE=$(bindir)/../../tmp/$(BFARCH)/srt_alias_file.python_db
SRT_SYM_CACHE_FILE=$(bindir)/../../tmp/$(BFARCH)/srt_sym_file.python_db
export SRT_ALIAS_CACHE_FILE
export SRT_SYM_CACHE_FILE
#
lib=$(LIBNT)
export lib
