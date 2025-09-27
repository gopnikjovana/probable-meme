_G.JasonHitbox = true
_G.hitboxnearestdist = 20
local hitboxcode = nil

local AttackAnimations = loadstring(game:HttpGet("https://raw.githubusercontent.com/gopnikjovana/probable-meme/refs/heads/main/hitboxanimations"))()

local function randomtext()
    local characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
    local length = math.random(5, 12)
    local result = ""

    for i = 1, length do
        local randIndex = math.random(1, #characters)
        result = result .. characters:sub(randIndex, randIndex)
    end

    return result
end

local function spawnhitbox(code)
    hitboxcode = code
    local mycode = code
    local hitbox
    hitbox = game:GetService("RunService").Heartbeat:Connect(function()
        if not _G.JasonHitbox then return end
        if not hitboxcode or hitboxcode ~= mycode then hitbox:Disconnect() end

        local Humanoid = game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid")
        local HumanoidRootPart = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        local Playing = false
        for _, v in Humanoid:GetPlayingAnimationTracks() do
            if AttackAnimations[v.Animation.AnimationId] and (v.TimePosition / v.Length < 0.75) then
                Playing = true
            end
        end

        if not Playing then
            return
        end

        local Target
        local ViewAngleTarget
        local ViewAngleMinDist = math.huge
        local maxViewAngle = 60

        local function loop(t)
            for _, v in t do
                if v == Character or not v:FindFirstChild("HumanoidRootPart") then
                    continue
                end
                local Dist = (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude

                local lookDirection = HumanoidRootPart.CFrame.LookVector
                local toTargetDirection = (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Unit
                local dotProduct = lookDirection:Dot(toTargetDirection)
                local angle = math.deg(math.acos(math.clamp(dotProduct, -1, 1)))
                
                if angle <= maxViewAngle/2 then
                    if Dist < ViewAngleMinDist then
                        ViewAngleMinDist = Dist
                        ViewAngleTarget = v
                    end
                end
            end
        end

        if game:GetService("Players").LocalPlayer.Character.Parent.Name == "Killers" then
            loop(workspace.Players.Survivors:GetDescendants())
            loop(workspace.Map:FindFirstChild("NPCs", true):GetChildren())
        else
            loop(workspace.Players.Killers:GetDescendants())
            loop(workspace.Map:FindFirstChild("NPCs", true):GetChildren())
        end

        if ViewAngleTarget then
            Target = ViewAngleTarget
        elseif not Target then
            return
        end

        local Dist = (Target.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
        if Dist > _G.hitboxnearestdist then
            return
        end

        local OldVelocity = HumanoidRootPart.Velocity
        local TargetPosition = Target.HumanoidRootPart.Position
        HitboxPosition = Vector3.new(
            TargetPosition.X,
            TargetPosition.Y,
            TargetPosition.Z
        )
        local NeededVelocity = (HitboxPosition - HumanoidRootPart.Position) * 12
        NeededVelocity = Vector3.new(NeededVelocity.X, NeededVelocity.Y, NeededVelocity.Z)
        
        HumanoidRootPart.Velocity = NeededVelocity
        game:GetService("RunService").RenderStepped:Wait()
        HumanoidRootPart.Velocity = OldVelocity
    end)
end

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    spawnhitbox(randomtext())
end)

spawnhitbox(randomtext())
