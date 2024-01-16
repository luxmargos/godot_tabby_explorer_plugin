@tool

extends Resource

const DEFAULT_FAVORITES_DOCK_NAME = "Favorites"
## A globalized preference within SubFSPlugin-scope

@export var use_favorite_dock:bool = true
@export var favorite_dock_refresh_interval:float = 3.0
@export var favorite_dock_name:String = DEFAULT_FAVORITES_DOCK_NAME

# Use default File-System integration
@export var use_dfsi_mode:bool = true

@export var use_user_config:bool = true
@export var user_config_prefix:String = ""

@export var use_project_shared_config:bool = false
@export var project_shared_config_prefix:String = "[P] "
@export var project_shared_pref_dir:String

@export var saved_tab_selections:Dictionary

func get_resolved_project_shared_pref_dir()->String:
	var result = project_shared_pref_dir
	if !result.begins_with("res://"):
		result = "res://" + result
	if !result.ends_with("/"):
		result = result + "/"
	return result

func get_saved_selection(p_tab_id:int)->String:
	return saved_tab_selections.get(p_tab_id, "")

func set_saved_selection(p_tab_id:int, p_value:String):
	saved_tab_selections[p_tab_id] = p_value

func fix_error():
	if !use_user_config and !use_project_shared_config:
		use_user_config = true
