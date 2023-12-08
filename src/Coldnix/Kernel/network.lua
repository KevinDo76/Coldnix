_G.network = {}
local primaryModem = component.avaliables("modem")
local modemProxy = false
if (primaryModem) then
    Log.writeLog("Primary modem set: "..primaryModem)
    modemProxy = component.proxy(primaryModem)
end
--Network discovery feature
local onlineHost = {}
local deadTime = 6
network.getOnlineHosts = function()
    local copyList = {} -- creating a copy so that the original list can't be modifiedaaaaaaaaaaaaaaaaaaaaaa
    for i,v in ipairs(onlineHost) do 
        copyList[i]=v
    end
    return copyList
end

local function checkForHostInList(modemID)
    local found = false
    for i,v in ipairs(onlineHost) do
        if v[1]==modemID then
            v[2] = computer.uptime() + deadTime
            found = true
            break
        end
    end
    if not found then
        computer.pushSignal("network_remotehost_alive",modemID)
        table.insert(onlineHost,{modemID, computer.uptime() + deadTime})
    end
end

local function discoveryModemMessageProcess(...)
    args = {...} 
    if (string.split(args[5],"|")[1]=="helloMessage") then
        checkForHostInList(string.split(args[5],"|")[2])
    end
end

local function checkNetworkOffline()
    for i,v in ipairs(onlineHost) do
        if v[2]<=computer.uptime() then
            table.remove(onlineHost,i)
            computer.pushSignal("network_remotehost_dead",v[1])
        end
    end
end

local function networkHellobroadcast()
    if modemProxy then
        modemProxy.open(1)
        modemProxy.broadcast(1,"helloMessage|"..tostring(primaryModem))
    end
end

--Registering event

eventManager.regsisterListener("networkEvent","modem_message",function(...)
    discoveryModemMessageProcess(...)
end) 

--Adding tasks
TaskScheduler.addTask("networkCheckOffine",checkNetworkOffline,1)
TaskScheduler.addTask("networkDiscovery",networkHellobroadcast,5)