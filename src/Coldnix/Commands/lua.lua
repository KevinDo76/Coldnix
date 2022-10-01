local module = {}
    module.name="lua"
    module.description="Lua interpreter"
    module.func = function (rawText)
        print("starting ".._VERSION.." Terminal")
        loadfile("/Coldnix/OSPrograms/luaProcessorProgram.lua")()
    end
return module