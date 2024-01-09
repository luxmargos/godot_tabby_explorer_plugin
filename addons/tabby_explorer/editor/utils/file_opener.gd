@tool

extends RefCounted

const SubFSShare := preload("../share.gd")
const SubFSTreeItemWrapper := preload("../sub_fs_dock/item/tree_item_wrapper.gd")
const SubFSItemFile := preload("../fs/fs_file.gd")

static func open_file_item(p_file_item:SubFSTreeItemWrapper, p_share:SubFSShare):
	var fs_item:SubFSItemFile = p_file_item.get_fs_item() as SubFSItemFile
	var item_path:String = fs_item.get_path()
	var file_type:StringName = fs_item.get_file_type()
	var file_ext:String = fs_item.get_file_ext().to_lower()
	
	var ei:EditorInterface = p_share.get_editor_interface()
	
	# see how godot open the file
	# void FileSystemDock::_select_file(const String &p_path, bool p_select_in_favorites) {
	# String EditorResourcePicker::_get_resource_type(const Ref<Resource> &p_resource) const {
	
	if ResourceLoader.exists(item_path):
		var res:Resource = ResourceLoader.load(item_path)
		if file_type == "GDScript":
			ei.edit_script(res)
#			ei.get_script_editor().grab_click_focus()
#			ei.get_script_editor().grab_focus()
			ei.edit_resource(res)
			#ei.get_script_editor()
		elif file_type == "PackedScene":
			if file_ext == "tscn":
				ei.open_scene_from_path(item_path)
			else:
				# TODO : Handle non-tscn PackedScene
				ei.edit_resource(res)
		else:
			ei.edit_resource(res)
	else:
		if file_type == "TextFile":
			pass
		pass
#		var res = ResourceLoader.load(item_path)
#		if res != null:
#			ei.edit_resource(res)
