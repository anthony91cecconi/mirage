extends Node

# Livelli di log_msg con i loro codici ANSI
var configs := {
	"focus":   28,
	"normal":  29,
	"debug":   30,
	"success": 32,
	"warn":    33,
	"error":   31
}

func log_msg(level: String, text: String) -> void:
	var color_code = configs.get(level, 29)
	print(
		_get_header() +
		"\u001b[" + str(color_code) + "m" +
		"[" + level.to_upper() + "] " +
		text +
		"\u001b[0m"
	)


# Alias comodi
func debug(t: String) -> void:
	log_msg("debug", t)

func error(t: String) -> void:
	log_msg("error", t)

func warn(t: String) -> void:
	log_msg("warn", t)

func success(t: String) -> void:
	log_msg("success", t)

func focus(t: String) -> void:
	log_msg("focus", t)

func normal(t: String) -> void:
	log_msg("normal", t)

func _get_header() -> String:
	var now = Time.get_time_dict_from_system()
	var time_str := "%02d:%02d:%02d " % [now.hour, now.minute, now.second]

	var context = _get_debug_context()

	var caller_info := ""

	if context.has("file") and context.has("line"):
		caller_info = "file:%s line:%d " % [
			context["file"],
			context["line"]
		]

	return time_str + caller_info



func _get_debug_context() -> Dictionary:
	var stack = get_stack()
	if stack.size() > 2:
		var frame = stack[2]
		return {
			"file": frame["source"].get_file(),
			"line": frame["line"],
			"function": frame["function"]
		}
	return {}
