## Represents a semi-controllable pet in the game. This is the main element of the game.
class_name Pet
extends Actor

#region Signals

signal stat_updated(stat_name: String, value: Variant)

#endregion

#region Public Variables
## The "base number" for stat updates.
const UPDATE_BASE := 0.07

## The pet's species data.
var species_data: SpeciesData

## The pet's stats.
var pet_stats := PetStats.new()
#endregion

#region Private Variables

var _logger: Logger = Logger.new("PetObject")

var _is_active := false

@onready var _tick_timer := $TickTimer
@onready var _sprite := $Sprite
@onready var _collision_box := $CollisionObject
#endregion


#region Private / Engine / Signal Functions
func _create_animation_rules() -> Array[AnimationRule]:
	var idle_happy := AnimationRule.new()
	var idle_upset := AnimationRule.new()
	var animations: Array[AnimationRule] = []

	idle_happy.animation_name = "idle_happy"
	idle_happy.priority = 1
	idle_happy.condition = func(actor: Actor) -> bool:
		var pet = actor as Pet

		if pet == null:
			return false

		var _pet_stats: PetStats = pet.pet_stats
		return _pet_stats.mood == GlobalEnums.Mood.HAPPY and pet.velocity.x == 0 and pet.is_on_floor()

	animations.append(idle_happy)

	idle_upset.animation_name = "idle_upset"
	idle_upset.priority = 1
	idle_upset.condition = func(actor: Actor) -> bool:
		var pet = actor as Pet

		if pet == null:
			return false

		var _pet_stats: PetStats = pet.pet_stats
		return _pet_stats.mood == GlobalEnums.Mood.UPSET and pet.velocity.x == 0 and pet.is_on_floor()

	animations.append(idle_upset)
	animations.append_array(PredefinedAnimationRules.get_all())

	return animations


func _is_bedtime() -> bool:
	return TimeHelper.is_between_time(TimeHelper.current_time_to_timestamp(), species_data.bedtime, species_data.waketime)


func _update_mood() -> void:
	var mood_to_set := GlobalEnums.Mood.NEUTRAL

	if pet_stats.mood == GlobalEnums.Mood.DISAPPOINTED:
		if (
			pet_stats.fullness >= 60
			and pet_stats.boredom <= 40
			and pet_stats.energy >= 40
			and pet_stats.happiness >= 50

		):
			pet_stats.mood = GlobalEnums.Mood.NEUTRAL

		return

	if (
		pet_stats.fullness >= 60
		and pet_stats.boredom <= 40
		and pet_stats.energy >= 40
		and pet_stats.happiness >= 50

	):
		pet_stats.mood = GlobalEnums.Mood.HAPPY
		return

	if _is_bedtime() or pet_stats.energy <= 20:
		pet_stats.mood = GlobalEnums.Mood.TIRED
		return

	if pet_stats.fullness <= 20:
		mood_to_set = GlobalEnums.Mood.HUNGRY

	if pet_stats.boredom >= 80:
		if mood_to_set != GlobalEnums.Mood.NEUTRAL:
			pet_stats.mood = GlobalEnums.Mood.UPSET
			return

		mood_to_set = GlobalEnums.Mood.BORED

	if pet_stats.happiness <= 20:
		mood_to_set = GlobalEnums.Mood.UPSET

	pet_stats.mood = mood_to_set


func _tired_update() -> void:
	_logger.debug("tired_update isn't integrated yet, why are you calling this")
	_update_mood()
	pass


func _upset_update() -> void:
	_logger.debug("upset_update isn't integrated yet, why are you calling this")
	_update_mood()
	pass


func _tick_update() -> void:
	set_stat("boredom", pet_stats.boredom + (UPDATE_BASE * species_data.boredom_rate))
	set_stat("fullness", pet_stats.fullness - (UPDATE_BASE * species_data.hunger_rate))
	_update_mood()
	random_movement()


func _on_tick() -> void:
	# Common tick logic goes here

	var weight_ratio := pet_stats.weight / species_data.average_weight
	var height_ratio := pet_stats.height / species_data.average_height

	weight_ratio = clampf(weight_ratio, 0.8, 1.2)
	height_ratio = clampf(height_ratio, 0.8, 1.2)

	scale = Vector2(1, 1) * species_data.scale
	scale.x *= weight_ratio
	scale.y *= height_ratio

	if pet_stats.mood == GlobalEnums.Mood.TIRED:
		_tired_update()
		return

	if pet_stats.mood == GlobalEnums.Mood.UPSET or pet_stats.mood == GlobalEnums.Mood.DISAPPOINTED:
		_upset_update()
		return

	_tick_update()


