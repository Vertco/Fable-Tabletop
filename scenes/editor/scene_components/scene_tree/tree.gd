extends Tree


func _get_drag_data(_at_position: Vector2) -> Variant:
	var items: Array[TreeItem] = []
	var selected_item: TreeItem = get_next_selected(null)
	var preview := VBoxContainer.new()
	while selected_item:
		if get_root() != selected_item.get_parent():
			items.append(selected_item)
		selected_item = get_next_selected(selected_item)
	set_drag_preview(preview)
	return items


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
