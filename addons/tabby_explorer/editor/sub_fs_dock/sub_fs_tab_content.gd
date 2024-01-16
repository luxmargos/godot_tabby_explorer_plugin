@tool

extends MarginContainer

const SubFSTreeItemWrapper := preload("./item/tree_item_wrapper.gd")
const SubFSItem := preload("../fs/fs_item.gd")

const SubFSShare := preload("../share.gd")
const DFSIModeHelper = preload("../dfsi_mode_helper.gd")
const SubFSManagerNode := preload("../fs/fs_manager_node.gd")

const SubFSThemeHelper := preload("../utils/theme_helper.gd")
const SubFSTextHelper := preload("../utils/text_helper.gd")
const SubFSFileOpener := preload("../utils/file_opener.gd")

const DragPreviewItem := preload("./preview_item.gd")
const DragPreviewItemPackedScene := preload("./preview_item.tscn")

const SubFSTabContentPref := preload("../dock_tab_pref.gd")
const SubFSMainPref := preload("../main_pref.gd")
const SubFSPref := preload("../pref.gd")

const SubFSContext := preload("./item/context.gd")

const SEP = &"/"

var _root_wrapper:SubFSTreeItemWrapper

var _fs_share:SubFSShare
var _fs_manager:SubFSManagerNode
var _global_pref:SubFSPref
var _tab_pref:SubFSTabContentPref
var _main_pref:SubFSMainPref
var _selected_path:String

var _main_cont:Control
var _popup_menu_keeper:Control

var _toolbar:Control

# TODO : implement history
var _history_cont:Control
var _history_prev_btn:Button
var _history_next_btn:Button

var _sel_item_info:Control

var _sel_item_path_body:Control
var _sel_item_path_edit:LineEdit
var _sel_item_path_copy_btn:Button

var _more_info_cont:Control
var _sel_item_uid_body:Control
var _sel_item_uid_edit:LineEdit
var _sel_item_uid_copy_btn:Button

var _sel_item_name_body:Control
var _sel_item_name_edit:LineEdit
var _sel_item_name_copy_btn:Button

var _reload_btn:Button
var _pin_btn:Button
var _post_selection_fs_dock_btn:Button
var _sel_item_info_expand_btn:Button

var _filter_edit:LineEdit
var _tree:Tree
var _selected_item:SubFSTreeItemWrapper
var _selected_items:Dictionary

# TODO: Support multi selection mode
var _is_multi_selection_mode:bool = false
var _ignore_item_selected_signal:bool = false

var _recreation_trigger:float = 0.0

var _saved_uncollapsed_paths:PackedStringArray
var _is_filter_mode:bool = false
var _was_filter_mode:bool = false

# Default FileSystem
var dfs_handle_popup_id_press:bool = false

signal pref_updated
signal saved_tab_selections_updated

func _ready():
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

	_main_cont = get_node("main")
	_popup_menu_keeper = get_node("popup_menu_keeper")
	
	_toolbar = _main_cont.get_node("toolbar")
	_history_cont = _main_cont.get_node("toolbar/history")
	_history_prev_btn = _main_cont.get_node("toolbar/history/prev_btn")
	_history_next_btn = _main_cont.get_node("toolbar/history/next_btn")
	
	_sel_item_info = _main_cont.get_node("toolbar/item_info")
	
	var copy_icon := get_theme_icon("ActionCopy","EditorIcons")
	_sel_item_path_body = _main_cont.get_node("toolbar/item_info/path_body")
	_sel_item_path_edit = _main_cont.get_node("toolbar/item_info/path_body/res_path_edit")
	_sel_item_path_copy_btn = _main_cont.get_node("toolbar/item_info/path_body/copy_res_path_btn")
