local failsafe = true
local image = paintutils.loadImage("drawing.nfp")
local image2 = paintutils.loadImage("turbine.nfp")
local errorimage = paintutils.loadImage("error.nfp")
local reactorStatusTab = true
local turbineStatusTab = false
local debugMode = false

-- Turbine Detection
if peripheral.find("peripheralProxy:turbine") ~= nil then
    turbine = peripheral.find("peripheralProxy:turbine")
else
    print("Turbine not found, continuing..")
    sleep(1)
end

-- Fission Reactor Detection
if peripheral.find("peripheralProxy:fissionReactor") ~= nil then
    reactor = peripheral.find("peripheralProxy:fissionReactor")
else
    error("Fission Reactor not found, this *is* a reactor program y'know")
end

-- ChatBox Detection
if peripheral.find("chatBox") ~= nil then
    chatbox = peripheral.find("chatBox")
else
    print("Chatbox not found, continuing..")
    sleep(1)
end

-- Adds a blank line
function newLine()
    xPos, yPos = term.getCursorPos()
    term.setCursorPos(1,(yPos + 1))
end

-- Mouse clicking routine (currently only switches between tabs)
function mouseClick()
    while true do
        local event,button,x,y = os.pullEvent("mouse_click")
        if button == 1 then
            if y == 1 and x>=1 and x<=9 then
            reactorStatusTab = true 
            turbineStatusTab = false
            elseif y == 1 and x>=11 and x<=19 then
            turbineStatusTab = true
            reactorStatusTab = false
            end
        end
        sleep(0.1)
    end
end

-- Updates the background color on the reactor tab
-- based on status
local function backgroundColor()
    if reactor.getStatus() == false then
    term.setBackgroundColor(colors.red)
    elseif reactor.getStatus() == true then
    term.setBackgroundColor(colors.green)
    end 
end 

-- Draws the menu bar on the top of the screen
local function menuBar()
    term.setBackgroundColor(colors.gray)
    term.setCursorPos(1,1)
    term.clearLine()
    print("[Reactor] [Turbine] [Etc..]")
end

-- Prints the status of both the reactor and turbine
local function StatusCheck()
    while true do
        -- Reactor Tab Info
        if reactorStatusTab == true then
            term.clear()
            menuBar()
            paintutils.drawImage(image,28,4 )
            term.setCursorPos(1,3) 
            backgroundColor() 
            if reactor.getStatus() == true then
                print("Reactor Status: Online")
            else
                print("Reactor Status: Offline")
            end 
            print("Reactor Temp: "..math.floor(reactor.getTemperature()).."K" )
            print("Reactor Damage: "..reactor.getDamagePercent().."%") 
            print("Burn Rate: "..reactor.getBurnRate().."mB/t")
            print("Heating Rate: "..reactor.getHeatingRate().." mB/t" )
            print("Coolant Level: "..math.floor(math.abs(reactor.getCoolantFilledPercentage() * 100)).."%") 
            newLine() 
            print("E - Toggle Reactor")
            print("F - Toggle Failsafe") 
            newLine()
            if failsafe == true then
                print("Reactor Failsafe: ACTIVE")
            else
                print("Reactor Failsafe: INACTIVE")
            end  
        end 
        -- Turbine Tab Info
        if turbineStatusTab == true and turbine ~= nil then
            term.clear()
            menuBar()
            paintutils.drawImage(image2,37,5)
            term.setBackgroundColor(colors.lightBlue)
            term.setCursorPos(1,3)
            if turbine.getProductionRate() >= 100 then
                print("Turbine Status: Online")
            elseif turbine.getProductionRate() <= 99 then
                print("Turbine Status: Low Generation!") 
            elseif turbine.getProductionRate() <= 1 then
                print("Turbine Status: Offline")
            end
            print("Steam Capacity: "..turbine.getSteamCapacity().."mB")
            print("Current Steam: "..turbine.getSteam().."mB")
            print("Flow Rate: "..turbine.getFlowRate().."mB/t")
            print("Energy Production: "..turbine.getProductionRate().."FE/t")
            newLine()
            print("Turbine Failsafe: WIP")
        elseif turbine == nil and turbineStatusTab == true then
            term.clear()
            menuBar()
            paintutils.drawImage(errorimage,1,8)
            term.setBackgroundColor(colors.lightBlue)
            term.setCursorPos(1,3)
            print("Running without turbine integration!")
            print("Connect turbine to see status!")
            print("(If this message is printed in error, contact us!)")
        end
        sleep(0.1)
    end
end

-- Shuts down the reactor when above 1200K
local function reactorFailsafe()
    if failsafe ==  true then
        while true do
            sleep(0.1) 
            if reactor.getTemperature() >= 1200 then
                 reactor.scram()
                 if chatbox ~= nil then
                    term.setCursorPos(1,18)
                    term.setBackgroundColor(colors.red)
                    print("[WARNING] Reactor temp at critical levels, failsafe has been activated!")
                    chatbox.sendMessage("§4[WARNING] §cReactor temp at critical levels, failsafe has been activated!") 
                 else
                     term.setCursorPos(1,18)
                     term.setBackgroundColor(colors.red)
                     print("[WARNING] Reactor temp at critical levels, failsafe has been activated!")
                 end
                 break
            end
        end
    else return end
end

-- Toggles the reactor
local function reactorToggle()
    while true do
        local event, key = os.pullEvent("key")
        if key == keys.e and reactorStatusTab == true and reactor.getStatus() == true then
            reactor.scram()
        elseif key == keys.e and reactorStatusTab == true  and reactor.getStatus() == false then
            reactor.activate() 
        elseif key == keys.f and reactorStatusTab == true and failsafe == true then
            failsafe = false
        elseif key == keys.f and reactorStatusTab == true and failsafe == false then
            failsafe = true 
        end
        sleep(0.1) 
    end  
end

-- Debug stuff
local function debugFailsafe()
while true do
    local event,key = os.pullEvent("key")
    if key == keys.leftShift and keys.f then
        print("debug test")
        sleep(0.5)
        break
    end
    sleep(0.1)
end
end

-- Startup code
term.clear()
term.setCursorPos(1,1)
term.setBackgroundColor(colors.cyan) 
textutils.slowPrint("JKR Fission Reactor & Turbine Software",20)
sleep(0.1) 
textutils.slowPrint("Developed by Heck (mostly)  & Scorch",20)
sleep(0.5)

while true do
    print("Press any key...") 
    local event, key = os.pullEvent("key")
    if event then
        textutils.slowPrint("Loading...........",15)
        sleep(1)
        term.clear()
        menuBar()
        break
    end
end

-- no touchy
parallel.waitForAll(debugFailsafe,mouseClick,reactorFailsafe,StatusCheck,reactorToggle)
