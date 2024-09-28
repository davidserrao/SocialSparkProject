//
//  ConnectionsPage.swift
//  SocialSpark
//
//  Created by David Serrao on 9/28/24.
//

import SwiftUI

// Model for the contact
struct Contact: Codable, Identifiable {
    var id = UUID()
    var name: String
    var phoneNumber: String
    var email: String
    var currentRelationship: String
    var desiredRelationship: String
    var lastContacted: Date
    var previousContacts: [Date]
    var description: String
}


struct ConnectionsPage: View {
    @StateObject private var viewModel = ConnectionsViewModel()
    @State private var selectedContact: Contact? = nil
    @State private var isShowingContactInfo = false
    @State private var isShowingAddContact = false // New state for showing the add/edit popup

    var body: some View {
        NavigationView {
            List(viewModel.contacts) { contact in
                Button(action: {
                    selectedContact = contact
                    isShowingContactInfo = true
                }) {
                    HStack {
                        Text(contact.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Connections")
            .navigationBarItems(trailing: Button(action: {
                isShowingAddContact = true
            }) {
                Image(systemName: "plus")
                    .font(.title2)
            })
            .sheet(item: $selectedContact) { contact in
                // Pass the selected contact to the sheet
                ContactInfoView(contact: contact)
            }
            .sheet(isPresented: $isShowingAddContact) {
                AddEditContactView(viewModel: viewModel, isShowing: $isShowingAddContact)
            }
            .onAppear {
                // Fetch contacts when the view appears
                viewModel.fetchContacts()
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
                    TextField("Phone Number", text: $phoneNumber)
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
                
                // Add description input
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
            name: name,
            phoneNumber: phoneNumber,
            email: email,
            currentRelationship: currentRelationship,
            desiredRelationship: desiredRelationship,
            lastContacted: Date(),
            previousContacts: [],
            description: description
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

    // Options for relationships
    let relationshipOptions = ["Undefined","Stranger", "Acquaintances", "Friends", "Close Friends", "Best Friends"]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("\(contact.name)")
                .font(.largeTitle)
            
            // Phone #
            Text("Phone Number: \(contact.phoneNumber)")
            
            // Phone #
            Text("Email: \(contact.email)")
            
            // Current Relationship Dropdown
            HStack() {
                Text("Current Relationship:")
                Spacer()
                Picker("Current Relationship", selection: $currentRelationshipIndex) {
                    ForEach(0..<relationshipOptions.count, id: \.self) { index in
                        Text(relationshipOptions[index]).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }


            // Desired Relationship Dropdown
            HStack() {
                Text("Desired Relationship:")
                Spacer()
                Picker("Desired Relationship", selection: $desiredRelationshipIndex) {
                    ForEach(0..<relationshipOptions.count, id: \.self) { index in
                        Text(relationshipOptions[index]).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            // Last Contacted Date
            Text("Last Contacted: \(formattedDate(contact.lastContacted))")
                .font(.title3)

            // List of Previous Contacts
            Text("Previous Contacts:")
                .font(.headline)
                .padding(.top)

            ForEach(contact.previousContacts, id: \.self) { date in
                Text(formattedDate(date))
                    .padding(.leading)
            }
            
            // Add description display
            Text("Description:")
                .font(.headline)
                .padding(.top)
            
            Text(contact.description)
                .padding(.leading)

            Spacer()

            // Close Button
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
            // Initialize the picker indexes when the view appears
            currentRelationshipIndex = relationshipOptions.firstIndex(of: contact.currentRelationship) ?? 0
            desiredRelationshipIndex = relationshipOptions.firstIndex(of: contact.desiredRelationship) ?? 0
        }
    }

    // Helper function to format date
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
