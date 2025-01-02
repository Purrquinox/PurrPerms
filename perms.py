def has_perm(perms: list[str], perm: str) -> bool:
    """
    Checks if a user has a permission.
    :param perms: A list of permissions.
    :param perm: The permission to check.
    :return: Whether the user has the permission or not.
    """
    # Normalize the permission format by replacing @ with .
    perm_split = perm.replace("@", ".").split(".")
    if len(perm_split) < 2:
        perm_split = [perm, "*"]

    perm_namespace = perm_split[0]
    perm_name = ".".join(perm_split[1:])

    has_perm = None
    has_negator = False

    for user_perm in perms:
        if user_perm == "global.*":
            return True

        # Normalize user permissions
        user_perm_split = user_perm.replace("@", ".").split(".")
        if len(user_perm_split) < 2:
            user_perm_split = [user_perm, "*"]

        user_perm_namespace = user_perm_split[0]
        user_perm_name = ".".join(user_perm_split[1:])

        if user_perm.startswith("~"):
            user_perm_namespace = user_perm_namespace[1:]

        if (
            (user_perm_namespace == perm_namespace or user_perm_namespace == "global")
            and (user_perm_name == "*" or user_perm_name == perm_name)
        ):
            has_perm = user_perm_split
            if user_perm.startswith("~"):
                has_negator = True

    return has_perm is not None and not has_negator


def build(namespace: str, subnamespace: str | None, perm: str) -> str:
    """
    Builds a permission.
    :param namespace: The permission's namespace.
    :param subnamespace: The permission's sub-namespace (optional).
    :param perm: The permission's name.
    :return: The built permission.
    """
    if subnamespace:
        return f"{namespace}@{subnamespace}.{perm}"
    return f"{namespace}.{perm}"
