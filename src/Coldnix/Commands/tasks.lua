local module = {}
    module.id=5
    module.name="task"
    module.description="TaskSchedular utility"
    module.func = function (rawText)
       local args=string.split(rawText," ")
       if args[2]=="list" then
        print("/Currently registered tasks")
        local longestLength=0
        for i,v in pairs(TaskScheduler.tasks) do
            if #i>longestLength then
                longestLength=#i
            end
        end
        print(System.utility.padText("Name",math.max(longestLength+3,3)).."Running")
        print(string.rep("-",longestLength+10))
        for i,v in pairs(TaskScheduler.tasks) do
            print(System.utility.padText(i,longestLength+3)..tostring(not v[4]))
        end
       end
    end
return module