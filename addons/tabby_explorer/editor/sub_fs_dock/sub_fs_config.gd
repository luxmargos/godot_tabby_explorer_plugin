@tool

extends MarginContainer

const SubFSShare := preload("../share.gd")

const SubFSDockPref := preload("../dock_pref.gd")
const SubFSMainPref := preload("../main_pref.gd")
const SubFSPref := preload("../pref.gd")

const ConfigDockItemPackedScene := preload("./sub_fs_config_dock_item.tscn")
const SubFSConfigDockItem := preload("./sub_fs_config_dock_item.gd")
const SubFSTextHelper := preload("../utils/text_helper.gd")

const SubFSDocksConfig := preload("./sub_fs_config_docks.gd")

var _cancel_btn:Button

var _use_user_config:CheckBox
var _user_config_prefix:LineEdit
var _use_project_shared_config:CheckBox
var _project_shared_config_prefix:LineEdit

var _options_header:Button
var _apply_options:Button

var _fs_share:SubFSShare
var _global_pref:SubFSPref
var _user_docks_pref:SubFSMainPref
var _project_shared_docks_pref:SubFSMainPref

var _user_docks_config:SubFSDocksConfig
var _project_docks_config:SubFSDocksConfig

signal cancelled
signal global_pref_updated
signal user_docks_updated
signal project_shared_docks_updated

func _ready():
	find_child("config_scroll_container").add_theme_stylebox_override("panel", get_theme_stylebox("panel", "Tree"))

	_cancel_btn = find_child("cancel_btn")
	_cancel_btn.icon = get_theme_icon("Close", "EditorIcons")
	_cancel_btn.pressed.connect(_on_cancel_btn_pressed)
	
	var config_opts:Control = find_child("options_container")
	_use_user_config = config_opts.find_child("use_user_config_checkbox")
	_user_config_prefix = config_opts.find_child("user_docks_prefix")
	_use_project_shared_config = config_opts.find_child("use_project_shared_config_checkbox")
	_project_shared_config_prefix = config_opts.find_child("project_shared_docks_prefix")
	
	_options_header = config_opts.find_child("option_section")
#	var section_indent_style:StyleBoxFlat = get_theme_stylebox("indent_box", "EditorInspectorSection")
#	_options_header.add_theme_stylebox_override("normal", section_indent_style)
	_apply_options = config_opts.find_child("apply_options_btn")
	_apply_options.pressed.connect(_save_global_config)
	
	_user_docks_config = find_child("user_docks_config")
	_project_docks_config = find_child("project_docks_config")
	
	_user_docks_config.set_main_pref(_user_docks_pref)
	_project_docks_config.set_main_pref(_project_shared_docks_pref)
	
	_user_docks_config.pref_updated.connect(_on_user_docks_pref_updated)
	_project_docks_config.pref_updated.connect(_on_project_docks_pref_updated)

func _on_user_docks_pref_updated():
	user_docks_updated.emit()

func _on_project_docks_pref_updated():
	project_shared_docks_updated.emit()

func set_initial_items(p_fs_share:SubFSShare, p_global_pref:SubFSPref, p_user_pref:SubFSMainPref, p_project_pref:SubFSMainPref):
	_fs_share = p_fs_share
	_global_pref = p_global_pref
	_user_docks_pref = p_user_pref
	_project_shared_docks_pref = p_project_pref

func _on_cancel_btn_pressed():
	hide_config()
	cancelled.emit()

func show_config():
	_use_user_config.button_pressed = _global_pref.use_user_config
	_user_config_prefix.text = _global_pref.user_config_prefix
	_use_project_shared_config.button_pressed = _global_pref.use_project_shared_config
	_project_shared_config_prefix.text = _global_pref.project_shared_config_prefix

	_user_docks_config.show_config()
	_project_docks_config.show_config()

func _save_global_config():
	_global_pref.use_user_config = _use_user_config.button_pressed
	_global_pref.user_config_prefix = _user_config_prefix.text
	_global_pref.use_project_shared_config = _use_project_shared_config.button_pressed
	_global_pref.project_shared_config_prefix = _project_shared_config_prefix.text
	
	_global_pref.fix_error()
	
	hide_config()
	global_pref_updated.emit()

func hide_config():
	_user_docks_config.hide_config()
	_project_docks_config.hide_config()
