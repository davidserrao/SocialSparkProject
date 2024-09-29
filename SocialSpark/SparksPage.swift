//
//  SparksPage.swift
//  SocialSpark
//
//  Created by David Serrao on 9/28/24.
//

import SwiftUI

// Model for the task
struct Task: Identifiable, Codable {
    var id = UUID()
    var name: String
    var isCompleted: Bool
}

struct SparksPage: View {
    // Using the view model to manage tasks
    @StateObject private var viewModel = SparksViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.tasks) { task in
                    HStack {
                        // Checkbox (Toggle)
                        Button(action: {
                            if let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                                viewModel.tasks[index].isCompleted.toggle()
                            }
                        }) {
                            Image(systemName: task.isCompleted ? "checkmark.square" : "square")
                        }
                        
                        // Task name text
                        Text(task.name)
                            .strikethrough(task.isCompleted, color: .black)
                            .foregroundColor(task.isCompleted ? .gray : .black)
                    }
                }
            }
            .navigationTitle("Sparks")
            .task {
                await viewModel.fetchTasks()
            }
        }
    }
}

#Preview {
    SparksPage()
}

