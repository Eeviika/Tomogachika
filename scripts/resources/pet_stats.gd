## A pet's statistics. This should not be created in the editor.
class_name PetStats
extends Resource

## The pet's gender.
@export var gender := GlobalEnums.Gender.NONE
## The pet's mood.
@export var mood := GlobalEnums.Mood.NEUTRAL

## The pet's nickname. If empty, scripts will default to the pet's species name.
@export var display_name := ""

## How full the pet is.
@export var fullness := 50.0:
	set(value):
		fullness = clampf(value, 0.00, 100.0)
## How bored a pet is.
@export var boredom := 0.0:
	set(value):
		boredom = clampf(value, 0.00, 100.0)
## How happy a pet is.
@export var happiness := 50.0:
	set(value):
		happiness = clampf(value, 0.00, 100.0)
## How much energy the pet has.
@export var energy := 100.0:
	set(value):
		energy = clampf(value, 0.00, 100.0)

## The pet's height in meters.
@export var height := 1.0:
	set(value):
		height = clampf(height, 0.01, 999.9)
## The pet's weight in kilograms.
@export var weight := 1.0:
	set(value):
		weight = clampf(weight, 0.01, 999.9)
