# Posts GameState.metrics to a Google Form text field on quit.
extends Node

const _SUBMIT_URL: String = "https://docs.google.com/forms/d/e/1FAIpQLScMGJIJu02ZO4R8zKH4wQ28QkRCaF6qLVbZhRdTUpqwKrHVTw/formResponse"
const _SUBMIT_FIELD: String = "entry.932053024"

# When running inside an iframe on the website, post a message so the host page can route back to /.
const NOTIFY_QUIT_JS: String = "if (window.parent && window.parent !== window) { window.parent.postMessage({ type: 'game-quit' }, '*'); }"

var _http: HTTPRequest
var _open_log_on_quit: bool = false


func _ready() -> void:
	if _SUBMIT_URL.is_empty() or _SUBMIT_FIELD.is_empty():
		return
	# Intercept the window close so we can submit asynchronously before quitting.
	get_tree().auto_accept_quit = false
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_submit_complete)

	if OS.is_debug_build():
		var section: VBoxContainer = Debug.add_section("Event Logger")
		Debug.add_checkbox(
			"Open metrics in tmp file on quit",
			_open_log_on_quit,
			func(p): _open_log_on_quit = p,
			section,
		)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		submit_and_quit()


func submit_and_quit() -> void:
	var ts_ended: float = Time.get_unix_time_from_system()
	GameState.metrics.session.ts_ended = ts_ended
	GameState.metrics.session.ts_duration = ts_ended - GameState.metrics.session.ts_started

	var payload: Dictionary = GameState.metrics.to_dict()

	if _open_log_on_quit:
		_dump_to_tmp(payload)

	if _http == null:
		_quit_now()
		return
	var body: String = "%s=%s" % [_SUBMIT_FIELD, JSON.stringify(payload, "\t").uri_encode()]
	var headers: PackedStringArray = ["Content-Type: application/x-www-form-urlencoded"]
	var err: int = _http.request(_SUBMIT_URL, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		push_error("EventLogger: submit failed (err %d)" % err)
		_quit_now()


func _dump_to_tmp(payload: Dictionary) -> void:
	var path: String = OS.get_cache_dir().path_join("educational_game_metrics_%d.json" % int(Time.get_unix_time_from_system()))
	var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("EventLogger: could not write %s" % path)
		return
	f.store_string(JSON.stringify(payload, "\t"))
	f.close()
	print("EventLogger: dumped metrics to %s" % path)
	OS.shell_open(path)


func _on_submit_complete(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	print("EventLogger: submit complete (result=%d, code=%d)" % [result, response_code])
	_quit_now()


func _quit_now() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval(NOTIFY_QUIT_JS, true)
	get_tree().quit()
