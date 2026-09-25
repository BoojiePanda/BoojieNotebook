local _, BN = ...

local ICON_TEXTURE = "Interface\\AddOns\\BoojieNotebook\\BoojieNotebookIcon.png"
-- Avoid "Note" in the internal name: WindTools treats names containing
-- "Note" as map-note pins and intentionally excludes them from its button bar.
local LDB_NAME = "BoojieBN"
local ldbIcon

function BN:SetMinimapButtonShown(shown)
    if not ldbIcon then
        return
    end

    self.db.settings.minimap.hide = not shown
    if shown then
        ldbIcon:Show(LDB_NAME)
    else
        ldbIcon:Hide(LDB_NAME)
    end
end

function BN:CreateMinimapButton()
    ldbIcon = LibStub("LibDBIcon-1.0")
    local launcher = LibStub("LibDataBroker-1.1"):NewDataObject(LDB_NAME, {
        type = "launcher",
        label = "Boojie Notebook",
        text = "Boojie Notebook",
        icon = ICON_TEXTURE,
        OnClick = function()
            self.frame:SetShown(not self.frame:IsShown())
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("Boojie Notebook", 1, 0.553, 0.631)
            tooltip:AddLine("Click to open or close.", 1, 1, 1)
        end,
    })

    self.db.settings.minimap.hide = not self.db.settings.showMinimapButton
    ldbIcon:Register(LDB_NAME, launcher, self.db.settings.minimap)
end