#	_sel_item_path_copy_btn.icon = get_theme_icon("Duplicate","EditorIcons")
	_sel_item_path_copy_btn.icon = copy_icon
	_sel_item_path_copy_btn.text = ""
	
	_pin_btn = _main_cont.get_node("toolbar/item_info/path_body/pin_btn")
	_pin_btn.icon = get_theme_icon("Pin", "EditorIcons")
	_pin_btn.text = ""
	_pin_btn.custom_minimum_size = Vector2(_pin_btn.custom_minimum_size.x, _sel_item_path_edit.size.y) 
	
	_more_info_cont = _main_cont.get_node("toolbar/item_info/more_info_cont")
	_sel_item_uid_body = _more_info_cont.get_node("uid_body")
	_sel_item_uid_edit = _sel_item_uid_body.get_node("edit")
	_sel_item_uid_copy_btn = _sel_item_uid_body.get_node("copy_btn")
	_sel_item_uid_copy_btn.icon = copy_icon
	_sel_item_uid_copy_btn.text = ""
	
	_sel_item_name_body = _more_info_cont.get_node("name_body")
	_sel_item_name_edit = _sel_item_name_body.get_node("edit")
	_sel_item_name_copy_btn = _sel_item_name_body.get_node("copy_btn")
	_sel_item_name_copy_btn.icon = copy_icon
	_sel_item_name_copy_btn.text = ""
	
	var tools_cont:Control = _main_cont.get_node("toolbar/item_info/path_body/tools")
	_reload_btn = tools_cont.get_node("reload_btn")
	_reload_btn.icon = get_theme_icon("Reload", "EditorIcons")
	_reload_btn.text = ""
	_reload_btn.custom_minimum_size = Vector2(_reload_btn.custom_minimum_size.x, _sel_item_path_edit.size.y)
	
	_post_selection_fs_dock_btn = tools_cont.get_node("post_selection_fs_dock_btn")
	#_post_selection_fs_dock_btn.icon = get_theme_icon("Search", "EditorIcons")
	_post_selection_fs_dock_btn.icon = get_theme_icon("Signals", "EditorIcons")
	#_post_selection_fs_dock_btn.icon = get_theme_icon("ExternalLink", "EditorIcons")
	_post_selection_fs_dock_btn.text = ""
	_post_selection_fs_dock_btn.custom_minimum_size = _reload_btn.custom_minimum_size
	
	_sel_item_info_expand_btn = tools_cont.get_node("expand_btn")
	#_sel_item_info_expand_btn.icon = get_theme_icon("GuiTreeArrowRight", "EditorIcons")
	#_sel_item_info_expand_btn.icon = get_theme_icon("GuiTreeArrowDown", "EditorIcons")
	_sel_item_info_expand_btn.custom_minimum_size = _reload_btn.custom_minimum_size
	#_sel_item_info_expand_btn.icon = get_theme_icon("Forward", "EditorIcons")
	_sel_item_info_expand_btn.icon = get_theme_icon("Collapse", "EditorIcons")
	_sel_item_info_expand_btn.text = ""

	_filter_edit = _main_cont.get_node("filter_cont/filter_edit")
	_filter_edit.text = ""
	_filter_edit.text_changed.connect(_on_filter_edit_text_changed)
	
	_tree = _main_cont.get_node("tree")
	if _is_multi_selection_mode:
		_tree.select_mode = Tree.SELECT_MULTI
	else:
		_tree.select_mode = Tree.SELECT_SINGLE
	_tree.gui_input.connect(_on_tree_gui_input)
	_tree.item_selected.connect(_on_tree_item_selected)
	_tree.multi_selected.connect(_on_tree_item_multi_selected)
	_tree.button_clicked.connect(_on_tree_button_clicked)
	_tree.item_mouse_selected.connect(_on_item_mouse_selected)
	_tree.item_activated.connect(_on_tree_item_activated)
	_tree.empty_clicked.connect(_on_tree_empty_clicked)
	_tree.set_drag_forwarding(_tree_item_get_drag_data, _tree_item_can_drop_data, _tree_item_drop)
	
	_reload_btn.pressed.connect(_on_reload_btn_pressed)
	_pin_btn.pressed.connect(_on_pin_btn_pressed)
	_post_selection_fs_dock_btn.pressed.connect(_on_post_selection_fs_dock_pressed)
	_sel_item_info_expand_btn.pressed.connect(_on_sel_item_info_expand_btn_pressed)
	
	_history_prev_btn.pressed.connect(_on_history_prev_btn_pressed)
	_history_next_btn.pressed.connect(_on_history_next_btn_pressed)
	
	_sel_item_path_edit.text_submitted.connect(_on_sel_item_path_edit)
	_sel_item_uid_edit.text_submitted.connect(_on_sel_item_uid_edit)
	
	_sel_item_path_copy_btn.pressed.connect(_on_sel_item_path_copy_btn_pressed)
	_sel_item_uid_copy_btn.pressed.connect(_on_sel_item_uid_copy_btn_pressed)
	_sel_item_name_copy_btn.pressed.connect(_on_sel_item_name_copy_btn_pressed)
	
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	set_process(is_visible_in_tree())
	if is_visible_in_tree():
		reset_list("_on_visibility_changed")

