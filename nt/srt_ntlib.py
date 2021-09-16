#!python
#
#  srt_ntlib.py
#
#  Translate a "ar" UNIX command into a lib command on the NT system. If the environment
#  var IDE_DUMP is defined (as a filename) write the command to the IDE_DUMP file for later
#  processing.
#
#  Because of the way the MS compilers operate, we keep two libraries going. One is a standard .a
#  file built by the cygwin ar command. This contains a bunch of modules, all short dummy files,
#  so that gmake can still parse the dates of modules in libraries correctly. The true object
#  is put in the .lib file. If you look at the output, you'll see both of these guys.
#
#  See the file srt_ntbashutil.py for other info on restrictions on things like filenames, etc. If
#  there is a new ar flag that must be supported, then you must add it here.
#
#  Created November 1997 Gordon Watts (Brown)
#

import sys
import os
import string
import regex
import regsub

import srt_options_line
import srt_ntbashutil
import srt_path_util
import srt_ntide_dummy_files

#
# Main program to translate from UNIX's ar options to msvc's LIB options
#

def main():
	#
	# Get the command line up and going
	#

	cmd_options = srt_options_line.options_line (sys.argv[1:])

	if cmd_options.length() == 0:
		print "Usage: " + sys.argv[0] + " <arguments>"
		return 1

	nt_cmd_line = "/nologo "
	ar_cmd_line = ""

	temp_files = [];
	if os.environ.has_key("temp"):
		temp_dir = os.environ["temp"]
	else:
		temp_dir = os.environ["TEMP"]

	#
	# Are we dumping for IDE stuff, or actually executing the command?
	#

	do_ide_dump = 0
	if os.environ.has_key("IDE_DUMP"):
		sys.stdout = open (srt_ntbashutil.translate_path(os.environ["IDE_DUMP"]), "a+")
		do_ide_dump = 1

	#
	# Init some flags
	#

	execute_commands = 1

	#
	# The lib command first has an option, which determines its overall behavior.
	#

	master_options = cmd_options.get_next_option ("LIB Command Option")
	while master_options[0] == "-":
		option = master_options[1:]
		if option == "NTNoRun":
			execute_commands = 0
		else:
			sys.stderr.write ("***ERROR: Unknown option " + option + ".\n");
			return 1
		master_options = cmd_options.get_next_option ("LIB Command Option")

	master_directive = master_options[0]

	#
	# Dump out for the IDE?
	#

	if do_ide_dump:
		print "->IDE<- *library"
		print "->IDE<-  working_dir " + os.getcwd()
		if os.environ.has_key("CURPKG"):
			print "->IDE<-  package_name " + os.environ["CURPKG"]

	#
	# Now, start in for sure!
	#

	if master_directive == "r":

		if do_ide_dump:
			print "->IDE<-  add_and_create"

		#
		# Update. Make sure the library is an input file if it already exists!
		#

		lib_file_raw = cmd_options.get_next_option ("Library filename")
		ar_lib_file = srt_ntbashutil.translate_path (lib_file_raw)
		nt_lib_file = srt_path_util.change_to_type (ar_lib_file, "lib")

		nt_cmd_line = nt_cmd_line + "/out:" + nt_lib_file + " "
		ar_cmd_line = "r " + lib_file_raw + " "

		if do_ide_dump:
			print "->IDE<-  library_file " + nt_lib_file

		#
		# It should never be the case that we have a .a file but no .lib file. If we do, then
		# get rid of the .a file and crash. If we have no .a file but a .lib file, just delete
		# the .lib file.
		#

		nt_exists = os.path.exists (nt_lib_file)
		ar_exists = os.path.exists (ar_lib_file)

		if nt_exists and (not ar_exists):
			os.remove (nt_lib_file)
			nt_exists = 0

		if (not nt_exists) and ar_exists:
			os.remove (ar_lib_file)
			print "*** ERROR: .a file exists but there is no matching .lib file! Restart build!"
			return 100

		#
		# If the .lib file is there, we need to make sure that the NT lib utility reads it as input
		# so the output files is really just the input + a new module!
		#

		if nt_exists:
			nt_cmd_line = nt_cmd_line + nt_lib_file + " "

		#
		# Now, process all the extra files on the command line to add them to the library.
		# Into the ar archive put a dummy text file.
		#

		while cmd_options.has_more_options():
			file_to_add_raw = cmd_options.get_next_option ("File to insert")
			file_to_add = srt_ntbashutil.translate_path (file_to_add_raw)

			#(base_dir, fname) = os.path.split (file_to_add_raw)
			#temp_file_name = os.path.join (temp_dir, fname)
			#temp_files.append (temp_file_name)
			#t_handle = open (temp_file_name, "w")
			#t_handle.write ("This is a dummy file")
			#t_handle.close ()

			nt_cmd_line = nt_cmd_line + file_to_add + " "
			ar_cmd_line = ar_cmd_line + file_to_add_raw + " "

			if do_ide_dump:
				if regex.search("^/.*$", file_to_add_raw) == 0:
					print "->IDE<-  add_file " + file_to_add
				else:
					print "->IDE<-  add_file " + os.getcwd() + "\\" + file_to_add

	else:
		print "*** WARNING: Unrecognized option to the ntlib command!"
		return 1;

	#
	# If this is only a dummy, only do the ar command, not the lib
	#

	result = 0
	if not do_ide_dump:
		if execute_commands:
			result = os.system ("lib " + nt_cmd_line)
		else:
			print "Execute: lib " + nt_cmd_line
	else:
		if not nt_exists:
			n_lib_handle = open (nt_lib_file, "w")
			n_lib_handle.write ("this is a test")
			n_lib_handle.close()
			srt_ntide_dummy_files.record_temp_file (nt_lib_file)

	if (result == 0):
		if execute_commands:
			result = os.system ("ar " + ar_cmd_line)
		else:
			print "Execute: ar " + ar_cmd_line

	#
	# Get rid of any of the temporary files that were created!
	#

	for temp_name in temp_files:
		if os.path.exists (temp_name):
			os.remove (temp_name)

	#
	# Flush the output stream. Have to do this due to a possible bug in cygwin (b18)'s bash shell
	# in which gmake's output is redirected to a file... this guy's output seems to dissapear.
	#

	sys.stdout.close()

	return result

#
# Execute the routine and let the shell know what happened.
#
if __name__ == '__main__':
	result = main()
	sys.stdout.close()
	os._exit(result)
