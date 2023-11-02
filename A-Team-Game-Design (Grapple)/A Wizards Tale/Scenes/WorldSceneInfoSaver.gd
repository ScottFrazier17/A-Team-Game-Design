extends Node

const starter_pos = Vector2(206,536)#750,-1250)#750,-3000))#206,536)
var player_pos = starter_pos

var currHookObj = null
var HookPosition = Vector2.ZERO
var BodyPosition = Vector2.ZERO
var currHookArea2D: Area2D

var fullscreen = false
var checkbox = null

var paused = false

var player_vec = Vector2.ZERO

var selectedHook = null
var curr_hook = null  

var grapple_draw = false

var p = Vector2.ZERO

var init_angle:float

var lockHookObj = null
