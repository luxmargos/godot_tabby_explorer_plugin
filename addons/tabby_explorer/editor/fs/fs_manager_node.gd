@tool

extends Node

const SubFSShare := preload("../share.gd")
const SubFSItemRootDir := preload("./fs_root_dir.gd")
const SubFSItem := preload("./fs_item.gd")

var _recreation_trigger:float = 0.0
var _fs_share:SubFSShare

var _root_item:SubFSItemRootDir

signal fs_generated

func set_fs_share(p_share:SubFSShare):
	_fs_share = p_share
	
	# this is same solution with godot editor.
	# see void FileSystemDock::_fs_changed() {
	# multiple selection will erase
	var fs:EditorFileSystem = _fs_share.get_editor_file_system()
	fs.filesystem_changed.connect(_on_file_system_changed)

func attempt_reload():
	_fs_share.scan("attempt_reload")
	_generate()

func _on_file_system_changed():
	_generate()

func _clear():
	_root_item = null
	_recreation_trigger = 0

func _generate():
	_clear()

	var base_fs:EditorFileSystemDirectory = _fs_share.get_editor_file_system().get_filesystem()
	
	# Godot seems replace the singleton of EditorFileSystem on startup.
	# Cancel list generation until finishing startup.
	if base_fs.get_subdir_count() < 1 and base_fs.get_file_count() < 1:
		var base_path:String = base_fs.get_path()
		if DirAccess.get_files_at(base_path).size() > 0 or DirAccess.get_directories_at(base_path).size() > 0:
			return

	_root_item = SubFSItemRootDir.new()
	_root_item.set_efsd(base_fs)
	_root_item.reset_sub_items()
	_root_item.invalid.connect(_on_root_item_invalid)
	fs_generated.emit()

func _on_root_item_invalid(p_item:SubFSItem):
	_generate()

func _process(delta):
	if _root_item == null:
		_recreation_trigger += delta
		if _recreation_trigger >= 0.5:
			_recreation_trigger = 0
			_generate()

func get_root_item()->SubFSItemRootDir:
	return _root_item

func _ready():
	_generate()
