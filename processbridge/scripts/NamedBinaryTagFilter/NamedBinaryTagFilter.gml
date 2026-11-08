 
function NamedBinaryTagFilter(_name, _type, _list, _super_filter) constructor {
	
	enum NBTFILTER_TYPE {
		NAMED_MASK_FILTER,
		STRUCT_ARRAY_REDIRECTER,
		
		VALUE_BASEAD_REDIRECTER_FILTER,
		VALUE_AUTOMATIC_BASED_REDIRECTER_FILTER
	}
	
	type = _type
	name = _name
	list = []
	list_length = 0
	
	for(var _k = 0; _k < array_length(_super_filter); _k++) {
		for(var _i = 0; _i < array_length(_super_filter[_k].list); _i++) {
			array_push(list, _super_filter[_k].list[_i])
		}
	}
	
	for(var _i = 0; _i < array_length(_list); _i++) {
		array_push(list, new NamedBinaryTagFilterElement(_list[_i]))
		
	}
	
	list_length = array_length(list)
	
	static get_by_name = function(_name) {
		var _index = find_by_name(_name) 
		if(_index == -1) {
			return undefined 
		}
		return list[_index]
	}
	
	static find_by_name = function(_name) {
		var _i = 0
		repeat(list_length) {
			if(list[_i].name == _name) {
				return _i 
			}
			_i++
		}
		return -1
	}
	
	static get_by_type = function(_type) {
		var _index = find_by_type(_type)
		if(_index == -1) {
			return undefined 
		}
		return list[_index]
	}
	
	static find_by_type = function(_type) {
		var _i = 0
		repeat(list_length) {
			if(list[_i].type == _type) {
				return _i
			} 
			_i++
		}
		return -1
	}  
	
	static add = function(_element) {
		array_push(list, new NamedBinaryTagFilterElement(_element))
		list_length++
	}
}