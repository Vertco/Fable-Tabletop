extends Tree


var suppress_selection := false
var previous_selection: Array[TreeItem] = []


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			suppress_selection = false
			var item := get_item_at_position(event.position)
			if item:
				var button_id := get_button_id_at_position(event.position)
				if button_id != -1:
					suppress_selection = true
					previous_selection.clear()
					var selected := get_next_selected(null)
					while selected:
						previous_selection.append(selected)
						selected = get_next_selected(selected)


func _on_item_selected() -> void:
	_validate_selection()


func _validate_selection() -> void:
	var selected := get_next_selected(null)
	while selected:
		var metadata: Node = selected.get_metadata(0)
		# if item is disabled or not selectable → immediately undo it
		if not selected.is_selectable(0) or (metadata and metadata.get("locked") == true):
			selected.deselect(0)
		selected = get_next_selected(selected)


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	var other_item:TreeItem = get_item_at_position(at_position)
	var other_node
	if other_item:
		other_node = other_item.get_metadata(0)
	if typeof(data) == TYPE_ARRAY && other_item:
		if data.is_typed():
			for item in data:
				if other_node.type in ["ImageAsset"]:
					drop_mode_flags = DropModeFlags.DROP_MODE_INBETWEEN
					return true
				else:
					drop_mode_flags = DropModeFlags.DROP_MODE_INBETWEEN
					return false
			drop_mode_flags = DropModeFlags.DROP_MODE_INBETWEEN
			return false
		else:
			drop_mode_flags = DropModeFlags.DROP_MODE_INBETWEEN
			return false
	else:
		drop_mode_flags = DropModeFlags.DROP_MODE_INBETWEEN
		return false


func _drop_data(at_position: Vector2, data: Variant) -> void:
	var drop_section := get_drop_section_at_position(at_position)
	var other_item := get_item_at_position(at_position)
	var other_node = other_item.get_metadata(0)
	var nodes:Array[Node]
	if other_node:
		if other_node.type in ["ImageAsset"]:
			for item in data:
				nodes.append(item.get_metadata(0))
			for node in nodes:
				node.get_parent().move_child(node,other_node.get_index()*drop_section)
