@tool

extends MarginContainer

const SubFSShare := preload("../share.gd")

const SubFSDockPref := preload("../dock_pref.gd")
const SubFSTabContentPref := preload("../dock_tab_pref.gd")
const SubFSMainPref := preload("../main_pref.gd")
const SubFSPref := preload("../pref.gd")
const SubFSManagerNode := preload("../fs/fs_manager_node.gd")

const SubFSConfig := preload("./sub_fs_config.gd")
const SubFSConfigPackedScene := preload("./sub_fs_config.tscn")

const TabContentPackedScene := preload("./sub_fs_tab_content.tscn")

const SubFSTabContent := preload("./sub_fs_tab_content.gd")
const TextHelper := preload("../utils/text_helper.gd")

const TabbarPackedScene := preload("./sub_fs_tab_content_tabbar.tscn")
const TabContainerPackedScene := preload("./sub_fs_tab_content_tab_container.tscn")

var _fs_share:SubFSShare
var _global_pref:SubFSPref
var _main_pref:SubFSMainPref
var _dock_prefix:String

var _main_user_pref:SubFSMainPref
var _main_project_shared_pref:SubFSMainPref

var _pref:SubFSDockPref
var _fs_manager_node:SubFSManagerNode

var _config_cont:Control
var _config:SubFSConfig

var _main:Control
var _tabbar_container:Control
var _space_filler_on_hidden_tabbar:Control
var _tab_bar_wrapper:Control
var _tab_bar:TabBar
var _tab_rename_btn:Button
var _new_tab_btn:Button
var _config_btn:Button

var _tab_rename_cont:Control
var _tab_rename_edit:LineEdit
var _tab_rename_done_btn:Button
var _edit_tabs_btn:Button

var _tab_container_wrapper:Control
var _tab_container:TabContainer

var _last_selected_idx:int = -1
var _last_clicked_time:float = 0

var _allow_empty_tabs:bool = false
var _view_as_empty_tabs:bool = false

var _is_config_mode:bool = false
var _ignore_events:bool = false

signal saved_tab_selections_updated
signal settings_updated
signal pref_updated

# Called when the node enters the scene tree for the first time.
func _ready():
	_config_cont = get_node("config_cont")

	_main = get_node("main")
	var main_inner = _main.get_node("inner")
	_tabbar_container = main_inner.get_node("tabbar_container")
	
	_space_filler_on_hidden_tabbar = _tabbar_container.get_node("space_filler_on_hidden_tabbar")
	_tab_bar_wrapper = _tabbar_container.get_node("tab_bar_wrapper")
	#_tab_bar = _tab_bar_wrapper.get_node("tab_bar")
	
	_tab_rename_btn = _tabbar_container.get_node("rename_btn")
	_tab_rename_btn.icon = get_theme_icon("Rename", "EditorIcons")
	_tab_rename_btn.text = ""
	
	_new_tab_btn = _tabbar_container.get_node("new_tab_btn")
	_new_tab_btn.icon = get_theme_icon("Add", "EditorIcons")
	_new_tab_btn.text = ""

	_edit_tabs_btn = _tabbar_container.get_node("edit_tabs_btn")
	_edit_tabs_btn.icon = get_theme_icon("Edit","EditorIcons")
	_edit_tabs_btn.text = ""
	
	_config_btn = _tabbar_container.get_node("config_btn")
	_config_btn.icon = get_theme_icon("Tools", "EditorIcons")
	_config_btn.text = ""
	_config_btn.pressed.connect(show_config)
	
	_tab_rename_cont = main_inner.get_node("tab_rename_cont")
	_tab_rename_edit = _tab_rename_cont.get_node("tab_rename_edit")
	_tab_rename_done_btn = _tab_rename_cont.get_node("tab_rename_done_btn")
	#_tab_rename_done_btn.icon = get_theme_icon("Close", "EditorIcons")
	#_tab_rename_done_btn.icon = get_theme_icon("dismiss", "AssetLib")
	
	_tab_container_wrapper = main_inner.get_node("tab_container_wrapper")
	#_tab_container = _tab_container_wrapper.get_node("tab_container")
	
	visibility_changed.connect(_on_visibility_changed)
	
	if _pref == null:
		return

	generate_tabs()
	
	_tab_rename_btn.pressed.connect(_on_tab_rename_btn_pressed)
	_new_tab_btn.pressed.connect(_on_new_tab_btn_pressed)
	_tab_rename_cont.visible = false
	_tab_rename_edit.text_submitted.connect(_on_tab_rename)
	_tab_rename_done_btn.pressed.connect(_on_tab_rename_done_btn_pressed)
	_edit_tabs_btn.toggled.connect(_on_toggle_edit_tabs_btn)
	
	hide_config()
	
