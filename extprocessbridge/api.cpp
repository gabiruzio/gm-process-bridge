//
// Created by gabiru on 07/11/2026.
//

#ifndef PROCESSBRIDGE_API_HPP
#define PROCESSBRIDGE_API_HPP

#define NOMINMAX
#include <Windows.h>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <string>
#include <unordered_map>
#include <mutex>

#ifdef _WIN64
    #define GMEXPORT extern "C" __declspec(dllexport)
#else
    #define GMEXPORT extern "C"
#endif

GMEXPORT double window_set_visibility(const char* _handle, double _visibility) {
    const auto _value = std::strtoull(_handle, nullptr, 16);
    HWND _hwnd = reinterpret_cast<HWND>(static_cast<uintptr_t>(_value));

    if (!IsWindow(_hwnd))
        return -1.0;

    if (_visibility == 0.0) {
        ShowWindow(_hwnd, SW_HIDE);
        LONG_PTR _style = GetWindowLongPtrW(_hwnd, GWL_EXSTYLE);

        _style &= ~WS_EX_APPWINDOW;
        _style |= WS_EX_TOOLWINDOW;

        SetWindowLongPtrW(_hwnd, GWL_EXSTYLE, _style);

        SetWindowPos(
            _hwnd,
            nullptr,
            0, 0, 0, 0,
            SWP_NOMOVE |
            SWP_NOSIZE |
            SWP_NOZORDER |
            SWP_NOACTIVATE |
            SWP_FRAMECHANGED
        );
    } else {
        ShowWindow(_hwnd, SW_SHOW);
    }

    return IsWindowVisible(_hwnd) ? 1.0 : 0.0;
}











#include <cmath>
#include <limits>
#include <vector>
#include <type_traits>


#define SHM_BUFFER_U8      1
#define SHM_BUFFER_S8      2
#define SHM_BUFFER_U16     3
#define SHM_BUFFER_S16     4
#define SHM_BUFFER_U32     5
#define SHM_BUFFER_S32     6
#define SHM_BUFFER_F16     7
#define SHM_BUFFER_F32     8
#define SHM_BUFFER_F64     9
#define SHM_BUFFER_BOOL    10
#define SHM_BUFFER_STRING  11
#define SHM_BUFFER_U64     12

static std::string g_shm_string_result;

struct SharedMemory
{
    HANDLE handle = nullptr;
    uint8_t* data = nullptr;
    size_t size = 0;
    std::string name;
};

static std::vector<SharedMemory> g_shared_memories;


static bool shm_parse_size(double value, size_t& result)
{
    if (!std::isfinite(value) ||
        value < 1 ||
        value > MAXDWORD ||
        std::floor(value) != value)
        return false;

    result = static_cast<size_t>(value);
    return true;
}


static double shm_register(
    HANDLE handle,
    uint8_t* data,
    size_t size,
    const char* name
)
{
    try
    {
        g_shared_memories.push_back({
            handle,
            data,
            size,
            name
        });

        return static_cast<double>(g_shared_memories.size());
    }
    catch (...)
    {
        UnmapViewOfFile(data);
        CloseHandle(handle);
        return 0;
    }
}


static SharedMemory* shm_get(double id)
{
    if (!std::isfinite(id) ||
        id < 1 ||
        std::floor(id) != id ||
        id > static_cast<double>(g_shared_memories.size()))
        return nullptr;

    SharedMemory& memory =
        g_shared_memories[static_cast<size_t>(id) - 1];

    if (!memory.data || !memory.handle)
        return nullptr;

    return &memory;
}


GMEXPORT double shm_create(
    const char* name,
    double size
)
{
    size_t _size;

    if (!name || !*name || !shm_parse_size(size, _size))
        return 0;

    HANDLE _mapping = CreateFileMappingA(
        INVALID_HANDLE_VALUE,
        nullptr,
        PAGE_READWRITE,
        0,
        static_cast<DWORD>(_size),
        name
    );

    if (!_mapping)
        return 0;

    const DWORD _error = GetLastError();

    if (_error == ERROR_ALREADY_EXISTS)
    {
        CloseHandle(_mapping);
        return 0;
    }

    auto* _data = static_cast<uint8_t*>(
        MapViewOfFile(
            _mapping,
            FILE_MAP_ALL_ACCESS,
            0,
            0,
            _size
        )
    );

    if (!_data)
    {
        CloseHandle(_mapping);
        return 0;
    }

    return shm_register(_mapping, _data, _size, name);
}


