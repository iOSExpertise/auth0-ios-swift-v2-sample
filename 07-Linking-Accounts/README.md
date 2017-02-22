# Linking Accounts

- [Full Tutorial](https://auth0.com/docs/quickstart/native/ios-swift/07-linking-accounts)

This sample exposes how to manage accounts linking for an Auth0 user.

Besides the usual view controllers known from previous samples, it contains a new one: `UserIdentitiesViewController`, which contains a table view that displays every account the user has linked with his account, including the main account itself. That view controller provides functionality to edit them, so that you can link new accounts or delete linked accounts (that are not the main account).

It's important to stand out that this sample follows the conventions already defined in the [session handling sample](/03-Session-Handling) as for session management, in order to avoid user profile updating inconsistencies among view controllers.

#### Important Snippets

Note: All these snippets are located in the `UserIdentitiesViewController.swift` file.

##### 1. Retrieve all user's identities

User's identities (main account + linked accounts) can be found in the `identities` array from the `A0UserProfile` instance. However, in the sample project, the profile is refreshed from the server before displaying the identities, in order to stay updated:

```swift
fileprivate func updateIdentities() {
    let loadingAlert = UIAlertController.loadingAlert()
    loadingAlert.presentInViewController(self)
    SessionManager.shared.retrieveIdentity { error, identities in
        loadingAlert.dismiss() {
            guard error == nil else { return }
            self.identities = identities
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
}
```

##### 2. Link an account

First, the user is asked for the credentials of the account he wants to link. To accomplish that, the Lock widget is presented:

```swift
fileprivate func showLinkAccountDialog() {
    Lock
        .classic()
        .withOptions {
            $0.closable = true
        }
        .onAuth { credentials in
            guard let idToken = credentials.idToken else {
                self.showMissingProfileOrTokenAlert()
                return
            }
            self.linkAccountWithIDToken(idToken)
        }
        .present(from: self)
}
```

The obtained `idToken` from the login dialog is used later on in order to link the account:

```swift
fileprivate func linkAccountWithIDToken(_ otherUserToken: String) {
    let loadingAlert = UIAlertController.loadingAlert()
    loadingAlert.presentInViewController(self)
    guard let idToken = SessionManager.shared.idToken else { return }
    Auth0
        .users(token: idToken)
        .link(self.userId, withOtherUserToken: otherUserToken)
        .start { result in
            loadingAlert.dismiss() {
                switch result {
                case .success:
                    let successAlert = UIAlertController.alertWithTitle(nil, message: "Successfully linked account!")
                    successAlert.presentInViewController(self, dismissAfter: 1.0) { completion in
                        self.updateIdentities()
                    }
                case .failure(let error):
                    let failureAlert = UIAlertController.alertWithTitle("Error", message: error.localizedDescription, includeDoneButton: true)
                    failureAlert.presentInViewController(self)
                }
            }
    }
}
```

Notice that once the account is linked, the `updateIdentities()` function (described in snippet 1) gets called, in order to refresh the table with the latest data.

##### 3. Unlink an account

In this case, the whole `Identity` object is passed in to the function, for convenience, because it requires its `userId` as well as its `provider` value.

```swift
fileprivate func unlinkIdentity(_ identity: Identity) {
    let loadingAlert = UIAlertController.loadingAlert()
    loadingAlert.presentInViewController(self)
    guard let idToken = SessionManager.shared.idToken else { return }
    SessionManager.shared.retrieveProfile { error in
        guard error == nil else { return }
        Auth0
            .users(token: idToken)
            .unlink(identityId: identity.identifier, provider: identity.provider, fromUserId: self.userId)
            .start { result in
                loadingAlert.dismiss() {
                    switch result {
                    case .success:
                        let successAlert = UIAlertController.alertWithTitle(nil, message: "Account unlinked")
                        successAlert.presentInViewController(self, dismissAfter: 1.0) { completion in
                            self.updateIdentities()
                        }
                    case .failure(let error):
                        let failureAlert = UIAlertController.alertWithTitle("Error", message: error.localizedDescription, includeDoneButton: true)
                        failureAlert.presentInViewController(self)
                    }
                }
        }
    }
}
```
