extends Node2D

var to_load: String = "internal_dummy"

@onready var pet: CharacterBody2D = %Pet


# We will pretend to be a "pet loader" that wants to load the dummy pet.
func _ready() -> void:
	# First, find it in content/species
	assert(
		ResourceLoader.exists("res://content/species/" + to_load + ".tres", "SpeciesData"),
		"res://content/species/" + to_load + ".tres doesn't exist"
	)
	var species_data: SpeciesData = load("res://content/species/" + to_load + ".tres")
	# Then find its respective spriteframes
	assert(
		ResourceLoader.exists("res://content/petsprites/" + to_load + ".tres"),
		"res://content/petsprites/" + to_load + ".tres doesn't exist"
	)
	var pet_sprites: SpriteFrames = load("res://content/petsprites/" + to_load + ".tres")
	# Then make the pet active
	pet.make_active(species_data, pet_sprites)
	pet.position = Vector2(100, 100)
