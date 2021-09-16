#!python
#
#  Python file to translate a f77 command line into a microsoft
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
	output_file = ""
	gcc_cmd_line = ""
	need_preprocessor = 0
	link_line = "/link "
	link_line_valid = 0

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
		print "->IDE<- *compile_fortran"
		print "->IDE<-  working_dir " + os.getcwd()
		if os.environ.has_key("CURPKG"):
			print "->IDE<-  package_name " + os.environ["CURPKG"]

	while cmd_options.has_more_options():
		option = cmd_options.get_next_option ("this should never fail!")
		if option[0] == "-":
			option = option[1:]
			#
			# I -- An include file
			#

			if option[0] == "I":
				translated_path = srt_ntbashutil.translate_path (option[1:])
				nt_path_list = srt_ntbashutil.resolve_bash_aliases (translated_path)
				if do_ide_dump:
					print "->IDE<-  unix_include_file_path " + option[1:]
				gcc_cmd_line = gcc_cmd_line + "-I" + option[1:] + " "
				#for path in nt_path_list:
				#	c_path = srt_ntbashutil.compress_path(path)
				#	gcc_cmd_line = gcc_cmd_line + "-I" + c_path + " "
				#	if do_ide_dump:
				#		print "->IDE<-  include_file_path " + c_path

			#
			# D -- Deifne a C macro symbol
			#

			elif option[0] == "D":
				gcc_cmd_line = gcc_cmd_line + "-D" + option[1:] + " "
#				if do_ide_dump:
#					print "->IDE<-  define_macro " + option[1:]
#				print "Warning: Fortran doesn't really do Defines (" + option[1:] + ")."

			#
			# c -- Don't link, only compile (defualt for cl).
			#

			elif option[0] == "c":
				cmd_line = cmd_line + "/c" + " "
				link_line_valid = 0
				if do_ide_dump:
					print "->IDE<-  do_compile_only"

			#
			# o -- Stuff the object file in the next argument.
			#

			elif option[0] == "o":
				unix_output_file = cmd_options.get_next_option("output file name")
				output_file = srt_ntbashutil.translate_path(unix_output_file)
				if srt_path_util.file_type(output_file) == "":
					link_line = link_line + "/exe:" + output_file + " "
					if do_ide_dump:
						print "->IDE<-  build_app " + output_file
				else:
					cmd_line = cmd_line + "/object:_OBJECT_ "
					if do_ide_dump:
						print "->IDE<-  build_obj " + output_file

			#
			# Pass through options -- these are really NT options, but we have to
			# use "-" instead of "/" when talking to them!
			#

			elif option[0:2] == "NT":
				cmd_line = cmd_line + "/" + option[2:] + " "
				if do_ide_dump:
					print "->IDE<-  option " + option[2:]
 
#			elif option[0:1] == "L":
#				link_line = link_line + "/libpath:" + srt_ntbashutil.translate_path(option[1:]) + " "
#				link_line_valid = 1
#				if do_ide_dump:
#					print "->IDE<-  library_search_path " + srt_ntbashutil.translate_path(option[1:])

#			elif option[0:1] == "l":
#				link_line = link_line + "lib" + option[1:] + ".lib "
#				link_line_valid = 1
#				if do_ide_dump:
#					print "->IDE<-  library lib" + option[1:] + ".lib"

			#
			# Game over. Wonder what this option was supposed to be?
			#

			else:
				sys.stderr.write("WARNING: Unkown gcc option in ntf77.py!!: -" + option + "\n")
				#return 1
		else:
			#
			# Got a plain file. If it is a .a file, change it to a .lib file. NT, of course,
			# uses .lib, while UNIX (dark ages) uses .a.
			#

			nt_path = srt_ntbashutil.translate_path (option)
			file_type = srt_path_util.file_type(nt_path)
			if file_type == "a":
				nt_path = srt_path_util.change_to_type (nt_path, "lib")
			
			#
			# Construct default output filenames
			#

			if output_file == "":
				(file_base, file_ext) = os.path.splitext (option)
				unix_output_file = file_base + ".obj"
				output_file = srt_ntbashutil.translate_path(unix_output_file)

			#
			# If this is a fortran file of type .F, then we will have to run the
			# preprocessor on it.
			#

			if file_type == "F":
				need_preprocessor = 1

			gcc_cmd_line = gcc_cmd_line + "_SOURCE_" + " "

			if do_ide_dump:
				print "->IDE<-  source_file " + nt_path

			input_file_name = nt_path

	#
	# If a link is involved here, then add the various commands into the command line.
	#

	if link_line_valid:
		cmd_line = cmd_line + link_line

	#
	# If we are dumping the IDE, don't really do anything here (afterall, we might crash cause the
	# input files are dummy files also!!); just create the output files. Otherwise, execute the
	# command, making sure to remember the result.
	#

	result = 0
	if do_ide_dump:
		if output_file == "":
			sys.stderr.write("*** ERROR: No output file specified!\n")
			sys.stderr.flush()
			return 2
		f_handle = open (output_file, "w")
		f_handle.write ("Temp File")
		f_handle.close()
		srt_ntide_dummy_files.record_temp_file (output_file)

	result = 0

	#
	# Run the commands. If we are doing an IDE file, only make sure they
	# get into the IDE text file. Replace the various strings that need to
	# be replaced...
	#

	sub_dict = {}
	sub_dict['_SOURCE_'] = input_file_name
	sub_dict['_OBJECT_'] = output_file
	(temp_dir, junk) = os.path.split (output_file)
	sub_dict['_TEMP_'] = temp_dir

	if need_preprocessor:
		#
		# Construct temporary output filename
		#
		temp_fortran_name = "_TEMP_" + construct_temp_file_name (output_file)
		unix_temp_fortran_name = srt_path_util.path_to_unix (temp_fortran_name)
		gcc_cmd_line = "-o " + unix_temp_fortran_name + " " + gcc_cmd_line

		full_gcc_command = "gcc -P -C -x c -E " + gcc_cmd_line
		if do_ide_dump:
			print "->IDE<- special_command set PATH=%CYGNUS_BIN%;%PATH%"
			print "->IDE<- special_command " + full_gcc_command
		else:
			result = os.system(translate_command(full_gcc_command,sub_dict))
		input_file_name = srt_ntbashutil.translate_path(temp_fortran_name)
	if result == 0:
		full_df_command = "df " + cmd_line + " " + input_file_name
		if do_ide_dump:
			print "->IDE<- special_command " + full_df_command
		else:
			result = os.system(translate_command(full_df_command,sub_dict))

	#
	# Make sure to flush the output. This seems to be required under certian circumstances
	# when running the b18 version of cygwin's bash util and piping the output of this script
	# to a file from the gmake command line. :-)
	#

	return result

#
# construct_temp_file_name
#
#  Build a temp filename outta the given name.  The temp filename will end with
#  _pp.f.
#
def construct_temp_file_name (source_name):
	#
	# Strip off the extension...
	#
	(base_dir, file_name) = os.path.split (source_name)
	(basename, ext) = os.path.splitext (file_name)
	return basename + "_pp.f"

#
# translate_command
#
#  Given a dictionary of replacements, do them in the current string
#
def translate_command (string, sub_dict):
	result = string
	for a_sub in sub_dict.keys():
		result = regsub.gsub (a_sub, sub_dict[a_sub], result)
	return result

#
# Execute the routine and let the shell know what happened.
#
if __name__ == '__main__':
	result = main()
	sys.stdout.close()
	os._exit(result)
