//
//  DTO.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 06/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject: DTOObject {
    var identifier: String {
        return self.objectID.uriRepresentation().absoluteString
    }
}

protocol DTOObject {
    var identifier: String { get }
}

class DTO {
    
    enum Status {
        case sucess
        case failure
    }
    
    // MARK: - Private
    private init() {}
    
    // MARK: - Public
    class func create<T: DTOObject>(object: T, completion: @escaping (_ status: Status) -> Void) {
        
        print("'create' not implemented")
        
        completion(.failure)
    }
    class func fetch<T: DTOObject>(with id: String, completion: @escaping (_ status: Status, _ result: T?) -> Void) {
        
        print("'fetchWithId' not implemented")
        
        completion(.failure, nil)
    }
    class func update<T: DTOObject>(object: T, completion: @escaping (_ status: Status) -> Void) {
        print("'update' not implemented")
        
        completion(.failure)
    }
    class func delete<T: DTOObject>(object: T, completion: @escaping (_ status: Status) -> Void) {
        print("'deleteObject' not implemented")
        
        completion(.failure)
    }
    class func delete(with id: String, completion: @escaping (_ status: Status) -> Void) {
        print("'deleteWithId' not implemented")
        
        completion(.failure)
    }
    
    // MARK: - Private
    private class func saveChanges() {
        
    }
}
