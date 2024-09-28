//
//  SparksPage.swift
//  SocialSpark
//
//  Created by David Serrao on 9/28/24.
//

import SwiftUI

// Model for the task
struct Task: Identifiable {
    let id = UUID()
    var name: String
    var isCompleted: Bool
}

struct SparksPage: View {
    // State to hold the list of tasks
    @State private var tasks: [Task] = [
        Task(name: "Call James", isCompleted: false),
        Task(name: "Hit up David", isCompleted: false),
        Task(name: "Text Yash", isCompleted: false)
    ]

    var body: some View {
        NavigationView{
            List {
                ForEach(tasks) { task in
                    HStack {
                        // Checkbox (Toggle)
                        Button(action: {
                            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                                tasks[index].isCompleted.toggle()
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
        }
    }
}
#Preview {
    SparksPage()
}
