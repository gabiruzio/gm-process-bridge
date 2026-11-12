function DuplexChannel(
    _name = -1,
    _size = 0x20000,
    _type = CHANNEL_TYPE.MANUAL,
    _wait_behavior = CHANNEL_WAIT_BEHAVIOR.SLEEP
) constructor {

    type = _type;
	
    var _c2m_name = _name;
    var _m2c_name = _name;

    if (_name != -1) {
        _c2m_name = string(_name) + ".c2m"
        _m2c_name = string(_name) + ".m2c"
    }

    // Core -> Main
    c2m = new SimplexChannel(
        APPID_CORE,
        APPID_MAIN,
        _c2m_name,
        _size,
        _type,
        _wait_behavior
    )

    // Main -> Core
    m2c = new SimplexChannel(
        APPID_MAIN,
        APPID_CORE,
        _m2c_name,
        _size,
        _type,
        _wait_behavior
    )

	
    incoming = APPID_SELF == c2m.receiver ? c2m : m2c 
    outgoing = APPID_SELF == c2m.sender ? c2m : m2c

    // Queue

    static push = function(
        _buffer,
        _owner = false,
        _offset = 0,
        _size = buffer_get_size(_buffer)
    ) {
        return outgoing.push(_buffer, _owner, _offset, _size)
    }

    static pull = function() {
        return incoming.pull()
    }
	
    static send = function() {
        return outgoing.send()
    }

    static receive = function() {
        return incoming.receive()
    }

    static __flush = function() {
        return outgoing.__flush()
    }
	
    static __flush_open = function() {
        return outgoing.__flush_open()
    }
	
    static __flush_get_buffer = function() {
        return outgoing.__flush_get_buffer()
    }
	
    static __flush_packet_begin = function() {
        return outgoing.__flush_packet_begin()
    }
	
    static __flush_packet_get_offset = function() {
        return outgoing.__flush_packet_get_offset()
    }
	
    static __flush_packet_commit = function(
        _size = shm_tell(outgoing.shm) - outgoing.flush_manual_offset
    ) {
        return outgoing.__flush_packet_commit(_size)
    }
	
    static __flush_close = function() {
        return outgoing.__flush_close()
    }
	
    static __drain = function() {
        return incoming.__drain()
    }

    static __drain_open = function() {
        return incoming.__drain_open()
    }

    static __drain_get_buffer = function() {
        return incoming.__drain_get_buffer()
    }

    static __drain_packet_begin = function() {
        return incoming.__drain_packet_begin()
    }

    static __drain_packet_get_offset = function() {
        return incoming.__drain_packet_get_offset()
    }
	
    static __drain_packet_get_size = function() {
        return incoming.__drain_packet_get_size()
    }
	
    static __drain_packet_commit = function() {
        return incoming.__drain_packet_commit()
    }
	
    static __drain_close = function() {
        return incoming.__drain_close()
    }

    static destroy = function() {
        c2m.destroy()
        m2c.destroy()
    }
}