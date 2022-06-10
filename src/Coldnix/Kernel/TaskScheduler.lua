--this will implement a system where "task"  can be regsistered and be run every so often
--this will allow for cooperative multitasking in the OS
_G.TaskSchedular={}
TaskSchedular.tasks={}

--TaskSchedular.addTask(taskname, [function,text] to run, interval) is going to let you add in a new task
TaskSchedular.addTask = function (taskname, taskCode, interval)
    if type(taskCode)=="string" then
        local result,err=loadstring(taskCode,"TaskSchedular.addTask()("..taskname..")",false)
        if result then
            taskCode=result
        else
            error("Failed to complie source into function(TaskSchedular.addTask()), error: "..err)
        end
    end
    --format for storing tasks metadata are {name[int],interval[int],nextruntime[int],paused[boolen]}
    TaskSchedular.tasks[taskname]={taskCode,interval,computer.uptime(),false}
    Log.writeLog(string.format('Added task id: "%s", with interval: %s sec',taskname,tostring(interval)))
end

--TaskSchedular.runTask() is going to be call in the system main loop as often as possible to check for tasks that needs to be run
TaskSchedular.runTask = function()
    for i,v in pairs(TaskSchedular.tasks) do
        if computer.uptime()>=v[3] and not (v[4]) then
            TaskSchedular.tasks[i][3]=computer.uptime()+v[2]
            v[1]()
        end
    end
end

TaskSchedular.removeTask = function(name)
    if TaskSchedular.tasks[name] then
        TaskSchedular.tasks[name]=nil
        return true
    end
    return false, "Unable to find task"
end

TaskSchedular.pauseTask = function (name)
    if TaskSchedular.tasks[name] then
        TaskSchedular.tasks[name][4]=true
        return true
    end
    return false, "Unable to find task"
end

TaskSchedular.resumeTask = function (name)
    if TaskSchedular.tasks[name] then
        TaskSchedular.tasks[name][4]=false
        return true
    end
    return false, "Unable to find task"
end