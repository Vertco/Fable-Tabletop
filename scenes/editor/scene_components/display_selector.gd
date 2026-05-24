extends Control


signal pc_zoom_updated(zoom:Vector2)


@export var pc_window:Window


func _ready() -> void:
	pc_window.connect("size_changed",update)
	get_window().connect("size_changed",update)


func _notification(what):
	if what == NOTIFICATION_WM_POSITION_CHANGED:
		update()


func update() -> void:
	if get_window():
		if !check_overlap():
			pc_window.hide()
			App.notify(App.StatusState.WARNING,"Stopped overlapping projection!")
		update_selector()
		update_preview()
		update_current()
		if pc_window.visible:
			%Label.text = "Projecting"
			%ConfirmButton.text = "Stop projecting"
		else:
			%Label.text = "Project..."
			%ConfirmButton.text = "Project"
		if App.pc_display != 99:
			%ConfirmButton.disabled = false


func check_overlap() -> bool:
	var pc_rect := Rect2i(pc_window.position, pc_window.size)
	var gm_rect := Rect2i(get_window().position, get_window().size)
	@warning_ignore("integer_division")
	if pc_rect.intersects(gm_rect) && pc_window.visible \
	&& pc_rect.intersection(gm_rect).get_area() > gm_rect.get_area()/2:
		return false
	else:
		return true


func update_selector() -> void:
	var displays: int = DisplayServer.get_screen_count()
	var displays_rect: Rect2 = Rect2()
	var display_buttons := get_tree().get_nodes_in_group("display_buttons")
	for button in display_buttons:
		button.queue_free()
	for display in displays:
		var pos: Vector2 = Vector2(DisplayServer.screen_get_position(display))
		var display_size: Vector2 = Vector2(DisplayServer.screen_get_size(display))
		var rect: Rect2 = Rect2(pos, display_size)
		displays_rect = rect if displays_rect == Rect2() else displays_rect.merge(rect)
	var preview_size: Vector2 = Vector2(392,242)
	var preview_scale: float = min(
		preview_size.x / displays_rect.size.x,
		preview_size.y / displays_rect.size.y
	)
	var scaled_size: Vector2 = displays_rect.size * preview_scale
	var offset: Vector2 = (preview_size - scaled_size) / 2.0
	for display in displays:
		var display_button:Button = Button.new()
		var pos: Vector2 = Vector2(DisplayServer.screen_get_position(display)) - displays_rect.position
		var display_size: Vector2 = Vector2(DisplayServer.screen_get_size(display))
		display_button.position = pos * preview_scale + offset
		display_button.size = display_size * preview_scale
		display_button.text = str(display)
		display_button.editor_description = str(display)
		display_button.pressed.connect(select_display.bind(display))
		display_button.add_to_group("display_buttons")
		if display == App.pc_display:
			var theme_override:StyleBox = display_button.get_theme_stylebox("normal").duplicate()
			theme_override.bg_color = Color(App.theme.player_color,0.25)
			display_button.add_theme_stylebox_override("normal", theme_override)
		%DisplaySelector.add_child(display_button)


func update_preview() -> void:
	var displays: int = DisplayServer.get_screen_count()
	var displays_rect: Rect2 = Rect2()
	var display_buttons := get_tree().get_nodes_in_group("display_previews")
	for button in display_buttons:
		button.queue_free()
	if pc_window.visible:
		for display in displays:
			var pos: Vector2 = Vector2(DisplayServer.screen_get_position(display))
			var display_size: Vector2 = Vector2(DisplayServer.screen_get_size(display))
			var rect: Rect2 = Rect2(pos, display_size)
			displays_rect = rect if displays_rect == Rect2() else displays_rect.merge(rect)
		var preview_size: Vector2 = %Preview.size
		var preview_scale: float = min(
			preview_size.x / displays_rect.size.x,
			preview_size.y / displays_rect.size.y
		)
		var scaled_size: Vector2 = displays_rect.size * preview_scale
		var offset: Vector2 = (preview_size - scaled_size) / 2.0
		for display in displays:
			var display_preview: Panel = Panel.new()
			var pos: Vector2 = Vector2(DisplayServer.screen_get_position(display)) - displays_rect.position
			var display_size: Vector2 = Vector2(DisplayServer.screen_get_size(display))
			display_preview.position = pos * preview_scale + offset
			display_preview.size = display_size * preview_scale
			display_preview.editor_description = str(display)
			display_preview.mouse_filter = Control.MOUSE_FILTER_PASS
			display_preview.add_to_group("display_previews")
			if display == App.pc_display:
				var theme_override:StyleBox = display_preview.get_theme_stylebox("panel").duplicate()
				theme_override.bg_color = Color(App.theme.player_color,0.25)
				display_preview.add_theme_stylebox_override("panel", theme_override)
			%Preview.add_child(display_preview)


