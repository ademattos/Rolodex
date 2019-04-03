//
//  ViewController.swift
//  Rolodex
//
//  Created by Anthony Demattos on 3/25/19.
//  Copyright © 2019 Anthony Demattos. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var contacts = [Contact]()
    private var selectedContact: Int?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var contactsTableView: UITableView!
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        let name = nameTextField.text ?? ""
        let phone = phoneTextField.text ?? ""
        let address = addressTextField.text ?? ""
        
        //try to add a contact to the database
        if let id = MyContactsDB.instance.addContact(cname: name, cphone: phone, caddress: address){
            //if successul adding a contact, then use the id MyContactsDB gave back
            let contact = Contact(id: id, name: name, phone: phone, address: address)
            
            //update the local array keeping track of whats in the database and display
            contacts.append(contact)
            print(contacts.count)
            //update the tableView display
            contactsTableView.insertRows(at: [NSIndexPath(row: contacts.count-1, section: 0) as IndexPath], with: .fade)
        }
        
        nameTextField.text = ""
        phoneTextField.text = ""
        addressTextField.text = ""
    }
    
    @IBAction func updateButtonClicked(_ sender: UIButton) {
        if selectedContact != nil {
            let id = contacts[selectedContact!].id!
            let contact = Contact(
                id: id,
                name: nameTextField.text ?? "",
                phone: phoneTextField.text ?? "",
                address: addressTextField.text ?? "")
            
            if MyContactsDB.instance.updateContact(cid: id, newContact: contact) {
                contacts.remove(at: selectedContact!)
                contacts.insert(contact, at: selectedContact!)
            }
            
            contactsTableView.reloadData()
        } else {
            print("No item selected")
        }
    }
    
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        if selectedContact != nil {
            
            let id = contacts[selectedContact!].id!
            if MyContactsDB.instance.deleteContact(cid: id){
                contacts.remove(at: selectedContact!)
                contactsTableView.deleteRows(at: [NSIndexPath(row: selectedContact!, section: 0) as IndexPath], with: .fade)
            }
            
        } else {
            print("No item selected")
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tv-3")
        nameTextField.text = contacts[indexPath.row].name
        phoneTextField.text = contacts[indexPath.row].phone
        addressTextField.text = contacts[indexPath.row].address
        
        selectedContact = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("tv-1")
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("tv-2")
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell")!
        var label: UILabel
        
        label = cell.viewWithTag(1) as! UILabel //Name Label
        label.text = contacts[indexPath.row].name
        
        label = cell.viewWithTag(2) as! UILabel //Phone Label
        label.text = contacts[indexPath.row].phone
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contacts = MyContactsDB.instance.getContacts()
        contactsTableView.delegate = self
        contactsTableView.dataSource = self        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

