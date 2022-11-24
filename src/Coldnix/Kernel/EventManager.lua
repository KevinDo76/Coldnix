--EventManager will allow the ability to regsister a function to a signal event
--allowing the program to respond to stuff like keyboard input.
_G.EventManager = {}
EventManager.eventsList={}
EventManager.regsisterListener = function (eventName,listeningEventName,func)
    if type(func)=="function" then
        --listen for name, func, is running
        EventManager.eventsList[eventName]={listeningEventName,func,true}
        Log.writeLog(string.format('New event registered, name: "%s" for event: "%s"',eventName,listeningEventName))
    end
    return false, "Failed to add listener, a function is not passed in"
end


EventManager.resumeListener=function(eventName)
    if EventManager.eventsList[eventName] then
        EventManager.eventsList[eventName][3]=true
    else
        return false, "Listener not found"    
    end
end

EventManager.pauseListener=function(eventName)
    if EventManager.eventsList[eventName] then
        EventManager.eventsList[eventName][3]=false
    else
        return false, "Listener not found"    
    end
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
            if v[1]==name and v[3] then
                v[2](...)
            end
        end
    end
end

--replacing the wait() function to call onSignal
_G.wait = function(time)
    local endTime=computer.uptime()+time
    while computer.uptime()<endTime do
        EventManager.onSignal(computer.pullSignal(math.clamp(endTime-computer.uptime(),0,0.01)))
        TaskSchedular.runTask()
    end
    return true
end