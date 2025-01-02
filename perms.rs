use std::collections::HashSet;

/// Checks if a user has a permission.
/// 
/// # Arguments
/// * `perms` - A set of permissions the user has.
/// * `perm` - The permission to check.
/// 
/// # Returns
/// * `bool` - Whether the user has the permission or not.
pub fn has_perm(perms: &HashSet<String>, perm: &str) -> bool {
    let mut perm_split: Vec<&str> = perm.replace("@", ".").split('.').collect();
    if perm_split.len() < 2 {
        perm_split.push("*");
    }

    let perm_namespace = perm_split[0];
    let perm_name = perm_split[1..].join(".");

    let mut has_perm = false;
    let mut has_negator = false;

    for user_perm in perms {
        if user_perm == "global.*" {
            return true;
        }

        let mut user_perm_split: Vec<&str> = user_perm.replace("@", ".").split('.').collect();
        if user_perm_split.len() < 2 {
            user_perm_split.push("*");
        }

        let mut user_perm_namespace = user_perm_split[0];
        let user_perm_name = user_perm_split[1..].join(".");

        if user_perm.starts_with('~') {
            user_perm_namespace = &user_perm_namespace[1..];
        }

        if (user_perm_namespace == perm_namespace || user_perm_namespace == "global")
            && (user_perm_name == "*" || user_perm_name == perm_name)
        {
            has_perm = true;
            if user_perm.starts_with('~') {
                has_negator = true;
            }
        }
    }

    has_perm && !has_negator
}

/// Builds a permission.
///
/// # Arguments
/// * `namespace` - The permission's namespace.
/// * `subnamespace` - The permission's sub-namespace (optional).
/// * `perm` - The permission's name.
///
/// # Returns
/// * `String` - The built permission.
pub fn build(namespace: &str, subnamespace: Option<&str>, perm: &str) -> String {
    match subnamespace {
        Some(sub) => format!("{}@{}.{}", namespace, sub, perm),
        None => format!("{}.{}", namespace, perm),
    }
}
