local libDir = "/Coldnix/library/"
local loadedLib = {}
local loadInMem = config.configList.LOADLIBRARYCODEINTOMEM == "1"
--initial load
local listofLib = System.listDirectory(libDir)
if not listofLib then error("Failed to load libs") end

if loadInMem then
    for i,v in ipairs(listofLib) do
        local libComplied = loadfile(libDir..v)
        if not libComplied then error("Failed to complie "..libDir..v) end
        local data = libComplied()
        loadedLib[data.name] = data
        print("[  " .. string.format( "%.2f", tostring (computer.uptime())) .."s  ] loaded \""..libDir..v.."\"")
    end
end
_G.require = function(libName) 
    if loadInMem then
        return loadedLib[libName]
    end
end