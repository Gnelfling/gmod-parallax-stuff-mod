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
    if not rt then return nil end
    if PARALLAX_MATERIAL and not PARALLAX_MATERIAL:IsError() then
        return PARALLAX_MATERIAL
    end

    -- Do not call Material("!" .. rt:GetName()) every frame. On some GMod
    -- builds that lookup returns an error/null material for a render target.
    -- CreateMaterial caches a real material whose base texture is the RT.
    PARALLAX_MATERIAL = CreateMaterial("parallax_hole_rt_material", "UnlitGeneric", {
        ["$basetexture"] = rt:GetName(),
        ["$vertexcolor"] = 1,
        ["$vertexalpha"] = 1,
        ["$translucent"] = 0,
        ["$ignorez"] = 1
    })

    if not PARALLAX_MATERIAL or PARALLAX_MATERIAL:IsError() then
        PARALLAX_MATERIAL = nil
        return nil
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

    local holeMaterial = GetParallaxHoleMaterial(rt)
    -- Never bind a failed/error material; this prevents CMatRenderContext spam.
    if not holeMaterial or holeMaterial:IsError() then return end

    render.SetMaterial(holeMaterial)
    render.DrawQuadEasy(
        self:GetPos() + self:GetUp() * 0.5,
        self:GetUp(),
        self:GetWidth(),
        self:GetHeight(),
        color_white,
        0
    )
end
