extends Control


const margin:Dictionary = {
	"top": 5.0,
	"right": 5.0,
	"bottom": 5.0,
	"left": 5.0
}
const seperation:float = 5

var dragging:bool
var offscreen:bool
var header_mouse_offset:Vector2


@export var gm_viewport: SubViewport
@export var gm_camera: Camera2D
@export var gm_gridrenderer: Node
@export var pc_window: Window
@export var pc_camera: Camera2D
@export var pc_gridrenderer: Node
@export var pc_cover: Node


func _process(_delta: float) -> void:
	update()


func update() -> void:
	if pc_window.visible:
		visible = true
		
		# Calculate scaled size and position
		var pc_size:Vector2 = Vector2(pc_window.get_visible_rect().size)
		var rect_pos:Vector2 = (pc_camera.get_offset()*gm_camera.zoom)+((Vector2(gm_viewport.get_size()) / 2) - ((pc_size/pc_camera.zoom / 2) * gm_camera.zoom)) - gm_camera.get_offset() * gm_camera.zoom
		var rect_size:Vector2 = pc_size/pc_camera.zoom * gm_camera.zoom
		
		# Set initial header position
		%PcViewHeader.set_position(rect_pos)
		
		# Calculate and apply header offset
		var header_offset:Vector2 = Vector2(rect_size.x/2-%PcViewHeader.size.x/2,-%PcViewHeader.size.y-seperation)
		var offset_pos:Vector2 = (rect_pos + header_offset).clamp(Vector2(margin.left,margin.top), Vector2(gm_viewport.get_size())-(Vector2(margin.right,margin.bottom)+%PcViewHeader.size))
		%PcViewHeader.set_position(offset_pos)
	else:
		visible = false


func _on_pc_view_header_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if event.pressed:
				dragging = true
				header_mouse_offset = gm_viewport.get_parent().get_global_position()+\
				%PcViewHeader.get_local_mouse_position()
				pc_gridrenderer.queue_redraw()
			else:
				dragging = false
				Input.warp_mouse(%PcViewHeader.position+header_mouse_offset)
			if event.double_click:
				var tween := get_tree().create_tween()
				tween.tween_property(gm_camera,"offset",pc_camera.offset-Vector2(0,55),0.5).set_trans(Tween.TRANS_CUBIC)
				tween.tween_callback(gm_gridrenderer.queue_redraw)
				tween.tween_callback(update)
	elif event is InputEventMouseMotion:
		if dragging:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			pc_camera.set_offset(pc_camera.offset+(event.relative/gm_camera.zoom))
			pc_gridrenderer.queue_redraw()
			update()


func _on_button_pressed() -> void:
	pc_cover.visible = !pc_cover.visible
	if pc_cover.visible:
		%Button.icon = preload("uid://dxli5mwr6dcm7") # gui_hidden
		%Button.tooltip_text = "Reveal"
	else:
		%Button.icon = preload("uid://b58bvuo6dkfw8") # gui_vvisible
		%Button.tooltip_text = "Cover"
