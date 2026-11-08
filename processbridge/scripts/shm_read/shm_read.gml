function shm_read(_id, _type){
	switch(_type) {
		case buffer_string:
			return __shm_read_string(-_id)
		default:
			return __shm_read(-_id, _type)
	} 
}