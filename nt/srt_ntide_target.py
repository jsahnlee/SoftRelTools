#
# ide_target.py
#
#  An object that keeps track of a single target the IDE has to build... This includes
#  things like object files, by the way. So not all targets translate to projects in the
#  ide (the routine is_a_project determines which targets are projects and which are not).
#
#  This is the place to mess around if you need to change things like what targets are built,
#  or what the targets are named in the ide, etc.
#
#  Created November 1997 Gordon Watts (1997)
#

import string
import os
import regex
import regsub

import srt_path_util

# The file types definition -- so we can figure out what we are dealing with
# File type classes for source files -- there are only a few
source_file_classes = {}
source_file_classes["cpp"] = ["cpp", "c", "cc", "cxx"]
source_file_classes["f"] = ["f", "f77", "f90", "F"]

# Executable files
exe_file_types = ["exe", "x", "", "tst"]

# Header files
header_file_types = ["hpp", "h"]


####
# A list of all the source file types -- built from above.
source_file_types = []
for source_class in source_file_classes.keys():
	for source_type in source_file_classes[source_class]:
		source_file_types.append(source_type)

class ide_target:

	def __init__ (self, ide_file_handle = "", newrel_dir = ""):
		self._option_list = []
		self._macro_definitions = []
		self._include_paths = []
		self._unix_include_paths = []
		self._source_files = []			# Can contain only source_file_types
		self._header_files = []
		self._forced_cpp_files = {}
		self._lib_files_to_add = []		# Contains all other types.
		self._newrel_directory = newrel_dir
		self._bfarch = os.environ["BFARCH"]
		self._special_commands = []
		self._working_dir = ""
		self._package_name = ""
		self._link_options = []

		self.reset_target_files ()
		self.reset_libraries ()

		if ide_file_handle != "":
			self.parse_from_file (ide_file_handle)


	#
	# reset_target_files
	#
	#  Clear out all the possible destination files
	#
	def reset_target_files (self):
		self._build_file = ""
		self._library_file = ""
		self._exe_name = ""

	#
	# reset_libraries
	#
	#  Reset all the library stuff
	#
	def reset_libraries (self):
		self._link_library_files = []
		self._library_search_paths = []

	#
	# parse_from_file
	#
	#  Read everything in from a file
	#
	def parse_from_file (self, ide_file_handle):

		star_line = ide_file_handle.get_line()

		ide_file_handle.load_buffer()
		while ide_file_handle.there_is_more() and (not ide_file_handle.is_star_line()):
			line = ide_file_handle.get_line()

			line_word_list = string.split (line, " ", 1)
			command = line_word_list[0]
			option = ""
			if len(line_word_list) == 2:
				option = line_word_list[1]

			if command == "option":
				self._option_list.append(option)
			elif command == "link_option":
				self._link_options.append(option)
			elif command == "define_macro":
				self._macro_definitions.append(option)
			elif command == "include_file_path":
				if (option != ".") and (option != ""):
					self._include_paths.append(option)
			elif command == "unix_include_file_path":
				if (option != ".") and (option != ""):
					self._unix_include_paths.append(option)
			elif command == "do_compile_only":
				self._option_list.append("c")
			elif command == "h_filename":
				self._header_files.append(option)
			elif command == "source_file":
				self.add_source_file (option)
			elif command == "source_file_cpp":
				self.add_source_file (option)
				self._forced_cpp_files[option] = "cpp"
			elif command == "special_command":
				self._special_commands.append(option)
			elif command == "add_and_create":
				i = 10
			elif command == "build_obj":
				if self._build_file != "":
					raise "Cannot build more than one output file per target!"
				self._build_file = option
			elif command == "build_file":
				if self._build_file != "":
					raise "Cannot build more than one output file per target!"
				self._build_file = option
			elif command == "library_file":
				if self._library_file != "":
					raise "Cannot build more than one library file per target!"
				self._library_file = option
			elif command == "library":
				self._link_library_files.append (option)
			elif command == "add_file":
				self._lib_files_to_add.append (option)
			elif command == "library_search_path":
				self._library_search_paths.append (option)
			elif command == "build_app":
				if self._exe_name != "":
					raise "Cannot build more than one exe per target!"
				self._exe_name = option
			elif command == "working_dir":
				common_prefix = os.path.commonprefix ([option, self._newrel_directory])
				if common_prefix != self._newrel_directory:
					raise "Working directory must be subdir of newrelease directory!"
				self._working_dir = option[len(self._newrel_directory)+1:]
			elif command == "package_name":
				self._package_name = option
			else:
				print "Unknown IDE Make file option: " + command
				raise "Could not parse the file"

			ide_file_handle.load_buffer()

		target_count = 0
		if self._build_file != "":
			target_count = target_count + 1
		if self._library_file != "":
			target_count = target_count + 1
		if self._exe_name != "":
			target_count = target_count + 1

		if target_count == 0:
			raise "No targets found for file!"
		if target_count > 1:
			raise "Too many targets found for file!"

	#
	# set_compile_only
	#
	#  Set if we are only building an object or linking as well. This has
	#  a big-time bug in it...
	#
	def set_compile_only (self, do_it):
		if do_it:
			if "c" not in self._option_list:
				self._option_list.append ("c")
		else:
			raise "Don't know how to remove the C option yet!"

	#
	# get_target_name
	#
	#  Return the name of the target for this file. This is a fully qualified name,
	#  including path info (potentially).
	#
	def get_target_name (self):
		if (self._library_file != "") and (self._build_file != ""):
			raise "Both library and build are non-zero!"
		if self._build_file != "":
			return self._build_file
		if self._library_file != "":
			return self._library_file
		if self._exe_name != "":
			return self._exe_name

		raise "Should never get here!"

	#
	# set_build_obj
	#
	#  Set the build object
	#
	def set_build_obj (self, filename):
		self._build_file = filename

	#
	# get_target_type
	#
	#  Return the extension that has the target type in it. NOTE: we assume that if
	#  there is no filetype here, we are dealing with a .exe... this may not be a good
	#  thing!
	#
	def get_target_type (self):
		fname = self.get_target_name_root()
		pos = regex.search ("\.[^\.]*$", fname)
		if pos == -1:
			t_type = "exe"
		else:
			t_type = fname[pos+1:]

		if t_type in exe_file_types:
			return "exe"
		return t_type


	#
	# get_target_name_root
	#
	#  Return the name of this target (no path allowed)
	#
	def get_target_name_root (self):
		return os.path.basename (self.get_target_name())

	def get_target_root_file (self):
		(name, exten) = os.path.splitext (self.get_target_name_root())
		return name

	#
	# combine
	#
	#  There is another ide_target object with the same target name as we have. Attempt
	# to combine these two guys.
	#
	#  Really should check to make sure other stuff is correct, but not for now!
	#
	def combine (self, other_target):

		if self.get_target_type() != "lib":
			str_ing =  "Can only combine library targets (type: " + self.get_target_type() + "; target: " + self.get_target_name_root() + ")"
			raise str_ing

		for a_file in other_target._lib_files_to_add:
			self._lib_files_to_add.append (a_file)

	#
	# get_project_file
	#
	#  Return our project file.
	#
	def get_project_file (self):
		(target_name, type) = os.path.splitext (self.get_target_name_root())
		return  self.get_project_file_dir() + "\\" + target_name + ".dsp"

	#
	# get_header_files
	#
	#  Return the list of header files this guy includes
	#
	def get_header_files (self):
		return self._header_files

	#
	# get_project_file_dir
	#
	#  Return the directory that the project file is located in.
	#
	def get_project_file_dir (self):
		return self._newrel_directory + "\\ide\\" + self._bfarch + "\\" + self.get_package_name()

	#
	# create_ide_directory
	#
	#  Make sure that a directory sitting under the ide directory exists. If it
	# does not, then create it.
	#
	def create_ide_directory (self, dir_name):
		dir_path = self.get_project_file_dir() + "\\" + dir_name
		if not os.path.exists (dir_path):
			os.mkdir (dir_path)

	#
	# get_package_name
	#
	#  Return the package we are involved with/in... Unfortunately,
	# the package name can be burried in several different spots.
	# -- the working directory could be one of the following two
	# forms:
	#   d0me\test
	#   tmp\CYGWIN32_NT\d0me
	# We have to pick the package name out of there correctly. The
	# method used below isn't very safe...
	#
	# normally this is supplied by the build commands. Complain if it isn't.
	#
	def get_package_name (self):
		if self._package_name == "":
			print "Warning: will attempt to guess the package name (compile commands should have given it)..."
			if regex.search("^tmp.*$", self._working_dir) == 0:
				pkg_finder = regex.compile ("^tmp\\\\[^\\]*\\\\\([^\\]*\).*$")
				if pkg_finder.match (self._working_dir) != -1:
					self._package_name = pkg_finder.group(1)
				else:
					raise "Working dir dosen't look right!"
			else:
				old_root = ""
				root = self._working_dir
				while root != "":
					old_root = root
					(root, stuff) = os.path.split (root)
				self._package_name = old_root
			print " Guessed " + self._package_name
		return self._package_name


	#
	# get_working_dir_rel
	#
	#  Returnt the relative working directory
	#
	def get_working_dir_rel (self):
		return self._working_dir

	#
	# get_project_ide_name
	#
	#  Return the name of this target as a project that it will be called in the ide.
	#  This isn't a valid filename, just the text string used by the IDE.
	#  The IDE can't handle "-" in its project names, so replace them with
	#   underscores.
	#
	def get_project_ide_name (self):
		temp = self.get_package_name() + "/" + self.get_target_root_file()
		return regsub.gsub ("-", "_", temp)

	#
	# has_special_commands
	#
	#  Return true if there are special commands associated with this target
	#
	def has_special_commands (self):
		return len(self._special_commands) > 0

	#
	# get_special_commands
	#
	#  Return the list of commands
	#
	def get_special_commands (self):
		return self._special_commands

	#
	# get_dependent_on_projects
	#
	#  Return a list of projects on whom we are dependent. Ugh.
	#
	def get_dependent_on_projects (self, all_project_objects):
		list_1 = find_dependent_projects (self._source_files, all_project_objects)
		list_2 = find_dependent_projects (self._lib_files_to_add, all_project_objects)

		for duh in list_2:
			list_1.append(duh)

		return list_1

	#
	# traverse_source_files
	#
	#  Traverse the network of source files, calling the helper object each time
	#  we get a new one.
	#
	#  The interface for the helper object. It must have a method "source_file"
	#  that takes two arguments, one a target and one a source file name. The object
	#  will only be called once for every source file.
	#
	#  Returns the modified object.
	#
	def traverse_source_files (self, helper_obj, target_list):
		done_list = []
		result = self.do_traverse_source_files (done_list, helper_obj, target_list)
		return result

	#
	# do_traverse_source_files
	#
	#  The work routine -- don't call this, call traverse_source_files instead.
	#
	def do_traverse_source_files (self, done_list, helper_obj, target_list):

		list_1 = self._source_files
		for a_file in self._lib_files_to_add:
			list_1.append (a_file)
		
		for a_file in list_1:
			if target_list.has_key(a_file):
				if not is_a_project (target_list[a_file].get_target_type()):
					helper_obj = target_list[a_file].do_traverse_source_files (done_list, helper_obj, target_list)
			else:
				if not os.path.isabs (a_file):
					the_file = self._newrel_directory + "\\" + self._working_dir + "\\" + a_file
				else:
					the_file = a_file
				if the_file not in done_list:
					helper_obj.source_file (the_file, self)
					done_list.append(the_file)
		return helper_obj

	#
	# get_source_files
	#
	#  We look at our list and see if we can determine what source files when into building
	# this particular target. A .lib file is ignored -- it will be included as a seperate
	# project.
	#
	def get_source_files (self, target_list):
		src_helper = get_source_file_helper()
		self.traverse_source_files (src_helper, target_list)
		return src_helper.source_list()

	#	source_list = []
	#
	#	list_1 = self._source_files
	#	for a_file in self._lib_files_to_add:
	#		list_1.append(a_file)

	#	for a_file in list_1:
	#		if target_list.has_key(a_file):
	#			if not is_a_project (target_list[a_file].get_target_type()):
	#				target_source_list = target_list[a_file].get_source_files (target_list)
	#				for more_files in target_source_list:
	#					if more_files not in list_1:
	#						list_1.append (more_files)
	#		else:
	#			if not os.path.isabs (a_file):
	#				the_file = self._newrel_directory + "\\" + self._working_dir + "\\" + a_file
	#			else:
	#				the_file = a_file
	#			source_list.append (the_file)

	#	return source_list

	#
	# get_target_source_file_list
	#
	#  Return the list of source files (not lib files)
	#
	def get_target_source_file_list (self):
		return self._source_files

	#
	# set_source_file_list
	#
	#  Reset the source file list to some new list
	#
	def set_source_file_list (self, new_list):
		self._source_files = new_list

	#
	# add_source_file
	#
	#  Make sure to add a new source file. Depending upon its type, put it in the correct list.
	#
	def add_source_file (self, new_file):
		t_type = srt_path_util.file_type (new_file)
		if t_type in source_file_types:
			self._source_files.append (new_file)
		else:
			self._lib_files_to_add.append (new_file)

	#
	# get_non_project_targets
	#
	#   Return the project targets that aren't an individual project in themselves.
	#
	def get_non_project_targets (self, target_list):
		found_targets = []

		list_1 = self._source_files
		for a_file in self._lib_files_to_add:
			list_1.append(a_file)

		for a_file in list_1:
			if target_list.has_key(a_file):
				if not is_a_project (target_list[a_file].get_target_type()):
					found_targets.append(a_file)

					target_source_list = target_list[a_file].get_source_files (target_list)
					for more_files in target_source_list:
						if more_files not in list_1:
							list_1.append (more_files)

		return found_targets

	#
	# get_options_list
	#
	#  Return the options list
	#
	def get_options_list (self):
		if self._forced_cpp_files.has_key(self._source_files[0]):
			temp = self._option_list
			temp.append("TP")
			return temp
		else:
			return self._option_list

	#
	# are_options_compatible
	#
	#  Return true if the options listed are compatible with the options this
	# guy was built with.
	#
	def are_options_compatible (self, option_list):
		for option in option_list:
			if option not in self._option_list:
				return 0
		return 1
 
	#
	# get_include_list
	#
	#  Return the include directory list
	#
	def get_include_list (self):
		return self._include_paths

	#
	# get_unix_include_list
	#
	#  Same thing, but return the unix include path list
	#
	def get_unix_include_list (self):
		return self._unix_include_paths

	#
	# get_macro_define_list
	#
	#  Return the defined macros
	#
	def get_macro_define_list (self):
		return self._macro_definitions

	#
	# get_link_libraries
	#
	#  Return the list of libraries we need to link to to build this thing.
	#  Try to use the link library search path to find them
	#
	def get_link_libraries (self):
		list_of_libs = []
		for a_lib in self._link_library_files:
			lib_file = a_lib
			if not os.path.exists (a_lib):
				for search_path in self._library_search_paths:
					temp = search_path + "\\" + a_lib
					if os.path.exists (temp):
						lib_file = temp
						break

			list_of_libs.append(lib_file)
				
		return self._link_library_files

	#
	# get_link_options
	#
	#  Return the link options
	#
	def get_link_options (self):
		return self._link_options

	#
	# set_link_libraries
	#
	#  Set a new list of link libraries
	#
	def set_link_libraries (self, new_list):
		self._link_library_files = new_list

	#
	# get_library_search_paths
	#
	#  Return the search paths for a library
	#
	def get_library_search_paths (self):
		return self._library_search_paths

