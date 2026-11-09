

#macro PEER_TIMOUT 10000 

#macro _1KB 0x400
#macro _8KB 0x2000
#macro _16KB 0x4000
#macro _32KB 0x8000
#macro _64KB 0x10000
#macro _128KB 0x20000
#macro _256KB 0x40000
#macro _512KB 0x80000
#macro _1MB 0x100000

#macro APPID_SELF global.appid
#macro APPKEY global.appkey
#macro APPID_MAIN 0 
#macro APPID_CORE 1 

#macro SHM_H_MAIN global.__shmid_h_main
#macro SHM_H_CORE global.__shmid_h_core
#macro SHM_H_SELF (global.appid==0 ? SHM_H_MAIN : SHM_H_CORE)
#macro SHM_H_OTHER (global.appid==0 ? SHM_H_CORE : SHM_H_MAIN)

#macro SHM_MAIN global.shmid_main
#macro SHM_CORE global.shmid_core
#macro SHM_SELF (global.appid==0 ? SHM_MAIN : SHM_CORE)

function init(){  
	global.appid = "" 
	global.appkey = "" 
	
	__init_child()
	
	
	global.__shmid_h_main = -1
	global.__shmid_h_core = -1
	
	global.shmid_main = -1
	global.shmid_core = -1
	 
	
	//global.appid = MultiClientGetID()
	global.pid = get_process_id() 
	application_surface_enable(false)
	application_surface_draw_enable(false)
	window_set_showborder(false)  
	window_set_visibility(string(window_handle()), false)
	
	SHM_MAIN=shm_sync($"&M{APPKEY}", 1000)
	SHM_CORE=shm_sync($"&C{APPKEY}", 1000)
	
	
	SHM_H_MAIN=shm_sync($"Local\\Gabiru.Main.Header.{APPKEY}", 64)
	SHM_H_CORE=shm_sync($"Local\\Gabiru.Core.Header.{APPKEY}", 64)
	
	
	
	shm_poke(SHM_H_SELF, 2, buffer_u64, global.pid) 
	shm_poke(SHM_H_SELF, 0, buffer_u8, 1) // deve ser a ultima coisa a ser escrita 
	
	
	__wait_peer_initialization() 
	__wait_peer_ready() 
	
	
	 
	
	
	
	global.nbt = new NamedBinaryTagCodec()
	
	
	
	if(global.appid == 0) {
		window_set_visibility(string(window_handle()), true)
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
	 
	
	global.box = new Mailbox(
		APPID_CORE, 
		APPID_MAIN,
		,
		,
		MAILBOX_TYPE.AUTOMATIC
	)
	
}