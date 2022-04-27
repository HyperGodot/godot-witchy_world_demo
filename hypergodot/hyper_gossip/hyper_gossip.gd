extends Node

class_name HyperGossip

const LRU = preload("../utils/lru.gd")

signal listening(extension_name)
signal event(type, data, from)
signal peers(peers)

export var url = "hyper://blog.mauve.moe/"
export var extension_name = "hyper-gossip-v1"
export var pool_size = 8
export var queue_warning_size = 8

var hyperGateway : HyperGateway

var peerListRequest = HyperRequest.new()
var eventSource = HyperEventSource.new()

# Pool of HyperRequest objects to send multiple broadcasts at once
var requestPool = []
# Queue of requests that should be sent out
var requestQueue = []
# Track whether we have warned about sending more requests than can be handled
var hasWarnedCapacity = false
var seen_messages = LRU.new()

func _ready():
	randomize()
	
	add_child(peerListRequest)
	peerListRequest.connect("request_completed", self, "_on_peer_list")
	peerListRequest.use_threads = true

	for _i in range(pool_size):
		var broadcastRequest = HyperRequest.new()
		broadcastRequest.use_threads = true
		add_child(broadcastRequest)
		broadcastRequest.connect("request_completed", self, "_on_broadcast_completed")
		requestPool.push_back(broadcastRequest)

	add_child(eventSource)
	eventSource.connect("event", self, "_on_event")
	eventSource.connect("response_started", self, "_on_events_started")

func start_listening():
	load_peers()
	eventSource.request(_get_extension_listen_url())

func _on_events_started(_statusCode, _responseHeaders):
	emit_signal("listening", extension_name)

func _enqueue_broadcast_request(reqURL, body):
	var broadcastRequest = _get_next_request()
	if broadcastRequest == null:
		print('Queueing')
		requestQueue.push_back({"reqURL": reqURL, "body": body})
		if requestQueue.size() > queue_warning_size && !hasWarnedCapacity:
			hasWarnedCapacity = true
			print_debug("Warning: You have more gossip events than your queue_warning_size permits, either slow down the rate or increase the pool_size to send more");
		return

	broadcastRequest.request(reqURL, [], false, HTTPClient.METHOD_POST, body)	

func _get_next_request():
	for request in requestPool:
		var status = request.get_http_client_status()
		if status == HTTPClient.STATUS_DISCONNECTED:
			return request
	return null

func _on_broadcast_completed(_result, _response_code, _headers, _body):
	if requestQueue.size() == 0: return
	var next = requestQueue.pop_front()
	_enqueue_broadcast_request(next.reqURL, next.body)

func rebroadcast(event):
	var reqURL = _get_extension_url()
	var body = JSON.print(event)
	_enqueue_broadcast_request(reqURL, body)

func broadcast_event(type: String, data):
	if(hyperGateway == null):
		# TODO : Make the link to HyperGateway static
		hyperGateway = get_tree().get_current_scene().get_node("HyperGodot").get_node("HyperGateway")
	if(hyperGateway != null):
		if( hyperGateway.getIsGatewayRunning() ):
			var reqURL = _get_extension_url()
			var body = JSON.print(_generateEvent(type, data))
			_enqueue_broadcast_request(reqURL, body)
	
func send_to_peer(peer, type, data):
	var reqURL = _get_extension_url_to_peer(peer)
	var body = JSON.print(_generateEvent(type, data))
	_enqueue_broadcast_request(reqURL, body)

func load_peers():
	var reqURL = _get_extension_url()
	peerListRequest.request(reqURL)

func _generateEvent(type, data):
	var id = _make_id()
	seen_messages.track(id)
	return {
		"id": id,
		"type": type,
		"data": data
	}

func _handle_event(event):
	var type = event.type
	var data = event.data
	var id = event.id
	var from = event.from
	
	if seen_messages.has(id):
		return
	
	seen_messages.track(id)
	
	emit_signal("event", type, data, from)
	rebroadcast(event)

func _on_event(data, event, id):
	# Ignore events for other extensions
	if event != extension_name: return

	var parsed = JSON.parse(data)
	
	if parsed.error != OK:
		printerr("Unable to parse EventSource content " + parsed.error_line + "\n" + data)
		return
	
	var result = parsed.result
	if !("from" in result):
		result.from = id

	_handle_event(result)
	

func _on_peer_list(_result, response_code, _headers, body):
	var text = body.get_string_from_utf8()
	if response_code != 200:
		printerr('Error listing peers ', response_code, " ", text)
		return

	var parsed = JSON.parse(text)

	if parsed.error != OK:
		printerr("Unable to parse Peer List" + String(parsed.error_line))
		return
		
	var peers = parsed.result

	emit_signal("peers", peers)

func _get_extension_url_to_peer(peer):
	return url + '$/extensions/' + extension_name + '/' + peer

func _get_extension_url():
	return url + '$/extensions/' + extension_name

func _get_extension_listen_url():
	return url + '$/extensions/'
	
func _get_url() -> String:
	return url

func _make_id():
	return str(randi()) + str(randi())
