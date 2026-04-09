local loaded_versions = {}
local available_versions = nil
local latest_version = nil
local LIB_NAME = "ExampleLib"

-- detect if we're in assembled mode (versions/ folder exists)
local function is_assembled()
    local ok, index = pcall(require, "versions/index")
    if ok then
        available_versions = index.versions
        latest_version = index.latest
        return true
    end
    return false
end

local assembled = is_assembled()

_G[LIB_NAME] = function(caller, ver)
    if not caller or type(caller) ~= "string" then
        core.log_error("[" .. LIB_NAME .. "] caller name is required as first argument")
        return nil
    end

    local prefix = "[" .. caller .. " > " .. LIB_NAME .. "] "

    -- dev mode: no versions/ folder, load directly from src/
    if not assembled then
        if not loaded_versions["dev"] then
            local lib = require("src/init")
            lib._version = "dev"
            loaded_versions["dev"] = lib
        end
        return loaded_versions["dev"]:new(caller)
    end

    -- assembled mode: resolve version
    local explicit = ver ~= nil
    ver = ver or latest_version

    if not explicit then
        core.log_warning(prefix .. "No version specified, using latest: " .. latest_version)
    end

    if not ver or not available_versions[ver] then
        core.log_error(prefix .. "Version " .. tostring(ver) .. " not found")
        return nil
    end

    -- lazy load and cache
    if not loaded_versions[ver] then
        local lib = require("versions/" .. ver .. "/init")
        lib._version = ver
        loaded_versions[ver] = lib
    end

    return loaded_versions[ver]:new(caller)
end
