@tool

extends RefCounted

const SubFSItemDir := preload("./fs_dir.gd")

static func new_dir()->SubFSItemDir:
	return SubFSItemDir.new()
