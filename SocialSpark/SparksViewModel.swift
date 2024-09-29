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
    private var cancellables = Set<AnyCancellable>()
    
    // Function to fetch tasks from an API
    func fetchTasks() {
        guard let url = URL(string: "https://yourapi.com/tasks") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer YOUR_ACCESS_TOKEN", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: [Task].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching tasks: \(error.localizedDescription)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] tasks in
                self?.tasks = tasks
            })
            .store(in: &cancellables)
    }
}

