tool
extends Object



var plugin     : EditorPlugin

var inspector  : Control
var properties : Array



func _enter_tree() -> void:
	inspector = plugin.get_editor_interface().get_inspector().get_child(0)



func _process(_delta : float) -> void:
	parse_all_properties(inspector)



func parse_all_properties(node : Node) -> void:
	if (node is EditorProperty):
		if (node.get_edited_object().script is GDScript):
			var src         : String = node.get_edited_object().script.source_code
			var property    : String = node.get_edited_property()
			var description :        = get_property_description(src, property)
			var help_bit    :        = get_editor_help_bit(node)
			if (help_bit):
				help_bit.set_text(TranslationServer.translate("Property:") + " [b][u]" + property + "[/u][/b]\n" + description)
				help_bit.get_child(0).fit_content_height = true
	for child in node.get_children():
		parse_all_properties(child)

func get_editor_help_bit(node : Node) -> Node:
	if (node.get_class() == "EditorHelpBit"):
		return node
	for child in node.get_children():
		var v := get_editor_help_bit(child)
		if (v): return v
	return null



func get_property_description(src : String, property : String) -> String:
	var description  := PoolStringArray()
	var regex_global := RegEx.new()
	regex_global.compile("((?:(?:^|\n)[ \t]*##(?:.*))+)\nexport *(?:\\(.*\\))?[ \t]*var[ \t]*(?:" + property + ")(?: |\t|\n|=|;)")
	var result_global := regex_global.search(src)
	if (result_global):
		var lines : PoolStringArray = result_global.strings[1].split("\n")
		for line in lines:
			var regex_line := RegEx.new()
			regex_line.compile("(?:^|\n)[ \t]*##(.*)")
			var result_line := regex_line.search(line)
			if (result_line):
				var desc_line : String = result_line.strings[1].strip_edges(false, true).trim_prefix(" ")
				description.append(desc_line)
	return description.join(" ")