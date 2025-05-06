## Helper class that provides reusable AnimationRules.
class_name PredefinedAnimationRules
extends RefCounted

static func idle_neutral() -> AnimationRule:
	var rule = AnimationRule.new()
	rule.animation_name = "idle_neutral"
	rule.priority = 0
	rule.condition = func(actor):
		return actor.velocity.x == 0 and actor.is_on_floor()
	return rule

static func move_right() -> AnimationRule:
	var rule = AnimationRule.new()
	rule.animation_name = "move_right"
	rule.priority = 1
	rule.condition = func(actor):
		return actor.velocity.x > 0 and actor.is_on_floor()
	return rule

static func move_left() -> AnimationRule:
	var rule = AnimationRule.new()
	rule.animation_name = "move_left"
	rule.priority = 1
	rule.condition = func(actor):
		return actor.velocity.x < 0 and actor.is_on_floor()
	return rule

static func jump_right() -> AnimationRule:
	var rule = AnimationRule.new()
	rule.animation_name = "jump_right"
	rule.priority = 2
	rule.condition = func(actor):
		return actor.velocity.y < 0 and actor.velocity.x > 0 and not actor.is_on_floor()
	return rule

static func jump_left() -> AnimationRule:
	var rule = AnimationRule.new()
	rule.animation_name = "jump_left"
	rule.priority = 2
	rule.condition = func(actor):
		return actor.velocity.y < 0 and actor.velocity.x < 0 and not actor.is_on_floor()
	return rule

static func fall_right() -> AnimationRule:
	var rule = AnimationRule.new()
	rule.animation_name = "fall_right"
	rule.priority = 2
	rule.condition = func(actor):
		return actor.velocity.y > 0 and actor.velocity.x > 0 and not actor.is_on_floor()
	return rule

static func fall_left() -> AnimationRule:
	var rule = AnimationRule.new()
	rule.animation_name = "fall_left"
	rule.priority = 2
	rule.condition = func(actor):
		return actor.velocity.y > 0 and actor.velocity.x < 0 and not actor.is_on_floor()
	return rule

static func get_all() -> Array[AnimationRule]:
	return [
		idle_neutral(),
		move_right(),
		move_left(),
		jump_right(),
		jump_left(),
		fall_right(),
		fall_left()
	]
