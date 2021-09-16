#!python
#
# srt_ntbashutil_test.py
#
#  This is a first attempt at a test file for the srt_ntbashutil.py file and srt_path_util.py
#  file. The two files contain several complex bash->NT file conversion routines, with
#  lots of twisted logic (aliases, etc.). I had to write a test file to make sure I was
#  getting the known problem spots right. This is it. It should be improved upon: at
#  the moment it references some stuff in my personal directory. You won't get errors
#  when that happens, but it could look better!
#
#  Gordon Watts
#

import srt_ntbashutil
import srt_path_util

def main():

	print "Translating /users/gwatts"
	print srt_ntbashutil.translate_path("/users/gwatts")
	print ""

	print "Translating /d0dist/dist/releases/test/doc"
	print srt_ntbashutil.translate_path("/d0dist/dist/releases/test/doc")
	print ""

	print "Translating /users/gwatts/d0/cvs_code/test_srt/ide_dump.txt"
	print srt_ntbashutil.translate_path("/users/gwatts/d0/cvs_code/test_srt/ide_dump.txt")
	print ""

	print "Translating /users/gwatts/d0/cvs_code/test_srt/include"
	print srt_ntbashutil.translate_path("/users/gwatts/d0/cvs_code/test_srt/include")
	print ""

	print "Doing symbolic link list /users/gwatts/d0/cvs_code/test_srt/include"
	bash_list = srt_ntbashutil.resolve_bash_aliases (srt_ntbashutil.translate_path("/users/gwatts/d0/cvs_code/test_srt/include"))
	for a_item in bash_list:
		print a_item
	print ""

	print "Doing symbolic link in release /d0dist/dist/releases/nt00.08.00/CINT/CINT"
	bash_trans = srt_ntbashutil.translate_path("/d0dist/dist/releases/nt00.08.00/CINT/CINT")
	bash_list = srt_ntbashutil.resolve_bash_aliases (bash_trans)
	for a_item in bash_list:
		print a_item
		print " "
	print "\n"

	print "Doing translation /d0dist/dist/releases/nt00.08.00/include/../CINT/CINT"
	bash_trans = srt_ntbashutil.translate_path("/d0dist/dist/releases/nt00.08.00/include/../CINT/CINT")
	print bash_trans
	print "\n"

	print "Doing symbolic link in release /d0dist/dist/releases/nt00.08.00/include/CINT"
	bash_trans = srt_ntbashutil.translate_path("/d0dist/dist/releases/nt00.08.00/include/CINT")
	bash_list = srt_ntbashutil.resolve_bash_aliases (bash_trans)
	for a_item in bash_list:
		print a_item
	print "\n"

	print "Doing symbolic link list /d0dist/dist/releases/test/include"
	print " * Path relative to /d0dist/dist"
	print " > Path relative to /users/gwatts"
	t_source = srt_ntbashutil.translate_path("/d0dist/dist/releases/test/include")
	bash_list = srt_ntbashutil.resolve_bash_aliases (t_source)

	for a_item in bash_list:
		c_path = srt_ntbashutil.compress_path(a_item)
		print c_path
		print " * " + srt_path_util.get_relative_path (c_path, srt_ntbashutil.translate_path("/d0dist/dist"))
		r_path = c_path
		try:
			r_path = srt_path_util.get_relative_path (c_path, srt_ntbashutil.translate_path("/users/gwatts"))
		except:
			i = 10
		print " > " + r_path
	print ""

	print "Looking for template file found via path var"
	print " Resolution is " + srt_path_util.find_file_in_PATH ("srt_ntide_project_lib.template")

def do_me():
	import profile
	profile.run('main()','testprof')

main()
#do_me()