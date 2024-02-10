extends Node

var rng = RandomNumberGenerator.new()

var unit_parameters = {
	"speed": 100,
	"shoot_distance": 150.0,
	"max_health": 10,
	"exp_value": 2,
	"attack_damage": 4,
	"money_reward": 1,
	"shots_per_second": 0.3
}

var cursor_mode: String = "normal"
var events = []
