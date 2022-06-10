--this will provide a logging function for the OS, that will go to a text file
--incase the terminal is the thing that's malfunctioning
local wipeOnStart=true
local logfileLocation="Coldnix/Data/log.txt"
_G.Log={}
--checking if there's a log file already and wipe if the setting is true
if BOOTDRIVEPROXY.exists(logfileLocation) and wipeOnStart then
    BOOTDRIVEPROXY.remove(logfileLocation)
end
--setting up the functions
Log.writeLog = function(...)
    local txt=""
    local args={...}
    for i,v in pairs(args) do
        txt=txt..tostring(v).." "
    end
    txt=string.sub(txt,1,#txt-1)
    local logfile=BOOTDRIVEPROXY.open(logfileLocation,"a")
    BOOTDRIVEPROXY.write(logfile,txt.."\n")
    BOOTDRIVEPROXY.close(logfile)
end

Log.writeLog("")
Log.writeLog("---------------------------------------------------")
Log.writeLog("Log service started")