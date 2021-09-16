#
# parse_dependency_file_t.py
#
#  Test out the dependency file parser
#

import parse_dependency_file

list = parse_dependency_file.parse_dependency_file("parse_dependency_file_t.d", "thread_util")

print "Found the following guys:"

for item in list:
	print " " + item

print "done"
