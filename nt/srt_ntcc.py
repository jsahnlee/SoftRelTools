#!python
#
#  Python file to translate a gcc command line into a microsoft
#  command line
#
#  If the environment varialbe IDE_DUMP is set (should evaultate to a filename),
#  then IDE commands will be written to that file and a dummy output file will be
#  created. This is to help with the conversion between the gmake and the ide.
#
# If people want to use a new compiler flag, then they will have to
# modify this guy to support it. Sorry; just is no other way.
#
#  See the restriction in the srt_ntbashutil.py file for further warnings.
#
# For testing purposes there is a flag NTNoRun. That will just print out the command
# line (if that is what is supposed to happen!).
#
#  Created November 1997 Gordon Watts (Brown)
#

import sys
import os
import string
import regex
import regsub
import tempfile

import srt_options_line
import srt_ntbashutil
import srt_path_util
import parse_dependency_file
import srt_ntide_dummy_files

#
# Main program to translate from gcc options to msvc options
#

def main():

	#
	# Setup and make sure command line stuff is there and cool.
	#

	cmd_options = srt_options_line.options_line (sys.argv[1:])

	if cmd_options.length() == 0:
		sys.stderr.write("Usage: " + sys.argv[0] + " <arguments>\n")
		return 1

	cmd_line = ""
	link_line = ""
	link_line_valid = 1

	nt_output_file = ""

	#
	# By default we will be executing this hole thing!
	#

	no_run = 0

	#
	# The local path cache varriable
	#

	local_path = ""

	#
	# Keep track of source files and link files. If we have no source files, then we had better just invoke the
	# link command!
	#

	n_source_files = 0
	n_link_files = 0

	#
	# Are we dumping for IDE stuff, or something else?
	#

	do_ide_dump = 0
	if os.environ.has_key("IDE_DUMP"):
		f_name = srt_ntbashutil.translate_path(os.environ["IDE_DUMP"])
		sys.stdout = open (f_name, "a+")
		do_ide_dump = 1

	#
	# Now, loop over all the arguments in the command line.
	#

	if do_ide_dump:
		print "->IDE<- *compile"
		print "->IDE<-  working_dir " + os.getcwd()
		current_package = ""
		if os.environ.has_key("CURPKG"):
			current_package = os.environ["CURPKG"]
			print "->IDE<-  package_name " + current_package

	while cmd_options.has_more_options():
		option = cmd_options.get_next_option ("this should never fail!")
		if option[0] == "-":
			option = option[1:]
			#
			# I -- An include file
			#

			if option[0] == "I":
				raw_path = option[1:]
				if not srt_ntbashutil.is_absolute_path(raw_path):
					if local_path == "":
						local_path_h = os.popen("pwd", "r")
						buffer = local_path_h.readline()
						local_path = buffer[:-1]
						local_path_h.close()
					raw_path = local_path + "/" + raw_path
				translated_path = srt_ntbashutil.translate_path (raw_path)
				nt_path_list = srt_ntbashutil.resolve_bash_aliases (translated_path)
				nt_path_list = fixup_no_conformist_includes (nt_path_list)
				if do_ide_dump:
					print "->IDE<- unix_include_file_path " + option[1:]
				for path in nt_path_list:
					c_path = srt_ntbashutil.compress_path(path)
					if c_path[-1] == "\\":
						c_path = c_path[:-1]
					cmd_line = cmd_line + "/I\"" + c_path + "\" "
					if do_ide_dump:
						print "->IDE<-  include_file_path " + c_path

			#
			# D -- Deifne a C macro symbol. This is a little touchy here.
			# Add a quote mark in the correct places in this guy.
			#

			elif option[0] == "D":
				eq_pat=regex.compile("^\([^\=]*\)\=\(.*\)$")
				if eq_pat.match(option[1:]) == -1:
					good_opt = option[1:]
				else:
					good_opt = eq_pat.group(1) + "=\"" + eq_pat.group(2) + "\""
				cmd_line = cmd_line + "/D" + good_opt + " "
				if do_ide_dump:
					print "->IDE<-  define_macro " + good_opt

			#
			# c -- Don't link, only compile (defualt for cl).
			#

			elif option[0] == "c":
				cmd_line = cmd_line + "/c" + " "
				link_line_valid = 0
				if do_ide_dump:
					print "->IDE<-  do_compile_only"

			#
			# g -- ignore the debug flag for now
			#

			elif option[0] == "g":
				#print "**"
				#print "** WARNING: Ignoring the debug 'g' flag."
				#print "**"
				stuff_place = 0

			#
			# o -- Remember the output file. Later, after we are done processing the
			# link line we can append it to the correct flag depending upon weather or
			# not this is just a compile or a compile and link.
			#

			elif option[0] == "o":
				raw_nt_output_file = cmd_options.get_next_option("output file name")
				nt_output_file = srt_ntbashutil.translate_path(raw_nt_output_file)

			#
			# Fd is the program database. Basically, pass right through, along with
			# a full blown filename translation. In the case of a IDE build, however,
			# this option gets ignored. The reason is that the IDE bases where to put the
			# db on its own internal temp directory, which is set as part of the build
			# process.
			#

			elif option[0:2] == "Fd":
				pdb_filename = option[2:]
				nt_pdb_filename = srt_ntbashutil.translate_path(pdb_filename)
				cmd_line = cmd_line + "/Fd" + nt_pdb_filename + " "

			elif option[0:2] == "FI":
				fi_filename = option[2:]
				nt_fi_filename = srt_ntbashutil.translate_path(fi_filename)
				cmd_line = cmd_line + "/FI" + nt_fi_filename + " "


			#
			# Pass through options -- these are really NT options, but we have to
			# use "-" instead of "/" when talking to them!
			#

			elif option[0:3] == "NTL":
				link_line = link_line + "/" + option[3:] + " "
				if do_ide_dump:
					print "->IDE<- link_option " + option[3:]

			elif option[0:2] == "NT":
				if option[2:] == "NoRun":
					no_run = 1
				else:
					cmd_line = cmd_line + "/" + option[2:] + " "
					if do_ide_dump:
						print "->IDE<-  option " + option[2:]
 
			elif option[0:1] == "L":
				link_line = link_line + "/libpath:" + srt_ntbashutil.translate_path(option[1:]) + " "
				link_line_valid = 1
				if do_ide_dump:
					print "->IDE<-  library_search_path " + srt_ntbashutil.translate_path(option[1:])

			#
			# A library -- add it on to the list. If it is one of the default libraries
			# just remove it from the link list (like the math library).
			#
			elif option[0:1] == "l":
				library_name = option[1:]
				if library_name != "m":
					link_line = link_line + "lib" + library_name + ".lib "
					link_line_valid = 1
					if do_ide_dump:
						print "->IDE<-  library lib" + library_name + ".lib"

			#
			# Game over. Wonder what this option was supposed to be?
			#

			else:
				sys.stderr.write("WARNING: Unkown gcc option in srt_ntcc.py!!: -" + option + "\n")
				return 1
		else:
			#
			# Got a plain file. If it is a .a file, change it to a .lib file. NT, of course,
			# uses .lib, while UNIX (dark ages) uses .a
			#

			nt_path = srt_ntbashutil.translate_path (option)
			if srt_path_util.file_type(nt_path) == "a":
				nt_path = srt_path_util.change_to_type (nt_path, "lib")

			file_type = srt_path_util.file_type(nt_path)
			force_cpp = 0
			if file_type == "cc":
				force_cpp = 1
				cmd_line = cmd_line + "/Tp " + nt_path + " "
				n_source_files = n_source_files + 1
			elif (file_type == "o") | (file_type == "obj") | (file_type == "lib"):
				link_line_valid = 1
				link_line = link_line + nt_path + " "
				n_link_files = n_link_files + 1
			else:
				cmd_line = cmd_line + nt_path + " " 
				n_source_files = n_source_files + 1
			
			#
			# We do something  a little different here if it is
			# a library -- we make sure mark a lib as a library.
			#
			if do_ide_dump:
				if file_type == "lib":
					print "->IDE<-  library " + nt_path
				else:
					if force_cpp == 1:
						print "->IDE<- source_file_cpp " + nt_path
					else:
						print "->IDE<-  source_file " + nt_path

	#
	# Do the output file correctly. This depends upon weather or not the link line
	# is valid
	#

	if nt_output_file != "":
		if link_line_valid:
			link_line = link_line + "/out:" + nt_output_file + " "
			if do_ide_dump:
				print "->IDE<-  build_app " + nt_output_file
		else:
			cmd_line = cmd_line + "/Fo" + nt_output_file + " "
			if do_ide_dump:
				print "->IDE<-  build_obj " + nt_output_file

		#
		# If we are building the file, make sure that any .d files that are
		# out there have their info put into the log file
		#

		if do_ide_dump:
			if (current_package != "") and (os.environ.has_key("SRT_TOP")):
				(dir, name) = os.path.split (nt_output_file)
				new_name = srt_path_util.change_to_type (name, "d")
				d_filename = os.environ["SRT_TOP"] + "/tmp/" + os.environ["BFARCH"] + "/" + current_package + "/" + new_name
				nt_d_filename = srt_ntbashutil.translate_path(d_filename)
				if os.path.exists(nt_d_filename):
					d_list = parse_dependency_file.parse_dependency_file (nt_d_filename, "/" + current_package + "/")
					for fname in d_list:
						if regex.match (".*/tmp/.*", fname) == -1:
							print "->IDE<- h_filename " + srt_ntbashutil.compress_path(srt_ntbashutil.translate_path (fname))

	#
	# If there were no source files and no link files, then we have a problem! If there were no source
	# files but there were link files, then we will be wanting to do a link command, no a C++ compile
	# command and the command options for the c++ compiler should be ignored!
	#

	if (n_source_files == 0) and (n_link_files == 0):
		sys.stderr.write("*** ERROR: No object or C/C++ source files specified!!!\n")
		sys.stderr.flush()
		return 2

	build_command = "cl"
	if n_source_files == 0:
		build_command = "link"
		cmd_line = ""
		link_line = "/nologo " + link_line
	else:
		link_line = "/link " + link_line

	#
	# If a link is involved here, then add the various commands into the command line.
	#

	if link_line_valid:
		cmd_line = cmd_line + link_line

	#
	# The nologo needs to appear first on some CL commands (don't totally understand why).
	# However, when this is done, in ctbuild at least, the options don't come spilling out.
	#

	have_nologo = 0
	if string.find (cmd_line, "nologo") != -1:
		cmd_line = "/nologo " + cmd_line

	#
	# If we are dumping the IDE, don't really do anything here (afterall, we might crash cause the
	# input files are dummy files also!!); just create the output files. Otherwise, execute the
	# command, making sure to remember the result.
	#

	result = 0
	if do_ide_dump:
		if nt_output_file == "":
			sys.stderr.write("*** ERROR: No output file specified!\n")
			sys.stderr.flush()
			return 2
		f_handle = open (nt_output_file, "w")
		f_handle.write ("Temp File")
		f_handle.close()
		srt_ntide_dummy_files.record_temp_file (nt_output_file)
	else:
		if no_run == 0:
			#
			# Running a command line. Because the command line can get _very_ long, we have to write
			# the command line to a temp file.
			#
			cmd_filename = tempfile.mktemp()
			cmd_file_handle = open (cmd_filename, "w")
			cmd_file_handle.write (cmd_line + "\n")
			cmd_file_handle.close()
			cmd_line_filename = tempfile.mktemp() + ".bat"
			cmd_line_handle = open (cmd_line_filename, "w")
			cmd_line_handle.write ("@ECHO OFF\n")
			cmd_line_handle.write ("set LIB=%LIBNT%\n")
			cmd_line_handle.write (build_command + " @" + cmd_filename + "\n")
			cmd_line_handle.close()
			sys.stdout.flush()
			result = os.system(cmd_line_filename)
			#os.unlink (cmd_filename)
			#os.unlink (cmd_line_filename)
			#
			# The last thing to do is make sure that the execute bit set set on the 
			# output file if this was an executable
			#
			if link_line_valid:
				os.system ("bash -c \"if [ -r " + raw_nt_output_file + " ]; then chmod a+x " + raw_nt_output_file + "; fi\"")
		else:
			print "Command was: " + build_command + " " + cmd_line + "\n"

	#
	# Make sure to flush the output. This seems to be required under certian circumstances
	# when running the b18 version of cygwin's bash util and piping the output of this script
	# to a file from the gmake command line. :-)
	#

	return result

#
# fixup_no_conformist_includes
#
#  Given a list of includes, look through them. If the modules are done correctly, then
# they should look like "modulename/modulename/..". That is fine. However, if they don't look
# like that, then remove the trailing ..s on them.
def fixup_no_conformist_includes (include_list):
	result = []
	locator = regex.compile ("^\(.*\)\\\\\(.+\)\\\\\(.+\)\\\\\(.+\)\\\\\.\.$")
	for item in include_list:
		ritem = item
		if locator.match(item) != -1:
			if (locator.group(3) != locator.group(4)) and (locator.group(2) != locator.group(4)):
				ritem = locator.group(1) + "\\" + locator.group(2) + "\\" + locator.group(3) + "\\" + locator.group(4)
				result.append(item)
		result.append(ritem)
	return result

#
# Execute the routine and let the shell know what happened.
#
if __name__ == '__main__':
	result = main()
	sys.stdout.close()
	os._exit(result)
