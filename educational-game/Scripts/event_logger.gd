# Event log for user-interaction telemetry.
# On game close, the log is POSTed to a Google Form text field.


extends Node

const _SUBMIT_URL: String = "https://docs.google.com/forms/d/e/1FAIpQLScMGJIJu02ZO4R8zKH4wQ28QkRCaF6qLVbZhRdTUpqwKrHVTw/formResponse"
const _SUBMIT_FIELD: String = "entry.932053024"

var _buffer: PackedStringArray = PackedStringArray()
var _http: HTTPRequest


func _ready() -> void:
	record("session_start", {"debug": OS.is_debug_build()})

	if _SUBMIT_URL.is_empty() or _SUBMIT_FIELD.is_empty():
		return
	# Intercept the window close so we can submit asynchronously before quitting.
	get_tree().auto_accept_quit = false
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_submit_complete)


## Append an event to the session log. any data can be added to the 'data' dictionary
func record(event: String, data: Dictionary = {}) -> void:
	var entry := {
		"ts": Time.get_unix_time_from_system(),
		"event": event,
	}
	if not data.is_empty():
		entry["data"] = data
	_buffer.append(JSON.stringify(entry))
	# print("event '%s'" % event)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		submit_and_quit()


## Submit the buffered log and quit.
func submit_and_quit() -> void:
	record("session_end")
	if _http == null:
		get_tree().quit()
		return
	var body_payload: String = "\n".join(_buffer)
	var body: String = "%s=%s" % [_SUBMIT_FIELD, body_payload.uri_encode()]
	var headers: PackedStringArray = ["Content-Type: application/x-www-form-urlencoded"]
	var err: int = _http.request(_SUBMIT_URL, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		push_error("EventLogger: submit request failed (err %d)" % err)
		get_tree().quit()


func _on_submit_complete(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	print("EventLogger: submit complete (result=%d, code=%d)" % [result, response_code])
	get_tree().quit()
