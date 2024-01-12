@tool

extends RefCounted

var current_fs:FileSystemDock
var split_cont:SplitContainer
var	tree:Tree
var tree_popup:PopupMenu
var tree_popup_origin_parent:Node
var file_list:ItemList
var file_list_popup:PopupMenu
var file_list_popup_origin_parent:Node
var is_split_mode:bool

func is_enabled()->bool:
	return tree != null and file_list != null and split_cont != null

func clear_refs():
	if tree:
		tree.visibility_changed.disconnect(determine_split_mode)
	if file_list:
		file_list.visibility_changed.disconnect(determine_split_mode)
	if current_fs:
		current_fs.visibility_changed.disconnect(determine_split_mode)

	current_fs = null
	split_cont = null
	tree = null
	tree_popup = null
	tree_popup_origin_parent = null
	file_list = null
	file_list_popup = null
	file_list_popup_origin_parent = null
	is_split_mode = false

func check_availability(p_fs_dock:FileSystemDock):
	if current_fs == null or current_fs != p_fs_dock:
		clear_refs()
		reveal_default_fs_components(p_fs_dock)
		determine_split_mode()
	else:
		determine_split_mode()

func determine_split_mode():
	if current_fs.is_visible_in_tree():
		is_split_mode = tree.is_visible_in_tree() and file_list.is_visible_in_tree()

func reveal_default_fs_components(p_fs_dock:FileSystemDock):
	p_fs_dock.visibility_changed.connect(determine_split_mode)

	current_fs = p_fs_dock
	split_cont = _find_split_cont(p_fs_dock, 0)

	tree = _find_fs_tree(split_cont, 0)
	if tree:
		tree.visibility_changed.connect(determine_split_mode)

	file_list = _find_file_list(split_cont, 0)
	if file_list:
		file_list.visibility_changed.connect(determine_split_mode)

	var children = p_fs_dock.get_children()
	for child in children:
		if child is PopupMenu:
			# godot 4.0 ~ 4.2
			# First PopupMenu is file_list_popup
			# Second PopupMenu is tree_popup
			if file_list_popup == null:
				file_list_popup = child
				file_list_popup_origin_parent = file_list_popup.get_parent()
			else:
				tree_popup = child
				tree_popup_origin_parent = tree_popup.get_parent()
				break

func _find_fs_tree(p_target:Node, p_depth:int)->Tree:
	if p_target is Tree:
		return p_target

	var children = p_target.get_children()
	for child in children:
		var result = _find_fs_tree(child, p_depth+1)
		if result :
			return result
	return null

func restore_popup_menus()->bool:
	if !is_enabled():
		return false

	var result = false
	if tree_popup.get_parent() != tree_popup_origin_parent:
		tree_popup.reparent(tree_popup_origin_parent)
		result = true
	
	if file_list_popup.get_parent() != file_list_popup_origin_parent:
		file_list_popup.reparent(file_list_popup_origin_parent)
		result = true
	
	return result

func _find_split_cont(p_target:Node, p_depth:int)->SplitContainer:
	# godot <= 4.1.3
	if p_target is VSplitContainer:
		return p_target

	# godot 4.2 >=
	if p_target is SplitContainer:
		return p_target

	var children = p_target.get_children()
	for child in children:
		var result = _find_split_cont(child, p_depth+1)
		if result :
			return result
	return null

func _find_file_list(p_target:Node, p_depth:int)->ItemList:
	if p_target is ItemList: # p_target.is_class("FileSystemList"):
		return p_target

	var children = p_target.get_children()
	for child in children:
		var result = _find_file_list(child, p_depth+1)
		if result :
			return result
	return null
