extends Control


signal new_scene_pressed
signal selection_changed


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
			add_tree_active_button(tree_layer,0,layer.active)
			add_tree_vis_button(tree_layer, 1, App.theme.gm_color, layer.gm_vis, "GM Visibility")
			add_tree_vis_button(tree_layer, 2, App.theme.player_color, layer.player_vis, "Player Visibility")
			for asset in layer.get_children():
				var tree_asset:TreeItem = tree.create_item(tree_layer)
				tree_asset.set_text(0,asset.asset.name)
				tree_asset.set_metadata(0,asset)
				tree_asset.set_selectable(0,!asset.locked)
				var type:String = asset.asset.get_script().get_global_name()
				match type:
					"ImageAsset":
						tree_asset.set_icon(0,preload("uid://dy1rg1sx6s3f4")) # image.svg
					"TokenAsset":
						tree_asset.set_icon(0,preload("uid://c357f0jhytyvb")) # character.svg
				tree_asset.add_button(0,get_locked_icon(asset.locked))
				if asset.is_in_group("selected_assets"):
					tree_asset.select(0)
				add_tree_vis_button(tree_asset, 1, App.theme.gm_color, asset.gm_vis, "GM Visibility")
				add_tree_vis_button(tree_asset, 2, App.theme.player_color, asset.player_vis, "Player Visibility")
				if asset.selected:
					tree_asset.select(0)
				else:
					tree_asset.deselect(0)
		var add_button:TreeItem = tree.create_item(root)
		add_button.set_text(0,"Add Layer")
		add_button.set_icon(0,preload("uid://del1s3wlfw7fg"))
		add_button.set_metadata(0,{"type":null})


func filter_tree(filter:String) -> void:
	var root: TreeItem = %Tree.get_root()
	var layer := root.get_first_child()
	while layer:
		if layer.get_text(0).to_lower() == filter.to_lower():
			layer.select(0)
		var asset := layer.get_first_child()
		while asset:
			if filter:
				if asset.get_text(0).containsn(filter):
					asset.set_visible(true)
					if asset.get_text(0).to_lower() == filter.to_lower():
						asset.select(0)
						print(asset.get_text(0) + " is exact!")
				else:
					asset.set_visible(false)
			else:
				asset.set_visible(true)
			asset = asset.get_next()
		layer = layer.get_next()


func get_vis_icon(visibility: bool) -> Resource:
	if visibility:
		return preload("uid://b58bvuo6dkfw8") # gui_visible.svg
	else:
		return preload("uid://dxli5mwr6dcm7") # gui_hidden.svg


func get_active_icon(state: bool) -> Resource:
	if state:
		return preload("uid://ymissyq5bnpx") # layer_cative.svg
	else:
		return preload("uid://dn0eq4280s37y") # layer_inactive.svg


func get_locked_icon(state: bool) -> Resource:
	if state:
		return preload("uid://mjuacri4od50") # lock.svg
	else:
		return preload("uid://o8hsmsstid6g") # unlock.svg


func add_tree_active_button(entry: TreeItem, id: int, active: bool) -> void:
	entry.add_button(0,get_active_icon(active))
	entry.set_button_disabled(0,id,active)
	if active:
		entry.set_button_tooltip_text(0,0,"Active Layer")
	else:
		entry.set_button_tooltip_text(0,0,"Set Active")


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
					item.set_button(0,0,get_locked_icon(metadata.locked))
					item.set_selectable(0,!metadata.locked)
				1:
					await metadata.edit("gm_vis")
					item.set_button(0,1,get_vis_icon(metadata.gm_vis))
				2:
					metadata.edit("player_vis")
					item.set_button(0,2,get_vis_icon(metadata.player_vis))
		"Layer":
			match id:
				0:
					await metadata.edit("active")
					item.set_button(0,0,get_active_icon(metadata.active))
					item.set_button_disabled(0,0,metadata.active)
				1:
					await metadata.edit("gm_vis")
					item.set_button(0,1,get_vis_icon(metadata.gm_vis))
				2:
					metadata.edit("player_vis")
					item.set_button(0,2,get_vis_icon(metadata.player_vis))


func _on_tree_multi_selected(item: TreeItem, column: int, selected: bool) -> void:
	if item.get_text(0) == "Add Layer":
		item.deselect(0)
		emit_signal("new_scene_pressed")
	else:
		var metadata:Node = item.get_metadata(column)
		match metadata.type:
			"ImageAsset":
				if selected:
					metadata.select()
				else:
					metadata.deselect()
	emit_signal("selection_changed")


func _on_tree_nothing_selected() -> void:
	var selected = %Tree.get_next_selected(null)
	while selected:
		selected.deselect(0)
		var metadata:Node = selected.get_metadata(0)
		match metadata.type:
			"ImageAsset":
				metadata.deselect()
		selected = %Tree.get_next_selected(selected)
