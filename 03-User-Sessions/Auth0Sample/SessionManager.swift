// SessionManager.swift
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

import Foundation
import SimpleKeychain
import Auth0

enum SessionManagerError: Error {
    case noIdToken
    case noRefreshToken
}

class SessionManager {
    static let shared = SessionManager()
    let keychain = A0SimpleKeychain(service: "Auth0")
    var profile: Profile?

    private init () { }

    func storeTokens(_ idToken: String, refreshToken: String? = nil) {
        self.keychain.setString(idToken, forKey: "id_token")
        if let refreshToken = refreshToken {
            self.keychain.setString(refreshToken, forKey: "refresh_token")
        }
    }

    func retrieveProfile(_ callback: @escaping (Error?) -> ()) {
        guard let idToken = self.keychain.string(forKey: "id_token") else {
            return callback(SessionManagerError.noIdToken)
        }
        Auth0
            .authentication()
            .tokenInfo(token: idToken)
            .start { result in
                switch(result) {
                case .success(let profile):
                    self.profile = profile
                     self.refreshToken(callback)
                    callback(nil)
                case .failure(_):
                    self.refreshToken(callback)
                }
        }
    }

    func refreshToken(_ callback: @escaping (Error?) -> ()) {
        guard let refreshToken = self.keychain.string(forKey: "refresh_token") else {
            return callback(SessionManagerError.noRefreshToken)
        }
        Auth0
            .authentication()
            .delegation(withParameters: ["refresh_token": refreshToken])
            .start { result in
                switch(result) {
                case .success(let credentials):
                    guard let idToken = credentials["id_token"] as? String else { return }
                    self.storeTokens(idToken)
                    self.retrieveProfile(callback)
                case .failure(let error):
                    callback(error)
                    self.logout()
                }
        }
    }

    func logout() {
        self.keychain.clearAll()
    }
    
}
