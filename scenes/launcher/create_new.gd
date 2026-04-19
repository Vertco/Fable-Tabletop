extends Node


func _on_canceled() -> void:
	%PopupBackground.visible = false
	%CreateType.current_tab = 0
	%CreateTitle.text = ""
	%CreateDescription.text = ""


func _on_confirmed() -> void:
	%PopupBackground.visible = false
	match %CreateType.current_tab:
		0:
			App.create_scene(%CreateTitle.text,%CreateDescription.text)
			%Fables.load_fables()
	
