//
//  UserStore.swift
//  RoadChat
//
//  Created by Niklas Sauer on 09.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit

struct UserStore {
    
    func create(_ user: RegisterRequest, completion: @escaping (Error?) -> Void) {
        let userService = UserService()
        
        do {
            try userService.create(user) { user, error in
                guard let user = user else {
                    log.error("Failed to register user: \(error!)")
                    completion(error!)
                    return
                }
                
                do {
                    try CredentialManager.shared.setUserID(user.id)
                    _ = try User.create(from: user, in: CoreDataStack.shared.viewContext)
                    CoreDataStack.shared.saveViewContext()
                    log.info("Successful registration.")
                    completion(nil)
                } catch {
                    // pass keychain error
                    // pass core data error
                    log.error("Failed to save credentials or create Core Data User entity: \(error)")
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            completion(error)
        }
    }
    
}
