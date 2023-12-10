extends Control


# Called when the node enters the scene tree for the first time.
func _ready():

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_enemy_damage_spin_box_value_changed(value):
	GlobalVar.unit_parameters.attack_damage = value


func _on_enemy_health_spin_box_value_changed(value):
	GlobalVar.unit_parameters.max_health = value


func _on_enemy_speed_spin_box_value_changed(value):
	GlobalVar.unit_parameters.speed = value


func _on_enemy_shoot_distance_spin_box_value_changed(value):
	GlobalVar.unit_parameters.shoot_distance = value


func _on_enemy_exp_drop_spin_box_value_changed(value):
	GlobalVar.unit_parameters.exp_value = value


func _on_enemy_money_spin_box_value_changed(value):
	GlobalVar.unit_parameters.money_reward = value


func _on_enemy_shots_per_second_spin_box_value_changed(value):
	GlobalVar.unit_parameters.shots_per_second = value
