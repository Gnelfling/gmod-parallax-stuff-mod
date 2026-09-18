TOOL.Category = "Construction"
TOOL.Name = "Parallax Hole"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar = {
    depth = "512",
    width = "64",
    height = "64"
}

if CLIENT then
    language.Add("tool.parallax_hole.name", "Parallax Hole")
    language.Add("tool.parallax_hole.desc", "Spawn a fake-depth parallax hole prop.")
    language.Add("tool.parallax_hole.0", "Left click: spawn. Right click: adjust selected hole.")

    function TOOL.BuildCPanel(panel)
        panel:Help("Parallax Hole")
        panel:NumSlider("Depth", "parallax_hole_depth", 64, 2000, 0)
        panel:NumSlider("Width", "parallax_hole_width", 8, 512, 0)
        panel:NumSlider("Height", "parallax_hole_height", 8, 512, 0)
    end
end

function TOOL:LeftClick(trace)
    if CLIENT then return true end
    if not trace.HitPos then return false end

    local ent = ents.Create("parallax_hole")
    if not IsValid(ent) then return false end

    ent:SetPos(trace.HitPos + trace.HitNormal * 4)
    ent:SetAngles(trace.HitNormal:Angle())
    ent:SetDepth(self:GetClientNumber("depth"))
    ent:SetWidth(self:GetClientNumber("width"))
    ent:SetHeight(self:GetClientNumber("height"))
    ent:Spawn()
    ent:Activate()

    return true
end

function TOOL:RightClick(trace)
    if CLIENT then return true end

    local ent = trace.Entity
    if not IsValid(ent) or ent:GetClass() ~= "parallax_hole" then return false end

    ent:SetDepth(self:GetClientNumber("depth"))
    ent:SetWidth(self:GetClientNumber("width"))
    ent:SetHeight(self:GetClientNumber("height"))
    return true
end
