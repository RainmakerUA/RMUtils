--[=====[
		## RM Utils library ver. 1.1.0
		## rmEvent.lua - Event module
		Code for rmUtils Event logic
--]=====]

local rmUtils = LibStub("rmUtils-1.1")
local eventMod = {}

rmUtils.Event = eventMod

local error = error
local ipairs = ipairs
local setmetatable = setmetatable
local tinsert = table.insert
local type = type

-- Remove all known globals after this point
-- luacheck: std none

local function addHandler(event, handler, receiver)
	if not event.handlers then
		event.handlers = {}
	end
	if not receiver and type(handler) == "table" then
		receiver, handler = handler, handler[event.name]
	elseif type(handler) == "string" then
		handler, receiver = receiver[handler], receiver
	elseif type(handler) ~= "function" then
		error("'func' must be either string or function", 2)
	end
	tinsert(event.handlers, { func = handler, receiver = receiver })
end

local function removeAllHandlers(event)
	event.handlers = {}
end

local function raise(event, ...)
	local result = nil
	for _, v in ipairs(event.handlers or {}) do
		if type(v.receiver) == "table" then
			result = result or v.func(v.receiver, ...)
		else
			result = result or v.func(...)
		end
	end
	return result
end

function eventMod.New(name)
	return setmetatable({
		name = name,
		AddHandler = addHandler,
		RemoveAllHandlers = removeAllHandlers,
		Raise = raise
	}, { __call = raise })
end
