## A stack. Works similarly to Stacks in other languages.
## So long as you use only the public methods, you should be ok.
class_name Stack
extends RefCounted

var _data: Array[Variant] = []


## Creates a new Stack.
func new(initial_data: Array[Variant]):
	_data = initial_data


## Adds a new item to the Stack.
func push(value: Variant) -> void:
	_data.append(value)


## Removes and returns the most recent item from the Stack.
func pop() -> Variant:
	if _data.is_empty():
		push_error("Stack Underflow.")
		return null
	return _data.pop_back()


## Gets the most recent item of the Stack without removing it.
func peek() -> Variant:
	if _data.is_empty():
		push_error("Stack is empty. Cannot peek.")
		return null
	return _data.back()


## Returns the Stack's size.
func size() -> int:
	return _data.size()


## Clears the Stack.
func clear() -> void:
	return _data.clear()
