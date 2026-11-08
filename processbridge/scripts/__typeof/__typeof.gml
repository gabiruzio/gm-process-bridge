 
function __typeof(_data){
	var _type = typeof(_data)
	switch(_type) {
		default: {
			return _type 
			} break
		case "ref": { 
			if(is_buffer(_data)) {
				return _type 
			} else {
				return "number"
			}
			} break
	}
}