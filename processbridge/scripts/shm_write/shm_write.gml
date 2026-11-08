function shm_write(_id, _type, _value){
	switch(_type) {
		case buffer_string:
			return __shm_write_string(-_id, _value, string_length(_value))
		default:
			return __shm_write(-_id, _type, _value)
	} 
}