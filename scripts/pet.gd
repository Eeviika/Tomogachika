## Represents a semi-controllable pet in the game. This is the main element of the game.
class_name Pet
extends CharacterBody2D

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
#endregion

#region Private Variables
var _pet_stats := PetStats.new()

var _logger: Logger = Logger.new("PetObject")

var _pet_stats_saveable := [
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
func _update_mood() -> void:
	if (
		TimeHelper.is_past_time(
			TimeHelper.create_timestamp(Time.get_time_dict_from_system()), species_data.bedtime
		)
		or TimeHelper.is_before_time(
			TimeHelper.create_timestamp(Time.get_time_dict_from_system()), species_data.waketime
		)
	):
		pass


func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY + (_pet_stats.weight + species_data.average_weight)
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
	if normalized_velocity == Vector2.ZERO:
		if _pet_stats.mood == GlobalEnums.Mood.UPSET or _pet_stats.mood == GlobalEnums.Mood.TIRED:
			animation_name = "idle_upset"
		elif _pet_stats.mood == GlobalEnums.Mood.HAPPY:
			animation_name = "idle_happy"
	if normalized_velocity == Vector2.LEFT:
		animation_name = "move_left"
		animation_speed = int(-(species_data.top_speed * DUMMY_UNIT) / velocity.x)
	if normalized_velocity == Vector2.RIGHT:
		animation_name = "move_right"
		animation_speed = int((species_data.top_speed * DUMMY_UNIT) / velocity.x)
	if normalized_velocity.y < 0 and normalized_velocity.x == Vector2.LEFT.x:
		animation_name = "jump_left"
	if normalized_velocity.y > 0 and normalized_velocity.x == Vector2.LEFT.x:
		animation_name = "fall_left"
	if normalized_velocity.y < 0 and normalized_velocity.x == Vector2.RIGHT.x:
		animation_name = "jump_right"
	if normalized_velocity.y > 0 and normalized_velocity.x == Vector2.RIGHT.x:
		animation_name = "fall_right"

	if _sprite.animation == animation_name:
		return

	animation_speed = clampf(animation_speed, 0.0, 1.0)

	_sprite.play(animation_name, animation_speed)


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
	_logger.debug("tired isn't integrated yet, why are you calling this")
	pass


func _tick_update() -> void:
	_pet_stats.boredom += UPDATE_BASE * species_data.boredom_rate
	_pet_stats.fullness -= UPDATE_BASE * species_data.hunger_rate
	random_movement()


func _on_tick() -> void:
	if _pet_stats.mood == GlobalEnums.Mood.TIRED:
		_tired_update()
		return
	_tick_update()


func _cheater_no_cheating(cheat_cause: GlobalEnums.CheatCause):
	_logger.error("Cheater! No cheating!")
	_logger.error("Detected cheat: {0}".format([cheat_cause]))
	_pet_stats.mood = GlobalEnums.Mood.DISAPPOINTED
	_pet_stats.fullness /= 2
	_pet_stats.energy /= 2
	_pet_stats.happiness /= 3
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

	_pet_stats.height = (
		species.average_height
		+ randf_range(
			species.average_height - species.height_mutation,
			species.average_height + species.height_mutation
		)
	)

	_pet_stats.weight = (
		species.average_weight
		+ randf_range(
			species.average_weight - species.weight_mutation,
			species.average_weight + species.weight_mutation
		)
	)

	_tick_timer.start()
	_logger.debug("Active")


## Saves the pet's data as a Dictionary.
## This reads from PetStats by using the array _pets_stats_saveable.
func save() -> Dictionary[String, Variant]:
	_logger.info("Saving data...")
	var saved_data: Dictionary[String, Variant] = {}

	for item in _pet_stats_saveable:
		var value = _pet_stats.get(item)
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
		_pet_stats.set(key, pet_data[key])

	# Calculate how long it has been (in hours) since the player left.
	var hours_since_last_visit: int = 0
	var seconds_since_last_visit: int = 0
	var current_date: Datestamp = TimeHelper.current_date_to_datestamp()
	var current_time: Timestamp = TimeHelper.current_time_to_timestamp()

	var current_unix: int = TimeHelper.merge_and_convert(current_date, current_time)
	var last_unix: int = TimeHelper.merge_and_convert(last_saved_date, last_saved_time)

	seconds_since_last_visit = current_unix - last_unix
	hours_since_last_visit = seconds_since_last_visit / 3600

	# Anti-cheat check:
	if last_unix > current_unix:
		_cheater_no_cheating(GlobalEnums.CheatCause.TIME_TRAVEL)
		return

	_pet_stats.boredom += (UPDATE_BASE / 2) * hours_since_last_visit
	_pet_stats.fullness -= (UPDATE_BASE / 2) * hours_since_last_visit
	_pet_stats.energy -= (UPDATE_BASE / 4) * hours_since_last_visit
	_pet_stats.happiness -= (UPDATE_BASE / 6) * hours_since_last_visit


func jump() -> void:
	_logger.debug("Jump isn't integrated yet, why are you calling this")
	pass


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
	save()
#endregion
