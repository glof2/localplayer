-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Game objects
local lplayer = Players.LocalPlayer

-- Main
local LocalPlayerLib = {}
LocalPlayerLib.__index = LocalPlayerLib

-- Cheatpart behavoirs
LocalPlayerLib.CheatPartBehaviours = {}
LocalPlayerLib.CheatPartBehaviours.FollowUnder = function(part)
    part.CFrame = LocalPlayerLib.Root.CFrame * CFrame.new(0, -3.6, 0)
end

-- Variable section
LocalPlayerLib.__InitComplete__ = false
LocalPlayerLib.__VerifyFailed__ = true
LocalPlayerLib.Player = lplayer
LocalPlayerLib.Character = ""
LocalPlayerLib.Humanoid = ""
LocalPlayerLib.Root = ""

local function waitForChildWhichIsA(instance, class, max_wait)
    local waited = 0
    local result = nil
    while result == nil and (max_wait == nil or max_wait == 0 or waited < max_wait) do
        result = instance:FindFirstChildWhichIsA(class)
        waited = waited + task.wait()
    end
    return result
end

-- Function section
-- Work functions
function LocalPlayerLib.Init()
    -- Connections
    -- Character
    LocalPlayerLib.Player.CharacterAdded:Connect(function(char)
        LocalPlayerLib.Update(character)
    end)

    -- Setting current vars
    LocalPlayerLib.Update()

    LocalPlayerLib.__InitComplete__ = true
    LocalPlayerLib.Verify()
end

function LocalPlayerLib.Update(character)
    LocalPlayerLib.Character = character or LocalPlayerLib.Player.Character or LocalPlayerLib.Player.CharacterAdded:Wait()
    LocalPlayerLib.Humanoid = waitForChildWhichIsA(character or LocalPlayerLib.Character, "Humanoid")
    LocalPlayerLib.Root = LocalPlayerLib.Character:WaitForChild("HumanoidRootPart")
end

function LocalPlayerLib.Verify()
    if typeof(LocalPlayerLib.Character) ~= "Instance" or typeof(LocalPlayerLib.Humanoid) ~= "Instance" then
        LocalPlayerLib.__VerifyFailed__ = true
        return false
    end
    LocalPlayerLib.__VerifyFailed__ = false
    return true
end
-- Cheat functions
function LocalPlayerLib.setWalkSpeed(value)
    if LocalPlayerLib.__InitComplete__ == false or LocalPlayerLib.__VerifyFailed__ == true then
        return
    end

    LocalPlayerLib.Humanoid.WalkSpeed = value
end

function LocalPlayerLib.setJumpPower(value)
    if LocalPlayerLib.__InitComplete__ == false or LocalPlayerLib.__VerifyFailed__ == true then
        return
    end

    LocalPlayerLib.Humanoid.JumpPower = value
end

function LocalPlayerLib.cheatPart(behaviourFunc, args)
    local part = Instance.new("Part")
    for key, value in pairs(args) do
        pcall(function()
            part[key] = value
        end) 
    end
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if part == nil or part.Parent ~= workspace then
            conn:Disconnect()
            return
        end
        behaviourFunc(part)
    end)
    return part
end

function LocalPlayerLib.teleportTo(cframe)
    LocalPlayerLib.Root.CFrame = cframe
end

function LocalPlayerLib.getDistance(position)
    return (LocalPlayerLib.Root.CFrame.Position - position).magnitude
end

function LocalPlayerLib.createTween(cframe, speed, info)
    -- Calculating speed
    local distance = LocalPlayerLib.getDistance(cframe.Position)
    local time = distance/speed

    -- Create tween
    local tween_info = TweenInfo.new(time, unpack(info or {}))
    local goal = {CFrame = cframe}
    local tween = TweenService:Create(LocalPlayerLib.Root, tween_info, goal)

    return tween
end

function LocalPlayerLib.tweenTo(cframe, speed, info)
    return LocalPlayerLib.createTween(cframe, speed, info):Play()
end

function LocalPlayerLib.smartTP(cframe, speed, tp_distance, info)
    while wait() do
        while LocalPlayerLib.getDistance(cframe.Position)  > tp_distance do
            local cheat_part = LocalPlayerLib.cheatPart(LocalPlayerLib.CheatPartBehaviours.FollowUnder, {Parent = workspace})
            local tween = LocalPlayerLib.createTween(cframe, speed, info)
            tween:Play()
            tween.Completed:Wait()
            cheat_part:Destroy()
        end
        LocalPlayerLib.teleportTo(cframe)
        if LocalPlayerLib.getDistance(cframe.Position) <= 3 then
            return
        end
    end
    
end

return LocalPlayerLib
