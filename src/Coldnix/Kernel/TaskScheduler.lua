--this will implement a system where "task"  can be regsistered and be run every so often
--this will allow for cooperative multitasking in the OS
_G.TaskScheduler={}
TaskScheduler.tasks={}

--TaskSchedular.addTask(taskname, [function,text] to run, interval) is going to let you add in a new task
TaskScheduler.addTask = function (taskname, taskCode, interval)
    if type(taskCode)=="string" then
        local result,err=loadstring(taskCode,"TaskScheduler.addTask()("..taskname..")",false)
        if result then
            taskCode=result
        else
            error("Failed to complie source into function(TaskScheduler.addTask()), error: "..err)
        end
    end
    --format for storing tasks metadata are {name[int],interval[int],nextruntime[int],paused[boolen]}
    TaskScheduler.tasks[taskname]={taskCode,interval,computer.uptime(),false}
    Log.writeLog(string.format('Added task id: "%s", with interval: %s sec',taskname,tostring(interval)))
end

--TaskSchedular.runTask() is going to be call in the system main loop as often as possible to check for tasks that needs to be run
TaskScheduler.runTask = function()
    for i,v in pairs(TaskScheduler.tasks) do
        if computer.uptime()>=v[3] and not (v[4]) then
            TaskScheduler.tasks[i][3]=computer.uptime()+v[2]
            v[1]()
        end
    end
end

TaskScheduler.removeTask = function(name)
    if TaskScheduler.tasks[name] then
        TaskScheduler.tasks[name]=nil
        return true
    end
    return false, "Unable to find task"
end

TaskScheduler.pauseTask = function (name)
    if TaskScheduler.tasks[name] then
        TaskScheduler.tasks[name][4]=true
        return true
    end
    return false, "Unable to find task"
end

TaskScheduler.resumeTask = function (name)
    if TaskScheduler.tasks[name] then
        TaskScheduler.tasks[name][4]=false
        return true
    end
    return false, "Unable to find task"
end