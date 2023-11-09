extends Node

const starter_pos = Vector2(206,536)#750,-1250)#750,-3000))#206,536)
var player_pos = starter_pos
var HookPosition = Vector2.ZERO
var BodyPosition = Vector2.ZERO
var fullscreen = false
var paused = false
var selectedHook = null 
var grapple_draw = false
var init_angle:float
var lockHookObj = null
var collectible = null

#var collectibles_list = []

