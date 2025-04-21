## Represents a saved game.
class_name SaveCapsule
extends Resource

## The last time that the Save Capsule was saved to.
@export var last_saved_time: Timestamp
## The last date that the Save Capsule was saved to.
@export var last_saved_date: Datestamp

var save_file: String

var save_name: String


func new():
	pass
