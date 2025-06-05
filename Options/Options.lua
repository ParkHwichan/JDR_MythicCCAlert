local E = unpack(select(2, ...))
local AceGUI = E.Libs.AceGUI -- AceGUI-3.0

if not E.Options then
    E.Options = {}
    E.Options.testMode = false
end


function E.Options:buildOptionsFrame()
    -- if we already made it, just show it
    if E.Options.cfgFrame then
        E.Options.cfgFrame:Show()
        E.showingConfig = true
        return
    end

    -- 1) Create the main frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("JDR MythicCCAlert 설정")
    frame:SetStatusText("Slash '/jdr config' to toggle")
    frame:SetLayout("Fill")       -- so our TabGroup fills it
    frame:SetWidth(800)
    frame:SetHeight(620)
    frame:EnableResize(false)


    -- 2) Create a TabGroup that itself fills the frame
    local tabs = AceGUI:Create("TabGroup")
    tabs:SetLayout("Fill")        -- so the scroll + content fill it
    tabs:SetFullWidth(true)
    tabs:SetFullHeight(true)
    tabs:SetTabs({
        { text = "인터페이스", value = "INTERFACE" },
        { text = "주문",       value = "SPELLS"    },
    })
    tabs:SetCallback("OnGroupSelected", function(_, _, group)
        tabs:ReleaseChildren()

        if group == "INTERFACE" then
            E.Options:buildInterfaceTab(tabs)
        else
            E.Options:buildSpellTab(tabs)
        end
    end)

    frame:AddChild(tabs)
    tabs:SelectTab("INTERFACE")    -- default

    frame:SetCallback("OnClose", function()
        E:SetIconPool({})
        E.Options.testMode = false
        E.showingConfig = false
        tabs:SelectTab("INTERFACE")
        frame:Hide()
    end)

    -- 5) Save for next time
    E.Options.cfgFrame = frame
    E.showingConfig     = true
end