func _process(delta):
	if !has_list():
		_recreation_trigger += delta
		if _recreation_trigger >= 0.3:
			_recreation_trigger = 0
			reset_list("_process")

func _exit_tree():
	if _has_dfsi_popup():
		_fs_share.dfsi_mode_helper.restore_popup_menus()

func _on_filter_edit_text_changed(p_text:String):
	_was_filter_mode = _is_filter_mode
	_is_filter_mode = !p_text.is_empty()

	reset_list("_on_filter_edit_text_changed")

func _get_filter_text()->String:
	return _filter_edit.text

func _on_sel_item_path_copy_btn_pressed():
	DisplayServer.clipboard_set(_sel_item_path_edit.text)
	
func _on_sel_item_uid_copy_btn_pressed():
	DisplayServer.clipboard_set(_sel_item_uid_edit.text)
	
func _on_sel_item_name_copy_btn_pressed():
	DisplayServer.clipboard_set(_sel_item_name_edit.text)

func _on_tree_gui_input(p_input:InputEvent):
	return

	var mouse_input:InputEventMouseButton = null
	if p_input is InputEventMouseButton:
		mouse_input = p_input as InputEventMouseButton
	
	if mouse_input == null:
		return
	
	if mouse_input.is_command_or_control_pressed():
		return
	if mouse_input.shift_pressed:
		return
	if !mouse_input.is_pressed():
		return
	
	if mouse_input.button_index == MOUSE_BUTTON_WHEEL_UP:
		return
	if mouse_input.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		return
	if mouse_input.button_index == MOUSE_BUTTON_WHEEL_LEFT:
		return
	if mouse_input.button_index == MOUSE_BUTTON_WHEEL_RIGHT:
		return
	if mouse_input.button_index == MOUSE_BUTTON_RIGHT:
		pass
		
func _on_tree_item_activated():
	if !has_selected_item():
		return
	
	# this means double clicked!
	var sel_item:SubFSTreeItemWrapper = get_selected_item()
	
	if _is_dfs_mode() and !sel_item.is_dir():
		_default_fs_navigate(get_selected_item().get_path())
		if _fs_share.dfsi_mode_helper.is_split_mode:
			var dfs_selection = _fs_share.dfsi_mode_helper.file_list.get_selected_items()
			if !dfs_selection.is_empty():
				_fs_share.dfsi_mode_helper.file_list.item_activated.emit(dfs_selection[0])
				return
		else:
			_fs_share.dfsi_mode_helper.tree.item_activated.emit()
			return

	var tree_item:TreeItem = sel_item.get_tree_item()
	if sel_item.is_dir():
		tree_item.collapsed = !tree_item.collapsed
	else:
		SubFSFileOpener.open_file_item(sel_item, _fs_share)

func _on_item_mouse_selected(p_position: Vector2, mouse_button_index: int):
	if !has_selected_item():
		return
	
	if _tab_pref.always_post_selection_to_fs_dock:
		_default_fs_navigate(get_selected_item().get_path())

	if mouse_button_index != MOUSE_BUTTON_RIGHT:
		return

	_handle_rmb_click(p_position, mouse_button_index)

func _on_tree_button_clicked(p_item:TreeItem, column: int, id: int, mouse_button_index: int):
	pass

func _on_tree_empty_clicked(p_position: Vector2, mouse_button_index: int):
	if mouse_button_index != MOUSE_BUTTON_RIGHT:
		return
		
	_select_item_wrapper(_root_wrapper, false, false, true)
	_handle_rmb_click(p_position, mouse_button_index)

func _on_tree_item_selected():
	if _ignore_item_selected_signal:
		return

	_update_selection(_tree.get_selected(), 0, true, true)
	
func _on_tree_item_multi_selected(p_item:TreeItem, p_column: int, p_selected: bool):
	if _ignore_item_selected_signal:
		return

	_update_selection(p_item, p_column, p_selected, true)

func _update_selection(p_item:TreeItem, p_column: int, p_selected: bool, p_by_click:bool):
	var wrapper:SubFSTreeItemWrapper = p_item.get_metadata(0) as SubFSTreeItemWrapper
	#print("update selection : ", wrapper.get_saved_path())
	
	if p_selected:
		if !_is_multi_selection_mode:
			_selected_items.clear()

		_selected_items[wrapper.get_instance_id()] = wrapper
		_selected_item = wrapper
		
		set_selected_path(_selected_item.get_path(), p_by_click)
		
		if p_by_click and _tab_pref.always_post_selection_to_fs_dock:
			_default_fs_navigate(_selected_item.get_path())
	else:
		_selected_items.erase(wrapper.get_instance_id())
	
	#print("SELECTED ITEMS : ", _selected_items.size(),",", _selected_path)
		
	if _selected_items.is_empty():
		_selected_item = null
		
