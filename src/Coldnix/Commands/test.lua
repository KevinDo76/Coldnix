local module = {}
    module.id=6
    module.name="test"
    module.description="this is a test program, very nice"
    module.func = function (rawText)
        for i=1,2 do
            for c=1,30000000 do
                local A=2
                local B=2
                local C=A*B^c
            end 
            wait()
        end
    end
return module