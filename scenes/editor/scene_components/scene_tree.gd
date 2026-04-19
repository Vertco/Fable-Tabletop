extends Control


@onready var scene: Node:
	set(value):
		var layer_manager:Node
		if scene != null:
			layer_manager = scene.get_node("LayerManager")
			if layer_manager != null:
				if layer_manager.is_connected("child_order_changed",update):
					layer_manager.disconnect("child_order_changed",update)
				for layer in layer_manager.get_children():
					if layer.is_connected("child_order_changed",update):
						layer.disconnect("child_order_changed",update)
		scene = value
		if scene != null:
			layer_manager = scene.get_node("LayerManager")
			if layer_manager != null:
				layer_manager.connect("child_order_changed",update)
				for layer in layer_manager.get_children():
					print(layer)
					layer.connect("child_order_changed",update)
		update()


func update() -> void:
	var layer_manager := scene.get_node("LayerManager")
	var tree := get_node("Tree")
	tree.clear()
	var root:TreeItem = tree.create_item()
	if layer_manager != null:
		for layer in layer_manager.get_children():
			var tree_layer:TreeItem = tree.create_item(root)
			tree_layer.set_text(0,layer.name)
			tree_layer.set_metadata(0,layer)
			tree_layer.set_icon(0,preload("uid://d21c6o4dpc1nw")) # tile_map_dock.svg
			add_tree_vis_button(tree_layer, 0, App.theme.gm_color, layer.gm_vis, "GM Visibility")
			add_tree_vis_button(tree_layer, 1, App.theme.player_color, layer.player_vis, "Player Visibility")
			for asset in layer.get_children():
				var tree_asset:TreeItem = tree.create_item(tree_layer)
				tree_asset.set_text(0,asset.asset.name)
				tree_asset.set_metadata(0,asset)
				var type:String = asset.asset.get_script().get_global_name()
				match type:
					"ImageAsset":
						tree_asset.set_icon(0,preload("uid://dy1rg1sx6s3f4")) # image.svg
					"TokenAsset":
						tree_asset.set_icon(0,preload("uid://c357f0jhytyvb")) # character.svg
				tree_asset.add_button(0,preload("uid://o8hsmsstid6g")) # unlock.svg
				add_tree_vis_button(tree_asset, 1, App.theme.gm_color, asset.gm_vis, "GM Visibility")
				add_tree_vis_button(tree_asset, 2, App.theme.player_color, asset.player_vis, "Player Visibility")


func get_vis_icon(visibility: bool) -> Resource:
	if visibility:
		return preload("uid://b58bvuo6dkfw8") # gui_visible.svg
	else:
		return preload("uid://dxli5mwr6dcm7") # gui_hidden.svg


func add_tree_vis_button(entry: TreeItem, id: int, color:Color, visibility: bool, tooltip: String) -> void:
	entry.add_button(0,get_vis_icon(visibility))
	entry.set_button_color(0,id,color)
	entry.set_button_tooltip_text(0,id,tooltip)


func _on_tree_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
	var metadata:Node = item.get_metadata(0)
	match metadata.type:
		"ImageAsset":
			match id:
				0:
					await metadata.edit("lock")
				1:
					await metadata.edit("gm_vis")
					item.set_button(0,1,get_vis_icon(metadata.gm_vis))
				2:
					metadata.edit("player_vis")
					item.set_button(0,2,get_vis_icon(metadata.player_vis))
		"Layer":
			match id:
				0:
					await metadata.edit("gm_vis")
					item.set_button(0,0,get_vis_icon(metadata.gm_vis))
				1:
					metadata.edit("player_vis")
					item.set_button(0,0,get_vis_icon(metadata.player_vis))
