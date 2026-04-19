extends Control


func _on_donate_pressed() -> void:
	OS.shell_open("https://www.paypal.com/donate/?hosted_button_id=PLM7Q4RRJK48N")
