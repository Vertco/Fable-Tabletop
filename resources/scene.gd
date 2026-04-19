extends Resource
class_name Scene

#region Metadata
@export_category("Metadata")
@export var version: String = ProjectSettings.get_setting("application/config/version")
@export var favorite := false
@export var title: String
@export_multiline("Description") var description: String
@export var scene_preview: Texture2D
@export var created_date_time: Dictionary
@export var updated_date_time: Dictionary
#endregion

#region Data
@export_category("Data")
@export var assets: Dictionary[String,Asset]
@export var layers: Array[SceneLayer]
@export var ground_layer: int = 0
@export var active_layer: int = 0
#endregion
