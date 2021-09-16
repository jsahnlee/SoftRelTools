#
# srt_options_line.py
#
#  Help with parsing an options line. Really simple stuff, actually; does some help with doing
#  the error detection, etc.
#
#  Created November 1997 Gordon Watts (Brown)
#

import string

class options_line:
	def __init__ (self, arg_line):
		self._arg_list = arg_line
		self._index = 0

	def length (self):
		return len(self._arg_list)

	def get_next_option (self, name):
		if self._index >= self.length():
			raise "Missing option " + name
		result = self._arg_list[self._index]
		self._index = self._index + 1
		return result

	def has_more_options (self):
		return self._index < self.length()