GMEXPORT double shm_open(
    const char* name,
    double size
)
{
    size_t _size;

    if (!name || !*name || !shm_parse_size(size, _size))
        return 0;

    // Verifica se já está aberto neste processo.
    for (size_t i = 0; i < g_shared_memories.size(); ++i)
    {
        const SharedMemory& _shm = g_shared_memories[i];

        if (_shm.handle && _shm.data && _shm.name == name)
        {
            // Evita devolver um ID com tamanho incompatível.
            if (_shm.size != _size)
                return 0;

            return static_cast<double>(i + 1);
        }
    }

    HANDLE _mapping = OpenFileMappingA(
        FILE_MAP_ALL_ACCESS,
        FALSE,
        name
    );

    if (!_mapping)
        return 0;

    auto* _data = static_cast<uint8_t*>(
        MapViewOfFile(
            _mapping,
            FILE_MAP_ALL_ACCESS,
            0,
            0,
            _size
        )
    );

    if (!_data)
    {
        CloseHandle(_mapping);
        return 0;
    }

    return shm_register(_mapping, _data, _size, name);
}


GMEXPORT double shm_exists(const char* name)
{
    if (!name || !*name)
        return 0;

    HANDLE _handle = OpenFileMappingA(
        FILE_MAP_READ,
        FALSE,
        name
    );

    if (!_handle)
        return 0;

    CloseHandle(_handle);
    return 1;
}


GMEXPORT double shm_peek(
    double id,
    double offset,
    double type
)
{
    if (!std::isfinite(offset) ||
        offset < 0 ||
        std::floor(offset) != offset)
        return -2;

    if (!std::isfinite(type) ||
        std::floor(type) != type ||
        type < 1 ||
        type > 12)
        return -4;

    const int _type = static_cast<int>(type);


    SharedMemory* _shm = shm_get(id);

    if (!_shm)
        return -1;

    if (offset > static_cast<double>(_shm->size))
        return -2;

    const size_t _offset = static_cast<size_t>(offset);

    auto _read = [&]<typename T>() -> double
    {
        if (_offset > _shm->size ||
            sizeof(T) > _shm->size - _offset)
            return -2;

        T _value{};

        std::memcpy(
            &_value,
            _shm->data + _offset,
            sizeof(T)
        );

        return static_cast<double>(_value);
    };

    switch (_type)
    {
        case SHM_BUFFER_U8:  return _read.template operator()<uint8_t>();  // buffer_u8
        case SHM_BUFFER_S8:  return _read.template operator()<int8_t>();   // buffer_s8
        case SHM_BUFFER_U16:  return _read.template operator()<uint16_t>(); // buffer_u16
        case SHM_BUFFER_S16:  return _read.template operator()<int16_t>();  // buffer_s16
        case SHM_BUFFER_U32:  return _read.template operator()<uint32_t>(); // buffer_u32
        case SHM_BUFFER_S32:  return _read.template operator()<int32_t>();  // buffer_s32
        case SHM_BUFFER_F32:  return _read.template operator()<float>();    // buffer_f32
        case SHM_BUFFER_F64:  return _read.template operator()<double>();   // buffer_f64

        case SHM_BUFFER_BOOL: // buffer_bool
        {
            const double _value = _read.template operator()<uint8_t>();
            return _value < 0 ? _value : (_value != 0 ? 1 : 0);
        }

        case SHM_BUFFER_U64: return _read.template operator()<uint64_t>(); // buffer_u64

        default:
            return -4;
    }
}


