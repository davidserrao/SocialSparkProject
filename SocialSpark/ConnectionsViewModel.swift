//
//  ConnectionsViewModel.swift
//  SocialSpark
//
//  Created by David Serrao on 9/28/24.
//

import Foundation
import Combine

// ViewModel to handle API calls and store contacts
class ConnectionsViewModel: ObservableObject {
    @Published var contacts: [Contact] = []

    // Function to fetch contacts from an API
    func fetchContacts() {
        guard let url = URL(string: "https://yourapi.com/contacts") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer YOUR_ACCESS_TOKEN", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching contacts: \(error.localizedDescription)")
                return
            }

            if let data = data {
                do {
                    let decodedContacts = try JSONDecoder().decode([Contact].self, from: data)
                    DispatchQueue.main.async {
                        self.contacts = decodedContacts
                    }
                } catch {
                    print("Failed to decode contacts: \(error)")
                }
            }
        }
        task.resume()
    }
}

