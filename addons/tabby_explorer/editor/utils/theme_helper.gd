@tool

extends RefCounted

const SubFSTreeItemWrapper := preload("../sub_fs_dock/item/tree_item_wrapper.gd")
const SubFSItemFile := preload("../fs/fs_file.gd")

static func setup_tree_item_icon(p_ref_control:Control, p_icon:TextureRect, p_item:SubFSTreeItemWrapper):
	p_icon.texture = find_tree_item_icon(p_ref_control, p_item)
	p_icon.self_modulate = find_tree_item_icon_color(p_ref_control, p_item)

static func find_tree_item_icon_color(p_ref_control:Control, p_item:SubFSTreeItemWrapper)->Color:
	if p_item.is_dir():
		return p_ref_control.get_theme_color("folder_icon_color", "FileDialog")

	return Color.WHITE
	
static func find_tree_item_icon(p_ref_control:Control, p_item:SubFSTreeItemWrapper)->Texture2D:
	if p_item.is_dir():
		return p_ref_control.get_theme_icon("Folder", "EditorIcons")

	return find_tree_item_file_icon(p_ref_control, p_item)

static func find_tree_item_file_icon(p_ref_control:Control, p_item:SubFSTreeItemWrapper)->Texture2D:
	var file:SubFSItemFile = p_item.get_fs_item() as SubFSItemFile
	return find_file_icon(p_ref_control, file.get_file_import_is_valid(), file.get_file_type())

static func find_file_icon(p_ref_control:Control, p_is_valid:bool, p_file_type:String)->Texture2D:
	var file_icon:Texture2D
	if !p_is_valid:
		file_icon = p_ref_control.get_theme_icon(&"ImportFail", &"EditorIcons")
	else:
		if p_ref_control.has_theme_icon(p_file_type, &"EditorIcons"):
			file_icon = p_ref_control.get_theme_icon(p_file_type, &"EditorIcons") 
		else:
			file_icon = p_ref_control.get_theme_icon(&"File", &"EditorIcons")

	return file_icon
	
static func set_theme_flat_stylebox_color(p_ref_control:Control, p_key:StringName, p_color:Color)->void:
	if p_ref_control.has_theme_stylebox(p_key):
		var style_box = p_ref_control.get_theme_stylebox(p_key).duplicate()
		if style_box != null and style_box is StyleBoxFlat:
			style_box.bg_color = p_color
			p_ref_control.add_theme_stylebox_override(p_key, style_box)
