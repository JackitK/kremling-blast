class_name PlayerKeybindResource
extends Resource

#--- Keyboard binding resources----
const SHOOT_KEY : String = "shoot_key"
const POWER_UP_KEY : String = "power_up_key"
const MOVE_LEFT : String = "move_left"
const MOVE_RIGHT : String = "move_right"
const MOVE_UP : String = "move_up"
const MOVE_DOWN : String = "move_down"

@export var DEFAULT_SHOOT_KEY = InputEventKey.new()
@export var DEFAULT_POWER_UP_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_LEFT_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_RIGHT_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_UP_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_DOWN_KEY = InputEventKey.new()

var shoot_key = InputEventKey.new()
var power_up_key = InputEventKey.new()
var move_left_key = InputEventKey.new()
var move_right_key = InputEventKey.new()
var move_up_key = InputEventKey.new()
var move_down_key = InputEventKey.new()

#Mouse input
const SHOOT : String = "shoot"
const POWER_UP: String = "power_up"

@export var DEFAULT_SHOOT = InputEventMouseButton.new()
@export var DEFAULT_POWER_UP = InputEventMouseButton.new()

var shoot = InputEventMouseButton.new()
var power_up = InputEventMouseButton.new()
