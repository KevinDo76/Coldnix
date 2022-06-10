--EventManager will allow the ability to regsister a function to a signal event
--allowing the program to respond to stuff like keyboard input.
_G.EventManager = {}
EventManager.eventsList={}
EventManager.regsisterListener = function (eventName,listeningEventName,func)
    if type(func)=="function" then
        EventManager.eventsList[eventName]={listeningEventName,func}
        Log.writeLog(string.format('New event registered, name: "%s" for event: "%s"',eventName,listeningEventName))
    end
    return false, "Failed to add listener, a function is not passed in"
end

EventManager.removeListener = function (eventName)
    if EventManager.eventsList[eventName] then
        EventManager.eventsList[eventName] = nil
        return true
    end
    return false, "Listener not found"
end
--this would be place into the wait() function since it's the only place that will ever call on eventpull
EventManager.onSignal = function (name,...)
    if name~=nil then
        for i,v in pairs(EventManager.eventsList) do
            if v[1]==name then
                v[2](...)
            end
        end
    end
end

--replacing the wait() function to call onSignal
_G.wait = function(time)
    local endTime=computer.uptime()+time
    while computer.uptime()<endTime do
        EventManager.onSignal(computer.pullSignal(math.clamp(endTime-computer.uptime(),0,0.1)))
        TaskSchedular.runTask()
    end
    return true
end