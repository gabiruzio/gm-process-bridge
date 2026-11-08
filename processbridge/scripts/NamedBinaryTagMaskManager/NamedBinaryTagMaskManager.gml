 
function NamedBinaryTagMaskManager() constructor {
	
	enum NBTMASK {
		NONE,
		SPRITE
	} 
	
	static masks = [
		{ //NONE
			mask : function(_value) {
				return _value
			},
			unmask : function(_value) {
				return _value 
			}
		},
		{ //SPRITE
			mask : function(_value) {
				return sprite_get_name(_value)
			},
			unmask : function(_value) {
				return asset_get_index(_value)
			}
		},
	]
	
	static mask = function(_mask, _value) {
		return masks[_mask].mask(_value)
	}
	
	static unmask = function(_mask, _value) {
		return masks[_mask].unmask(_value)
	}
}