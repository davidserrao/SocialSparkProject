//
//  SparksViewModel 2.swift
//  SocialSpark
//
//  Created by Bryce Hanna on 9/28/24.
//


//
//  SparksViewModel.swift
//  SocialSpark
//
//  Created by David Serrao on 9/28/24.
//

import Foundation
import Combine


class SparksViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    
    func fetchTopN() async throws -> [Int] {
        guard let url = URL(string: "http://127.0.0.1:8000/api/get/get-top-n/1/2") else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Uncomment and set your Bearer token if needed
        // request.setValue("Bearer YOUR_ACCESS_TOKEN", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        // Check for a valid HTTP response
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "Invalid response", code: 0, userInfo: nil)
        }

        // Decode the response data into an array of Int
        let ids = try JSONDecoder().decode([Int].self, from: data)
        return ids
    }
    
    func fetchTasks() async {
        guard let contactIds = try? await fetchTopN() else {
            print("Failed to fetch contact IDs")
            return  // Return nil on error
        }
        
        var tasks: [Task] = []
        
        for id in contactIds {
            // Attempt to fetch each task, adding it to the array if successful
            if let task = try? await fetchTask(contactId: id) {
                tasks.append(Task(id: UUID(), name: task, isCompleted: false))
            } else {
                print("Failed to fetch task for contact ID: \(id)")
            }
        }
        
        self.tasks = tasks
    }
    
    func fetchTask(contactId: Int) async throws -> String {
        guard let url = URL(string: "http://127.0.0.1:8000/api/get/daily_suggestion/1/\(contactId)") else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Uncomment and set your Bearer token if needed
        // request.setValue("Bearer YOUR_ACCESS_TOKEN", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        // Check for a valid HTTP response
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "Invalid response", code: 0, userInfo: nil)
        }

        // Decode the response data into a String
        let task = try JSONDecoder().decode(String.self, from: data)
        return task
    }
}
