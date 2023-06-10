local module = {}
    module.id=11
    module.name="restart"
    module.description='restart the computer'
    module.func = function (rawText) 
        computer.shutdown(true)
    end
return module