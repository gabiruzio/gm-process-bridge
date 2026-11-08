function shm_peek(_id, _offset, _type){
	switch(_type) {
		case buffer_string: 
			return __shm_peek_string(_id, _offset)
		default: 
			return __shm_peek(_id, _offset, _type) 
	}
}