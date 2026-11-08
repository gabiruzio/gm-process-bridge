
function NamedBinaryTagFilterManager() constructor {
	
	filters = {} 
	//filters_count = 0
	
	static create = function(_filter_name, _list) {
		if(_filter_name == "") {
			show_error("invalid filter name", true)
		}
		
		var _name_of_new = _filter_name
		var _names = string_split(_filter_name, ":", true) 
		var _type
		var _superclasses = []
		 
		if(array_length(_names) > 0) {
			for(var _i = 1; _i < array_length(_names); _i++) {
				 
				//if(find(_names[_i]) == -1) {
				if(!struct_exists_from_hash(filters, variable_get_hash(_names[_i]))) {
					show_error($"super filter {_names[_i]} no exists", true)
				} else {
					array_push(_superclasses, get(_names[_i]))
				}
			} 
			_name_of_new = _names[0]
		} else {
			_name_of_new = _filter_name
		}
		
		//if(find(_name_of_new) != -1) {
		if(struct_exists_from_hash(filters, variable_get_hash(_name_of_new))) {
			show_error("filter already exits", true)
		} 
		
		switch(array_length(_list[0])) {
			case 3:
				_type = NBTFILTER_TYPE.VALUE_BASEAD_REDIRECTER_FILTER
				break 
			case 2:
				if(is_string(_list[0][1])) {
					_type = NBTFILTER_TYPE.STRUCT_ARRAY_REDIRECTER
				} else {
					_type = NBTFILTER_TYPE.NAMED_MASK_FILTER
				}
				break 
		} 
		
		//verify if parents are of the same type
		/*for(var _i = 0; _i < array_length(_superclasses); _i++) {
			if(_superclasses[_i].type != _type) {
				show_error($"type filter parent {_superclasses[_i].name} is diferent of {_filter_name}", true)
			}
		}*/
		
		var _filter = new NamedBinaryTagFilter(_name_of_new, _type, _list, _superclasses)
		
		struct_set_from_hash(filters, variable_get_hash(_name_of_new), _filter)
		
		//array_push(filters, _filter)
		
		//filters_count++
		return _filter
	}
	
	static get = function(_filter_name) {
		if(_filter_name == "") {
			return undefined 
		} 
		//var _filter_index = struct_exists_from_hash(filters, variable_get_hash(_filter_name)) //find(_filter_name) 
		
		//if(!_filter_index ) {
		//	return undefined 
		//}
		
		return struct_get_from_hash(filters, variable_get_hash(_filter_name)) //filters[_filter_index]
	} 
}