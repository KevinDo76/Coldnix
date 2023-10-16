local module = {}
    module.id=10
    module.name="pong"
    module.description='The game pong'
    module.func = function (rawText) 
        local func=loadfile("/Coldnix/OSPrograms/pong.lua",true,BOOTDRIVEPROXY,SandBox)
        if func then
            func()
        end
        func=nil
    end
return module