function sprite_to_struct(_sprite){ 
	var _buffer = bitmap_to_binary(_sprite)
	var _struct = global.nbt_codec.decode(_buffer)
	buffer_delete(_buffer) 
	return _struct 
}