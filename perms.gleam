import gleam/list
import gleam/string
import gleam/option.{unwrap_or}

pub type Permission {
  Permission(String)
}

/// Checks if a user has a permission.
/// 
/// `perms`: A list of user permissions.
/// `perm`: The permission to check.
/// 
/// Returns `True` if the user has the permission, otherwise `False`.
pub fn has_perm(perms: List(Permission), perm: Permission) -> Bool {
  let Permission(perm_str) = perm
  let perm_split = split_permission(perm_str)

  let perm_namespace = list.head(perm_split) |> unwrap_or("")
  let perm_name = list.tail(perm_split)
    |> list.join_with(".")
    |> unwrap_or("*")

  let mut has_perm = False
  let mut has_negator = False

  for perms {
    Permission(user_perm) -> {
      if user_perm == "global.*" {
        True
      } else {
        let user_perm_split = split_permission(user_perm)
        let user_perm_namespace = list.head(user_perm_split) |> unwrap_or("")
        let user_perm_name = list.tail(user_perm_split)
          |> list.join_with(".")
          |> unwrap_or("*")

        let user_perm_namespace =
          if string.starts_with(user_perm_namespace, "~") {
            string.drop(user_perm_namespace, 1)
          } else {
            user_perm_namespace
          }

        if user_perm_namespace == perm_namespace || user_perm_namespace == "global" {
          if user_perm_name == "*" || user_perm_name == perm_name {
            has_perm = True
            if string.starts_with(user_perm, "~") {
              has_negator = True
            }
          }
        }
      }
    }
  }

  has_perm && not has_negator
}

/// Builds a permission.
///
/// `namespace`: The permission's namespace.
/// `subnamespace`: The permission's sub-namespace (optional).
/// `perm`: The permission's name.
/// 
/// Returns the formatted permission string.
pub fn build(namespace: String, subnamespace: Option(String), perm: String) -> Permission {
  let formatted_perm = 
    case subnamespace {
      Some(sub) -> string.concat([namespace, "@", sub, ".", perm])
      None -> string.concat([namespace, ".", perm])
    }
  Permission(formatted_perm)
}

/// Helper function to split a permission string into components.
fn split_permission(perm: String) -> List(String) {
  perm
  |> string.replace("@", ".")
  |> string.split(".")
}
