extends Resource
class_name SceneLayer

enum GridOptions {
	NONE,
	VISIBLE,
	FULL
}

#region Metadata
@export_category("Metadata")
@export var version: String = ProjectSettings.get_setting("application/config/version")
@export var id: String
@export var name: String
@export var active: bool
@export var gm_vis: bool
@export var player_vis: bool
#endregion

#region Data
@export_category("Data")
@export var assets: Array[AssetInstance] = []
#endregion
