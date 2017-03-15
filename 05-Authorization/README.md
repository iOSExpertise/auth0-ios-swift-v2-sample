# Authorization

The guts of this topic is actually found in the [full tutorial](https://auth0.com/docs/quickstart/native/ios-swift/05-authorization), where it's exposed how to configure a rule from the Auth0 management website.

However, this sample project does contain a snippet that might be of your interest.

#### Important Snippets

#### 1. Check the user role

Look at `ProfileViewController.swift`:

```swift
@IBAction func checkUserRole(sender: UIButton) {
    SessionManager.shared.retrieveRoles { error, role in
        DispatchQueue.main.async {
            guard error == nil else { return self.showErrorRetrievingRolesAlert() }
            if role == "admin" {
                self.showAdminPanel()
            } else {
                self.showAccessDeniedAlert()
            }
        }
    }
}
```

##### 2. Retrieve the users metadata

Look at the `retrieveRoles` method in `SessionManager`

```swift
func retrieveRoles(_ callback: @escaping (Error?, String?) -> ()) {
    guard let idToken = self.keychain.string(forKey: "id_token") else {
        return callback(SessionManagerError.noIdToken, nil)
    }
    guard let userId = profile?.id else {
        return callback(SessionManagerError.noProfile, nil)
    }
    Auth0
        .users(token: idToken)
        .get(userId, fields: [], include: true)
        .start { result in
            switch result {
            case .success(let user):
            guard
                let appMetadata = user["app_metadata"] as? [String: Any],
                let roles = appMetadata["roles"] as? [String]
                else {
                    return callback(SessionManagerError.missingRoles, nil)
                }
                callback(nil, roles.first)
                break
            case .failure(let error):
                callback(error, nil)
                break
            }
    }
}
```
