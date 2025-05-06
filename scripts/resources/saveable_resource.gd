## Resource that handles converting to / from dictionaries.
## Resources should implement their own save functionality.
class_name SaveableResource
extends Resource


## Returns a copy of the properties within the Resource in a Dictionary.
## These properties must exist, and must be passed through as an argument.
func to_dict(properties_to_save: Array[String]) -> Dictionary[String, Variant]:
	var result : Dictionary[String, Variant] = {}
	for prop in properties_to_save:
		if not (prop in self):
			continue
		result[prop] = get(prop)
	return result


## Gets the values from a Dictionary and assigns them to their respective properties
## within the Resource if they exist.
func from_dict(dictionary_to_load: Dictionary) -> void:
	for key in dictionary_to_load.keys():
		# Don't need to check if key exists, since set does nothing if key isnt in self
		set(key, dictionary_to_load[key])
