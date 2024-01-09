@tool

extends Resource

const SubFSTabContentPref := preload("./dock_tab_pref.gd")

@export var name:String
@export var selected_tab:int
@export var tabs:Array[SubFSTabContentPref]
@export var dock_pos:int = EditorPlugin.DOCK_SLOT_RIGHT_BL
