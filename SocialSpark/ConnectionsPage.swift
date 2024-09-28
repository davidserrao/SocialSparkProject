//
//  ConnectionsPage.swift
//  SocialSpark
//
//  Created by David Serrao on 9/28/24.
//

import SwiftUI

// Model for the contact
struct Contact: Identifiable {
    let id = UUID()
    var name: String
    var phoneNumber: String
    var email: String
    var currentRelationship: String
    var desiredRelationship: String
    var lastContacted: Date
    var previousContacts: [Date]
}

struct ConnectionsPage: View {
    // List of contacts with additional properties
    @State private var contacts: [Contact] = [
        Contact(
            name: "John Doe",
            phoneNumber: "555-1234",
            email: "john@example.com",
            currentRelationship: "Friends",
            desiredRelationship: "Close Friends",
            lastContacted: Date(),
            previousContacts: [Date(), Date().addingTimeInterval(-86400)] // Two previous contact dates
        ),
        Contact(
            name: "Jane Smith",
            phoneNumber: "555-5678",
            email: "jane@example.com",
            currentRelationship: "Acquaintances",
            desiredRelationship: "Friends",
            lastContacted: Date().addingTimeInterval(-172800), // Two days ago
            previousContacts: [Date().addingTimeInterval(-604800)] // One week ago
        ),
        Contact(
            name: "Michael Johnson",
            phoneNumber: "555-9876",
            email: "michael@example.com",
            currentRelationship: "Stranger",
            desiredRelationship: "Friends",
            lastContacted: Date().addingTimeInterval(-259200), // Three days ago
            previousContacts: []
        )
    ]
    
    @State private var selectedContact: Contact? = nil
    @State private var isShowingContactInfo = false

    var body: some View {
        NavigationView {
            List(contacts) { contact in
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
            .sheet(item: $selectedContact) { contact in
                // Pass the selected contact to the sheet
                ContactInfoView(contact: contact)
            }
        }
    }
}

// View for displaying contact information in a modal
struct ContactInfoView: View {
    var contact: Contact
    @State private var currentRelationshipIndex: Int = 0
    @State private var desiredRelationshipIndex: Int = 0

    // Options for relationships
    let relationshipOptions = ["Stranger", "Acquaintances", "Friends", "Close Friends", "Best Friends"]

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

            Spacer()

            // Close Button
            Button(action: {
                
            }) {
                Text("Close")
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
