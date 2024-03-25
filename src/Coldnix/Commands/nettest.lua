local module = {}
    module.id=16
    module.name="net"
    module.description="network test"
    module.func = function (rawText)
        networkHandle = network.RNP.createConnection(10, "11b3d40c-2d6e-4902-8ffa-36d9abfdd174")
        print(networkHandle.port)

        wait(2)

        networkHandle.sendData("12|4567|||, this iis craazzyy things are greate. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",networkHandle.connectionID)
    end
return module