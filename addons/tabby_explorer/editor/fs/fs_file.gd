@tool

extends "fs_item.gd"

const SubFSItemDir := preload("./fs_dir.gd")

var _file_index:int

func set_file_index(p_value:int):
	_file_index = p_value

func get_name()->String:
	if !is_valid():
		return ""

	return get_parent().get_efsd().get_file(_file_index)

func is_dir()->bool:
	return false

func get_parent_dir()->SubFSItemDir:
	return get_parent() as SubFSItemDir

func get_parent_efsd()->EditorFileSystemDirectory:
	var pd:SubFSItemDir = get_parent_dir()
	if pd == null:
		return null

	return pd.get_efsd()

func get_path()->String:
	if !is_valid():
		return ""

	return get_parent_efsd().get_file_path(_file_index)

func get_file_type()->StringName:
	if !is_valid():
		return ""

	return get_parent_efsd().get_file_type(_file_index)

func is_exists()->bool:
	if !is_valid():
		return false

	return FileAccess.file_exists(get_path())

func get_file_ext()->String:
	return get_path().get_extension()

func get_file_import_is_valid()->bool:
	if !is_valid():
		return false
		
	return get_parent_efsd().get_file_import_is_valid(_file_index)

func is_valid()->bool:
	return get_parent() != null and get_parent().is_valid()

func get_uid()->int:
	return ResourceLoader.get_resource_uid(get_path())

