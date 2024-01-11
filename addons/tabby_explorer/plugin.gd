@tool

extends EditorPlugin

const SubFsPackedScene: = preload("./editor/sub_fs_dock/sub_fs_dock.tscn")
const SubFSDockPref := preload("./editor/dock_pref.gd")
const SubFSMainPref := preload("./editor/main_pref.gd")
const SubFSPref := preload("./editor/pref.gd")

const SubFSManagerNode := preload("./editor/fs/fs_manager_node.gd")
const SubFSShare := preload("./editor/share.gd")
const SubFSDock := preload("./editor/sub_fs_dock/sub_fs_dock.gd")

var _pref:SubFSPref
var _user_docks_pref:SubFSMainPref
var _project_shared_docks_pref:SubFSMainPref 

const PREF_DIR_NAME:String = ".tabby_explorer_pref"
const PREF_DIR:String = "res://" + PREF_DIR_NAME
const PREF_FILE_NAME:String ="tabby_explorer_pref.tres"
const PREF_FILE:String = PREF_DIR + "/" + PREF_FILE_NAME
const PREF_FILE_IGNORE:String = PREF_DIR + "/" + ".gitignore" 

const MAIN_PREF_FILE_NAME:String = "tabby_explorer_main_pref.tres"

var _all_docks:Array[SubFSDock]
var _fs_manager_node:SubFSManagerNode
var _sub_fs_share:SubFSShare

func _get_pref()->SubFSPref:
	if _pref == null:
		if ResourceLoader.exists(PREF_FILE):
			_pref = ResourceLoader.load(PREF_FILE)
		else:
			if !DirAccess.dir_exists_absolute(PREF_DIR):
				DirAccess.make_dir_recursive_absolute(PREF_DIR)

				if !ResourceLoader.exists(PREF_FILE_IGNORE):
					var git_ignore:FileAccess = FileAccess.open(PREF_FILE_IGNORE, FileAccess.WRITE)
					git_ignore.store_string(PREF_FILE_NAME)
					git_ignore.close()

			_pref = SubFSPref.new()
			_pref.resource_path = PREF_FILE
			ResourceSaver.save(_pref)

	return _pref

func _save_pref():
	ResourceSaver.save(_get_pref())

func _save_user_docks_pref():
	ResourceSaver.save(_get_user_docks_pref())
	
func _save_project_shared_docks_pref():
	ResourceSaver.save(_get_project_shared_docks_pref())

func _get_user_docks_pref_save_dir()->String:
	var ei:EditorInterface = get_editor_interface()
	var ep:EditorPaths = ei.get_editor_paths()
#	print("get_project_settings_dir : ", ep.get_project_settings_dir())
#	print("get_cache_dir : ", ep.get_cache_dir())
#	print("get_config_dir : ", ep.get_config_dir())
#	print("get_data_dir : ", ep.get_data_dir())
	
	return ep.get_project_settings_dir() + "/" + PREF_DIR_NAME
	
func _get_project_shared_docks_pref_save_dir()->String:
	return PREF_DIR

func _get_user_docks_pref()->SubFSMainPref:
	if _user_docks_pref != null:
		return _user_docks_pref
		
	var target_dir:String = _get_user_docks_pref_save_dir()
	if !DirAccess.dir_exists_absolute(target_dir):
		DirAccess.make_dir_recursive_absolute(target_dir)
		
	var target_file:String = target_dir + "/" + MAIN_PREF_FILE_NAME
	_user_docks_pref = _load_main_pref(target_file)
	return _user_docks_pref

func _get_project_shared_docks_pref()->SubFSMainPref:
	if _project_shared_docks_pref != null:
		return _project_shared_docks_pref

	var target_dir:String = _get_project_shared_docks_pref_save_dir()
	if !DirAccess.dir_exists_absolute(target_dir):
		DirAccess.make_dir_recursive_absolute(target_dir)
		
	var target_file:String = target_dir + "/" + MAIN_PREF_FILE_NAME
	_project_shared_docks_pref = _load_main_pref(target_file)
	return _project_shared_docks_pref
		
func _load_main_pref(p_path:String)->SubFSMainPref:
	var result:SubFSMainPref = null
	if ResourceLoader.exists(p_path):
		result = ResourceLoader.load(p_path)
	else:
		result = SubFSMainPref.new()
		result.resource_path = p_path
		ResourceSaver.save(result)
	
	var save:bool = result.fix_empty_docks()
	if save:
		ResourceSaver.save(result)

	return result

func _enter_tree():
	if _sub_fs_share == null:
		_sub_fs_share = SubFSShare.new(get_editor_interface())

	if _fs_manager_node == null:
		_fs_manager_node = SubFSManagerNode.new()
		_fs_manager_node.set_fs_share(_sub_fs_share)
		add_child(_fs_manager_node)

	_generate_all_docks()

func _exit_tree():
	_clear_docks()

func _generate_all_docks():
	_clear_docks()
	
	if _get_pref().use_user_config:
		_generate_docks(_get_user_docks_pref(), _pref.user_config_prefix)

	if _get_pref().use_project_shared_config:
		_generate_docks(_get_project_shared_docks_pref(), _pref.project_shared_config_prefix)

func _generate_docks(p_main_pref:SubFSMainPref, p_prefix:String):
	for dock_pref in p_main_pref.docks:
		var sub_fs_dock:SubFSDock = SubFsPackedScene.instantiate()
		_all_docks.append(sub_fs_dock)
		sub_fs_dock.post_init(_sub_fs_share, _pref, p_main_pref, 
			p_prefix, dock_pref, _fs_manager_node, 
			_get_user_docks_pref(), _get_project_shared_docks_pref())
		sub_fs_dock.pref_updated.connect(_on_dock_pref_updated)
		sub_fs_dock.saved_tab_selections_updated.connect(_on_saved_tab_selections_updated)
		
		sub_fs_dock.settings_updated.connect(_on_settings_updated)
		#sub_fs_dock.global_pref_updated.connect(_on_global_pref_updated)
		#sub_fs_dock.user_docks_updated.connect(_on_global_pref_updated)
		#sub_fs_dock.project_shared_docks_updated.connect(_on_global_pref_updated)

		add_control_to_dock(dock_pref.dock_pos, sub_fs_dock)
		
func _clear_docks():
	for dock in _all_docks:
		remove_control_from_docks(dock)
	_all_docks.clear()
	
func _on_dock_pref_updated():
	_save_user_docks_pref()
	_save_project_shared_docks_pref()

func _on_saved_tab_selections_updated():
	_save_pref()

func _on_settings_updated():
	_save_pref()
	_save_user_docks_pref()
	_save_project_shared_docks_pref()
	_clear_docks()
	_generate_all_docks()
