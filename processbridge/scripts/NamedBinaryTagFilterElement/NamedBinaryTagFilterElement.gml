 
function NamedBinaryTagFilterElement(_element) constructor {
	name = _element[0]
	type = _element[0]
	mask = is_string(_element[1]) ? NBTMASK.NONE : _element[1]
	filter = is_string(_element[1]) ? _element[1] : ""
	
	//["__class", "mushroom", "mushroom"],
	value = _element[1]
	if(array_length(_element) >= 3) {
		filter = _element[2]
	}
}
