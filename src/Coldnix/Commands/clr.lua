local module = {}
    module.id=4
    module.name="clr"
    module.description='clear the terminal\nuse flag "rl" to reload instead'
    module.func = function (rawText)
        local args=System.utility.getArgs(rawText)
        if args[2]=="rl" then
            terminal.reload()
        else
            terminal.clearScreen()
        end
    end
return module