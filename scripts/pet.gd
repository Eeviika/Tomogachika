## Represents a semi-controllable pet in the game. This is the main element of the game.
class_name Pet
extends CharacterBody2D

#region Public Variables
## The pet's flavor preference(s). If left empty, the pet will not have any preference.
var flavor_preference: Array[GlobalEnums.Flavor] = []

## The pet's gender.
var gender: GlobalEnums.Gender = GlobalEnums.Gender.NONE
## The pet's mood.
var mood: GlobalEnums.Mood = GlobalEnums.Mood.NEUTRAL

## The pet's nickname. If empty, will default to the pet's name.
var display_name: String = ""
## The pet's name (not nickname).
var pet_name: String = ""

## How full the pet is.
var fullness: int = 50
## How much lasting fullness the pet has.
## Saturation decreases over time, affecting the rate at which the pet's hunger depletes.
## Once saturation reaches zero, then fullness will decrease directly.
var saturation: int = 10
var enjoyment: int = 50
var happiness: int = 50

## The pet's height in meters.
var height: float = 1.0
## The pet's weight in kilograms.
var weight: float = 1.0
## How quickly a pet hungers.
var hunger_rate: float = 1.00
## How quickly a pet's saturation decreases.
var saturation_rate: float = 1.00

## The time the pet wakes up.
var waketime: Dictionary[String, int] = {hour = 8, minute = 30, second = 0}
## The time the pet goes to sleep.
var bedtime: Dictionary[String, int] = {hour = 20, minute = 30, second = 0}

## Determines if the pet's weight can be influenced by eating (or lack thereof).
var weight_can_be_influenced: bool = true
## Determines if the pet's height can be influenced by sleeping.
var height_can_be_influenced: bool = true
#endregion

#region Private Variables
## The pet's average weight in kilograms. This is private and should not be accessed externally.
var _avg_weight: float = 1.0
## The pet's average height in meters. This is private and should not be accessed externally.
var _avg_height: float = 1.0

@onready var _tick_timer = $TickTime
#endregion
