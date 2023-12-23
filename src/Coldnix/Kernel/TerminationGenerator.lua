_G.termGen = {}

termGen.ControlC = function ()
    computer.pushSignal("SIGTERM")
    if terminal and terminal.getProcessState() then
        if terminal.typingEnable then
            terminal.type("^C")
            terminal.enter()
        else
            print("^C")
        end
    end
end
termGen.ControlX = function ()
    computer.pushSignal("SIGKILL")
    terminal.typingEnable = true
    terminal.prefix = ((System.filesystem.getShortDriveName(WORKINGDRIVEADDRESS) == System.filesystem.getShortDriveName(BOOTDRIVEADDRESS) and "boot") or System.filesystem.getShortDriveName(WORKINGDRIVEADDRESS))..":"..currentWorkingDir..": "
    if terminal and terminal.getProcessState() then
        if terminal.typingEnable then
            terminal.type("^X")
            terminal.enter()
        else
            print("^X")
        end
    end
end
eventManager.regsisterListener("TerminationGeneratorDown","key_down",function(componentId,asciiNum,keyboardcode)
    if keyboardcode==29 then
        _G.ControlDown=true
    elseif ControlDown and keyboardcode==46 then
        termGen.ControlC()
    elseif ControlDown and keyboardcode==45 then
        termGen.ControlX()
    end
end)

eventManager.regsisterListener("TerminationGeneratorUp","key_up",function(componentId,asciiNum,keyboardcode)
    if keyboardcode==29 then
        _G.ControlDown=false
    end
end)