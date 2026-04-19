@tool
extends Control

func _on_tab_changed(tab: int) -> void:
	match tab:
		0:
			%MapsCampaigns.visible = true
			%AssetLibrary.visible = false
		1:
			%MapsCampaigns.visible = false
			%AssetLibrary.visible = true
