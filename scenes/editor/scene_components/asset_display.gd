extends Node2D
class_name AssetDisplay


@export var asset: Asset:
	set(value):
		asset = value
		update(value)
@export var locked := false
@export var gm_vis := true:
	set(value):
		for layer in range(0,10):
			set_visibility_layer_bit(layer,value)
			for child in get_children():
				child.set_visibility_layer_bit(layer,value)
		gm_vis = value
@export var player_vis := true:
	set(value):
		for layer in range(11,20):
			set_visibility_layer_bit(layer,value)
			for child in get_children():
				child.set_visibility_layer_bit(layer,value)
		player_vis = value
@export var selected := false:
	set(value):
		if value:
			add_to_group("selected_assets")
			selected = value
		else:
			remove_from_group("selected_assets")
			selected = value
	get:
		return is_in_group("selected_assets")


var type: String


func update(new_asset: Asset) -> void:
	type = new_asset.get_script().get_global_name()
	match type:
		"ImageAsset":
			image_asset()
		"TokenAsset":
			token_asset()


func save() -> AssetInstance:
	var result = AssetInstance.new()
	result.asset = asset
	result.pos = position
	result.rot = rotation
	result.scale = scale
	result.locked = locked
	result.gm_vis = gm_vis
	result.player_vis = player_vis
	return result


func edit(field:String, value:Variant = null) -> void:
	match type:
		"ImageAsset":
			match field:
				"lock":
					if value:
						locked = value
					else:
						locked = !locked
				"gm_vis":
					if value:
						gm_vis = value
					else:
						gm_vis = !gm_vis
				"player_vis":
					if value:
						player_vis = value
					else:
						player_vis = !player_vis
		"TokenAsset":
			pass


func get_rect() -> Rect2:
	var display := get_children()[0] as Sprite2D
	return display.get_global_transform() * display.get_rect()


func is_pixel_opaque(global_pos: Vector2) -> bool:
	var display := get_children()[0] as Sprite2D
	var sprite_local := display.to_local(global_pos)
	return display.is_pixel_opaque(sprite_local)


func select() -> void:
	selected = true


func deselect() -> void:
	selected = false


func image_asset() -> void:
	var sprite := Sprite2D.new()
	var image := Image.load_from_file(asset.texture)
	sprite.texture = ImageTexture.create_from_image(image)
	if asset.pps:
		sprite.scale = Vector2(50.0/asset.pps, 50.0/asset.pps)
	for layer in range(0,10):
		sprite.set_visibility_layer_bit(layer,gm_vis)
	for layer in range(11,20):
		sprite.set_visibility_layer_bit(layer,player_vis)
	add_child(sprite)


func token_asset() -> void:
	pass
