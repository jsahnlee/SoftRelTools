#
# ide_project_file.py
#
#  These functions create a project file given an ide_target object. The project files
#  are all template files, so we first fill in a dictionary with all the possible values
#  and then hand it off to the template translator to do the dirty work.
#
#  Unforunately for us, DevStudio only handles about 2K worth of characters in
#  all of its environment vars and other things. Thus, we have to write a seperate
#  file with all the includes in it to keep the command line short enough. This file
#  is also inserted in the project so the user can get at it easily.
#
#  Created November 1997 Gordon Watts (Brown)
#

import srt_file_template
import srt_path_util
import srt_ntide_target
import srt_ntide_list_set
import regsub
import regex
import os

dir_debug_prefix = "Debug_"
dir_release_prefix = "Release_"

#
# create_project_file
#
#  Create the .dsp file for the project
#
def create_project_file (project, target_list, newrel_dir):
	project_dsp = open (project.get_project_file(), "w")

	#
	# Figure out what the name of the template file is. We will use this
	# as the basis for our project.
	#

	template_name = "srt_ntide_project_" + project.get_target_type() + ".template"
	template_filename = srt_path_util.find_file_in_PATH (template_name)
	if template_filename == "":
		raise "Could not find template file " + template_name + " in PATH."

	#
	# We have to create the dictionary of all the stuff we know about that
	# will be put into the output file. Sigh.
	#

	project_dict = {}

	# The project name
	project_dict["project_name"] = project.get_project_ide_name()
	print project_dict["project_name"]

	# The target type
	t_type = project.get_target_type()
	if t_type == "lib":
		t_build = '# TARGTYPE "Win32 (x86) Static Library" 0x0104'
	elif (t_type == 'exe') or (t_type == ''):
		t_build = '# TARGTYPE "Win32 (x86) Console Application" 0x0103'
	project_dict["project_type"] = t_build

	# The cygwin path
	
	project_dict["cygwin_path"] = os.environ["CYGNUS_BIN"]

	# The working directories

	project_dict["working_dir_debug"] = dir_debug_prefix + project.get_target_root_file()
	project_dict["working_dir_release"] = dir_release_prefix + project.get_target_root_file()

	# The name of the destination file

	project_dict["target_filename"] = project.get_target_name_root()
	project_dict["target_name"] = project.get_target_root_file()

	f_target_path = project.get_target_name()
	project_dict["final_target"] = srt_path_util.get_relative_path (f_target_path, project.get_project_file_dir())
	project_dict["final_target_unix"] = srt_path_util.path_to_unix(project_dict["final_target"])
	(project_dict["final_target_dir"], bogus) = os.path.split (project_dict["final_target"])

	# Compiler flags, includes, and other per-source file things
	source_targets = project.get_non_project_targets (target_list)

	source_options_list = {}
	include_dir_list = {}
	macro_define_list = {}
	link_library_list = srt_ntide_list_set.srt_ntide_list_set()
	link_lib_path_list = srt_ntide_list_set.srt_ntide_list_set()
	link_options_list = srt_ntide_list_set.srt_ntide_list_set()
	header_file_list = srt_ntide_list_set.srt_ntide_list_set()

	for target_type in srt_ntide_target.source_file_classes.keys():
		source_options_list[target_type] = srt_ntide_list_set.srt_ntide_list_set()
		include_dir_list[target_type] = srt_ntide_list_set.srt_ntide_list_set()
		macro_define_list[target_type] = srt_ntide_list_set.srt_ntide_list_set()

	for a_target in source_targets:
		
		#
		# Get the source file from the target, and its class
		#

		a_source_file = target_list[a_target].get_target_source_file_list()[0]
		target_class = srt_ntide_target.get_file_class(a_source_file)
		if target_class == "":
			raise "Error file of type " + target_class + " is not a source class for target " + a_target + "!"

		#
		# Find the common options, include dirs, and macro defines it has
		#

		source_options_list[target_class].intersection (target_list[a_target].get_options_list())
		include_dir_list[target_class].intersection(target_list[a_target].get_include_list())
		macro_define_list[target_class].intersection(target_list[a_target].get_macro_define_list())

		#
		# Accumulate any particular link libraries or the like
		#

		link_library_list.add(target_list[a_target].get_link_libraries())
		link_lib_path_list.add (target_list[a_target].get_library_search_paths())
		link_options_list.add (target_list[a_target].get_link_options())

		#
		# And any header files it has
		#

		header_file_list.add(target_list[a_target].get_header_files())

	#
	# Great. We have a lot of per-project info.
	#
	#  First up are the libraries we are going to link in. Some of them are projects
	# we are also building... don't need to put them in, as they will be in once already.
	#

	link_library_list.add(project.get_link_libraries())

	dep_project_names = project.get_dependent_on_projects (target_list)

	link_lib_string = ""
	for link_lib in link_library_list.get_list():
		if link_lib not in dep_project_names:
			if os.path.exists(link_lib):
				rel_file = srt_path_util.get_relative_path (link_lib, project.get_project_file_dir())
			else:
				rel_file = link_lib
			link_lib_string = link_lib_string + rel_file + " "

	project_dict["link_libraries"] = link_lib_string

	#
	# The link options
	#

	link_options_list.add(project.get_link_options())
	link_options_string = ""
	for link_option in link_options_list.get_list():
		link_options_string = link_options_string + "/" + link_option + " "

	project_dict["link_options"] = link_options_string

	#
	# Library search paths
	#

	link_lib_path_list.add(project.get_library_search_paths())

	link_search_paths = ""
	for search_path in link_lib_path_list.get_list():
		link_search_paths = link_search_paths + '/libpath:"' + search_path + '" '
	project_dict["link_search_paths"] = link_search_paths

	#
	# Next, assemble the standard options string that we are going to need to
	# look at. This will include stuff like macro definitions, etc. We have to
	# do this by compiler -- or source class
	#

	option_string = {}
	for source_class in srt_ntide_target.source_file_classes.keys():
		option_string[source_class] = make_option_string (source_options_list[source_class].get_list())

	option_string["cpp"] = option_string["cpp"] + "/YX /Fp.\\" + project.get_target_root_file() + ".PCH "

	#
	# Do it for the macro definitions
	#

	macro_string = {}
	for source_class in srt_ntide_target.source_file_classes.keys():
		macro_string[source_class] = make_macro_string (macro_define_list[source_class].get_list())

	#
	# Next, do the same loop for the include paths. This list can get so long that it overflows
	# DevStudio's ability to store it. So we write it to a file which is later read back from
	# the project. We also insert it in the project so that the poor user can easily look at the
	# file.
	#

	include_path_file = {}
	for source_class in srt_ntide_target.source_file_classes.keys():
		include_path_file[source_class] = srt_ntide_compiler_include_file (project, newrel_dir, "include_paths_" + source_class)
		include_handle = include_path_file[source_class].open ()

		for includes in include_dir_list[source_class].get_list():
			try:
				rel_file = srt_path_util.get_relative_path (includes, project.get_project_file_dir())
			except:
				rel_file = includes
			include_handle.write ('/I "' + rel_file + '"\n')
		include_handle.close ()

	#
	# Put together the list of compiler options
	#

	project_dict["cpp_flags_debug"] = option_string["cpp"] \
			+ macro_string["cpp"]

	project_dict["f_flags_debug"] = option_string["f"] \
			+ macro_string["f"]

	#
	# Next, add in the correct indirect files -- these are the guys that contain the long lists
	# of include files.
	#

	project_dict["compiler_option_file_list"] = ""
	for source_class in include_path_file.keys():
		rel_inc_filename = srt_path_util.get_relative_path (include_path_file[source_class].name(),
															project.get_project_file_dir())
		project_dict[source_class + "_flags_debug"] = project_dict[source_class + "_flags_debug"] + \
				'@"' + rel_inc_filename + '"'

		project_dict["compiler_option_file_list"] = project_dict["compiler_option_file_list"] \
			+ "# Begin Source File\n\nSOURCE=.\\" + rel_inc_filename + "\n# End Source File\n"

	#
	# Currently, the release and debug flags are the same... Eventually we will
	# have to fix this, I suppose. :(
	#

	project_dict["cpp_flags_release"] = project_dict["cpp_flags_debug"]
	project_dict["f_flags_release"] = project_dict["f_flags_debug"]
	
	#
	# A list of the source files. Need to add in any defines, etc. that aren't
	# in the master list...
	#

	source_lines = ""

	t_helper = target_spec_helper ()
	project.traverse_source_files (t_helper, target_list)

	#
	# Now we have all the source files and their associated targets. Time to walk
	# through them and emit the source lines to do the work.
	#

	project_dict["compiler_special_cmd_file_list"] = ""
	project_dict["source_file_list"] = ""
	for file_target_pair in t_helper.get_builds():
		(a_file, a_target) = file_target_pair
		file_class = srt_ntide_target.get_file_class(a_file)

		#
		# If we have fortran files, better set the fortran marker. This prevents us
		# from emitting fortran specific info in a ide file that doesn't need it. MSVC
		# will choke on such a file if fortran hasn't been installed.
		#

		if file_class == "f":
			project_dict["has_fortran_files"] = "1"

		#
		# Next, if it has special commands associated with it, take care of the
		# problem. Otherwise, it is a plain old guy requiring some real work. :(
		# Make sure to make the special command files a part of the project so the poor
		# user can get at them pretty simply.
		#

		source_lines = ""
		if a_target.has_special_commands():
			(source_lines, cmd_file_r, cmd_file_d) = create_special_commands (a_file, a_target, project)
			project_dict["compiler_special_cmd_file_list"] = project_dict["compiler_special_cmd_file_list"] \
				+ "# Begin Source File\n\nSOURCE=.\\" + cmd_file_r + "\n# End Source File\n"
			project_dict["compiler_special_cmd_file_list"] = project_dict["compiler_special_cmd_file_list"] \
				+ "# Begin Source File\n\nSOURCE=.\\" + cmd_file_d + "\n# End Source File\n"
		else:
			delta_defines = macro_define_list[file_class].difference (a_target.get_macro_define_list())
			delta_include_dir = include_dir_list[file_class].difference (a_target.get_include_list())
			delta_source_options = source_options_list[target_class].difference (a_target.get_options_list())

			delta_define_string = make_macro_string (delta_defines)
			delta_include_dir_string = make_include_string (delta_include_dir, project.get_project_file_dir())
			delta_options_string = make_option_string (delta_source_options)

			new_opt_string = delta_define_string + delta_options_string + delta_include_dir_string

			rel_file = srt_path_util.get_relative_path (a_file, project.get_project_file_dir())
			source_lines = "# Begin Source File\n\nSOURCE=.\\" + rel_file + "\n"

			if new_opt_string != "":
				source_lines = source_lines + "# ADD CPP " + new_opt_string + "\n"

			source_lines = source_lines + "# End Source File\n"

		project_dict["source_file_list"] = project_dict["source_file_list"] + source_lines
	
	#
	# The header files that this project includes
	#

	header_file_list.add(project.get_header_files())
	header_string = ""
	for header in header_file_list.get_list():
		if srt_ntide_target.get_file_class(header) == "hpp":
			rel_file = srt_path_util.get_relative_path (header, project.get_project_file_dir())
			source_lines = "# Begin Source File\n\nSOURCE=.\\" + rel_file + "\n"
			source_lines = source_lines + "# End Source File\n"
			header_string = header_string + source_lines

	project_dict["header_file_list"] = header_string

	#
	# Great, now do it.
	#

	srt_file_template.file_template (project_dsp, template_filename, project_dict)

	project_dsp.close()

