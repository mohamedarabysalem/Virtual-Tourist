//
//  DataController.swift
//  VirtualTourist
//
//  Created by Mohamad El Araby on 4/20/19.
//  Copyright © 2019 Mohamad El Araby. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    static var shared = DataController(modelName: "VirtualTourist")
    let persistentContainer:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    let backgroundContext:NSManagedObjectContext!
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
        
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
          //  self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
}

