extends Asset
class_name ImageAsset

#region Data
@export_category("Data")
@export_file("*.jpg","*.jpeg","*.png","*.webp") var texture
@export_range(10, 1024, 0.1, "suffic:PPS") var pps: float
@export var occluders: Array[OccluderPolygon2D]
@export var portals: Dictionary[bool,OccluderPolygon2D]
var lights: Array[PointLight2D]
#endregion
