local module = {}
    module.id=12
    module.name="con"
    module.description="AttemptConnect"
    module.func = function (rawText)
        start = 0x2800
        buff = ""
        for y = 0,15 do
            for x = 0,15 do
                buff=buff..utf8.char(start)
                start=start+1
            end
            buff=buff.."\n"
        end
        print(buff)
    end
return module