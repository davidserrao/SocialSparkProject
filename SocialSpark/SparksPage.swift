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
        ZStack {
            // Background gradient
            let customPink = UIColor(red: 0xF0, green: 0xB4, blue: 0xFF).color
            let customPurple = UIColor(red: 0x6D, green: 0x78, blue: 0xED).color
            LinearGradient(
                gradient: Gradient(colors: [customPink, customPurple]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // HStack for logo and button in the same row
                HStack {
                    // Custom header image
                    Image("SparksTitle") // Corrected image name
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 80) // Adjust as needed
                        .padding(.leading, 20)

                    Spacer() // Pushes the button to the right

                    // "Regenerate Sparks" button
                    Button(action: {
                        Task {
                            await viewModel.fetchTasks()
                        }
                    }) {
                        Text("Regenerate Sparks").foregroundColor(Color.white)
                    }
                    .padding(.trailing, 20) // Padding from the right side
                }
                .padding(.top, 20) // Top padding for the HStack

                // Task list
                List {
                    ForEach(viewModel.tasks) { task in
                        ZStack {
                            // White background for each task
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(radius: 1)

                            // Task content
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

                                Spacer()
                            }
                            .padding(.vertical, 10)
                            .padding(.leading, 10) // Padding inside the white box
                        }
                        .padding(.vertical, 5) // Space between white boxes
                        .listRowBackground(Color.clear) // Ensure the row background is transparent
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