func update_current() -> void:
	var current:int = DisplayServer.window_get_current_screen()
	var display_buttons:Array[Node] = get_tree().get_nodes_in_group("display_buttons")
	for button in display_buttons:
		if button.text == str(current):
			button.disabled = true
			button.tooltip_text = "Can't select active display"
			button.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
		else:
			button.disabled = false
			button.tooltip_text = ""


func select_display(display:int) -> void:
	var display_buttons:Array[Node] = get_tree().get_nodes_in_group("display_buttons")
	for button in display_buttons:
		if button.editor_description == str(display):
			App.pc_display = display
			var theme_override:StyleBox = button.get_theme_stylebox("normal").duplicate()
			theme_override.bg_color = Color(App.theme.player_color,0.25)
			button.add_theme_stylebox_override("normal", theme_override)
		else:
			button.remove_theme_stylebox_override("normal")
	var display_previews:Array[Node] = get_tree().get_nodes_in_group("display_previews")
	for preview in display_previews:
		if preview.editor_description == str(display):
			App.pc_display = display
			var theme_override:StyleBox = preview.get_theme_stylebox("panel").duplicate()
			theme_override.bg_color = Color(App.theme.player_color,0.25)
			preview.add_theme_stylebox_override("panel", theme_override)
		else:
			preview.remove_theme_stylebox_override("panel")
	update()


func _on_pressed() -> void:
	%SelectionMenu.popup()
	%SelectionMenu.position = global_position + Vector2(-%SelectionMenu.size.x+size.x,size.y)
	update()


func _on_selection_menu_mouse_exited() -> void:
	%SelectionMenu.hide()


func _on_confirmed() -> void:
	if pc_window.visible:
		%SelectionMenu.hide()
		App.confirm("Do you want to stop projecting?","Stop projecting?",\
		"Stop","Cancel")
		var confirm = await App.confirmation
		if confirm[0]:
			pc_window.hide()
			App.notify(App.StatusState.INFO,"Stopped projecting")
			update()
	else:
		var global_pos = DisplayServer.screen_get_position(App.pc_display)
		pc_window.set_position(global_pos)
		pc_window.popup()
		emit_signal("pc_zoom_updated", Prefs.pc_zoom)
		%SelectionMenu.hide()
		App.notify(App.StatusState.SUCCESS,"Succesfully started projecting")
		update()


func _on_options_button_pressed() -> void:
	%PcOptions.popup()


func _on_pc_options_about_to_popup() -> void:
	%Width.value = Prefs.pc_zoom.x
	%Height.value = Prefs.pc_zoom.y


func _on_pc_options_confirmed() -> void:
	var pc_view_size:Vector2
	if %Width.value == 0 && %Height.value == 0:
		emit_signal("pc_zoom_updated", Vector2(0,0))
		pc_view_size = Vector2(0,0)
	else:
		pc_view_size = Vector2(%Width.value,%Height.value)
	Prefs.save_prefs({"pc_zoom": pc_view_size})
	emit_signal("pc_zoom_updated", pc_view_size)


func _on_reset_width_pressed() -> void:
	%Width.value = 0


func _on_reset_height_pressed() -> void:
	%Height.value = 0
