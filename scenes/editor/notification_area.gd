extends Control


enum StatusState {
	SUCCESS,
	WARNING,
	ERROR
}


const packed_scene := preload("uid://fjjf7rl8cqcp") # Notification


func _ready() -> void:
	App.create_notification.connect(notify)


func notify(status: StatusState, message: String) -> void:
	var new = packed_scene.instantiate()
	new.status = status
	new.message = message
	%NotificationContainer.add_child(new)
