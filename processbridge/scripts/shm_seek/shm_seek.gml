function shm_seek(_id, _base, _offset)
{
    var _native_base;

    switch (_base)
    {
        case buffer_seek_start:
            _native_base = 0;
            break;

        case buffer_seek_relative:
            _native_base = 1;
            break;

        case buffer_seek_end:
            _native_base = 2;
            break;

        default:
            return -4;
    }

    return __shm_seek(-_id, _native_base, _offset);
}