//
//  SparksPage.swift
//  SocialSpark
//
//  Created by David Serrao on 9/28/24.
//

import SwiftUI

// Model for the task
struct SparkTask: Identifiable, Codable {
    var id: String
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
                                viewModel.complete_task(task: task)
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
            .navigationBarItems(trailing: Button(action: {
                Task {
                    await viewModel.fetchTasks()
                }
            }) {
                Text("Regenerate Sparks").foregroundColor(Color.blue)
            })
            .task {
                await viewModel.fetchTasks()
            }
        }
    }
}

#Preview {
    SparksPage()
}

