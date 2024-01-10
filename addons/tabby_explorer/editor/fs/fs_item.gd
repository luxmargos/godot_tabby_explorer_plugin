@tool

extends RefCounted

const SubFSItem = preload("./fs_item.gd")

class SearchResult:
	var _depth:int = 0
	var _item:SubFSItem
	
	func _init(p_depth:int, p_item:SubFSItem):
		_depth = p_depth
		_item = p_item
	
	func get_depth()->int:
		return _depth
		
	func get_item()->SubFSItem:
		return _item
	
	func has_item()->bool:
		return _item != null

## Deprecated by filesystem_changed. Consider remove it
signal invalid(p_item:SubFSItem)
signal _inter_invalid(p_item:SubFSItem)

var _parent:WeakRef = weakref(null)

func is_dir()->bool:
	return false

func is_valid()->bool:
	return false

func is_exists()->bool:
	return false

func validate()->bool:
	if !is_valid():
		if has_parent():
			_inter_invalid.emit(self)
		else:
			invalid.emit(self)
		return false

	return true

func is_expandable()->bool:
	return false

func has_parent()->bool:
	return get_parent() != null

func is_root_item()->bool:
	return false

func get_parent()->SubFSItem:
	return _parent.get_ref()

func set_parent(p_parent:SubFSItem):
	if p_parent != null:
		assert(p_parent.is_dir())
	_parent = weakref(p_parent)

func get_name()->String:
	return ""

func get_path()->String:
	return ""

func get_os_path()->String:
	var p:String = get_path()
	if p.is_empty():
		return ""

	return ProjectSettings.globalize_path(p)

func get_sub_items()->Array[SubFSItem]:
	return []

func is_starts_with(p_target_path:String)->bool:
	if p_target_path.is_empty():
		if is_root_item():
			return true
		return false
		
	var item_path:String = get_path()

	var paths_components:PackedStringArray = p_target_path.split("/", false)
	var item_components:PackedStringArray = item_path.split("/", false)

	if item_components.size() > paths_components.size():
		return false
		
	var is_begins_with:bool = true
	for i in range(paths_components.size()):
		var pc:String = paths_components[i]
		if i >= item_components.size():
			break
		var ic = item_components[i]
		if pc != ic:
			is_begins_with = false
			break

	return is_begins_with
	
func is_match(p_target_path:String)->bool:
	if p_target_path.is_empty():
		if is_root_item():
			return true
		return false

	if !is_starts_with(p_target_path):
		return false

	var item_path:String = get_path()
	if is_dir():
		if p_target_path == item_path or p_target_path + "/" == item_path:
			return true
	else:
		if p_target_path == item_path:
			return true

	return false

func _inter_find_item(p_target_path:String, p_find_alt_dir:bool, p_search_depth:int)->SearchResult:
	if !is_starts_with(p_target_path):
		return SearchResult.new(p_search_depth, null)

	if is_match(p_target_path):
		return SearchResult.new(p_search_depth, self)
		
	if !is_dir():
		return SearchResult.new(p_search_depth, null)

	if is_expandable():
		var next_depth:int = p_search_depth + 1
		var deepest_depth:int = next_depth
		
		var sub_item_result:SearchResult = null
		for sub_item in get_sub_items():
			var result := sub_item._inter_find_item(p_target_path, p_find_alt_dir, next_depth)
			deepest_depth = maxi(result.get_depth(), deepest_depth)
			if result.has_item():
				sub_item_result = result
				break

		if sub_item_result != null and sub_item_result.has_item():
			return sub_item_result
	
		if p_find_alt_dir and deepest_depth == next_depth:
			return SearchResult.new(p_search_depth, self)

	if p_find_alt_dir:
		return SearchResult.new(p_search_depth, self)

	return SearchResult.new(p_search_depth, null)

func find_item(p_target_path:String, p_find_alt_dir:bool, p_search_depth:int)->SubFSItem:
	return _inter_find_item(p_target_path, p_find_alt_dir, p_search_depth).get_item()

func reset_sub_items():
	pass

func get_uid()->int:
	return ResourceUID.INVALID_ID

func get_uid_text()->String:
	var uid:int = get_uid()
	if uid != ResourceUID.INVALID_ID:
		return ResourceUID.id_to_text(uid) # uid://xxxxx
	
	return ""
	
func is_uid_owner(p_uid_text:String)->bool:
	return get_uid_text() == p_uid_text

func find_item_by_uid_text(p_uid_text:String)->SubFSItem:
	if is_uid_owner(p_uid_text):
		return self
	
	for sub_item in get_sub_items():
		var sub_item_result:SubFSItem = sub_item.find_item_by_uid_text(p_uid_text)
		if sub_item_result != null:
			return sub_item_result
			
	return null
