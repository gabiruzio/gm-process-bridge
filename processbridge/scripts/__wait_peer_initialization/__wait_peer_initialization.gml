function __wait_peer_initialization(){
	static call = false
	if(call) return 0
	
	var _initial_time, _elapsed_time, _is_other_initialized
	_initial_time = get_timer() / 1000
	_elapsed_time = 0
	while(true) {
		_elapsed_time = (get_timer() / 1000) - _initial_time
		if(_elapsed_time >= PEER_TIMOUT) {
			show_error($"{global.appid}: step 1 timeout", true)
		}
		_is_other_initialized = shm_peek(SHM_H_OTHER, 0, buffer_u8)
		if(_is_other_initialized) { 
			__peer_pid_add(shm_peek(SHM_H_OTHER, 2, buffer_u64))
			shm_poke(SHM_H_SELF, 1, buffer_u8, 1) // tenho o contexto do outro 
			break 
		} 
		thread_sleep(1)
	}
}