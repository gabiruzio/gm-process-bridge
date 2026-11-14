
#macro CALLONCE  static call = false if(call) return 0 call = true

#macro PEER_TIMOUT 10000  

#macro APPID_SELF global.appid
#macro APPKEY global.appkey
#macro APPID_MAIN 0 
#macro APPID_CORE 1 

#macro SHM_H_MAIN global.__shmid_h_main
#macro SHM_H_CORE global.__shmid_h_core
#macro SHM_H_SELF (global.appid==0 ? SHM_H_MAIN : SHM_H_CORE)
#macro SHM_H_OTHER (global.appid==0 ? SHM_H_CORE : SHM_H_MAIN) 

#macro R_INIT_MAIN rm_main
#macro R_INIT_CORE rm_core

#macro PROCESS_BRIDGE_ENABLE true   

function __init(){
	
	global.appid = "" 
	global.appkey = "" 
	
	global.__shmid_h_main = -1
	global.__shmid_h_core = -1
	
	global.shmid_main = -1
	global.shmid_core = -1 
	
	global.pid = get_process_id() 
	
	application_surface_enable(false)
	application_surface_draw_enable(false)
	window_set_showborder(false)  
	window_set_visibility(string(window_handle()), false) 
	
	if(!PROCESS_BRIDGE_ENABLE) {
		window_set_visibility(string(window_handle()), true)
		window_set_showborder(true)
		application_surface_draw_enable(true)
		application_surface_enable(true)
		room_goto(R_INIT_MAIN)  
		return 
	}
	
	
	 
	
	__init_child()
	
	SHM_H_MAIN = shm_sync($"Local\\Gabiru.Main.Header.{APPKEY}", 64)
	SHM_H_CORE = shm_sync($"Local\\Gabiru.Core.Header.{APPKEY}", 64)
	
	shm_poke(SHM_H_SELF, 2, buffer_u64, global.pid) 
	shm_poke(SHM_H_SELF, 0, buffer_u8, 1) // deve ser a ultima coisa a ser escrita 
	
	
	__wait_peer_initialization() 
	__wait_peer_ready() 
	
	if(global.appid == 0) {
		window_set_visibility(string(window_handle()), true)
		window_set_showborder(true)
		application_surface_draw_enable(true)
		application_surface_enable(true) 
		room_goto(R_INIT_MAIN)   
	} else {
		window_set_visibility(string(window_handle()), false)
		room_goto(R_INIT_CORE)   
	} 
	 
	
	/*global.box = new SimplexChannel(
		APPID_CORE, 
		APPID_MAIN,
		,
		,
		CHANNEL_TYPE.MANUAL
	)*/
	
	global.pipe = new DuplexChannel("example",,CHANNEL_TYPE.MANUAL)
}