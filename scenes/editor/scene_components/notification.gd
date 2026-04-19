extends Control


const info = preload("uid://ftrpbe54yaax")
const success = preload("uid://cbd4iajh4mnjc")
const warning = preload("uid://bmcq8qf76xfb2")
const error = preload("uid://d1qohihsw65kp")


@export var status: App.StatusState:
	set(value):
		status = value
		update()
@export var message: String:
	set(value):
		message = value
		update()


func update() -> void:
	match status:
		App.StatusState.INFO:
			%Status.texture = info
		App.StatusState.SUCCESS:
			%Status.texture = success
		App.StatusState.WARNING:
			%Status.texture = warning
		App.StatusState.ERROR:
			%Status.texture = error
	%Message.text = message


func _on_tree_entered() -> void:
	await get_tree().create_timer(3).timeout
	queue_free()
