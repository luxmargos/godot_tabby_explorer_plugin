@tool

extends RefCounted

const SubFSTreeItemWrapper := preload("./tree_item_wrapper.gd")

var _depth:int = 0
var _item:SubFSTreeItemWrapper

func _init(p_depth:int, p_item:SubFSTreeItemWrapper):
	_depth = p_depth
	_item = p_item

func get_depth()->int:
	return _depth
	
func get_item()->SubFSTreeItemWrapper:
	return _item

func has_item()->bool:
	return _item != null
