#
# ide_dump_file.py
#
#  Object to help with reading in the ide file that was written by the various srt_ntcc, srt_ntlib, etc.
# files when the IDE_DUMP envrionment varriable was defined. This parses out extra lines, and strips off
# the flag that denotes a line we need to pay attention to. This guy also does look ahead to help determine
# when one command is over and the next is beginning.
#
#  Created November 1997 Gordon Watts (Brown)
#

import regex

class ide_dump_file:
	def __init__ (self, filename):
		self._handle = open (filename, "r")
		self._buffer = ""
		self._valid_buffer = 0
		self._eof = 0
		self._ide_pat = regex.compile("^->IDE<- *\(\*\|\)\(.*\)\n$")


	def __del__ (self):
		self._handle.close()


	#
	# get_line
	#
	#	Return a line of text
	#
	def get_line (self):
		if not self.load_buffer():
			raise "Error reading from ide dump file"
		self._valid_buffer = 0
		return self._buffer

	#
	# load_buffer
	#
	#  Make sure the buffer has the next line in it. Remove the trailing newline
	#  and the ->IDE<- moniker. Ignore lines that the moniker on them, btw.
	#
	def load_buffer (self):
		if self._valid_buffer:
			return 1
		if self._eof:
			return 0

		while (not self._valid_buffer) and (not self._eof):
			try:
				self._buffer = self._handle.readline()
				self._valid_buffer = self._buffer != ""
				self._eof = not self._valid_buffer
			except:
				self._eof = 1

			if self._valid_buffer:
				if self._ide_pat.match(self._buffer) != -1:
					self._buffer = self._ide_pat.group(2)
					self._is_new_block = self._ide_pat.group(1) == "*"
				else:
					self._valid_buffer = 0


		return not self._eof

	#
	# there_is_more
	#
	#  return true if there is another valid IDE line in the file.
	#
	def there_is_more (self):
		return self.load_buffer()

	#
	# is_star_line
	#
	#  True if this line started out with a star. This guy is a little tricky -- only
	#	valid for the last returned line.
	#
	def is_star_line (self):
		return self._is_new_block
