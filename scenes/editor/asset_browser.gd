extends FoldableContainer

@onready var asset_entry = preload("uid://5i565bfc7ykb")


var precol_offset: int
var focused := false


func load_assets() -> void:
	for child in %AssetsContainer.get_children():
		child.queue_free()
	if DirAccess.dir_exists_absolute(App.current_dir):
		for asset in DirAccess.get_files_at(App.current_dir+"/assets"):
			var entry := asset_entry.instantiate()
			entry.asset = asset
			entry.connect("single_select", select_asset)
			entry.connect("multi_select", multi_select)
			entry.connect("open",open_asset_editor)
			entry.connect("delete",delete_asset)
			%AssetsContainer.add_child(entry)
	filter_assets()


func filter_assets(_new_text = null) -> void:
	var filter:String = %AssetsFilter.text
	var children := %AssetsContainer.get_children()
	for child in children:
		if filter:
			if child.data.name.containsn(filter):
				child.set_visible(true)
				if child.data.name.to_lower() == filter.to_lower():
					child.select()
			else:
				child.set_visible(false)
		else:
			child.set_visible(true)


func _on_folding_changed(fold_state: bool) -> void:
	if fold_state:
		@warning_ignore("narrowing_conversion")
		precol_offset = size.y
		custom_minimum_size.y = 0
		get_parent_control().split_offsets = [0]
	else:
		custom_minimum_size.y = 221
		get_parent_control().split_offsets = [-precol_offset]


func open_asset_editor(asset:Asset = null) -> void:
	if asset == null:
		$AssetEditor/Background/Window.title = "Create new asset"
	else:
		%AssetEditor.title = "Edit " + asset.get_script().get_global_name()
		%AssetEditor.file_path = asset.texture
		%AssetEditor.display_name = asset.name
	%AssetEditor.show()
	$AssetEditor/Background/Window.popup()


func select_asset(asset:Node) -> void:
	get_tree().call_group("selected_asset_entries","deselect")
	asset.select()


func multi_select(asset:Node) -> void:
	if asset.is_in_group("selected_asset_entries"):
		asset.deselect()
	else:
		asset.select()


func delete_asset(entry:Node) -> void:
	var asset:String = entry.asset
	var texture:String = entry.data.texture
	DirAccess.remove_absolute(App.current_dir+"/assets/"+asset)
	DirAccess.remove_absolute(texture)
	load_assets()


func _unhandled_input(event: InputEvent) -> void:
	if focused:
		if event.is_action_released("ui_delete"):
			for asset in get_tree().get_nodes_in_group("selected_asset_entries"):
				delete_asset(asset)
		elif event.is_action_released("ui_cancel"):
			get_tree().call_group("selected_asset_entries","deselect")


func _on_mouse_entered() -> void:
	focused = true


func _on_mouse_exited() -> void:
	focused = false


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action("ui_select"):
		get_tree().call_group("selected_asset_entries","deselect")
