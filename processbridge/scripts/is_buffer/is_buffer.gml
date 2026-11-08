  
function is_buffer(_value) { 
	return !is_string(_value) && !is_array(_value) && buffer_exists(_value)  
}