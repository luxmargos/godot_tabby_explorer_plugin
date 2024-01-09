@tool

extends RefCounted

var _all_items:Dictionary
var _matched_items:Dictionary
var _filter_text:String
var _has_filter_text:bool

func get_all_items()->Dictionary:
	return _all_items

func get_matched_items()->Dictionary:
	return _matched_items

func set_filter_text(p_text:String):
	_filter_text = p_text.to_lower()
	_has_filter_text = !p_text.is_empty()

func get_filter_text()->String:
	return _filter_text

func has_filter_text()->bool:
	return _has_filter_text
