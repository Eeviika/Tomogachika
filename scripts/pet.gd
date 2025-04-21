## Represents a semi-controllable pet in the game. This is the main element of the game.
class_name Pet
extends CharacterBody2D

#region Public Variables
## The "base number" for stat updates.
const UPDATE_BASE := 0.11
## The gravity to apply to the pet.
const GRAVITY := 2.33
#endregion

#region Private Variables
var _species_data: SpeciesData

var _pet_stats: PetStats = PetStats.new()

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
func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY
	elif velocity.y > 0:
		velocity.y = 0

	if _point_of_interest != Vector2.ZERO:
		_move_towards_point_of_interest()
	else:
		velocity.x -= (
			_species_data.acceleration * 2
			if _species_data.acceleration > 0
			else -_species_data.acceleration * 2
		)
	if velocity.x < _species_data.acceleration:
		velocity.x = 0

	velocity.x = clampf(velocity.x, -_species_data.top_speed, _species_data.top_speed)
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
		animation_speed = _species_data.top_speed / velocity.x
	if normalized_velocity == Vector2.RIGHT:
		animation_name = "move_right"
		animation_speed = _species_data.top_speed / velocity.x
	if normalized_velocity.y < 0 and normalized_velocity.x == Vector2.LEFT.x:
		animation_name = "jump_left"
	if normalized_velocity.y > 0 and normalized_velocity.x == Vector2.LEFT.x:
		animation_name = "fall_left"
	if normalized_velocity.y < 0 and normalized_velocity.x == Vector2.RIGHT.x:
		animation_name = "jump_right"
	if normalized_velocity.y > 0 and normalized_velocity.x == Vector2.RIGHT.x:
		animation_name = "fall_right"

	_sprite.play(animation_name, animation_speed)


func _move_towards_point_of_interest() -> void:
	# First, check if we are near the POI.
	if position.distance_to(_point_of_interest) <= 16:
		# We're close to the POI and can stop moving towards it.
		_point_of_interest = Vector2.ZERO
		return
	# Otherwise move towards the POI.
	velocity.x += (
		_species_data.acceleration
		if _point_of_interest.x > position.x
		else -_species_data.acceleration
	)


func _tired_update() -> void:
	pass


func _tick_update() -> void:
	_pet_stats.boredom += UPDATE_BASE * _species_data.boredom_rate
	_pet_stats.fullness -= UPDATE_BASE * _species_data.hunger_rate
	random_movement()


func _on_tick() -> void:
	if (
		TimeHelper.is_past_time(
			TimeHelper.create_timestamp(Time.get_time_dict_from_system()), _species_data.bedtime
		)
		or TimeHelper.is_before_time(
			TimeHelper.create_timestamp(Time.get_time_dict_from_system()), _species_data.waketime
		)
	):
		_tired_update()
		return
	_tick_update()


#endregion


#region Public Methods
## Makes the pet object active. Ideally you'd want to call this before loading data.
## Effectively creates a new Pet with default attributes.
func make_active(species: SpeciesData, sprites: SpriteFrames) -> bool:
	if _is_active:
		return false
	process_mode = Node.PROCESS_MODE_PAUSABLE
	visible = true
	_sprite.sprite_frames = sprites
	_species_data = species
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
	return _is_active


## Saves the pet's data as a Dictionary.
## This reads from PetStats by using the array _pets_stats_saveable.
func save() -> Dictionary[String, Variant]:
	var saved_data: Dictionary[String, Variant] = {}

	for item in _pet_stats_saveable:
		var value = _pet_stats.get(item)
		if value == null:
			push_warning("")
			continue
		saved_data[item] = value

	return saved_data


func jump() -> void:
	pass


func random_movement(forced: bool = false) -> void:
	if _point_of_interest != Vector2.ZERO and not forced:
		return
	if not (forced or randi_range(0, 10) == 10):
		return
	if not is_on_floor():
		return
	_point_of_interest = Vector2(position.x + randi_range(-75, 75), position.y)
#endregion