#
# find_dependent_projects
#
#  This guy will search through a list of files and extract those that are dependent
# projects. That is, this is a list of dependents. Some of them are going to be made into
# a project... which ones so we can establish project dependencies.
#
#  NOTE that at the moment I don't take into account library search paths, so that could
# lead to some problems with links! I suspect this should be handled some other place in
# this script, not here, however.
#
def find_dependent_projects (file_name_list, all_projects):
	found_list = []

	for file_name in file_name_list:
		if all_projects.has_key(file_name):
			t_type = all_projects[file_name].get_target_type()
			if is_a_project (t_type):
				found_list.append (file_name)

	return found_list

#
# is_a_project
#
#  Return true if this guy is a project
#
def is_a_project (project_type):
	return (project_type == "lib") or (project_type == "exe") or (project_type == "")

#
# get_file_class
#
#  Returns the class of a source file
#
def get_file_class (filename):
		file_class = ""
		pos = regex.search ("\.[^\.]*$", filename)
		if pos == -1:
			file_type = "exe"
		else:
			file_type = filename[pos+1:]

		if file_type in header_file_types:
			return "hpp"

		for a_target_class in source_file_classes.keys():
			if file_type in source_file_classes[a_target_class]:
				file_class = a_target_class
		return file_class

#
# get_source_file_helper
#
#  Helper obj to get the list of source files
#
class get_source_file_helper:
	def __init__ (self):
		self._source_file_list = []

	def source_list (self):
		return self._source_file_list

	def source_file (self, a_file, target_obj):
		self._source_file_list.append (a_file)
