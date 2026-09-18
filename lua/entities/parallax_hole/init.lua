AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local DEFAULT_DEPTH = 512
local DEFAULT_WIDTH = 64
local DEFAULT_HEIGHT = 64

local function MakeParallaxHole(data)
    data = istable(data) and data or {}

    local ent = ents.Create("parallax_hole")
    if not IsValid(ent) then
        return NULL
    end

    ent:SetPos(isvector(data.Pos) and data.Pos or Vector(0, 0, 0))
    ent:SetAngles(isangle(data.Angle) and data.Angle or Angle(0, 0, 0))
    ent:Spawn()
    ent:Activate()

    ent:SetDepth(isnumber(data.Depth) and data.Depth or DEFAULT_DEPTH)
    ent:SetWidth(isnumber(data.Width) and data.Width or DEFAULT_WIDTH)
    ent:SetHeight(isnumber(data.Height) and data.Height or DEFAULT_HEIGHT)

    return ent
end

duplicator.RegisterEntityClass("parallax_hole", MakeParallaxHole, "Data")

duplicator.RegisterEntityModifier("parallax_hole_data", function(_, ent, data)
    if not IsValid(ent) or not istable(data) then return end

    if isvector(data.Pos) then ent:SetPos(data.Pos) end
    if isangle(data.Angle) then ent:SetAngles(data.Angle) end
    if isnumber(data.Depth) then ent:SetDepth(data.Depth) end
    if isnumber(data.Width) then ent:SetWidth(data.Width) end
    if isnumber(data.Height) then ent:SetHeight(data.Height) end
end)

function ENT:Initialize()
    self:SetModel("models/hunter/plates/plate.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    if self:GetDepth() <= 0 then self:SetDepth(DEFAULT_DEPTH) end
    if self:GetWidth() <= 0 then self:SetWidth(DEFAULT_WIDTH) end
    if self:GetHeight() <= 0 then self:SetHeight(DEFAULT_HEIGHT) end

    -- This is intentionally not a real hole: the thin plate remains solid.
    -- The apparent depth exists only in the client-side render-target illusion.
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
        phys:Sleep()
    end
end

function ENT:OnDuplicated()
    local data = {
        Pos = self:GetPos(),
        Angle = self:GetAngles(),
        Depth = self:GetDepth(),
        Width = self:GetWidth(),
        Height = self:GetHeight()
    }

    duplicator.StoreEntityModifier(self, "parallax_hole_data", data)
    return data
end

function ENT:OnRestore()
    if self:GetDepth() <= 0 then self:SetDepth(DEFAULT_DEPTH) end
    if self:GetWidth() <= 0 then self:SetWidth(DEFAULT_WIDTH) end
    if self:GetHeight() <= 0 then self:SetHeight(DEFAULT_HEIGHT) end
end
