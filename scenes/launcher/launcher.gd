extends Control


func _ready() -> void:
	DisplayServer.window_set_title("Fable Tabletop | Launcher")


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()
