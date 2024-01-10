@tool

extends RefCounted

const SubFSTreeItemWrapper = preload("./tree_item_wrapper.gd")

const SubFSShare := preload("../../share.gd")
const SubFSThemeHelper := preload("../../utils/theme_helper.gd")
const SubFSContext := preload("./context.gd")
const Utils := preload("./utils.gd")
const SubFSSearchResult := preload("./search_result.gd")
const SubFSItem := preload("../../fs/fs_item.gd")
const SubFSItemDir := preload("../../fs/fs_dir.gd")

static func as_paths(p_items:Array[SubFSTreeItemWrapper])->PackedStringArray:
	var paths:PackedStringArray
	for item in p_items:
		paths.append(item.get_path())

	return paths

var _fs_item:SubFSItem
var _tree_item:WeakRef
var _ref_control:Control
var _saved_path:String
var _fs_share:SubFSShare
var _context:SubFSContext
var _is_filter_match:bool = false
signal invalid(p_item:SubFSTreeItemWrapper)

func post_init(p_context:SubFSContext, p_fs_share:SubFSShare, p_fs_item:SubFSItem, p_tree_item:TreeItem, p_ref_control:Control):
	_context = p_context
	_fs_share = p_fs_share
	_ref_control = p_ref_control
	_set_fs_item(p_fs_item)
	_set_tree_item(p_tree_item)

func _set_fs_item(p_fs_item:SubFSItem):
	_fs_item = p_fs_item
	_saved_path = _fs_item.get_path()
	_fs_item.invalid.connect(_on_fs_item_invalid)
	
	if _fs_item.is_dir():
		var dir_item:SubFSItemDir = _fs_item as SubFSItemDir
		dir_item.sub_items_updated.connect(_on_sub_items_updated)

func _on_fs_item_invalid(p_item:SubFSItem):
	invalid.emit(self)

func _on_sub_items_updated(p_item:SubFSItem):
	_reset_sub_tree_items()

func get_fs_item()->SubFSItem:
	return _fs_item
	
func get_id()->String:
	return _saved_path
	
func get_saved_path()->String:
	return _saved_path

func _set_tree_item(p_tree_item:TreeItem):
	_clear_tree_item()

	_tree_item = weakref(p_tree_item)
	if !has_tree_item():
		return
	
	var ti:TreeItem = get_tree_item()

	ti.set_metadata(0, self)
	ti.set_text(0, _fs_item.get_name())
#	ti.disable_folding = !_fs_item.is_expandable()
#	ti.disable_folding = false
	ti.set_structured_text_bidi_override(0, TextServer.STRUCTURED_TEXT_FILE)
	ti.set_icon(0, SubFSThemeHelper.find_tree_item_icon(_ref_control, self)) 
	ti.set_icon_modulate(0, SubFSThemeHelper.find_tree_item_icon_color(_ref_control, self))
	ti.collapsed = true

	if _context.has_filter_text():
		var filter_text:String = _context.get_filter_text()
#		var fpath:String = get_path()
		var filter_compare:String = get_name().to_lower()
		_is_filter_match = filter_compare.contains(filter_text)

	_reset_sub_tree_items()

func is_visible_in_filter()->bool:
	if !has_tree_item():
		return false

	if _is_filter_match:
		return true
		
	var ti:TreeItem = get_tree_item()
	
	for child_ti in ti.get_children():
		var child_wrapper:SubFSTreeItemWrapper = child_ti.get_metadata(0)
		if child_wrapper.is_visible_in_filter():
			return true
	return false

func _fetch_preview():
	if is_dir():
		return

	_fs_share.get_resource_previewer().queue_resource_preview(get_path(), self, "_tree_thumbnail_done", null)
	
func reset_post_state():
	if !has_tree_item():
		return
		
	var ti:TreeItem = get_tree_item()
	if ti.get_parent() == null:
		ti.visible = true
		_fetch_preview()
		return
		
	if !_context.has_filter_text() or ti.get_parent() == null:
		ti.visible = true
		_fetch_preview()
		return

	ti.visible = _is_filter_match
	if _is_filter_match:
		_fetch_preview()

	if ti.get_parent() != null:
		var parent_ti:TreeItem = ti.get_parent()
		var parent_wrapper:SubFSTreeItemWrapper = parent_ti.get_metadata(0)
		parent_wrapper.reset_post_state()

	for child_ti in ti.get_children():
		var child_wrapper:SubFSTreeItemWrapper = child_ti.get_metadata(0)
		if child_wrapper.is_visible_in_filter():
			ti.visible = true
			ti.uncollapse_tree()
			break

