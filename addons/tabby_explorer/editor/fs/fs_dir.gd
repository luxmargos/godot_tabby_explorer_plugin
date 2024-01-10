@tool

extends "fs_item.gd"

const SubFSItemDir := preload("./fs_dir.gd")
const SubFSItemFile := preload("./fs_file.gd")
const Utils := preload("./utils.gd")

var _efsd:WeakRef
var _dir_index:int
var _sub_items:Array[SubFSItem]

signal sub_items_updated(p_item:SubFSItemDir)

func is_dir()->bool:
	return true

func set_dir_index(p_value:int):
	_dir_index = p_value

func get_name()->String:
	return get_efsd().get_name()

func get_path()->String:
	if get_efsd() == null:
		return ""

	return get_efsd().get_path()

func get_parent_dir()->SubFSItemDir:
	return get_parent() as SubFSItemDir

func set_efsd(p_efsd:EditorFileSystemDirectory):
	_efsd = weakref(p_efsd)
	
func get_efsd()->EditorFileSystemDirectory:
	return _efsd.get_ref()

func is_exists()->bool:
	if !is_valid():
		return false
	return DirAccess.dir_exists_absolute(get_path())

func is_valid()->bool:
	return get_efsd() != null

func is_expandable()->bool:
	if !validate():
		return false

	return get_efsd().get_subdir_count() > 0 or get_efsd().get_file_count() > 0

func _notify_sub_items_updated():
	sub_items_updated.emit(self)

func get_sub_items()->Array[SubFSItem]:
	return _sub_items

func _set_sub_items(p_items:Array[SubFSItem]):
	clear_sub_items()
	_sub_items = p_items
	_notify_sub_items_updated()

func clear_sub_items():
	for item in _sub_items:
		item.set_parent(null)

	_sub_items.clear()
	_notify_sub_items_updated()

func _on_sub_item_invalid():
	if !validate():
		clear_sub_items()
		return

	reset_sub_items()

func reset_sub_items():
	if !validate():
		return

	clear_sub_items()
	var efsd := get_efsd()
	var new_sub_items:Array[SubFSItem] = []
	for i in range(efsd.get_subdir_count()):
		var sub_efsd:EditorFileSystemDirectory = efsd.get_subdir(i)
		
		var sub_item:SubFSItemDir = Utils.new_dir()
		sub_item.set_parent(self)
		sub_item._inter_invalid.connect(_on_sub_item_invalid)
		sub_item.set_efsd(sub_efsd)
		sub_item.set_dir_index(i)
		new_sub_items.append(sub_item)
		sub_item.reset_sub_items()

	for i in range(efsd.get_file_count()):
		var sub_item:SubFSItemFile = SubFSItemFile.new()
		sub_item.set_parent(self)
		sub_item._inter_invalid.connect(_on_sub_item_invalid)
		sub_item.set_file_index(i)
		new_sub_items.append(sub_item)
		
	_set_sub_items(new_sub_items)

func get_child_index(p_child:SubFSItem)->int:
	if _sub_items.is_empty():
		return -1
	return _sub_items.find(p_child)

func find_item_by_uid_text(p_uid_text:String)->SubFSItem:
	return null
