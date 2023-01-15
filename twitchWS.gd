extends Node

@onready var peepos = get_tree().get_nodes_in_group("peepos")
@onready var dc_text = get_node('/root/main/disconnect_text')
@onready var acvoice
@onready var timer = $Timer

var tts_active = false

var ip = "ws://irc-ws.chat.twitch.tv:80"

var nick = "justinfan" + str(randi_range(1001,9999))
var password = 'randomstring' # use oauth if not using readonly justinfan# login
#var nick = "xhiggy"
#var password = 'oauth:ID' # use oauth if not using readonly justinfan# login
var channel = "#xhiggy"

var client
var _login_sent = false
var split_str = "PRIVMSG " + channel + " :"

var msg_queue = []
var talking_peepo
var talking = 0
var wait_time = 1.2

func _ready():
	randomize()
	client = WebSocketPeer.new()
	print(client.connect_to_url(ip))
	timer.wait_time = wait_time

func send_login():
	_login_sent = true
	print('sending login')
	if password != "":
		client.send_text(("PASS "+ password + "\n"))
	#client.put_data(("USER "+ nick +" "+ nick +" "+ nick +" :TEST\n").to_utf8_buffer())
	client.send_text(("NICK "+ nick + "\n"))
	client.send_text(("JOIN "+ channel + "\n"))
	print(client.get_ready_state())

func _process(_delta):
	var state = client.get_ready_state()
	
	client.poll()

	if state == WebSocketPeer.STATE_OPEN:
		if not _login_sent:
			send_login()
		while client.get_available_packet_count():
			# print("Packet: ", client.get_packet().get_string_from_utf8())
			var pkt = client.get_packet().get_string_from_utf8()
			if split_str in pkt:
				var msg = pkt.split(split_str)[1]
				msg_queue.append(msg)
				print(msg)
			elif pkt.contains('PING'):
				#print(pkt)
				var pong = pkt.replace('PING','PONG')
				client.send_text(pong)
			else:
				#print(pkt)
				pass
				
				
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = client.get_close_code()
		var reason = client.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		dc_text.visible = true
		
		set_process(false) # Stop processing.
		
	if len(msg_queue) > 0 and talking == 0 and timer.is_stopped():
		var tts_msg = msg_queue.pop_at(0)
		talking = 1
		talking_peepo = peepos[randi_range(0,len(peepos)-1)]
		
		acvoice = talking_peepo.get_node("ACVoicebox")
		acvoice.base_pitch = randf_range(2.5,4.5)
		acvoice.play_string(tts_msg)
		
		talking_peepo.text_to_speech(1,tts_msg)
		
		


func _on_ac_voicebox_finished_phrase():
	talking_peepo.text_to_speech(0,"")
	talking_peepo.change_phoneme(0)
	talking = 0
	timer.start()
	


func _on_timer_timeout():
	timer.stop()
	timer.wait_time = wait_time
