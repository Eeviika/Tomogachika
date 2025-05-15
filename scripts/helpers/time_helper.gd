class_name TimeHelper
extends RefCounted


static func is_between_time(current_time: Timestamp, start_time: Timestamp, end_time: Timestamp) -> bool:
	return (
		TimeHelper.is_past_time(
			current_time, start_time
		)
		or TimeHelper.is_before_time(
			current_time, end_time
		)
	)

static func _is_valid_time_dict(time_dict) -> bool:
	if not "hour" in time_dict and "minute" in time_dict and "second" in time_dict:
		return false

	var hour: int = time_dict.get("hour", -1)
	var minute: int = time_dict.get("minute", -1)
	var second: int = time_dict.get("second", -1)

	return (
		(hour >= 0 and hour <= 23)
		and (minute >= 0 and minute <= 59)
		and (second >= 0 and second <= 59)
	)


static func _is_valid_date_dict(date_dict) -> bool:
	if not "year" in date_dict and "month" in date_dict and "day" in date_dict:
		return false

	var year: int = date_dict.get("year", -1)
	var month: int = date_dict.get("month", -1)
	var day: int = date_dict.get("day", -1)

	return (
		(year >= 1 and year <= 9999) and (month >= 1 and month <= 12) and (day >= 1 and day <= 31)
	)


static func create_timestamp(time_dict) -> Timestamp:
	assert(_is_valid_time_dict(time_dict), "Cannot create a timestamp from an invalid time_dict.")

	var new_timestamp: Timestamp = Timestamp.new()
	new_timestamp.hour = time_dict.get("hour", -1)
	new_timestamp.minute = time_dict.get("minute", -1)
	new_timestamp.second = time_dict.get("second", -1)

	return new_timestamp

static func current_time_to_timestamp() -> Timestamp:
	var time_dict = Time.get_time_dict_from_system()
	
	var new_timestamp: Timestamp = Timestamp.new()
	new_timestamp.hour = time_dict.get("hour", -1)
	new_timestamp.minute = time_dict.get("minute", -1)
	new_timestamp.second = time_dict.get("second", -1)
	
	return new_timestamp

static func create_datestamp(date_dict) -> Datestamp:
	assert(_is_valid_date_dict(date_dict), "Cannot create a datestamp from an invalid date_dict.")

	var new_datestamp: Datestamp = Datestamp.new()
	new_datestamp.year = date_dict.get("year", -1)
	new_datestamp.month = date_dict.get("month", -1)
	new_datestamp.day = date_dict.get("day", -1)

	return new_datestamp


static func current_date_to_datestamp() -> Datestamp:
	var date_dict = Time.get_date_dict_from_system()
	
	var new_datestamp: Datestamp = Datestamp.new()
	new_datestamp.year = date_dict.get("year", -1)
	new_datestamp.month = date_dict.get("month", -1)
	new_datestamp.day = date_dict.get("day", -1)

	return new_datestamp


static func is_past_time(current_time: Timestamp, target_time: Timestamp) -> bool:
	if current_time.hour > target_time.hour:
		return true
	elif current_time.hour < target_time.hour:
		return false

	if current_time.minute > target_time.minute:
		return true
	elif current_time.minute < target_time.minute:
		return false

	if current_time.second > target_time.second:
		return true
	elif current_time.second < target_time.second:
		return false

	return false


static func is_before_time(current_time: Timestamp, target_time: Timestamp) -> bool:
	if current_time == target_time:
		return false
	return not is_past_time(current_time, target_time)


static func is_past_date(current_time: Datestamp, target_time: Datestamp) -> bool:
	if current_time.year > target_time.year:
		return true
	elif current_time.year < target_time.year:
		return false

	if current_time.month > target_time.month:
		return true
	elif current_time.month < target_time.month:
		return false

	if current_time.day > target_time.day:
		return true
	elif current_time.day < target_time.day:
		return false

	return false


static func is_before_date(current_date: Datestamp, target_date: Datestamp) -> bool:
	if current_date == target_date:
		return false
	return not is_past_date(current_date, target_date)


static func merge_and_convert(_date: Datestamp, _time: Timestamp) -> int:
	var datetime: Dictionary = {
		"year" = _date.year,
		"month" = _date.month,
		"day" = _date.day,
		"hour" = _time.hour,
		"minute" = _time.minute,
		"second" = _time.second
	}
	return Time.get_unix_time_from_datetime_dict(datetime)
