extends Resource
class_name Campaign

#region Metadata
@export_category("Metadata")
@export var version: String = ProjectSettings.get_setting("application/config/version")
@export var favorite := false
@export var title: String
@export_multiline("Description") var description: String
@export var chapters: Dictionary[String, PackedStringArray]
var created_date_time: Dictionary[String,int]
var updated_date_time: Dictionary[String,int]
#endregion
