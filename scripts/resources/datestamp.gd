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
