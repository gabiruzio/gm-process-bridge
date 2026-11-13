 function shm_copy(_src, _src_offset, _size, _dest, _dest_offset) {
	
	enum __COPY_TYPE {
		B2B = (1 << 2) | (1 << 1),
		B2S = (1 << 2) | (0 << 1),
		S2B = (0 << 2) | (1 << 1),
		S2S = (0 << 2) | (0 << 1),
	}
	
	var _src_is_buffer = real(_src) >= 0;
	var _dest_is_buffer = real(_dest) >= 0;

	var _type = (_src_is_buffer << 2) | (_dest_is_buffer << 1);
	
	static buffer_param = buffer_create(40, buffer_fixed, 8);
	buffer_seek(buffer_param, buffer_seek_start, 0);
	
	switch(_type) {
		case __COPY_TYPE.B2B: // Buffer -> Buffer
			return buffer_copy(_src, _src_offset, _size, _dest, _dest_offset)
		case __COPY_TYPE.B2S: // Buffer -> Shared Memory
			buffer_write(buffer_param, buffer_f64, -_dest);
			buffer_write(buffer_param, buffer_f64, buffer_get_size(_src));
			buffer_write(buffer_param, buffer_f64, _src_offset);
			buffer_write(buffer_param, buffer_f64, _size);
			buffer_write(buffer_param, buffer_f64, _dest_offset);

			return __shm_copy_b2s(
				buffer_get_address(buffer_param),
				buffer_get_address(_src)
			); 
		case __COPY_TYPE.S2B: // Shared Memory -> Buffer
			buffer_write(buffer_param, buffer_f64, -_src);
			buffer_write(buffer_param, buffer_f64, buffer_get_size(_dest));
			buffer_write(buffer_param, buffer_f64, _src_offset);
			buffer_write(buffer_param, buffer_f64, _size);
			buffer_write(buffer_param, buffer_f64, _dest_offset);

			return __shm_copy_s2b(
				buffer_get_address(buffer_param),
				buffer_get_address(_dest)
			);
		case __COPY_TYPE.S2S: // Shared Memory -> Shared Memory
			buffer_write(buffer_param, buffer_f64, -_src);
			buffer_write(buffer_param, buffer_f64, -_dest);
			buffer_write(buffer_param, buffer_f64, _src_offset);
			buffer_write(buffer_param, buffer_f64, _size);
			buffer_write(buffer_param, buffer_f64, _dest_offset);

			return __shm_copy_s2s(
				buffer_get_address(buffer_param) 
			);
	}
	 
} 