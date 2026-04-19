extends Node


@warning_ignore("unused_signal")
signal confirmation(result:bool,custom:StringName)
signal layers_changed(active: int, visible: Array[int])
signal create_notification(status: App.StatusState, message: String)


enum StatusState {
	INFO,
	SUCCESS,
	WARNING,
	ERROR
}


const current_dir := "user://current"
const theme :={
	"gm_color": Color("#6aff7c"),
	"player_color": Color("#6393ff")
}


var selected_fables: Array:
	set(value):
		var fables: Array[String]
		for fable in value:
			fables.append(fable.ftt)
		selected_fables = fables
var active_layer := 1:
	set(value):
		active_layer = value
		emit_signal("layers_changed",value,visible_layers)
var visible_layers: Array[int] = [1]:
	set(value):
		visible_layers = value
		emit_signal("layers_changed",active_layer,value)


var canvas: CanvasLayer
var gm_zoom: float
var temp_files: PackedStringArray
var pc_display: int = 99


func create_scene(title:String,_description:String="",_campaign:String="",_chapter:String="") -> Error:
	var writer := ZIPPacker.new()
	var result: Error
	result = writer.open(Prefs.fables_location + "/" + title + ".ftt")
	result = writer.start_file("scenes/" + title + ".tres")
	var scene := Scene.new()
	var scene_layer := SceneLayer.new()
	scene.title = title
	scene.description = _description
	scene.created_date_time = Time.get_datetime_dict_from_system()
	scene.updated_date_time = Time.get_datetime_dict_from_system()
	scene_layer.name = "Ground"
	scene.layers.append(scene_layer)
	var temp = FileAccess.create_temp(FileAccess.ModeFlags.READ_WRITE,"",".tres",true)
	var temp_path := temp.get_path_absolute()
	App.temp_files.append(temp_path)
	result = ResourceSaver.save(scene,temp_path)
	writer.write_file(temp.get_buffer(temp.get_length()))
	temp.close()
	if result == Error.OK:
		result = writer.close_file()
	result = writer.close()
	return result


func create_asset(asset_name:String,path:String) -> void:
	var image := Image.new()
	image.load(path)
	var imported_image := Image.new()
	imported_image.copy_from(image)
	var buffer := imported_image.save_webp_to_buffer()
	var filename := current_dir+"/media/"+asset_name+".webp"
	var new_file := FileAccess.open(filename, FileAccess.WRITE_READ)
	new_file.store_buffer(buffer)
	new_file.close()
	var asset := ImageAsset.new()
	asset.texture = current_dir+"/media/"+asset_name+".webp"
	asset.name = asset_name
	ResourceSaver.save(asset,current_dir+"/assets/"+asset_name+".tres")


func pack_current() -> void:
	var zip: ZIPPacker = ZIPPacker.new()
	zip.open(selected_fables[0])
	pack_recursive(zip,current_dir)
	zip.close()


func pack_recursive(zip:ZIPPacker, path:String) -> void:
	var dir:DirAccess = DirAccess.open(path)
	dir.list_dir_begin()
	var current:String = dir.get_next()
	while current != "":
		if dir.current_is_dir():
			await pack_recursive(zip,path+"/"+current)
		else:
			var file:FileAccess = FileAccess.open(path+"/"+current,FileAccess.READ)
			var buffer:PackedByteArray = file.get_buffer(file.get_length())
			zip.start_file((path+"/"+current).trim_prefix(current_dir+"/"))
			zip.write_file(buffer)
			zip.close_file()
		current = dir.get_next()


func delete_recursive(path:String) -> Error:
	var dir:DirAccess = DirAccess.open(path)
	if dir != null:
		dir.list_dir_begin()
		var current:String = dir.get_next()
		while current != "":
			if dir.current_is_dir():
				delete_recursive(path+"/"+current)
				dir.remove(current)
			else:
				dir.remove(current)
			current = dir.get_next()
		dir.list_dir_end()
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		return Error.OK
	else:
		return DirAccess.get_open_error()


func notify(status: App.StatusState, message: String) -> void:
	emit_signal("create_notification",status,message)


func confirm(message:String,title:String="Confirm?",confirm_button:String="Confirm",\
cancel_button:String="Cancel",custom_button:String="",\
custom_button_right:bool=false,custom_action:String="") -> void:
	get_window().gui_embed_subwindows = true
	canvas = CanvasLayer.new()
	
	# Setup background
	var background:Button = Button.new()
	background.theme_type_variation = "SquareButton"
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.pressed.connect(cancel_pressed)
	
	# Setup background shader
	var shader_mat:ShaderMaterial = ShaderMaterial.new()
	var shader:Shader = load("uid://djohlryjdqhop") # menuBlur
	shader_mat.shader = shader
	shader_mat.set_shader_parameter("blur_amount", 2)
	shader_mat.set_shader_parameter("mix_amount", 0.5)
	background.material = shader_mat
	
	# Setup dialog
	var dialog:ConfirmationDialog = ConfirmationDialog.new()
	dialog.dialog_text = message
	dialog.title = title
	dialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dialog.get_label().vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dialog.get_label().autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	
	# Setup dialog buttons
	dialog.ok_button_text = confirm_button
	dialog.cancel_button_text = cancel_button
	if custom_button != "":
		var custom:Button = dialog.add_button(custom_button,custom_button_right,custom_action)
		dialog.custom_action.connect(custom_pressed)
		custom.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	dialog.confirmed.connect(ok_pressed)
	dialog.canceled.connect(cancel_pressed)
	dialog.get_ok_button().mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	dialog.get_cancel_button().mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# Display the popup
	dialog.visible = true
	background.add_child(dialog)
	canvas.add_child(background)
	if get_viewport().get_camera_2d():
		get_viewport().get_camera_2d().add_child(canvas)
	else:
		get_tree().root.add_child(canvas)
	
	# Reset gui_embed_subwindows to default
	get_window().gui_embed_subwindows = ProjectSettings.get_setting("display/window/subwindows/embed_subwindows")


func ok_pressed() -> void:
	canvas.queue_free()
	emit_signal("confirmation",true,"")


func cancel_pressed() -> void:
	emit_signal("confirmation",false,"")
	canvas.queue_free()


func custom_pressed(action:StringName) -> void:
	emit_signal("confirmation",true,action)
	canvas.queue_free()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		for temp in temp_files:
			DirAccess.remove_absolute(temp)
