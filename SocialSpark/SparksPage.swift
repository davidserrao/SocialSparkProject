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


import SwiftUI

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
                .listStyle(PlainListStyle()) // Optional: List style adjustment
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
                        }}
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
    
    var color: Color {
        Color(self)
    }
}

#Preview {
    SparksPage()
}

