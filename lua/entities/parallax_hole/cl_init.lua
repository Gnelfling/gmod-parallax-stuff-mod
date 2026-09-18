include("shared.lua")

local RT_SIZE = 512
local CULL_DISTANCE = 2000
local PARALLAX_RT
local PARALLAX_MATERIAL

local function GetParallaxHoleRT()
    if not PARALLAX_RT then
        PARALLAX_RT = GetRenderTarget("parallax_hole_rt", RT_SIZE, RT_SIZE)
    end
    return PARALLAX_RT
end

local function GetParallaxHoleMaterial(rt)
    if not PARALLAX_MATERIAL then
        PARALLAX_MATERIAL = Material("!" .. rt:GetName())
    end
    return PARALLAX_MATERIAL
end

local function DrawFakeShaft(self)
    if not IsValid(self) then return end

    local depth = math.max(self:GetDepth(), 1)
    local width = math.max(self:GetWidth(), 8)
    local height = math.max(self:GetHeight(), 8)
    local rt = GetParallaxHoleRT()
    if not rt then return end

    render.PushRenderTarget(rt)
        render.Clear(0, 0, 0, 255, true, true)

        local cameraPos = self:GetPos() - self:GetUp() * depth
        local lookAt = self:GetPos() + self:GetUp() * 8
        local cameraAngle = (lookAt - cameraPos):Angle()

        cam.Start3D(cameraPos, cameraAngle, 80, 0, 0, RT_SIZE, RT_SIZE)
            render.FogMode(MATERIAL_FOG_LINEAR)
            render.FogColor(0, 0, 0)
            render.FogStart(depth * 0.05)
            render.FogEnd(depth * 0.9)
            render.FogMaxDensity(1)

            local steps = 12
            for i = 0, steps do
                local t = i / steps
                local distance = depth * (0.15 + t * 1.25)
                local sizeMultiplier = 1 - t * 0.85
                local position = self:GetPos() - self:GetUp() * distance
                local halfWidth = width * 0.5 * sizeMultiplier
                local halfHeight = height * 0.5 * sizeMultiplier
                local shade = math.Clamp(12 + i * 16, 12, 255)

                render.DrawBox(
                    position,
                    self:GetAngles(),
                    Vector(-halfWidth, -halfHeight, -8),
                    Vector(halfWidth, halfHeight, 8),
                    Color(shade, shade, shade, 255)
                )
            end
        cam.End3D()
    render.PopRenderTarget()
end

function ENT:Draw()
    if not IsValid(self) then return end

    self:DrawModel()

    local localPlayer = LocalPlayer()
    if not IsValid(localPlayer) then return end
    if localPlayer:GetPos():Distance(self:GetPos()) > CULL_DISTANCE then return end

    -- TODO: lower RT_SIZE or update every other frame when many holes are visible.
    local rt = GetParallaxHoleRT()
    if not rt then return end

    DrawFakeShaft(self)

    render.SetMaterial(GetParallaxHoleMaterial(rt))
    render.DrawQuadEasy(
        self:GetPos() + self:GetUp() * 0.5,
        self:GetUp(),
        self:GetWidth(),
        self:GetHeight(),
        color_white,
        0
    )
end
