@tool

extends RefCounted

const DFSIModeHelper = preload("./dfsi_mode_helper.gd")

var _ei:EditorInterface
var dfsi_mode_helper:DFSIModeHelper

func _init(p_ei:EditorInterface):
	_ei = p_ei
	dfsi_mode_helper = DFSIModeHelper.new()

func get_editor_interface()->EditorInterface:
	return _ei
	
func get_editor_settings()->EditorSettings:
	return get_editor_interface().get_editor_settings()

func get_file_system_dock()->FileSystemDock:
	return get_editor_interface().get_file_system_dock()
	
func get_editor_file_system()->EditorFileSystem:
	return get_editor_interface().get_resource_filesystem()
	
func get_resource_previewer()->EditorResourcePreview:
	return get_editor_interface().get_resource_previewer()
	
func scan(p_tag:String):
	get_editor_file_system().scan()
	
func check_dfsi_mode_availability():
	dfsi_mode_helper.check_availability(get_file_system_dock())