func _on_toggle_edit_tabs_btn(_p_value:bool):
	_refresh_tab_management_tools()
	
func _refresh_tab_management_tools():
	_tab_rename_btn.visible = _edit_tabs_btn.button_pressed
	_new_tab_btn.visible = _edit_tabs_btn.button_pressed
	if _edit_tabs_btn.button_pressed:
		_tab_bar.tab_close_display_policy = TabBar.CLOSE_BUTTON_SHOW_ALWAYS
	else:
		_tab_bar.tab_close_display_policy = TabBar.CLOSE_BUTTON_SHOW_NEVER

#func _on_config_global_pref_updated():
	#global_pref_updated.emit()
	#
#func _on_user_docks_updated():
	#user_docks_updated.emit()
#
#func _on_project_shared_docks_updated():
	#project_shared_docks_updated.emit()
	
func _on_settings_updated():
	settings_updated.emit()
	
func _on_visibility_changed():
	if _pref != null:
		if !visible:
			hide_config()
	
func show_config():
	if _config == null:
		_config = SubFSConfigPackedScene.instantiate()
		#_config.global_pref_updated.connect(_on_config_global_pref_updated)
		#_config.user_docks_updated.connect(_on_user_docks_updated)
		#_config.project_shared_docks_updated.connect(_on_project_shared_docks_updated)
		_config.settings_updated.connect(_on_settings_updated)
		_config.cancelled.connect(hide_config)
		_config.set_initial_items(_fs_share, _global_pref, _main_user_pref, _main_project_shared_pref)
		_config_cont.add_child(_config)

	
	_is_config_mode = true
	_refresh_view_state()
	_config.show_config()
	
func hide_config():
	_is_config_mode = false
	_refresh_view_state()
	if _config != null:
		_config.hide_config()

func _on_tab_rename_done_btn_pressed():
	_on_tab_rename(_tab_rename_edit.text)

func _on_tab_rename(p_new_text:String):
	_tabbar_container.visible = true
	_tab_rename_cont.visible = false
	if p_new_text.is_empty():
		return

	if _last_selected_idx < 0 or _last_selected_idx >= _tab_bar.tab_count:
		print("Tabby Explorer error : No tab to rename")
		return

	_tab_bar.set_tab_title(_last_selected_idx, p_new_text)
	_pref.tabs[_last_selected_idx].name = p_new_text
	pref_updated.emit()

func _on_new_tab_btn_pressed():
	add_new_tab(true)

func _on_tab_selected(p_idx:int):
	var target_idx = p_idx
	if _tab_bar.tab_count < 1:
		target_idx = -1

	if _last_selected_idx != target_idx:
		_last_selected_idx = target_idx
		_last_clicked_time = Time.get_unix_time_from_system()
		return
	
	if _ignore_events:
		return

	var cur_time:float = Time.get_unix_time_from_system()
	var old_click_time:float = _last_clicked_time
	_last_clicked_time = cur_time

	var time_diff:float = cur_time - old_click_time
	if time_diff < 0.3:
		show_tab_rename_tools(p_idx)

func _on_tab_rename_btn_pressed():
	show_tab_rename_tools(_tab_bar.current_tab)

func show_tab_rename_tools(p_idx):
	_tabbar_container.visible = false
	_tab_rename_cont.visible = true
	_tab_rename_edit.text = _pref.tabs[p_idx].name
	_tab_rename_edit.select_all()
	_tab_rename_edit.grab_focus()
	
func _on_active_tab_rearranged(p_to_idx:int):
	if _last_selected_idx < 0:
		return
		
	var target_pref:SubFSTabContentPref = _pref.tabs.pop_at(_last_selected_idx)
	_pref.tabs.insert(p_to_idx, target_pref)
	var target_control:Control = _tab_container.get_tab_control(_last_selected_idx)
	var p = target_control.get_parent()
	p.move_child(target_control, p_to_idx)
	pref_updated.emit()

func _on_tab_changed(p_idx:int):
	_tab_container.current_tab = p_idx

func _on_tab_close_pressed(p_idx:int):	
	if _tab_bar.tab_count <= 1:
		return

	_remove_tab(p_idx, true)
	_on_tab_selected(_tab_bar.current_tab)

func post_init(p_share:SubFSShare, 
	p_global_pref:SubFSPref, p_main_pref:SubFSMainPref, 
	p_dock_prefix:String, p_dock_pref:SubFSDockPref, 
	p_fs_manager_node:SubFSManagerNode,
	p_main_user_pref:SubFSMainPref, 
	p_main_project_shared_pref:SubFSMainPref):
	_fs_share = p_share
	_global_pref = p_global_pref
	_main_pref = p_main_pref
	_pref = p_dock_pref
	_fs_manager_node = p_fs_manager_node
	_main_user_pref = p_main_user_pref
	_main_project_shared_pref = p_main_project_shared_pref
	_dock_prefix = p_dock_prefix
	apply_pref()
	
