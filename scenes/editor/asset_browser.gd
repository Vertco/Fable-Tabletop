extends FoldableContainer

@onready var asset_entry = preload("uid://5i565bfc7ykb")


var precol_offset: int


func load_assets() -> void:
	for child in %AssetsContainer.get_children():
		child.queue_free()
	if DirAccess.dir_exists_absolute(App.current_dir):
		for asset in DirAccess.get_files_at(App.current_dir+"/assets"):
			var entry := asset_entry.instantiate()
			entry.asset = asset
			#entry.connect("select",%Fables.select)
			#entry.connect("multi_select",%Fables.multi_select)
			entry.connect("open",open_asset_editor)
			%AssetsContainer.add_child(entry)
	#sort_assets()


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
