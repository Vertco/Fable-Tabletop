extends Node2D


@export var scene = Scene:
	set(value):
		scene = value
		update()
@export_category("Camera2D")
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


func update() -> void:
	gm_zoom = 1
	for layer in scene.layers:
		var layer_node := Layer.new()
		layer_node.scene_layer = layer
		layer_node.gm_vis = layer.gm_vis
		layer_node.player_vis = layer.player_vis
		%LayerManager.add_child(layer_node)


func update_gm_zoom(incr:float) -> void:
	var old_zoom = gm_zoom
	var old_pos = get_global_mouse_position()
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
	var new_pos = get_global_mouse_position()
	%GmCam.offset += (old_pos - new_pos)
	%GmGrid.queue_redraw()


func add_asset(_asset_position: Vector2, data: Variant, layer: int = 99) -> void:
	var packed_scene = preload("uid://rgndpcsbkpvi")
	var instance = packed_scene.instantiate()
	instance.asset = data
	if layer == 99:
		%LayerManager.get_children()[App.active_layer-1].add_child(instance)
	else:
		%LayerManager.get_children()[layer].add_child(instance)
	instance.position = get_global_mouse_position()
