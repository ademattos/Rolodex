//
//  MyContactsDB.swift
//  Rolodex
//
//  Created by Anthony Demattos on 4/1/19.
//  Copyright © 2019 Anthony Demattos. All rights reserved.
//

import SQLite

class MyContactsDB {
    //instance will be the main connection to the database
    //stored on the device. All instances of MyContactsDB wil;
    //refer to the same database
    static let instance = MyContactsDB()
    private let db: Connection?
    
    /* Analogy:
        Struct contacts {
            long int id;
            string name;
            string phone;
            string address;
        }
     
     struct contacts_type contacts[200];
 */
    private let contacts = Table("contacts")
    private let id = Expression<Int64>("id")
    private let name = Expression<String?>("name")
    private let phone = Expression<String>("phone")
    private let address = Expression<String>("address")
    
    private init() {
        //the path on the device (or siimulaor) to store the database.
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        //attempt the statemets in the do block. if it fails
        //then drop down and execute the catch block.
        do {
            print("\(path)/MyContacts.sqlite3")
            db = try Connection("\(path)/MyContacts.sqlite3")
        } catch {
            //why would i end up in this block?
            //1) file does not exist? in this case, Connection will
            //  try to create the file. If successul; we will not end up in the
            //  catch block
            //2) Not enough space on the device
            //3) Do not have permission to create the file on the device
            db = nil
            print("Unable to open database")
        }
        
        //we could end up here with a database without contacts table
        //or a databse opened with a contacts table
        createTable()
    }
    
    func createTable() {
        do {
            //db is the connection to the databse
            //the .run runs a command.
            try db!.run(
                contacts.create(ifNotExists: true)
                {
                    table in
                    table.column(id, primaryKey: true)
                    table.column(name)
                    table.column(phone, unique: true)
                    table.column(address)
                }
            )
        } catch {
            print("Unable to create table")
        }
    }
    
    func addContact(cname: String, cphone: String, caddress: String) -> Int64? {
        do {
            //setup a sql command to insert a record into the databse table
            let insert = contacts.insert(name <- cname, phone <- cphone, address <- caddress)
            //execute the command, i.e run the sql command
            let id = try db!.run(insert)
            print(insert)
            print(insert.asSQL())
            return id
        } catch {
            print("Insert failed")
            return -1
        }
    }
    
    func getContacts() -> [Contact] {
        var contacts = [Contact]()
        
        do {
            //the following for loop is similar to sql select
            for contact in try db!.prepare(self.contacts) {
                contacts.append(Contact(
                    id: contact[id],
                    name: contact[name]!,
                    phone: contact[phone],
                    address: contact[address]))
            }
        } catch {
            print("Select failed")
        }
        
        return contacts
    }
    
    func deleteContact(cid: Int64) -> Bool {
        do {
            let contact = contacts.filter(id == cid)
            try db!.run(contact.delete())
            //what print statement would print out the sql command
            print(contact.delete().asSQL())
            return true
        } catch {
            print("Delete failed")
        }
        return false
    }
    
    func updateContact(cid: Int64, newContact: Contact) -> Bool {
        let contact = contacts.filter(id == cid)
        do {
            let update = contact.update([
                name <- newContact.name,
                phone <- newContact.phone,
                address <- newContact.address
                ])
            //what print statement would print out the sql command
            print(contact.update().asSQL())
            if try db!.run(update) > 0 {
                return true
            }
        } catch {
            print("Update Failed: \(error)")
        }
        
        return false
    }
}
