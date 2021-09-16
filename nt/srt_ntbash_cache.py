#
# srt_ntbash_cache.py
#
#  Cache the results of ntbashutil's directory scans. When running across a server
# this can really speed things up.
#
#  BAD NEWS: there is a circular dependence here.  BAD software design. It works,
#  but reall the bashutil should be pulled apart into two different bits. One that
#  uses caches and one that does not. Unfortunately, this means a rewrite of some
#  large sections of the code. :(
#

import os
from stat import *
import pickle
import srt_ntbashutil

class srt_cache:
	def __init__ (self, filename):
		self._filename = filename
		self._sym_link_cache = {}
		self._sym_link_date = {}
		self.load_db()

	#
	# load_db -- Load the database in. If we fial to open the file or the data in the
	#  file is bogus. We leave the filealone. When we go to write out the data, we will
	#  update the bogus file with something new and correct.
	#
	def load_db(self):
		if os.path.exists (self._filename):
			try:
				cache_file = open (self._filename, "r")
				self._sym_link_cache = pickle.load (cache_file)
				self._sym_link_date = pickle.load (cache_file)
				cache_file.close()
			except:
				self._sym_link_cache = {}
				self._sym_link_date = {}
	
	#
	# write_db -- write the database out. Sometimes someone else has this open while
	#  we are trying to read it. In that case, we will just ignore this, and loose the
	#  new info we have on the cache.
	#
	def write_db (self):
		try:
			cache_file = open (self._filename, "w")
			pickle.dump (self._sym_link_cache, cache_file)
			pickle.dump (self._sym_link_date, cache_file)
			cache_file.close()
		except:
			pass

	def lookup (self, the_key):
		if self.is_valid_entry(the_key):
			return self._sym_link_cache[the_key]
		return ""

	def cache (self, the_key, value):
		self._sym_link_cache[the_key] = value
		if os.path.exists(the_key):
			self._sym_link_date[the_key] = os.stat(the_key)[ST_MTIME]
		else:
			self._sym_link_date[the_key] = 0

	def delete (self):
		os.remove (self._filename)

	def has_key (self, key_name):
		return self.is_valid_entry (key_name)

	def is_valid_entry (self, key_name):	# Check the date on the file matches the cache
		if not self._sym_link_date.has_key(key_name):
			return 0
		if not os.path.exists (key_name):
			return 1

		file_mod_time = os.stat(key_name)[ST_MTIME]
		return file_mod_time <= self._sym_link_date[key_name]


############
#
# srt_cache_sym_link -- meant to hold symbolic links. It is just done like
# this to encapsulate the file name stuff

class srt_cache_sym_link (srt_cache):
	def __init__ (self):
		filename = "c:\\temp\\sym_link_default.python_db"
		if os.environ.has_key("SRT_SYM_CACHE_FILE"):
			filename = os.environ["SRT_SYM_CACHE_FILE"]
			srt_ntbashutil.set_cache_enable(0)
			filename = srt_ntbashutil.translate_path(filename)
			srt_ntbashutil.set_cache_enable(1)

		srt_cache.__init__ (self, filename)

############
#
# srt_cache_alias_res -- meant to hold resolution of aliases
#

class srt_cache_alias_res (srt_cache):
	def __init__ (self):
		filename = "c:\\temp\\alias_resolution_default.python_db"
		if os.environ.has_key("SRT_ALIAS_CACHE_FILE"):
			filename = os.environ["SRT_ALIAS_CACHE_FILE"]
			srt_ntbashutil.set_cache_enable(0)
			filename = srt_ntbashutil.translate_path(filename)
			srt_ntbashutil.set_cache_enable(1)

		srt_cache.__init__ (self, filename)
