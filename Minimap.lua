local _, BN = ...
local ICON_TEXTURE = "Interface\\AddOns\\BoojieNotebook\\BoojieNotebookIcon.png"

function BN:CreateMinimapButton()
    local button = CreateFrame("Button", "BoojieBNMinimapButton", Minimap)
    button:SetSize(31, 31)
    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("LeftButton")
    local function Position()
        local radius = (Minimap:GetWidth() * 0.5) + 10
        local radians = math.rad(self.db.settings.minimapAngle)
        button:ClearAllPoints()
        button:SetPoint("CENTER", Minimap, "CENTER", math.cos(radians) * radius, math.sin(radians) * radius)
    end
    Position()

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(ICON_TEXTURE)
    icon:SetSize(18, 18)
    icon:SetPoint("CENTER")
    button.icon = icon
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:SetHitRectInsets(-6, -6, -6, -6)
    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetTexture(136467)
    background:SetSize(24, 24)
    background:SetPoint("CENTER")
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture(136430)
    border:SetSize(50, 50)
    border:SetPoint("TOPLEFT")
    local function SyncPresentation()
        local onMinimap = button:GetParent() == Minimap
        background:SetShown(onMinimap)
        border:SetShown(onMinimap)
    end
    SyncPresentation()
    hooksecurefunc(button, "SetParent", SyncPresentation)
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    button:SetScript("OnClick", function()
        if not button._justDragged then self.frame:SetShown(not self.frame:IsShown()) end
    end)
    button:SetScript("OnDragStart", function(current)
        current:SetScript("OnUpdate", function()
            local cursorX, cursorY = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            local centerX, centerY = Minimap:GetCenter()
            if centerX and centerY then
                self.db.settings.minimapAngle = math.deg(math.atan2((cursorY / scale) - centerY, (cursorX / scale) - centerX))
                Position()
            end
        end)
    end)
    button:SetScript("OnDragStop", function(current)
        current:SetScript("OnUpdate", nil)
        current._justDragged = true
        Position()
        C_Timer.After(0, function() current._justDragged = nil end)
    end)
    button:SetScript("OnEnter", function()
        local mapX = Minimap:GetCenter()
        GameTooltip:SetOwner(Minimap, mapX and mapX < (UIParent:GetWidth() * 0.5) and "ANCHOR_RIGHT" or "ANCHOR_LEFT")
        GameTooltip:AddLine("BoojieNotebook")
        GameTooltip:AddLine("Click to open or close.", 1, 1, 1)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", GameTooltip_Hide)
    button:SetShown(self.db.settings.showMinimapButton)
    self.minimapButton = button
    self:ApplyTheme()
end
