-- REACTOR CONTROL AND TURBINE MONITORING PROGRAM --
-- PROGRAMMED BY AyScorch and Heck --


-- locals
local image = paintutils.loadImage("drawing.nfp")
local image2 = paintutils.loadImage("turbine.nfp")
local errorimage = paintutils.loadImage("error.nfp")
local reactorStatusTab = true
local turbineStatusTab = false
local failsafe = true
local turbineFailsafe = true
local failsafeTriggeredTurbine = false
local failsafeTriggeredReactor = false
local debugMode = false
local turbine
local chatbox
local reactor

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
local function newLine()
    xPos, yPos = term.getCursorPos()
    term.setCursorPos(1,(yPos + 1))
end

-- Mouse clicking routine (switch between tabs and toggle functions)
local function mouseClick()
    while true do
        local event,button,x,y = os.pullEvent("mouse_click")
        if button == 1 then
            if y == 1 and x>=1 and x<=9 then -- reactor tab
            reactorStatusTab = true 
            turbineStatusTab = false
            elseif y == 1 and x>=11 and x<=19 then -- turbine tab
            turbineStatusTab = true
            reactorStatusTab = false
            elseif y == 10 and x >= 1 and x<= 7 and reactorStatusTab == true and reactor.getStatus() == true then
                reactor.scram()
            elseif y == 10 and x >= 1 and x<= 7 and reactorStatusTab == true and reactor.getStatus() == false then
                reactor.activate()
            elseif y == 11 and x >= 1 and x<= 7 and reactorStatusTab == true and failsafe == true then
                failsafe = false
            elseif y == 11 and x >= 1 and x<= 7 and reactorStatusTab == true and failsafe == false then
                failsafe = true
            elseif y == 10 and x >= 1 and x<= 7 and turbineStatusTab == true and turbineFailsafe == false then
                turbineFailsafe = true
            elseif y == 10 and x >= 1 and x<= 7 and turbineStatusTab == true and turbineFailsafe == true then
                turbineFailsafe = false
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

-- failsafe triggers to stop the reactor going no
local function failsafeTrigger()
    while true do
        if reactor.getTemperature() >= 1200 and failsafe == true then
            reactor.scram()
            if chatbox ~= nil and failsafeTriggeredReactor == false then
               chatbox.sendMessage("WARNING: Reactor temp at critical levels, shutting down")
           end
            failsafeTriggeredReactor = true
        end
        if turbine.getSteam() >= turbine.getSteamCapacity() and turbine ~= nil and turbineFailsafe == true then
            reactor.scram()
            if chatbox ~= nil and failsafeTriggeredTurbine == false then
                chatbox.sendMessage("WARNING: Turbine at dangerous steam levels, shutting down reactor to prevent buildup")
            end
            failsafeTriggeredTurbine = true
        end
        sleep(0.1)
    end
end

-- unfailsafes the trigger
local function unFailsafeTrigger()
    sleep(60)
    failsafeTriggeredReactor = false
    failsafeTriggeredTurbine = false
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
            print("[Click] or E - Toggle Reactor")
            print("[Click] or F - Toggle Failsafe") 
            newLine()
            if failsafe == true then
                print("Reactor Failsafe: ACTIVE")
            elseif failsafe == false then
                print("Reactor Failsafe: INACTIVE")
            end  
            if failsafeTriggeredReactor == true then
                term.setCursorPos(1,18)
                print("FAILSAFE TRIGGERED: REACTOR TEMP")
                unFailsafeTrigger()
            elseif failsafeTriggeredTurbine == true then
                term.setCursorPos(1,18)
                print("FAILSAFE TRIGGERED: TURBINE OVERFLOW")
                unFailsafeTrigger()
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
                print("Turbine Status: Probably Spinning")
            elseif turbine.getProductionRate() <= 99 then
                print("Turbine Status: idk lol go look at it") 
            elseif turbine.getProductionRate() <= 1 then
                print("Turbine Status: Definently not spinning")
            end
            print("Steam Capacity: "..turbine.getSteamCapacity().."mB")
            print("Current Steam: "..turbine.getSteam().."mB")
            print("Steam Filled Percentage: "..math.floor(math.abs(turbine.getSteamFilledPercentage() * 100)).."%")
            print("Flow Rate: "..turbine.getFlowRate().."mB/t")
            print("Energy Production: "..turbine.getProductionRate().."FE/t")
            newLine()
            print("[Click] or F - Toggle Failsafe")
            newLine()
            if turbineFailsafe == true then
                print("Turbine Failsafe: ACTIVE")
            else
                print("Turbine Failsafe: INACTIVE")
            end
            if failsafeTriggeredTurbine == true then
                term.setCursorPos(1,18)
                print("FAILSAFE TRIGGERED: TURBINE OVERFLOW")
                unFailsafeTrigger()
            elseif failsafeTriggeredReactor == true then
                term.setCursorPos(1,18)
                print("FAILSAFE TRIGGERED: REACTOR TEMP")
                unFailsafeTrigger()
            end
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

-- Turbine controls
local function turbineToggle()
        while true do
            local event, key = os.pullEvent("key")
                if key == keys.f and turbineStatusTab == true and turbineFailsafe == true then
                    turbineFailsafe = false
                elseif key == keys.f and turbineStatusTab == true and turbineFailsafe == false then
                    turbineFailsafe = true
                end
            sleep(0.1)
        end
end

-- Debug stuff
local function debugFunction()
    --function testing goes here
    while true do
        local event,key = os.pullEvent("key")
        if key == keys.d and debugMode == true then
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
textutils.slowPrint("Developed by Heck & Scorch",20)
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
parallel.waitForAll(debugFunction,mouseClick,StatusCheck,reactorToggle,turbineToggle,failsafeTrigger)
