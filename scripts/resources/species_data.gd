## Represents the biology and statistics of a pet species.
## Typically converted from a JSON file when packing mods.
class_name SpeciesData
extends Resource

@export_category("Common")
@export var name: String = "Pet"
@export var can_be_naturally_obtained: bool = false
@export var scale: float = 1.00
@export var collision_radius: float = 1.00
@export var collision_offset: Vector2 = Vector2.ZERO

@export_category("Gender")
@export var can_be_female: bool = false
@export var can_be_male: bool = false
@export_range(-10.0, 10.0, 1) var gender_ratio: float = 0.0

@export_category("Biology")
@export var average_weight: float = 1.0
@export var average_height: float = 1.0
@export var height_mutation: float = 0.0
@export var weight_mutation: float = 0.0
@export var weight_is_influenced: bool = false
@export var height_is_influenced: bool = false

@export_category("Preferences")
@export_range(0.5, 2.5, 1) var boredom_rate: float = 1.00
@export_range(0.5, 2.5, 1) var hunger_rate: float = 1.00
@export var flavor_preference: Array[GlobalEnums.Flavor] = []
@export var bedtime: Timestamp
@export var waketime: Timestamp

@export_category("Evolutions")
@export var can_evolve: bool = false
@export var evolutions: Array
