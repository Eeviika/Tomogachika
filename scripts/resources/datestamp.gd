## Represents a specific date.
class_name Datestamp
extends Resource

## The day of this datestamp.
## Cannot be below 1 or exceed 31.
@export var day: int = 0:
	get:
		return day
	set(value):
		day = clampi(value, 1, 31)
## The month of this datestamp.
## Cannot be below 1 or exceed 12.
@export var month: int = 0:
	get:
		return month
	set(value):
		month = (clampi(value, 1, 12))
## The year of this datestamp.
## Cannot be below 1 or exceed 9999.
@export var year: int = 0:
	get:
		return year
	set(value):
		year = (clampi(value, 1, 9999))


## Converts the datestamp into a string in ISO 8601 format.
func _to_string() -> String:
	return "{0}-{1}-{2}".format([year, month, day])

## Converts the datestamp into a dictionary.
func _to_dict() -> Dictionary[String, int]:
	return {
		"year" = year,
		"month" = month,
		"day" = day
	}
