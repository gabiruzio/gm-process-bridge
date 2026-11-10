
#macro MAILBOX_HEADER_PACKET_SIZE 8
#macro MAILBOX_HEADER_PACKET_COUNT 20

#macro MAILBOX_HEADER_SIZE (1 + 8 + 2 + MAILBOX_HEADER_PACKET_SIZE * MAILBOX_HEADER_PACKET_COUNT) // esse final é qnts pacotes suporta por vez 
#macro MAILBOX_HEADER_PACKETS_INIT (MAILBOX_HEADER_SIZE - MAILBOX_HEADER_PACKET_SIZE * MAILBOX_HEADER_PACKET_COUNT)  

// one way 
function Mailbox( 
	_sender,
	_receiver,
	_name = -1,
	_size = 0x20000, 
	_type = MAILBOX_TYPE.MANUAL,
	_wait_behavior = MAILBOX_WAIT_BEHAVIOR.SLEEP
	) constructor {
	
	static count = 0
	count++
	
	enum MAILBOX_STATUS {
		EMPTY,
		WRITING,
		READY,
		READING
	} // ciclo 
	
	enum MAILBOX_WAIT_BEHAVIOR {
		SLEEP,
		RETURN 
	}
	
	enum MAILBOX_TYPE {
		MANUAL,
		AUTOMATIC 
	}
	
	enum MAILBOX_FLUSH_FLOW {
		MANUAL,
		AUTOMATIC 
	}
	
	enum MAILBOX_DRAIN_FLOW {
		MANUAL,
		AUTOMATIC 
	}
	
	static __mailbox_status = [
		"empty",
		"writing",
		"ready",
		"reading"
	]
	
	sender = _sender
	receiver = _receiver 
	
	if(sender == receiver) {
		show_error("Invalid mailbox: sender and receiver must be different.", true)
	}
	
	flush_flow = MAILBOX_FLUSH_FLOW.AUTOMATIC
	drain_flow = MAILBOX_DRAIN_FLOW.AUTOMATIC
	timeout = 2000 // em μs | 1000μs = 1ms 
	
	name = _name == -1? $"Local\\Mailbox.Count{count}" : _name 
	name += $".{APPKEY}"
	payload_size = _size
	size = MAILBOX_HEADER_SIZE + payload_size
	shm = shm_sync(name, size) 
	
	wait_behavior = _wait_behavior
	type = _type 
	
	scheduler = -1
	
	send_queue = []
	receive_queue = []
	
	flush_manual_packet_count = 0
	flush_manual_packet_open = false
	flush_manual_offset = 0
	
	static __loop = function(_mailbox) {
		if(APPID_SELF == _mailbox.sender) { 
			_mailbox.__flush()
		} else {  
			_mailbox.__drain()
		}
		
	}
	
	static push = function(_buffer, _owner = false, _offset = 0, _size = buffer_get_size(_buffer)) { 
		if(_size > payload_size) {
			return false
		} 
		array_push(send_queue,[_buffer, _offset, _size, _owner]) 
		return true 
	}
	
	static pull = function() { 
		var _queue = receive_queue
		receive_queue = []
		return _queue 
	}
	
	static send = function() {
		if(flush_flow == MAILBOX_FLUSH_FLOW.MANUAL) show_error("invalid flux", true)
		if(APPID_SELF != sender) return 0
		if(array_length(send_queue) <= 0) return 0
		
		var _initial_time, _elapsed_time
		_initial_time = get_timer() 
		while(true) {
			if(shm_peek(shm, 0, buffer_u8) == MAILBOX_STATUS.EMPTY) break 
 			_elapsed_time = get_timer() - _initial_time
			if(_elapsed_time >= timeout) return undefined 
			switch(wait_behavior) {
				case MAILBOX_WAIT_BEHAVIOR.SLEEP:
					thread_sleep(1)
					break 
				case MAILBOX_WAIT_BEHAVIOR.RETURN:
					return 0
					break 
			} 
		}
		
		switch(type) {
			case MAILBOX_TYPE.MANUAL: // send 
				__flush()
				break 
			case MAILBOX_TYPE.AUTOMATIC: // ignore 
				return 0
				break 
		} 
	}
	
    static receive = function() {
		if(drain_flow = MAILBOX_DRAIN_FLOW.MANUAL) show_error("invalid flux", true)
		if(type != MAILBOX_TYPE.MANUAL) {
			return 0
		}
		if(APPID_SELF != receiver) return 0
		
		var _initial_time, _elapsed_time
		_initial_time = get_timer() 
		while(true) { 
			if(shm_peek(shm, 0, buffer_u8) == MAILBOX_STATUS.READY) break 
			_elapsed_time = get_timer() - _initial_time
			if(_elapsed_time >= timeout) return undefined 
 			switch(wait_behavior) {
				case MAILBOX_WAIT_BEHAVIOR.SLEEP:
					thread_sleep(1)
					break 
				case MAILBOX_WAIT_BEHAVIOR.RETURN:
					return 0
					break 
			} 
		}
		
		switch(type) {
			case MAILBOX_TYPE.MANUAL:
				__drain()
				break 
			case MAILBOX_TYPE.AUTOMATIC: // ignore 
				return 0 
				break 
		} 
		
	} 
	
	// automatic write (copy)
	static __flush = function() { 
		if(flush_flow == MAILBOX_FLUSH_FLOW.MANUAL) return 0 
		if(APPID_SELF != sender) return 0
		if(array_length(send_queue) <= 0) return 0 
		if(shm_peek(shm, 0, buffer_u8) != MAILBOX_STATUS.EMPTY) return 0  
		//show_debug_message("flush")
		shm_seek(shm, buffer_seek_start, 0)  
		shm_poke(shm, 0, buffer_u8, MAILBOX_STATUS.WRITING)
		shm_poke(shm, 1, buffer_u64, get_timer() / 1000)   
				
		shm_seek(shm, buffer_seek_start, MAILBOX_HEADER_SIZE)  
		var _i, _offset 
		_i = 0
		_offset = MAILBOX_HEADER_SIZE
		repeat(array_length(send_queue)) {
			 
			if(shm_tell(shm) + send_queue[0][2] >= size) {
				break 
			}
			if(_i >= MAILBOX_HEADER_PACKET_COUNT) { // <- isso resolve
				break 
			}
					
			shm_poke(
				shm, 
				MAILBOX_HEADER_PACKETS_INIT + _i * MAILBOX_HEADER_PACKET_SIZE + 0,
				buffer_u32,
				shm_tell(shm)
			)
			shm_poke(
				shm, 
				MAILBOX_HEADER_PACKETS_INIT + _i * MAILBOX_HEADER_PACKET_SIZE + 4,
				buffer_u32,
				send_queue[0][2]
			)
			shm_copy(
				send_queue[0][0],
				send_queue[0][1],
				send_queue[0][2],
				shm,
				shm_tell(shm)
			) 
			shm_seek(shm, buffer_seek_relative, send_queue[0][2])
			if(send_queue[0][3]) {
				buffer_delete(send_queue[0][0])
			}
			array_delete(send_queue, 0, 1)
			_i++ 
		}
				
		shm_poke(shm, 9, buffer_u16, _i)  
		shm_poke(shm, 0, buffer_u8, MAILBOX_STATUS.READY)
	}
	
	// manual write (no copy) 
	static __flush_open = function() { 
		if(type != MAILBOX_TYPE.MANUAL) return false  
		if(APPID_SELF != sender) return false  
		if(shm_peek(shm, 0, buffer_u8) != MAILBOX_STATUS.EMPTY) return false
		
		flush_flow = MAILBOX_FLUSH_FLOW.MANUAL
		
		shm_seek(shm, buffer_seek_start, 0)  
		shm_poke(shm, 0, buffer_u8, MAILBOX_STATUS.WRITING)
		shm_poke(shm, 1, buffer_u64, get_timer() / 1000)   
				
		flush_manual_packet_count = 0
		flush_manual_offset = MAILBOX_HEADER_SIZE
		shm_seek(shm, buffer_seek_start, flush_manual_offset)  
		return true 
	}
	
	
	static __flush_packet_begin = function() {
		if(flush_manual_packet_open) return false 
		if(flush_manual_packet_count + 1 >= MAILBOX_HEADER_PACKET_COUNT) {
			return false 
		}
		flush_manual_packet_open = true 
		return true 
	}
	
	static __flush_packet_get_offset = function() {
		if(!flush_manual_packet_open) return false 
		return flush_manual_offset
	} 
	
	static __flush_packet_commit = function(_size = shm_tell(shm) - flush_manual_offset) { 
		if(!flush_manual_packet_open) return false 
		if(flush_manual_offset + _size >= size) {
			return false 
		}
		if(_size <= 0) {
			show_error("invalid size", true)
		}
		shm_poke(
			shm, 
			MAILBOX_HEADER_PACKETS_INIT + flush_manual_packet_count * MAILBOX_HEADER_PACKET_SIZE + 0,
			buffer_u32,
			flush_manual_offset
		)
		shm_poke(
			shm, 
			MAILBOX_HEADER_PACKETS_INIT + flush_manual_packet_count * MAILBOX_HEADER_PACKET_SIZE + 4,
			buffer_u32,
			_size
		)
		
		flush_manual_packet_open = false 
		flush_manual_offset += _size 
		flush_manual_packet_count++
		shm_seek(shm, buffer_seek_start, flush_manual_offset)  
		return true 
	} 
	
	static __flush_close = function() {
		if(flush_flow != MAILBOX_FLUSH_FLOW.MANUAL) return false
		flush_flow = MAILBOX_FLUSH_FLOW.AUTOMATIC
		shm_poke(shm, 9, buffer_u16, flush_manual_packet_count)  
		shm_poke(shm, 0, buffer_u8, MAILBOX_STATUS.READY) 
	}
	
	// automatic 
	static __drain = function() {
		if(drain_flow == MAILBOX_DRAIN_FLOW.MANUAL) return 0
		if(APPID_SELF != receiver) return 0 
		if(shm_peek(shm, 0, buffer_u8) != MAILBOX_STATUS.READY) return 0 
		//show_debug_message("drain")
		var _time 
		shm_poke(shm, 0, buffer_u8, MAILBOX_STATUS.READING)
		_time = shm_peek(shm, 1, buffer_u64) 
		
		var _i, _offset, _size, _buffer, _list
		_list = []
		_i = -1
		repeat(shm_peek(shm, 9, buffer_u16)) {
			_i++
			_offset = shm_peek(
				shm, 
				MAILBOX_HEADER_PACKETS_INIT + _i * MAILBOX_HEADER_PACKET_SIZE + 0,
				buffer_u32
			)
			_size = shm_peek(
				shm, 
				MAILBOX_HEADER_PACKETS_INIT + _i * MAILBOX_HEADER_PACKET_SIZE + 4,
				buffer_u32
			)
				 
			_buffer = buffer_create(_size, buffer_fixed, 1)
					
			shm_copy(
				shm,
				_offset,
				_size,
				_buffer,
				0
			)
			//show_debug_message($"{_i}:{_buffer}: {buffer_get_size(_buffer)}")
			array_push(receive_queue, _buffer)
		} 
		shm_poke(shm, 1, buffer_u64, get_timer()/1000)
		shm_poke(shm, 0, buffer_u8, MAILBOX_STATUS.EMPTY)
	}
	 
	drain_manual_packet_current = -1
	drain_manual_packet_offset = 0
	drain_manual_packet_size = 0
	drain_manual_packet_count = 0
	drain_manual_packet_open = false 
	
	static __drain_open = function() {  
		if(type != MAILBOX_TYPE.MANUAL) return false  
		if(APPID_SELF != receiver) return false  
		if(shm_peek(shm, 0, buffer_u8) != MAILBOX_STATUS.READY) return false 
		drain_flow = MAILBOX_DRAIN_FLOW.MANUAL
		shm_poke(shm, 0, buffer_u8, MAILBOX_STATUS.READING)
		drain_manual_packet_current = -1
		drain_manual_packet_count = shm_peek(shm, 9, buffer_u16)
		drain_manual_packet_offset = -1 
		drain_manual_packet_size = -1
		 
		return true 
	}
	
	static __drain_packet_begin = function() {
		if(drain_manual_packet_open) return false 
		if(drain_manual_packet_current + 1 >= drain_manual_packet_count) return false 
		drain_manual_packet_current++
		
		drain_manual_packet_offset = shm_peek(
			shm, 
			MAILBOX_HEADER_PACKETS_INIT + drain_manual_packet_current * MAILBOX_HEADER_PACKET_SIZE + 0,
			buffer_u32
		)
		drain_manual_packet_size = shm_peek(
			shm, 
			MAILBOX_HEADER_PACKETS_INIT + drain_manual_packet_current * MAILBOX_HEADER_PACKET_SIZE + 4,
			buffer_u32
		)
		
		drain_manual_packet_open = true 
		
		return true 
	}
	
	static __drain_packet_get_offset = function() {
		return drain_manual_packet_offset
	} 
	
	static __drain_packet_get_size = function() {
		return drain_manual_packet_size
	} 
	
	static __drain_packet_commit = function() { 
		if(!drain_manual_packet_open) return false 
		drain_manual_packet_open = false  
		drain_manual_packet_offset = -1 
		drain_manual_packet_size = -1
	} 
	
	static __drain_close = function() { 
		if(drain_flow != MAILBOX_DRAIN_FLOW.MANUAL) return 0
		drain_flow = MAILBOX_DRAIN_FLOW.AUTOMATIC
		shm_poke(shm, 1, buffer_u64, get_timer()/1000)
		shm_poke(shm, 0, buffer_u8, MAILBOX_STATUS.EMPTY) 
	}
	
	if(type == MAILBOX_TYPE.AUTOMATIC) {
		
		scheduler = time_source_create(
			time_source_global,
			1/60,
			time_source_units_seconds,
			__loop,
			[self],
			-1
		)
		time_source_start(scheduler)
	}
}
