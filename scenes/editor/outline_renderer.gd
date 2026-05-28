extends Control


var selection_rect := Rect2()
var prev_selection_rect:Rect2
var pc_cam_rect := Rect2()
var prev_pc_cam_rect:Rect2


func _process(_delta: float) -> void:
	get_selection_rect()
	get_pc_cam_rect()


func get_selection_rect() -> void:
	selection_rect = Rect2()
	var first:bool = true
	for n in get_tree().get_nodes_in_group("selected_assets"):
		var rect:Rect2
		rect.position = (n.position*%GmCam.zoom)+\
		((Vector2(%GmView.get_size()) / 2)) - %GmCam.get_offset() * %GmCam.zoom
		rect.size = n.get_rect().size*%GmCam.zoom
		rect.position = rect.position - (rect.size / 2)
		if first:
			selection_rect = rect
		else:
			selection_rect = selection_rect.merge(rect)
		first = false
	
	# Redraw selection outline if different to previous
	if selection_rect != prev_selection_rect:
		queue_redraw()
	prev_selection_rect = selection_rect


func get_pc_cam_rect() -> void:
	if %PcWindow.visible:
		var pc_size:Vector2 = Vector2(%PcWindow.get_visible_rect().size)
		var rect_pos:Vector2 = (%PcCam.get_offset()*%GmCam.zoom)+\
		((Vector2(%GmView.get_size())/2)-((pc_size/%PcCam.zoom/2)*\
		%GmCam.zoom))-%GmCam.get_offset()*%GmCam.zoom
		var rect_size:Vector2 = pc_size/%PcCam.zoom*%GmCam.zoom
		pc_cam_rect = Rect2(rect_pos,rect_size)
	else:
		pc_cam_rect = Rect2()
	
	# Redraw camera outline if different to previous
	if pc_cam_rect != prev_pc_cam_rect:
		queue_redraw()
	prev_pc_cam_rect = pc_cam_rect


func _draw() -> void:
	# Draw selection rect
	draw_dashed_line(selection_rect.position, selection_rect.position+Vector2(selection_rect.size.x, 0), Color.WHITE, 2, 4)
	draw_dashed_line(selection_rect.position+Vector2(selection_rect.size.x, 0), selection_rect.position + Vector2(selection_rect.size.x, selection_rect.size.y), Color.WHITE, 2, 4)
	draw_dashed_line(selection_rect.position+Vector2(selection_rect.size.x, selection_rect.size.y), selection_rect.position + Vector2(0, selection_rect.size.y), Color.WHITE, 2, 4)
	draw_dashed_line(selection_rect.position+Vector2(0, selection_rect.size.y), selection_rect.position, Color.WHITE, 2, 4)
	draw_rect(selection_rect,Color(Color.WHITE,0.2))
	
	draw_rect(pc_cam_rect,Color(0.1,0.1,0.1,0.6),false,2)
