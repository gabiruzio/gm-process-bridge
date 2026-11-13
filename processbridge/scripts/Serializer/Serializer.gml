#macro SERIALIZER_BUFFER_HEADER_BUFFER_SIZE buffer_u32

function Serializer() constructor {
	gml_pragma("global", "new Serializer()")
	enum STAG {
		END,
		REAL,
		BOOL,
		STRING,
		STRUCT,
		ARRAY,
		BUFFER,
		UNDEFINED
	}

	#region encode

	static encode = function(_struct, _ignore_internal_variables = false, _destination = undefined) {
		if (_destination == undefined) {
			var _buffer = buffer_create(0x20000, buffer_grow, 1);
			buffer_seek(_buffer, buffer_seek_start, 0);

			__encode_buffer_write_struct_content(
				_buffer,
				_struct,
				_ignore_internal_variables
			);

			var _size = buffer_tell(_buffer);
			buffer_resize(_buffer, _size);
			buffer_seek(_buffer, buffer_seek_end, 0);

			return _buffer;
		}
		 
		__encode_buffer_write_struct_content(
			_destination,
			_struct,
			_ignore_internal_variables
		); 
		return undefined;
	}

	static __encode_buffer_write_tag_name = function(_buffer, _type, _tag_name) {
		__write(_buffer, buffer_u8, _type);
		__write(_buffer, buffer_string, _tag_name);
	}

	static __encode_buffer_write_real = function(_buffer, _value) {
		__write(_buffer, buffer_f32, _value);
	}

	static __encode_buffer_write_bool = function(_buffer, _value) {
		__write(_buffer, buffer_u8, _value);
	}

	static __encode_buffer_write_string = function(_buffer, _value) {
		__write(_buffer, buffer_string, _value);
	}

	static __encode_buffer_write_array_index = function(_buffer, _index, _type) {
		__write(_buffer, buffer_u16, _index);
		__write(_buffer, buffer_u8, _type);
	}

	static __encode_buffer_write_array_length = function(_buffer, _length) {
		__write(_buffer, buffer_u16, _length);
	}

	static __encode_buffer_write_array_content = function(
		_buffer,
		_array,
		_ignore_internal_variables
	) {
		var _array_length = array_length(_array);
		__encode_buffer_write_array_length(_buffer, _array_length);

		var _i = 0;
		repeat (_array_length) {
			var _value = _array[_i];
			var _value_type = typeof(_value);

			switch (_value_type) {
				case "method":
					__encode_buffer_write_array_index(_buffer, _i, STAG.UNDEFINED);
				break;

				case "number":
				case "int32":
				case "int64":
					__encode_buffer_write_array_index(_buffer, _i, STAG.REAL);
					__encode_buffer_write_real(_buffer, _value);
				break;

				case "bool":
					__encode_buffer_write_array_index(_buffer, _i, STAG.BOOL);
					__encode_buffer_write_bool(_buffer, _value);
				break;

				case "string":
					__encode_buffer_write_array_index(_buffer, _i, STAG.STRING);
					__encode_buffer_write_string(_buffer, _value);
				break;

				case "array":
				case "vec3":
				case "vec4":
					__encode_buffer_write_array_index(_buffer, _i, STAG.ARRAY);
					__encode_buffer_write_array_content(
						_buffer,
						_value,
						_ignore_internal_variables
					);
				break;

				case "struct":
					__encode_buffer_write_array_index(_buffer, _i, STAG.STRUCT);
					__encode_buffer_write_struct_content(
						_buffer,
						_value,
						_ignore_internal_variables
					);
				break;

				case "ref":
					__encode_buffer_write_array_index(_buffer, _i, STAG.BUFFER);
					__encode_buffer_write_buffer(_buffer, _value);
				break;

				case "undefined":
					__encode_buffer_write_array_index(_buffer, _i, STAG.UNDEFINED);
				break;

				default:
					__encode_buffer_write_array_index(_buffer, _i, STAG.UNDEFINED);
				break;
			}

			_i++;
		}
	}

	static __encode_buffer_write_struct_content = function(
		_buffer,
		_struct,
		_ignore_internal_variables
	) {
		var _variables = struct_get_names(_struct);
		var _variables_count = array_length(_variables);

		__write(_buffer, buffer_string, instanceof(_struct));

		var _i = 0;
		repeat (_variables_count) {
			var _variable_name = _variables[_i];

			if (_ignore_internal_variables && string_length(_variable_name) >= 2) {
				if (
					string_char_at(_variable_name, 1) == "_" &&
					string_char_at(_variable_name, 2) == "_"
				) {
					_i++;
					continue;
				}
			}

			var _variable_name_hash = variable_get_hash(_variable_name);
			var _value = struct_get_from_hash(_struct, _variable_name_hash);
			var _value_type = typeof(_value);
			
			switch (_value_type) {
				case "method":
				break;

				case "number":
				case "int32":
				case "int64":
					__encode_buffer_write_tag_name(_buffer, STAG.REAL, _variable_name);
					__encode_buffer_write_real(_buffer, _value);
				break;

				case "bool":
					__encode_buffer_write_tag_name(_buffer, STAG.BOOL, _variable_name);
					__encode_buffer_write_bool(_buffer, _value);
				break;

				case "string":
					__encode_buffer_write_tag_name(_buffer, STAG.STRING, _variable_name);
					__encode_buffer_write_string(_buffer, _value);
				break;

				case "array":
				case "vec3":
				case "vec4":
					__encode_buffer_write_tag_name(_buffer, STAG.ARRAY, _variable_name);
					__encode_buffer_write_array_content(
						_buffer,
						_value,
						_ignore_internal_variables
					);
				break;

				case "struct":
					__encode_buffer_write_tag_name(_buffer, STAG.STRUCT, _variable_name);
					__encode_buffer_write_struct_content(
						_buffer,
						_value,
						_ignore_internal_variables
					);
				break;

				case "ref":
					__encode_buffer_write_tag_name(_buffer, STAG.BUFFER, _variable_name);
					__encode_buffer_write_buffer(_buffer, _value);
				break;

				case "undefined":
					__encode_buffer_write_tag_name(_buffer, STAG.UNDEFINED, _variable_name);
				break;
			}

			_i++;
		}

		__encode_buffer_write_struct_end(_buffer);
	}

	static __encode_buffer_write_struct_end = function(_buffer) {
		__write(_buffer, buffer_u8, STAG.END);
	}

	static __encode_buffer_write_buffer = function(_buffer, _buffer_source) { 
		var _size = __get_size(_buffer_source);
		__write(_buffer, SERIALIZER_BUFFER_HEADER_BUFFER_SIZE, _size);
		__copy(_buffer_source, 0, _size, _buffer, __tell(_buffer));
		__seek(_buffer, buffer_seek_relative, _size);
	}

	#endregion

	#region decode

	static decode = function(_buffer, _offset = 0) {
		__seek(_buffer, buffer_seek_start, _offset);

		var _instanceof = __read(_buffer, buffer_string);
		var _struct;

		if (_instanceof != "struct") {
			var _ref = variable_global_get(_instanceof);
			_struct = (_ref != undefined) ? new _ref() : {};
		} else {
			_struct = {};
		}

		__decode_buffer_get_struct(_struct, _buffer);
		return _struct;
	}

	static __decode_buffer_get_tag_name = function(_buffer) {
		return __read(_buffer, buffer_string);
	}

	static __decode_buffer_get_real = function(_buffer) {
		return __read(_buffer, buffer_f32);
	}

	static __decode_buffer_get_bool = function(_buffer) {
		return __read(_buffer, buffer_u8);
	}

	static __decode_buffer_get_string = function(_buffer) {
		return __read(_buffer, buffer_string);
	}

	static __decode_buffer_get_struct = function(_struct, _buffer) {
		var _type = __read(_buffer, buffer_u8);

		while (_type != STAG.END) {
			var _tag_name = __decode_buffer_get_tag_name(_buffer);
			var _tag_name_hash = variable_get_hash(_tag_name);
			var _value;

			switch (_type) {
				case STAG.REAL:
					_value = __decode_buffer_get_real(_buffer);
				break;

				case STAG.BOOL:
					_value = __decode_buffer_get_bool(_buffer);
				break;

				case STAG.STRING:
					_value = __decode_buffer_get_string(_buffer);
				break;

				case STAG.STRUCT:
					var _instanceof = __read(_buffer, buffer_string);
					var _existing_value = struct_exists_from_hash(_struct, _tag_name_hash)
						? struct_get_from_hash(_struct, _tag_name_hash)
						: undefined;

					if (is_struct(_existing_value)) {
						_value = _existing_value;
					} else if (_instanceof != "struct") {
						var _ref = variable_global_get(_instanceof);
						_value = (_ref != undefined) ? new _ref() : {};
					} else {
						_value = {};
					}

					__decode_buffer_get_struct(_value, _buffer);
				break;

				case STAG.ARRAY:
					_value = [];
					__decode_buffer_get_array(_value, _buffer);
				break;

				case STAG.BUFFER:
					var _old_value = struct_get_from_hash(_struct, _tag_name_hash);
					if (is_buffer(_old_value)) {
						buffer_delete(_old_value);
						struct_set_from_hash(_struct, _tag_name_hash, -1);
					}
					_value = __decode_buffer_get_buffer(_buffer);
				break;

				case STAG.UNDEFINED:
					_value = undefined;
				break;
			}

			struct_set_from_hash(_struct, _tag_name_hash, _value);
			_type = __read(_buffer, buffer_u8);
		}
	}

	static __decode_buffer_get_array = function(_array, _buffer) {
		var _length = __read(_buffer, buffer_u16);

		repeat (_length) {
			var _index = __read(_buffer, buffer_u16);
			var _type = __read(_buffer, buffer_u8);
			var _value;

			switch (_type) {
				case STAG.REAL:
					_value = __decode_buffer_get_real(_buffer);
				break;

				case STAG.BOOL:
					_value = __decode_buffer_get_bool(_buffer);
				break;

				case STAG.STRING:
					_value = __decode_buffer_get_string(_buffer);
				break;

				case STAG.STRUCT:
					var _instanceof = __read(_buffer, buffer_string);
					if (_instanceof != "struct") {
						var _ref = variable_global_get(_instanceof);
						_value = (_ref != undefined) ? new _ref() : {};
					} else {
						_value = {};
					}
					__decode_buffer_get_struct(_value, _buffer);
				break;

				case STAG.ARRAY:
					_value = [];
					__decode_buffer_get_array(_value, _buffer);
				break;

				case STAG.BUFFER:
					_value = __decode_buffer_get_buffer(_buffer);
				break;

				case STAG.UNDEFINED:
					_value = undefined;
				break;
			}

			_array[_index] = _value;
		}
	}

	static __decode_buffer_get_buffer = function(_buffer) {
		var _size = __read(_buffer, SERIALIZER_BUFFER_HEADER_BUFFER_SIZE);
		var _temp_buffer = buffer_create(_size, buffer_grow, 1);
		__copy(_buffer, __tell(_buffer), _size, _temp_buffer, 0);
		__seek(_buffer, buffer_seek_relative, _size);
		return _temp_buffer;
	}

	#endregion

	#region helper

	static __write = function(_buffer, _type, _value) {
		if (real(_buffer) < 0) {
			return shm_write(_buffer, _type, _value);
		}
		return buffer_write(_buffer, _type, _value);
	}

	static __read = function(_buffer, _type) {
		if (real(_buffer) < 0) {
			return shm_read(_buffer, _type);
		}
		return buffer_read(_buffer, _type);
	}

	static __seek = function(_buffer, _base, _offset) {
		if (real(_buffer) < 0) {
			return shm_seek(_buffer, _base, _offset);
		}
		return buffer_seek(_buffer, _base, _offset);
	}

	static __tell = function(_buffer) {
		if (real(_buffer) < 0) {
			return shm_tell(_buffer);
		}
		return buffer_tell(_buffer);
	}

	static __copy = function(_src, _src_offset, _size, _dest, _dest_offset) {
		return shm_copy(_src, _src_offset, _size, _dest, _dest_offset);
	}

	static __get_size = function(_buffer) {
		if (real(_buffer) < 0) {
			return shm_get_size(_buffer);
		}
		return buffer_get_size(_buffer);
	}

	#endregion helper
}