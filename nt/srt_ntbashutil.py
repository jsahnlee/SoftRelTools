#!python
#
#  Utilities to help with the translation between nt and bash
#
#  This depends on a number of things, unfortunately:
#
#	- CYGWIN's implementation of the "mount" command. If its output
#		format changes, this script will have to be changed to
#		reparse the output.
#
#	- The way symbolic links are defined in cygwin. Since straight
#		NT does not support them, we have to resolve them here.
#		While the ls command could have been used, I don't think
#		NT supports pipe io, so this would require writing lots
#		of files. I suspect the "ls -l" command would be used
#		if the cywin symbolic link format changes... :(
#
# Created November 1997 Gordon Watts (Brown)
#

import sys
import os
import string
import regex
import regsub
import re

import srt_ntbash_cache

sym_link_cache = 0
alias_cache = 0

cache_enable = 1

#
# load_mount_table
#	Load in the mount table that bash uses so we can do translation
#	correctly.
#
mount_table_loaded = 0
mount_table = {}

def load_mount_table():
	global mount_table_loaded
	global mount_table
	if mount_table_loaded == 1:
		return

	#
	# Access the mount table by parsing the output of the mount
	# command. Ugly, but I don't know a better way!
	#

	if os.environ.has_key("temp"):
		temp_dir = os.environ["temp"]
	else:
		temp_dir = os.environ["TEMP"]
	temp_file = temp_dir + "\\temp_mount_output.txt"
	os.system ("mount > " + temp_file)

	#
	# Load the file into memory. First line from the mount command
	# is a string header...
	#
	
	m_file = open (temp_file, "r")
	m_file_lines = m_file.readlines()
	m_file.close()

	mount_finder = regex.compile("^\([^/]+\) +/\([^ ]*\).*$")
	for line in m_file_lines[1:]:
		item_list = string.split(line)
		if mount_finder.match(line) != -1:
			unix_mount_point = "/" + string.strip(mount_finder.group(2))
			nt_mount_point = string.strip(mount_finder.group(1))
			if unix_mount_point == "/":
				if string.rfind(nt_mount_point, "\\") != len(nt_mount_point):
					nt_mount_point = nt_mount_point + "\\"
			if unix_mount_point[0:4] != "/dev":
				mount_table[unix_mount_point] = nt_mount_point

	mount_table_loaded = 1