func _on_reload_btn_pressed():
	_fs_manager.attempt_reload()

func has_selected_item()->bool:
	return get_selected_item() != null

func get_selected_item()->SubFSTreeItemWrapper:
	return _selected_item

func _on_pin_btn_pressed():
	if _selected_item == null:
		return
	
	if _tab_pref.pinned_path.is_empty():
		_tab_pref.pinned_path = get_selected_item().get_path()
	else:
		_tab_pref.pinned_path = ""
	_notify_pref_updated()

	reset_list("_on_pin_btn_pressed")

func _on_post_selection_fs_dock_pressed():
	if has_selected_item():
		_default_fs_navigate(get_selected_item().get_path())

func _default_fs_navigate(p_path:String):
	if FileAccess.file_exists(p_path) or DirAccess.dir_exists_absolute(p_path):
		_fs_share.get_file_system_dock().navigate_to_path(p_path)
	
func _on_sel_item_info_expand_btn_pressed():
	_tab_pref.sel_info_expand = !_tab_pref.sel_info_expand
	_notify_pref_updated()
	_refresh_sel_info_expand()

func _on_history_prev_btn_pressed():
	pass

func _on_history_next_btn_pressed():
	pass

func _on_sel_item_path_edit(p_text:String):
	find_and_select_item(p_text, true, true, false, true)

func _on_sel_item_uid_edit(p_text:String):
	if p_text.is_empty():
		return

	if !has_selected_item():
		return
	
	if !p_text.begins_with("uid://"):
		p_text = "uid://" + p_text

	var item:SubFSTreeItemWrapper = _root_wrapper
	var found_item:SubFSTreeItemWrapper = item.find_item_by_uid_text(p_text)
	
	if found_item != null:
		_select_item_wrapper(found_item, true, false, true)
	else:
		refresh_selected_path()

func post_init(p_value:SubFSShare, p_global_pref:SubFSPref, p_main_pref:SubFSMainPref, p_tab_pref:SubFSTabContentPref, p_fs_manager:SubFSManagerNode):
	_fs_share = p_value
	_global_pref = p_global_pref
	_tab_pref = p_tab_pref
	_main_pref = p_main_pref
	_selected_path = _global_pref.get_saved_selection(_tab_pref.tab_id)
	_fs_manager = p_fs_manager
	_fs_manager.fs_generated.connect(_on_fs_gen)
	
	if _is_dfs_mode():
		#print("Turn on DFSI mode...")
		_register_dfs_events()

	reset_list("post_init")

func _on_fs_gen():
	if !is_visible_in_tree():
		return

	reset_list("_on_fs_gen")

func _clear_list():
	if has_list():
		#in the filter mode, keep uncollapsed paths to restore when it finishes
#		if !_is_filter_mode and !_was_filter_mode:
		if !_was_filter_mode:
			_saved_uncollapsed_paths = get_uncollapsed_paths()

		_clear_selection()
		_tree.clear()
		_root_wrapper = null

func _on_item_invalid(p_item:SubFSTreeItemWrapper):
	_clear_list()

func has_list()->bool:
	return _root_wrapper != null

func reset_list(p_tag:String):
	#print(get_instance_id(), ", reset_list_attemptd : ", p_tag)
	_clear_list()
	refresh_selected_path()
	refresh_pin_btn()
	_refresh_sel_info_expand()

	if _fs_manager == null:
		return

	var root_fs_item := _fs_manager.get_root_item()
	if root_fs_item == null:
		return
		
	#print(get_instance_id(), ", start reset_list : ", p_tag)

	_root_wrapper = null
	var tab_root_item:SubFSItem = null
	if !_tab_pref.pinned_path.is_empty() and _tab_pref.pinned_path.is_absolute_path():
		var pinned_path:String = _tab_pref.pinned_path
		tab_root_item = root_fs_item.find_item(pinned_path, false, 0)

		if tab_root_item != null:
			if !tab_root_item.is_dir():
				tab_root_item = tab_root_item.get_parent()

	if tab_root_item == null:
		tab_root_item = root_fs_item
		
	if !tab_root_item.is_valid():
		return

	var context:SubFSContext = SubFSContext.new()
	context.set_filter_text(_get_filter_text())
	var tab_root_tree_item:TreeItem = _tree.create_item()
	_root_wrapper = SubFSTreeItemWrapper.new()
	_root_wrapper.post_init(context, _fs_share, tab_root_item, tab_root_tree_item, self)
	tab_root_tree_item.collapsed = false
	tab_root_tree_item.visible = true

