## Represents a point in time.
class_name Timestamp
extends Resource

## The hour of this timestamp (in 24-hour time).
## Cannot be below 0 or exceed 23.
@export var hour: int = 0:
	get:
		return hour
	set(value):
		hour = floor(clamp(value, 0, 23))
## The minute of this timestamp.
## Cannot be below 0 or exceed 59.
@export var minute: int = 0:
	get:
		return minute
	set(value):
		minute = floor(clamp(value, 0, 59))
## The second of this timestamp.
## Cannot be below 0 or exceed 59.
@export var second: int = 0:
	get:
		return second
	set(value):
		second = floor(clamp(value, 0, 59))
