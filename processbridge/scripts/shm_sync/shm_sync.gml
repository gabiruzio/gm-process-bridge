function shm_sync(_name, _size){
	if(shm_exists(_name)) return shm_open(_name, _size)
	return shm_create(_name, _size)
}