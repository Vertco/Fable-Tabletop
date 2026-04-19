@tool
extends Node2D


func _ready() -> void:
	set_layer_masks()


func _on_child_order_changed() -> void:
	set_layer_masks()


func set_layer_masks() -> Error:
	var layers := get_children()
	var current := 1
	if layers.size() <= 9:
		for layer in layers:
			if current <= 10:
				layer.layer_id = current
				current += 1
			else:
				return Error.ERR_PARAMETER_RANGE_ERROR
		return Error.OK
	else:
		return Error.ERR_PARAMETER_RANGE_ERROR
