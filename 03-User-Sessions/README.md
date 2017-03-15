# Session Handling

- [Full Tutorial](https://auth0.com/docs/quickstart/native/ios-swift/03-user-sessions)

The idea of this sample is showing how to achieve session handling in your application, meaning, how to keep the user logged in despite relaunching the app, how to keep his profile up to date, and how to clean everything up when he performs logout.

There are many approaches that can be used to achieve session handling, with their pros and cons. This sample project uses a `SessionManager` class to keep the view controllers lightweight. That class, however, should not be interpreted as a singleton, because it isn't. State is kept with the aid of the `SingleKeychain` library, which is, in a way, something similar to the well-known `NSUserDefaults`.

#### Important Snippets

##### 1. Check if a session already exists

Upon app's launch, you'd want to check if a user has already logged in, in order to take him straight to the app's content and prevent him from having to enter his credentials again.

So, in `HomeViewController.swift`:

```swift
fileprivate func checkAccessToken() {
    let loadingAlert = UIAlertController.loadingAlert()
    loadingAlert.presentInViewController(self)
    SessionManager.shared.retrieveProfile { error in
        loadingAlert.dismiss(animated: true) {
            guard error == nil else {
                return self.showLock()
            }
            self.performSegue(withIdentifier: "ShowProfileNonAnimated", sender: nil)
        }
    }
}
```

That's how you ask for the session from the view controller point of view. Pretty neat, huh? Ok, here's where the magic really happens, in `SessionManager.swift`.

##### 2. Obtaining the user profile

In this sample, the profile is retrieved from the `SessionManager` which fetches the latest profile and stores it. If you check out `ProfileViewController.swift`, you'll find:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    profile = SessionManager.shared.profile
    self.welcomeLabel.text = "Welcome, \(self.profile.name)"
    let task = URLSession.shared.dataTask(with: self.profile.pictureURL) { (data, response, error) in
        guard let data = data , error == nil else { return }
        DispatchQueue.main.async {
            self.avatarImageView.image = UIImage(data: data)
        }
    }
    task.resume()
}
```

Pay special attention to this line:

```swift
self.profile = SessionManager.shared.profile
```

`SessionManager` retrives the profile by making a call to `userInfo`.

```swift
func retrieveProfile(_ callback: @escaping (Error?) -> ()) {
    guard let accessToken = self.keychain.string(forKey: "access_token") else {
        return callback(SessionManagerError.noIdToken)
    }
    Auth0
        .authentication()
        .userInfo(token: accessToken)
        .start { result in
            switch(result) {
            case .success(let profile):
                self.profile = profile
                callback(nil)
            case .failure(_):
                self.refreshToken(callback)
            }
    }
}
```

In this case, the `retrieveSession` function uses, the current `accessToken` to fetch the latest profile. If the `accessToken` has expired, the function retrieves a new one by using the `refreshToken`. The only scenarios in which you wouldn't get a `profile` instance there is, either connection issues, server errors, or that the `refreshToken` got revoked, so, you'll have to deal with those in your project.

##### 3. Log out

In `ProfileViewController.swift`:

```swift
@IBAction func logout(_ sender: UIBarButtonItem) {
   SessionManager.shared.logout()
   self.presentingViewController?.dismiss(animated: true, completion: nil)
}
```

In `SessionManager.swift`:

```swift
func logout() {
    self.keychain.clearAll()
}
```

where `self.keychain` is always equal to `A0SimpleKeychain(service: "Auth0")`.
