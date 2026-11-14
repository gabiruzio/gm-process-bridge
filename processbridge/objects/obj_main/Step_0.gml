

if(variable_global_exists("pipe"))
switch(global.pipe.type) {
	case CHANNEL_TYPE.MANUAL: 
		// escrever 
		if(global.pipe.__flush_open()) {   
			if(global.pipe.__flush_packet_begin()) {  
				Serializer.encode({ msg : "main" }, , global.pipe.__flush_get_buffer())  
				global.pipe.__flush_packet_commit()
			} 
			global.pipe.__flush_close()
		}
		
		// ler 
		if(global.pipe.__drain_open()) { 
			while(global.pipe.__drain_packet_begin()) {  
				var _struct = Serializer.decode(global.pipe.__drain_get_buffer(), global.pipe.__drain_packet_get_offset())
				show_debug_message(_struct)
				global.pipe.__drain_packet_commit()
			} 
			global.pipe.__drain_close()
		}
		
		break 
	case CHANNEL_TYPE.AUTOMATIC:
		/*
		global.pipe.push(Serializer.encode({
			pipe : "pipe main"
		}), true)

		var _messages = global.pipe.pull()
		for(var _i = 0; _i < array_length(_messages); _i++) {
			show_debug_message($"message({_i+1}): {Serializer.decode(_messages[_i])}")
			buffer_delete(_messages[_i])
		}*/
		break 
}
 


if(variable_global_exists("box"))
switch(global.box.type) {
	case CHANNEL_TYPE.MANUAL:
	
		// option 1 (no copy)
		if(global.box.__drain_open()) {
			
			while(global.box.__drain_packet_begin()) {  
				var _struct = Serializer.decode(global.box.shm, global.box.__drain_packet_get_offset())
				show_debug_message(_struct)
				global.box.__drain_packet_commit()
			}
			
			global.box.__drain_close()
		}
		
		
		// easy option 2 (copy) 
		/*global.box.receive() 
		var _messages = global.box.pull() 
		for(var _i = 0; _i < array_length(_messages); _i++) {
			show_debug_message($"message({_i+1}): {Serializer.decode(_messages[_i])}")
			buffer_delete(_messages[_i])
		}*/
		break 
	case CHANNEL_TYPE.AUTOMATIC:
		
		var _messages = global.box.pull()
		for(var _i = 0; _i < array_length(_messages); _i++) {
			show_debug_message($"message({_i+1}): {Serializer.decode(_messages[_i])}")
			buffer_delete(_messages[_i])
		}
		
		 
		break 
}
 


