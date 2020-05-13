""" 
Démonstartion d'utilisation du Shader "braidRing"
J'ai pris le projet de démo de shaders de Godot, et je m'en suis servi comme base,
mais j'ai laissé les shaders, pour comparer.
Mes fichiers sont "shaders/BraidRing.shader" et "graindDots.png" (texture pour un effet)

Vous pouvez lancer la démo, le shader est chargé automatiquement, vous pouvez changer d'image en haut à gauche.
déplacez la souris sur l'écran pour déplacer l'anneau du shader, et cliquer droit pour l'afficher/cacher

toute cette petite démo est codée dans ce fichier, ça peut vous aider pour l'implémenter sur votre jeu
(au lieu de la souris mettre la pos du personnage, et au lieu du clic l'event quand on mets / enlève le masque)
par contre c'est en GDScript parce que pourquoi pas.

vous pouvez modifier tous les paramètres du shader dans son objet dans la hiérarchie:
Effects -> BraidRing  dans les onglets material -> shader param

vous pouvez aussi lire et modifier le shader, je l'ai commenté.
(les parties ou je comprenais comment il fonctionnait en tout cas ^^')
Les paramètres sont bien décrits dedans en tout cas.

Good luck pour votre projet!
""" 

extends "debugControls.gd"

# commented because already defined in parent class (debug controls)
# onready var braidShader = $Effects/BraidRing;

var is_showed = true;
var previousCircleSize = 0;


func _ready():
	#we can set it in the editor, but safer to check if user resizes the window
	braidShader.material.set_shader_param("screenResolution", get_viewport_rect().size)
	braidShader.show()


#hide/show circle when right clicking
func show_braid_shader():
	var speed = 0.001
	if !is_showed:
		braidShader.show()

	#prevent the circle to pulsate while it changes of size
	braidShader.material.set_shader_param("pulsePercent", 0);


	var circleSize = braidShader.material.get_shader_param("circleSize");
	if (circleSize < 0.001):
		circleSize = previousCircleSize
		
	var size = 0
	while size < circleSize:
		size += speed
		braidShader.material.set_shader_param("circleSize", size if !is_showed else (circleSize-size));
		yield(get_tree(), "idle_frame")

	braidShader.material.set_shader_param("pulsePercent", 10);

	if is_showed:
		previousCircleSize = circleSize;
		braidShader.hide()
		
	is_showed = !is_showed		


func _input(event):
   # Mouse in viewport coordinates
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_RIGHT:
			show_braid_shader()
	elif event is InputEventMouseMotion:
		# move ring at position
		var pos = event.position / get_viewport_rect().size
		pos.y = 1 - pos.y #or do it in shader?
		braidShader.material.set_shader_param("pos", pos)

