//
//  EmailViewModel.swift
//  SocialSpark
//
//  Created by David Serrao on 9/28/24.
//

import Foundation
import Combine

// Model for Email
struct Email: Codable, Identifiable {
    var id = UUID()
    var email: String
}

// ViewModel for handling API calls
class EmailViewModel: ObservableObject {
    @Published var emails: [Email] = []
    
    // Function to fetch user info
    func getUserInfo(domain: String, accessToken: String) {
        guard let url = URL(string: "https://\(domain)/userinfo") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            if let data = data {
                DispatchQueue.main.async {
                    do {
                        let emailInfo = try JSONDecoder().decode([Email].self, from: data)
                        self.emails = emailInfo
                    } catch {
                        print("Failed to decode JSON: \(error.localizedDescription)")
                    }
                }
            }
        }
        task.resume()
    }
}

