extends Node

const transition_node_name = "transition_node"
var is_showing_transition = false

var function_to_call: Callable

enum TransitionType{
	ZoomOut=1,
	SwipeRight=2,
	FallDown=3
}

func setup_sprite():
	var transition_sprite = load("res://transition_sprite.tscn").instantiate() as Sprite2D
	var image = get_viewport().get_texture().get_image()
	var transition_texture = ImageTexture.create_from_image(image)
	transition_sprite.name = transition_node_name
	transition_sprite.texture = transition_texture
	return transition_sprite
	
func change_scene(new_scene_location: String, transition_type: int):
	if is_showing_transition:
		return
	is_showing_transition = true
	var transition_sprite = setup_sprite()
	get_tree().change_scene_to_file(new_scene_location)
	function_to_call = show_transition.bind(transition_sprite, transition_type)
	get_tree().node_added.connect(function_to_call)
	

func show_transition(_new_node, transition_sprite: Sprite2D, type: TransitionType):
	if get_tree().root.get_node_or_null(transition_node_name) != null:
		return
	get_tree().root.add_child(transition_sprite)
	var transition_tween = create_tween().set_parallel()
	
	if type == TransitionType.ZoomOut:
		transition_tween.set_trans(Tween.TRANS_CUBIC)
		transition_tween.tween_property(transition_sprite, "scale", Vector2(0.01,0.01), 1)
	elif type == TransitionType.SwipeRight:
		transition_tween.tween_property(transition_sprite, "global_position", Vector2(1800,-400), 1)
		transition_tween.tween_property(transition_sprite, "rotation", deg_to_rad(180), 1)
	elif type == TransitionType.FallDown:
		transition_tween.set_trans(Tween.TRANS_EXPO)
		transition_tween.tween_property(transition_sprite, "global_position", Vector2(0,800), 1)
		
		
	
	transition_tween.finished.connect(transition_sprite.queue_free)
	await transition_tween.finished
	get_tree().node_added.disconnect(function_to_call)
	is_showing_transition = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		TransitionManager.change_scene("res://main_2.tscn", TransitionType.ZoomOut)
	if Input.is_action_just_pressed("ui_right"):
		TransitionManager.change_scene("res://main_3.tscn", TransitionType.SwipeRight)
	if Input.is_action_just_pressed("ui_down"):
		TransitionManager.change_scene("res://main_1.tscn", TransitionType.FallDown)
