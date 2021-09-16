#
#  This guy will read an input file and sub for strings of the form
#  "${blah}", and replace them with the contents of a dictionary that
#  has the key "blah" in it. A nice way to do string subsitiution when
#  generating a file from a template.
#
#  Created by Gordon Watts (Brown) November 1997

import regex
import regsub

def file_template (output_handle, input_file_name, dictionary):
    #
    # Open the input file
    #

    input_handle = open (input_file_name, "r")

    #
    # Now, read the input to the output
    #

    line = input_handle.readline()
    while (line != ""):
	output_handle.write(translate_line(line, dictionary))
	line = input_handle.readline()

    #
    # Done, close the input file
    #

    input_handle.close()


#
# translate_line
#
#  Do subsitution for a single line. Don't use the regsub module because
# something strange happens when replacing with double "\"s.
#
find_sub = regex.compile("\${\([^{} ]+\)}")
find_if = regex.compile("\${if \([^{} ]+\)}")
find_end = regex.compile("\${end}")
find_start = regex.compile("\${")
add_to_line_ok = 1
if_stack = [1]
def translate_line (line, dict):
	global add_to_line_ok

	result = ""
	remaining_line = line
	while find_start.search(remaining_line) != -1:
		#
		# Get rid of everything before the start of the ${.
		#

		(start_pos, finish_pos) = find_start.regs[0]
		if add_to_line_ok:
			result = result + remaining_line[:start_pos]
		remaining_line = remaining_line[start_pos:]

		#
		# Now, figure out what kind of thing we are looking at
		#

		if find_if.search (remaining_line) == 0:
			if_is_true = 0
			if dict.has_key(find_if.group(1)):
				if_is_true = 1
			if_stack.insert (0, if_is_true)
			add_to_line_ok = if_is_true
			end_of_string = find_if.regs[0][1]

		elif find_end.search(remaining_line) == 0:
			if len (if_stack) == 1:
				raise "Too many ${end} in template file!"
			del if_stack[0:1]
			add_to_line_ok = if_stack[0]
			end_of_string = find_end.regs[0][1]

		elif find_sub.search(remaining_line) == 0:
			if add_to_line_ok:
				if dict.has_key(find_sub.group(1)):
					result = result + dict[find_sub.group(1)]
			end_of_string = find_sub.regs[0][1]
		else:
			end_of_string = 0
			
		#
		# And remove anything we have looked at from remaining_line
		#

		remaining_line = remaining_line[end_of_string:]
			
	#
	# This means remaining line doesn't have anything interesting left on it. That means
	# we need to just do the append
	#

	if add_to_line_ok:
		result = result + remaining_line

	#
	# Done!
	#

	return result
