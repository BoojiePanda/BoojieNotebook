local ADDON_NAME, BN = ...

BN.sections = { "notes", "lists", "references" }
BN.sectionNames = { notes = "Notes", lists = "Lists", references = "References" }
BN.entryNames = { notes = "Note", lists = "List", references = "Reference" }
BN.fonts = {
    { "Friz Quadrata", "Fonts\\FRIZQT__.TTF" },
    { "Arial Narrow", "Fonts\\ARIALN.TTF" },
    { "Morpheus", "Fonts\\MORPHEUS.TTF" },
    { "Skurri", "Fonts\\SKURRI.TTF" },
}
if C_AddOns.GetAddOnInfo("SharedMedia_MyMedia") then
    BN.fonts[#BN.fonts + 1] = { "Bellota", "Interface\\AddOns\\SharedMedia_MyMedia\\font\\Bellota-Regular.ttf" }
    BN.fonts[#BN.fonts + 1] = { "Bellota Bold", "Interface\\AddOns\\SharedMedia_MyMedia\\font\\Bellota-Bold.ttf" }
end

local defaults = {
    selected = "Account",
    section = "notes",
    font = "Fonts\\FRIZQT__.TTF",
    fontSize = 14,
    textColor = { 0.92, 0.92, 0.92 },
    background = { 0.035, 0.035, 0.045 },
    alpha = 0.96,
    theme = "class",
    classColorName = true,
    showMinimapButton = true,
    minimap = { minimapPos = 135 },
    width = 980,
    height = 650,
}

local function NewNotebook()
    return { notes = {}, lists = {}, references = {} }
end

local function CopyDefaults(target, source)
    for key, value in pairs(source) do
        if target[key] == nil then
            if type(value) == "table" then
                target[key] = {}
                CopyDefaults(target[key], value)
            else
                target[key] = value
            end
        end
    end
end

local appearanceKeys = { "theme", "textColor", "background", "alpha" }

local function CopyValue(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, child in pairs(value) do copy[key] = CopyValue(child) end
    return copy
end

function BN:SetAppearanceSetting(key, value)
    self.characterAppearance[key] = CopyValue(value)
    self.db.settings[key] = CopyValue(value)
end

function BN:Notebook(key)
    if key == "Account" then
        return self.db.account
    end
    local character = self.db.characters[key]
    return character and character.notebook
end

function BN:CharacterKeys()
    local keys = {}
    for key in pairs(self.db.characters) do
        keys[#keys + 1] = key
    end
    table.sort(keys, function(a, b) return a:lower() < b:lower() end)
    return keys
end

function BN:DisplayName(key)
    if key == "Account" then
        return "Personal Notebook"
    end
    local character = self.db.characters[key]
    return character and character.name or key
end

function BN:NewEntry(section)
    local now = time()
    local entry = {
        id = tostring(now) .. ":" .. tostring(math.random(100000, 999999)),
        title = "Untitled " .. self.entryNames[section],
        content = "",
        created = now,
        edited = now,
        pinned = false,
    }
    if section == "lists" then
        entry.items = {}
        entry.numbered = false
    end
    return entry
end

function BN:FindEntry(notebook, section, id)
    for index, entry in ipairs(notebook[section]) do
        if entry.id == id then
            return entry, index
        end
    end
end

function BN:CopyEntry(entry)
    local copy = {}
    for key, value in pairs(entry) do
        if key == "items" then
            copy.items = {}
            for index, item in ipairs(value) do
                copy.items[index] = { text = item.text, checked = item.checked }
            end
        else
            copy[key] = value
        end
    end
    copy.id = tostring(time()) .. ":" .. tostring(math.random(100000, 999999))
    copy.title = copy.title .. " Copy"
    copy.created = time()
    copy.edited = copy.created
    return copy
end

function BN:InitializeDatabase()
    BoojieNotebookDB = BoojieNotebookDB or {}
    self.db = BoojieNotebookDB
    self.db.settings = self.db.settings or {}
    local legacyMinimapAngle = tonumber(self.db.settings.minimapAngle)
    local hadMinimapSettings = type(self.db.settings.minimap) == "table"
    CopyDefaults(self.db.settings, defaults)
    if legacyMinimapAngle and not hadMinimapSettings then
        self.db.settings.minimap.minimapPos = legacyMinimapAngle
    end
    self.db.settings.minimapAngle = nil
    self.db.account = self.db.account or NewNotebook()
    self.db.characters = self.db.characters or {}

    local name, realm = UnitFullName("player")
    realm = realm or GetRealmName()
    local key = name .. " - " .. realm
    local character = self.db.characters[key]
    if not character then
        character = {
            notebook = NewNotebook(),
            appearance = {
                theme = "class",
                textColor = CopyValue(defaults.textColor),
                background = CopyValue(defaults.background),
                alpha = defaults.alpha,
            },
        }
        self.db.characters[key] = character
    end
    character.name = name
    character.realm = realm
    character.class = select(2, UnitClass("player"))
    character.faction = UnitFactionGroup("player")
    character.notebook = character.notebook or NewNotebook()
    character.appearance = character.appearance or {}
    for _, setting in ipairs(appearanceKeys) do
        if character.appearance[setting] == nil then
            character.appearance[setting] = CopyValue(self.db.settings[setting])
        end
        self.db.settings[setting] = CopyValue(character.appearance[setting])
    end
    self.characterAppearance = character.appearance
    for _, section in ipairs(self.sections) do
        character.notebook[section] = character.notebook[section] or {}
        self.db.account[section] = self.db.account[section] or {}
    end
    self.db.settings.selected = key
    self.currentCharacter = key
end

function BN:FormatShortDate(timestamp)
    local month, day, year = date("%m", timestamp), date("%d", timestamp), date("%Y", timestamp)
    return tonumber(month) .. "/" .. tonumber(day) .. "/" .. year
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, _, addon)
    if addon ~= ADDON_NAME then
        return
    end
    BN:InitializeDatabase()
    BN:CreateUI()
    BN:CreateMinimapButton()
    BN:RegisterSettings()
    eventFrame:UnregisterEvent("ADDON_LOADED")
end)

SLASH_BOOJIENOTEBOOK1 = "/boojienotes"
SLASH_BOOJIENOTEBOOK2 = "/bn"
SlashCmdList.BOOJIENOTEBOOK = function()
    if BN.frame then
        BN.frame:SetShown(not BN.frame:IsShown())
    end
end

SLASH_BOOJIERELOAD1 = SLASH_BOOJIERELOAD1 or "/rl"
SlashCmdList.BOOJIERELOAD = SlashCmdList.BOOJIERELOAD or ReloadUI
