extends Node
class_name HumanModel

# === SPRITE FRAMES (runtime) ===
var helmet_normal_frames: SpriteFrames
var helmet_normal_color_frames: SpriteFrames
var head_normal_frames: SpriteFrames
var head_normal_color_frames: SpriteFrames

# === DATA ===
var weapon: bool
var helmet: bool
var color: Color


# === CONSTRUCTOR ===
func _init(
	_helmet_normal_frames: SpriteFrames,
	_helmet_normal_color_frames: SpriteFrames,
	_head_normal_frames: SpriteFrames,
	_head_normal_color_frames: SpriteFrames,
	_weapon: bool,
	_helmet: bool,
	_color: Color
) -> void:
	helmet_normal_frames = _helmet_normal_frames
	helmet_normal_color_frames = _helmet_normal_color_frames
	head_normal_frames = _head_normal_frames
	head_normal_color_frames = _head_normal_color_frames
	weapon = _weapon
	helmet = _helmet
	color = _color


# === SERIALIZATION (JSON SAFE) ===
func to_dict() -> Dictionary:
	return {
		"helmet_normal_frames": helmet_normal_frames.resource_path,
		"helmet_normal_color_frames": helmet_normal_color_frames.resource_path,
		"head_normal_frames": head_normal_frames.resource_path,
		"head_normal_color_frames": head_normal_color_frames.resource_path,
		"weapon": weapon,
		"helmet": helmet,
		"color": color.to_html(true) # #RRGGBBAA
	}


static func from_dict(d: Dictionary) -> HumanModel:
	return HumanModel.new(
		_load_frames(d.get("helmet_normal_frames", "")),
		_load_frames(d.get("helmet_normal_color_frames", "")),
		_load_frames(d.get("head_normal_frames", "")),
		_load_frames(d.get("head_normal_color_frames", "")),
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
		"  helmet_normal_frames:        %s\n" % _res_path(helmet_normal_frames) +
		"  helmet_normal_color_frames:  %s\n" % _res_path(helmet_normal_color_frames) +
		"  head_normal_frames:          %s\n" % _res_path(head_normal_frames) +
		"  head_normal_color_frames:    %s\n" % _res_path(head_normal_color_frames) +
		"  weapon:               %s\n" % weapon +
		"  helmet:               %s\n" % helmet +
		"  color:                %s\n" % color.to_html(true) +
		"}"
	)


static func _res_path(res: Resource) -> String:
	if res == null:
		return "null"
	return res.resource_path
