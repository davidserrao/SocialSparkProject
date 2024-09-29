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
    var label: String?
    var activeflag: Int = 1
    var location: String?

    
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
            case label
            case activeflag
            case location
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

                Spacer() // Push content down to give space for header/buttons

                // The list of contacts
                List(viewModel.contacts) { contact in
                    Button(action: {
                        selectedContact = contact
                        isShowingAddContact = true
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
            .navigationBarItems(leading: Button(action: {
                openContactPicker()
            }) {
                Text("Import Contacts")
                    .font(.title2)
                    .foregroundColor(Color.yellow)
            }, trailing: Button(action: {
                selectedContact = nil
                isShowingAddContact = true
            }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(Color.yellow)

            })
//            .sheet(item: $selectedContact) { contact in
//                // Pass the selected contact to the sheet
//                ContactInfoView(contact: contact, isShowingAddContact: $isShowingAddContact, isShowingContactInfo: $isShowingContactInfo)
//            }
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
            .sheet(isPresented: $isShowingAddContact) {
                            AddEditContactView(viewModel: viewModel, isShowing: $isShowingAddContact, selectedContact: $selectedContact)
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
                print(selectedContact)
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
        print(description)
        let newContact = ServerContact(
            id: selectedContact?.id,
            fname: name,
            lname: name,
            pnumber: Int(phoneNumber) ?? 0,
            email: email,
            curCloseness: currentRelationship,
            desiredCloseness: desiredRelationship,
            minIFCount: -1,
            minIFTime: -1,
            descript: description
        )
        if selectedContact != nil {
            viewModel.updateContact(newContact)
        } else {
            viewModel.addContact(newContact)
        }
        isShowing = false
    }
}

// View for showing contact info
struct ContactInfoView: View {
    var contact: ServerContact
    @Binding var isShowingAddContact: Bool
    @Binding var isShowingContactInfo: Bool

    @State private var currentRelationshipIndex: Int = 0
    @State private var desiredRelationshipIndex: Int = 0

    let relationshipOptions = ["Undefined", "Stranger", "Acquaintances", "Friends", "Close Friends", "Best Friends"]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("\(contact.fname)")
                .font(.largeTitle)

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
                isShowingAddContact = true
                isShowingContactInfo = false

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