#############################################
#
# target_spec_helper
#
#  Temp object to help out with traversing the source file list (and constructing
#  the source files!).
#
class target_spec_helper:
	def __init__(self):
		self._normal_files = []

	def get_builds (self):
		return self._normal_files

	def source_file (self, a_file, target_obj):
		self._normal_files.append ([a_file, target_obj])

#
#  create_special_commands
#
#  Return a string var that is all the source file commands for a particular file guy
#  where we are going to execute a special command file.
#
def create_special_commands (a_file, target_obj, project):

	#
	# Get the relative path to the file itself
	#

	rel_file = srt_path_util.get_relative_path (a_file, project.get_project_file_dir())

	#
	# Next, grab the name of the output object file name. Below we will assume
	# that the output is an object, which may not always be the right thing
	# to do!
	#

	(basename, filename) = os.path.split (rel_file)
	(file_name_root, file_ext) = os.path.splitext (filename)

	#
	# Because DevStudio can only handle about 200 characters on their command
	# lines, we have to write the commands to a file.  We must make two of
	# these files, one for the debug and release. Unfortunately, we have to
	# assume that the same build commands go for each (no way around it). :(
	#

	project_name = project.get_target_root_file()

	project_dir_debug_prefix = dir_debug_prefix + project_name
	command_file_debug = project_dir_debug_prefix + "\\" + file_name_root + "_deb_b.bat"
	project.create_ide_directory (project_dir_debug_prefix)

	project_dir_release_prefix = dir_release_prefix + project_name
	command_file_release = project_dir_release_prefix + "\\" + file_name_root + "_rel_b.bat"
	project.create_ide_directory (project_dir_release_prefix)

	#
	# Write the commands out to the files
	#

	cmd_file_d_handle = open (project.get_project_file_dir() + "\\" + command_file_debug, "w")
	cmd_file_r_handle = open (project.get_project_file_dir() + "\\" + command_file_release, "w")

	source_commands = target_obj.get_special_commands()

	sub_dict = {}
	sub_dict['_SOURCE_'] = rel_file
	sub_dict['_OBJECT_'] = project_dir_release_prefix + "\\" + file_name_root + ".obj"
	sub_dict['_TEMP_'] = project_dir_release_prefix + "\\"

	for a_command in source_commands:
		cmd_file_r_handle.write(translate_command(a_command, sub_dict) + "\n")

	sub_dict['_OBJECT_'] = project_dir_debug_prefix + "\\" + file_name_root + ".obj"
	sub_dict['_TEMP_'] = project_dir_debug_prefix + "\\"

	for a_command in source_commands:
		cmd_file_d_handle.write(translate_command(a_command, sub_dict) + "\n")

	cmd_file_d_handle.close ()
	cmd_file_r_handle.close ()

	#
	# Now that we have the command files built, we need to insert the special
	# build commands into the IDE dude.
	#

	source_lines ='# Begin Source File\n\
\n\
SOURCE=' + rel_file + '\n\
\n\
!IF  "$(CFG)" == "' + project.get_project_ide_name() + ' - Win32 Release"\n\
\n\
# PROP Ignore_Default_Tool 1 \n\
# Begin Custom Build - Fortran w/ Preprocessor\n\
InputPath=' + rel_file + '\n\
\n\
"' + project_dir_release_prefix + '\\' + file_name_root + '.obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"\n\
	' + command_file_release + '\n\
\n\
# End Custom Build\n\
	\n\
!ELSEIF  "$(CFG)" == "' + project.get_project_ide_name() + ' - Win32 Debug"\n\
\n\
# PROP Ignore_Default_Tool 1\n\
# Begin Custom Build - Fortran w/ Preprocessor\n\
InputPath=' + rel_file + '\n\
\n\
"' + project_dir_debug_prefix + '/' + file_name_root + '.obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"\n\
	' + command_file_debug + '\n\
	\n\
# End Custom Build\n\
\n\
!ENDIF \n\
\n\
# End Source File\n'
	return [source_lines, command_file_release, command_file_debug]


