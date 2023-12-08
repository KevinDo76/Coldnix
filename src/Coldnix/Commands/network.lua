local running = false
local function onlineHosts()
    running = true
    eventManager.regsisterListener("networkInfoTermination","SIGTERM",function() running=false end)
    local x,y=BOOTGPUPROXY.getResolution()
    local gpu=BOOTGPUPROXY
    while (wait(0.2) and running) do
        local online = network.getOnlineHosts()
        gpu.fill(1,1,x,y," ")
        gpu.set(1,1,"Online hosts: ")
        for i,v in ipairs(online) do
            gpu.set(1,i+1,tostring(i)..". "..v[1].." "..tostring(v[2]-computer.uptime()).."s")
        end
    end
    eventManager.removeListener("networkInfoTermination")
end

local module = {}
    module.id=15
    module.name="network"
    module.description="Network information\n-online\n  see online hosts"
    module.func = function (rawText)
        local args = System.utility.getArgs(rawText)
        if table.getIndex(args,"-online")~=-1 then
            System.utility.loadAsGraphicalApp(onlineHosts)
        else
            print(module.description)
        end
    end
return module