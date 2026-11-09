 function shm_copy(_src, _src_offset, _size, _dest, _dest_offset) {
	static buffer_param = buffer_create(40, buffer_fixed, 8);

	var _src_is_shm = _src < 0;
	var _dest_is_shm = _dest < 0;
	
	if (_src_is_shm == _dest_is_shm)
		return -4;

	buffer_seek(buffer_param, buffer_seek_start, 0);

	if (_dest_is_shm) {
		// Buffer -> Shared Memory
		buffer_write(buffer_param, buffer_f64, -_dest);
		buffer_write(buffer_param, buffer_f64, buffer_get_size(_src));
		buffer_write(buffer_param, buffer_f64, _src_offset);
		buffer_write(buffer_param, buffer_f64, _size);
		buffer_write(buffer_param, buffer_f64, _dest_offset);

		return __shm_copy_b2s(
			buffer_get_address(buffer_param),
			buffer_get_address(_src)
		);
	}
	else {
		// Shared Memory -> Buffer
		buffer_write(buffer_param, buffer_f64, -_src);
		buffer_write(buffer_param, buffer_f64, buffer_get_size(_dest));
		buffer_write(buffer_param, buffer_f64, _src_offset);
		buffer_write(buffer_param, buffer_f64, _size);
		buffer_write(buffer_param, buffer_f64, _dest_offset);

		return __shm_copy_s2b(
			buffer_get_address(buffer_param),
			buffer_get_address(_dest)
		);
	}
} 