local class = require("class")

TVBStream = class.class()

function TVBStream:_init(tvb)
    self.tvb = tvb
    self._pos = 0
end

function TVBStream:close()
    -- empty
end

function TVBStream:seek(whence, offset)
    local len = self.tvb:len()
    whence = whence or "cur"

    if whence == "set" then
        self._pos = offset or 0
    elseif whence == "cur" then
        self._pos = self._pos + (offset or 0)
    elseif whence == "end" then
        self._pos = len + (offset or 0)
    else
        error("bad argument #1 to 'seek' (invalid option '" .. tostring(whence) .. "')", 2)
    end

    if self._pos < 0 then
        self._pos = 0
    elseif self._pos > len then
        self._pos = len
    end

    return self._pos
end

function TVBStream:read(num)
    local len = self.tvb:len()

    if num == "*all" then
        if self._pos == len then
            return nil
        end

        local ret = self.tvb:raw(self._pos)
        self._pos = len

        return ret
    elseif num <= 0 then
        return ""
    end

    if self._pos + num > len then
        num = len - self._pos
    end
    local ret = self.tvb:raw(self._pos, num)

    if ret:len() == 0 then
        return nil
    end

    self._pos = self._pos + num
    if self._pos > len then
        self._pos = len
    end

    return ret
end

function TVBStream:pos()
    return self._pos
end
