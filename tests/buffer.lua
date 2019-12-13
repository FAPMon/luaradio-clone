---
-- Temporary file backed buffer with a file I/O interface for unit testing.
--
-- @module tests.buffer

local ffi = require('ffi')

local platform = require('radio.core.platform')

---
-- Create a buffer backed by a temporary file.
--
-- @internal
-- @function open
-- @tparam[opt=""] string str Initial data
-- @treturn int File descriptor of file
local function open(str)
    -- Default to empty buffer (e.g. writing only purposes)
    str = str or ""

    -- Create and get a file descriptor to a temporary file
    local tmpfile_path = string.format("/tmp/%08x", math.random(0, 0xffffffff))
    local file = ffi.C.fopen(tmpfile_path, "w+")
    if file == nil then
        error("fopen(): " .. ffi.string(ffi.C.strerror(ffi.errno())))
    end

    -- Get file descriptor from file
    local fd = ffi.C.fileno(file)
    if fd == -1 then
        error("fileno(): " .. ffi.string(ffi.C.strerror(ffi.errno())))
    end

    -- Unlink the temporary file
    if ffi.C.unlink(tmpfile_path) ~= 0 then
        error("unlink(): " .. ffi.string(ffi.C.strerror(ffi.errno())))
    end

    -- Write the buffer
    if ffi.C.write(fd, str, #str) ~= #str then
        error("write(): " .. ffi.string(ffi.C.strerror(ffi.errno())))
    end

    -- Rewind the file
    if ffi.C.lseek(fd, 0, ffi.C.SEEK_SET) ~= 0 then
        error("lseek(): " .. ffi.string(ffi.C.strerror(ffi.errno())))
    end

    return fd
end

---
-- Read from buffer.
--
-- @internal
-- @function read
-- @tparam int fd File descriptor of buffer
-- @tparam int count Number of bytes to read
-- @treturn string Data read
local function read(fd, count)
    -- Read up to to count bytes from the fd
    local buf = ffi.new("char[?]", count)
    local num_read = ffi.C.read(fd, buf, ffi.sizeof(buf))
    if num_read < 0 then
        error("read(): " .. ffi.string(ffi.C.strerror(ffi.errno())))
    end

    return ffi.string(buf, num_read)
end

---
-- Write to buffer.
--
-- @internal
-- @function write
-- @tparam int fd File descriptor of buffer
-- @tparam string str Data to write
local function write(fd, str)
    -- Write the string to the fd
    if ffi.C.write(fd, str, #str) ~= #str then
        error("write(): " .. ffi.string(ffi.C.strerror(ffi.errno())))
    end
end

---
-- Rewind buffer.
--
-- @internal
-- @function rewind
-- @tparam int fd File descriptor of buffer
local function rewind(fd)
    if ffi.C.lseek(fd, 0, ffi.C.SEEK_SET) ~= 0 then
        error("lseek(): " .. ffi.string(ffi.C.strerror(ffi.errno())))
    end
end

---
-- Close buffer.
--
-- @internal
-- @function close
-- @tparam int fd File descriptor of buffer
local function close(fd)
    if ffi.C.close(fd) ~= 0 then
        error("close(): " .. ffi.string(ffi.C.strerror(ffi.errno())))
    end
end

return {open = open, read = read, write = write, rewind = rewind, close = close}
