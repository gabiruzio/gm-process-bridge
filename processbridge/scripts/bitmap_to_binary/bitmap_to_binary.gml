function bitmap_to_binary(_bitmap){
	//show_debug_message(_bitmap)
	var _width = sprite_get_width(_bitmap)
	var _height = sprite_get_height(_bitmap)
	var _surface = surface_create(_width, _height)
	//show_debug_message($"bmt to bin {_width} {_height}")
	surface_set_target(_surface)
	draw_clear_alpha(c_white, 0)
	gpu_set_blendenable(false)
	draw_sprite(_bitmap, 0, 0, 0)
	gpu_set_blendenable(true)
	surface_reset_target()
	
	var _buffer = buffer_create((_width * _height) * 4, buffer_fixed, 1)
	
	buffer_get_surface(_buffer, _surface, 0)
	
	buffer_seek(_buffer, buffer_seek_start, 0)
	var _version = buffer_read(_buffer, buffer_u32)
	var _size = buffer_read(_buffer, buffer_u32)
	//show_debug_message($"bmt to bin -> 0 -> {_version}")
	//show_debug_message($"bmt to bin -> 1 -> {_size}")
	if(_version != BINARY_TO_BITMAP_CONVERTER_VERSION) {
		show_error($"[error] binary/bitmap converter version wrong, \nreceived->{_version}\nexpected->{BINARY_TO_BITMAP_CONVERTER_VERSION}", true)
	}
	
	var _binary = buffer_create(_size, buffer_fixed, 1)
	buffer_copy(_buffer, 8, _size, _binary, 0)
	buffer_delete(_buffer)
	surface_free(_surface)
	return _binary 
}