print("starting ".._VERSION.." Terminal")
commandAPI.noCommandProcess=true
terminal.prefix=_VERSION..": "
terminal.reload()
_G.exit=false
_G.ControlDown=false
EventManager.regsisterListener("luainterdown","key_down",function(componentId,asciiNum,keyboardcode)
    if keyboardcode==29 then
        ControlDown=true
    elseif keyboardcode==46 and ControlDown then
        _G.exit=true 
        terminal.type("^C")
        terminal.enter()
    end
end)

EventManager.regsisterListener("luainterup","key_up",function(componentId,asciiNum,keyboardcode)
    if keyboardcode==29 then
        ControlDown=false
    end
end)
while true do
    if exit then break end
    local inp=terminal.input(_VERSION..": ")
    if string.sub(inp,#inp-1,#inp)~="^C" then
        local func,err=load(inp,"=Lua interpreter","t",_G)
        if func then
            local succ,err=pcall(function() func() end)
            if not succ then
                print("Runtime error: "..(err or "nil"))
            end
        else
            print(err)
        end
    else
        break
    end
end
print("Exiting ".._VERSION.." Terminal")
commandAPI.noCommandProcess=false
terminal.prefix=System.utility.getPrefixWorkingDir()..currentWorkingDir..": "
terminal.reload()
_G.exit=nil
_G.ControlDown=nil
EventManager.removeListener("luainterdown")
EventManager.removeListener("luainterup")