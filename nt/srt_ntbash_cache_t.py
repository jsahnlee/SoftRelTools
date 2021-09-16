#
# srt_ntbash_cache_test.py
#
#  Test out the cache stuff
#

import os
from stat import *
import srt_ntbash_cache
import srt_ntbashutil

def main():

	test_db = srt_ntbash_cache.srt_cache ("")
	test_db.cache ("dork", "mama")
	print "Simple Cache Test: " + test_db.lookup("dork")

	cache_db_file = "c:\\temp\\junk.python_db"

	def simple_write(cache_db_file):
		cache_db = srt_ntbash_cache.srt_cache (cache_db_file)
		cache_db.cache ("test", "you dude")
		print "Got back for key test: " + cache_db.lookup ("test")
		test = ["hi", "there", "me"]
		cache_db.cache ("list", test)

		cache_db.write_db()

	simple_write(cache_db_file)

	cache_db = srt_ntbash_cache.srt_cache (cache_db_file)
	print "Got back after read file " + cache_db.lookup ("test")

	test_list = cache_db.lookup("list")
	print "From list I found:"
	for item in test_list:
		print " " + item

	print "Has key test (should): ", cache_db.has_key("test")
	print "Has key bogus (shouldn't): ", cache_db.has_key("bogus")

	print "Going to test out srt_ntbash_cache stuff now"
	print " Creating a temp directory called junk in local directory"

	if not os.path.exists ("junk_dir"):
		os.system ("bash --norc -c \"mkdir junk_dir\"")
	if os.path.exists("junk_dir/link1"):
		os.unlink ("junk_dir/link1")
	if os.path.exists("junk_dir/link2"):
		os.unlink ("junk_dir/link2")
	if os.path.exists("junk_dir/link3"):
		os.unlink ("junk_dir/link3")
	
	os.system ("bash --norc -c \"ln -s  srt_ntbash_cache_t.py junk_dir/link1\"")
	os.system ("bash --norc -c \"ln -s  srt_ntbash_cache_t.py junk_dir/link2\"")

	translated_path = srt_ntbashutil.translate_path ("junk_dir")
	print " Links found (should be 2 extra):"
	nt_path_list = srt_ntbashutil.resolve_bash_aliases (translated_path)
	for path in nt_path_list:
		print "  Resolved to: " + path

	m_old_time = os.stat("junk_dir")[ST_MTIME]
	os.system ("bash --norc -c \"ln -s  srt_ntbash_cache_t.py junk_dir/link3\"")
	m_new_time = os.stat("junk_dir")[ST_MTIME]

	print "Old Mod Time: ", m_old_time, " and new mod time: ", m_new_time
	print " Difference: ", m_new_time - m_old_time

	print " Links found after third link created (should be 3 extra):"
	nt_path_list = srt_ntbashutil.resolve_bash_aliases (translated_path)
	for path in nt_path_list:
		print "  Resolved to: " + path

	sym_cache = srt_ntbash_cache.srt_cache_sym_link()
	sym_cache.cache ("hi", "bogus!")
	sym_cache.write_db()

	print "Open cache file for reading, and try to write cache. No errors should occur..."
	temp_file = open (cache_db_file, "r")
	cache_db.write_db()
	temp_file.close()

	print "Open cache file for writing, and try to read the cache. No errors should occur,"
	print " and the db should be empty"
	temp_file = open (cache_db_file, "w")
	cache_db.load_db()
	print " test lookup is ->" + cache_db.lookup ("test") + "<-..."
	temp_file.close()

main()