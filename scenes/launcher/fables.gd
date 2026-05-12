extends Control


@export var selected: Array[Node]


@onready var campaign_entry = preload("uid://ccqsgmlmewjh4")


func _ready() -> void:
	%Version.text = "v" + ProjectSettings.get_setting("application/config/version")
	Prefs.prefs_updated.connect(prefs_updated)
	App.recover = false
	if Prefs.fables_location:
		load_fables()
	else:
		%FablesBrowser.popup()
	check_recovery()


func check_recovery() -> void:
	if DirAccess.dir_exists_absolute(App.current_dir):
		App.confirm("Found a previous fable.
		Recover this fable?",\
		"Recover previous?","Recover","Ignore")
		var confirm = await App.confirmation
		if confirm[0] == true:
			var ftt:String = FileAccess.get_file_as_string(App.current_dir + "\\path")
			App.selected_fables.clear()
			App.selected_fables.append(ftt)
			App.recover = true
			get_tree().change_scene_to_file("uid://di4shqeay3pxf")
		else:
			App.delete_recursive(App.current_dir)


func prefs_updated(pref:String) -> void:
	match pref:
		"fables_location":
			update_fables_location()


func update_fables_location() -> void:
	%FablesBrowser.current_dir = Prefs.fables_location
	%FableLocation.text = Prefs.fables_location


func load_fables() -> Error:
	%FableLocation.text = Prefs.fables_location
	%FablesBrowser.current_dir = Prefs.fables_location
	for child in %FttList.get_children():
		child.queue_free()
	if DirAccess.dir_exists_absolute(Prefs.fables_location):
		for ftt in DirAccess.get_files_at(Prefs.fables_location):
			if ftt.get_extension() == "ftt":
				var fable_entry := campaign_entry.instantiate()
				fable_entry.ftt = Prefs.fables_location + "/" + ftt
				fable_entry.connect("select",%Fables.select)
				fable_entry.connect("multi_select",%Fables.multi_select)
				fable_entry.connect("open",%Fables.open)
				%FttList.add_child(fable_entry)
	sort_fables()
	return Error.OK


func sort_fables() -> void:
	var fables := %FttList.get_children()
	match %SortOption.selected:
		0:
			fables.sort_custom(sort_edited)
		1:
			fables.sort_custom(sort_title)
		2:
			fables.sort_custom(sort_path)
	for child in fables:
		%FttList.move_child(child, %FttList.get_child_count())


func filter_fables(filter:String) -> void:
	var fables := %FttList.get_children()
	for fable in fables:
		if filter:
			if fable.data:
				if fable.data.title.containsn(filter) || fable.data.description.containsn(filter):
					fable.show()
				else:
					fable.hide()
			else:
				if fable.ftt.containsn(filter):
					fable.show()
				else:
					fable.hide()
		else:
			fable.show()


func sort_edited(a, b) -> bool:
	var atime:int
	var btime:int
	if a.data:
		atime = Time.get_unix_time_from_datetime_dict(a.data.updated_date_time)
	else:
		return false
	if b.data:
		btime = Time.get_unix_time_from_datetime_dict(b.data.updated_date_time)
	else:
		return true
	return atime > btime
		


func sort_title(a, b) -> bool:
	var atitle:String
	var btitle:String
	if a.data:
		atitle = a.data.title
	else:
		return false
	if b.data:
		btitle = b.data.title
	else:
		return true
	return atitle < btitle


func sort_path(a, b) -> bool:
	return a.ftt < b.ftt


func select(node:Node) -> void:
	for ftt in %FttList.get_children():
		if ftt == node:
			if selected.size() > 1:
				ftt.selected = true
			else:
				ftt.selected = !ftt.selected
			if ftt.selected:
				selected.clear()
				selected.append(ftt)
				selection_changed(selected)
			else:
				selected.erase(ftt)
				selection_changed(selected)
		else:
			ftt.selected = false


func multi_select(node:Node) -> void:
	node.selected = !node.selected
	if node.selected:
		selected.append(node)
		selection_changed(selected)
	else:
		selected.erase(node)
		selection_changed(selected)


func deselect() -> void:
	for ftt in %FttList.get_children():
		ftt.selected = false
	selected.clear()
	selection_changed(selected)


func open(node:Node) -> void:
	selected.clear()
	selected.append(node)
	selection_changed(selected)
	_on_edit_pressed()


func selection_changed(selection:Array[Node]) -> void:
	App.selected_fables = selection
	if selection.size() == 1:
		%Edit.disabled = false
		#%Play.disabled = false
		#%Rename.disabled = false
		#%Tags.disabled = false
		%Remove.disabled = false
	elif selection.size() == 0:
		%Edit.disabled = true
		#%Play.disabled = true
		#%Rename.disabled = true
		#%Tags.disabled = true
		%Remove.disabled = true
	else:
		%Edit.disabled = true
		#%Play.disabled = true
		#%Rename.disabled = true
		#%Tags.disabled = false
		%Remove.disabled = false


func _on_reload_pressed() -> void:
	load_fables()


func _on_create_pressed() -> void:
	%PopupBackground.visible = true
	%CreateNew.popup()


func _on_select_folder_pressed() -> void:
	%fablesBrowser.show()


func _on_sort_option_item_selected(_index: int) -> void:
	sort_fables()


func _on_campaigns_browser_dir_selected(dir: String) -> void:
	Prefs.fables_location = dir
	load_fables()


func _on_remove_pressed() -> void:
	var message := "Delete " + str(selected.size()) + " items?"
	App.confirm(message,"Delete?")
	var confirm = await App.confirmation
	if confirm[0] == true:
		for item in selected:
			DirAccess.remove_absolute(item.ftt)
		load_fables()
	print(confirm)


func _on_donate_pressed() -> void:
	OS.shell_open("https://www.paypal.com/donate/?hosted_button_id=PLM7Q4RRJK48N")


func _on_fables_location_pressed() -> void:
	OS.shell_show_in_file_manager(Prefs.fables_location)


func _on_edit_pressed() -> void:
	get_tree().change_scene_to_file("uid://di4shqeay3pxf")


func _on_scroll_container_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_select"):
		deselect()
