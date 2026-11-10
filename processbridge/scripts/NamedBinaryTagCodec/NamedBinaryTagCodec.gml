
#macro NBT_DEFAULT_SIZE_IN_BYTES _128KB
#macro NBT_BUFFER_HEADER_BUFFER_SIZE buffer_u32

#macro SERIALIZER_ERROR show_error(noyetimpl, true)
function NamedBinaryTagCodec() constructor {
	
	// abstração  
	
	static __write = function(_buffer, _type, _value) {
		if(real(_buffer) < 0) {
			return shm_write(_buffer, _type, _value)
		}
		return buffer_write(_buffer, _type, _value)
	}
	static __read = function(_buffer, _type) {
		if(real(_buffer) < 0) {
			return shm_read(_buffer, _type)
		}
		return buffer_read(_buffer, _type)
	}
	static __seek = function(_buffer, _base, _offset) {
		if(real(_buffer) < 0) {
			return shm_seek(_buffer, _base, _offset)
		}
		return buffer_seek(_buffer, _base, _offset)
	}
	
	/*
		versao 2
		data 14/08/2024
		
		versao 3
		data 07/19/2025
	*/ 
	
	enum TAG {
		END,		// marca o final da struct
		REAL,		// (tipo[u8]) (tamanho nome[16u]) (nome[...]) (conteudo[32s])
		BOOL,		// (tipo[u8]) (tamanho nome[16u]) (nome[...]) (conteudo[u8])
		STRING,		// (tipo[u8]) (tamanho nome[16u]) (nome[...]) (comprimento[16u]) (conteudo[...])
		STRUCT,		// (tipo[u8]) (tamanho nome[16u]) (nome[...]) (conteudo[...])
		ARRAY,		// (tipo[u8]) (tamanho nome[16u]) (nome[...]) (comprimento[16u]) (conteudo[...])
		BUFFER,		// (tipo[u8]) (tamanho nome[16u]) (nome[...]) (comprimento[16u]) (conteudo[...])
		UNDEFINED,	// (tipo[u8]) (tamanho nome[16u]) (nome[...]) 
	}
	
	//DEBUG = false 
	
	static filter_manager = new NamedBinaryTagFilterManager()
	static mask_manager = new NamedBinaryTagMaskManager()
	
	static encode = function(_struct, _ignore_internal_variables = false, _filter = "", _destination = undefined) {  
		//gml_pragma("forceinline")
		
		if(_destination == undefined) {
		
			var _buffer 
			_buffer = buffer_create(NBT_DEFAULT_SIZE_IN_BYTES, buffer_grow, 1)  
			buffer_seek(_buffer, buffer_seek_start, 0)
		 
			__encode_buffer_write_struct_content(_buffer, _struct, _ignore_internal_variables, _filter)
			var _tell
			_tell = buffer_tell(_buffer)
		
			buffer_resize(_buffer, _tell)
			buffer_seek(_buffer, buffer_seek_end, 0)
		 
			return _buffer
		} else {
			__encode_buffer_write_struct_content(_destination, _struct, _ignore_internal_variables, _filter)
		}
		return undefined 
	}
	
	static __encode_buffer_write_tag_name = function(_buffer, _type, _mask, _tag_name) {
		//gml_pragma("forceinline")
		//if(DEBUG) {
		//	print($" -> {buffer_tell(_buffer)} {_type} {_tag_name}")
		//}
		__write(_buffer, buffer_u8, _type) 
		
		__write(_buffer, buffer_u8, _mask) 
		
		__write(_buffer, buffer_string, _tag_name)
		
	}
	static __econde_buffer_write_real = function(_buffer, _value) {
		//gml_pragma("forceinline")
		__write(_buffer, buffer_f32, _value)
	}
	static __econde_buffer_write_bool = function(_buffer, _bool) {
		//gml_pragma("forceinline")
		__write(_buffer, buffer_u8, _bool)
	}
	static __encode_buffer_write_string = function(_buffer, _string) { 
		//gml_pragma("forceinline")
		__write(_buffer, buffer_string, _string)
	}
	static __encode_buffer_write_array_index = function(_buffer, _index, _type, _mask) {
		//gml_pragma("forceinline")
		__write(_buffer, buffer_u16, _index)
		__write(_buffer, buffer_u8, _type)
		__write(_buffer, buffer_u8, _mask)
	}
	static __encode_buffer_write_array_length = function(_buffer, _length) {
		//gml_pragma("forceinline")
		__write(_buffer, buffer_u16, _length)
	}
	/// @desc Resolve um filtro redirector; retorna vazio quando o valor nao e permitido.
	static __redirect_filter_resolve = function(_redirect_filter, _value) {
		if(_redirect_filter == undefined || _redirect_filter.type != NBTFILTER_TYPE.VALUE_BASEAD_REDIRECTER_FILTER) return ""
		for(var _i = 0; _i < _redirect_filter.list_length; _i++) {
			var _element = _redirect_filter.list[_i]
			var _hash = variable_get_hash(_element.name)
			if(struct_exists_from_hash(_value, _hash) && struct_get_from_hash(_value, _hash) == _element.value) {
				return _element.filter
			}
		}
		return ""
	}
	static __encode_buffer_write_array_content = function(_buffer, _array, _ignore_internal_variables, _filter) {
		//gml_pragma("forceinline")
		var _array_length 
		_array_length = array_length(_array)
		
		var  _value_mask, _filter_instance, _filter_is_valid, _filter_element, _arr_lenght_with_filter = 0
		_filter_instance = filter_manager.get(_filter)
		_filter_is_valid = _filter_instance != undefined 
		
		var _i, _value, _value_type
		_i = 0
		repeat(_array_length) {
		//for(var _i = 0; _i < _array_length; _i++) {
			_value = _array[_i]
			_value_type = __typeof(_value) 
			
			if(_filter_is_valid) {   
				_filter_element = _filter_instance.find_by_type(_value_type) // "find" e mais rapido que "get"
				if(_filter_element == -1) {
					_i++
					continue 
				}
				_filter_element = _filter_instance.get_by_type(_value_type)
				var _redirect_filter = filter_manager.get(_filter_element.filter)
				if(_value_type == "struct" && _redirect_filter != undefined
				&& _redirect_filter.type == NBTFILTER_TYPE.VALUE_BASEAD_REDIRECTER_FILTER
				&& __redirect_filter_resolve(_redirect_filter, _value) == "") {
					show_debug_message($"NBT: ignorando struct sem filtro no redirector '{_filter_element.filter}'")
					_i++
					continue
				}
			}
			
			_arr_lenght_with_filter++
			_i++
		}
		
		__encode_buffer_write_array_length(_buffer, _arr_lenght_with_filter)
		
		_i = 0
		repeat(_array_length) {
		//for(var _i = 0; _i < _array_length; _i++) {
			_value = _array[_i]
			_value_type = __typeof(_value)
			
			if(_filter_is_valid) {
				_filter_element = _filter_instance.get_by_type(_value_type)
				if(_filter_element == undefined) {
					_i++
					continue 
				}
				var _redirect_filter = filter_manager.get(_filter_element.filter)
				if(_value_type == "struct" && _redirect_filter != undefined
				&& _redirect_filter.type == NBTFILTER_TYPE.VALUE_BASEAD_REDIRECTER_FILTER
				&& __redirect_filter_resolve(_redirect_filter, _value) == "") {
					_i++
					continue
				}
			} 
			
			_value = _filter_is_valid ? mask_manager.mask(_filter_element.mask, _array[_i]) : _array[_i]
			_value_type = __typeof(_value) 
			
			_value_mask = _filter_is_valid ? _filter_element.mask : NBTMASK.NONE
			
			switch(_value_type) {
				case "method": // deve ser ignorado
					
				break 
				case "number":  
				case "int32":  
				case "int64":
					__encode_buffer_write_array_index(_buffer, _i, TAG.REAL, _value_mask) 
					__econde_buffer_write_real(_buffer, _value)
				break 
				case "bool":
					__encode_buffer_write_array_index(_buffer, _i, TAG.BOOL, _value_mask)
					__econde_buffer_write_bool(_buffer, _value)
				break  
				case "string":  
					__encode_buffer_write_array_index(_buffer, _i, TAG.STRING, _value_mask)
					__encode_buffer_write_string(_buffer, _value)
				break 
				case "array":  
				case "vec3":  
				case "vec4":  
					__encode_buffer_write_array_index(_buffer, _i, TAG.ARRAY, _value_mask)
					__encode_buffer_write_array_content(_buffer, _value, _ignore_internal_variables, _filter_is_valid ? _filter_element.filter : "")
				break 
				case "struct":  
					__encode_buffer_write_array_index(_buffer, _i, TAG.STRUCT, _value_mask)
					//__encode_buffer_write_struct_content(_buffer, _value, _ignore_internal_variables, _filter_is_valid ? _filter_element.filter : "")
					//show_message(_filter_element)
					var _f_set, _f_type 
					_f_set = _filter_is_valid ? filter_manager.get(_filter_element.filter) : ""
					_f_type = _filter_is_valid && _f_set != undefined ? _f_set.type : ""
					//show_message(_f_set)
					switch(_f_type) {
						default:
							__encode_buffer_write_struct_content(_buffer, _value, _ignore_internal_variables, _filter_is_valid ? _filter_element.filter : "")
							break 
						case NBTFILTER_TYPE.NAMED_MASK_FILTER:
							__encode_buffer_write_struct_content(_buffer, _value, _ignore_internal_variables, _filter_element.filter) // passa o filtro associado 
							break 
						case NBTFILTER_TYPE.VALUE_BASEAD_REDIRECTER_FILTER:
							var _fvbr_filter_result = __redirect_filter_resolve(_f_set, _value)
							__encode_buffer_write_struct_content(_buffer, _value, _ignore_internal_variables, _fvbr_filter_result)
							break
					}
				break  
				case "ref":  
					__encode_buffer_write_array_index(_buffer, _i, TAG.BUFFER, _value_mask)
					__encode_buffer_write_buffer(_buffer, _value) 
				break  
				case "undefined":  
					__encode_buffer_write_array_index(_buffer, _i, TAG.UNDEFINED, _value_mask)
				break  
			} 
			_i++
		}
	}
	 
	static __encode_buffer_write_struct_content = function(_buffer, _struct, _ignore_internal_variables, _filter) {
		//gml_pragma("forceinline")
		//print("write struct")
		//print(_struct)
		
		var _variables, _variable_name, _variables_count, _variable_name_hash, _value, _value_type, _value_mask, _filter_instance, _filter_is_valid, _filter_element = undefined
		_filter_instance = filter_manager.get(_filter) 
		_filter_is_valid = _filter_instance != undefined   
		
		
		_variables = _filter_is_valid ? 0 : struct_get_names(_struct) 
		_variables_count = _filter_is_valid ? _filter_instance.list_length : array_length(_variables)
		//show_debug_message(instanceof(_struct))
		__write(_buffer, buffer_string, instanceof(_struct))
		//print($"filter => {_filter} | {_filter_instance}") 
		//print(instanceof(_struct)) 
		var _i 
		 _i = 0
		repeat(_variables_count) {
			//print($"repeat {_i}")
		//for(var _i = 0; _i < _variables_count; _i++) {
			_variable_name = _filter_is_valid ? _filter_instance.list[_i].name : _variables[_i]  
			
			_variable_name_hash = variable_get_hash(_variable_name)
			 
			if(!_filter_is_valid && _ignore_internal_variables && string_length(_variable_name) >= 2) {
				if(string_char_at(_variable_name, 1) == "_" && string_char_at(_variable_name, 2) == "_") {
					_i++
					continue 
				}
			}
			
			if(_filter_is_valid) {   
				_filter_element = _filter_instance.get_by_name(_variable_name)
				if(_filter_element == undefined) { 
					_i++
					continue 
				}
			}
			
			//print($"write => {_variable_name}")
			
			_value = _filter_is_valid ? mask_manager.mask(_filter_element.mask, struct_get_from_hash(_struct, _variable_name_hash)) : struct_get_from_hash(_struct, _variable_name_hash)
			_value_type = __typeof(_value) 
			_value_mask = _filter_is_valid ? _filter_element.mask : NBTMASK.NONE
			
			 
			switch(_value_type) {
				case "method": // deve ser ignorado
					
				break 
				case "number":  
				case "int32":  
				case "int64":  
					 
					__encode_buffer_write_tag_name(_buffer, TAG.REAL, _value_mask, _variable_name)
					 
					__econde_buffer_write_real(_buffer, _value) 
					 
				break 
				case "bool":
					__encode_buffer_write_tag_name(_buffer, TAG.BOOL, _value_mask, _variable_name)
					__econde_buffer_write_bool(_buffer, _value)
				break  
				case "string":  
					__encode_buffer_write_tag_name(_buffer, TAG.STRING, _value_mask, _variable_name)
					__encode_buffer_write_string(_buffer, _value)
				break 
				case "array":  
				case "vec3":  
				case "vec4":  
					//print("write array")
					__encode_buffer_write_tag_name(_buffer, TAG.ARRAY, _value_mask, _variable_name)
					__encode_buffer_write_array_content(_buffer, _value, _ignore_internal_variables, _filter_is_valid ? _filter_element.filter : "") // passa o filtro associado 
				break 
				case "struct":  
					var _f_set, _f_type 
					_f_set = _filter_is_valid ? filter_manager.get(_filter_element.filter) : "" 
					_f_type = _filter_is_valid && _f_set != undefined ? _f_set.type : ""
					var _fvbr_filter_result = _f_type == NBTFILTER_TYPE.VALUE_BASEAD_REDIRECTER_FILTER
						? __redirect_filter_resolve(_f_set, _value) : ""
					if(_f_type == NBTFILTER_TYPE.VALUE_BASEAD_REDIRECTER_FILTER && _fvbr_filter_result == "") {
						show_debug_message($"NBT: ignorando struct '{_variable_name}' sem filtro no redirector '{_filter_element.filter}'")
						break
					}
					__encode_buffer_write_tag_name(_buffer, TAG.STRUCT, _value_mask, _variable_name)
					//show_message(_f_set)
					switch(_f_type) {
						default:
							__encode_buffer_write_struct_content(_buffer, _value, _ignore_internal_variables, _filter_is_valid ? _filter_element.filter : "")
							break 
					case NBTFILTER_TYPE.NAMED_MASK_FILTER:
						__encode_buffer_write_struct_content(_buffer, _value, _ignore_internal_variables, _filter_element.filter) // passa o filtro associado
						break
					case NBTFILTER_TYPE.VALUE_BASEAD_REDIRECTER_FILTER:
						__encode_buffer_write_struct_content(_buffer, _value, _ignore_internal_variables, _fvbr_filter_result)
						break
					}
				break 
				case "ref":  
					
					//print("write buffer")
					__encode_buffer_write_tag_name(_buffer, TAG.BUFFER, _value_mask, _variable_name)
					__encode_buffer_write_buffer(_buffer, _value)
					 
				break  
				case "undefined":  
					__encode_buffer_write_tag_name(_buffer, TAG.UNDEFINED, _value_mask, _variable_name)
				break  
			}  
			_i++
		} 
		__encode_buffer_write_struct_end(_buffer) 
	} 
	static __encode_buffer_write_struct_end = function(_buffer) {
		//gml_pragma("forceinline")
		__write(_buffer, buffer_u8, TAG.END) 
	}
	static __encode_buffer_write_buffer = function(_buffer, _buffer_source) { SERIALIZER_ERROR 
		//gml_pragma("forceinline")\
		
		//buffer_write_buffer(_buffer, _buffer_source)
		
		var _size 
		_size = buffer_get_size(_buffer_source) 
		buffer_write(_buffer, NBT_BUFFER_HEADER_BUFFER_SIZE, _size) 
		buffer_copy(_buffer_source, 0, _size, _buffer, buffer_tell(_buffer)) 
		buffer_seek(_buffer, buffer_seek_relative, _size)
		 
	}
 
	
	static decode = function(_buffer, _offset = 0) {
		//gml_pragma("forceinline")
		
		
		__seek(_buffer, buffer_seek_start, _offset)
		
		var _instanceof, _ref, _struct
		_instanceof = __read(_buffer, buffer_string) 
		if(_instanceof != "struct") {
			//show_debug_message($"-> {_instanceof}")
			_ref = variable_global_get(_instanceof)
			if(_ref != undefined) { 
				_struct = new _ref() 
				
				//show_message(_ref) 
				//show_message(_struct) 
			} else {
				_struct = {}
			}
		} else {
			_struct = {}
		} 
		 
		__decode_buffer_get_struct(_struct, _buffer, NBTMASK.NONE)  
		return _struct
	}
	
	static __decode_buffer_get_tag_name = function(_buffer) {  
		//gml_pragma("forceinline")
		 
		var _tag_name  
		_tag_name = __read(_buffer, buffer_string)
		
		return _tag_name
	}
	static __decode_buffer_get_real = function(_buffer, _mask) {
		//gml_pragma("forceinline")
		return mask_manager.unmask(_mask, __read(_buffer, buffer_f32))
	}
	static __decode_buffer_get_bool = function(_buffer, _mask) {
		//gml_pragma("forceinline")
		return mask_manager.unmask(_mask, __read(_buffer, buffer_u8))
	}
	static __decode_buffer_get_string = function(_buffer, _mask) {
		//gml_pragma("forceinline")
		return mask_manager.unmask(_mask, __read(_buffer, buffer_string))
	}
	static __decode_buffer_get_struct = function(_struct, _buffer, _mask) { 
		//gml_pragma("forceinline")
		var _instanceof, _type, _value_mask, _value, _tag_name, _tag_name_hash
		
		 
		
		//variable_global_get("Pineapple")
		
		_type = __read(_buffer, buffer_u8)
		//_value_mask = buffer_read(_buffer, buffer_u8)
		 
		while(_type != TAG.END) {    
			//var _tell = buffer_tell(_buffer)
			
			_value_mask = __read(_buffer, buffer_u8)
			_tag_name = __decode_buffer_get_tag_name(_buffer) 
			_tag_name_hash = variable_get_hash(_tag_name)
			 
			//if(DEBUG) {
			//	print($" -> {_tell} {_type} {_tag_name}")
			//}
			/*if(struct_exists_from_hash(_struct, _tag_name_hash)) {
				var _value = struct_get_from_hash(_struct, _tag_name_hash)
				if(is_buffer(_value)) {
					buffer_delete(_value) 
					struct_set_from_hash(_struct, _tag_name_hash, -1)
				}
			}*/
			
			switch(_type) {
				case TAG.END:
					
					break
				case TAG.REAL:
					_value = __decode_buffer_get_real(_buffer, _value_mask)
					break
				case TAG.BOOL:
					_value = __decode_buffer_get_bool(_buffer, _value_mask)
					break
				case TAG.STRING:
					_value = __decode_buffer_get_string(_buffer, _value_mask)
					break
				case TAG.STRUCT: // e MUITO importante ver se ja existe, evitar vazamento 
					var _instanceof, _ref
					_instanceof = __read(_buffer, buffer_string)
					
					// A constructor may declare an optional persisted field as
					// undefined. If an older save contains a struct for that field,
					// it exists by name but still cannot be used as the decode target.
					// Recreate the saved struct instead of recursing into undefined.
					_value = struct_exists_from_hash(_struct, _tag_name_hash)
						? struct_get_from_hash(_struct, _tag_name_hash)
						: undefined
					if(!is_struct(_value)) {
						if(_instanceof != "struct") {
							_ref = variable_global_get(_instanceof)
							if(_ref != undefined) {
								_value = new _ref() 
							} else {
								_value = {}
							}
						} else {
							_value = {}
						}
					}
					__decode_buffer_get_struct(_value, _buffer, _value_mask)
					
					break
				case TAG.ARRAY:
                    /*_value = struct_get_from_hash(_struct, _tag_name_hash)
                    if(is_array(_value)) {
    					for(var __i = 0; __i < array_length(_value); __i++) {
    						if(is_buffer(_value[__i])) {
    							buffer_delete(_value[__i])
    							_value[__i] = -1
    						}
    					}
                    }*/
					_value = []
					__decode_buffer_get_array(_value, _buffer, _value_mask)
					break
				case TAG.BUFFER: SERIALIZER_ERROR 
					var _old_value 
					_old_value = struct_get_from_hash(_struct, _tag_name_hash) 
					
					if(is_buffer(_old_value)) {
						buffer_delete(_old_value) 
						struct_set_from_hash(_struct, _tag_name_hash, -1) 
						//print($"deletei {_tag_name}")
					}
					//print($"aqui {_tag_name}")
					_value = __decode_buffer_get_buffer(_buffer, _value_mask)
					break 
				case TAG.UNDEFINED:
					_value = undefined 
					break
			}
			
			struct_set_from_hash(_struct, _tag_name_hash, _value) 
			
			_type = __read(_buffer, buffer_u8) 
			 
		} 
		
		//if((global.game_context == GAME_CONTEXT.SERVER || global.game_context == GAME_CONTEXT.SEIDE || global.game_context == GAME_CONTEXT.INITIALIZATION)) { 
			//show_debug_message(instanceof(_struct))
			//if(instanceof(_struct) == "StructureResourceDatabase") {
			//	show_message("here")
			//}
			//show_message(struct_exists_from_hash(_struct, variable_get_hash("__internal__on_load")))
			if(struct_exists_from_hash(_struct, variable_get_hash("__internal__on_load"))) { // on_load 
				_struct.__internal__on_load()
			}
		//}
		
		if(struct_exists_from_hash(_struct, variable_get_hash("__internal__on_deserialize"))) { // on_deserialize 
			_struct.__internal__on_deserialize()
		}
	}
	static __decode_buffer_get_array = function(_array, _buffer, _mask) { 
		//gml_pragma("forceinline")
		var _length = __read(_buffer, buffer_u16), _index
		var _type, _value_mask, _value , _tag_name 
		
		repeat(_length) {
			_index = __read(_buffer, buffer_u16) 
			_type = __read(_buffer, buffer_u8)  
			_value_mask = __read(_buffer, buffer_u8)   
			
			// apagar buffer existente no index
			/*if(_index >= 0 && _index < _length && _index < array_length(_array)) {
                if(is_buffer(_array[_index])) {
                    buffer_delete(_array[_index])
                    _array[_index] = -1
                }
            }*/
			
			switch(_type) {
				case TAG.END:
					
					break
				case TAG.REAL:
					_value = __decode_buffer_get_real(_buffer, _value_mask)
					break
				case TAG.BOOL:
					_value = __decode_buffer_get_bool(_buffer, _value_mask)
					break
				case TAG.STRING:
					_value = __decode_buffer_get_string(_buffer, _value_mask)
					break
				case TAG.STRUCT:  
					var _instanceof, _ref 
					_instanceof = __read(_buffer, buffer_string) 
					if(_instanceof != "struct") {
						_ref = variable_global_get(_instanceof) 
						if(_ref != undefined) {
							_value = new _ref() 
						} else {
							_value = {}
						}
					} else {
						_value = {}
					}  
					
					__decode_buffer_get_struct(_value, _buffer, _value_mask)
					break
				case TAG.ARRAY:
                    /*if(_index >= 0 && _index < _length && _index < array_length(_array)) {
                        _value = _array[_index]
                        if(is_array(_value)) {
        					for(var __i = 0; __i < array_length(_value); __i++) {
        						if(is_buffer(_value[__i])) {
        							buffer_delete(_value[__i])
        							_value[__i] = -1
        						}
        					}
                         }
                    }*/
					_value = []
					__decode_buffer_get_array(_value, _buffer, _value_mask)
					break
				case TAG.BUFFER: 
					_value = __decode_buffer_get_buffer(_buffer, _value_mask)
					break 
				case TAG.UNDEFINED:
					_value = undefined 
					break
			}  
			_array[ _index] = _value 
		}
	} 
	static __decode_buffer_get_buffer = function(_buffer, _value_mask) { SERIALIZER_ERROR
		//gml_pragma("forceinline")
		var _size = buffer_read(_buffer, NBT_BUFFER_HEADER_BUFFER_SIZE)
		 
		var _temp_buffer = buffer_create(_size, buffer_grow, 1)
		buffer_copy(_buffer, buffer_tell(_buffer), _size, _temp_buffer, 0)
		buffer_seek(_buffer, buffer_seek_relative, _size)
		return _temp_buffer
	}
	
}
