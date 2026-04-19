extends Node2D


@export var asset: Asset:
	set(value):
		asset = value
		update(value)
@export var locked := false
@export var gm_vis := true:
	set(value):
		for layer in range(0,10):
			set_visibility_layer_bit(layer,value)
		gm_vis = value
@export var player_vis := true:
	set(value):
		for layer in range(11,20):
			set_visibility_layer_bit(layer,value)
		player_vis = value


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
					pass
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


func image_asset() -> void:
	var sprite := Sprite2D.new()
	var image := Image.load_from_file(asset.texture)
	sprite.texture = ImageTexture.create_from_image(image)
	add_child(sprite)


func token_asset() -> void:
	pass
