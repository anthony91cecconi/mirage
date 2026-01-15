extends Node
class_name HumanModel

# === SPRITE FRAMES (runtime) ===
var helmet_frames: SpriteFrames
var helmet_color_frames: SpriteFrames
var head_frames: SpriteFrames
var head_color_frames: SpriteFrames

# === DATA ===
var weapon: bool
var helmet: bool
var color: Color


# === CONSTRUCTOR ===
func _init(
	_helmet_frames: SpriteFrames,
	_helmet_color_frames: SpriteFrames,
	_head_frames: SpriteFrames,
	_head_color_frames: SpriteFrames,
	_weapon: bool,
	_helmet: bool,
	_color: Color
) -> void:
	helmet_frames = _helmet_frames
	helmet_color_frames = _helmet_color_frames
	head_frames = _head_frames
	head_color_frames = _head_color_frames
	weapon = _weapon
	helmet = _helmet
	color = _color


# === SERIALIZATION (JSON SAFE) ===
func to_dict() -> Dictionary:
	return {
		"helmet_frames": helmet_frames.resource_path,
		"helmet_color_frames": helmet_color_frames.resource_path,
		"head_frames": head_frames.resource_path,
		"head_color_frames": head_color_frames.resource_path,
		"weapon": weapon,
		"helmet": helmet,
		"color": color.to_html(true) # #RRGGBBAA
	}


static func from_dict(d: Dictionary) -> HumanModel:
	return HumanModel.new(
		_load_frames(d.get("helmet_frames", "")),
		_load_frames(d.get("helmet_color_frames", "")),
		_load_frames(d.get("head_frames", "")),
		_load_frames(d.get("head_color_frames", "")),
		d.get("weapon", false),
		d.get("helmet", false),
		Color.from_string(d.get("color", "#ffffffff"), Color.WHITE)
	)


# === UTILS ===
static func _load_frames(path: String) -> SpriteFrames:
	if path.is_empty():
		return null
	return load(path)


# === DEBUG ===
func _to_string() -> String:
	return (
		"HumanModel {\n" +
		"  helmet_frames:        %s\n" % _res_path(helmet_frames) +
		"  helmet_color_frames:  %s\n" % _res_path(helmet_color_frames) +
		"  head_frames:          %s\n" % _res_path(head_frames) +
		"  head_color_frames:    %s\n" % _res_path(head_color_frames) +
		"  weapon:               %s\n" % weapon +
		"  helmet:               %s\n" % helmet +
		"  color:                %s\n" % color.to_html(true) +
		"}"
	)


static func _res_path(res: Resource) -> String:
	if res == null:
		return "null"
	return res.resource_path
