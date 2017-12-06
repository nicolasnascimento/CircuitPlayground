//
//  CoreDataManager.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 06/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    enum Status {
        case sucess
        case failure(Error?)
    }
    
    private init() { }
    
    // MARK: - Core Data stack
    
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CircuitPlayground")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()
    
//    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
    static var undoManager: UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return CoreDataManager.persistentContainer.viewContext.undoManager
    }

//    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    static func save(completion: (_ status: Status) -> Void) {
        // Save changes in the application's managed object context before the application terminates.
        let context = CoreDataManager.persistentContainer.viewContext
        
        if !context.commitEditing() {
            completion(.failure(nil))
        } else if !context.hasChanges {
            return completion(.failure(nil))
        } else {
        
            do {
                try context.save()
                completion(.sucess)
            } catch {
                let nserror = error as NSError
                completion(.failure(nserror as Error))
                
            }
        }
    }

}
