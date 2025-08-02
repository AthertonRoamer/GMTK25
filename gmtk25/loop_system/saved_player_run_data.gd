class_name SavedPlayerRunData
extends RefCounted

var saved_player_input_record : InputRecord
var saved_player : Player
var loop_when_saved : int
var loop_being_completed : int
var once_current_player : Player
var once_current_player_input_record : InputRecord
var new_saved_player_input_record : InputRecord

var currently_running_saved_player : bool = false
var currently_replaying_loop_when_saved : bool = false

var frame_when_saved : int

var reincarnate_once_current_player : Player #player to give control to when finshing the loop on which the save took place
