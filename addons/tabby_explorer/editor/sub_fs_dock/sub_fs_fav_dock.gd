@tool

extends "./sub_fs_dock.gd"

var _current_favs:PackedStringArray
var _changes_detection_intv:float
var _no_folders_label:Label

func _ready():
	super._ready()
	_edit_tabs_btn.visible = false
	
func _refresh_view_state():
	super._refresh_view_state()
	if _no_folders_label == null:
		_no_folders_label = get_node("no_folders_label")
	_no_folders_label.visible = !_tab_bar_wrapper.visible

func show_config():
	super.show_config()
	_no_folders_label.visible = false
	
	
func apply_pref():
	_allow_empty_tabs = true
	_pref.name = _global_pref.favorite_dock_name
	name = _pref.name

	_fs_share.get_editor_settings().settings_changed.connect(_on_settings_changed)
	reset_favorites()

func _on_settings_changed():
	if reset_favorites():
		generate_tabs()
	
func reset_favorites()->bool:
	if _fs_share == null:
		return false
		
	var editor_fav = _fs_share.get_editor_interface().get_editor_settings().get_favorites().duplicate()
	if hash(_current_favs) == hash(editor_fav):
		return false

	_current_favs = editor_fav
	
	var favs_to_add := _current_favs.duplicate()
	var tabs_size:int = _pref.tabs.size()
	var tab_i:int  = 0
	while tab_i < tabs_size:
		var tab_conf:SubFSTabContentPref = _pref.tabs[tab_i]
		var idx_in_fav:int = favs_to_add.find(tab_conf.fav_path)
		if idx_in_fav < 0:
			_pref.tabs.remove_at(tab_i)
			tabs_size -= 1
			tab_i -= 1
		else:
			favs_to_add.remove_at(idx_in_fav)
		
		tab_i += 1
		

	for fav in favs_to_add:
		if DirAccess.dir_exists_absolute(fav) and fav.ends_with("/"):
			var tab_content:SubFSTabContentPref = SubFSTabContentPref.new()
			tab_content.fav_path = fav
			if fav == "res://":
				tab_content.name = fav
			else:
				tab_content.name = fav.substr(0, fav.length() - 1).get_file()
			tab_content.pinned_path = fav
			_pref.tabs.append(tab_content)

	return true

func _process(p_delta:float):
	if _global_pref == null:
		set_process(false)
		return

	_changes_detection_intv += p_delta
	if _changes_detection_intv >= _global_pref.favorite_dock_refresh_interval:
		_changes_detection_intv = 0.0
		if reset_favorites():
			generate_tabs()


