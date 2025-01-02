package main

import (
	"strings"
	"fmt"
)

// Checks if a user has a permission
// perms: A slice of user permissions
// perm: The permission to check
// Returns: Whether the user has the permission or not
func hasPerm(perms []string, perm string) bool {
	// Normalize the permission format
	permSplit := splitPermission(perm)

	permNamespace := permSplit[0]
	permName := strings.Join(permSplit[1:], ".")

	var hasPerm bool
	var hasNegator bool

	for _, userPerm := range perms {
		if userPerm == "global.*" {
			return true
		}

		// Normalize user permissions
		userPermSplit := splitPermission(userPerm)
		userPermNamespace := userPermSplit[0]
		userPermName := strings.Join(userPermSplit[1:], ".")

		if strings.HasPrefix(userPermNamespace, "~") {
			userPermNamespace = userPermNamespace[1:]
		}

		if (userPermNamespace == permNamespace || userPermNamespace == "global") &&
			(userPermName == "*" || userPermName == permName) {
			hasPerm = true
			if strings.HasPrefix(userPerm, "~") {
				hasNegator = true
			}
		}
	}

	return hasPerm && !hasNegator
}

// Builds a permission
// namespace: The permission's namespace
// subnamespace: The permission's sub-namespace (optional)
// perm: The permission's name
// Returns: The built permission
func build(namespace, subnamespace, perm string) string {
	if subnamespace != "" {
		return fmt.Sprintf("%s@%s.%s", namespace, subnamespace, perm)
	}
	return fmt.Sprintf("%s.%s", namespace, perm)
}

// Helper function to split a permission string into components
func splitPermission(perm string) []string {
	// Replace "@" with "." and split the string
	perm = strings.ReplaceAll(perm, "@", ".")
	return strings.Split(perm, ".")
}
