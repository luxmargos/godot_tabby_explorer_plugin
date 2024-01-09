extends RefCounted

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
