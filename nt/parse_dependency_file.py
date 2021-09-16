#
# parse_dependency_file.py
#
#  This will parse a dependency file and return only those items
# in it that have a certian string in them.
#

import regex
import string

def parse_dependency_file (filename, find_it):
	d_file = open (filename, "r")
	result = []

	line = " "
	while line != "":
		line = d_file.readline()
		line_list = string.split(line, " ")
		for item in line_list:
			if regex.match("^.*" + find_it + ".*$", item) != -1:
				result.append (item)
	d_file.close()

	return result