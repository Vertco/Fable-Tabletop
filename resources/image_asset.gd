extends Asset
class_name ImageAsset

#region Data
@export_category("Data")
@export_file("*.jpg","*.jpeg","*.png","*.webp") var texture
var occluders: Array[OccluderPolygon2D]
var portals: Dictionary[bool,OccluderPolygon2D]
var lights: Array[PointLight2D]
#endregion