#
# translate_path -- Translate a BASH path to an NT one
#   Use the mount table to see what we need to change (or not!). Also, btw, remove the "//" that
#   UNIX seems to like and replace it with a single "/". Make sure not do this if it is at the
#   start of the string!
#   Finally, loop over all the
#   resolved directory list looking for a symbolic link...
#
def translate_path (bash_path):

	# psrxxx
	# psrxxx  Bypass all this by using bash to do the hard work.
	# psrxxx

	# Accept an empty string silently.
	if len(bash_path) == 0:
		return bash_path

	# Plain filenames do not get translated to hold down the command line length.
	if string.find(bash_path, "/") == -1:
		return bash_path
		
	#
	#  Try to use the geninc mechanism for the include directory.
	#

	pubinc  = os.environ["SRT_PUBLIC_CONTEXT"]  + "/include"
	#privinc = os.environ["SRT_PRIVATE_CONTEXT"] + "/include"
	#print "pubinc=" + pubinc
	#print "privinc=" + privinc
	inc_pat = pubinc + "$"
	#print "inc_pat=" + inc_pat
	#print "bash_path=" + bash_path
	#print re.search(inc_pat, bash_path)
	#print
	#sys.stdout.flush()
	if re.search(inc_pat, bash_path):
		bash_path = bash_path[0:-8] + "/geninc/" + os.environ["SRT_SUBDIR"]
		#print "bash_path=" + bash_path
		#print
		#sys.stdout.flush()
										
	#
	#  Now we can translate the name.
	#
	#  We will use bash to expand the symbolic links to real
	# directories and file names, and we will follow up with
	# cygpath to push it all the way to WinNT format.
	#


	#
	# The following mess is pseudo-code documentation for the
	# bash script which is executed to do the translation.
	#
	# The real code follows right after this mess.
	#
	
	# Split the passed path into directory and filename parts.
	#path=$bash_path ; \
	#if test -d $path ; \
	#then \
	#	dir=$path ; \
	#	name= ; \
	#else \
	#	dir=`dirname $path` ; \
	#	name=`basename $path` ; \
	#fi ; \
	# Tell bash to expand symbolic links fully.
	#set -P ; \
	# We must be careful, the passed path may refer to a directory
	# that does not exist.  Bash will not translate the symbolic
	# links in that case.
	#if test -d $dir ; \
	#then \
		# Good, we can use bash directly to translate.
		#cd $dir ; \
		#dir=`pwd` ; \
	#else \
		# Rats, travel backwards up the path looking for
		# a directory that does exist, we can have bash
		# translate from there and then just append the rest.
		#while test dir != / ; \
		#do \
			# Move up one directory level.
			#name=`basename $dir`/$name ; \
			#dir=`dirname $dir` ; \
			# If this one exists, use bash to translate
			# and stop looping.
			#if test -d $dir ; \
			#then \
				#cd $dir ; \
				#dir=`pwd` ; \
				#break ; \
			#fi ; \
		#done ; \
	#fi ; \
	# Now use cygpath to translate the path after symbolic
	# link names have been removed.
	#if test x$name = x ; \
	#then \
		# We have a pure directory name.
		#cygpath -w $dir ; \
	#else \
		#if test $dir != / ; \
		#then \
			# We have an expanded directory name,
			# and some other stuff to tack on.
			#cygpath -w $dir/$name ; \
		#else \
			# We are at the root.
			#cygpath -w /$name ; \
		#fi ; \
	#fi

	#cmd='bash -c "path=' + bash_path + ' ; if test -d $path ; then dir=$path ; name= ; else dir=`dirname $path` ; name=`basename $path` ; fi ; set -P ; if test -d $dir ; then cd $dir ; dir=`pwd` ; else while test dir != / ; do name=`basename $dir`/$name ; dir=`dirname $dir` ; if test -d $dir ; then cd $dir ; dir=`pwd` ; break ; fi ; done ; fi ; if test x$name = x ; then cygpath -w $dir ; else if test $dir != / ; then cygpath -w $dir/$name ; else cygpath -w /$name ; fi ; fi"'
	#tmp = os.popen(cmd)
	#nt_path = tmp.readline()[0:-1]
	#err = tmp.close()
	#if (err) or (len(nt_path) == 0):
	#	print "ERROR: could not translate path:", bash_path
	#	sys.stdout.flush()
	#	return bash_path
	
	# If the passed path had a slash at the end, keep it.
	#if ((bash_path[-1] == "/") or (bash_path[-1] == "\\")) and (nt_path[-1] != "\\"):
	#	nt_path = nt_path + "\\"

	#return nt_path

	#
	# Remove any "//"s from the filename
	#

	bash_path = bash_path[0:1] + regsub.gsub("//", "/", bash_path[1:])

	#
	# Parse through the mount table and see if it contains
	# something relavent to us
	#

	load_mount_table()

	global mount_table
	def len_compare (arg1, arg2):
		return cmp(len(arg2), len(arg1))
	mount_list = mount_table.keys()
	mount_list.sort(len_compare)
	for unix_prefix in mount_list:

		#
		# Something funny goes on in how regex parses its second argument. The upshot
		# is I need to add a second "\\"  to the start if a "\" is the leading
		# character in the replacing string. Hmm.
		#

		if mount_table[unix_prefix][0] == "\\":
			add_on = "\\"
		else:
			add_on = ""
		bash_path = regsub.gsub ("^" + unix_prefix, add_on + mount_table[unix_prefix], bash_path)

	bash_path = regsub.gsub("/", "\\", bash_path)

	bash_path = remove_symlink_dirs (bash_path)

	return bash_path

#
# remove_symlink_dirs
#
#  If any of the directories are symlinked, remove them!
# 
#  At one time I hoped you could do a quick bail if the file was found to exist.
#  Because you can have ".."s in the directory name, you cannot. :(
#
def remove_symlink_dirs (bash_path):

	#
	# Now do the work. We do this in an iterative fasion until there are
	# no more changes. We have to do this because symlink resolution could cause
	# other symlinks to enter into the path. Sigh.
	#

	#
	#  But first we try to use the geninc mechanism!
	#

	pubinc  = os.environ["SRT_PUBLIC_CONTEXT"]  + "/include"
	privinc = os.environ["SRT_PRIVATE_CONTEXT"] + "/include"
	inc_pat = pubinc + "$|" + privinc + "$"
	inc_pat = re.sub("/", "\\\\", inc_pat)
	if re.search(inc_pat, bash_path):
		bash_path = bash_path[0:-8] + "\\geninc\\" + os.environ["SRT_SUBDIR"]
		return bash_path
	
	#
	#  Now try it the way outlined above.
	#
	
	old_bash_path = ""
	resolved_dir = bash_path
	while old_bash_path != resolved_dir:
		old_bash_path = resolved_dir
		resolved_dir = remove_one_level_symlink_dirs (resolved_dir)

	return resolved_dir

