@tool

extends VBoxContainer

const SubFSMainPref := preload("../main_pref.gd")
const SubFSDockPref := preload("../dock_pref.gd")
const SubFSTextHelper := preload("../utils/text_helper.gd")

const SubFSConfigDockItem := preload("./sub_fs_config_dock_item.gd")
const ConfigDockItemPackedScene := preload("./sub_fs_config_dock_item.tscn")

var _docks_header:Button
var _docks_list:Control
var _add_dock_item_btn:Button
var _docks_save_btn:Button

var _main_pref:SubFSMainPref

@export var title:String = "Docks"

signal pref_updated

func _ready():
	_docks_header = find_child("docks_section")
	_docks_list = find_child("docks_list")
	_add_dock_item_btn = find_child("add_dock_btn")
	_add_dock_item_btn.icon = get_theme_icon("Add", "EditorIcons")
	_add_dock_item_btn.pressed.connect(_on_add_dock_btn_pressed)

func _on_add_dock_btn_pressed():
	add_dock_config_item(null)
	
func apply_docks_config():
	var new_docks:Array[SubFSDockPref] = []
	var new_dock_items:Array[Node] = _docks_list.get_children()
	var all_names:Array = _get_all_dock_config_item_names()
	
	for i in range(new_dock_items.size()-1, -1, -1):
		var dock_item:SubFSConfigDockItem = new_dock_items[i] as SubFSConfigDockItem
		if dock_item.is_remove_required():
			continue
		
		var dock_pref:SubFSDockPref = dock_item.get_pref()
		dock_pref.name = SubFSTextHelper.as_unique_name(all_names[i], all_names, i)
		all_names[i] = dock_pref.name
		dock_pref.dock_pos = dock_item.get_new_dock_pos()
		
		new_docks.insert(0, dock_pref)
	_main_pref.docks = new_docks
	_main_pref.fix_empty_docks()

	hide_config()
	pref_updated.emit()

func set_main_pref(p_main_pref:SubFSMainPref):
	_main_pref = p_main_pref

func show_config():
	_docks_header.text = title

	for child in _docks_list.get_children():
		child.queue_free()

	for dock_pref in _main_pref.docks:
		add_dock_config_item(dock_pref)

func add_dock_config_item(p_item:SubFSDockPref):
	var target:SubFSDockPref = p_item
	if target == null:
		target = _main_pref.create_new_dock(false)
		var all_names:Array = _get_all_dock_config_item_names()
		target.name = SubFSTextHelper.as_unique_name(target.name, all_names, -1)
		
	var dock_item:SubFSConfigDockItem = ConfigDockItemPackedScene.instantiate()
	_docks_list.add_child(dock_item)
	dock_item.set_pref(target)

func _get_all_dock_config_item_names()->Array:
	var new_dock_items:Array[Node] = _docks_list.get_children()
	var all_names:Array = []
	for child in new_dock_items:
		var dock_item:SubFSConfigDockItem = child as SubFSConfigDockItem
		all_names.append(dock_item.get_new_dock_name())
	return all_names
	
func hide_config():
	for child in _docks_list.get_children():
		child.queue_free()
