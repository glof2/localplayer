-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Game objects
local lplayer = Players.LocalPlayer

-- Main
local LocalPlayerLib = {}
LocalPlayerLib.__index = LocalPlayerLib

-- Cheatpart behavoirs
LocalPlayerLib.CheatPartBehaviours = {}
LocalPlayerLib.CheatPartBehaviours.FollowUnder = function(part)
    local root = LocalPlayerLib.Character:FindFirstChild("HumanoidRootPart")
    local l_leg = LocalPlayerLib.Character:FindFirstChild("Left Leg")

    local y = l_leg.Position.Y - (part.Size.Y/2) - (l_leg.Size.Y/2)
    local angles = root.CFrame - root.CFrame.Position

    part.CFrame = CFrame.new(root.Position.X, y, root.Position.Z) * angles
end

-- Variable section
LocalPlayerLib.__InitComplete__ = false
LocalPlayerLib.__VerifyFailed__ = true
LocalPlayerLib.Player = lplayer
LocalPlayerLib.Character = ""
LocalPlayerLib.Humanoid = ""

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

function LocalPlayerLib.cheatPart(behaviour_func, args)
    local part = Instance.new("Part")
    for key, value in pairs(args) do
        pcall(function()
            part[key] = value
        end) 
    end
    RunService.Heartbeat:Connect(function()
        behaviour_func(part)
    end)
end

return LocalPlayerLib
