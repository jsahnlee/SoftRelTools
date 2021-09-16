#!python
#
#  This is an example file to translate a UNIX command into something that can
#  be done by the IDE or from gmake.
#
#  It shows you (I hope) how to:
#
#	- Translate paths from UNIX form into NT form
#	- Expand a directory listing so that it dosen't contains symbolic links
#		(cause NT doesn't have them in version 4.0).
#	- How to issue the command when running from plain gmake
#	- How to issue the command when building an IDE
#		- specify what are the input files
#		- specify what are the output files
#		- how to list the commands that should be executed.
#
#  Created Feb 1998 Gordon Watts (Brown)
#

import sys
import os
import string

#
# These modules are pulled in from the srt package -- actually, from the
# lib area in your current release.
#

import srt_options_line
import srt_ntbashutil
import srt_path_util


#
# The main driving program.
#

def main():

	#
	# I've written (along with everyone else in the world) something to help me
	# process command line options. You don't have to use it, but it does make
	# life simpler. I think the python library has something too, but I've not
	# had a chance to look at it yet.
	#

	cmd_options = srt_options_line.options_line (sys.argv[1:])

	#
	# If no arguments were handed to us, whine. If there is an error, make sure
	# to return a non-zero value from main. This is so that gmake and the other
	# things invoking this can quickly see that a command has failed and halt
	# the build process.
	#

	if cmd_options.length() == 0:
		sys.stderr.write("Usage: " + sys.argv[0] + " <arguments>\n")
		return 1

	#
	# Init some vars we use to build up the real command that we are going to
	# be executing. cmd_line will contain the final command line.
	#

	cmd_line = ""
	output_file = ""

	#
	# If the environment var IDE_DUMP is defined, then we are in the middle of
	# an ntide_build command. The value of IDE_DUMP is the filename where all
	# the text is being written (usually ide_dump.txt at the local_release top
	# level directory -- read this file to see what is going on). Because the
	# filename is created in UNIX, it must be put into a path form that python
	# can hack (the translate_path function).
	#

	do_ide_dump = 0
	if os.environ.has_key("IDE_DUMP"):
		f_name = srt_ntbashutil.translate_path(os.environ["IDE_DUMP"])
		sys.stdout = open (f_name, "a+")
		do_ide_dump = 1

	#
	# If we are doing a dump, indicate we are starting a new command (the "*"
	# line).
	#
	# working_dir is the location we are running from. If the dump processor has
	# to calculate relative paths, it will do so relative to this working_dir
	# directory.
	#

	if do_ide_dump:
		print "->IDE<- *compile_special_command"
		print "->IDE<-  working_dir " + os.getcwd()

	#
	# Now, loop over all the arguments in the command line.
	#

	while cmd_options.has_more_options():
		option = cmd_options.get_next_option ("this should never fail!")

		#
		# A standard UNIX flag begins with a "-" (-I /gtwd0/include_dir for example).
		#

		if option[0] == "-":
			option = option[1:]

			#
			# I -- An include directory. This gets a little tricky because the include
			# directory may contain a whole slew of symbolic links. If linked against
			# ms libraries, this just won't fly. Soooo, we have to expand the list.
			# The resolve_bash_aliases routine does just that.
			#
			# compress_path makes sure that there aren't funning things like
			# double "/"s in the path (not likely at this point).
			#

			if option[0] == "I":
				translated_path = srt_ntbashutil.translate_path (option[1:])
				nt_path_list = srt_ntbashutil.resolve_bash_aliases (translated_path)

				for path in nt_path_list:
					c_path = srt_ntbashutil.compress_path(path)
					cmd_line = cmd_line + "/I " + c_path + " "

			#
			# D -- Deifne a C macro symbol
			#

			elif option[0] == "D":
				cmd_line = gcc_cmd_line + "/D" + option[1:] + " "

			#
			# o -- The output file. Once you know the location of the file, you
			# write "build_file" to the IDE log to specify it. You can have as many
			# of these as you want for one command.
			#

			elif option[0] == "o":
				unix_output_file = cmd_options.get_next_option("output file name")
				output_file = srt_ntbashutil.translate_path(unix_output_file)
				if do_ide_dump:
					print "->IDE<-  build_file " + output_file

			#
			# Sometimes it is useful to specify some NT specific options someplace
			# in your .mk file (like arc_speck.mk's NT section) and pass them directly
			# through. The following code does that for you.
			#

			elif option[0:2] == "NT":
				cmd_line = cmd_line + "/" + option[2:] + " "
				if do_ide_dump:
					print "->IDE<-  option " + option[2:]
 
			#
			# Game over. Wonder what this option was supposed to be?
			#

			else:
				sys.stderr.write("**\n");
				sys.stderr.write("**WARNING: Unkown gcc option in ntf77.py!!: -" + option + "\n")
				sys.stderr.write("**\n");

		#
		# Ok, come here if it wasn't an option
		#

		else:

			nt_path = srt_ntbashutil.translate_path (option)

			#
			# There are some tricks when dealing with files -- not that .a files
			# aren't valid here -- they are .lib files. A .a file does exist, but it
			# is just a dummy. So watch for that if you expect library files to
			# be passed to you. Example below.
			#

			file_type = srt_path_util.file_type(nt_path)
			if file_type == "a":
				nt_path = srt_path_util.change_to_type (nt_path, "lib")

			#
			# Tell the ide about a source file. You can have more than one of
			# these, of course.  These files will be listed as the things your output
			# file depends upon...
			#
			
			cmd_line = cmd_line + " " + nt_path
			if do_ide_dump:
				print "->IDE<-  source_file " + nt_path

	#
	# Done with the processing of the command line. cmd_line how has a valid command
	# in it.
	#
	# First question, if this is a IDE build and an output file is expected by
	# make (i.e., it won't function without it), then we need to build a dummy
	# output file.
	#

	if do_ide_dump:
		if output_file == "":
			sys.stderr.write("*** ERROR: No output file specified!\n")
			sys.stderr.flush()
			return 2
		f_handle = open (output_file, "w")
		f_handle.write ("Temp File")
		f_handle.close()

	#
	# Run the commands. If we are doing an IDE file, only make sure they
	# get into the IDE text file. Replace the various strings that need to
	# be replaced...
	#
	# You can write out as many of these special_commands as you need (see
	# the routine below for generating temp filenames). Be aware that NT doesn't
	# like having a command line more than 5K charachters long. To get around this
	# you'll have to put command line options in a file. Unfortunately, there is
	# no automatic way to do this yet. Sorry.
	#

	result = 0
	full_df_command = "my_cmd " + cmd_line + " " + input_file_name
	if do_ide_dump:
		print "->IDE<- special_command " + full_df_command
	else:
		result = os.system(translate_command(full_df_command,sub_dict))

	#
	# Make sure to return the result of trying to run those commands so that
	# we transmit our status back to the shell!
	#

	return result

#
# construct_temp_file_name
#
#  Build a temp filename outta the given name.  The temp filename will end with
#  _pp.f. Use a routine like this if you want to create a temp file internal
#  to the command. If you don't need it, you can get rid of it.
#
def construct_temp_file_name (source_name):
	#
	# Strip off the extension...
	#
	(base_dir, file_name) = os.path.split (source_name)
	(basename, ext) = os.path.splitext (file_name)
	return basename + "_pp.f"


#
# Execute the routine and let the shell know what happened. We protect it so that
# it can be compiled when copied over into the bin area during a release (and, most
# importantly, precompiled to speed its use) but not actually be run.
#
if __name__ == '__main__':
	result = main()
	sys.stdout.close()
	os._exit(result)
