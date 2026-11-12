
counter++

//shm_seek(SHM_CORE, buffer_seek_start, 0)
//shm_write(SHM_CORE, buffer_string, $"ola mundoo!!! {current_time}")

var _struct = {}


if(choose(1,0)) _struct.counter = counter
if(choose(1,0)) _struct.ola = "mundo"
if(choose(1,0)) _struct.teste = irandom(100)

shm_seek(SHM_CORE, buffer_seek_start, 0)
global.nbt.encode(_struct, , , SHM_CORE)

if(variable_global_exists("pipe"))
switch(global.pipe.type) {
	case CHANNEL_TYPE.MANUAL:
		
		// escrever 
		if(global.pipe.__flush_open()) {  
			if(global.pipe.__flush_packet_begin()) {
				global.nbt.encode({ msg : "core" }, , , global.pipe.__flush_get_buffer())
				global.pipe.__flush_packet_commit()
			} 
			global.pipe.__flush_close()
		}
		
		// ler 
		if(global.pipe.__drain_open()) {  
			while(global.pipe.__drain_packet_begin()) {  
				var _struct = global.nbt.decode(global.pipe.__drain_get_buffer(), global.pipe.__drain_packet_get_offset())
				show_debug_message(_struct)
				global.pipe.__drain_packet_commit()
			} 
			global.pipe.__drain_close()
		}
	
		break 
	case CHANNEL_TYPE.AUTOMATIC:
		
		global.pipe.push(global.nbt.encode({
			pipe : "pipe core"
		}), true)

		var _messages = global.pipe.pull()
		for(var _i = 0; _i < array_length(_messages); _i++) {
			show_debug_message($"message({_i+1}): {global.nbt.decode(_messages[_i])}") 
			buffer_delete(_messages[_i])
		}
		break 
}
 
 
if(variable_global_exists("box"))
switch(global.box.type) {
	case CHANNEL_TYPE.MANUAL:
		
		// option 1 (no copy)
		if(global.box.__flush_open()) { 
		
			if(global.box.__flush_packet_begin()) {
				global.nbt.encode({ ola : "mundo" }, , , global.box.shm)
				global.box.__flush_packet_commit()
			}
		
			if(global.box.__flush_packet_begin()) {
				global.nbt.encode({ hello : "world" }, , , global.box.shm)
				global.box.__flush_packet_commit()
			}
			
			global.box.__flush_close()
		}
		
		// easy option (copy)
		/*global.box.push(global.nbt.encode({
			teste : "mailbox"
		}), true) 
		global.box.push(global.nbt.encode({
			teste : "mailbox222"
		}), true) 
		global.box.send()*/ 
	
		break 
	case CHANNEL_TYPE.AUTOMATIC:
		//global.box.push(global.nbt.encode({
		//	teste : "mailbox"
		//}), true)
		/*global.box.push(global.nbt.encode({
			teste : "mailbox2"
		}), true)
		global.box.push(global.nbt.encode({
			teste : $"mailbox3 {current_time}"
		}), true)*/
		break 
}


 
//shm_poke(SHM_CORE, 0, buffer_string, $"ola {counter}  mundo!!! {current_time} | fps real {fps_real}")  

