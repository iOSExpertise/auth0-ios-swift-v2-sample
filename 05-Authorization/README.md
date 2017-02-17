# Authorization

The guts of this topic is actually found in the [full tutorial](https://auth0.com/docs/quickstart/native/ios-swift/05-authorization), where it's exposed how to configure a rule from the Auth0 management website.

However, this sample project does contain a snippet that might be of your interest.

#### Important Snippets

##### 1. Check the user role

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
