extends Node


signal updated()


var title: String:
	set(value):
		title = value
		%Window.title = value
var file_path: String:
	set(value):
		file_path = value
		%FilePath.text = value
var display_name: String:
	set(value):
		display_name = value
		%DisplayName.text = value
var pps: float:
	set(value):
		pps = value
		if pps:
			%Scaled.button_pressed = true
			%PPS.value = pps
		else:
			%Scaled.button_pressed = false
			%PPS.value = 0
var asset: Asset


func show() -> void:
	if asset == null:
		title = "Create new asset"
	else:
		title = "Edit " + asset.get_script().get_global_name()
		file_path = asset.texture
		display_name = asset.name
		pps = asset.pps
	self.visible = true
	%Window.popup()


func close_editor() -> void:
	%Window.hide()
	%AssetEditor.hide()
	%FilePath.text = ""
	%DisplayName.text = ""
	%PPS.value = 10
	asset = null


func _on_file_picker_pressed() -> void:
	%ImageFileDialog.popup()


func _on_image_file_dialog_file_selected(path: String) -> void:
	%FilePath.text = path
	%DisplayName.text = path.get_file().rsplit(".")[0]
	Prefs.import_location = %ImageFileDialog.current_dir


func _on_window_confirmed() -> void:
	if %FilePath.text && %DisplayName.text:
		App.create_asset(%DisplayName.text, %FilePath.text, %PPS.value, asset)
		emit_signal("updated")
		asset = null
		close_editor()


func _on_scaled_toggled(toggled_on: bool) -> void:
	if toggled_on:
		%Scaled.text = "Scaled"
		%PpsSpacer.visible = true
		%PpsContainer.visible = true
	else:
		%Scaled.text = "Not scaled"
		%PpsSpacer.visible = false
		%PpsContainer.visible = false


func _on_window_about_to_popup() -> void:
	%ImageFileDialog.current_dir = Prefs.import_location
