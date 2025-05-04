
function DumpTable(tbl, indent)
    indent = indent or ""
    for k, v in pairs(tbl) do
        local keyStr = tostring(k)
        local valStr
        if type(v) == "table" then
            DumpTable(v, indent .. "  ")
        else
            valStr = tostring(v)
        end
    end
end
-- ───────────────────────────────────────────
--  사각 테두리 글로우  (ADD, 황금, α 펄스)
-- ───────────────────────────────────────────
local GOLD = { r = 1, g = 0.82, b = 0 }

function ShowGlow(bar)
    if not bar.gGlow then
        local g = CreateFrame("Frame", nil, bar)
        g:SetPoint("TOPLEFT",  -2,  2)
        g:SetPoint("BOTTOMRIGHT", 2, -2)
        g:SetFrameLevel(bar:GetFrameLevel() + 5)

        ------------------------------------------------
        -- 4 면 2-픽셀 황금선
        ------------------------------------------------
        local TEX = "Interface\\BUTTONS\\WHITE8X8"
        local function edge(parent, point1, point2, w, h)
            local t = parent:CreateTexture(nil, "OVERLAY")
            t:SetTexture(TEX)
            t:SetVertexColor(GOLD.r, GOLD.g, GOLD.b)
            t:SetBlendMode("ADD")
            t:SetPoint(point1)
            t:SetPoint(point2)
            if w then t:SetWidth(w) end
            if h then t:SetHeight(h) end
        end
        edge(g, "TOPLEFT",    "TOPRIGHT",  nil, 2)  -- 위
        edge(g, "BOTTOMLEFT", "BOTTOMRIGHT", nil, 2) -- 아래
        edge(g, "TOPLEFT",    "BOTTOMLEFT", 2)       -- 왼
        edge(g, "TOPRIGHT",   "BOTTOMRIGHT", 2)      -- 오

        ------------------------------------------------
        -- α 펄스 애니메이션  (1 → 0.25 → 1 …)
        ------------------------------------------------
        local ag   = g:CreateAnimationGroup()
        local out  = ag:CreateAnimation("Alpha")
        out:SetFromAlpha(1)   out:SetToAlpha(0.25)
        out:SetDuration(0.35) out:SetOrder(1)

        local inn  = ag:CreateAnimation("Alpha")
        inn:SetFromAlpha(0.25) inn:SetToAlpha(1)
        inn:SetDuration(0.35)  inn:SetOrder(2)

        ag:SetLooping("REPEAT")

        g.ag   = ag
        bar.gGlow = g
    end

    bar.gGlow:Show()
    bar.gGlow.ag:Play()
end

function HideGlow(bar)
    if bar.gGlow then
        bar.gGlow.ag:Stop()
        bar.gGlow:Hide()
    end
end

function GetSpecRGB(classToken)
    local classC = C_ClassColor.GetClassColor(classToken)
            or RAID_CLASS_COLORS[classToken]
            or { r = 1, g = 1, b = 1 }
    return {
        r = classC.r, g = classC.g, b = classC.b,
    }
end