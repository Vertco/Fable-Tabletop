extends Control


signal select(node:Node)
signal multi_select(node:Node)
signal open(asset:Asset) ## Open the current asset in the asset editor
signal delete(node:Node) ## Delete the current asset


@export_file_path() var asset: String:
	set(value):
		asset = value
		update()
@export var selected := false:
	set(value):
		selected = value
		if value:
			var theme_selected := StyleBoxFlat.new()
			theme_selected.bg_color = "99999933"
			theme_selected.border_color = "cccccc66"
			theme_selected.border_width_left = 1
			theme_selected.border_width_top = 1
			theme_selected.border_width_right = 1
			theme_selected.border_width_bottom = 1
			theme_selected.corner_radius_top_left = 5
			theme_selected.corner_radius_top_right = 5
			theme_selected.corner_radius_bottom_left = 5
			theme_selected.corner_radius_bottom_right = 5
			%Focus.add_theme_stylebox_override("panel",theme_selected)
			%Focus.show()
		else:
			var theme_not_selected := StyleBoxFlat.new()
			theme_not_selected.bg_color = "99999933"
			theme_not_selected.corner_radius_top_left = 5
			theme_not_selected.corner_radius_top_right = 5
			theme_not_selected.corner_radius_bottom_left = 5
			theme_not_selected.corner_radius_bottom_right = 5
			%Focus.add_theme_stylebox_override("panel",theme_not_selected)
			if !hover:
				%Focus.hide()
var hover := false:
	set(value):
		hover = value
		if hover:
			%Focus.show()
		else:
			if !selected:
				%Focus.hide()
var data: Resource
var type: String


func update() -> Error:
	var result := Error.OK
	data = ResourceLoader.load(App.current_dir+"/assets/"+asset)
	var image := Image.load_from_file(data.texture)
	if image.get_width()*image.get_height() > 1:
		%Preview.set_expand_mode(TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL)
	else:
		%Preview.set_expand_mode(TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL)
	%Preview.texture = ImageTexture.create_from_image(image)
	%Label.text = data.name
	type = data.get_script().get_global_name()
	match type:
		"ImageAsset":
			%TypeIcon.texture = preload("uid://dy1rg1sx6s3f4")
			%TypeIcon.tooltip_text = "Image"
		"TokenAsset":
			%TypeIcon.texture = preload("uid://c357f0jhytyvb")
			%TypeIcon.tooltip_text = "Token"
	return result


func _get_drag_data(_at_position) -> Asset:
	var icon = TextureRect.new()
	var preview = Control.new()
	var image := Image.load_from_file(data.texture)
	icon.texture = ImageTexture.create_from_image(image)
	icon.position = (icon.texture.get_size() * -0.5)*App.gm_zoom
	icon.scale = icon.scale*App.gm_zoom
	icon.modulate = "ffffff88"
	preview.add_child(icon)
	set_drag_preview(preview)
	return data


func _on_mouse_entered() -> void:
	hover = true


func _on_mouse_exited() -> void:
	hover = false


func _on_gui_input(event: InputEvent) -> void:
	if data:
		if event.is_action_pressed("ui_multi_select"):
			emit_signal("multi_select",self)
		elif event.is_action_pressed("ui_select"):
			if event.double_click:
				emit_signal("open",data)
			else:
				emit_signal("select",self)
		elif event.is_action_pressed("mouse_alt_select"):
			%PopupMenu.position = get_global_mouse_position()
			%PopupMenu.popup()


func _on_popup_menu_mouse_exited() -> void:
	%PopupMenu.hide()


func _on_popup_menu_id_pressed(id: int) -> void:
	match id:
		0:
			emit_signal("open",data)
		1:
			emit_signal("delete",self)