#	_tree.hide_root = _root_wrapper.get_fs_item().is_root_item()
	_root_wrapper.invalid.connect(_on_item_invalid)

	if !_is_filter_mode:
		find_and_select_item(_selected_path, true, true, false, false)
		restore_uncollapsed_paths()
	else:
		find_and_select_item(_selected_path, false, true, false, false)

	refresh_selected_path()
	refresh_pin_btn()
	_refresh_sel_info_expand()
	_tree.queue_redraw()

func _notify_pref_updated():
	pref_updated.emit()
	
func _notify_saved_tab_selections_updated():
	saved_tab_selections_updated.emit()

func find_and_select_item(p_target_path:String, p_find_alt_dir:bool, p_expand:bool, p_reset:bool, p_notify:bool):
	if !has_list():
		return

	if p_target_path.is_empty():
		p_target_path = _root_wrapper.get_path()
		
	#print("find_and_select_item : ", p_target_path, ", expand : ", p_expand, ", reset : ", p_reset)
		
	var found_item:SubFSTreeItemWrapper = _root_wrapper.find_item(p_target_path, p_find_alt_dir, 0)
	if found_item == null and p_find_alt_dir:
		found_item = _root_wrapper

	if found_item != null:
		_select_item_wrapper(found_item, p_expand, p_reset, p_notify)

func _select_item_wrapper(p_item:SubFSTreeItemWrapper, p_expand:bool, p_reset:bool, p_notify:bool):
	#print("_select_item_wrapper : ", p_item.get_saved_path())

	if p_reset and p_item.is_dir():
		p_item.get_fs_item().reset_sub_items()
	
	if p_expand:
		if p_item.is_expandable():
			p_item.get_tree_item().uncollapse_tree()
		elif p_item.get_parent_tree_item() != null:
			p_item.get_parent_tree_item().uncollapse_tree()
				
	if p_notify:
		# to emit tree.multi_selected signal!
		# this method has same effect with clicked my mouse!
		_tree.set_selected(p_item.get_tree_item(), 0)
	else:
		_ignore_item_selected_signal = true
		# without emit tree.multi_selected siangl
		var ti = p_item.get_tree_item()
		ti.select(0)
		_update_selection(ti, 0, true, false)
		_ignore_item_selected_signal = false

	refresh_selected_path()
	if p_notify:
		_tree.scroll_to_item(p_item.get_tree_item())
	_tree.queue_redraw()
	
func _clear_selection():
	_tree.deselect_all()
	_selected_items.clear()
	_selected_item = null

func set_selected_path(p_path:String, p_notify:bool):
	if _tab_pref == null:
		return
	
	#print(_tab_pref.name, ", set_selected_path : ", p_path, ",", p_notify)
	
	_selected_path = p_path
	refresh_selected_path()

	_global_pref.set_saved_selection(_tab_pref.tab_id, p_path)
	if p_notify:
		_notify_saved_tab_selections_updated()

func _on_focus_entered():
	pass
	
func _on_focus_exited():
	pass

func refresh_selected_path():
	if !is_inside_tree() or _tab_pref == null:
		return

	_sel_item_path_edit.text = _selected_path
	var paths := _selected_path.split("/", false)
	if paths.is_empty():
		_sel_item_name_edit.text = ""
	else:
		_sel_item_name_edit.text = paths[paths.size()-1]

	var uid:int = ResourceLoader.get_resource_uid(_selected_path)
	if uid != ResourceUID.INVALID_ID:
		_sel_item_uid_edit.text = ResourceUID.id_to_text(uid) # uid://xxxxx
	else:
		_sel_item_uid_edit.text = ""

func refresh_pin_btn():
	if _tab_pref == null:
		_pin_btn.set_pressed_no_signal(false)
		return
	_pin_btn.set_pressed_no_signal(!_tab_pref.pinned_path.is_empty())
	
func _refresh_sel_info_expand():
	if _tab_pref == null:
		_sel_item_info_expand_btn.set_pressed_no_signal(false)
		_more_info_cont.visible = false
		return

	_sel_item_info_expand_btn.set_pressed_no_signal(_tab_pref.sel_info_expand)
	_more_info_cont.visible = _tab_pref.sel_info_expand

