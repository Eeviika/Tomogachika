## A pet's statistics. This should not be created in the editor.
class_name PetStats
extends SaveableResource

var SAVEABLE_KEYS: Array[String] = [
	"_namespace",
	"gender",
	"mood",
	"display_name",
	"fullness",
	"boredom",
	"happiness",
	"energy",
	"height",
	"weight"
]

## Namespace from the SpeciesData assigned to this pet.
@warning_ignore("unused_private_class_variable")
var _namespace := &""

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
@export var height := 1.0
## The pet's weight in kilograms.
@export var weight := 1.0


func save() -> Dictionary[String, Variant]:
	return to_dict(SAVEABLE_KEYS)


func load_(data: Dictionary) -> void:
	from_dict(data)
