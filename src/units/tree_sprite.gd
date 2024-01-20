extends Node2D

@onready var tree_type: int
@onready var shadow0 = $Shadow0
@onready var shadow1 = $Shadow1
@onready var shadow2 = $Shadow2
@onready var tree_sprite0 = $TreeSprite0
@onready var tree_sprite1 = $TreeSprite1
@onready var tree_sprite2 = $TreeSprite2

@onready var trees = [tree_sprite0, tree_sprite1, tree_sprite2]
@onready var shadows = [shadow0, shadow1, shadow2]

func _ready():
	var visible_type = GlobalVar.rng.randi_range(0, 2)
	for tree_idx in trees.size():
		if tree_idx == visible_type:
			trees[tree_idx].show()
		else:
			trees[tree_idx].hide()
		

