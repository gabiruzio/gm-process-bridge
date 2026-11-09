function __wait_peer_ready(){
	static call = false
	if(call) return 0
	
	var _initial_time, _elapsed_time, _other_knows_me
	_initial_time = get_timer() / 1000
	_elapsed_time = 0
	while(true) {
		_elapsed_time = (get_timer() / 1000) - _initial_time
		if(_elapsed_time >= PEER_TIMOUT) {
			show_error($"{global.appid}: step 2 timeout", true)
		}
		_other_knows_me = shm_peek(SHM_H_OTHER, 1, buffer_u8)
		if(_other_knows_me) {  
			break 
		} 
		thread_sleep(1)
	}
}