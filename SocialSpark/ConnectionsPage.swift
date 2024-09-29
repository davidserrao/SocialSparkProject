//
//  ConnectionsPage.swift
//  SocialSpark
//
//  Created by David Serrao on 9/28/24.
//

import SwiftUI
import ContactsUI
import Combine

// Model for the contact
struct ServerContact: Codable, Identifiable {
    var id: Int?
    var fname: String
    var lname: String
    var pnumber: Int
    var email: String?
    var curCloseness: Int
    var desiredCloseness: Int
    var minIFCount: Int
    var minIFTime: Int
    var descript: String?
    
    enum CodingKeys: String, CodingKey {
            case id = "contactid"          // Maps JSON "userid" to Swift "id"
            case fname
            case lname
            case pnumber
            case email
            case curCloseness
            case desiredCloseness
            case minIFCount
            case minIFTime
            case descript
        }
}

class ContactDelegate: NSObject, CNContactPickerDelegate {
    @Published var selectedContacts: [CNContact] = []
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        selectedContacts = contacts
    }
    
    
}


struct ConnectionsPage: View {
    @StateObject private var viewModel = ConnectionsViewModel()
    @State private var selectedContact: ServerContact? = nil
    @State private var isShowingContactInfo = false
    @State private var isShowingAddContact = false // New state for showing the add/edit popup
    @State private var isShowingImportContacts = false
    
    private var contactPickerCoordinator = ContactDelegate()

    func openContactPicker() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = contactPickerCoordinator
        //        contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
//        contactPicker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
//        contactPicker.predicateForSelectionOfContact = NSPredicate(format: "phoneNumbers.@count == 1")
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.first as? UIWindowScene
        let window = windowScenes?.windows.first
        window?.rootViewController?.present(contactPicker, animated: true, completion: nil)
    }
    
    var body: some View {
        NavigationView {
            List(viewModel.contacts) { contact in
                Button(action: {
                    print(selectedContact)
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
            .navigationTitle("Connections")
            .navigationBarItems(leading: Button(action: {
                openContactPicker()
            }) {
                Text("Import Contacts")
                    .font(.title2)
            }, trailing: Button(action: {
                isShowingAddContact = true
            }) {
                Image(systemName: "plus")
                    .font(.title2)
            })
            .sheet(item: $selectedContact) { contact in
                // Pass the selected contact to the sheet
                ContactInfoView(contact: contact, isShowingAddContact: $isShowingAddContact, isShowingContactInfo: $isShowingContactInfo, selectedContact: $selectedContact)
            }
            .sheet(isPresented: $isShowingAddContact) {
                AddEditContactView(viewModel: viewModel,  isShowing: $isShowingAddContact, selectedContact: $selectedContact)
            }
            .task {
                await viewModel.fetchServerContacts()
            }
            .onReceive(contactPickerCoordinator.$selectedContacts) { contacts in
                
                for c in contacts {
                    
                    var serverContact = ServerContact(
                        fname: c.givenName,
                        lname: c.familyName,
                        pnumber: 0,//phoneNumberToInt(contact: c) ?? 0,
                        curCloseness: 0,
                        desiredCloseness: 0,
                        minIFCount: 0,
                        minIFTime: 0
                    )
                    viewModel.addContact(serverContact)
                }
            }
        }
    }
}

func phoneNumberToInt(contact: CNContact) -> Int? {
    // Assuming we take the first phone number
    guard let phoneNumber = contact.phoneNumbers.first?.value.stringValue else {
        return nil
    }
    
    // Remove non-numeric characters
    let numericString = phoneNumber.filter { "0123456789".contains($0) }
    
    // Convert to Int
    return Int(numericString)
}

// View for adding or editing a contact
struct AddEditContactView: View {
    @ObservedObject var viewModel: ConnectionsViewModel
    @Binding var isShowing: Bool
    @Binding var selectedContact: ServerContact?
    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var currentRelationship: Int = 0
    @State private var desiredRelationship: Int = 0
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
                        ForEach(0..<relationshipOptions.count, id: \.self) { index in
                                            Text(relationshipOptions[index])
                                                .tag(index)
                                        }                    }
                    Picker("Desired Relationship", selection: $desiredRelationship) {
                        ForEach(0..<relationshipOptions.count, id: \.self) { index in
                                            Text(relationshipOptions[index])
                                                .tag(index)
                                        }                    }
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
            .onAppear {
                        if let contact = selectedContact {
                            // Populate the fields with selected contact's information
                            name = contact.fname // Assuming ServerContact has a 'name' property
                            phoneNumber = String(contact.pnumber) // Assuming ServerContact has a 'phoneNumber' property
                            email = contact.email ?? "" // Assuming ServerContact has an 'email' property
                            currentRelationship = contact.curCloseness
                            desiredRelationship = contact.desiredCloseness
                            description = contact.descript ?? "No description provided"// Assuming ServerContact has a 'description' property
                        } else {
                            // Set default values if no contact is selected
                            name = ""
                            phoneNumber = ""
                            email = ""
                            currentRelationship = 0
                            desiredRelationship = 0
                            description = ""
                        }
                    }
        }
    }
    
    private func saveContact() {
        let newContact = ServerContact(
            fname: name,
            lname: name,
            pnumber: Int(phoneNumber) ?? 0,
            email: email,
            curCloseness: currentRelationship,
            desiredCloseness: desiredRelationship,
            minIFCount: -1,
            minIFTime: -1
        )
        viewModel.addContact(newContact)
        isShowing = false
    }
}

// View for showing contact info
struct ContactInfoView: View {
    var contact: ServerContact
    @Binding var isShowingAddContact: Bool
    @Binding var isShowingContactInfo: Bool
    @Binding var selectedContact: ServerContact?

    @State private var currentRelationshipIndex: Int = 0
    @State private var desiredRelationshipIndex: Int = 0

    // Options for relationships
    let relationshipOptions = ["Undefined","Stranger", "Acquaintances", "Friends", "Close Friends", "Best Friends"]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("\(contact.fname)")
                .font(.largeTitle)
            
            // Phone #
            Text("Phone Number: \(contact.pnumber)")
            
            // Phone #
            Text("Email: \(contact.email ?? "No email")")
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
            Text("Last Contacted: \(formattedDate(Date()))")
                .font(.title3)

            // List of Previous Contacts
            Text("Previous Contacts:")
                .font(.headline)
                .padding(.top)

//            ForEach(contact.previousContacts, id: \.self) { date in
//                Text(formattedDate(date))
//                    .padding(.leading)
//            }
            
            // Add description display
            Text("Description:")
                .font(.headline)
                .padding(.top)
            
            Text("This is where content descripton should go")
                .padding(.leading)

            Spacer()

            // Close Button
            Button(action: {
                // action for closing
                isShowingAddContact = true
                isShowingContactInfo = false
                selectedContact = contact

            }) {
                Text("Edit")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .onAppear() {
            // Initialize the picker indexes when the view appears
            selectedContact = contact
            currentRelationshipIndex = contact.curCloseness
            desiredRelationshipIndex = contact.desiredCloseness
            print(selectedContact)
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