func _get_selected_items()->Dictionary:
	return _selected_items
	
func _get_selected_items_as_array()->Array[SubFSTreeItemWrapper]:
	var result:Array[SubFSTreeItemWrapper]
	result.assign(_selected_items.values())
	return result

func _get_dir_for_selected_item()->SubFSTreeItemWrapper:
	if _selected_item == null:
		return null

	if _selected_item.is_dir():
		return _selected_item

	return _selected_item.get_parent()

func _get_drag_data(at_position):
	# Variant FileSystemDock::get_drag_data_fw(const Point2 &p_point, Control *p_from) {
	# see
	# Variant EditorNode::drag_files_and_dirs(const Vector<String> &p_paths, Control *p_from) {
	
#	p_from->set_drag_preview(vbox); // Wait until it enters scene.
#
#	Dictionary drag_data;
#	drag_data["type"] = has_folder ? "files_and_dirs" : "files";
#	drag_data["files"] = p_paths;
#	drag_data["from"] = p_from;
#	return drag_data;
	
	if _selected_item == null:
		return null

	var drag_type:String = "files"
	if _selected_item.is_dir():
		drag_type = "files_and_dirs"

	var items:Array[SubFSTreeItemWrapper] = _get_selected_items_as_array()
	var file_paths:PackedStringArray = SubFSTreeItemWrapper.as_paths(items)
	
	var drag_data:Dictionary = {
		"type":drag_type,
		"files":file_paths,
		"from":self
	}

	var v_box := VBoxContainer.new()
	for item in items:
		var drag_item_control:DragPreviewItem = DragPreviewItemPackedScene.instantiate()
		drag_item_control.set_item(item)
		v_box.add_child(drag_item_control)

	set_drag_preview(v_box)
	return drag_data

func _notification(what):
	return

	if what == NOTIFICATION_DRAG_BEGIN:
		var dd:Dictionary = get_viewport().gui_get_drag_data()
		if _tree.is_visible_in_tree() and dd.has("type"):
			if String(dd["type"]) == "files" or String(dd["type"]) == "files_and_dirs" or String(dd["type"]) == "resource":
				_tree.drop_mode_flags = Tree.DROP_MODE_ON_ITEM | Tree.DROP_MODE_INBETWEEN
		
	elif what == NOTIFICATION_DRAG_END:
		_tree.drop_mode_flags = Tree.DROP_MODE_DISABLED

func _get_drag_target_folder(p_point:Vector2)->String:
	var ti:TreeItem = _tree.get_item_at_position(p_point)
	var section:int = _tree.get_drop_section_at_position(p_point)
	if ti == null:
		return ""
		
	var wrapper:SubFSTreeItemWrapper = ti.get_metadata(0)
	var fpath:String = wrapper.get_path()
	if section == 0:
		if fpath.ends_with("/"):
			# We drop on a folder.
			return fpath
		else:
			# We drop on the folder that the target file is in.
			return fpath.get_base_dir()
	else:
		if fpath != "res://":
			# We drop between two files
			if fpath.ends_with("/"):
				fpath = fpath.substr(0, fpath.length() - 1)
			return fpath.get_base_dir()
	return ""

func _can_drop_data(at_position: Vector2, drag_data: Variant)->bool:
	## GD Plugin is so limited to move a files.
	## Hold until to expose more Godot APIs
	return false
	
	if !drag_data.has("type"):
		return false
	#bool FileSystemDock::can_drop_data_fw(const Point2 &p_point, const Variant &p_data, Control *p_from) const {
	if String(drag_data["type"]) == "files" or String(drag_data["type"]) == "files_and_dirs":
		# Move files or dir.
		var target_folder:String = _get_drag_target_folder(at_position)
		if target_folder.is_empty():
			return false

		# Attempting to move a folder into itself will fail later,
		# rather than bring up a message don't try to do it in the first place.
		if !target_folder.ends_with("/"):
			target_folder = target_folder + "/"

		var fnames = drag_data["files"]
		for i in range(fnames.size()):
			if fnames[i].ends_with("/") and target_folder.begins_with(fnames[i]):
				return false

		return true
	return false

