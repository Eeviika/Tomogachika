class_name Actor
extends CharacterBody2D

@onready var hitbox: CollisionShape2D = $CollisionObject
@onready var sprite: AnimatedSprite2D = $Sprite

## The gravity to apply to the Actor.
const GRAVITY := 2.33

## How close the Actor must get to the POI before it considers the POI "reached."
const POI_LENIENCY := 6
## Units for movement.
const DUMMY_UNIT := 16

## Location that Actor wants to move towards.
var point_of_interest := Vector2.ZERO

## How fast the Actor accelerates towards its top speed.
var acceleration := 0.0
## The maximum speed that the Actor can go.
var top_speed := 0.0

## Additional gravity for the Actor.
var gravity_modifier := 0.00

## All valid animations that this Actor has.
var animation_rules: Array[AnimationRule]

func _physics_process(_delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY + gravity_modifier
	elif velocity.y > 0:
		velocity.y = 0

	if point_of_interest != Vector2.ZERO:
		_move_towards_point_of_interest()
	else:
		var deceleration = abs(acceleration) * 2
		if velocity.x > 0:
			velocity.x = max(velocity.x - deceleration, 0)
		elif velocity.x < 0:
			velocity.x = min(velocity.x + deceleration, 0)

	velocity.x = clampf(velocity.x, -top_speed * DUMMY_UNIT, top_speed * DUMMY_UNIT)
	animate()
	move_and_slide()


func _move_towards_point_of_interest() -> void:
	# First, check if we are near the POI.
	if position.distance_to(point_of_interest) <= POI_LENIENCY:
		# We're close to the POI and can stop moving towards it.
		point_of_interest = Vector2.ZERO
		return
	# Otherwise move towards the POI.
	velocity.x += (
		acceleration * DUMMY_UNIT
		if point_of_interest.x > position.x
		else -acceleration * DUMMY_UNIT
	)


func random_movement() -> void:
	if point_of_interest != Vector2.ZERO:
		return
	if not randi_range(0, 30) == 30:
		return
	if not is_on_floor():
		return
	point_of_interest = Vector2(position.x + randi_range(-75, 75) + POI_LENIENCY, position.y)
	if point_of_interest.x < 0 or point_of_interest.x > 720:
		point_of_interest = Vector2.ZERO


func animate() -> void:
	var best_rule: AnimationRule = null
	var best_priority := -INF
	
	for rule: AnimationRule in animation_rules:
		if rule.matches(self) and rule.priority > best_priority:
			best_rule = rule
			best_priority = rule.priority
	
	if best_rule and sprite.animation != best_rule.animation_name:
		sprite.play(best_rule.animation_name)


# todo: implement jump
func jump() -> void:
	pass
