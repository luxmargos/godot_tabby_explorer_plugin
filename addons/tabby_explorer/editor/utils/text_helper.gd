@tool

extends RefCounted

static func as_unique_name(p_name:String, p_other_refs:Array, p_skip_index:int):
	var append_num:int = 1
	var result:String = p_name.strip_edges()
	
	var found_unique_name:bool = false
	while found_unique_name == false:
		var test_passed:bool = true
		for i in range(p_other_refs.size()):
			if i == p_skip_index:
				continue
			var other_name:String = p_other_refs[i] as String
			if other_name == result:
				test_passed = false
				break

		if test_passed:
			found_unique_name = true
		else:
			append_num += 1
			result = "{0} {1}".format([p_name, append_num])
	
	return result

static func get_tab_name(p_idx:int):
	return "Tab {0}".format([p_idx+1])
