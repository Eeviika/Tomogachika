class_name CommonSaveData
extends SaveableResource

var name := ""
var money := 0
var gender := GlobalEnums.Gender.NONE

var food_inventory : Array[Food]
var experience := 0

var start_date := Datestamp.new()
