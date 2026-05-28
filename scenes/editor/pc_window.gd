extends Window


func _ready() -> void:
	on_prefs_updated("pc_desk")
	Prefs.connect("prefs_updated",on_prefs_updated)


func on_prefs_updated(pref:String) -> void:
	match pref:
		"pc_desk":
			if Prefs.pc_desk:
				%PcDeskLeft.visible = true
				%PcDeskRight.visible = true
				var pc_width := Prefs.pc_zoom.x
				var multiplier := size.x/pc_width
				%PcDeskLeft.size = Vector2(Prefs.pc_desk*multiplier, size.y)
				%PcDeskLeft.position = Vector2.ZERO
				%PcDeskRight.size = Vector2(Prefs.pc_desk*multiplier, size.y)
				%PcDeskRight.position = Vector2(size.x - Prefs.pc_desk*multiplier,0)
			else:
				%PcDeskLeft.visible = false
				%PcDeskRight.visible = false


func _on_visibility_changed() -> void:
	on_prefs_updated("pc_desk")
