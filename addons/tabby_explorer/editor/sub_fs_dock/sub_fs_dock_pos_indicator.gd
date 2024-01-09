@tool

extends MarginContainer

var _left_ul:CheckBox
var _left_bl:CheckBox
var _left_ur:CheckBox
var _left_br:CheckBox

var _right_ur:CheckBox
var _right_br:CheckBox
var _right_ul:CheckBox
var _right_bl:CheckBox

signal selected(p_value:int)
# Called when the node enters the scene tree for the first time.
func _ready():
	_left_ul = get_node("main/left_ul")
	_left_bl = get_node("main/left_bl")
	_left_ur = get_node("main/left_ur")
	_left_br = get_node("main/left_br")
	
	_right_ur = get_node("main/right_ur")
	_right_br = get_node("main/right_br")
	_right_ul = get_node("main/right_ul")
	_right_bl = get_node("main/right_bl")
	
	_left_ul.toggled.connect(_left_ul_togged)
	_left_bl.toggled.connect(_left_bl_togged)
	_left_ur.toggled.connect(_left_ur_togged)
	_left_br.toggled.connect(_left_br_togged)
	
	_right_ur.toggled.connect(_right_ur_togged)
	_right_br.toggled.connect(_right_br_togged)
	_right_ul.toggled.connect(_right_ul_togged)
	_right_bl.toggled.connect(_right_bl_togged)
	
func _left_ul_togged(p_value:bool):
	if !p_value:
		return
	select(EditorPlugin.DOCK_SLOT_LEFT_UL, true)

func _left_bl_togged(p_value:bool):
	if !p_value:
		return
	select(EditorPlugin.DOCK_SLOT_LEFT_BL, true)

func _left_ur_togged(p_value:bool):
	if !p_value:
		return
	select(EditorPlugin.DOCK_SLOT_LEFT_UR, true)
		
func _left_br_togged(p_value:bool):
	if !p_value:
		return
	select(EditorPlugin.DOCK_SLOT_LEFT_BR, true)
		
func _right_ur_togged(p_value:bool):
	if !p_value:
		return
	select(EditorPlugin.DOCK_SLOT_RIGHT_UR, true)

func _right_br_togged(p_value:bool):
	if !p_value:
		return
	select(EditorPlugin.DOCK_SLOT_RIGHT_BR, true)

func _right_ul_togged(p_value:bool):
	if !p_value:
		return
	select(EditorPlugin.DOCK_SLOT_RIGHT_UL, true)

func _right_bl_togged(p_value:bool):
	if !p_value:
		return
	select(EditorPlugin.DOCK_SLOT_RIGHT_BL, true)

func _get_button(p_value:int)->CheckBox:
	if p_value == EditorPlugin.DOCK_SLOT_LEFT_UL:
		return _left_ul
	if p_value == EditorPlugin.DOCK_SLOT_LEFT_UR:
		return _left_ur
	if p_value == EditorPlugin.DOCK_SLOT_LEFT_BL:
		return _left_bl
	if p_value == EditorPlugin.DOCK_SLOT_LEFT_BR:
		return _left_br
		
	if p_value == EditorPlugin.DOCK_SLOT_RIGHT_UL:
		return _right_ul
	if p_value == EditorPlugin.DOCK_SLOT_RIGHT_UR:
		return _right_ur
	if p_value == EditorPlugin.DOCK_SLOT_RIGHT_BL:
		return _right_bl
	if p_value == EditorPlugin.DOCK_SLOT_RIGHT_BR:
		return _right_br
		
	return null
		
func select(p_value:int, p_notify:bool):
	_clear_all_btn()
	var target_btn:CheckBox = _get_button(p_value)
	if target_btn == null:
		if p_notify:
			selected.emit(-1)
		return
		
	target_btn.set_pressed_no_signal(true)
	
	if p_notify:
		selected.emit(p_value)

func _clear_all_btn():
	_left_ul.set_pressed_no_signal(false)
	_left_bl.set_pressed_no_signal(false)
	_left_ur.set_pressed_no_signal(false)
	_left_br.set_pressed_no_signal(false)
	
	_right_ur.set_pressed_no_signal(false)
	_right_br.set_pressed_no_signal(false)
	_right_ul.set_pressed_no_signal(false)
	_right_bl.set_pressed_no_signal(false)
