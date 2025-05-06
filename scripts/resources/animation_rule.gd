class_name AnimationRule
extends Resource

@export var animation_name := ""
@export var priority := 0

var condition: Callable

func matches(actor) -> bool:
	if condition and condition.is_valid():
		return condition.call(actor)
	return false
