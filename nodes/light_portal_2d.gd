@tool
@icon("uid://srd76q1icmgc")
extends LightOccluder2D
class_name LightPortal2D

@export var enabled := true:
	set(value):
		if value:
			occluder_light_mask = occluder_light_mask_cache
			occluder_light_mask_cache = 0
		else:
			occluder_light_mask_cache = light_mask
			occluder_light_mask = 0
		enabled = value
var occluder_light_mask_cache: int
