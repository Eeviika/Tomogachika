class_name TimeHelper
extends RefCounted


static func _is_valid_time_dict(time: Dictionary[String, int]) -> bool:
	if not ("hour" in time and "minute" in time and "second" in time):
		return false

	var hour: int = time.get("hour", -1)
	var minute: int = time.get("minute", -1)
	var second: int = time.get("second", -1)

	if hour < 0 or hour > 23:
		return false
	if minute < 0 or minute > 59:
		return false
	if second < 0 or second > 59:
		return false

	return true


static func is_past_time(
	current_time: Dictionary[String, int], target_time: Dictionary[String, int]
) -> bool:
	if not (_is_valid_time_dict(current_time) and _is_valid_time_dict(target_time)):
		return false

	if current_time.hour != target_time.hour:
		return current_time.hour > target_time.hour
	if current_time.minute != target_time.minute:
		return current_time.minute > target_time.minute
	return current_time.second > target_time.second


static func is_before_time(
	current_time: Dictionary[String, int], target_time: Dictionary[String, int]
) -> bool:
	if not (_is_valid_time_dict(current_time) and _is_valid_time_dict(target_time)):
		return false

	if current_time == target_time:
		return false

	return not is_past_time(current_time, target_time)
