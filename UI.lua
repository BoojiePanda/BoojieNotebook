local ADDON_NAME, BN = ...
local HEART_MARKUP = "|TInterface\\AddOns\\BoojieNotebook\\BoojieNotebookHeart.tga:10:10:0:0|t"
local ADDON_ICON = "Interface\\AddOns\\BoojieNotebook\\BoojieNotebookIcon.png"
local PERSONAL_NOTEBOOK_ICON = "Interface\\AddOns\\BoojieNotebook\\XalatathAvatar.png"

local function Backdrop(frame, color)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(color[1], color[2], color[3], color[4] or 1)
    frame:SetBackdropBorderColor(0.22, 0.22, 0.25, 1)
end

local function Button(parent, text, width, height)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(width or 100, height or 24)
    Backdrop(button, { 0.055, 0.055, 0.065, 0.96 })
    local fontString = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fontString:SetPoint("CENTER")
    fontString:SetText(text)
    BN.fontObjects[#BN.fontObjects + 1] = fontString
    button.text = fontString

    local selection = CreateFrame("Frame", nil, button)
    selection:SetAllPoints()
    selection.lines = {}
    local alphas = { 1, 0.65 }
    for index, alpha in ipairs(alphas) do
        local top = selection:CreateTexture(nil, "OVERLAY")
        top:SetTexture("Interface\\Buttons\\WHITE8X8")
        top:SetPoint("BOTTOMLEFT", selection, "TOPLEFT", 0, (index - 1) * 2)
        top:SetPoint("BOTTOMRIGHT", selection, "TOPRIGHT", 0, (index - 1) * 2)
        top:SetHeight(1)
        top.alpha = alpha
        selection.lines[#selection.lines + 1] = top

        local bottom = selection:CreateTexture(nil, "OVERLAY")
        bottom:SetTexture("Interface\\Buttons\\WHITE8X8")
        bottom:SetPoint("TOPLEFT", selection, "BOTTOMLEFT", 0, -(index - 1) * 2)
        bottom:SetPoint("TOPRIGHT", selection, "BOTTOMRIGHT", 0, -(index - 1) * 2)
        bottom:SetHeight(1)
        bottom.alpha = alpha
        selection.lines[#selection.lines + 1] = bottom
    end
    selection:Hide()
    button.selection = selection

    function button:SetText(value)
        self.text:SetText(value)
    end

    function button:GetFontString()
        return self.text
    end

    function button:SetSelected(selected)
        self.selection:SetShown(selected)
    end

    button:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.10, 0.10, 0.12, 1)
    end)
    button:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.055, 0.055, 0.065, 0.96)
    end)
    local color = BN.themeText or (BN.db and BN.db.settings.textColor)
    if color then
        button:SetBackdropBorderColor(color[1] * 0.55, color[2] * 0.55, color[3] * 0.55, 0.9)
        for _, line in ipairs(selection.lines) do
            line:SetVertexColor(color[1], color[2], color[3], line.alpha)
        end
    end
    BN.buttons[#BN.buttons + 1] = button
    return button
end

local function Label(parent, text, size)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetText(text)
    label._size = size
    BN.fontObjects[#BN.fontObjects + 1] = label
    if BN.db then
        label:SetFont(BN.db.settings.font, size or BN.db.settings.fontSize, "")
        label:SetTextColor(unpack(BN.themeText or BN.db.settings.textColor))
    end
    return label
end

local function EditBox(parent, multiline)
    local box = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
    Backdrop(box, { 0.02, 0.02, 0.025, 0.9 })
    box:SetTextInsets(8, 8, 6, 6)
    box:SetAutoFocus(false)
    box:SetEnabled(true)
    box:EnableMouse(true)
    box:EnableKeyboard(true)
    box:SetMultiLine(multiline or false)
    box:SetFontObject(ChatFontNormal)
    box:SetScript("OnEscapePressed", box.ClearFocus)
    BN.editBoxes[#BN.editBoxes + 1] = box
    if BN.db then
        box:SetFont(BN.db.settings.font, BN.db.settings.fontSize, "")
        box:SetTextColor(unpack(BN.themeText or BN.db.settings.textColor))
    end
    return box
end

local function StyleDropdown(dropdown)
    local name = dropdown:GetName()
    for _, suffix in ipairs({ "Left", "Middle", "Right" }) do
        local texture = _G[name .. suffix]
        if texture then texture:SetAlpha(0) end
    end

    local background = CreateFrame("Frame", nil, dropdown, "BackdropTemplate")
    background:SetPoint("TOPLEFT", 16, -2)
    background:SetPoint("BOTTOMRIGHT", -16, 2)
    background:SetFrameLevel(math.max(0, dropdown:GetFrameLevel() - 1))
    Backdrop(background, { 0.025, 0.025, 0.03, 0.96 })

    local button = _G[name .. "Button"]
    button:ClearAllPoints()
    button:SetAllPoints(background)
    button:GetNormalTexture():SetAlpha(0)
    button:GetPushedTexture():SetAlpha(0)
    button:GetDisabledTexture():SetAlpha(0)
    button:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")
    button:GetHighlightTexture():SetAlpha(0.08)
    local arrow = Label(button, "v", 11)
    arrow:SetPoint("RIGHT", -7, 1)

    local text = _G[name .. "Text"]
    text:ClearAllPoints()
    text:SetPoint("LEFT", background, 8, 0)
    text:SetPoint("RIGHT", background, -24, 0)
    text:SetJustifyH("LEFT")
    BN.fontObjects[#BN.fontObjects + 1] = text
    BN.dropdowns[#BN.dropdowns + 1] = background
end

local function Confirm(text, callback)
    StaticPopupDialogs.BOOJIE_NOTEBOOK_CONFIRM = {
        text = text,
        button1 = YES,
        button2 = NO,
        OnAccept = function(_, data) data() end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("BOOJIE_NOTEBOOK_CONFIRM", nil, nil, callback)
end

local function ColorPicker(color, changed)
    local info = {
        r = color[1], g = color[2], b = color[3],
        swatchFunc = function()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            changed(r, g, b)
        end,
        cancelFunc = function(previous)
            changed(previous.r, previous.g, previous.b)
        end,
    }
    ColorPickerFrame:SetupColorPickerAndShow(info)
end

local function RGB(color, fallback)
    if not color then return fallback end
    return { color.r or color[1], color.g or color[2], color.b or color[3] }
end

function BN:ApplyTheme()
    local settings = self.db.settings
    local background = settings.background
    local text = settings.textColor
    if settings.theme == "horde" then
        background, text = { 0, 0, 0 }, { 0.85, 0.08, 0.08 }
    elseif settings.theme == "alliance" then
        background, text = { 0, 0, 0 }, { 0.10, 0.40, 1 }
    elseif settings.theme == "class" then
        local character = self.db.characters[self.currentCharacter]
        local color = character and (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[character.class]
        background = { 0, 0, 0 }
        if color then text = { color.r, color.g, color.b } end
    elseif settings.theme == "boojiepink" then
        text = { 246 / 255, 177 / 255, 1 }
    elseif settings.theme == "elvui" and ElvUI then
        local E = unpack(ElvUI)
        if E and E.media then
            background = RGB(E.media.backdropcolor, background)
            text = RGB(E.media.rgbvaluecolor, text)
        end
    end
    self.themeText = text
    self.frame:SetBackdropColor(background[1], background[2], background[3], settings.alpha)
    self.sidebar:SetBackdropColor(background[1] * 0.7, background[2] * 0.7, background[3] * 0.7, settings.alpha)
    for _, fontString in ipairs(self.fontObjects) do
        local size = fontString._size or settings.fontSize
        fontString:SetFont(settings.font, size, "")
        fontString:SetTextColor(text[1], text[2], text[3])
    end
    for _, box in ipairs(self.editBoxes) do
        box:SetFont(settings.font, settings.fontSize, "")
        box:SetTextColor(text[1], text[2], text[3])
    end
    for _, button in ipairs(self.buttons) do
        button:SetBackdropBorderColor(text[1] * 0.55, text[2] * 0.55, text[3] * 0.55, 0.9)
        for _, line in ipairs(button.selection.lines) do
            line:SetVertexColor(text[1], text[2], text[3], line.alpha)
        end
    end
    for _, dropdown in ipairs(self.dropdowns) do
        dropdown:SetBackdropBorderColor(text[1] * 0.65, text[2] * 0.65, text[3] * 0.65, 0.9)
    end
    local themeDropdownText = _G.BoojieNotebookThemeDropdownText
    if themeDropdownText then
        themeDropdownText:SetTextColor(text[1], text[2], text[3])
    end
    if self.header then
        self:UpdateHeader()
    end
end

function BN:UpdateHeader()
    local key = self.db.settings.selected
    local name = self:DisplayName(key)
    self.header:SetText(key == "Account" and "My Notebook" or name .. "'s Notebook")
    local character = self.db.characters[key]
    if key == "Account" then
        self.classIcon:SetTexture(PERSONAL_NOTEBOOK_ICON)
        self.classIcon:SetTexCoord(0, 1, 0, 1)
        self.classIconFrame:Show()
        self.header:SetTextColor(unpack(self.themeText))
    elseif character and character.class then
        local coords = CLASS_ICON_TCOORDS[character.class]
        self.classIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
        self.classIcon:SetTexCoord(unpack(coords))
        self.classIconFrame:Show()
        local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[character.class]
        if self.db.settings.classColorName and color then
            self.header:SetTextColor(color.r, color.g, color.b)
        else
            self.header:SetTextColor(unpack(self.themeText))
        end
    else
        self.classIconFrame:Hide()
        self.header:SetTextColor(unpack(self.themeText))
    end
end

function BN:PopulateCharacterDropdown()
    UIDropDownMenu_Initialize(self.characterDropdown, function(_, level)
        local function Add(key, text)
            local info = UIDropDownMenu_CreateInfo()
            info.text = self.db.settings.selected == key and HEART_MARKUP .. " " .. text or text
            info.notCheckable = true
            info.func = function()
                self:SaveEditor()
                self.db.settings.selected = key
                UIDropDownMenu_SetText(self.characterDropdown, self:DisplayName(key))
                self.selectedEntry = nil
                self.searchBox:SetText("")
                self:Refresh()
            end
            UIDropDownMenu_AddButton(info, level)
        end
        Add("Account", "Personal Notebook")
        local current = self.currentCharacter
        local character = self.db.characters[current]
        Add(current, character.name .. " - " .. character.realm)
        for _, key in ipairs(self:CharacterKeys()) do
            if key ~= current then
                local character = self.db.characters[key]
                Add(key, character.name .. " - " .. character.realm)
            end
        end
    end)
    UIDropDownMenu_SetText(self.characterDropdown, self:DisplayName(self.db.settings.selected))
end

function BN:GetVisibleEntries()
    local notebook = self:Notebook(self.db.settings.selected)
    local query = self.searchBox:GetText():lower()
    local entries = {}
    local sections = query ~= "" and self.sections or { self.db.settings.section }
    for _, section in ipairs(sections) do
        for _, entry in ipairs(notebook[section]) do
            local searchable = entry.title .. " " .. (entry.content or "")
            for _, item in ipairs(entry.items or {}) do
                searchable = searchable .. " " .. item.text
            end
            if query == "" or searchable:lower():find(query, 1, true) then
                entries[#entries + 1] = { entry = entry, section = section }
            end
        end
    end
    table.sort(entries, function(a, b)
        if a.entry.pinned ~= b.entry.pinned then
            return a.entry.pinned
        end
        return a.entry.edited > b.entry.edited
    end)
    return entries
end

function BN:SaveEditor()
    local entry = self.selectedEntry
    if not entry or not self.editor:IsShown() then
        return
    end
    local changed = false
    local title = strtrim(self.titleBox:GetText())
    title = title ~= "" and title or "Untitled " .. self.entryNames[self.selectedSection]
    if entry.title ~= title then entry.title = title; changed = true end
    if self.selectedSection ~= "lists" then
        local content = self.contentBox:GetText()
        if entry.content ~= content then entry.content = content; changed = true end
    end
    if changed then entry.edited = time() end
end

function BN:ShowEntry(entry, section)
    self:SaveEditor()
    self.selectedEntry = entry
    self.selectedSection = section
    self.emptyMessage:Hide()
    self.editor:Show()
    self.titleBox:SetText(entry.title)
    self.pinButton:SetText(entry.pinned and "Unpin" or "Pin")
    self.listControls:SetShown(section == "lists")
    self.contentScroll:SetShown(section ~= "lists")
    if section == "lists" then
        self.numberedCheck:SetChecked(entry.numbered)
        self:RefreshListItems()
    else
        self.contentBox:SetText(entry.content or "")
        self.contentBox:SetCursorPosition(0)
        self.contentScroll:SetVerticalScroll(0)
        C_Timer.After(0, function()
            if self.selectedEntry == entry then
                self.contentBox:SetCursorPosition(0)
                self.contentScroll:SetVerticalScroll(0)
            end
        end)
    end
end

function BN:RefreshListItems()
    for _, row in ipairs(self.itemRows) do row:Hide() end
    local entry = self.selectedEntry
    if not entry or self.selectedSection ~= "lists" then return end
    local previous
    for index, item in ipairs(entry.items) do
        local row = self.itemRows[index]
        if not row then
            row = CreateFrame("Frame", nil, self.itemContent)
            row:SetHeight(30)
            row.check = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
            row.check:SetPoint("LEFT", 0, 0)
            row.number = Label(row, "", 13)
            row.number:SetPoint("LEFT", 3, 0)
            row.box = EditBox(row)
            row.box:SetPoint("LEFT", 31, 0)
            row.box:SetPoint("RIGHT", -30, 0)
            row.box:SetHeight(25)
            row.delete = Button(row, "×", 25, 25)
            row.delete:SetPoint("RIGHT")
            self.itemRows[index] = row
        end
        row:ClearAllPoints()
        if previous then
            row:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -4)
            row:SetPoint("TOPRIGHT", previous, "BOTTOMRIGHT", 0, -4)
        else
            row:SetPoint("TOPLEFT")
            row:SetPoint("TOPRIGHT")
        end
        row.check:SetShown(not entry.numbered)
        row.number:SetShown(entry.numbered)
        row.number:SetText(index .. ".")
        row.check:SetChecked(item.checked)
        row.box:SetText(item.text or "")
        row.check:SetScript("OnClick", function(button)
            item.checked = button:GetChecked() and true or false
            entry.edited = time()
        end)
        row.box:SetScript("OnTextChanged", function(box, user)
            if user then item.text = box:GetText(); entry.edited = time() end
        end)
        row.delete:SetScript("OnClick", function()
            Confirm("Delete this list item?", function()
                table.remove(entry.items, index)
                entry.edited = time()
                self:RefreshListItems()
            end)
        end)
        row:Show()
        previous = row
    end
    self.itemContent:SetHeight(math.max(1, #entry.items * 34))
end

function BN:RefreshEntryList()
    for _, row in ipairs(self.entryRows) do row:Hide() end
    local visible = self:GetVisibleEntries()
    local previous
    for index, data in ipairs(visible) do
        local row = self.entryRows[index]
        if not row then
            row = CreateFrame("Button", nil, self.entryListContent, "BackdropTemplate")
            row:SetHeight(42)
            Backdrop(row, { 0.06, 0.06, 0.075, 0.85 })
            row.title = Label(row, "", 13)
            row.title:SetPoint("TOPLEFT", 8, -6)
            row.title:SetPoint("RIGHT", -6, 0)
            row.title:SetJustifyH("LEFT")
            row.detail = Label(row, "", 10)
            row.detail:SetPoint("BOTTOMLEFT", 8, 5)
            self.entryRows[index] = row
        end
        row:ClearAllPoints()
        if previous then
            row:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -4)
            row:SetPoint("TOPRIGHT", previous, "BOTTOMRIGHT", 0, -4)
        else
            row:SetPoint("TOPLEFT")
            row:SetPoint("TOPRIGHT")
        end
        row.title:SetText((data.entry.pinned and "★ " or "") .. data.entry.title)
        row.detail:SetText("Created " .. self:FormatShortDate(data.entry.created) .. " - Edited " .. self:FormatShortDate(data.entry.edited))
        row:SetScript("OnClick", function() self:ShowEntry(data.entry, data.section) end)
        row:Show()
        previous = row
    end
    self.entryListContent:SetHeight(math.max(1, #visible * 46))
end

function BN:Refresh()
    self:ApplyTheme()
    for section, button in pairs(self.sectionButtons) do
        button:SetSelected(section == self.db.settings.section)
    end
    self.newButton:SetText("New " .. self.entryNames[self.db.settings.section])
    self:RefreshEntryList()
    if self.selectedEntry then
        local notebook = self:Notebook(self.db.settings.selected)
        if not self:FindEntry(notebook, self.selectedSection, self.selectedEntry.id) then
            self.selectedEntry = nil
        end
    end
    self.editor:SetShown(self.selectedEntry ~= nil)
    self.emptyMessage:SetShown(self.selectedEntry == nil)
end

function BN:OpenTransferMenu(anchor, copy)
    MenuUtil.CreateContextMenu(anchor, function(_, root)
        root:CreateTitle(copy and "Copy to" or "Move to")
        local function Add(key, text)
            if key ~= self.db.settings.selected then
                root:CreateButton(text, function()
                    self:SaveEditor()
                    local target = self:Notebook(key)
                    local source = self:Notebook(self.db.settings.selected)
                    local entry = self.selectedEntry
                    local section = self.selectedSection
                    if copy then
                        table.insert(target[section], self:CopyEntry(entry))
                    else
                        local _, index = self:FindEntry(source, section, entry.id)
                        table.remove(source[section], index)
                        table.insert(target[section], entry)
                        self.selectedEntry = nil
                    end
                    self:Refresh()
                end)
            end
        end
        Add("Account", "Personal Notebook")
        for _, key in ipairs(self:CharacterKeys()) do Add(key, key) end
    end)
end

function BN:CreateSidebar()
    local sidebar = CreateFrame("Frame", nil, self.frame, "BackdropTemplate")
    sidebar:SetPoint("TOPLEFT", 10, -38)
    sidebar:SetPoint("BOTTOMLEFT", 10, 10)
    sidebar:SetWidth(230)
    Backdrop(sidebar, { 0.025, 0.025, 0.03, 0.96 })
    self.sidebar = sidebar

    local choose = Label(sidebar, "Notebook", 14)
    choose:SetPoint("TOPLEFT", 14, -14)
    self.characterDropdown = CreateFrame("Frame", "BoojieNotebookCharacterDropdown", sidebar, "UIDropDownMenuTemplate")
    self.characterDropdown:SetPoint("TOPLEFT", -3, -32)
    UIDropDownMenu_SetWidth(self.characterDropdown, 175)
    StyleDropdown(self.characterDropdown)

    local settings = Label(sidebar, "Settings", 16)
    settings:SetPoint("TOPLEFT", 14, -90)
    local themeLabel = Label(sidebar, "Theme", 12)
    themeLabel:SetPoint("TOPLEFT", 14, -122)
    self.themeDropdown = CreateFrame("Frame", "BoojieNotebookThemeDropdown", sidebar, "UIDropDownMenuTemplate")
    self.themeDropdown:SetPoint("TOPLEFT", -3, -137)
    UIDropDownMenu_SetWidth(self.themeDropdown, 175)
    StyleDropdown(self.themeDropdown)
    UIDropDownMenu_Initialize(self.themeDropdown, function(_, level)
        local themes = {
            { "custom", "Custom", "ffffff" },
            { "boojiepink", "BoojiePink", "f6b1ff" },
            { "horde", "Horde", "d91414" },
            { "alliance", "Alliance", "1a66ff" },
            { "class", "Class Theme", "ffffff" },
        }
        if ElvUI then themes[#themes + 1] = { "elvui", "Match ElvUI", "00bfff" } end
        for _, theme in ipairs(themes) do
            local key, text, color = unpack(theme)
            local info = UIDropDownMenu_CreateInfo()
            info.text = self.db.settings.theme == key and HEART_MARKUP .. " |cff" .. color .. text .. "|r" or text
            info.notCheckable = true
            info.func = function()
                self:SetAppearanceSetting("theme", key)
                UIDropDownMenu_SetText(self.themeDropdown, text)
                self:Refresh()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    local themeNames = { custom = "Custom", boojiepink = "BoojiePink", horde = "Horde", alliance = "Alliance", class = "Class Theme", elvui = "Match ElvUI" }
    UIDropDownMenu_SetText(self.themeDropdown, themeNames[self.db.settings.theme] or "Custom")

    local fontLabel = Label(sidebar, "Font", 12)
    fontLabel:SetPoint("TOPLEFT", 14, -190)
    self.fontDropdown = CreateFrame("Frame", "BoojieNotebookFontDropdown", sidebar, "UIDropDownMenuTemplate")
    self.fontDropdown:SetPoint("TOPLEFT", -3, -205)
    UIDropDownMenu_SetWidth(self.fontDropdown, 175)
    StyleDropdown(self.fontDropdown)
    UIDropDownMenu_Initialize(self.fontDropdown, function(_, level)
        for _, font in ipairs(self.fonts) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = self.db.settings.font == font[2] and HEART_MARKUP .. " " .. font[1] or font[1]
            info.notCheckable = true
            info.func = function()
                self.db.settings.font = font[2]
                UIDropDownMenu_SetText(self.fontDropdown, font[1])
                self:Refresh()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    for _, font in ipairs(self.fonts) do
        if font[2] == self.db.settings.font then UIDropDownMenu_SetText(self.fontDropdown, font[1]) end
    end

    local sizeLabel = Label(sidebar, "Font Size", 12)
    sizeLabel:SetPoint("TOPLEFT", 14, -258)
    local slider = CreateFrame("Slider", nil, sidebar, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", 20, -282)
    slider:SetWidth(185)
    slider:SetMinMaxValues(10, 24)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)
    slider:SetValue(self.db.settings.fontSize)
    slider.Low:SetText("10"); slider.High:SetText("24"); slider.Text:SetText(self.db.settings.fontSize)
    slider:SetScript("OnValueChanged", function(control, value)
        value = math.floor(value + 0.5)
        self.db.settings.fontSize = value
        control.Text:SetText(value)
        self:Refresh()
    end)

    local textColor = Button(sidebar, "Text Color", 92, 24)
    textColor:SetPoint("TOPLEFT", 14, -310)
    textColor:SetScript("OnClick", function()
        ColorPicker(self.db.settings.textColor, function(r, g, b)
            self:SetAppearanceSetting("textColor", { r, g, b })
            self:SetAppearanceSetting("theme", "custom")
            self:Refresh()
        end)
    end)
    local background = Button(sidebar, "Background", 100, 24)
    background:SetPoint("LEFT", textColor, "RIGHT", 6, 0)
    background:SetScript("OnClick", function()
        ColorPicker(self.db.settings.background, function(r, g, b)
            self:SetAppearanceSetting("background", { r, g, b })
            self:SetAppearanceSetting("theme", "custom")
            self:Refresh()
        end)
    end)

    local alphaLabel = Label(sidebar, "Transparency", 12)
    alphaLabel:SetPoint("TOPLEFT", 14, -344)
    local alpha = CreateFrame("Slider", nil, sidebar, "OptionsSliderTemplate")
    alpha:SetPoint("TOPLEFT", 20, -366)
    alpha:SetWidth(185)
    alpha:SetMinMaxValues(0.25, 1)
    alpha:SetValueStep(0.05)
    alpha:SetObeyStepOnDrag(true)
    alpha:SetValue(self.db.settings.alpha)
    alpha.Low:SetText("25%"); alpha.High:SetText("100%"); alpha.Text:SetText(math.floor(self.db.settings.alpha * 100) .. "%")
    alpha:SetScript("OnValueChanged", function(control, value)
        self:SetAppearanceSetting("alpha", value)
        control.Text:SetText(math.floor(value * 100) .. "%")
        self:ApplyTheme()
    end)

    local classColor = CreateFrame("CheckButton", nil, sidebar, "UICheckButtonTemplate")
    classColor:SetChecked(self.db.settings.classColorName)
    classColor.text = Label(classColor, "Class-colored name", 12)
    classColor.text:SetPoint("LEFT", classColor, "RIGHT", 2, 0)
    classColor:SetScript("OnClick", function(button)
        self.db.settings.classColorName = button:GetChecked() and true or false
        self:UpdateHeader()
    end)
    local minimap = CreateFrame("CheckButton", nil, sidebar, "UICheckButtonTemplate")
    minimap:SetPoint("BOTTOMLEFT", 10, 8)
    classColor:SetPoint("BOTTOMLEFT", minimap, "TOPLEFT", 0, 2)
    minimap:SetChecked(self.db.settings.showMinimapButton)
    minimap.text = Label(minimap, "Show minimap button", 12)
    minimap.text:SetPoint("LEFT", minimap, "RIGHT", 2, 0)
    minimap:SetScript("OnClick", function(button)
        self.db.settings.showMinimapButton = button:GetChecked() and true or false
        self:SetMinimapButtonShown(self.db.settings.showMinimapButton)
    end)
end

function BN:CreateContent()
    local content = CreateFrame("Frame", nil, self.frame)
    content:SetPoint("TOPLEFT", self.sidebar, "TOPRIGHT", 10, 0)
    content:SetPoint("BOTTOMRIGHT", -10, 10)

    self.classIconFrame = CreateFrame("Frame", nil, content, "BackdropTemplate")
    self.classIconFrame:SetSize(38, 38)
    self.classIconFrame:SetPoint("TOPLEFT", 4, -2)
    Backdrop(self.classIconFrame, { 0, 0, 0, 1 })
    self.classIconFrame:SetClipsChildren(true)
    self.classIcon = self.classIconFrame:CreateTexture(nil, "ARTWORK")
    self.classIcon:SetPoint("TOPLEFT", -5, 5)
    self.classIcon:SetPoint("BOTTOMRIGHT", 5, -5)
    local mask = self.classIconFrame:CreateMaskTexture()
    mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(self.classIconFrame)
    self.classIcon:AddMaskTexture(mask)
    self.header = Label(content, "", 22)
    self.header:SetPoint("LEFT", self.classIconFrame, "RIGHT", 10, 0)

    self.sectionButtons = {}
    for index, section in ipairs(self.sections) do
        local button = Button(content, self.sectionNames[section], 110, 28)
        button:SetPoint("TOP", content, "TOP", (index - 2) * 116, -50)
        button:SetScript("OnClick", function()
            self:SaveEditor()
            self.db.settings.section = section
            self.selectedEntry = nil
            self.searchBox:SetText("")
            self:Refresh()
        end)
        self.sectionButtons[section] = button
    end
    self.searchBox = EditBox(content)
    self.searchBox:SetSize(180, 26)
    self.searchBox:SetPoint("TOPRIGHT", -2, -8)
    self.searchBox:SetTextInsets(24, 7, 0, 0)
    self.searchBox.Instructions = self.searchBox:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    self.searchBox.Instructions:SetPoint("LEFT", 25, 0)
    self.searchBox.Instructions:SetText("Search all sections")
    self.searchBox:SetScript("OnTextChanged", function(box)
        box.Instructions:SetShown(box:GetText() == "")
        self:RefreshEntryList()
    end)
    local searchIcon = self.searchBox:CreateTexture(nil, "ARTWORK")
    searchIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon")
    searchIcon:SetSize(14, 14); searchIcon:SetPoint("LEFT", 6, 0)

    self.newButton = Button(content, "", 120, 25)
    self.newButton:SetPoint("TOPLEFT", 4, -88)
    self.newButton:SetScript("OnClick", function()
        self:SaveEditor()
        local section = self.db.settings.section
        local entry = self:NewEntry(section)
        table.insert(self:Notebook(self.db.settings.selected)[section], entry)
        self:RefreshEntryList()
        self:ShowEntry(entry, section)
        self.titleBox:HighlightText(); self.titleBox:SetFocus()
    end)
    local listScroll = CreateFrame("ScrollFrame", nil, content, "UIPanelScrollFrameTemplate")
    listScroll:SetPoint("TOPLEFT", 4, -120)
    listScroll:SetPoint("BOTTOMLEFT", 4, 4)
    listScroll:SetWidth(225)
    self.entryListContent = CreateFrame("Frame", nil, listScroll)
    self.entryListContent:SetWidth(202)
    listScroll:SetScrollChild(self.entryListContent)
    self.entryRows = {}

    self.editor = CreateFrame("Frame", nil, content, "BackdropTemplate")
    self.editor:SetPoint("TOPLEFT", listScroll, "TOPRIGHT", 14, 0)
    self.editor:SetPoint("BOTTOMRIGHT", -2, 4)
    Backdrop(self.editor, { 0.045, 0.045, 0.055, 0.85 })
    self.titleBox = EditBox(self.editor)
    self.titleBox:SetPoint("TOPLEFT", 10, -10); self.titleBox:SetPoint("TOPRIGHT", -10, -10); self.titleBox:SetHeight(30)
    self.titleBox:SetScript("OnTextChanged", function(box, user)
        if user and self.selectedEntry then
            local title = strtrim(box:GetText())
            self.selectedEntry.title = title ~= "" and title or "Untitled " .. self.entryNames[self.selectedSection]
            self.selectedEntry.edited = time()
            self:RefreshEntryList()
        end
    end)
    self.titleBox:SetScript("OnEnterPressed", function(box) box:ClearFocus(); self:SaveEditor(); self:RefreshEntryList() end)
    self.pinButton = Button(self.editor, "Pin", 58, 23); self.pinButton:SetPoint("TOPLEFT", 10, -49)
    self.pinButton:SetScript("OnClick", function()
        self.selectedEntry.pinned = not self.selectedEntry.pinned
        self.pinButton:SetText(self.selectedEntry.pinned and "Unpin" or "Pin")
        self:RefreshEntryList()
    end)
    local duplicate = Button(self.editor, "Duplicate", 78, 23); duplicate:SetPoint("LEFT", self.pinButton, "RIGHT", 5, 0)
    duplicate:SetScript("OnClick", function()
        self:SaveEditor()
        local copy = self:CopyEntry(self.selectedEntry)
        table.insert(self:Notebook(self.db.settings.selected)[self.selectedSection], copy)
        self:RefreshEntryList(); self:ShowEntry(copy, self.selectedSection)
    end)
    local copy = Button(self.editor, "Copy To", 68, 23); copy:SetPoint("LEFT", duplicate, "RIGHT", 5, 0)
    copy:SetScript("OnClick", function(button) self:OpenTransferMenu(button, true) end)
    local move = Button(self.editor, "Move To", 68, 23); move:SetPoint("LEFT", copy, "RIGHT", 5, 0)
    move:SetScript("OnClick", function(button) self:OpenTransferMenu(button, false) end)
    local delete = Button(self.editor, "Delete", 62, 23); delete:SetPoint("LEFT", move, "RIGHT", 5, 0)
    delete:SetScript("OnClick", function()
        Confirm("Delete this " .. self.entryNames[self.selectedSection]:lower() .. "?", function()
            local notebook = self:Notebook(self.db.settings.selected)
            local _, index = self:FindEntry(notebook, self.selectedSection, self.selectedEntry.id)
            table.remove(notebook[self.selectedSection], index)
            self.selectedEntry = nil
            self:Refresh()
        end)
    end)

    local contentBackground = CreateFrame("Frame", nil, self.editor, "BackdropTemplate")
    contentBackground:SetPoint("TOPLEFT", 10, -85); contentBackground:SetPoint("BOTTOMRIGHT", -10, 10)
    Backdrop(contentBackground, { 0.02, 0.02, 0.025, 0.9 })
    self.contentScroll = CreateFrame("ScrollFrame", nil, self.editor, "InputScrollFrameTemplate")
    self.contentScroll:SetPoint("TOPLEFT", contentBackground, 6, -6)
    self.contentScroll:SetPoint("BOTTOMRIGHT", contentBackground, -6, 6)
    self.contentScroll.maxLetters = 0
    self.contentScroll.hideCharCount = true
    self.contentScroll.instructions = ""
    InputScrollFrame_OnLoad(self.contentScroll)
    self.contentBox = self.contentScroll.EditBox
    self.contentBox:SetAutoFocus(false)
    self.contentBox:SetFont(self.db.settings.font, self.db.settings.fontSize, "")
    self.contentBox:SetTextColor(unpack(self.themeText or self.db.settings.textColor))
    self.contentBox:SetScript("OnEscapePressed", self.contentBox.ClearFocus)
    self.editBoxes[#self.editBoxes + 1] = self.contentBox
    self.contentBox:HookScript("OnTextChanged", function(box, user)
        if user and self.selectedEntry and self.selectedSection ~= "lists" then
            self.selectedEntry.content = box:GetText()
            self.selectedEntry.edited = time()
        end
    end)

    self.listControls = CreateFrame("Frame", nil, self.editor)
    self.listControls:SetPoint("TOPLEFT", 10, -85); self.listControls:SetPoint("BOTTOMRIGHT", -10, 10)
    self.numberedCheck = CreateFrame("CheckButton", nil, self.listControls, "UICheckButtonTemplate")
    self.numberedCheck:SetPoint("TOPLEFT")
    self.numberedCheck.text = Label(self.numberedCheck, "Numbered list", 12); self.numberedCheck.text:SetPoint("LEFT", self.numberedCheck, "RIGHT", 2, 0)
    self.numberedCheck:SetScript("OnClick", function(button)
        self.selectedEntry.numbered = button:GetChecked() and true or false
        self.selectedEntry.edited = time(); self:RefreshListItems()
    end)
    local addItem = Button(self.listControls, "Add Item", 80, 23); addItem:SetPoint("TOPRIGHT")
    addItem:SetScript("OnClick", function()
        table.insert(self.selectedEntry.items, { text = "", checked = false })
        self.selectedEntry.edited = time(); self:RefreshListItems()
        self.itemRows[#self.selectedEntry.items].box:SetFocus()
    end)
    local itemScroll = CreateFrame("ScrollFrame", nil, self.listControls, "UIPanelScrollFrameTemplate")
    itemScroll:SetPoint("TOPLEFT", 0, -38)
    itemScroll:SetPoint("BOTTOMRIGHT", -20, 0)
    self.itemContent = CreateFrame("Frame", nil, itemScroll)
    self.itemContent:SetWidth(420)
    self.itemContent:SetHeight(1)
    itemScroll:SetScrollChild(self.itemContent)
    self.itemRows = {}

    local function LayoutEditor(width)
        move:ClearAllPoints()
        delete:ClearAllPoints()
        contentBackground:ClearAllPoints()
        self.listControls:ClearAllPoints()
        if width < 390 then
            move:SetPoint("TOPLEFT", 10, -77)
            delete:SetPoint("LEFT", move, "RIGHT", 5, 0)
            contentBackground:SetPoint("TOPLEFT", 10, -113)
            self.listControls:SetPoint("TOPLEFT", 10, -113)
        else
            move:SetPoint("LEFT", copy, "RIGHT", 5, 0)
            delete:SetPoint("LEFT", move, "RIGHT", 5, 0)
            contentBackground:SetPoint("TOPLEFT", 10, -85)
            self.listControls:SetPoint("TOPLEFT", 10, -85)
        end
        contentBackground:SetPoint("BOTTOMRIGHT", -10, 10)
        self.listControls:SetPoint("BOTTOMRIGHT", -10, 10)
    end
    self.editor:SetScript("OnSizeChanged", function(_, width)
        LayoutEditor(width)
    end)
    LayoutEditor(self.editor:GetWidth())

    self.emptyMessage = Label(content, "Select an entry or create a new one.", 15)
    self.emptyMessage:SetPoint("CENTER", self.editor)
end

function BN:CreateUI()
    self.fontObjects, self.editBoxes, self.buttons, self.dropdowns = {}, {}, {}, {}
    local frame = CreateFrame("Frame", "BoojieNotebookFrame", UIParent, "BackdropTemplate")
    UISpecialFrames[#UISpecialFrames + 1] = "BoojieNotebookFrame"
    frame:Hide()
    frame:SetSize(self.db.settings.width, self.db.settings.height)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:SetResizeBounds(800, 520, 1400, 900)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnShow", function(control) control:Raise() end)
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetScript("OnHide", function() self:SaveEditor() end)
    Backdrop(frame, { 0.035, 0.035, 0.045, 0.96 })
    self.frame = frame

    local addonIcon = frame:CreateTexture(nil, "ARTWORK")
    addonIcon:SetTexture(ADDON_ICON)
    addonIcon:SetSize(24, 24)
    addonIcon:SetPoint("TOPLEFT", 12, -7)
    local version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")
    local title = Label(frame, "BoojieNotebook v" .. version, 18); title:SetPoint("LEFT", addonIcon, "RIGHT", 6, 0)
    local gameVersion = Label(frame, "Midnight, Patch 12.1 \"Curse of Ula’tek,\" Season 2", 13)
    gameVersion:SetPoint("TOP", frame, "TOP", 0, -14)
    local close = Button(frame, "×", 28, 28)
    close.text._size = 22
    close:SetPoint("TOPRIGHT", -6, -6)
    close:SetScript("OnClick", function() frame:Hide() end)
    local resize = CreateFrame("Button", nil, frame)
    resize:SetSize(28, 28); resize:SetPoint("BOTTOMRIGHT")
    resize:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resize:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resize:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resize:SetScript("OnMouseDown", function() frame:StartSizing("BOTTOMRIGHT") end)
    resize:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        self.db.settings.width, self.db.settings.height = frame:GetSize()
    end)

    self:CreateSidebar()
    self:CreateContent()
    self:PopulateCharacterDropdown()
    self:Refresh()
end

function BN:RegisterSettings()
    local panel = CreateFrame("Frame")
    panel.name = "Boojie Notebook"

    local icon = panel:CreateTexture(nil, "ARTWORK")
    icon:SetSize(128, 128)
    icon:SetPoint("TOP", 0, -28)
    icon:SetTexture(ADDON_ICON)

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOP", icon, "BOTTOM", 0, -12); title:SetText("Boojie Notebook")
    local notice = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    notice:SetPoint("TOP", title, "BOTTOM", 0, -14)
    notice:SetText("Open Boojie Notebook from any chat window with /boojienotes or /bn.")
    local open = CreateFrame("Button", nil, panel, "BackdropTemplate")
    open:SetSize(180, 26)
    open:SetPoint("TOP", notice, "BOTTOM", 0, -18)
    Backdrop(open, { 0.055, 0.055, 0.065, 0.96 })
    open:SetBackdropBorderColor(0.45, 0.45, 0.48, 1)
    local openText = open:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    openText:SetPoint("CENTER")
    openText:SetText("Open Boojie Notebook")
    BN.fontObjects[#BN.fontObjects + 1] = openText
    open:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.10, 0.10, 0.12, 1)
    end)
    open:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.055, 0.055, 0.065, 0.96)
    end)
    open:SetScript("OnClick", function() self.frame:Show() end)

    local addonDescription = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    addonDescription:SetPoint("TOP", open, "BOTTOM", 0, -24)
    addonDescription:SetWidth(420)
    addonDescription:SetJustifyH("CENTER")
    addonDescription:SetText(C_AddOns.GetAddOnMetadata(ADDON_NAME, "Notes") or "")

    local author = panel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    author:SetPoint("BOTTOM", 0, 24)
    author:SetText("by " .. (C_AddOns.GetAddOnMetadata(ADDON_NAME, "Author") or "SilverRavyn"))

    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end
end