func get_tree_item()->TreeItem:
	if _tree_item == null:
		return null
	return _tree_item.get_ref()
	
func has_tree_item()->bool:
	return get_tree_item() != null

func _tree_thumbnail_done(p_path:String, p_preview:Texture2D, p_small_preview:Texture2D, p_udata:Variant):
#	if !p_small_preview.is_valid():
#		return
	
	if p_small_preview == null:
		return

	if !has_tree_item() or is_dir():
		return

	var ti:TreeItem = get_tree_item()
	ti.set_icon(0, p_small_preview)

func _clear_tree_item():
	_clear_sub_tree_items()
	if !has_tree_item():
		return

	var ti := get_tree_item()
	
	if ti.get_parent() != null:
		ti.get_parent().remove_child(ti)
		ti.free()
	_tree_item = null

func _clear_sub_tree_items():
	if !has_tree_item():
		return

	var ti := get_tree_item()
	for child in ti.get_children():
		ti.remove_child(child)
		child.free()

func _reset_sub_tree_items():
	_clear_sub_tree_items()
	
	if !has_tree_item():
		return
	
	var ti := get_tree_item()
	if _fs_item.is_dir():
		var dir_item:SubFSItemDir = _fs_item as SubFSItemDir
		for sub_item in dir_item.get_sub_items():
			var child_wrapper := Utils.new_wrapper()
			var child_tree_item := ti.create_child()
			child_wrapper.post_init(_context, _fs_share, sub_item, child_tree_item, _ref_control)

	reset_post_state()

func is_dir()->bool:
	return _fs_item.is_dir()

func get_tree_item_children()->Array[TreeItem]:
	if !has_tree_item():
		return []
		
	return get_tree_item().get_children()

func get_parent_tree_item()->TreeItem:
	return get_tree_item().get_parent()

func is_expandable()->bool:
	return _fs_item.is_expandable()

func get_path()->String:
	return _fs_item.get_path()
	
func get_os_path()->String:
	return _fs_item.get_os_path()
	
func get_name()->String:
	return _fs_item.get_name()
	
func _inter_find_item(p_target_path:String, p_find_alt_dir:bool, p_search_depth:int)->SubFSSearchResult:
	if !_fs_item.is_starts_with(p_target_path):
		return SubFSSearchResult.new(p_search_depth, null)

	if _fs_item.is_match(p_target_path):
		return SubFSSearchResult.new(p_search_depth, self)

	if !_fs_item.is_dir():
		return SubFSSearchResult.new(p_search_depth, null)
	
	if _fs_item.is_expandable():
		var next_depth:int = p_search_depth + 1
		var deepest_depth:int = next_depth
		
		var sub_item_result:SubFSSearchResult = null
		for sub_item in get_tree_item_children():
			var sub_item_wrapper:SubFSTreeItemWrapper = sub_item.get_metadata(0)
			var result := sub_item_wrapper._inter_find_item(p_target_path, p_find_alt_dir, next_depth)
			deepest_depth = maxi(result.get_depth(), deepest_depth)
			if result.has_item():
				sub_item_result = result
				break

		if sub_item_result != null and sub_item_result.has_item():
			return sub_item_result
		
		if p_find_alt_dir and deepest_depth == next_depth:
			return SubFSSearchResult.new(p_search_depth, self)

	if p_find_alt_dir:
		return SubFSSearchResult.new(p_search_depth, self)

	return SubFSSearchResult.new(p_search_depth, null)

func find_item(p_target_path:String, p_find_alt_dir:bool, p_search_depth:int)->SubFSTreeItemWrapper:
	return _inter_find_item(p_target_path, p_find_alt_dir, p_search_depth).get_item()
	
func find_tree_item(p_target_path:String, p_find_alt_dir:bool, p_search_depth:int)->TreeItem:
	return find_item(p_target_path, p_find_alt_dir, p_search_depth).get_tree_item()

func is_uid_owner(p_uid_text:String)->bool:
	return _fs_item.is_uid_owner(p_uid_text)

func find_item_by_uid_text(p_uid_text:String)->SubFSTreeItemWrapper:
	if is_uid_owner(p_uid_text):
		return self
	
	for sub_tree_item in get_tree_item_children():
		var sub_item_wrapper:SubFSTreeItemWrapper = sub_tree_item.get_metadata(0)
		var sub_item_result:SubFSTreeItemWrapper = sub_item_wrapper.find_item_by_uid_text(p_uid_text)
		if sub_item_result != null:
			return sub_item_result

	return null
