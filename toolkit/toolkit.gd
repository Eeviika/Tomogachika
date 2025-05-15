extends Node

var info_table: Dictionary[String, String] = {}

var valid_commands: Array[ToolkitCommandRef] = []

var valid_command_strings: Array[String] = []

var format_table: Dictionary[String, String] = {
	"version": ProjectSettings.get_setting("application/config/version")
}


func _ready() -> void:
	var args := OS.get_cmdline_args()

	var command = args[0] if args.size() >= 1 else ""
	var command_index := 0
	args.remove_at(0)

	print("> " + command + " " + " ".join(args))

	for file in ResourceLoader.list_directory("res://toolkit/command_references/"):
		var full_path = "res://toolkit/command_references/" + file
		var ref: ToolkitCommandRef = load(full_path)

		if not ref:
			push_warning("Could not load " + full_path)
			continue

		valid_commands.append(ref)
		valid_command_strings.append(str(ref.callable_name))
		info_table[str(ref.callable_name)] = \
		ref.command_syntax + "\n\n" \
		+ "Description:\n\t" + ref.command_description.format(format_table)

	if not (command in valid_command_strings):
		print("Unrecognized command.")
		command = ""
	else:
		command_index = valid_command_strings.find(command)

	if command == null or command == "":
		generic()
		get_tree().quit()
		return

	if (
		args.size() > valid_commands[command_index].maximum_arguments or \
		args.size() < valid_commands[command_index].minimum_arguments

	):
		print("bad argument size")
		get_tree().quit()

	Callable(self, command).callv([args])
	get_tree().quit()


func info(args: Array = []) -> void:

	var command = args[0] if args.size() == 1 else ""
	if not (command in info_table) and command != "":
		print("help: I don't know what \"" + command + "\" is.\nProviding generic help dialogue.")
		command = ""

	if command == "":
		generic()
		return


func generic(_args: Array = []) -> void:
	print("ok")
	return
