# Login

- [Full Tutorial](https://auth0.com/docs/quickstart/native/ios-swift/08-customizing-lock)

This sample project shows how to customize the login widget.

#### Important Snippets

##### Present the login widget

In `HomeViewController.swift`:

```swift
@IBAction func showLoginController(_ sender: UIButton) {
    Lock
        .classic()
        .withOptions {
            $0.oidcConformant = true
        }
        .withStyle {
            $0.title = "Phantom Inc."
            $0.headerBlur = .extraLight
            $0.logo = LazyImage(name: "icn_phantom")
            $0.primaryColor = UIColor ( red: 0.6784, green: 0.5412, blue: 0.7333, alpha: 1.0 )
        }
        .onAuth { credentials in
            self.showMissingProfileAlert(credentials.accessToken!)
        }
        .present(from: self)
}
```
