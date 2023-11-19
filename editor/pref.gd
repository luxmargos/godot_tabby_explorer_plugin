@tool

extends Resource

## A globalized preference within SubFSPlugin-scope

@export var use_user_config:bool = true
@export var user_config_prefix:String = ""

@export var use_project_shared_config:bool = false
@export var project_shared_config_prefix:String = "[P] "

@export var saved_tab_selections:Dictionary

func get_saved_selection(p_tab_id:int)->String:
	return saved_tab_selections.get(p_tab_id, "")

func set_saved_selection(p_tab_id:int, p_value:String):
	saved_tab_selections[p_tab_id] = p_value

func fix_error():
	if !use_user_config and !use_project_shared_config:
		use_user_config = true
