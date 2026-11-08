function struct_to_sprite(_struct){
	var _buffer = global.nbt_codec.encode(_struct)
	var _sprite = binary_to_bitmap(_buffer)
	buffer_delete(_buffer)
	return _sprite 
}