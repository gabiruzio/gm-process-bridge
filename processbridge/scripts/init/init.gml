

#macro _1KB 0x400
#macro _8KB 0x2000
#macro _16KB 0x4000
#macro _32KB 0x8000
#macro _64KB 0x10000
#macro _128KB 0x20000
#macro _256KB 0x40000
#macro _512KB 0x80000
#macro _1MB 0x100000

#macro SHM_MAIN global.shmid_main
#macro SHM_CORE global.shmid_core

function init(){  
	global.shm_main = "m"
	global.shm_core = "c"
	global.shmid_main = -1
	global.shmid_core = -1
	
	global.appid = MultiClientGetID()
	application_surface_enable(false)
	application_surface_draw_enable(false)
	window_set_showborder(false)
	
	if(!shm_exists(global.shm_main)) SHM_MAIN=shm_create(global.shm_main, 1000) 
	if(!shm_exists(global.shm_core)) SHM_CORE=shm_create(global.shm_core, 1000) 
	
	SHM_MAIN=shm_open(global.shm_main, 1000)
	SHM_CORE=shm_open(global.shm_core, 1000)
	
	
	global.nbt = new NamedBinaryTagCodec()
	
	
	
	//show_message($"app {global.appid}\n\nmain{shm_exists(SHM_MAIN)}\ncore{shm_exists(SHM_CORE)}")
	
	if(global.appid == 0) {
		window_set_showborder(true)
		application_surface_draw_enable(true)
		application_surface_enable(true)
		surface_resize(application_surface, 512, 512)
		window_set_size(512, 512) 
		window_center()
		room_goto(rm_main)  
		
		 
		
		 
		 
	} else {
		window_set_visibility(string(window_handle()), false)
		room_goto(rm_core)  
		
		
	}
	
	show_debug_message($"app {global.appid} iniciou")

	
	
}