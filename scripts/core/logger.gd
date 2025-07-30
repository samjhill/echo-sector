extends RefCounted
class_name Logger

enum LogLevel {
	DEBUG,
	INFO,
	WARNING,
	ERROR
}

static var current_level: LogLevel = LogLevel.INFO
static var enabled: bool = true

static func debug(message: String, context: String = ""):
	if enabled and current_level <= LogLevel.DEBUG:
		print("[DEBUG]", _format_message(message, context))

static func info(message: String, context: String = ""):
	if enabled and current_level <= LogLevel.INFO:
		print("[INFO]", _format_message(message, context))

static func warning(message: String, context: String = ""):
	if enabled and current_level <= LogLevel.WARNING:
		print("[WARNING]", _format_message(message, context))

static func error(message: String, context: String = ""):
	if enabled and current_level <= LogLevel.ERROR:
		print("[ERROR]", _format_message(message, context))

static func _format_message(message: String, context: String) -> String:
	if context.is_empty():
		return message
	return "[%s] %s" % [context, message]

static func set_level(level: LogLevel):
	current_level = level

static func enable():
	enabled = true

static func disable():
	enabled = false 