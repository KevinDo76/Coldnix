local connectionInit=false
connectID = ""
local function onConnect(id)
    connectionInit = true
    connectionID = id
    print(id, "connection initlized")
end

if component.avaliables("modem") == "11b3d40c-2d6e-4902-8ffa-36d9abfdd174" then
    handle = network.RNP.listenConnection(10, onConnect)
end
