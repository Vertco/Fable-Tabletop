extends Control


signal select(node:Node)
signal multi_select(node:Node)
signal open(node:Node)


var hover := false:
	set(value):
		hover = value
		if hover:
			%Focus.show()
		else:
			if !selected:
				%Focus.hide()


@export_file_path() var ftt: String:
	set(value):
		ftt = value
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
var data: Resource
var type: String



func update() -> Error:
	var result: Error
	var reader := ZIPReader.new()
	result = reader.open(ftt)
	if reader.file_exists("campaign.tres"):
		pass
	else:
		if reader.file_exists("scenes/" + ftt.get_file().rsplit(".")[0] + ".tres"):
			var temp_data := reader.read_file("scenes/" + ftt.get_file().rsplit(".")[0] + ".tres")
			var temp = FileAccess.create_temp(FileAccess.ModeFlags.READ_WRITE,"",".tres",true)
			temp.store_buffer(temp_data)
			var temp_path := temp.get_path_absolute()
			temp.close()
			App.temp_files.append(temp_path)
			ResourceLoader.set_abort_on_missing_resources(false)
			data = ResourceLoader.load(temp_path,"",ResourceLoader.CACHE_MODE_IGNORE_DEEP)
			ResourceLoader.set_abort_on_missing_resources(true)
	%Path.text = ftt
	if data:
		%Favorite.button_pressed = data.favorite
		type = data.get_script().get_global_name()
		match type:
			"Scene":
				%TypeIcon.texture = preload("uid://d21c6o4dpc1nw")
				%TypeIcon.tooltip_text = "Scene"
			"Campaign":
				%TypeIcon.texture = preload("uid://cj6hl186mqwam")
				%TypeIcon.tooltip_text = "Campaign"
			_:
				%TypeIcon.texture = preload("uid://b02x18chf4r8y")
				%TypeIcon.tooltip_text = "Unknown"
		%DisplayName.text = data.title
		%Description.text = data.description
		%Version.text = "v" + data.version
		if data.version != ProjectSettings.get_setting("application/config/version"):
			%VersionMismatch.show()
		else:
			%VersionMismatch.hide()
		%Updated.text = Time.get_datetime_string_from_datetime_dict(data.updated_date_time,true)
	else:
		%Favorite.disabled = true
		%Preview.texture = preload("uid://c66uqhabpmixa")
		%TypeIcon.texture = preload("uid://b02x18chf4r8y")
		%TypeIcon.tooltip_text = "Error"
		%DisplayName.text = ftt.get_file()
		%Description.text = "This file is malformed, and could not be loaded!"
		%Version.text = "Error"
		%VersionMismatch.show()
		%Updated.hide()
		mouse_filter = Control.MOUSE_FILTER_PASS
	return result


func _on_path_pressed() -> void:
	OS.shell_show_in_file_manager(ftt)


func _on_mouse_entered() -> void:
	hover = true


func _on_mouse_exited() -> void:
	hover = false


func _on_gui_input(event: InputEvent) -> void:
	if data:
		if event.is_action_pressed("mouse_multi_select"):
			emit_signal("multi_select",self)
		elif event.is_action_pressed("mouse_select"):
			if event.double_click:
				emit_signal("open",self)
			else:
				emit_signal("select",self)
