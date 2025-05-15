## Represents a saved game.
## This is a runtime class (should not be created in editor).
class_name SaveCapsule
extends Resource

## The last time that the Save Capsule was saved to.
var last_saved_time: Timestamp
## The last date that the Save Capsule was saved to.
var last_saved_date: Datestamp

## The pet data stored in the capsule.
var pet_data: Dictionary[String, Variant]


func _init(create_new: bool = false, new_pet_data: Dictionary = {}) -> void:

	if not create_new:
		return

	if new_pet_data.is_empty():
		return

	last_saved_date = TimeHelper.current_date_to_datestamp()
	last_saved_time = TimeHelper.current_time_to_timestamp()
	pet_data = new_pet_data


func _create_directories():
	if not DirAccess.dir_exists_absolute("user://pet_saves/"):
		DirAccess.make_dir_absolute("user://pet_saves/")


## Creates a file and saves the contents of the save capsule in it.
func save_to_file():
	_create_directories()
	if pet_data.get("_namespace") == null:
		push_error("SaveToFile failed: no namespace provided")
		return

	var save_file = FileAccess.open("user://pet_saves/" + pet_data.get("_namespace") + ".sav", FileAccess.WRITE)

	if save_file == null:
		push_error("SaveToFile failed: " + str(FileAccess.get_open_error()))
		return

	save_file.store_var({
		# save_version and its project setting is an int
		# using override for compatiability with custom saves
			# which has the consequence of said saves not loadable on vanilla games
			# (versions won't match up, non-int versions won't load)

		"save_version" = ProjectSettings.get_setting_with_override("game/config/save_file_version"),
		"saved_before_quitting" = true,
		"last_saved_date" = last_saved_date.to_dict(),
		"last_saved_time" = last_saved_time.to_dict(),
		"pet_data" = pet_data
	})
	save_file.close()


## Loads a file, and then creates a Save Capsule from it.
static func load_file(filename: String) -> SaveCapsule:
	if not filename.is_absolute_path():
		# Assumes that the user is referring to the actual file name
		# of a save game.
		filename = "user://pet_saves/" + filename

	assert(FileAccess.file_exists(filename), "LoadFile given non-existent filename")

	var new_save_capsule: SaveCapsule = SaveCapsule.new(false)
	var save_file = FileAccess.open(filename, FileAccess.READ)

	if save_file == null:
		push_error("LoadFile failed: " + str(FileAccess.get_open_error()))
		return null

	var file_contents: Dictionary = save_file.get_var()

	if file_contents.save_version != ProjectSettings.get_setting_with_override("game/config/save_file_version"):
		push_error("LoadFile failed: invalid save version")
		return null

	new_save_capsule.last_saved_date = TimeHelper.create_datestamp(file_contents.last_saved_date)
	new_save_capsule.last_saved_time = TimeHelper.create_timestamp(file_contents.last_saved_time)
	new_save_capsule.pet_data = file_contents.pet_data

	save_file.close()
	save_file = FileAccess.open(filename, FileAccess.WRITE)

	file_contents.saved_before_quitting = false
	save_file.store_var(file_contents)

	save_file.close()

	return new_save_capsule