func _drop_data(at_position:Vector2, drag_data:Variant):
	## GD Plugin is so limited to move a files.
	## Hold until to expose more Godot APIs

	if drag_data.has("type") and (String(drag_data["type"]) == "files" or String(drag_data["type"]) == "files_and_dirs"):
		# Move files
		var to_dir:String = _get_drag_target_folder(at_position)
		if !to_dir.is_empty():
			var fnames = drag_data["files"]
			var target_dir:String
			if to_dir == "res://":
				target_dir = to_dir
			else:
				target_dir = to_dir.trim_suffix("/")

			var to_move:Array
			for i in range(fnames.size()):
				if fnames[i].trim_suffix("/").get_base_dir() != target_dir:
					to_move.push_back({"path":fnames[i], "is_file":!fnames[i].ends_with("/")})

func _tree_item_get_drag_data(at_position: Vector2):
	return _get_drag_data(at_position)

func _tree_item_can_drop_data(at_position: Vector2, data: Variant)->bool:
	return _can_drop_data(at_position, data)

func _tree_item_drop(at_position: Vector2, data: Variant):
	_drop_data(at_position, data)

func _on_script_created(p_script:Script):
	find_and_select_item(p_script.resource_path, true, true, true, true)

func _on_remove_dialog_job_complete():
	reset_list("_on_remove_dialog_job_complete")

func get_uncollapsed_paths()->PackedStringArray:
	var result:PackedStringArray
	var root_item:TreeItem = _tree.get_root()
	if root_item == null:
		return result
		
	var loop_item:Array[TreeItem]
	loop_item.append(root_item)
	
	while !loop_item.is_empty():
		var item:TreeItem = loop_item.pop_back() as TreeItem
		if !item.collapsed and item.get_child_count() > 0:
			result.append((item.get_metadata(0) as SubFSTreeItemWrapper).get_saved_path())
			
		for i in range(item.get_child_count()):
			loop_item.append(item.get_child(i))
	
	return result

func restore_uncollapsed_paths():
	var root_item:TreeItem = _tree.get_root()
	if root_item == null:
		return
		
	var loop_item:Array[TreeItem]
	loop_item.append(root_item)
	
	while !loop_item.is_empty() and !_saved_uncollapsed_paths.is_empty():
		var item:TreeItem = loop_item.pop_back() as TreeItem
		if item.collapsed and item.get_child_count() > 0:
			var wrapper = item.get_metadata(0) as SubFSTreeItemWrapper
			var idx:int = _saved_uncollapsed_paths.find(wrapper.get_saved_path())
			if idx >= 0:
				_saved_uncollapsed_paths.remove_at(idx)
				item.collapsed = false

		for i in range(item.get_child_count()):
			loop_item.append(item.get_child(i))

# FileSystem Tweaks

func _is_dfs_mode()->bool:
	if !_global_pref.use_dfsi_mode:
		return false
	
	_fs_share.check_dfsi_mode_availability()
	return _fs_share.dfsi_mode_helper.is_enabled()
	
func _register_dfs_events():
	if _fs_share.dfsi_mode_helper.file_list_popup:
		#print("file_list_popup : ", _fs_share.dfsi_mode_helper.file_list_popup.name)
		_fs_share.dfsi_mode_helper.file_list_popup.id_pressed.connect(_on_popup_id_pressed)
		_fs_share.dfsi_mode_helper.file_list_popup.visibility_changed.connect(_on_popup_visibility_changed)

	if _fs_share.dfsi_mode_helper.tree_popup:
		#print("tree_popup : ", _fs_share.dfsi_mode_helper.tree_popup.name)
		_fs_share.dfsi_mode_helper.tree_popup.id_pressed.connect(_on_popup_id_pressed)
		_fs_share.dfsi_mode_helper.tree_popup.visibility_changed.connect(_on_popup_visibility_changed)

func _on_popup_id_pressed(p_id:int):
	#print("_on_popup_id_pressed : ", p_id, ",", dfs_handle_popup_id_press)
	if dfs_handle_popup_id_press and has_selected_item():
		dfs_handle_popup_id_press = false
		var item := get_selected_item()
		if item.is_dir():
			# 0 : Expand Folder,
			if p_id == 0:
				item.get_tree_item().collapsed = false
			# 19 : Expand Hierachy
			if p_id == 19:
				item.get_tree_item().set_collapsed_recursive(false)
			# 20 : Collapse Hierachy
			if p_id == 20:
				item.get_tree_item().set_collapsed_recursive(true)

func _has_dfsi_popup():
	if _fs_share == null:
		return false
		
	if !_fs_share.dfsi_mode_helper.is_enabled():
		return false

	if _fs_share.dfsi_mode_helper.tree_popup.get_parent() == _popup_menu_keeper:
		return true

	if _fs_share.dfsi_mode_helper.file_list_popup.get_parent() == _popup_menu_keeper:
		return true
		
	return false
		
