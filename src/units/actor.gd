extends Node2D

var movement_state = "idle"
@export var movement_speed: float = 200.0
var movement_target_position: Vector2 = Vector2(0.0, 0.0)
var movement_target_unit: Node2D
var attack_target_unit: Node2D

# const?
var aggro_radius = 200

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
var stop_distance = 100.0
var path_desired_distance = 100.0

func _ready():
	ready_navigation()
	ready_aggro_collision()


func ready_navigation():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = stop_distance
	navigation_agent.target_desired_distance = stop_distance
	
	# Make sure to not await during _ready.
	call_deferred("actor_setup")


func ready_aggro_collision():
	var aggro_area = $AggroArea
	var aggro_circle: CircleShape2D = $AggroArea/CollisionShape2D.shape
	aggro_circle.set_radius(aggro_radius)
	# TODO set up masks
	

func _physics_process(_delta):
	if movement_state == "idle":
		# don't do anything, but aggro to nearby enemies
		return

	elif movement_state == "m_move":
		# non-aggro move
		# just navigate to the place, don't attack
		keep_moving_to_position()
		pass
	elif movement_state == "a_move":
		# attack-move
		# navigate, but keep checking for enemies
		pass
	elif movement_state == "attack":
		pass
		# attack a specific enemy
		# move towards and enemy and attack it
		# don't aggro
			


func keep_moving_to_position():
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	var new_velocity: Vector2 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * movement_speed

	navigation_agent.set_velocity(new_velocity)


func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame


func set_movement_target(movement_target: Vector2):
	movement_target_position = movement_target
	navigation_agent.target_position = movement_target


func move_to_position(target_position: Vector2):
	movement_state = "m_move"
	set_movement_target(target_position)
	
	
func attack_move_to_position(target_position: Vector2):
	movement_state = "a_move"
	set_movement_target(target_position)


func attack_unit(unit):
	attack_target_unit = unit
	movement_state = "attack"
	set_movement_target(unit.position)


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	move_with_velocity(safe_velocity)

func move_with_velocity(velocity):
	var delta = get_physics_process_delta_time()
	translate(velocity * delta)