###########################################
# translate_command
#
#  Given a dictionary of replacements, do them in the current string
#
def translate_command (string, sub_dict):
	result = string
	for a_sub in sub_dict.keys():
		result = regsub.gsub (a_sub, sub_dict[a_sub], result)
	return result

#############################################
#
# srt_ntide_compiler_include_file
#
#  A helper object that will control writing out an inclue file
#  for the compiler command line.
#
class srt_ntide_compiler_include_file:
	def __init__ (self, project, newrel_dir, name_modifier):
		self.build_filename (project, newrel_dir, name_modifier)

	#
	# build_filename -- build the damm filename out of the parts -- we want to
	# store it in the project directory.
	#
	def build_filename (self, project, newrel_dir, name):
		project_filename = project.get_project_file()
		(project_file_base, extension) = os.path.splitext (project_filename)
		self._filename = project_file_base + "_" + name + ".compiler_opt"

	#
	# Open the file for output
	#
	def open (self):
		return open (self._filename, "w")

	#
	# name -- return the name of the file
	#
	def name (self):
		return self._filename


#
# make_option_string
#
#  Given a list of options, create a options string
#
def make_option_string (opt_list):
	result = ""
	for option in opt_list:
		result = result + "/" + option + " "
	return result

#
# make_macro_string
#
#  Do the same thing for macro guys
#
def make_macro_string (mac_list):
	result = ""
	for a_macro in mac_list:
		split_pat=regex.compile("^\([^=]*\)=\(.*\)$")
		if split_pat.match(a_macro) == -1:
			result = result + '/D "' + a_macro + '" '
		else:
			result = result + '/D ' + split_pat.group(1) + '=' + split_pat.group(2) + " "
	return result

#
# make_include_string
#
#  Returns a list (not a file) of include paths
#
def make_include_string (inc_list, proj_dir):
	result = ""
	for option in inc_list:
		try:
			rel_file = srt_path_util.get_relative_path (option, proj_dir)
		except:
			rel_file = option
		result = result + "/I " + rel_file + " "
	return result
