# Custom Login

- [Full Tutorial](https://auth0.com/docs/quickstart/native/ios-swift/02-custom-login)

This sample project shows how to make up a login and a sign up dialog by your own, by connecting to Auth0 services through the [Auth0.swift](https://github.com/auth0/Auth0.swift) toolkit.

You'll find two important view controllers here: The `LoginViewController` and the `SignUpViewController`, which contain text fields and buttons which are linked to actions that are described below.

#### Important Snippets

##### 1. Perform a Login

In `LoginViewController.swift`:

```swift
fileprivate func performLogin() {
    self.view.endEditing(true)
    self.loading = true
    Auth0
        .authentication()
        .login(usernameOrEmail: self.emailTextField.text!, password: self.passwordTextField.text!, connection: "Username-Password-Authentication", scope: "openid profile")
        .start { result in
            DispatchQueue.main.async {
                self.loading = false
                switch result {
                case .success(let credentials):
                    self.loginWithCredentials(credentials)
                case .failure(let error):
                    self.showAlertForError(error)
                }
            }
    }
}
```

##### 2. Pass the credentials object

The `credentials` instance is used to retrieve the profile in the next screen, that is to say, in the `ProfileViewController`.

So, in `LoginViewController.swift`...

First, the segue is performed, saving the credentials to an instance variable:

```swift
fileprivate func loginWithCredentials(_ credentials: Credentials) {
    self.retrievedCredentials = credentials
    self.performSegue(withIdentifier: "ShowProfile", sender: nil)
}
```
Then, the retrieved credentials are passed to the `ProfileViewController`:

```swift
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let profileViewController = segue.destination as? ProfileViewController else {
        return
    }
    profileViewController.loginCredentials = self.retrievedCredentials!
}
```

##### 3. Retrieve the user profile with his credentials

In `ProfileViewController.swift`, once it's got the credentials:

```swift
fileprivate func retrieveProfile() {
    guard let accessToken = loginCredentials.accessToken else {
        print("Error retrieving profile")
        let _ = self.navigationController?.popViewController(animated: true)
        return
    }
    Auth0
        .authentication()
        .userInfo(token: accessToken)
        .start { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self.welcomeLabel.text = "Welcome, \(profile.name)"
                    let task = URLSession.shared.dataTask(with: profile.pictureURL) { (data, response, error) in
                        guard let data = data , error == nil else { return }
                        DispatchQueue.main.async {
                            self.avatarImageView.image = UIImage(data: data)
                        }
                    }
                    task.resume()
                    self.userMetadataTextView.text = profile.userMetadata.description
                case .failure(let error):
                    self.showAlertForError(error)
                }
            }
    }
}
```

##### 4. Perform a Sign Up

In `SignUpViewController.swift`:

```swift
fileprivate func performRegister() {
    self.view.endEditing(true)
    self.loading = true
    Auth0
        .authentication()
        .signUp(
            email: self.emailTextField.text!,
            password: self.passwordTextField.text!,
            connection: "Username-Password-Authentication",
            userMetadata: ["first_name": self.firstNameTextField.text!,
                "last_name": self.lastNameTextField.text!]
        )
        .start { result in
            DispatchQueue.main.async {
                self.loading = false
                switch result {
                case .success(let credentials):
                    self.retrievedCredentials = credentials
                    self.performSegue(withIdentifier: "DismissSignUp", sender: nil)
                case .failure(let error):
                    self.showAlertForError(error)
                }
            }
    }
}
```

Notice that the credentials are stored in the `retrievedCredentials` instance variable.

##### 5. Hook up Login and Sign Up navigation

Once someone has signed up, the `SignUpViewController` is dismissed, and the `LoginViewController` takes the control. Through an [unwind segue](https://www.youtube.com/watch?v=akmPXZ4hDuU), the `LoginViewController` automatically logs the user in with the credentials he's just got upon registering.

In `LoginViewController.swift`:

```swift
@IBAction func unwindToLogin(_ segue: UIStoryboardSegueWithCompletion) {
    guard let controller = segue.source as? SignUpViewController,
    let credentials = controller.retrievedCredentials
    else { return  }
    segue.completion = {
        self.loginWithCredentials(credentials)
    }
}
```

Notice how the `retrievedCredentials` mentioned in the step 4 are used here.

##### 6. Perform Social Authentication using webauth

In order to get credentials from a social provider, whether it's for sign in or sign up purposes, you present the user a webauth social authentication dialog by just using this snippet, which you can get from `LoginViewController.swift`:

```swift
fileprivate func performFacebookAuthentication() {
    self.view.endEditing(true)
    self.loading = true
    Auth0
        .webAuth()
        .connection("facebook")
        .scope("openid")
        .start { result in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                switch result {
                case .success(let credentials):
                    self.loginWithCredentials(credentials)
                case .failure(let error):
                    self.showAlertForError(error)
                }
            }
    }
}
```

Replace `"facebook"` with any social provider that you need (as long as it appears in [Auth0 identity providers](https://auth0.com/docs/identityproviders)).
