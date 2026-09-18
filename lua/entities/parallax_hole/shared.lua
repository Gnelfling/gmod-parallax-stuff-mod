ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Parallax Hole"
ENT.Category = "Fun"
ENT.Spawnable = true
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "Depth")
    self:NetworkVar("Float", 1, "Width")
    self:NetworkVar("Float", 2, "Height")

    if SERVER then
        self:SetDepth(512)
        self:SetWidth(64)
        self:SetHeight(64)
    end
end
