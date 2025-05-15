class_name ToolkitCommandRef
extends Resource

## Visual syntax of the command. Affects nothing.
@export_multiline var command_syntax := "toolkit command_name"
## Description of the command.
@export_multiline var command_description := "command_description"
## Name of the callable that handles this command.
@export var callable_name := &"command_callable"
## Min amount of arguments that this command requires (from left to right).
@export var minimum_arguments := 0
## Max amounts of arguments that this command accepts.
@export var maximum_arguments := 0
