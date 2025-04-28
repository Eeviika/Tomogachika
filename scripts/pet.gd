## Represents a semi-controllable pet in the game. This is the main element of the game.
class_name Pet
extends CharacterBody2D

#region Signals

signal stat_updated(stat_name: String, value: Variant)

#endregion

#region Public Variables
## The "base number" for stat updates.
const UPDATE_BASE := 0.07
## The gravity to apply to the pet.
const GRAVITY := 2.33

## How close the pet must get to the POI before it considers the POI "reached."
const POI_LENIENCY := 6
## Units for movement.
const DUMMY_UNIT := 16

## The pet's species data.
var species_data: SpeciesData

## The pet's stats.
var pet_stats := PetStats.new()
#endregion

#region Private Variables

var _logger: Logger = Logger.new("PetObject")

var pet_stats_saveable := [
	"height",
	"weight",
	"gender",
	"mood",
	"display_name",
	"fullness",
	"boredom",
	"happiness",
	"energy"
]

var _point_of_interest := Vector2.ZERO

var _is_active := false

@onready var _tick_timer := $TickTime
@onready var _sprite := $Sprite
@onready var _collision_box := $CollisionBox
#endregion


#region Private / Engine / Signal Functions
func _is_bedtime() -> bool:
	return (
		TimeHelper.is_past_time(
			TimeHelper.create_timestamp(Time.get_time_dict_from_system()), species_data.bedtime
		)
		or TimeHelper.is_before_time(
			TimeHelper.create_timestamp(Time.get_time_dict_from_system()), species_data.waketime
		)
	)


func _update_mood() -> void:
	var mood_to_set := GlobalEnums.Mood.NEUTRAL

	if (
		pet_stats.fullness >= 70
		and pet_stats.boredom <= 30
		and pet_stats.energy >= 20
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


func _physics_process(_delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY + (pet_stats.weight + species_data.average_weight)
	elif velocity.y > 0:
		velocity.y = 0

	if _point_of_interest != Vector2.ZERO:
		_move_towards_point_of_interest()
	else:
		var deceleration = abs(species_data.acceleration) * 2
		if velocity.x > 0:
			velocity.x = max(velocity.x - deceleration, 0)
		elif velocity.x < 0:
			velocity.x = min(velocity.x + deceleration, 0)

	velocity.x = clampf(
		velocity.x, -species_data.top_speed * DUMMY_UNIT, species_data.top_speed * DUMMY_UNIT
	)
	_animate()
	move_and_slide()


func _animate() -> void:
	var normalized_velocity: Vector2 = velocity.normalized()
	var animation_name: String = "idle_neutral"
	var animation_speed: float = 1.0

	if velocity.y < 0:
		if normalized_velocity.x < 0:
			animation_name = "jump_left"
		else:
			animation_name = "jump_right"
	elif velocity.y > 0:
		if normalized_velocity.x < 0:
			animation_name = "fall_left"
		else:
			animation_name = "fall_right"

	elif normalized_velocity.x < 0:
		animation_name = "move_left"
		animation_speed = -species_data.top_speed / -velocity.x
	elif normalized_velocity.x > 0:
		animation_name = "move_right"
		animation_speed = species_data.top_speed / velocity.x

	else:
		if pet_stats.mood == GlobalEnums.Mood.UPSET or pet_stats.mood == GlobalEnums.Mood.TIRED:
			animation_name = "idle_upset"
		elif pet_stats.mood == GlobalEnums.Mood.HAPPY:
			animation_name = "idle_happy"

	if _sprite.animation != animation_name:
		animation_speed = clampf(animation_speed, 0.0, 1.0)
		_sprite.play(animation_name)


func _move_towards_point_of_interest() -> void:
	# First, check if we are near the POI.
	if position.distance_to(_point_of_interest) <= POI_LENIENCY:
		_logger.debug("Reached POI")
		# We're close to the POI and can stop moving towards it.
		_point_of_interest = Vector2.ZERO
		return
	# Otherwise move towards the POI.
	velocity.x += (
		species_data.acceleration * DUMMY_UNIT
		if _point_of_interest.x > position.x
		else -species_data.acceleration * DUMMY_UNIT
	)


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

	var weight_ratio := pet_stats.weight / species_data.average_weight
	var height_ratio := pet_stats.height / species_data.average_height

	weight_ratio = clampf(weight_ratio, 0.8, 1.2)
	height_ratio = clampf(height_ratio, 0.8, 1.2)

	scale = Vector2(1, 1) * species_data.scale
	scale.x *= weight_ratio
	scale.y *= height_ratio

	_tick_timer.start()
	_logger.debug("Active")


## Saves the pet's data as a Dictionary.
## This reads from PetStats by using the array _pets_stats_saveable.
func save() -> Dictionary[String, Variant]:
	_logger.info("Saving data...")
	var saved_data: Dictionary[String, Variant] = {}

	for item in pet_stats_saveable:
		var value = pet_stats.get(item)
		if value == null:
			_logger.warn("Cannot save {0}.".format(item))
			continue
		saved_data[item] = value

	saved_data["_namespace"] = species_data._namespace

	_logger.info("Done saving data.")
	_logger.t_debug(str(saved_data))
	return saved_data


func load_from_save_capsule(save_capsule: SaveCapsule):
	_logger.info("Loading from save...")

	var last_saved_date: Datestamp = save_capsule.last_saved_date
	var last_saved_time: Timestamp = save_capsule.last_saved_time
	var pet_data: Dictionary[String, Variant] = save_capsule.pet_data

	for key in pet_data.keys():
		pet_stats.set(key, pet_data[key])

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

	set_stat("boredom", pet_stats.boredom + (UPDATE_BASE) * (hours_since_last_visit * 2))
	@warning_ignore("integer_division")
	set_stat("boredom", pet_stats.boredom + (UPDATE_BASE) * (seconds_since_last_visit / 120))
	set_stat("fullness", pet_stats.fullness - (UPDATE_BASE) * (hours_since_last_visit * 2))
	@warning_ignore("integer_division")
	set_stat("fullness", pet_stats.fullness - (UPDATE_BASE) * (seconds_since_last_visit / 120))
	set_stat("energy", pet_stats.energy - (UPDATE_BASE) * (hours_since_last_visit))
	@warning_ignore("integer_division")
	set_stat("energy", pet_stats.energy - (UPDATE_BASE) * (seconds_since_last_visit / 180))
	set_stat("happiness", pet_stats.happiness - (UPDATE_BASE) * (hours_since_last_visit))
	@warning_ignore("integer_division")
	set_stat("happiness", pet_stats.happiness - (UPDATE_BASE) * (seconds_since_last_visit / 180))


func jump() -> void:
	_logger.debug("Jump isn't integrated yet, why are you calling this")
	pass


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


func random_movement() -> void:
	if _point_of_interest != Vector2.ZERO:
		_logger.t_debug("Cannot do random movement because POI already defined")
		return
	if not randi_range(0, 30) == 30:
		return
	if not is_on_floor():
		_logger.t_debug("Cannot do random movement because not on floor")
		return
	_point_of_interest = Vector2(position.x + randi_range(-75, 75) + POI_LENIENCY, position.y)
	_logger.t_debug("New POI: {0}".format([_point_of_interest]))
	_logger.t_debug("Current Position: {0}".format([position]))
	if _point_of_interest.x < 0 or _point_of_interest.x > 720:
		_logger.t_debug("Cancelling random movement POI because it potentially goes out of bounds")
		_point_of_interest = Vector2.ZERO
#endregion
