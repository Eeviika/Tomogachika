class_name TimeHelper
extends RefCounted


static func _is_valid_time_dict(time_dict) -> bool:
	if not ("hour" in time_dict and "minute" in time_dict and "second" in time_dict):
		return false

	var hour: int = time_dict.get("hour", -1)
	var minute: int = time_dict.get("minute", -1)
	var second: int = time_dict.get("second", -1)

	if hour < 0 or hour > 23:
		return false
	if minute < 0 or minute > 59:
		return false
	if second < 0 or second > 59:
		return false

	return true


static func create_timestamp(time_dict) -> Timestamp:
	assert(_is_valid_time_dict(time_dict), "Cannot create a timestamp from an invalid time_dict.")
	var new_timestamp: Timestamp = Timestamp.new()
	new_timestamp.hour = time_dict.get("hour")
	new_timestamp.minute = time_dict.get("minute")
	new_timestamp.second = time_dict.get("second")

	return new_timestamp


static func is_past_time(current_time: Timestamp, target_time: Timestamp) -> bool:
	if current_time.hour != target_time.hour:
		return current_time.hour > target_time.hour
	if current_time.minute != target_time.minute:
		return current_time.minute > target_time.minute
	return current_time.second > target_time.second


static func is_before_time(current_time: Timestamp, target_time: Timestamp) -> bool:
	if current_time == target_time:
		return false
	return not is_past_time(current_time, target_time)
