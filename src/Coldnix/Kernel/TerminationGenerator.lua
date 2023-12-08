eventManager.regsisterListener("TerminationGeneratorDown","key_down",function(componentId,asciiNum,keyboardcode)
    if keyboardcode==29 then
        _G.ControlDown=true
    elseif ControlDown and keyboardcode==46 then
        computer.pushSignal("SIGTERM")
        if terminal and terminal.getProcessState() then
            if terminal.typingEnable then
                terminal.type("^C")
                terminal.enter()
            else
                print("^C")
            end
        end
    elseif ControlDown and keyboardcode==45 then
        computer.pushSignal("SIGKILL")
        terminal.typingEnable = true
        if terminal and terminal.getProcessState() then
            if terminal.typingEnable then
                terminal.type("^C")
                terminal.enter()
            else
                print("^C")
            end
        end
    end
end)

eventManager.regsisterListener("TerminationGeneratorUp","key_up",function(componentId,asciiNum,keyboardcode)
    if keyboardcode==29 then
        _G.ControlDown=false
    end
end)