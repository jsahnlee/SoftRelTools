#!python
#
# srt_make_ntide_files.py
#
#  This python script will build a set of MSVC 5.0 IDE files given the output
# from a gmake command in a cvs structure goverened by SRT. The BFARCH must be
# MSVC50-NT4 and the environment variable IDE_DUMP must be set to the name of the
# file that is passed as input to this script.
#

import sys
import os
import regsub
import copy

import srt_ntide_dump_file
import srt_ntide_target
import srt_ntbashutil
import srt_ntide_project_file
import srt_path_util

#
#  parse_ide_dump
#
#	Parse the ide dump and create all the file objects we need for this guy.
#
def parse_ide_dump (filename, newrel_dir):
	ide_file = srt_ntide_dump_file.ide_dump_file (filename)

	file_list = []

	while ide_file.there_is_more():
		ide_file.load_buffer()
		if not ide_file.is_star_line():
			raise "Badly formatted ide dump file!"

		new_target = srt_ntide_target.ide_target (ide_file, newrel_dir)
		file_list.append (new_target)

	return file_list

#
# combine_targets
#
#  Given a list of targets, construct a dictonary keyed off the target names
#
def combine_targets (target_list):
	target_dict = {}

	for a_file in target_list:
		t_name = a_file.get_target_name()
		if target_dict.has_key(t_name):
			target_dict[t_name].combine(a_file)
		else:
			target_dict[t_name] = a_file
	return target_dict

#
# find_project_targets
#
#  Return a string list of those guys that should be individual projects
#
def find_project_targets (target_dict):
	the_list = []
	for a_target_name in target_dict.keys():
		t_type = target_dict[a_target_name].get_target_type()
		if srt_ntide_target.is_a_project (t_type):
			the_list.append (a_target_name)

	return the_list

#
# create_project_workspace
#
#  Create the .dsw file at the root of the newrel directory
#
def create_project_workspace (newrel_dir, project_list, target_list):
	newrel_name = os.path.basename (newrel_dir)
	
	newrel_dsw = open (newrel_dir + "\\" + newrel_name + ".dsw", "w")

	newrel_dsw.write("Microsoft Developer Studio Workspace File, Format Version 5.00\n")
	newrel_dsw.write("# WARNING: DO NOT EDIT OR DELETE THIS WORKSPACE FILE!\n\n")

	for a_project_name in project_list:
		newrel_dsw.write ("###############################################################################\n\n")

		project_ide_name = target_list[a_project_name].get_project_ide_name()

		project_file = target_list[a_project_name].get_project_file()
		project_file = srt_path_util.get_relative_path (project_file, newrel_dir)
		newrel_dsw.write ('Project: "' + project_ide_name + '"=.\\' + project_file + " - Package Owner=<4>\n\n")
		newrel_dsw.write ("Package=<5>\n{{{\n}}}\n\n")

		#
		# Do the project dependancies
		#

		newrel_dsw.write ("Package=<4>\n{{{\n")

		dep_list = target_list[a_project_name].get_dependent_on_projects(target_list)
		for a_dep_name in dep_list:
			newrel_dsw.write ("    Begin Project Dependency\n")
			newrel_dsw.write ("    Project_Dep_Name " + target_list[a_dep_name].get_project_ide_name() + "\n")
			newrel_dsw.write ("    End Project Dependency\n")

		newrel_dsw.write ("}}}\n\n")

	#
	# Write out the global project properties
	#

	newrel_dsw.write ("###############################################################################\n\n")
	newrel_dsw.write ("Global:\n\n")
	newrel_dsw.write ("Package=<5>\n{{{\n}}}\n\n")
	newrel_dsw.write ("Package=<3>\n{{{\n")
	newrel_dsw.write ("}}}\n\n")
	newrel_dsw.close()

