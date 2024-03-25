_G.network = {}
local primaryModem = component.avaliables("modem")
local modemProxy = false
if (primaryModem) then
    Log.writeLog("Primary modem set: "..primaryModem)
    modemProxy = component.proxy(primaryModem)
end

--#####################--

--network card handling

--#####################--
local function checkNetworkIntAva()
    return primaryModem == component.avaliables("modem")
end

eventManager.regsisterListener("networkCardDetach", "component_removed",function(add)
    if modemProxy and add == primaryModem then
        modemProxy = false
        print(modemProxy)
    end
end)

eventManager.regsisterListener("networkCardAttach", "component_added",function(add)
    local primaryModem = component.avaliables("modem")
    if (primaryModem) then
        Log.writeLog("Primary modem set: "..primaryModem)
        modemProxy = component.proxy(primaryModem)
    end
end)

--#########################--

--Network discovery feature

--#########################--

local onlineHost = {}
local deadTime = 5
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
    if modemProxy and checkNetworkIntAva() then
        modemProxy.open(1)
        modemProxy.broadcast(1,"helloMessage|"..tostring(primaryModem))
    elseif not checkNetworkIntAva() then
        print("int error") 
    end
end

    --Registering event

eventManager.regsisterListener("networkEvent-Discovery","modem_message",function(...)
    discoveryModemMessageProcess(...)
end) 

    --Adding tasks
TaskScheduler.addTask("networkCheckOffine",checkNetworkOffline,1)
TaskScheduler.addTask("networkDiscovery",networkHellobroadcast,5)

--#########################--

--reliable network protocol

--#########################--
local timeoutSec = 14
local tickSpeed = 0.05
local maxDataSegmentSize = 2
network.RNP = {}
_G.connectionState = {}

local function generateID()
    txt=""
    for i=1,25 do
        txt=txt..string.char(math.random(97,122))
    end
    return txt
end

local function sendNetworkMessage(address, port, data)
    if modemProxy and checkNetworkIntAva() then 
        modemProxy.send(address, port, data)
        return true
    end
    return false
end

