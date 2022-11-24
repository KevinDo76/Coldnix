local module = {}
    module.id=6
    module.name="test"
    module.description="this is a test program, very nice"
    module.func = function (rawText)
        terminal.stopProcess(true)
        terminal.type("task list")
        terminal.enter()
        wait(5)
        terminal.resumeProcess()
    end
return module