#
# srt_ntide_list_set_t.py
#
#  Some tests to run on the srt_ntide_list_set guy.
#

import srt_ntide_list_set

def dump_list_set (obj):
	lst = obj.get_list()
	for item in lst:
		print item, 

def dump_list (lst):
	for item in lst:
		print item, 

def test1():
	l1 = ["opt1", "opt2", "opt3"]
	l2 = ["opt1", "opt2", "opt3"]

	obj=srt_ntide_list_set.srt_ntide_list_set()
	obj.intersection (l1)
	obj.intersection (l2)

	print "options 1, 2, and 3:",
	dump_list_set (obj)
	print

	l3 = ["opt1", "opt2", "opt3", "opt4"]
	print "Difference with 4 items should give one:",
	dump_list (obj.difference(l3))
	print

	print "Difference with l1 should give nothing:",
	dump_list (obj.difference(l2))
	print

	print "2 item list (1 common), contents now:",
	l4 = ["opt1", "opt5"]
	obj.intersection (l4)
	dump_list_set (obj)
	print

	print "diff with 2, one diff (at start):",
	l5 = ["opt6", "opt1"]
	dump_list (obj.difference(l5))
	print

	print "Adding list with opt6 and opt1:",
	obj.add(l5)
	dump_list_set (obj)

test1()
