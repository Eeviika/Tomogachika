extends Node2D

var to_load: String = "internal_dummy"

@onready var pet: Pet = %Pet

@onready var debug_text: Label = %DebugText

@onready var reset_position_button: Button = %ResetPositionButton
@onready var reset_stats_button: Button = %ResetStatsButton
@onready var create_save_button: Button = %CreateSaveButton
@onready var create_old_save_button: Button = %CreateOldSaveButton
@onready var load_save_button: Button = %LoadSaveButton


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
	debug_text.text = ""
	pet.position = Vector2(100, 100)
	pet.stat_updated.connect(update_debug_text)

	reset_position_button.pressed.connect(func() -> void: pet.position = Vector2(384, 0))

	reset_stats_button.pressed.connect(
		func() -> void:
			pet.pet_stats.boredom = 0
			pet.pet_stats.happiness = 50
			pet.pet_stats.energy = 100
			pet.pet_stats.fullness = 50
			pet.pet_stats.mood = GlobalEnums.Mood.NEUTRAL
	)

	create_save_button.pressed.connect(
		func() -> void:
			var save: SaveCapsule = SaveCapsule.new(true, pet.pet_stats.save())
			save.save_to_file()
	)

	create_old_save_button.pressed.connect(
		func() -> void:
			var save: SaveCapsule = SaveCapsule.new(true, pet.pet_stats.save())
			save.last_saved_date.day -= 1
			save.save_to_file()
	)

	load_save_button.pressed.connect(
		func() -> void:
			var save: SaveCapsule = SaveCapsule.load_file("internal_dummy.sav")
			pet.load_from_save_capsule(save)
	)


func update_debug_text(_stat_name, _stat_value):
	debug_text.text = ""
	debug_text.text += "Mood: " + GlobalEnums.Mood.find_key(pet.pet_stats.mood)
	debug_text.text += "\nGender: " + GlobalEnums.Gender.find_key(pet.pet_stats.gender)
	debug_text.text += "\nFullness: %0.2f" % pet.pet_stats.fullness
	debug_text.text += "\nBoredom: %0.2f" % pet.pet_stats.boredom
	debug_text.text += "\nEnergy: %0.2f" % pet.pet_stats.energy
	debug_text.text += "\nHappiness: %0.2f" % pet.pet_stats.happiness
	debug_text.text += "\nWeight: %0.2f" % pet.pet_stats.weight + "kg"
	debug_text.text += "\nHeight: %0.2f" % pet.pet_stats.height + "m"
