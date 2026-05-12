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
	instance.position = _asset_position


func get_assets_at(at_position:Vector2) -> Array[Node]:
	var nodes:Array[Node]
	for layer in %LayerManager.get_children():
		for node in layer.get_children():
			if node.type in ["ImageAsset", "TokenAsset"] &&\
			!node.locked:
				if node.get_rect().has_point(at_position) &&\
				node.is_pixel_opaque(node.to_local(at_position)):
					nodes.append(node)
	nodes.reverse()
	return nodes