func _on_popup_visibility_changed():
	#print("_on_popup_visibility_changed tree_popup : ", tree_popup.visible, ", file_list_popup : ", file_list_popup.visible)
	if _fs_share.dfsi_mode_helper.tree_popup.visible or _fs_share.dfsi_mode_helper.file_list_popup.visible:
		dfs_handle_popup_id_press = false

	var attempt_restore:bool = false
	
	if _has_dfsi_popup() and !_fs_share.dfsi_mode_helper.tree_popup.visible and !_fs_share.dfsi_mode_helper.file_list_popup.visible:
		attempt_restore = true

	if attempt_restore:
		#_on_popup_id_pressed will occurs
		#print("restore dfs_tree_popup parent")
		dfs_handle_popup_id_press = true
		_fs_share.dfsi_mode_helper.restore_popup_menus()

func _handle_rmb_click(p_pos:Vector2, p_mouse_button_index:int):
	if !_is_dfs_mode():
		return
	if !has_selected_item():
		return

	# TODO: Support multi selection mode
	if _is_multi_selection_mode:
		return

	_default_fs_navigate(get_selected_item().get_path())
	
	var selected_item := get_selected_item()
	var dfs_dock := _fs_share.get_file_system_dock()
	var dfs_tree_popup := _fs_share.dfsi_mode_helper.tree_popup
	var dfs_file_list_popup := _fs_share.dfsi_mode_helper.file_list_popup
	
	# default FileSystem is in split mode
	
	if _fs_share.dfsi_mode_helper.is_split_mode and !selected_item.is_dir():
		var dfs_selection = _fs_share.dfsi_mode_helper.file_list.get_selected_items()
		if !dfs_selection.is_empty():
			var cur_pos := _tree.get_screen_position()
			var dfs_pos := _fs_share.dfsi_mode_helper.file_list.get_screen_position()
			var emit_pos := p_pos + (cur_pos - dfs_pos)
		
			dfs_tree_popup.reparent(_popup_menu_keeper, true)
			dfs_file_list_popup.reparent(_popup_menu_keeper, true)
			_fs_share.dfsi_mode_helper.file_list.item_clicked.emit(dfs_selection[0], emit_pos, p_mouse_button_index)
	else:
		var cur_pos := _tree.get_screen_position()
		var dfs_pos := _fs_share.dfsi_mode_helper.tree.get_screen_position()
		var emit_pos := p_pos + (cur_pos - dfs_pos)

		dfs_tree_popup.reparent(_popup_menu_keeper, true)
		dfs_file_list_popup.reparent(_popup_menu_keeper, true)
		_fs_share.dfsi_mode_helper.tree.item_mouse_selected.emit(emit_pos, p_mouse_button_index)
		
		#tree_popup.position = _tree.get_screen_position() + p_pos
		
		#if selected_item.is_dir():
			##FileMenu { FILE_OPEN
			#var indices_to_remove:Array[int]
			#for i in range(tree_popup.item_count):
				#var item_id = tree_popup.get_item_id(i)
				#if item_id == 0 or item_id == 19 or item_id == 20:
					#indices_to_remove.append(i)
					#tree_popup.set_item_disabled(i, true)
					#pass
					##tree_popup.remove_item()
					#
			#indices_to_remove.reverse()
			#
			##for i in indices_to_remove:
				##tree_popup.remove_item(i)
			##tree_popup.reset_size()
	
	
	var FILE_RENAME:int = 9
	var black_list:Array = [FILE_RENAME, "FolderColor"]
	var indices_to_remove:Array[int]
	for i in range(dfs_tree_popup.item_count):
		var submenu := dfs_tree_popup.get_item_submenu(i)
		var item_id := dfs_tree_popup.get_item_id(i)
		if black_list.has(item_id) or black_list.has(submenu):
			indices_to_remove.append(i)
	for i in indices_to_remove:
		dfs_tree_popup.remove_item(i)
	dfs_tree_popup.reset_size()
	indices_to_remove.clear()

	for i in range(dfs_file_list_popup.item_count):
		var submenu := dfs_file_list_popup.get_item_submenu(i)
		var item_id = dfs_file_list_popup.get_item_id(i)
		if black_list.has(item_id) or black_list.has(submenu):
			indices_to_remove.append(i)
	for i in indices_to_remove:
		dfs_file_list_popup.remove_item(i)
	dfs_file_list_popup.reset_size()
	indices_to_remove.clear()
