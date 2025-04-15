class_name TimeHelper
extends RefCounted


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


static func create_datestamp(date_dict) -> Datestamp:
	assert(_is_valid_time_dict(date_dict), "Cannot create a datestamp from an invalid date_dict.")

	var new_datestamp: Datestamp = Datestamp.new()
	new_datestamp.year = date_dict.get("year", -1)
	new_datestamp.month = date_dict.get("month", -1)
	new_datestamp.day = date_dict.get("day", -1)

	return new_datestamp


static func is_past_time(current_time: Timestamp, target_time: Timestamp) -> bool:
	return (
		(current_time.hour > target_time.hour)
		or (current_time.minute > target_time.minute)
		or (current_time.second > target_time.second)
	)


static func is_before_time(current_time: Timestamp, target_time: Timestamp) -> bool:
	if current_time == target_time:
		return false
	return not is_past_time(current_time, target_time)


static func is_past_date(current_date: Datestamp, target_date: Datestamp) -> bool:
	return (
		(current_date.year > target_date.year)
		or (current_date.month > target_date.month)
		or (current_date.day > target_date.day)
	)


static func is_before_date(current_date: Datestamp, target_date: Datestamp) -> bool:
	if current_date == target_date:
		return false
	return not is_past_date(current_date, target_date)
