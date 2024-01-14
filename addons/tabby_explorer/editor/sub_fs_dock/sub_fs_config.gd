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
const SubFSThemeHelper := preload("../utils/theme_helper.gd")

var _cancel_btn:Button
var _apply_options:Button

var _repository_btn:Button
var _donate_btn:Button

var _dock_for_favorites_checkbox:CheckBox
var _favorites_dock_name:LineEdit
var _suport_context_menu_chk:CheckBox

var _use_user_config:CheckBox
var _user_config_prefix:LineEdit
var _use_project_shared_config:CheckBox
var _project_shared_config_prefix:LineEdit

var _activate_dfsi_mode:CheckBox

var _fs_share:SubFSShare
var _global_pref:SubFSPref
var _user_docks_pref:SubFSMainPref
var _project_shared_docks_pref:SubFSMainPref

var _user_docks_config:SubFSDocksConfig
var _project_docks_config:SubFSDocksConfig

signal cancelled
signal settings_updated

func _ready():
	find_child("config_scroll_container").add_theme_stylebox_override("panel", get_theme_stylebox("panel", "Tree"))

	var bottom_toolbar = find_child("bottom_toolbar")
	_cancel_btn = bottom_toolbar.find_child("cancel_btn")
	_cancel_btn.icon = get_theme_icon("Close", "EditorIcons")
	_cancel_btn.pressed.connect(_on_cancel_btn_pressed)
	
	_apply_options = bottom_toolbar.find_child("apply_options_btn")
	_apply_options.icon = get_theme_icon("Save", "EditorIcons")
	_apply_options.pressed.connect(_save_settings)
	SubFSThemeHelper.set_theme_flat_stylebox_color(_apply_options, &"normal", Color(0,0.38,0.88,1))
	SubFSThemeHelper.set_theme_flat_stylebox_color(_apply_options, &"hover", Color(0.47,0.6,1.0,1))
	
	var heading_cont:Control = get_node("config_inner/VBoxContainer/config_scroll_container/scroll_inner/heading_controls")
	_donate_btn = heading_cont.get_node("donate_btn")
	_donate_btn.pressed.connect(_on_donate_btn_pressed)

	_repository_btn = heading_cont.get_node("repo_btn")
	_repository_btn.pressed.connect(_on_repository_btn_pressed)
	
	var inner_cont:Control = get_node("config_inner/VBoxContainer/config_scroll_container/scroll_inner")
	var config_opts:Control = inner_cont.find_child("options_container")
	
	_dock_for_favorites_checkbox = config_opts.find_child("dock_for_favorites_checkbox")
	_favorites_dock_name = config_opts.find_child("favorites_dock_name")
	_suport_context_menu_chk = config_opts.find_child("support_context_menu_checkbox")
	
	_use_user_config = get_node("config_inner/VBoxContainer/config_scroll_container/scroll_inner/use_user_config_checkbox")
	_user_config_prefix = get_node("config_inner/VBoxContainer/config_scroll_container/scroll_inner/user_prefix/user_docks_prefix")
	
	_use_project_shared_config = get_node("config_inner/VBoxContainer/config_scroll_container/scroll_inner/use_project_shared_config_checkbox")
	_project_shared_config_prefix = get_node("config_inner/VBoxContainer/config_scroll_container/scroll_inner/project_prefix/project_shared_docks_prefix")
	
	_user_docks_config = find_child("user_docks_config")
	_project_docks_config = find_child("project_docks_config")
	
	_user_docks_config.set_main_pref(_user_docks_pref)
	_project_docks_config.set_main_pref(_project_shared_docks_pref)

func set_initial_items(p_fs_share:SubFSShare, p_global_pref:SubFSPref, p_user_pref:SubFSMainPref, p_project_pref:SubFSMainPref):
	_fs_share = p_fs_share
	_global_pref = p_global_pref
	_user_docks_pref = p_user_pref
	_project_shared_docks_pref = p_project_pref

func _on_donate_btn_pressed():
	OS.shell_open("https://github.com/luxmargos/godot_tabby_explorer_plugin")

func _on_repository_btn_pressed():
	OS.shell_open("https://github.com/luxmargos/godot_tabby_explorer_plugin")
	
func _on_cancel_btn_pressed():
	hide_config()
	cancelled.emit()

func show_config():
	_dock_for_favorites_checkbox.button_pressed = _global_pref.use_favorite_dock
	_favorites_dock_name.text = _global_pref.favorite_dock_name
	_suport_context_menu_chk.button_pressed = _global_pref.use_dfsi_mode
	_use_user_config.button_pressed = _global_pref.use_user_config
	_user_config_prefix.text = _global_pref.user_config_prefix
	_use_project_shared_config.button_pressed = _global_pref.use_project_shared_config
	_project_shared_config_prefix.text = _global_pref.project_shared_config_prefix

	_user_docks_config.show_config()
	_project_docks_config.show_config()

func _save_settings():
	_fs_share.dfsi_mode_helper.restore_popup_menus()
	_global_pref.use_favorite_dock = _dock_for_favorites_checkbox.button_pressed
	_global_pref.favorite_dock_name = _favorites_dock_name.text
	if _global_pref.favorite_dock_name.strip_edges().is_empty():
		_global_pref.favorite_dock_name = SubFSPref.DEFAULT_FAVORITES_DOCK_NAME

	_global_pref.use_dfsi_mode = _suport_context_menu_chk.button_pressed
	_global_pref.use_user_config = _use_user_config.button_pressed
	_global_pref.user_config_prefix = _user_config_prefix.text
	_global_pref.use_project_shared_config = _use_project_shared_config.button_pressed
	_global_pref.project_shared_config_prefix = _project_shared_config_prefix.text
	
	_global_pref.fix_error()
	
	_user_docks_config.apply_docks_config()
	_project_docks_config.apply_docks_config()
	
	hide_config()
	#global_pref_updated.emit()
	settings_updated.emit()

func hide_config():
	_user_docks_config.hide_config()
	_project_docks_config.hide_config()
