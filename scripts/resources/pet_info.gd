## Represents the contents and statistics of a pet.
## Typically converted from a JSON file when packing mods.
class_name PetInfo
extends Resource

@export_category("Common")
@export var name: String
@export var can_be_naturally_obtained: bool
@export var scale: float
@export var collision_radius: float
@export var collision_offset: Vector2

@export_category("Gender")
@export var can_be_female: bool
@export_range(0, 100, 1) var female_chance: float
@export var can_be_male: bool
@export_range(0, 100, 1) var male_chance: float

@export_category("Biology")
@export var average_weight: float
@export var average_height: float
@export var height_mutation: float
@export var weight_mutation: float
@export var weight_is_influenced: bool
@export var height_is_influenced: bool