func _cheater_no_cheating(cheat_cause: GlobalEnums.CheatCause):
	_logger.error("Cheater! No cheating!")
	_logger.error("Detected cheat: {0}".format([cheat_cause]))
	set_stat("mood", GlobalEnums.Mood.DISAPPOINTED)
	set_stat("fullness", pet_stats.fullness / 2)
	set_stat("energy", pet_stats.energy / 2)
	set_stat("happiness", pet_stats.happiness / 3)
	pass
#endregion


#region Public Methods
func feed(food: Food):
	pass


## Makes the pet object active. Ideally you'd want to call this before loading data.
## Effectively creates a new Pet with default attributes.
func make_active(species: SpeciesData, sprites: SpriteFrames):
	if _is_active:
		_logger.warn("Already active, cannot be made active again.")
		return false

	_logger.debug("Activating")
	process_mode = Node.PROCESS_MODE_PAUSABLE
	visible = true
	_sprite.sprite_frames = sprites
	species_data = species
	_is_active = true

	animation_rules.append_array(_create_animation_rules())

	_collision_box.position = species.collision_offset
	_collision_box.shape.radius = species.collision_radius
	scale *= species.scale

	pet_stats.height = (
		species.average_height
		+ randf_range(
			species.average_height - species.height_mutation,
			species.average_height + species.height_mutation

		)

	)

	pet_stats.weight = (
		species.average_weight
		+ randf_range(
			species.average_weight - species.weight_mutation,
			species.average_weight + species.weight_mutation

		)

	)
	
	acceleration = species_data.acceleration
	top_speed = species_data.top_speed

	var weight_ratio := pet_stats.weight / species_data.average_weight
	var height_ratio := pet_stats.height / species_data.average_height

	weight_ratio = clampf(weight_ratio, 0.8, 1.2)
	height_ratio = clampf(height_ratio, 0.8, 1.2)
	gravity_modifier = clampf(weight_ratio, 1.0, 1.2)

	scale = Vector2(1, 1) * species_data.scale
	scale.x *= weight_ratio
	scale.y *= height_ratio
	
	pet_stats._namespace = species_data._namespace

	_tick_timer.start()
	_logger.debug("Active")


func load_from_save_capsule(save_capsule: SaveCapsule):
	_logger.info("Loading from save...")

	var last_saved_date: Datestamp = save_capsule.last_saved_date
	var last_saved_time: Timestamp = save_capsule.last_saved_time
	var pet_data: Dictionary[String, Variant] = save_capsule.pet_data
	pet_stats.load_(pet_data)

	# Calculate how long it has been (in hours) since the player left.
	var hours_since_last_visit: int = 0
	var seconds_since_last_visit: int = 0
	var current_date: Datestamp = TimeHelper.current_date_to_datestamp()
	var current_time: Timestamp = TimeHelper.current_time_to_timestamp()

	var current_unix: int = TimeHelper.merge_and_convert(current_date, current_time)
	var last_unix: int = TimeHelper.merge_and_convert(last_saved_date, last_saved_time)

	seconds_since_last_visit = current_unix - last_unix
	@warning_ignore("integer_division")
	hours_since_last_visit = seconds_since_last_visit / 3600

	# Anti-cheat check:
	if last_unix > current_unix:
		_cheater_no_cheating(GlobalEnums.CheatCause.TIME_TRAVEL)
		return

	# Do not punish the player for being gone for a minor amount of time.
	if hours_since_last_visit <= 1.1:
		return

	var stat_update_rules = {
		"boredom": {"hour_mult": +2, "second_divisor": 120},
		"fullness": {"hour_mult": -2, "second_divisor": -120},
		"energy": {"hour_mult": -1, "second_divisor": -180},
		"happiness": {"hour_mult": -1, "second_divisor": -180}
	}

	for stat_name in stat_update_rules.keys():
		var rule = stat_update_rules[stat_name]
		var hour_effect = UPDATE_BASE * hours_since_last_visit * rule.hour_mult
		var second_effect = UPDATE_BASE * (seconds_since_last_visit / rule.second_divisor)
		set_stat(stat_name, pet_stats.get(stat_name) + hour_effect + second_effect)


func set_stat(stat_name: String, value: Variant) -> void:
	if not (stat_name in pet_stats):
		_logger.warn(stat_name + " cannot be changed for it doesn't exist!")
		return

	if typeof(value) != typeof(pet_stats.get(stat_name)):
		_logger.warn("set_stat type mismatch for stat {0}!".format([stat_name]))
		_logger.warn(
			"expected {0}, got {1}".format(
				[type_string(typeof(pet_stats.get(stat_name))), type_string(typeof(value))]

			)

		)
		return

	pet_stats.set(stat_name, value)
	stat_updated.emit(stat_name, value)
#endregion
