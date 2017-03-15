# Calling APIs

- [Full Tutorial](https://auth0.com/docs/quickstart/native/ios-swift/04-calling-apis)

The idea of this project is to perform authenticated requests by attaching the `accessToken`, obtained upon login, into an authorization header.

This sample can be seen as a template where you'll have to set your own stuff in order to get it working. Pay attention to the snippets where you have to do that.

Also, you will need a server that accepts authenticated APIs with an endpoint capable of checking whether or not a request has been properly authenticated. You can use your own or [this nodeJS one](https://github.com/auth0-samples/auth0-angularjs2-systemjs-sample/tree/master/Server), whose setup is quite simple.

#### Important Snippets

##### 1. Call your API

The only important snippet you need to be aware of: making up an authenticated request for your API!

Look at `ProfileViewController.swift`:

```swift
private func callAPI(authenticated shouldAuthenticate: Bool) {
    let url = URL(string: "your api url")!
    var request = URLRequest(url: url)
    // Configure your request here (method, body, etc)
    if shouldAuthenticate {
        guard let token = A0SimpleKeychain(service: "Auth0").string(forKey: "access_token") else {
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
        DispatchQueue.main.async {
            let title = "Results"
            let message = "Error: \(error?.localizedDescription)\n\nData: \(data == nil ? "nil" : "(there is data)")\n\nResponse: \(response?.description)"
            let alert = UIAlertController.alertWithTitle(title, message: message, includeDoneButton: true)
            self.present(alert, animated: true, completion: nil)

        }
    })
    task.resume()
}
```

These are the specific lines of code that you have to configure:

First, set your API url here:

```swift
let url = URL(string: "your api url")!
```

Then, add any extra configuration that your API might require for your requests:

```swift
// Configure your request here (method, body, etc)
```

Then, pay attention to how the header is made up:

```swift
request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
```

That string interpolation might vary depending on the standards that your API follows. The one showed in the sample corresponds to OAuth2 standards.

Also, this line is important:

```swift
guard let token = A0SimpleKeychain(service: "Auth0").string(forKey: "access_token") else { return }
```

That specifies that the `access_token` is the token that you're using for authentication. You might want to choose using a different one (for example, the `idToken`), it depends on how your API checks the authentication against Auth0.

> For further information on the authentication process, check out [the full documentation](https://auth0.com/docs/api/authentication).
