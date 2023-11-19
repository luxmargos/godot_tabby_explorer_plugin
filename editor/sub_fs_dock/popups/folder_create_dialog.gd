extends ConfirmationDialog

const SubFSTextHelper := preload("../../utils/text_helper.gd")
const SubFSShare := preload("../../share.gd")

var _dir_label:Label
var _dir_path:LineEdit

var _base_dir:String

var _fs_share:SubFSShare

func _ready():
	var mkdir_vb:VBoxContainer = VBoxContainer.new()
	add_child(mkdir_vb)

	_dir_label = Label.new()
	_dir_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mkdir_vb.add_child(_dir_label)

	_dir_path = LineEdit.new()
	_dir_path.clear_button_enabled = true
	_dir_path.text_changed.connect(_on_text_changed)
	_dir_path.text_submitted.connect(_on_text_submitted)
	mkdir_vb.add_child(_dir_path)

	title = "Create Folder"
	
	visibility_changed.connect(_on_visibility_changed)
	
	wrap_controls = true
	canceled.connect(_on_make_dir_canceled)
	confirmed.connect(_on_make_dir_confirmed)

func _on_text_changed(p_text:String):
	_refresh_dir_label(p_text)
	
func _on_text_submitted(p_text:String):
	_refresh_dir_label(p_text)
	if p_text.is_empty():
		return

	confirmed.emit()
	hide()
 
func _on_visibility_changed():
	if visible:
		_dir_path.grab_focus()

func set_params(p_share:SubFSShare, p_base_dir:String, p_default_name:String):
	_fs_share = p_share
	_base_dir = p_base_dir
	_dir_path.text = p_default_name
	_refresh_dir_label(p_default_name)
	
	var new_min_size = Vector2i(480, 0)
	if _fs_share != null:
		new_min_size = new_min_size * _fs_share.get_editor_interface().get_editor_scale()
	min_size = new_min_size

func _refresh_dir_label(p_text:String):
	_dir_label.text = _base_dir.path_join(p_text)
	
func get_dir_path()->String:
	return _base_dir.path_join(_dir_path.text)

func _on_make_dir_canceled():
	pass

func _on_make_dir_confirmed():
	var dir_path = get_dir_path()
	if dir_path.is_empty() or DirAccess.dir_exists_absolute(dir_path):
		return

	var error := DirAccess.make_dir_recursive_absolute(dir_path)
	if error != OK:
		print(error)

	if _fs_share == null:
		return

	_fs_share.get_editor_file_system().scan()
