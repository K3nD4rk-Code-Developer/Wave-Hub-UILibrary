local HttpService = game:GetService("HttpService")

local EnableTraceback = false
local Signal = {}
Signal.__index = Signal
Signal.ClassName = "Signal"

function Signal.isSignal(Value)
    return type(Value) == "table" and getmetatable(Value) == Signal
end

function Signal.new()
    local Self = setmetatable({}, Signal)
    Self.BindableEvent = Instance.new("BindableEvent")
    Self.ArgMap = {}
    Self.Source = EnableTraceback and debug.traceback() or ""

    Self.BindableEvent.Event:Connect(function(Key)
        Self.ArgMap[Key] = nil
        if not Self.BindableEvent and not next(Self.ArgMap) then
            Self.ArgMap = nil
        end
    end)

    return Self
end

function Signal:Fire(...)
    if not self.BindableEvent then
        warn(("Signal is already destroyed. %s"):format(self.Source))
        return
    end

    local Args = table.pack(...)
    local Key = HttpService:GenerateGUID(false)

    self.ArgMap[Key] = Args
    self.BindableEvent:Fire(Key)
end

function Signal:Connect(Handler)
    if typeof(Handler) ~= "function" then
        error(("Connect(%s): Expected function"):format(typeof(Handler)), 2)
    end

    return self.BindableEvent.Event:Connect(function(Key)
        local Args = self.ArgMap[Key]
        if Args then
            Handler(table.unpack(Args, 1, Args.n))
        else
            error("Missing argument data, possibly due to reentrance.")
        end
    end)
end

function Signal:Once(Handler)
    if typeof(Handler) ~= "function" then
        error(("Once(%s): Expected function"):format(typeof(Handler)), 2)
    end

    return self.BindableEvent.Event:Once(function(Key)
        local Args = self.ArgMap[Key]
        if Args then
            Handler(table.unpack(Args, 1, Args.n))
        else
            error("Missing argument data, possibly due to reentrance.")
        end
    end)
end

function Signal:Wait()
    local Key = self.BindableEvent.Event:Wait()
    local Args = self.ArgMap[Key]

    if Args then
        return table.unpack(Args, 1, Args.n)
    else
        error("Missing argument data, possibly due to reentrance.")
        return nil
    end
end

function Signal:Destroy()
    if self.BindableEvent then
        self.BindableEvent:Destroy()
        self.BindableEvent = nil
    end

    setmetatable(self, nil)
end

return Signal
