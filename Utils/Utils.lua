local E = select(2, ...):unpack()

local function Serialize(tbl, indent, visited, lines)
    indent  = indent  or ""
    visited = visited or {}
    lines   = lines   or {}

    if type(tbl) ~= "table" then
        lines[#lines+1] = indent .. tostring(tbl)
        return lines
    end
    if visited[tbl] then
        lines[#lines+1] = indent .. "<cycle>"
        return lines
    end
    visited[tbl] = true

    lines[#lines+1] = indent .. "{"
    local nextI = indent .. "    "
    for k,v in pairs(tbl) do
        local key = "["..tostring(k).."] = "
        if type(v) == "table" then
            lines[#lines+1] = nextI .. key
            Serialize(v, nextI .. "    ", visited, lines)
        else
            lines[#lines+1] = nextI .. key .. tostring(v)
        end
    end
    lines[#lines+1] = indent .. "}"
    return lines
end

function E:Serialize(tbl)
    return Serialize(tbl)
end