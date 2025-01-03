extends Control
class_name NakamaMultiplayer

var session : NakamaSession
var client : NakamaClient
var socket : NakamaSocket
var Match
var multiplayerBridge

func _process(delta: float) -> void:
	pass
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	client = Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http")
	
	pass

func updateUserInfo(username, displayname, avatarurl = "", language = "en", location = "us", timezone = "est"):
	await client.update_account_async(session, username, displayname, avatarurl, language, location, timezone)

func onMatchPresence(presence : NakamaRTAPI.MatchPresenceEvent):
	print(presence)
	
func onMatchState(state : NakamaRTAPI.MatchData):
	print(state)

func onSocketConnected():
	print("socket connected")
	
func onSocketClosed():
	print("socket closed")
	
func onSocketReceivedError(err):
	print("Socket error: " + str(err))

# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_login_button_button_down() -> void:
	session = await client.authenticate_email_async($Panel2/EmailInput.text , $Panel2/PasswordInput.text)
	socket = Nakama.create_socket_from(client)
	
	await socket.connect_async(session)
	
	socket.connected.connect(onSocketConnected)
	socket.closed.connect(onSocketClosed)
	socket.received_error.connect(onSocketReceivedError)
	
	socket.received_match_presence.connect(onMatchPresence)
	socket.received_match_state.connect(onMatchState)
	updateUserInfo("test", "testDisplay")
	var account = await  client.get_account_async(session)
	
	$Panel/UserAccountText.text = account.user.username
	$Panel/DisplayNameText.text = account.user.display_name
	print(account)
	
	setupMultiplayerBridge()
	pass # Replace with function body.

func setupMultiplayerBridge():
	multiplayerBridge = NakamaMultiplayerBridge.new(socket)
	multiplayerBridge.match_join_error.connect(onMatchJoinError)
	var multiplayer = get_tree().get_multiplayer()
	multiplayer.set_multiplayer_peer(multiplayerBridge.multiplayer_peer)
	multiplayer.peer_connected.connect(onPeerConnected)
	multiplayer.peer_disconnected.connect(onPeerDisconnected)

func onPeerConnected(id):
	print("Peer Connected! Id is: " + str(id))
	
func onPeerDisconnected(id):
	print("Peer Disconnected! Id is: " + str(id))

func onMatchJoinError(error):
	print("Unable to Join Match " + error.message)
	
func onMatchJoin():
	print("Joined Match with id: " + multiplayerBridge.match_id)

func _on_store_data_button_down() -> void:
	var saveGame = {
		"name" : "username",
		"items" : [{
			"id" : 1,
			"name" : "gun",
			"ammo" : 10
		},
		{
			"id" : 2,
			"name" : "sword",
			"ammo" : 0
		}
		],
		"level" : 10
	}
	
	var data = JSON.stringify(saveGame)
	var result = await client.write_storage_objects_async(session, [
		NakamaWriteStorageObject.new("saves", "savegame2", 1, 1, data,"")
	])
	
	if result.is_exception():
		print("error " + str(result))
		return
	print("stored data successfully")
	
	pass # Replace with function body.


func _on_get_data_button_down() -> void:
	var result = await client.read_storage_objects_async(session, [
		NakamaStorageObjectId.new("saves", "savegame", session.user_id)
	])
	
	if result.is_exception():
		print("error " + str(result))
		return
	for i in result.objects:
		print(str(i.value))
		
	pass # Replace with function body.


func _on_list_data_button_down() -> void:
	var datalist = await client.list_storage_objects_async(session, "saves", session.user_id, 5)
	for i in datalist.objects:
		print(i)
	pass # Replace with function body.


func _on_join_create_match_button_down() -> void:
	multiplayerBridge.join_named_match($Panel4/MatchName.text)
	#var createdMatch = await socket.create_match_async($Panel4/LineEdit.text)
	#if createdMatch.is_exception():
		#print("Failed to create Match " + str(createdMatch))
		#return
	#
	#print("Created Match " + str(createdMatch.match_id))
	pass # Replace with function body.


func _on_ping_button_down() -> void:
	#sendData.rpc("Hello World")
	var newData = {"hello" : "world"}
	socket.send_match_state_async(Match.match_id, 1, JSON.stringify(newData))
	pass # Replace with function body.

@rpc("any_peer")
func sendData(message):
	print(message)


func _on_matchmaking_button_down() -> void:
	var query = "+properties.region:US +properties.rank:>=4 +properties.rank:<=10"
	var stringP = {"region" : "US"}
	var numberP = {"rank" : 6}
	
	var ticket = await socket.add_matchmaker_async(query, 2, 4, stringP, numberP)
	
	if ticket.is_exception():
		print("Failed matchmaking: " + str(ticket))
		return
		
	print("Match Ticket Number: " + str(ticket))
	
	socket.received_matchmaker_matched.connect(onMatchMakerMatched)
	pass # Replace with function body.

func onMatchMakerMatched(matched : NakamaRTAPI.MatchmakerMatched):
	var joinedMatch = await socket.join_matched_async(matched)
	Match = joinedMatch
