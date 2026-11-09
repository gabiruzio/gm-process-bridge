

shm_poke(SHM_MAIN, 0, buffer_u64, current_time)


switch(global.box.type) {
	case MAILBOX_TYPE.MANUAL:
		global.box.receive() 
		var _messages = global.box.pull() 
		for(var _i = 0; _i < array_length(_messages); _i++) {
			show_debug_message($"message({_i+1}): {global.nbt.decode(_messages[_i])}")
		}
		break 
	case MAILBOX_TYPE.AUTOMATIC:
		var _messages = global.box.pull()
		for(var _i = 0; _i < array_length(_messages); _i++) {
			show_debug_message($"message({_i+1}): {global.nbt.decode(_messages[_i])}")
		}
		break 
}
 


