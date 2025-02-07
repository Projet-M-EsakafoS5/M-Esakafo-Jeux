extends Control

@onready var nom_label = $nom_plat
@onready var image_texture = $image
@onready var temps_label = $temps


# Fonction pour mettre à jour les informations du plat
func set_data(nom: String, image_path: String, temps: int):
	#if nom_label:
	nom_label.text = nom
	temps_label.text = str(temps)
	var texture = load(image_path)
	if texture:
		image_texture.texture = texture
		image_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH  # ✅ Ajuste à la largeur
		image_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		image_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH
