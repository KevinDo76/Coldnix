local module = {}
    module.id=16
    module.name="error"
    module.description="It error out"
    module.func = function (rawText)
        args = System.utility.getArgs(rawText)
        System.utility.loadAsGraphicalApp(error,"a")
    end
return module