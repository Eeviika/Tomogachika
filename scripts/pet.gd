## Represents a semi-controllable pet in the game. This is the main element of the game.
class_name Pet
extends CharacterBody2D

#region Public Variables
## The "base number" for stat updates.
const UPDATE_BASE: float = 0.11
## The gravity to apply to the pet.
const GRAVITY: float = 2.33
## A dummy unit is 16px and is used as a measurement unit.
const DUMMY_UNIT: int = 16

## The pet's gender.
var gender: GlobalEnums.Gender = GlobalEnums.Gender.NONE
## The pet's mood.
var mood: GlobalEnums.Mood = GlobalEnums.Mood.NEUTRAL

## The pet's nickname. If empty, will default to the pet's name.
var display_name: String = ""

## How fast the pet moves in terms of "dummy units (16px)."
## Example: If speed was set to 10, then the pet would have a max velocity of 160 (10 x 16).
var speed: int = 15

## How full the pet is. This can exceed 100.0.
var fullness: float = 50.0:
	get:
		return fullness
	set(value):
		fullness = clampf(value, 0.00, 100.0)
## How bored a pet is.
var boredom: float = 0.0:
	get:
		return boredom
	set(value):
		boredom = clampf(value, 0.00, 100.0)
## How happy a pet is.
var happiness: float = 50.0:
	get:
		return happiness
	set(value):
		happiness = clampf(value, 0.00, 100.0)
## How much energy the pet has.
var energy: float = 100.0:
	get:
		return energy
	set(value):
		energy = clampf(value, 0.00, 100.0)

## The pet's height in meters.
var height: float = 1.0
## The pet's weight in kilograms.
var weight: float = 1.0
#endregion

#region Private Variables
## The species data that this pet inherits.
var _species_data: SpeciesData

## The point of interest that this pet will move towards.
var _point_of_interest: Vector2 = Vector2.ZERO

## If this pet is active or not. Active pets do not tick.
## Pets are inactive by default and cannot become active without _species_data.
var _is_active: bool = false

@onready var _tick_timer = $TickTime
@onready var _sprite = $Sprite
@onready var _collision_box = $CollisionBox
#endregion


#region Private / Engine / Signal Functions
func _to_string() -> String:
	var text: String = "Name: {0} ({1}) [{2}]\n\tHappiness: {3}\n\tEnergy: {4}\n\tBoredom: {5}\n\tFullness: {6}"
	text = text.format(
		[_species_data.name, display_name, gender, happiness, energy, boredom, fullness]
	)
	return text


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
		velocity.x /= 1.5
	if velocity.x < speed:
		velocity.x = 0

	velocity.x = clampf(velocity.x, -(speed * DUMMY_UNIT), speed * DUMMY_UNIT)
	_animate()
	move_and_slide()


func _animate() -> void:
	var normalized_velocity: Vector2 = velocity.normalized()
	var animation_name: String = "idle_neutral"
	if normalized_velocity == Vector2.ZERO:
		if mood == GlobalEnums.Mood.UPSET or mood == GlobalEnums.Mood.TIRED:
			animation_name = "idle_upset"
		elif mood == GlobalEnums.Mood.HAPPY:
			animation_name = "idle_happy"
	if normalized_velocity == Vector2.LEFT:
		animation_name = "move_left"
	if normalized_velocity == Vector2.RIGHT:
		animation_name = "move_right"
	if normalized_velocity.y < 0 and normalized_velocity.x == Vector2.LEFT.x:
		animation_name = "jump_left"
	if normalized_velocity.y > 0 and normalized_velocity.x == Vector2.LEFT.x:
		animation_name = "fall_left"
	if normalized_velocity.y < 0 and normalized_velocity.x == Vector2.RIGHT.x:
		animation_name = "jump_right"
	if normalized_velocity.y > 0 and normalized_velocity.x == Vector2.RIGHT.x:
		animation_name = "fall_right"

	_sprite.play(animation_name)


func _move_towards_point_of_interest() -> void:
	# First, check if we are near the POI.
	if position.distance_to(_point_of_interest) <= 16:
		# We're close to the POI and can stop moving towards it.
		_point_of_interest = Vector2.ZERO
		return
	# Otherwise move towards the POI.
	velocity.x += (
		velocity.x + (speed / 2.0)
		if _point_of_interest.x > position.x
		else velocity.x - (speed / 2.0)
	)


func _tired_update() -> void:
	pass


func _tick_update() -> void:
	boredom += UPDATE_BASE * _species_data.boredom_rate
	fullness -= UPDATE_BASE * _species_data.boredom_rate
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

	_tick_timer.start()
	return _is_active


func jump() -> void:
	pass


func random_movement(forced: bool = false) -> void:
	if not (forced or randi_range(0, 10) == 10):
		return
	if not is_on_floor():
		return
	_point_of_interest = Vector2(position.x + randi_range(-75, 75), position.y)
#endregion