#
# remove_one_level_symlink_dirs
#
#  Walk through the directory list, and remove one level of symbolic links.
#
def remove_one_level_symlink_dirs (bash_path):
	#
	# Look in the cache to see if this has been done already
	#

	global cache_enable
	if cache_enable:
		global alias_cache
		if alias_cache == 0:
			alias_cache = srt_ntbash_cache.srt_cache_alias_res()

		if alias_cache.has_key (bash_path):
			return alias_cache.lookup (bash_path)

	#
	# Ok, split up into all the directories, and then move through the thing
	# slowly. Special case a disk name. Otherwise, check to make sure everyone
	# is a dir. If it isn't, and no file exists, then we have a bogus guy. Ignore it!
	#

	dirlist = string.split (bash_path, "\\")
	resolved_dir = ""
	split_char = ""
	for dir_name in dirlist:
		next_dir_name = dir_name
		if dir_name == "":
			i = 10
		else:
			if string.find(dir_name, ":") == -1:
				temp_name = resolved_dir + split_char + dir_name
				if not os.path.isdir(temp_name):
					if os.path.exists(temp_name):
						translation = symbolic_link_resolution (temp_name)
						if translation != "":
							if is_absolute_path (translation):
								split_char = ""
								next_dir_name = ""
								resolved_dir = translation
							else:
								next_dir_name = translation

		resolved_dir = resolved_dir + split_char + next_dir_name
		split_char = "\\"

	#
	# Before returning the result, cache it for next time!
	#

	if cache_enable:
		alias_cache.cache (bash_path, resolved_dir)
		alias_cache.write_db()

	return resolved_dir


#
# is_absolute_path
#
#  Is the argument we've been handed an absolute path?
#
def is_absolute_path (path_name):
	if string.find (path_name, ":") != -1:
		return 1
	if (path_name[0:1] == "/") or (path_name[0:1] == "\\"):
		return 1
	return 0

#
# is_symbolic_link
#
#  Given the current filename, figure out if it is a symbolic link.  If not, return a "",
#  otherwise, return the target.
#
def symbolic_link_resolution (link_name):

	link_target = ""
	
	#
	# CYGWIN symbolic links do not have a ".xxx" type extension
	#

	(dir_root, directory_name) = os.path.split (link_name)
	if string.find (directory_name, ".") == -1:
		try:
			sym_file = open (link_name, "r")
			sym_indicator_text = sym_file.read (10)
			if sym_indicator_text == "!<symlink>":
				rest_of_line = sym_file.readline()
				temp = string.find(rest_of_line, "\000")
				rest_of_line = rest_of_line[:temp]
				link_target = os.path.join (dir_root, translate_path (rest_of_line))
			sym_file.close()
		except:
			link_target = ""
	return link_target

#
# resolve_bash_aliases
#
#  As it stands here we don't have anything like an alias, so we have
# to fake the system out. Examine the current directory. If the path
# is a directory, then look to see if there is a directory alias in it.
# Return a list (perhaps just the original path) of the directories.
#
#  We expect a fully translated path as input, and only give translated paths as
# output.
#
def resolve_bash_aliases (nt_dir_path):

	#
	# First, check the cache
	#

	global cache_enable
	if cache_enable:
		global sym_link_cache
		if sym_link_cache == 0:
			sym_link_cache = srt_ntbash_cache.srt_cache_sym_link()

		if sym_link_cache.has_key (nt_dir_path):
			return sym_link_cache.lookup (nt_dir_path)

	#
	# Ok -- it wasn't in the cache. Next we will have to actually go out and
	# construct it. This can be expensive when the item sits on a server.
	#

	path_list = [nt_dir_path]

	if os.path.isdir(nt_dir_path):
		dir_list = os.listdir(nt_dir_path)
		for a_dir in dir_list:
			link_target = symbolic_link_resolution (os.path.join(nt_dir_path, a_dir))
			if link_target != "":
				if link_target[len(link_target)-1:len(link_target)] != "\\":
					link_target = link_target + "\\"
				link_target = link_target + ".."
				path_list.append(translate_path(link_target))

	#
	# Before handing it back, cache the result for next time
	#

	if cache_enable:
		sym_link_cache.cache (nt_dir_path, path_list)
		sym_link_cache.write_db()

	return path_list

#
#  compress_path
#
#  Remove the ".."s if we can, and other things like that. "."s too.
#
#  We expect a fully done out nt path name.
#
def compress_path (nt_path):
	nt_dir_list = string.split (nt_path, "\\")
	nt_compressed_list = []

	for nt_dir in nt_dir_list:
		if nt_dir == ".":
			i = 10
		elif nt_dir == "..":
			last_item = len(nt_compressed_list)
			if last_item > 0:
				del nt_compressed_list[last_item-1:last_item]
			else:
				nt_compressed_list.append (nt_dir)
		else:
			nt_compressed_list.append (nt_dir)

	return string.join (nt_compressed_list, "\\")

#############################
# set_cache_enable -- should we use our caches?
#
def set_cache_enable (enable):
	global cache_enable
	cache_enable = enable

