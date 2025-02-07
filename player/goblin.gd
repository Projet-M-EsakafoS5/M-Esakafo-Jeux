class_name Goblin extends CharacterBody2D

const MOTION_SPEED = 160 # Pixels/second.
var food_held = null  # Stocke l'objet ramassé
var food_info = null
var last_direction = Vector2(1, 0)

var anim_directions = {
	"idle": [ # list of [animation name, horizontal flip]
		["side_right_idle", false],
		["45front_right_idle", false],
		["front_idle", false],
		["45front_left_idle", false],
		["side_left_idle", false],
		["45back_left_idle", false],
		["back_idle", false],
		["45back_right_idle", false],
	],

	"walk": [
		["side_right_walk", false],
		["45front_right_walk", false],
		["front_walk", false],
		["45front_left_walk", false],
		["side_left_walk", false],
		["45back_left_walk", false],
		["back_walk", false],
		["45back_right_walk", false],
	],
}


func _physics_process(_delta):
	var motion = Vector2()
	motion.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	motion.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	motion.y /= 2
	motion = motion.normalized() * MOTION_SPEED
	set_velocity(motion)
	move_and_slide()
	var dir = velocity

	if dir.length() > 0:
		last_direction = dir
		update_animation("walk")
	else:
		update_animation("idle")


func update_animation(anim_set):
	var angle = rad_to_deg(last_direction.angle()) + 22.5
	var slice_dir = floor(angle / 45)

	$Sprite2D.play(anim_directions[anim_set][slice_dir][0])
	$Sprite2D.flip_h = anim_directions[anim_set][slice_dir][1]


func _process(delta):
	if Input.is_action_just_pressed("grab"):  # "space"
		if food_held:
			drop_food()
		else:
			pick_food()


func pick_food():
	var areas = $Area2D.get_overlapping_areas()
	if areas.size() > 0:
		areas.sort_custom(func(a, b): 
			return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
		)

		var closest_food = areas[0]  # Prend l'aliment le plus proche
		if closest_food.is_in_group("ingredient"):
			# Dupliquer l'ingrédient au lieu de le déplacer
			var food_clone = closest_food.duplicate()  
			add_child(food_clone)
			food_clone.position = Vector2(0, -40)  # Position relative au joueur
			food_held = food_clone  # Associer le clone comme aliment tenu

			# Vérifie si le sprite existe avant d'y accéder
			var sprite = closest_food.get_node_or_null("Sprite2D")
			if sprite and sprite.texture:
				var sprite_path = sprite.texture.resource_path
				# Trouver l'ingrédient correspondant dans ingredient_recup
				for ingredient in GetIngredient.ingredient_recup:
					var path = "res://assets/ingredients/"+ingredient["sprite"]
					if path in sprite_path:
						food_info = ingredient
						print("Ingrédient ramassé :", food_info["id"])
						break
			else:
				print("Erreur : Sprite2D introuvable dans l'objet ramassé !")


func drop_food():
	if food_held:
		remove_child(food_held)
		get_parent().add_child(food_held)
		food_held.global_position = global_position  # Dépose un peu plus loin
		food_held.queue_free()
		food_held = null
		food_info = null
		print("Nourriture lâchée !")
