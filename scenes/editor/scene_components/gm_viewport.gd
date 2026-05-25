extends SubViewportContainer


signal selection_changed


@export var max_gm_zoom:float = 0.025
@export var min_gm_zoom:float = 4.0
@export var gm_zoom_incr:float = 0.1
@export var gm_zoom:float = 1.0:
	set(value):
		gm_zoom = value
		App.gm_zoom = value


var cam_pan := false
var asset_drag := false
var was_dragging_asset := false
var was_multi_select := false
var last_single_select_stack: Array[int] = []
var focus := false
var move_action_open := false
var drag_assets: Array[Node] = []
var drag_start_positions := {}
var undo_redo:UndoRedo


func update_scene() -> void:
	undo_redo = %SceneRoot.get_node("./Scene").undo_redo


func _unhandled_input(event: InputEvent) -> void:
	if focus:
		if event.is_action_released("ui_undo"):
			if not move_action_open:
				undo_redo.undo()
		elif event.is_action_released("ui_redo"):
			if not move_action_open:
				undo_redo.redo()
		elif event.is_action_released("asset_delete"):
			undo_redo.create_action("Delete assets")
			var assets: Array[Node] = get_tree().get_nodes_in_group("selected_assets")
			for asset in assets:
				undo_redo.add_undo_reference(asset)
				undo_redo.add_undo_reference(asset.get_parent())
				undo_redo.add_do_method(asset.get_parent().remove_child.bind(asset))
				undo_redo.add_undo_method(asset.get_parent().add_child.bind(asset))
				undo_redo.add_undo_method(asset.get_parent().move_child.bind(asset, asset.get_index()))
			undo_redo.commit_action()
		elif event.is_action_released("ui_cancel"):
			get_tree().call_group("selected_assets","deselect")
	if event.is_action_pressed("cam_pan"):
		cam_pan = true
	elif event.is_action_released("cam_pan"):
		cam_pan = false
	var pos: Vector2 = %GmView.get_canvas_transform().affine_inverse() * %GmView.get_mouse_position()
	if event.is_action_pressed("asset_multi_select"):
		select(true)
		was_multi_select = true
	elif event.is_action_pressed("asset_select"):
		var nodes: Array = %SceneRoot.get_node("Scene").get_assets_at(pos)
		var over_selected := false
		for node in nodes:
			if node.selected:
				over_selected = true
		if over_selected:
			asset_drag = true
			was_dragging_asset = false
			drag_assets = get_tree().get_nodes_in_group("selected_assets")
			drag_start_positions.clear()
			for asset in drag_assets:
				drag_start_positions[asset] = asset.position
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
	elif event.is_action_released("asset_select"):
		asset_drag = false
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		if move_action_open:
			for asset in drag_assets:
				undo_redo.add_do_property(asset, "position", asset.position)
			undo_redo.commit_action(false)
			move_action_open = false
			was_dragging_asset = false
			drag_assets.clear()
			drag_start_positions.clear()
		elif was_multi_select:
			was_multi_select = false
			return
		else:
			select()
	if event.is_action_pressed("cam_zoom_in"):
		update_gm_zoom(gm_zoom_incr)
	elif event.is_action_pressed("cam_zoom_out"):
		update_gm_zoom(-gm_zoom_incr)
	if event is InputEventMouseMotion:
		if cam_pan:
			var new_offset = %GmCam.get_offset() - event.relative / gm_zoom
			%GmCam.set_offset(new_offset)
			%GmGrid.queue_redraw()
		elif asset_drag:
			if event.relative.is_zero_approx():
				return
			if not move_action_open:
				undo_redo.create_action("Move assets")
				for asset in drag_assets:
					undo_redo.add_undo_property(asset, "position", drag_start_positions[asset])
				move_action_open = true
			for asset in drag_assets:
				asset.position += event.relative / gm_zoom
			was_dragging_asset = true


func get_asset_ids(nodes: Array) -> Array[int]:
	var ids: Array[int] = []
	for node in nodes:
		ids.append(node.get_instance_id())
	return ids


func select(multi: bool = false) -> void:
	var pos: Vector2 = %GmView.get_canvas_transform().affine_inverse() * %GmView.get_mouse_position()
	var nodes: Array = %SceneRoot.get_node("Scene").get_assets_at(pos)
	if nodes.is_empty():
		last_single_select_stack.clear()
		if not multi:
			get_tree().call_group("selected_assets", "deselect")
		emit_signal("selection_changed")
		return
	var selected_count := get_tree().get_nodes_in_group("selected_assets").size()
	if nodes.size() == 1:
		var node = nodes[0]
		last_single_select_stack = get_asset_ids(nodes)
		if multi:
			if node.selected:
				node.deselect()
			else:
				node.select()
			emit_signal("selection_changed")
			return
		if selected_count > 1:
			get_tree().call_group("selected_assets", "deselect")
			node.select()
			emit_signal("selection_changed")
			return
		if node.selected:
			node.deselect()
		else:
			get_tree().call_group("selected_assets", "deselect")
			node.select()
		emit_signal("selection_changed")
		return
	if multi:
		for node in nodes:
			if not node.selected:
				node.select()
				emit_signal("selection_changed")
				return
		emit_signal("selection_changed")
		return
	var stack_ids: Array[int] = get_asset_ids(nodes)
	var stack_changed := stack_ids != last_single_select_stack
	var current_index := -1
	if not stack_changed and selected_count <= 1:
		for i in range(nodes.size()):
			if nodes[i].selected:
				current_index = i
				break
	get_tree().call_group("selected_assets", "deselect")
	if stack_changed or selected_count > 1:
		nodes[0].select()
	else:
		var next_index := (current_index + 1) % nodes.size()
		nodes[next_index].select()
	last_single_select_stack = stack_ids
	emit_signal("selection_changed")



func update_gm_zoom(incr:float) -> void:
	var old_zoom = gm_zoom
	var old_pos = %GmView.get_canvas_transform().affine_inverse() * %GmView.get_mouse_position()
	var new_incr = incr * gm_zoom
	gm_zoom += new_incr
	if gm_zoom < max_gm_zoom:
		gm_zoom = max_gm_zoom
	elif gm_zoom > min_gm_zoom:
		gm_zoom = min_gm_zoom
	if old_zoom == gm_zoom:
		return
	var new_zoom = Vector2(gm_zoom, gm_zoom)
	%GmCam.set_zoom(new_zoom)
	var new_pos = %GmView.get_canvas_transform().affine_inverse() * %GmView.get_mouse_position()
	%GmCam.offset += (old_pos - new_pos)
	%GmGrid.queue_redraw()


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if typeof(data) == TYPE_OBJECT:
		if data.get_script().get_global_name() in ["ImageAsset"]:
			return true
		else:
			return false
	else:
		return false


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var pos = %GmView.get_canvas_transform().affine_inverse() * %GmView.get_mouse_position()
	%SceneRoot.get_node("Scene").add_asset(pos, data)


func _on_mouse_entered() -> void:
	focus = true


func _on_mouse_exited() -> void:
	focus = false