GMEXPORT double shm_poke(
    double id,
    double offset,
    double type,
    double value
)
{
    if (!std::isfinite(offset) ||
        offset < 0 ||
        std::floor(offset) != offset)
        return -2;

    if (!std::isfinite(type) ||
        std::floor(type) != type ||
        type < 1 ||
        type > 12)
        return -4;

    if (!std::isfinite(value))
        return -3;

    const int _type = static_cast<int>(type);


    SharedMemory* _shm = shm_get(id);

    if (!_shm)
        return -1;

    if (offset > static_cast<double>(_shm->size))
        return -2;

    const size_t _offset = static_cast<size_t>(offset);

    auto _write = [&]<typename T>() -> double
    {
        if (_offset > _shm->size ||
            sizeof(T) > _shm->size - _offset)
            return -2;

        if constexpr (std::is_integral_v<T>)
        {
            if constexpr (std::is_same_v<T, uint64_t>)
            {
                if (value < 0 ||
                    value >= 18446744073709551616.0)
                    return -3;
            }
            else
            {
                if (value < static_cast<double>(
                        std::numeric_limits<T>::lowest()) ||
                    value > static_cast<double>(
                        std::numeric_limits<T>::max()))
                    return -3;
            }
        }
        else if constexpr (std::is_same_v<T, float>)
        {
            if (std::fabs(value) >
                std::numeric_limits<float>::max())
                return -3;
        }

        const T _typed_value = static_cast<T>(value);

        std::memcpy(
            _shm->data + _offset,
            &_typed_value,
            sizeof(T)
        );

        return 0;
    };

    switch (_type)
    {
        case SHM_BUFFER_U8: return _write.template operator()<uint8_t>();  // buffer_u8
        case SHM_BUFFER_S8: return _write.template operator()<int8_t>();   // buffer_s8
        case SHM_BUFFER_U16: return _write.template operator()<uint16_t>(); // buffer_u16
        case SHM_BUFFER_S16: return _write.template operator()<int16_t>();  // buffer_s16
        case SHM_BUFFER_U32: return _write.template operator()<uint32_t>(); // buffer_u32
        case SHM_BUFFER_S32: return _write.template operator()<int32_t>();  // buffer_s32
        case SHM_BUFFER_F32: return _write.template operator()<float>();    // buffer_f32
        case SHM_BUFFER_F64: return _write.template operator()<double>();   // buffer_f64

        case SHM_BUFFER_BOOL: // buffer_bool
        {
            if (_offset >= _shm->size)
                return -2;

            const uint8_t _value = value != 0.0 ? 1 : 0;

            std::memcpy(
                _shm->data + _offset,
                &_value,
                sizeof(_value)
            );

            return 0;
        }

        case SHM_BUFFER_U64: return _write.template operator()<uint64_t>(); // buffer_u64

        default:
            return -4;
    }
}

GMEXPORT const char* shm_peek_string(
    double id,
    double offset
)
{
    if (
        !std::isfinite(offset) ||
        offset < 0 ||
        std::floor(offset) != offset
    )
        return "";


    SharedMemory* _shm = shm_get(id);

    if (!_shm || offset >= static_cast<double>(_shm->size))
        return "";

    const size_t _offset = static_cast<size_t>(offset);
    const size_t _remaining = _shm->size - _offset;

    const char* _source = reinterpret_cast<const char*>(
        _shm->data + _offset
    );

    const char* _end = static_cast<const char*>(
        std::memchr(_source, '\0', _remaining)
    );

    if (!_end)
        return "";

    try
    {
        g_shm_string_result.assign(
            _source,
            static_cast<size_t>(_end - _source)
        );

        return g_shm_string_result.c_str();
    }
    catch (...)
    {
        return "";
    }
}


GMEXPORT double shm_poke_string(
    double id,
    double offset,
    const char* value,
    double length
)
{
    if (
        !value ||
        !std::isfinite(offset) ||
        !std::isfinite(length) ||
        offset < 0 ||
        length < 0 ||
        std::floor(offset) != offset ||
        std::floor(length) != length
    )
        return -2;

    const size_t _value_size = std::strlen(value);

    if (length > static_cast<double>(_value_size))
        return -3;


    SharedMemory* _shm = shm_get(id);

    if (!_shm)
        return -1;

    if (offset >= static_cast<double>(_shm->size))
        return -2;

    const size_t _offset = static_cast<size_t>(offset);
    const size_t _length = static_cast<size_t>(length);
    const size_t _remaining = _shm->size - _offset;

    if (_length >= _remaining)
        return -2;

    std::memcpy(
        _shm->data + _offset,
        value,
        _length
    );

    _shm->data[_offset + _length] = '\0';

    return 0;
}


GMEXPORT double shm_close(double id)
{

    SharedMemory* _shm = shm_get(id);

    if (!_shm)
        return 0;

    UnmapViewOfFile(_shm->data);
    CloseHandle(_shm->handle);

    _shm->data = nullptr;
    _shm->handle = nullptr;
    _shm->size = 0;

    return 1;
}

#endif //PROCESSBRIDGE_API_HPP