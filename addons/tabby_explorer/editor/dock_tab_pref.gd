@tool

extends Resource

@export var tab_id:int = ResourceUID.create_id()
@export var name:String
@export var pinned_path:String
@export var sel_info_expand:bool = false
@export var always_post_selection_to_fs_dock:bool = false

@export var fav_path:String
