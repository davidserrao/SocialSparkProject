//
//  ConnectionsViewModel.swift
//  SocialSpark
//
//  Created by David Serrao on 9/28/24.
//

import Foundation
import Combine
import Contacts


// ViewModel to handle API calls and store contacts
class ConnectionsViewModel: ObservableObject {
    @Published var contacts: [Contact] = []

    // Function to fetch contacts from an API
    func fetchContacts() async {
        guard let url = URL(string: "http://127.0.0.1:8000/api/get/contacts/1") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
//        request.setValue("Bearer YOUR_ACCESS_TOKEN", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching contacts: \(error.localizedDescription)")
                return
            }

            if let data = data {
                do {
                    let decodedContacts = try JSONDecoder().decode([Contact].self, from: data)
                    print(decodedContacts.map { $0.id })
                    DispatchQueue.main.async {
                        self.contacts = decodedContacts
                    }
                } catch {
                    print("Failed to decode contacts: \(error)")
                }
            }
        }
        task.resume()
    }

    // Function to add a contact using an API (POST)
    func addContact(_ contact: Contact) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/create/contact/1") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
//        request.setValue("Bearer YOUR_ACCESS_TOKEN", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let contactData = try JSONEncoder().encode(contact)
            request.httpBody = contactData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error adding contact: \(error.localizedDescription)")
                    return
                }

                // Handle success response if needed
                if let data = data {
                    do {
                        let addedContact = try JSONDecoder().decode(Contact.self, from: data)
                        DispatchQueue.main.async {
                            self.contacts.append(addedContact)
                        }
                    } catch {
                        print("Failed to decode added contact: \(error)")
                    }
                }
            }
            task.resume()
        } catch {
            print("Failed to encode contact: \(error)")
        }
    }

    // Function to update a contact using an API (PUT)
    func updateContact(_ contact: Contact) {
        let contactId = contact.id

        guard let url = URL(string: "https://yourapi.com/contacts/\(contactId)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer YOUR_ACCESS_TOKEN", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let contactData = try JSONEncoder().encode(contact)
            request.httpBody = contactData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error updating contact: \(error.localizedDescription)")
                    return
                }

                // Handle success response if needed
                if let data = data {
                    do {
                        let updatedContact = try JSONDecoder().decode(Contact.self, from: data)
                        DispatchQueue.main.async {
                            if let index = self.contacts.firstIndex(where: { $0.id == contact.id }) {
                                self.contacts[index] = updatedContact
                            }
                        }
                    } catch {
                        print("Failed to decode updated contact: \(error)")
                    }
                }
            }
            task.resume()
        } catch {
            print("Failed to encode contact: \(error)")
        }
    }
    
    func importContacts() {
        // Initialize the contact store.
        var store = CNContactStore()

    }
}
