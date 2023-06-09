EventManager.regsisterListener("TerminationGeneratorDown","key_down",function(componentId,asciiNum,keyboardcode)
    if keyboardcode==29 then
        _G.ControlDown=true
    elseif ControlDown and keyboardcode==46 then
        computer.pushSignal("SIGTERM")
        if terminal and terminal.getProcessState() then
            terminal.type("^C")
            terminal.enter()
        end
    elseif ControlDown and keyboardcode==45 then
        computer.pushSignal("SIGKILL")
        if terminal and terminal.getProcessState() then
            terminal.type("^X")
            terminal.enter()
        end
    end
end)

EventManager.regsisterListener("TerminationGeneratorUp","key_up",function(componentId,asciiNum,keyboardcode)
    if keyboardcode==29 then
        _G.ControlDown=false
    end
end)