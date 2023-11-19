extends ConfirmationDialog

const SubFSShare := preload("../../share.gd")

var _label:Label
var _targets_scroll:ScrollContainer
var _targets:Label
var _items:PackedStringArray
var _fs_share:SubFSShare

signal job_complete

# Called when the node enters the scene tree for the first time.
func _ready():
	var vb:VBoxContainer = VBoxContainer.new()
	add_child(vb)

	_label = Label.new()
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(_label)

	_targets_scroll = ScrollContainer.new()
	vb.add_child(_targets_scroll)
	_targets_scroll.custom_minimum_size = Vector2(0, 200.0)
	_targets_scroll.add_theme_stylebox_override("panel", get_theme_stylebox("panel", "Tree"))

	_targets = Label.new()
	_targets.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_targets.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_targets.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_targets_scroll.add_child(_targets)
	
	canceled.connect(_on_canceled)
	confirmed.connect(_on_confirmed)

func prepare(p_fs_share:SubFSShare, p_items:PackedStringArray):
	_fs_share = p_fs_share
	_items = p_items

	if _items.is_empty():
		_label.text = ""
	elif _items.size() == 1:
		_label.text = "Are you sure you want to remove selected item from the project? (Cannot be undone)"
	else:
		_label.text = "Are you sure you want to remove selected {0} items from the project? (Cannot be undone)".format([_items.size()])
	
	_targets.text = "\n".join(p_items)

	var new_min_size = Vector2i(480, 0)
	if _fs_share != null:
		new_min_size = new_min_size * _fs_share.get_editor_interface().get_editor_scale()
	min_size = new_min_size

func _on_canceled():
	pass

func _on_confirmed():
#	C++ Reference
#	void DependencyRemoveDialog::ok_pressed() {
#	String path = OS::get_singleton()->get_resource_dir() + files_to_delete[i].replace_first("res://", "/");
#		print_verbose("Moving to trash: " + path);
#		Error err = OS::get_singleton()->move_to_trash(path);
#		if (err != OK) {
#			EditorNode::get_singleton()->add_io_error(TTR("Cannot remove:") + "\n" + files_to_delete[i] + "\n");
#		} else {
#			emit_signal(SNAME("file_removed"), files_to_delete[i]);
#		}

	for item in _items:
		if item.strip_edges().is_empty():
			continue
		if !FileAccess.file_exists(item) and !DirAccess.dir_exists_absolute(item):
			continue

		var os_path:String = ProjectSettings.globalize_path(item)
#		print("remove_path : ", item, "->", os_path)
		var err := OS.move_to_trash(os_path)
		if err != OK:
#			print(os_path, ", Remove failed with error code => ", err)
			pass
		else:
#			print(os_path, ", Removed!")
			pass

	_fs_share.scan("Remove Dialog")
	job_complete.emit()
