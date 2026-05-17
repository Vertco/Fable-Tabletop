extends Node2D


@export var scene = Scene:
	set(value):
		scene = value
		update()
@export_category("Camera2D")
@export var pc_cam:Node


var undo_redo := UndoRedo.new()


func update() -> void:
	for layer in scene.layers:
		var layer_node := Layer.new()
		layer_node.scene_layer = layer
		layer_node.gm_vis = layer.gm_vis
		layer_node.player_vis = layer.player_vis
		%LayerManager.add_child(layer_node)


func add_asset(_asset_position: Vector2, data: Variant, layer: int = 99) -> void:
	undo_redo.create_action("Add asset")
	var packed_scene = preload("uid://rgndpcsbkpvi")
	var instance = packed_scene.instantiate()
	instance.asset = data
	instance.position = _asset_position
	if layer == 99:
		undo_redo.add_undo_reference(instance)
		%LayerManager.get_children()[App.active_layer-1].add_child(instance)
		undo_redo.add_do_method(%LayerManager.get_children()[App.active_layer-1].add_child.bind(instance))
		undo_redo.add_do_method(%LayerManager.get_children()[App.active_layer-1].move_child.bind(instance,instance.get_index()))
		undo_redo.add_undo_method(%LayerManager.get_children()[App.active_layer-1].remove_child.bind(instance))
	else:
		undo_redo.add_undo_reference(instance)
		%LayerManager.get_children()[layer].add_child(instance)
		undo_redo.add_do_method(%LayerManager.get_children()[layer].add_child.bind(instance))
		undo_redo.add_do_method(%LayerManager.get_children()[layer].move_child.bind(instance,instance.get_index()))
		undo_redo.add_undo_method(%LayerManager.get_children()[layer].remove_child.bind(instance))
	undo_redo.commit_action(false)


func get_assets_at(at_position:Vector2) -> Array[Node]:
	var nodes:Array[Node]
	for layer in %LayerManager.get_children():
		for node in layer.get_children():
			if node.type in ["ImageAsset", "TokenAsset"] &&\
			!node.locked and node.gm_vis:
				if node.get_rect().has_point(at_position) &&\
				node.is_pixel_opaque(node.to_local(at_position)):
					nodes.append(node)
	nodes.reverse()
	return nodes
