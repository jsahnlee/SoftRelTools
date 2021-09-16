#
# srt_ntide_list_set.py
#
#  Holds a set of options or include directories or the like. Allows operations on
# them, like union, difference, intersection. This makes management of options lists
# much simpler (I hope).
#

class srt_ntide_list_set:

	def __init__ (self):
		self._list = []			# Master list of what we are keeping track of
		self._list_valid = 0	# 0 till we have had something put in at least once

	#
	# intersection -- _list = _list intersect arg. If list_valid is zero, then _list = arg.
	#
	def intersection (self, arg_list):
		if self._list_valid == 0:
			self._list_valid = 1
			for item in arg_list:
				self._list.append(item)
		else:
			i = 0
			while i < len(self._list):
				if self._list[i] not in arg_list:
					del self._list[i]
				else:
					i = i + 1

	#
	# difference -- Assumed that _list is a subset of arg_list. Returns the extra stuff in arg_list
	#
	def difference (self, arg_list):
		result = []
		i = 0
		while i < len(arg_list):
			if arg_list[i] not in self._list:
				result.append (arg_list[i])
			i = i + 1
		return result

	#
	# get_list -- Return the list
	#
	def get_list (self):
		return self._list

	#
	# add -- just add items to the internal list if they haven't been already
	#
	def add (self, arg_list):
		for item in arg_list:
			if item not in self._list:
				self._list.append(item)
		self._list_valid = 1
