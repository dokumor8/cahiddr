extends Node

@export var game_ended = false
@export var hero_respawn_cooldown = 5
@export var money = 300
@export var building_cost = 200
@export var hero_experience = 0
@export var max_experience = 10
@export var hero_level = 1
@onready var hero: Area2D

