## Represents the biology and statistics of a pet species.
## Typically converted from a JSON file when packing mods.
class_name SpeciesData
extends Resource

## The name of your pet's species.
@export var name: String = "Pet"
## Can this pet be naturally obtained?
## (via. finding eggs, purchasing, etc.)
## If false, this can only be obtained via a mod or command line.
@export var can_be_naturally_obtained: bool = false
## The size of the pet.
## (A scale of 2.00 means the pet will be twice as large.)
@export var scale: float = 1.00
## The radius of the collision circle.
@export var collision_radius: float = 1.00
## The offset of the collision circle from the center of the pet.
@export var collision_offset: Vector2 = Vector2.ZERO

## Gender-specific stuff.
@export_category("Gender")
## If true, this species can be female.
## If it cannot be either female or male, it is genderless.
@export var can_be_female: bool = false
## If true, this species can be male.
## If it cannot be either female or male, it is genderless.
@export var can_be_male: bool = false
## The gender ratio of the pet.
## Lower numbers means more males, higher numbers means more females.
@export_range(-10.0, 10.0, 1) var gender_ratio: float = 0.0

## Biology and physical traits.
@export_category("Biology")
## The average weight of this species.
@export var average_weight: float = 1.0
## The average height of this species.
@export var average_height: float = 1.0
## The possible height mutation when one hatches.
@export var height_mutation: float = 0.0
## The possible weight mutation when one hatches.
@export var weight_mutation: float = 0.0
## Determines if weight can be influenced by overeating / undereating.
@export var weight_is_influenced: bool = false
## Determines if height can be influenced by sleeping.
@export var height_is_influenced: bool = false

## The species specific preferences.
@export_category("Preferences")
## How fast this species gets bored.
@export_range(0.5, 2.5, .1) var boredom_rate: float = 1.00
## How fast this species gets hungry.
@export_range(0.5, 2.5, .1) var hunger_rate: float = 1.00
## The flavor preference(s) of this species.
## If left empty, pets of this species may have random (or no) preferences.
@export var flavor_preference: Array[GlobalEnums.Flavor] = []
## When this species prefers to sleep.
@export var bedtime: Timestamp = Timestamp.new()
## When this species prefers to wake up.
@export var waketime: Timestamp = Timestamp.new()

## Evolution stuff.
@export_category("Evolutions")
## Determines if this species can evolve into another species.
@export var can_evolve: bool = false
## The possible evolutions this species can undertake.
## Has no effect if `can_evolve` is false.
@export var evolutions: Array[EvolutionData] = []
