local module = {}
    module.id=2
    module.name="lua"
    module.description="Lua interpreter"
    module.func = function (rawText)
        local func=loadfile("/Coldnix/OSPrograms/luaProcessorProgram.lua",true,BOOTDRIVEPROXY,SandBox)
        if func then
            func()
        end
        func=nil
    end
return module