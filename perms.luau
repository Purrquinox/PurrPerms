-- Checks if a user has a permission
-- @param perms: Array of permissions
-- @param perm: The permission to check
-- @returns: Whether the user has the permission or not
local function hasPerm(perms, perm)
    -- Normalize the permission format
    local permSplit = string.split(string.gsub(perm, "@", "."), ".")
    if #permSplit < 2 then
        table.insert(permSplit, "*")
    end

    local permNamespace = permSplit[1]
    local permName = table.concat(permSplit, ".", 2)

    local hasPerm = nil
    local hasNegator = false

    for _, userPerm in ipairs(perms) do
        if userPerm == "global.*" then
            return true
        end

        -- Normalize user permissions
        local userPermSplit = string.split(string.gsub(userPerm, "@", "."), ".")
        if #userPermSplit < 2 then
            table.insert(userPermSplit, "*")
        end

        local userPermNamespace = userPermSplit[1]
        local userPermName = table.concat(userPermSplit, ".", 2)

        if string.sub(userPerm, 1, 1) == "~" then
            userPermNamespace = string.sub(userPermNamespace, 2)
        end

        if (userPermNamespace == permNamespace or userPermNamespace == "global") and
            (userPermName == "*" or userPermName == permName) then
            hasPerm = userPermSplit
            if string.sub(userPerm, 1, 1) == "~" then
                hasNegator = true
            end
        end
    end

    return hasPerm ~= nil and not hasNegator
end

-- Builds a permission
-- @param namespace: The permission's namespace
-- @param subnamespace: The permission's sub-namespace (optional)
-- @param perm: The permission's name
-- @returns: The built permission
local function build(namespace, subnamespace, perm)
    if subnamespace then
        return string.format("%s@%s.%s", namespace, subnamespace, perm)
    else
        return string.format("%s.%s", namespace, perm)
    end
end
