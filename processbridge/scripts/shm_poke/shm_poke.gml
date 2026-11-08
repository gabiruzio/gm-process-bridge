function shm_poke(_id, _offset, _type, _value){
	switch(_type) {
		case buffer_string: 
			return __shm_poke_string(_id, _offset, _value, string_length(_value))
		default: 
			return __shm_poke(_id, _offset, _type, _value) 
	}
}