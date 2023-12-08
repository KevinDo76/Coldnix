print("starting ".._VERSION.." Terminal")
commandAPI.noCommandProcess=true
terminal.prefix=_VERSION..": "
terminal.reload()
local running=true

local function returnValue(value)
    if type(value)~="string" then
        return value
    end
    local func = load("local a="..value.." return a","=Lua interpreter","t",_G)
    if func then
        local succ, value = pcall(func)
        if not succ then
            value="nil"
        end
        return value
    else
        return "nil"
    end
end

local function listToString(obj,name,minimal)
    if type(obj)=="table" then
        local str=""
        for i,v in pairs(obj) do
            --the extra parameters are meant for recursive, not impletmented due to memory limitation
            if not minimal then
                --str=str..'\n    '..i.."="..tostring(listToString(obj[i],"",true))..","
                str=str..'\n        '..i.."="..tostring(obj[i])..","
            else
                str=str.." "..tostring(listToString(obj[i],""))..","
            end
        end
        if minimal then
            str=name.."{"..str
        else
            str=name.."={"..str
        end
        return string.sub(str,1,#str-1).."\n}"
    else
        return obj
    end
end

eventManager.regsisterListener("LuaTerminalTermination","SIGTERM",function() 
    running=false
end)

while running do
    local inp=terminal.input(_VERSION..": ")
    if string.sub(inp,#inp-1,#inp)~="^C" then
        local func,err=load(inp,"=Lua interpreter","t",_G)
        local func2,err2=load("return "..inp,"=Lua interpreter","t",_G)
        --checking for single value request
        local split=string.split(inp," ")

        if #split==1 then
            if err then
                print(listToString(returnValue(inp),inp))
                func = function() end
            else
                if func2 then
                    _G.returnV = nil
                    pcall(function() _G.returnV = func2() end)
                    if _G.returnV then print(_G.returnV) end
                    _G.returnV = nil
                end
            end
        end
        
        func2 = function() end
        if func then
            local succ,err=pcall(function() func() end)
            if not succ then
                print("Runtime error: "..(err or "nil"))
            end
        else
            print(err)
        end
    end
end
print("Exiting ".._VERSION.." Terminal")
commandAPI.noCommandProcess=false
terminal.prefix=System.filesystem.getPrefixWorkingDir()..currentWorkingDir..": "
terminal.reload()
_G.exit=nil
_G.ControlDown=nil
eventManager.removeListener("LuaTerminalTermination")