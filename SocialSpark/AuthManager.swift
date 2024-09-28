//
//  AuthManager.swift
//  SocialSpark
//
//  Created by David Serrao on 9/28/24.
//

import Auth0
import Foundation

class AuthManager {
    
    func login(completion: @escaping (Bool, String?) -> Void) {
        Auth0
            .webAuth()
            .start { result in
                switch result {
                case .failure(let error):
                    print("Failure: \(error)")
                    completion(false, nil)
                    
                case .success(let credentials):
                    print("Credentials: \(credentials)")
                    completion(true, credentials.accessToken)
                }
            }
    }
    
    func logout(completion: @escaping (Bool) -> Void) {
        Auth0
            .webAuth()
            .clearSession { result in
                switch result {
                case .failure(let error):
                    print("Failure: \(error)")
                    completion(false)
                    
                case .success:
                    completion(true)
                }
            }
    }
}

