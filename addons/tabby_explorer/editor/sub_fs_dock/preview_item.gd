@tool

extends HBoxContainer

const SubFSThemeHelper := preload("../utils/theme_helper.gd")

var _icon:TextureRect
var _label:Label
var _item:SubFSTreeItemWrapper

# Called when the node enters the scene tree for the first time.
func _ready():
	_icon = get_node("TextureRect")
	_label = get_node("Label")
	if _item == null:
		return
		
	SubFSThemeHelper.setup_tree_item_icon(self, _icon, _item)
	_label.text = _item.get_name()

func set_item(p_item:SubFSTreeItemWrapper):
	_item = p_item
