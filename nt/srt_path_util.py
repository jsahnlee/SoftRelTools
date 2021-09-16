#
# path_util.py
#
#  Some nice path utilities... really, these should have been part of the posixpath module in python.
#
#  Created November 1997 Gordon Watts (Brown)
#

import os
import sys
import string
import regex
import regsub

import srt_ntbashutil

#
# get_relative_path
#
#  Simple dude to extract a relative path from two paths
#
def get_relative_path (the_path, base_path):

	#
	# Dumb special case
	#

	if the_path == base_path:
		return "."

	#
	# There is a bug in commonprefix... it doesn't do it by directory, but, rather
	# by string... so it can cut off in the middle of a directory (!!!!!). Actually,
	# the docs say that that is what it is meant to do, but geez!
	#

	common_path = os.path.commonprefix ([the_path, base_path])
	index = len(common_path)
	index = string.rfind (the_path[:index+1], "\\")
	if index == -1:
		index = 0

	common_path = the_path[:index]
	l_path =  the_path[index+1:]
	l_base = base_path[index+1:]

	#
	# Make sure they had something in common, or this isn't going to work!
	#

	if common_path == "":
		raise "Path '" + the_path + "' and base path '" + base_path + "' have nothing in common, so cannot be made relative!"

	#
	# Add a set of ".."s to the start of l_path for each directory there is in
	# l_base. That should do it!
	#

	while (l_base != "\\") and (l_base != ""):
		(l_base, fragment) = os.path.split (l_base)
		l_path = "..\\" + l_path

	return l_path

#
# find_file_in_PATH
#
#  Search the PATH environ var for a certian file. Report back the filename if we find it, a null
#  string if we can't.
#
def find_file_in_PATH (filename):
	return find_file_in_search_string (filename, os.environ["PATH"])

#
# find_file_in_search_string
#
#  Find a file in a given search string. The seperator is the default for this platform (os.pathsep).
#
def find_file_in_search_string (filename, search_dir_string):
	search_list = string.split (search_dir_string, os.pathsep)
	search_list.insert (0, "./")

	for search_path in search_list:
		file_to_look_for = search_path + os.sep + filename
		if os.path.exists (file_to_look_for):
			return file_to_look_for

#
# change_to_type
#
#  Change the file extension of a given path
#
def change_to_type (old_path, new_type):
	(base_dir, fname) = os.path.split (old_path)
	new_fname = regsub.gsub("\.[^\.]*$", "." + new_type, fname)
	return os.path.join (base_dir, new_fname)

#
# file_type
#
#  Return the filetype of the handed path.
#
def file_type (the_path):
	(base_dir, fname) = os.path.split (the_path)
	temp = regex.compile (".*\.\([^\.]*\)$")
	if temp.match(the_path) != -1:
		return temp.group(1)
	return ""

#
# path_to_unix
#
#  Convert from NT to unix path -- just change the \ to /s
#
def path_to_unix (the_path):
	return regsub.gsub("\\\\", "/", the_path)
