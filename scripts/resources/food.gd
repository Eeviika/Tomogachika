class_name Food
extends Resource

## The flavor of the food. Pets like some flavors over others.
@export var flavor := GlobalEnums.Flavor.SWEET
## The quality of the food. The higher the quality, the more the pet will like it.
@export var quality := GlobalEnums.FoodQuality.AVERAGE
## The name of the food.
@export var name: String
## How filling it is to the pet.
@export_range(0.0, 100.0, 1.0) var fullness: float = 10.0
