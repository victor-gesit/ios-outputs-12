//
//  FriendsControllerHelper.swift
//  Output12
//
//  Created by Victor Idongesit on 03/12/2017.
//  Copyright © 2017 Victor Idongesit. All rights reserved.
//

import UIKit
import CoreData

extension FriendsController {
    func clearData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext {
            let entityNames = ["Message", "Friend"]
            for entityName in entityNames {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                do {
                    messages = try context.fetch(fetchRequest) as? [Message]
                    let objects = try context.fetch(fetchRequest) as? [NSManagedObject]
                    for object in objects! {
                        context.delete(object)
                    }
                    try context.save()
                } catch let err {
                    print(err)
                }
            }
        }
    }
    func setupData() {
        clearData()
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext {
            let steve = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            steve.name = "Steve Jobs"
            steve.profileImageName = "steve"
            
            let zuckerberg = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            zuckerberg.name = "Mark Zuckerberg"
            zuckerberg.profileImageName = "zuckerberg"
            createVictorsMessageWithContext(context: context)
            FriendsController.createMessageWithText(text: "You'll someday connect the dots.", friend: steve, minutesAgo: 120, context: context)
            FriendsController.createMessageWithText(text: "Even though you don't understand it now", friend: steve, minutesAgo: 90, context: context)
            FriendsController.createMessageWithText(text: "You only live once. Give it all you've got.", friend: steve, minutesAgo: 30, context: context)
            FriendsController.createMessageWithText(text: "Ideas do not come out fully formed", friend: zuckerberg, minutesAgo: 60 * 24 * 10, context: context)
            FriendsController.createMessageWithText(text: "No, They dont", friend: zuckerberg, minutesAgo: 60 * 24 * 25, context: context)
            
            do {
                try context.save()
            } catch let err {
                print(err)
            }
            loadData()
        }
    }
    static func createMessageWithText(text: String, friend: Friend, minutesAgo: Double, context: NSManagedObjectContext, isSender: Bool = false) -> Message {
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message.text = text
        message.friend = friend
        message.date = Date().addingTimeInterval(-minutesAgo * 60)
        message.isSender = isSender
        return message
    }
    private func createVictorsMessageWithContext(context: NSManagedObjectContext) {
        let idem = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        idem.name = "Victor Idongesit"
        idem.profileImageName = "gesit"
        
        FriendsController.createMessageWithText(text: "Hello there... How do you do?", friend: idem, minutesAgo: 10, context: context)
        FriendsController.createMessageWithText(text: "I was wondering if you know you write you epitaph without knowing. I was wondering if you know you write you epitaph without knowing. I was wondering if you know you write you epitaph without knowing. I was wondering if you know you write you epitaph without knowing", friend: idem, minutesAgo: 60 * 5, context: context)
        FriendsController.createMessageWithText(text: "Anyway, don't matter what you wrote before. Just do it right from now on", friend: idem, minutesAgo: 60 * 5, context: context)
        FriendsController.createMessageWithText(text: "I know!", friend: idem, minutesAgo: 5, context: context, isSender: true)
        FriendsController.createMessageWithText(text: "But I'm sorta busy right now", friend: idem, minutesAgo: 2, context: context, isSender: true)
        FriendsController.createMessageWithText(text: "Anyway, don't matter what you wrote before. Just do it right from now on", friend: idem, minutesAgo: 1, context: context, isSender: true)
        FriendsController.createMessageWithText(text: "Anyway, don't matter what you wrote before. Just do it right from now on", friend: idem, minutesAgo: 1, context: context)
    }
    func loadData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        messages = [Message]()
        if let context = delegate?.persistentContainer.viewContext {
            if let friends = fetchFriends() {
                for friend in friends {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false) ]
                    fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friend.name!)
                    fetchRequest.fetchLimit = 1
                    do {
                        let fetchedMessages = try context.fetch(fetchRequest) as? [Message]
                        messages?.append(contentsOf: fetchedMessages!)
                    } catch let err {
                        print(err)
                    }
                }
                messages = messages?.sorted(by: {$0.date!.compare($1.date!) == .orderedDescending})
            }
        }
    }
    private func fetchFriends() -> [Friend]? {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        var friends: [Friend]? = [Friend]()
        if let context = delegate?.persistentContainer.viewContext {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
            do {
                friends = try context.fetch(fetchRequest) as? [Friend]
                return friends
            } catch let err {
                print(err)
            }
        }
        return nil
    }
}