local function dataSendReq(data, connectionID)
    data = string.gsub(data,"|","\\124")
    for i,v in pairs(connectionState) do
        if v.connectionID == connectionID then
            local packetCount = math.ceil(#data/maxDataSegmentSize)
            local segment = {}
            for ii = 0,packetCount-1 do
                segmentData = "RNP|DATA_EXCHANGE|"..primaryModem.."|"..tostring(ii+1).."|"..string.sub(data,1+(ii*maxDataSegmentSize),maxDataSegmentSize+(ii*maxDataSegmentSize))
                segment[#segment+1] = segmentData
                print(segmentData)
            end

            local newDataSend = {
                state = "AWAIT_ACK",
                ["packetCount"] = packetCount,
                messages = segment,
                packetPointer = 1,
                packetArrived = {},
                attemptTimer = 0
            }
            for i=1,packetCount do
                newDataSend.packetArrived[i] = false
            end
            table.insert(v.messageQueue, newDataSend)
            return true
        end
    end
    return false
end

local function networkRecieve(selfAddress, _, port, _, rawdata)
    local data = string.split(rawdata,"|")
    if (rawdata:sub(1,3)=="RNP") and connectionState[port] and (connectionState[port].remoteAddress == data[3] or connectionState[port].state == "LISTEN") then
        local temp = ""
        for i,v in ipairs(data) do
            temp=temp..v.." "
        end
        print(temp)
        if data[2]=="TERM" then
            if connectionState[port] then
                connectionState[port] = nil
            end
        end
        if data[2]=="INIT_REQ" then
            if connectionState[port] and connectionState[port].state == "LISTEN" then
                if sendNetworkMessage(data[3], port, "RNP|INIT_ACK|"..primaryModem) then 
                    connectionState[port].remoteAddress = data[3]
                    connectionState[port].deadTimer = timeoutSec
                    connectionState[port].state = "CONNECTED"
                    connectionState[port].connectionID = data[4]
                    connectionState[port].connectionInitCallbackFunc(data[4])
                end
            end
        elseif data[2]=="DATA_REQ" then
            if connectionState[port] and connectionState[port].state == "CONNECTED" and connectionState[port].recieveState.state == "AWAIT_REQ" then
                if sendNetworkMessage(data[3], port, "RNP|DATA_ACK|"..primaryModem) then
                    connectionState[port].recieveState.state = "DATA_ACK"
                    connectionState[port].recieveState.packetCount = tonumber(data[4])
                    for i=1,tonumber(data[4]) do
                        connectionState[port].recieveState.packetArrived[i] = false
                    end
                end
            end
        elseif data[2]=="DATA_FIN" then
            if connectionState[port] and connectionState[port].state == "CONNECTED" and connectionState[port].recieveState.state == "DATA_ACK" then
                local text=""
                for i,v in ipairs(connectionState[port].recieveState.packetArrived) do
                    if not v then
                        text = text .. tostring(i).."."
                    end
                end
                print(text)
            end
        elseif data[2]=="DATA_EXCHANGE" then
            if connectionState[port] and connectionState[port].state == "CONNECTED" and connectionState[port].recieveState.state == "DATA_ACK" then
                print(data[4])
                connectionState[port].recieveState.packetArrived[tonumber(data[4])] = true
            end
        elseif data[2]=="DATA_ACK" then
            if connectionState[port] and connectionState[port].state == "CONNECTED" and connectionState[port].messageQueue[1].state == "AWAIT_ACK" then
                connectionState[port].messageQueue[1].state = "DATA_ACK"
                connectionState[port].messageQueue[1].attemptTimer = 0
            end
        elseif data[2]=="INIT_ACK" then
            if connectionState[port] and connectionState[port].state == "INIT_REQ" then
                connectionState[port].state = "CONNECTED"
                connectionState[port].deadTimer = timeoutSec
            end
        elseif data[2]=="KEEPALIVE_ACK" then
            if connectionState[port] and connectionState[port].state == "CONNECTED" and connectionState[port].role == "CLIENT" then
                connectionState[port].deadTimer = timeoutSec
                connectionState[port].keepaliveSent=false
            end
        elseif data[2]=="KEEPALIVE" then
            if connectionState[port] and connectionState[port].state == "CONNECTED" and connectionState[port].role == "SERVER" then
                connectionState[port].deadTimer = timeoutSec
                sendNetworkMessage(data[3], port, "RNP|KEEPALIVE_ACK|"..primaryModem)
            end
        end
    end
end


local CheckPort = function(portN,state)
    for i,v in pairs(connectionState) do
        if v.state == state then
            return true
        end
    end
    return false
end

network.RNP.createConnection = function(portN, address)
    if not connectionState[portN] then 
        connectionState[portN] = {deadTimer = timeoutSec, 
                                  remoteAddress = address,
                                  state = "INIT_REQ",
                                  role = "CLIENT",
                                  keepaliveSent = false,
                                  messageQueue = {},
                                  connectionID = generateID(),
                                  recieveState = {
                                    state = "AWAIT_REQ",
                                    buffer = "",
                                    packetArrived = {},
                                    packetCount = -1
                                  },
                                }

        if modemProxy and checkNetworkIntAva() then 
            modemProxy.open(portN) 
            modemProxy.send(address, portN, "RNP|INIT_REQ|"..primaryModem.."|"..tostring(connectionState[portN].connectionID))
        else
            return false, "No network interface found"
        end

        return {port = portN, sendData = dataSendReq, getData = function() end, connectionID = connectionState[portN].connectionID}
    else
        return false, "Port occupied, unable to create connection"
    end
end

network.RNP.listenConnection = function(port, connectionInitCallback)
    if not connectionState[port] then
        connectionState[port] = {deadTimer = -2,
                                 remoteAddress = address,
                                 state = "LISTEN",
                                 role = "SERVER",
                                 keepaliveSent=false,
                                 messageQueue = {},
                                 connectionID = -1,
                                 connectionInitCallbackFunc = connectionInitCallback,
                                 recieveState = {
                                    state = "AWAIT_REQ",
                                    buffer = "",
                                    packetArrived = {},
                                    packetCount = -1
                                 },
                                }


        if modemProxy and checkNetworkIntAva() then 
            modemProxy.open(port)
        else
            return false, "No network interface found"
        end
    end
    return {port = portN, sendData = function() end, getData = function() end}
end

eventManager.regsisterListener("networkEvent-RNP","modem_message",function(...)
    networkRecieve(...)
end) 

TaskScheduler.addTask("RNP-PeriodicTasks", function()
    for i,v in pairs(connectionState) do
        if v.deadTimer>0 then v.deadTimer = v.deadTimer - tickSpeed end
        if (v.deadTimer > -1 and v.deadTimer<=0) then
            connectionState[i]=nil
            print("Connection timeout") 
            if modemProxy and checkNetworkIntAva() then
                modemProxy.open(i) 
                modemProxy.send(v.remoteAddress, i, "RNP|TERM|"..primaryModem)
            end
        end

        if v.role == "CLIENT" and v.deadTimer<=12 and math.ceil(v.deadTimer)%3==0 and v.state == "CONNECTED" and not v.keepaliveSent then
            if sendNetworkMessage(v.remoteAddress, i, "RNP|KEEPALIVE|"..primaryModem) then
                v.deadTimer = math.ceil(v.deadTimer)-1
                if v.deadTimer<=9 and v.messageQueue[1] and v.messageQueue[1].state == "DATA_ACK" then
                    v.messageQueue[1].attemptTimer=5
                    print("throttle",v.deadTimer)
                end
                return --slowing down the stream for a keep alive message to come through
            end
        end

        if v.messageQueue[1] and v.messageQueue[1].state == "DATA_ACK" and v.state == "CONNECTED" then
            if v.messageQueue[1].attemptTimer <=0 and sendNetworkMessage(v.remoteAddress, i, v.messageQueue[1].messages[v.messageQueue[1].packetPointer]) then
                v.messageQueue[1].attemptTimer = 0.05
                v.messageQueue[1].packetPointer = v.messageQueue[1].packetPointer + 1
                if v.messageQueue[1].packetPointer > #v.messageQueue[1].messages then
                    v.messageQueue[1].state = "DATA_AWAIT_CONFIRM"
                    v.messageQueue[1].attemptTimer = 0
                end
            else
                v.messageQueue[1].attemptTimer = v.messageQueue[1].attemptTimer - tickSpeed
            end
        end

        if v.messageQueue[1] and v.messageQueue[1].attemptTimer<=0 and v.messageQueue[1].state == "DATA_AWAIT_CONFIRM" and v.state == "CONNECTED" then
            print(sendNetworkMessage(v.remoteAddress, i, "RNP|DATA_FIN|"..primaryModem))
            print("send con")
            v.messageQueue[1].attemptTimer = 5
        elseif v.messageQueue[1] then
            v.messageQueue[1].attemptTimer = v.messageQueue[1].attemptTimer - tickSpeed
        end

        if v.messageQueue[1] and v.messageQueue[1].state == "AWAIT_ACK" and v.state == "CONNECTED" then
            if v.messageQueue[1].attemptTimer <=0 and sendNetworkMessage(v.remoteAddress, i, "RNP|DATA_REQ|"..primaryModem.."|"..tostring(v.messageQueue[1].packetCount)) then
                v.messageQueue[1].attemptTimer = 1
            else
                v.messageQueue[1].attemptTimer = v.messageQueue[1].attemptTimer - tickSpeed
            end
        end
    end
end,tickSpeed)