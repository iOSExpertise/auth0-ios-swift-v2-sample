// HomeViewController.swift
// Auth0Sample
//
// Copyright (c) 2016 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Lock
import Auth0

class HomeViewController: UIViewController {

    // MARK: - IBAction

    @IBAction func showLoginController(_ sender: UIButton) {
        Lock
            .classic()
            .withOptions {
                $0.oidcConformant = true
                $0.scope = "openid profile"
            }
            .onAuth { credentials in
                guard let accessToken = credentials.accessToken else { return }
                SessionManager.shared.storeToken(accessToken)
                SessionManager.shared.retrieveProfile { error in
                    DispatchQueue.main.async {
                        guard error == nil else {
                            self.showMissingProfileAlert()
                            return
                        }

                        self.performSegue(withIdentifier: "ShowProfile", sender: nil)
                    }
                }

            }
            .onError { error in
                print(error)
            }
            .present(from: self)
    }

    // MARK: - Private

    fileprivate var retrievedProfile: Profile!

    fileprivate func showMissingProfileAlert() {
        let alert = UIAlertController(title: "Error", message: "Could not retrieve profile", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
