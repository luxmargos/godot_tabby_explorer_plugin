@tool

extends HBoxContainer

const SubFSDockPref := preload("../dock_pref.gd")
const SubFSDockPosIndicator := preload("./sub_fs_dock_pos_indicator.gd")

var _pref:SubFSDockPref

var _idx_label:Label
var _remove_btn:Button
var _name_edit:LineEdit
var _dock_pos_opts:OptionButton
var _dock_pos_indicator:SubFSDockPosIndicator

var _new_name:String
var _new_dock_pos:int
var _remove_required:bool = false

class DockPos:
	var _value:int
	var _text:String
	
	func _init(p_value:int, p_text:String):
		_value = p_value
		_text = p_text
		
	func get_value()->int:
		return _value
	
	func get_text()->String:
		return _text
 
var all_dock_pos:Array[DockPos]

func _ready():
	_idx_label = get_node("index_label")
	_remove_btn = get_node("remove_btn")
	_name_edit = get_node("body/name_cont/name_edit")
	_dock_pos_opts = get_node("body/dock_pos_cont/dock_pos_opts")
	_dock_pos_indicator = get_node("body/dock_pos_cont/dock_pos_indicator")

	_name_edit.text_changed.connect(_on_text_changed)
	_remove_btn.pressed.connect(_on_remove_btn_pressed)
	_remove_btn.icon = get_theme_icon("Remove", "EditorIcons")
	_remove_btn.text = ""

	all_dock_pos.append(DockPos.new(EditorPlugin.DOCK_SLOT_LEFT_UL, "Left, Upper-Left"))
	all_dock_pos.append(DockPos.new(EditorPlugin.DOCK_SLOT_LEFT_BL, "Left, Bottom-Left"))
	all_dock_pos.append(DockPos.new(EditorPlugin.DOCK_SLOT_LEFT_UR, "Left, Upper-Right"))
	all_dock_pos.append(DockPos.new(EditorPlugin.DOCK_SLOT_LEFT_BR, "Left, Bottom-Right"))

	all_dock_pos.append(DockPos.new(EditorPlugin.DOCK_SLOT_RIGHT_UL, "Right, Upper-Left"))
	all_dock_pos.append(DockPos.new(EditorPlugin.DOCK_SLOT_RIGHT_BL, "Right, Bottom-Left"))
	all_dock_pos.append(DockPos.new(EditorPlugin.DOCK_SLOT_RIGHT_UR, "Right, Upper-Right"))
	all_dock_pos.append(DockPos.new(EditorPlugin.DOCK_SLOT_RIGHT_BR, "Right, Bottom-Right"))

	_dock_pos_opts.clear()
	for pos in all_dock_pos:
		_dock_pos_opts.add_item(pos.get_text(), pos.get_value())

	_dock_pos_opts.item_selected.connect(_on_dock_pos_opts_selected)
	_dock_pos_indicator.selected.connect(_on_dock_pos_indicator_selected)

func _get_dock_pos_index(p_value:int):
	var dock_pos_idx:int = -1
	for i in range(all_dock_pos.size()):
		if all_dock_pos[i].get_value() == p_value:
			dock_pos_idx = i
			break
	return dock_pos_idx
	
func _on_dock_pos_indicator_selected(p_value:int):
	_dock_pos_opts.item_selected.disconnect(_on_dock_pos_opts_selected)
	
	var dock_pos_idx:int = _get_dock_pos_index(p_value)
	_dock_pos_opts.select(dock_pos_idx)
	_new_dock_pos = p_value

	_dock_pos_opts.item_selected.connect(_on_dock_pos_opts_selected)

func _on_dock_pos_opts_selected(p_idx:int):
	var dock_pos:DockPos = all_dock_pos[p_idx]
	_new_dock_pos = dock_pos.get_value()
	_dock_pos_indicator.select(_new_dock_pos, false)

func _on_text_changed(p_text:String):
	_new_name = p_text

func _on_remove_btn_pressed():
	_remove_required = !_remove_required
	_remove_btn.set_pressed_no_signal(_remove_required)

func set_pref(p_pref:SubFSDockPref):
	_pref = p_pref

	_new_name = _pref.name
	_name_edit.text = _new_name

	_new_dock_pos = _pref.dock_pos
	var dock_pos_idx:int = _get_dock_pos_index(_new_dock_pos)
	_dock_pos_opts.select(dock_pos_idx)
	_dock_pos_indicator.select(_new_dock_pos, false)

func get_pref()->SubFSDockPref:
	return _pref

func get_new_dock_name()->String:
	return _new_name

func is_remove_required()->bool:
	return _remove_required

func get_new_dock_pos()->int:
	if _new_dock_pos < 0:
		return EditorPlugin.DOCK_SLOT_LEFT_BR

	if _new_dock_pos >= EditorPlugin.DOCK_SLOT_MAX:
		return EditorPlugin.DOCK_SLOT_LEFT_BR

	return _new_dock_pos
