extends Node2D
class_name Layer

@export var scene_layer: SceneLayer:
	set(value):
		active = value.active
		scene_layer = value
		update()
@export var layer_id: int:
	set(value):
		set_visibility_layer(0)
		set_visibility_layer_bit(value,gm_vis)
		set_visibility_layer_bit(value+10,player_vis)
@export var gm_vis := true:
	set(value):
		set_visibility_layer_bit(layer_id+1,value)
		gm_vis = value
@export var player_vis := true:
	set(value):
		set_visibility_layer_bit(layer_id+11,value)
		player_vis = value

var grid := preload("uid://cbn6ycgpm4u5b")
var type := "Layer"
var active: bool


func update() -> void:
	name = scene_layer.name
	gm_vis = scene_layer.gm_vis
	player_vis = scene_layer.player_vis
	for asset in scene_layer.assets:
		var packed_scene = preload("uid://rgndpcsbkpvi") # asset_display
		var display = packed_scene.instantiate()
		display.asset = asset.asset
		display.position = asset.pos
		display.rotation = asset.rot
		display.scale = asset.scale
		display.locked = asset.locked
		display.gm_vis = asset.gm_vis
		display.player_vis = asset.player_vis
		add_child(display)


func save() -> SceneLayer:
	var result := SceneLayer.new()
	result.name = name
	result.gm_vis = gm_vis
	result.player_vis = player_vis
	for asset_display in get_children():
		result.assets.append(asset_display.save())
	return result


func edit(field:String, value:Variant = null) -> void:
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