func apply_pref():
	name = _dock_prefix + _pref.name

func generate_tabs():
	_ignore_events = true
	
	if _tab_bar:
		_tab_bar.queue_free()
		_tab_container.queue_free()
		_tab_bar.tab_selected.disconnect(_on_tab_selected)
		_tab_bar.tab_changed.disconnect(_on_tab_changed)
		_tab_bar.tab_close_pressed.disconnect(_on_tab_close_pressed)
		_tab_bar.active_tab_rearranged.disconnect(_on_active_tab_rearranged)
		_tab_bar = null
		_tab_container = null
	
	_tab_bar = TabbarPackedScene.instantiate()
	_tab_bar_wrapper.add_child(_tab_bar)
	_tab_container = TabContainerPackedScene.instantiate()
	_tab_container_wrapper.add_child(_tab_container)

	var tab_count_to_remove:int = _tab_bar.tab_count
	_view_as_empty_tabs = false

	# Godot's Tabbar don't allow empty tabs!
	if _pref.tabs.is_empty():
		add_new_tab(true)
		if !_allow_empty_tabs:
			_view_as_empty_tabs = false
		else:
			_view_as_empty_tabs = true

		for i in range(tab_count_to_remove):
			_remove_tab(0, false)

		_tab_bar.current_tab = 0
		_tab_container.current_tab = 0
		_on_tab_selected(_tab_bar.current_tab)
		_refresh_view_state()
		_refresh_tab_management_tools()
		_set_tabbar_events()

		_ignore_events = false
		return

	for tab_pref in _pref.tabs:
		_create_tab(tab_pref)

	for i in range(tab_count_to_remove):
		_remove_tab(0, false)
	_tab_bar.current_tab = _pref.selected_tab
	_tab_container.current_tab = _pref.selected_tab
	_on_tab_selected(_tab_bar.current_tab)
	_refresh_view_state()
	_refresh_tab_management_tools()
	_set_tabbar_events()
	
	_ignore_events = false
	
func _set_tabbar_events():
	_tab_bar.tab_selected.connect(_on_tab_selected)
	_tab_bar.tab_changed.connect(_on_tab_changed)
	_tab_bar.tab_close_pressed.connect(_on_tab_close_pressed)
	_tab_bar.active_tab_rearranged.connect(_on_active_tab_rearranged)
	
func _refresh_view_state():
	if _is_config_mode:
		_config_cont.visible = true
		_main.visible = false
	else:
		_config_cont.visible = false
		_main.visible = true
		_space_filler_on_hidden_tabbar.visible = _view_as_empty_tabs
		_tab_bar_wrapper.visible = !_view_as_empty_tabs
		_tab_container_wrapper.visible = !_view_as_empty_tabs

func _create_tab(p_tab_pref:SubFSTabContentPref)->SubFSTabContent:
	var new_tab_index = _tab_bar.tab_count
	
	_tab_bar.add_tab(p_tab_pref.name)
	var tab_content:SubFSTabContent = TabContentPackedScene.instantiate()
	_tab_container.add_child(tab_content)
	tab_content.post_init(_fs_share, _global_pref, _main_pref, p_tab_pref, _fs_manager_node)
	tab_content.pref_updated.connect(_on_tab_content_pref_updated)
	tab_content.saved_tab_selections_updated.connect(_on_saved_tab_selections_updated)
	
	_tab_bar.current_tab = new_tab_index
	_tab_container.current_tab = new_tab_index

	return tab_content
	
func _on_saved_tab_selections_updated():
	saved_tab_selections_updated.emit()

func _remove_tab(p_idx:int, p_apply_pref:bool):
	_tab_bar.remove_tab(p_idx)
	_tab_container.get_tab_control(p_idx).queue_free()
	if p_apply_pref:
		_pref.tabs.remove_at(p_idx)
		pref_updated.emit()
	
func add_new_tab(p_notify:bool):
	var new_tab_name:String = TextHelper.get_tab_name(_tab_bar.tab_count)
	var tab_pref:SubFSTabContentPref  = SubFSTabContentPref.new()
	tab_pref.name = new_tab_name
	_pref.tabs.append(tab_pref)
	if p_notify:
		pref_updated.emit()

	_create_tab(tab_pref)

func _on_tab_content_pref_updated():
	pref_updated.emit()
