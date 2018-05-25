//
//  AppDelegate.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 30/11/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Insert code here to initialize your application
        NSApplication.shared.mainWindow?.makeKey()
        NSApplication.shared.mainWindow?.setIsVisible(true)
    }

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        
        CoreDataManager.save { (status) in
            switch status {
            case .sucess:
                print("sucess")
            case .failure(let error):
                if let error = error {
                    print("Error - \(error)")
                } else {
                    print("Unknown error")
                }
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        return CoreDataManager.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        
        CoreDataManager.save { (status) in
            switch status {
            case .sucess:
                print("sucess")
            case .failure(let error):
                if let error = error {
                    print("Error - \(error)")
                } else {
                    print("Unknown error")
                }
            }
        }
        
        // If we got here, it is time to quit.
        return .terminateNow
    }
}

