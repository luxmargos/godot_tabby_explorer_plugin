@tool

extends "fs_dir.gd"

func get_name()->String:
	if !is_valid():
		return ""

	var fs_name:String = get_efsd().get_name()
	if !fs_name.is_empty():
		return fs_name
	
	return "res://"

func is_root_item()->bool:
	return true
