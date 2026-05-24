extends Node


signal fable_changed(new:Resource)


enum Mode{
	EDIT,
	PLAY
}


@onready var scene := preload("uid://t8eala4qk0sq") # scenes/editor/scene_types/scene

@export var fable_path: String:
	set(value):
		fable_path = value
		if load_fable() == Error.OK:
			update_titlebar()
@export var mode := Mode.EDIT:
	set(value):
		match typeof(value):
			TYPE_INT:
				mode = value as Mode
			TYPE_STRING:
				mode = Mode.find_key(value) as Mode
		update_titlebar()
@export var fable: Resource:
	set(value):
		emit_signal("fable_changed",value)
		fable = value


func _ready() -> void:
	update_cull_mask(App.active_layer, App.visible_layers)
	App.layers_changed.connect(update_cull_mask)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	%FableMenu.get_popup().connect("id_pressed",_on_fable_menu_id_pressed)
	%GmView.world_2d = %SceneRoot.get_world_2d()
	%PcView.world_2d = %SceneRoot.get_world_2d()
	if App.selected_fables:
		fable_path = App.selected_fables[0]


func update_cull_mask(_active_layer: int, _visible_layers: Array[int]):
	%SceneRoot.set_canvas_cull_mask(0)
	%SceneRoot.set_canvas_cull_mask_bit(0, true)
	for layer in _visible_layers:
		%SceneRoot.set_canvas_cull_mask_bit(layer, true)


func load_fable() -> Error:
	var result := Error.OK
	var current: DirAccess
	current = DirAccess.open("user://")
	if !App.recover:
		# Unpack ftt file
		result = current.make_dir("current")
		if !result:
			current.change_dir("current")
			var path_file := FileAccess.open(App.current_dir + "\\path",FileAccess.WRITE)
			path_file.store_string(fable_path)
			path_file.close()
			var reader := ZIPReader.new()
			result = reader.open(fable_path)
			if !result:
				for file in reader.get_files():
					if current.dir_exists(file.get_base_dir()):
						if !file.ends_with("/"):
							var file_access := FileAccess.open("user://current/" + file,FileAccess.WRITE)
							if file_access == null:
								print(error_string(FileAccess.get_open_error()))
							var data:PackedByteArray = reader.read_file(file)
							file_access.store_buffer(data)
					else:
						current.make_dir_recursive(file.get_base_dir())
						if !file.ends_with("/"):
							var file_access := FileAccess.open("user://current/" + file,FileAccess.WRITE)
							if file_access == null:
								print(error_string(FileAccess.get_open_error()))
							var data:PackedByteArray = reader.read_file(file)
							file_access.store_buffer(data)
				load_fable_resources(current)
	else:
		current.change_dir("current")
		load_fable_resources(current)
	return result


func load_fable_resources(current:DirAccess) -> void:
	var result = validate_fable()
	if !result:
		if current.file_exists("campaign.tres"):
			print("This fable is a campaign!") #TODO implement campaign loading
		elif current.file_exists("scenes/"+App.selected_fables[0].get_file().rsplit(".")[0]+".tres"):
			fable = ResourceLoader.load("user://current/scenes/"+App.selected_fables[0].get_file().rsplit(".")[0]+".tres")
			var new_scene := scene.instantiate()
			new_scene.scene = fable
			%GmCam.offset = fable.gm_cam_pos
			%GmCam.zoom = Vector2(fable.gm_cam_zoom,fable.gm_cam_zoom)
			%GmViewport.gm_zoom = fable.gm_cam_zoom
			%PcCam.offset = fable.pc_cam_pos
			update_pc_zoom(Prefs.pc_zoom)
			%SceneRoot.add_child(new_scene)
			%AssetBrowser.load_assets()
			%SceneTree.scene = new_scene


func save_fable() -> void: # TODO Add support for campaigns
	var new_scene := Scene.new()
	for layer in %SceneRoot.get_node("Scene/LayerManager").get_children():
		new_scene.layers.append(layer.save())
	new_scene.title = fable.title
	new_scene.updated_date_time = Time.get_datetime_dict_from_system()
	new_scene.gm_cam_pos = %GmCam.offset
	new_scene.gm_cam_zoom = %GmCam.zoom.x
	new_scene.pc_cam_pos = %PcCam.offset
	var current := DirAccess.open("user://current")
	if current.file_exists("scenes/"+new_scene.title+".tres"):
		DirAccess.remove_absolute("user://current/scenes/"+new_scene.title+".tres")
		ResourceSaver.save(new_scene,"user://current/scenes/"+new_scene.title+".tres")
	App.pack_current()


func validate_fable() -> Error:
	const dirs := [
		"scenes",
		"media",
		"assets"
	]
	var result := Error.OK
	var current: DirAccess
	current = DirAccess.open("user://current")
	for dir in dirs:
		if !current.dir_exists(dir):
			var make_err := current.make_dir(dir)
			if make_err != Error.OK:
				result = make_err
				printerr("Couldn't create " + dir + " in current dir.")
	return result


func update_titlebar(_id:int = 0) -> void:
	DisplayServer.window_set_title("Fable Tabletop | " + App.selected_fables[0].get_file().rsplit(".")[0] + \
	" - " + %ModeSelector.get_tab_title(%ModeSelector.current_tab))


func update_pc_zoom(size:Vector2) -> void:
	print(size)
	if size != Vector2(0,0):
		%PcCam.zoom = Vector2((%PcWindow.get_visible_rect().size*0.0508)/size)


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		App.confirm("Save changes to this fable?","Save Changes?",\
		"Save","Cancel","Discard",true,"discard")
		var confirm = await App.confirmation
		if confirm[0]:
			if confirm[1] == &"discard":
				App.delete_recursive(App.current_dir)
				get_tree().quit()
			else:
				save_fable()
				App.delete_recursive(App.current_dir)
				get_tree().quit()


func _on_mode_selector_tab_changed(tab: int) -> void:
	@warning_ignore("int_as_enum_without_cast")
	mode = tab


func _on_fable_menu_id_pressed(id: int) -> void:
	match id:
		3:
			App.confirm("Save changes to this fable?","Save Changes?",\
			"Save","Cancel")
			var confirm = await App.confirmation
			if confirm[0]:
				save_fable()
				App.notify(App.StatusState.SUCCESS, "Sucsesfully saved!")
