
counter++

//shm_seek(SHM_CORE, buffer_seek_start, 0)
//shm_write(SHM_CORE, buffer_string, $"ola mundoo!!! {current_time}")

var _struct = {}


if(choose(1,0)) _struct.counter = counter
if(choose(1,0)) _struct.ola = "mundo"
if(choose(1,0)) _struct.teste = irandom(100)

shm_seek(SHM_CORE, buffer_seek_start, 0)
global.nbt.encode(_struct, , , SHM_CORE)







switch(global.box.type) {
	case MAILBOX_TYPE.MANUAL:
		
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
	case MAILBOX_TYPE.AUTOMATIC:
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

