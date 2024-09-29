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

import SwiftUI

struct SparksPage: View {
    @State private var tasks: [Task] = [
        Task(name: "Call James", isCompleted: false),
        Task(name: "Hit up David", isCompleted: false),
        Task(name: "Text Yash", isCompleted: false)
    ]

    var body: some View {
        ZStack { // ZStack to place the background color underneath the content
            let customPink = UIColor(red: 0xF0, green: 0xB4, blue: 0xFF).color
            let customPurple = UIColor(red: 0x6D, green: 0x78, blue: 0xED).color
            LinearGradient(
                gradient: Gradient(colors: [customPink, customPurple]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                // Custom header image
                Image("Sparks")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80) // Adjust as needed
                    .padding(.top, 20) // Optional top padding
                    .frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 20)
                
                // Task list
                List {
                    ForEach(tasks.indices, id: \.self) { index in
                        HStack {
                            Button(action: {
                                tasks[index].isCompleted.toggle()
                            }) {
                                Image(tasks[index].isCompleted ? "sparklesCheckBox" : "sparklesCheckBox")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .padding(.trailing, 10) // Add padding between the image and the text
                            }
                            Text(tasks[index].name).font(.system(size: 20, weight: .regular, design: .serif)).foregroundColor(Color.gray)
                                .strikethrough(tasks[index].isCompleted, color: .black)
                                .foregroundColor(tasks[index].isCompleted ? .gray : .black)
                        }

                    }
                }
                .listStyle(PlainListStyle())
            } //VStack ending
        }
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
