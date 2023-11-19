@tool

extends Resource

const SubFSDockPref := preload("./dock_pref.gd")
const SubFSTextHelper := preload("./utils/text_helper.gd")

@export var docks:Array[SubFSDockPref]

func create_new_dock(p_as_unique_name:bool)->SubFSDockPref:
	var dock_pref:SubFSDockPref = SubFSDockPref.new()
	if p_as_unique_name:
		dock_pref.name = get_unique_dock_name("Sub FileSystem")
	else:
		dock_pref.name = "Sub FileSystem"
	return dock_pref

static func get_dock_name(p_dock:SubFSDockPref)->String:
	return p_dock.name

func get_dock_names()->Array:
	return docks.map(get_dock_name)
	
func get_unique_dock_name(p_name:String)->String:
	return SubFSTextHelper.as_unique_name(p_name, get_dock_names(), -1)