#
# split_targets
#
#  Loop over all the targets looking for guys that need to be split. If they do,
#  create the two new targets. Keep doing this till no more splits are needed.
#
def split_targets (target_list):
	#
	# First task is to split all the targets so that each has only one source
	# file.
	#
	
	new_target_list = []
	for target in target_list:
		source_list = target.get_target_source_file_list()
		if len(source_list) <= 1:
			new_target_list.append(target)
		else:
			for source_file in source_list:
				new_target = copy.deepcopy(target)
				new_target.set_source_file_list ([ source_file ])
				new_target_list.append(new_target)

	target_list = new_target_list

	#
	# Now, make sure that each target is really only one step
	#

	number_split = 1
	while number_split != 0:
		#
		# Init the loop
		#

		number_split = 0
		new_target_list = []

		for target in target_list:
			#
			#
			#
			# There is most likely a general way to do this (make certianly has one),
			# but I don't know how to do it.
			#

			source_file_list = target.get_target_source_file_list()
			if len(source_file_list) > 1:
				raise "Error: bad number of sources in " + target.get_target_name_root() + " (" + `len(source_file_list)` + ")."

			if len(source_file_list) == 0:
				source_file_type = "null_source"
			else:
				source_file_type = srt_path_util.file_type (source_file_list[0])
			dest_file_type = target.get_target_type()

			#
			#  If the source file type is part of the "compiled source list", then
			#  the target of this guy had better be a ".o" object file. If not, then
			#  this guy has to be made into two projects.
			#

			did_split = 0
			if source_file_type in srt_ntide_target.source_file_types:
				if dest_file_type != "o":

					obj_file = srt_path_util.change_to_type(source_file_list[0], "o")

					object_target = copy.deepcopy(target)
					object_target.reset_target_files()
					object_target.reset_libraries()
					object_target.set_compile_only (1)
					object_target.set_build_obj (obj_file)
					new_target_list.append (object_target)

					new_final_target = copy.deepcopy(target)
					new_final_target.set_source_file_list ([ obj_file ])
					new_target_list.append (new_final_target)
					did_split = 1

			if did_split:
				number_split = number_split + 1
			else:
				new_target_list.append (target)

		#
		# Have a new target list. Lets try the loop again.
		#

		target_list = new_target_list
	return target_list

#
# auto_link_libs
#
#  Find all the included library files that are also targets. Some
# libraries just exist, others we have to build. We want the ones we
# have to build to become project dependencies.
#
def auto_link_libs (target_map):
	#
	# First, get a list of all the .lib projects we are going to build
	#

	project_lib_map = {}
	for t_key in target_map.keys():
		if target_map[t_key].get_target_type() == "lib":
			project_lib_map[target_map[t_key].get_target_root_file()] = target_map[t_key]

	#
	# Next job is to loop through all the targets and find all
	# the .lib files they are leaning on. If their name matches
	# any of the names of the above list, then we alter it so that
	# we can create a dependancy later.
	#

	for t_key in target_map.keys():
		link_lib_list = target_map[t_key].get_link_libraries()
		new_link_lib_list = []
		for library in link_lib_list:
			basename = os.path.basename (library)
			(lib_name, exten) = os.path.splitext (basename)

			if project_lib_map.has_key(lib_name):
				target_map[t_key].add_source_file (project_lib_map[lib_name].get_target_name())
			else:
				new_link_lib_list.append (library)

		target_map[t_key].set_link_libraries (new_link_lib_list)

	return target_map

#
# main
#
#  Drive this whole thing
#
def main():

	#
	# Do a few sanity checks!
	#

	if len(sys.argv) < 3:
		print "Usage: " + sys.argv[0] + " <ide-dump-file> <slt-newrel-directory>"
		return 1

	ide_dump_file = srt_ntbashutil.translate_path(sys.argv[1])
	if not os.path.exists (ide_dump_file):
		print "File '" + sys.argv[1] + "' does not exist!"
		return 1

	newrel_dir = srt_ntbashutil.translate_path(sys.argv[2])
	if not os.path.exists (newrel_dir):
		print "newrel directory '" + newrel_dir + "' does not exist!"
		return 1

	build_workspace = 1
	if len(sys.argv) == 4:
		options_line = sys.argv[3]
		if options_line == "noworkspace":
			build_workspace = 0;
		elif options_line == "workspace":
			build_workspace = 1;
		else:
			raise "Unknown option (workspace, noworkspace allowed): " + options_line

	#
	# Now, parse the file. This will create a bunch of file objects.
	#

	file_objects = parse_ide_dump (ide_dump_file, newrel_dir)

	#
	# Some of the targets may actually be several steps all wrapped into one.
	# For example, a .cpp file as input, a .exe as output. Needs to be converted
	# to two bits.
	#

	file_objects = split_targets (file_objects)

	#
	# Next, turn them into a dictonary, keyed by their targets.  This also means that
	# if there is more than one of the same target it will be combined.
	#

	target_dict = combine_targets (file_objects)

	#
	# Next, see if there are project .lib's in there that are also project
	# targets of ours... we have to do this because there are several ways
	# to specify how to link in libraries.
	#

	target_dict = auto_link_libs (target_dict)

	#
	# Now, find the list of targets which should each be a project in the IDE
	#

	project_target_list = find_project_targets (target_dict)

	#
	# Next, create the project workspace in the newrel directory
	#

	if build_workspace:
		create_project_workspace (newrel_dir, project_target_list, target_dict)

	#
	# Now, for each of these guys, create a new project file!
	#

	for project in project_target_list:
		srt_ntide_project_file.create_project_file (target_dict[project], target_dict, newrel_dir)
		if not build_workspace:
			print "*** You MUST add the file " + target_dict[project].get_project_file() + " to your workspace!"

#
# If we are just being imported, do nothing
#
if __name__ == '__main__':
	main()

