extends Resource
class_name Token

#region Metadata
@export_category("Metadata")
@export var version: int = 1
@export var id: String
@export var asset_id: String
#endregion

#region Data
@export_category("Data")
@export_file("*.jpg *.jpeg *.png *.webp") var texture
@export var visible_to_players := true
@export var locked := true
#endregion

#region Transform
@export_category("Transform")
@export var position: Vector2
@export var rotation: float
@export var scale: Vector2 = Vector2.ONE
#endregion
