extends Node2D

var score := [0, 0]
var spawnpoints
@export var playerScene : PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnpoints = get_tree().get_nodes_in_group("SpawnPoint")
	var index = 0
	var keys = NakamaMultiplayer.Players.keys()
	keys.sort()
	for i in keys:
		var instancedPlayer = playerScene.instantiate()
		instancedPlayer.name = str(NakamaMultiplayer.Players[i].name)
		
		add_child(instancedPlayer)
		
		instancedPlayer.global_position = spawnpoints[index].global_position
		
		index +=1
	pass # Replace with function body.


func _on_ball_timer_timeout() -> void:
	$Ball.new_ball()


func _on_score_left_body_entered(body):
	score[1] += 1
	$HUD/PlayerScore2.text = str(score[1])
	$BallTimer.start()
	
func _on_score_right_body_entered(body):
	score[0] += 1
	$HUD/PlayerScore.text = str(score[0])
	$BallTimer.start()
