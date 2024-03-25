--eventManager will allow the ability to regsister a function to a signal event
--allowing the program to respond to stuff like keyboard input.
_G.eventManager = {}
eventManager.eventsList={}
eventManager.regsisterListener = function (eventName,listeningEventName,func)
    if type(func)=="function" then
        --listen for {name, func, is running}
        eventManager.eventsList[eventName]={listeningEventName,func,true}
        Log.writeLog(string.format('New event registered, name: "%s" for event: "%s"',eventName,listeningEventName))
    end
    return false, "Failed to add listener, a function is not passed in"
end


eventManager.resumeListener=function(eventName)
    if eventManager.eventsList[eventName] then
        eventManager.eventsList[eventName][3]=true
    else
        return false, "Listener not found"    
    end
end

eventManager.pauseListener=function(eventName)
    if eventManager.eventsList[eventName] then
        eventManager.eventsList[eventName][3]=false
    else
        return false, "Listener not found"    
    end
end

eventManager.removeListener = function (eventName)
    if eventManager.eventsList[eventName] then
        eventManager.eventsList[eventName] = nil
        return true
    end
    return false, "Listener not found"
end
--this would be place into the wait() function since it's the only place that will ever call on eventpull
eventManager.onSignal = function (name,...)
    if name=="SIGKILL" then
        error("Keyboard termination")
    end
    if name~=nil then
        for i,v in pairs(eventManager.eventsList) do
            if v[1]==name and v[3] then
                v[2](...)
            end
        end
    end
end

--replacing the wait() function to call onSignal
_G.yieldCheck={}
yieldCheck.start=computer.uptime()
_G.wait = function(time)
    local endTime=computer.uptime()+(time or 0.01)
    computer.ElapseT=computer.uptime()-yieldCheck.start
    if computer.ElapseT>4 then
        error("program termination, too long no yield")
    end
    while computer.uptime()<endTime do
        eventManager.onSignal(computer.pullSignal(math.clamp(endTime-computer.uptime(),0,0.01)))
        TaskScheduler.runTask()
    end
    yieldCheck.start=computer.uptime()
    CheckYield()
    return true 
end

--check when was the last time wait() was ran. Meant to be inserted at the top of system api functions/print/etc. running wait() is important because it register all user input
_G.CheckYield = function ()
    computer.ElapseT=computer.uptime()-yieldCheck.start
    SandBox.computer.ElapseT = computer.ElapseT
    if computer.ElapseT>4 then
        --preventing recursive loop
        yieldCheck.start = computer.uptime()

        error("program termination, too long no yield")
    end
end

