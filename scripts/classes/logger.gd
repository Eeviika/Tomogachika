## Logger class for debugging and logging.
class_name Logger
extends RefCounted

var _id: String = ""


## Creates a new Logger.
func new(id: String):
	_id = id


## Prints to the output stream including the stack trace.
## Does nothing on release builds.
## Does not work on Threads. Use 't_debug' as an alternative.
func debug(text: String):
	if not OS.is_debug_build():
		return
	print_debug("[{0}/DEBUG]: {1}".format([_id, text]))


## Prints to the output stream on the DEBUG level.
## Does nothing on release builds.
## A good alternative for Threads.
func t_debug(text: String):
	if not OS.is_debug_build():
		return
	print("[{0}/DEBUG]: {1}".format([_id, text]))


## Prints to standard output on the INFO level.
func info(text: String):
	print("[{0}/INFO]: {1}".format([_id, text]))


## Prints to standard output on the WARN level.
## Also pushes warning to Godot's built-in debugger.
func warn(text: String):
	push_warning("[{0}/WARN]: {1}".format([_id, text]))


## Prints to standard output on the ERROR level.
## Also pushes warning to Godot's built-in debugger.
## Also halts execution on Debug builds.
func error(text: String):
	assert('Error thrown by "{0}"!'.format(_id))
	push_error("[{0}/ERROR]: {1}".format([_id, text]))
