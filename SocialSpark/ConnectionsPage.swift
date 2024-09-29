//
//  ConnectionsPage.swift
//  SocialSpark
//
//  Created by David Serrao on 9/28/24.
//

import SwiftUI
import Contacts

// Model for the contact
struct Contact: Codable, Identifiable {
    var id: Int?
    var fname: String
    var lname: String
    var pnumber: Int
    var email: String?
    var curCloseness: Int
    var desiredCloseness: Int
    var minIFCount: Int
    var minIFTime: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "contactid"
        case fname
        case lname
        case pnumber
        case email
        case curCloseness
        case desiredCloseness
        case minIFCount
        case minIFTime
    }
}

struct ConnectionsPage: View {
    @StateObject private var viewModel = ConnectionsViewModel()
    @State private var selectedContact: Contact? = nil
    @State private var isShowingContactInfo = false
    @State private var isShowingAddContact = false

    var body: some View {
        NavigationView {
            VStack {
                // Header image, left-aligned
                Image("ConnectionsHeader")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 60) // Adjust height for header
                    .frame(maxWidth: .infinity, alignment: .leading) // Left-align the header
                    .padding(.leading, 15) // Add padding from the left
                    .padding(.top, 20) // Optional top padding for spacing

                // HStack for the buttons, positioned below the header
                HStack {
                    Button(action: {
                        viewModel.importContacts()
                    }) {
                        Text("IMPORT CONTACTS")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 15) // Align the "Import Contacts" to the left

                    Spacer() // Push the "+" button to the right

                    Button(action: {
                        isShowingAddContact = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 15) // Align "+" button to the right
                }
                .padding(.top, -10) // Add space between the header and the button row
                .padding(.leading, 5)

                Spacer() // Push content down to give space for header/buttons

                // The list of contacts
                List(viewModel.contacts) { contact in
                    Button(action: {
                        selectedContact = contact
                        isShowingContactInfo = true
                    }) {
                        HStack {
                            Text(contact.fname)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        UIColor(red: 0x6D, green: 0x78, blue: 0xED).color,
                        UIColor(red: 0xF0, green: 0xB4, blue: 0xFF).color
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            )
            .sheet(item: $selectedContact) { contact in
                ContactInfoView(contact: contact)
            }
            .sheet(isPresented: $isShowingAddContact) {
                AddEditContactView(viewModel: viewModel, isShowing: $isShowingAddContact)
            }
            .task {
                await viewModel.fetchContacts()
            }
        }
    }
}




// View for adding or editing a contact
struct AddEditContactView: View {
    @ObservedObject var viewModel: ConnectionsViewModel
    @Binding var isShowing: Bool
    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var currentRelationship: String = "Undefined"
    @State private var desiredRelationship: String = "Undefined"
    @State private var description: String = ""

    let relationshipOptions = ["Undefined", "Stranger", "Acquaintances", "Friends", "Close Friends", "Best Friends"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact Information")) {
                    TextField("Name", text: $name)
                    TextField("Phone Number", text: $phoneNumber).keyboardType(.numberPad)
                    TextField("Email", text: $email)
                }

                Section(header: Text("Relationships")) {
                    Picker("Current Relationship", selection: $currentRelationship) {
                        ForEach(relationshipOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    Picker("Desired Relationship", selection: $desiredRelationship) {
                        ForEach(relationshipOptions, id: \.self) {
                            Text($0)
                        }
                    }
                }

                Section(header: Text("Description")) {
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1))
                }

                Section {
                    Button("Save Contact") {
                        saveContact()
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Add/Edit Contact")
            .navigationBarItems(leading: Button("Cancel") {
                isShowing = false
            })
        }
    }

    private func saveContact() {
        let newContact = Contact(
            fname: name,
            lname: name,
            pnumber: Int(phoneNumber) ?? 0,
            email: email,
            curCloseness: Int(currentRelationship) ?? -1,
            desiredCloseness: Int(desiredRelationship) ?? -1,
            minIFCount: -1,
            minIFTime: -1
        )
        viewModel.addContact(newContact)
        isShowing = false
    }
}

// View for showing contact info
struct ContactInfoView: View {
    var contact: Contact
    @State private var currentRelationshipIndex: Int = 0
    @State private var desiredRelationshipIndex: Int = 0

    let relationshipOptions = ["Undefined", "Stranger", "Acquaintances", "Friends", "Close Friends", "Best Friends"]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("\(contact.fname)")
                .font(.largeTitle)

            Text("Phone Number: \(contact.pnumber)")

            Text("Email: \(contact.email)")

            HStack {
                Text("Current Relationship:")
                Spacer()
                Picker("Current Relationship", selection: $currentRelationshipIndex) {
                    ForEach(0..<relationshipOptions.count, id: \.self) { index in
                        Text(relationshipOptions[index]).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            HStack {
                Text("Desired Relationship:")
                Spacer()
                Picker("Desired Relationship", selection: $desiredRelationshipIndex) {
                    ForEach(0..<relationshipOptions.count, id: \.self) { index in
                        Text(relationshipOptions[index]).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            Text("Last Contacted: \(formattedDate(Date()))")
                .font(.title3)

            Text("Previous Contacts:")
                .font(.headline)
                .padding(.top)

            Text("Description:")
                .font(.headline)
                .padding(.top)

            Text("This is where content description should go")
                .padding(.leading)

            Spacer()

            Button(action: {
                // action for closing
            }) {
                Text("Edit")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .onAppear {
            currentRelationshipIndex = contact.curCloseness
            desiredRelationshipIndex = contact.desiredCloseness
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}



// Preview provider
struct ConnectionsPage_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionsPage()
    }
}
