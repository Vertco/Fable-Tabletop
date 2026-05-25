extends Node


signal prefs_updated(pref:String)


const defaults:Dictionary[String,Variant] = {
	"fables_location": null,
	"assets_location": "user://assets",
	"pc_grid": true
}


var initialized := false
var prefs_file := "user://preferences.tres"


@export_global_dir var fables_location: String:
	set(value):
		fables_location = value
		if initialized:
			save_prefs({"fables_location": value})
		emit_signal("prefs_updated","fables_location")
@export_global_dir var assets_location: String = "user://assets":
	set(value):
		assets_location = value
		if initialized:
			save_prefs({"assets_location": value})
		emit_signal("prefs_updated","assets_location")
@export var pc_zoom:Vector2:
	set(value):
		pc_zoom = value
		if initialized:
			save_prefs({"pc_zoom": value})
		emit_signal("prefs_updated","pc_zoom")
@export var pc_grid:bool:
	set(value):
		pc_grid = value
		if initialized:
			save_prefs({"pc_grid": value})
		emit_signal("prefs_updated","pc_grid")


func _ready() -> void:
	var result := load_prefs()
	if result == Error.OK:
		initialized = true


func load_prefs() -> Error:
	var new_prefs := Preferences.new()
	if FileAccess.file_exists(prefs_file):
		new_prefs = ResourceLoader.load(prefs_file)
	for pref in new_prefs.preferences.keys():
		if pref in self:
			set(pref, new_prefs.preferences[pref])
		else:
			push_error("Preference key \"" + pref + "\" not found, skipping.")
	return Error.OK


func save_prefs(pref:Dictionary[String,Variant]) -> void:
	var new_prefs := Preferences.new()
	if FileAccess.file_exists(prefs_file):
		new_prefs = ResourceLoader.load(prefs_file)
	new_prefs.preferences.merge(pref,true)
	ResourceSaver.save(new_prefs,prefs_file)
