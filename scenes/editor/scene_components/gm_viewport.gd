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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_pan"):
		cam_pan = true
	elif event.is_action_released("mouse_pan"):
		cam_pan = false
	if event.is_action_pressed("mouse_multi_select"):
		select(true)
	elif event.is_action_pressed("mouse_select"):
		select()
	elif event.is_action_pressed("cam_zoom_in"):
		update_gm_zoom(gm_zoom_incr)
	elif event.is_action_pressed("cam_zoom_out"):
		update_gm_zoom(-gm_zoom_incr)
	elif event is InputEventMouseMotion && cam_pan:
		var new_offset = %GmCam.get_offset() - event.relative/gm_zoom
		new_offset.x = new_offset.x
		new_offset.y = new_offset.y
		%GmCam.set_offset(new_offset)
		%GmGrid.queue_redraw()


func select(multi: bool = false) -> void:
	var pos: Vector2 = %GmView.get_canvas_transform().affine_inverse() * %GmView.get_mouse_position()
	var nodes: Array = %SceneRoot.get_node("Scene").get_assets_at(pos)
	var next_index:int
	if nodes.is_empty():
		emit_signal("selection_changed")
		return
	if multi:
		var highest_selected_index := -1
		for i in range(nodes.size()):
			if nodes[i].selected:
				highest_selected_index = i
		next_index = (highest_selected_index + 1) % nodes.size()
		nodes[next_index].select()
		emit_signal("selection_changed")
		return
	if nodes.size() == 1:
		var node = nodes[0]
		if node.selected:
			node.deselect()
		else:
			get_tree().call_group("selected_assets", "deselect")
			node.select()
		emit_signal("selection_changed")
		return
	var current_index := -1
	for i in range(nodes.size()):
		if nodes[i].selected:
			current_index = i
			break
	get_tree().call_group("selected_assets", "deselect")
	next_index = (current_index + 1) % nodes.size()
	nodes[next_index].select()
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
