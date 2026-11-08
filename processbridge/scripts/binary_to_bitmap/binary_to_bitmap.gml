#macro BINARY_TO_BITMAP_CONVERTER_VERSION 1

function binary_to_bitmap(_binary){
	
	// header 16 bytes (u64 version + u64 size(in bytes)) 
	var _size = buffer_get_size(_binary) 
	var _size_bitmap = ceil(sqrt((_size + 8) div 4))
	var _bitmap = buffer_create((_size_bitmap * _size_bitmap) * 4, buffer_fixed, 1)
	//show_debug_message($"bin to bmt {_size_bitmap} {_size_bitmap}")
	buffer_seek(_bitmap, buffer_seek_start, 0)
	buffer_write(_bitmap, buffer_u32, BINARY_TO_BITMAP_CONVERTER_VERSION)
	buffer_write(_bitmap, buffer_u32, _size)
	//show_debug_message($"bin to bmt -> 0 -> {BINARY_TO_BITMAP_CONVERTER_VERSION}")
	//show_debug_message($"bin to bmt -> 1 -> {_size}")
	buffer_copy(_binary, 0, _size, _bitmap, 8)
	
	var _surface = surface_create(_size_bitmap, _size_bitmap)
	surface_set_target(_surface)
	draw_clear_alpha(c_white, 0) 
	surface_reset_target()
	
	buffer_set_surface(_bitmap, _surface, 0)
	
	var _sprite = sprite_create_from_surface(_surface, 0, 0, _size_bitmap, _size_bitmap, false, false, 0, 0) 
	//show_debug_message($"bin to bmt -> 0 -> {buffer_peek(_bitmap, 0, buffer_u32)}")
	//show_debug_message($"bin to bmt -> 1 -> {buffer_peek(_bitmap, 4, buffer_u32)}")
	
	buffer_delete(_bitmap)
	surface_free(_surface)
	
	
	
	return _sprite
}