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


func close_editor() -> void:
	%Window.hide()
	%AssetEditor.hide()
	%FilePath.text = ""
	%DisplayName.text = ""


func _on_file_picker_pressed() -> void:
	%ImageFileDialog.popup()


func _on_image_file_dialog_file_selected(path: String) -> void:
	%FilePath.text = path
	%DisplayName.text = path.get_file().rsplit(".")[0]


func _on_window_confirmed() -> void:
	if %FilePath.text && %DisplayName.text:
		App.create_asset(%DisplayName.text,%FilePath.text)
		emit_signal("updated")
		close_editor()
