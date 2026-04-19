extends Node2D


@export var scene = Scene:
	set(value):
		scene = value
		update()
@export_category("Camera2D")
@export var pc_cam:Node


func update() -> void:
	for layer in scene.layers:
		var layer_node := Layer.new()
		layer_node.scene_layer = layer
		layer_node.gm_vis = layer.gm_vis
		layer_node.player_vis = layer.player_vis
		%LayerManager.add_child(layer_node)


func add_asset(_asset_position: Vector2, data: Variant, layer: int = 99) -> void:
	var packed_scene = preload("uid://rgndpcsbkpvi")
	var instance = packed_scene.instantiate()
	instance.asset = data
	if layer == 99:
		%LayerManager.get_children()[App.active_layer-1].add_child(instance)
	else:
		%LayerManager.get_children()[layer].add_child(instance)
	instance.position = get_global_mouse_position()
