
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
		global.box.push(global.nbt.encode({
			teste : "mailbox"
		})) 
		global.box.push(global.nbt.encode({
			teste : "mailbox222"
		})) 
		global.box.send()
	
		break 
	case MAILBOX_TYPE.AUTOMATIC:
		global.box.push(global.nbt.encode({
			teste : "mailbox"
		}))
		/*global.box.push(global.nbt.encode({
			teste : "mailbox2"
		}))
		global.box.push(global.nbt.encode({
			teste : $"mailbox3 {current_time}"
		}))*/
		break 
}


 
//shm_poke(SHM_CORE, 0, buffer_string, $"ola {counter}  mundo!!! {current_time} | fps real {fps_real}")  

