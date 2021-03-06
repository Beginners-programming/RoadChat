//
//  Conversation.swift
//  RoadChat
//
//  Created by Niklas Sauer on 02.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import CoreData
import RoadChatKit
import UIKit

enum ConversationError: Error {
    case notParticipating
}

class Conversation: NSManagedObject, ReportOwner {
    
    // MARK: - Public Class Methods
    class func createOrUpdate(from prototype: RoadChatKit.Conversation.PublicConversation, in context: NSManagedObjectContext) throws -> Conversation {
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", prototype.id)
        
        do {
            let matches = try context.fetch(request)
            
            if matches.count > 0 {
                assert(matches.count >= 1, "Conversation.create -- Database Inconsistency")
                
                // update existing conversation
                let conversation = matches.first!
                conversation.title = prototype.title
                
                // set last message
                if let newestMessage = prototype.newestMessage, let message = try? DirectMessage.create(from: newestMessage, conversationID: Int(conversation.id), in: context) {
                    conversation.newestMessage = message
                    message.conversation = conversation
                }
                
                // set participants
                let participants = prototype.participants.compactMap {
                    try? Participant.createOrUpdate(from: $0, conversationID: prototype.id, in: context)
                }
                
                conversation.addToParticipants(NSSet(array: participants))
                
                return conversation
            }
        } catch {
            throw error
        }
        
        // create new conversation
        let conversation = Conversation(context: context)
        conversation.id = Int32(prototype.id)
        conversation.creatorID = Int32(prototype.creatorID)
        conversation.title = prototype.title
        conversation.creation = prototype.creation
        
        // set last message
        if let newestMessage = prototype.newestMessage, let message = try? DirectMessage.create(from: newestMessage, conversationID: Int(conversation.id), in: context) {
            conversation.newestMessage = message
            message.conversation = conversation
        }
        
        // set participants
        let participants = prototype.participants.compactMap {
            try? Participant.createOrUpdate(from: $0, conversationID: prototype.id, in: context)
        }
        
        conversation.addToParticipants(NSSet(array: participants))
        
        // retrieve public resources
        conversation.getMessages(completion: nil)
        
        return conversation
    }
    
    // MARK: - Public Properties
    var storedParticipants: [Participant] {
        return Array(participants!) as! [Participant]
    }
    
    // MARK: - ReportOwner Protocol
    var logDescription: String {
        return "'Conversation' [id: '\(self.id)']"
    }
    
    // MARK: - Private Properties
    private let conversationService = ConversationService(config: DependencyContainer().config)
    private let context: NSManagedObjectContext = CoreDataStack.shared.viewContext
    
    // MARK: - Initialization
    override func awakeFromFetch() {
        super.awakeFromFetch()
        get(completion: nil)
        getMessages(completion: nil)
        getParticipants(completion: nil)
    }
    
    // MARK: - Public Methods
    func get(completion: ((Error?) -> Void)?) {
        conversationService.get(conversationID: Int(id)) { conversation, error in
            guard let conversation = conversation else {
                // pass service error
                let report = Report(.failedServerOperation(.retrieve, resource: nil, isMultiple: false, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            do {
                _ = try Conversation.createOrUpdate(from: conversation, in: self.context)
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.retrieve, resource: nil, isMultiple: false), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                let report = Report(.failedCoreDataOperation(.retrieve, resource: nil, isMultiple: false, error: error), owner: self)
                log.error(report)
                completion?(error)
            }
        }
    }
    
    func save(completion: ((Error?) -> Void)?) {
        let updateRequest = ConversationUpdateRequest(title: title)
        
        do {
            try conversationService.update(conversationID: Int(id), to: updateRequest) { error in
                guard error == nil else {
                    let report = Report(.failedServerOperation(.update, resource: nil, isMultiple: false, error: error!), owner: self)
                    log.error(report)
                    completion?(error!)
                    return
                }
                
                do {
                    try self.context.save()
                    
                    let report = Report(.successfulCoreDataOperation(.update, resource: nil, isMultiple: false), owner: self)
                    log.debug(report)
                    
                    completion?(nil)
                } catch {
                    // pass core data error
                    let report = Report(.failedCoreDataOperation(.update, resource: nil, isMultiple: false, error: error), owner: self)
                    log.error(report)
                    completion?(error)
                }
            }
        } catch {
            // pass body encoding error
            let report = Report(.failedServerRequest(requestType: "ConversationUpdateRequest", error: error), owner: self)
            log.error(report)
            completion?(error)
        }
    }

    func delete(completion: @escaping (Error?) -> Void) {
        conversationService.delete(conversationID: Int(id)) { error in
            guard error == nil else {
                // pass service error
                let report = Report(.failedServerOperation(.delete, resource: nil, isMultiple: false, error: error!), owner: self)
                log.error(report)
                completion(error!)
                return
            }

            do {
                self.context.delete(self)
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.delete, resource: nil, isMultiple: false), owner: self)
                log.debug(report)
                completion(nil)
            } catch {
                let report = Report(.failedCoreDataOperation(.delete, resource: nil, isMultiple: false, error: error), owner: self)
                log.error(report)
                completion(error)
            }
        }
    }
 
    func getMessages(completion: ((Error?) -> Void)?) {
        conversationService.getMessages(conversationID: Int(id)) { messages, error in
            guard let messages = messages else {
                // pass service error
                let report = Report(.failedServerOperation(.retrieve, resource: "DirectMessage", isMultiple: true, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            let coreMessages: [DirectMessage] = messages.compactMap {
                do {
                    let message = try DirectMessage.create(from: $0, conversationID: Int(self.id), in: self.context)
                    
                    if let newestMessage = self.newestMessage {
                        if message.time! > newestMessage.time! {
                            self.newestMessage = message
                        }
                    } else {
                        self.newestMessage = message
                    }
                    
                    return message
                } catch DirectMessageError.duplicate {
                    return nil
                } catch {
                    let report = Report(.failedCoreDataOperation(.create, resource: "DirectMessage", isMultiple: true, error: error), owner: self)
                    log.error(report)
                    return nil
                }
            }
            
            self.addToMessages(NSSet(array: coreMessages))
            
            do {
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.retrieve, resource: "DirectMessage", isMultiple: true), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                let report = Report(.failedCoreDataOperation(.retrieve, resource: "DirectMessage", isMultiple: true, error: error), owner: self)
                log.error(report)
                completion?(error)
            }
        }
    }

    func createMessage(_ message: DirectMessageRequest, completion: @escaping (Error?) -> Void) {
        do {
            try conversationService.createMessage(message, conversationID: Int(id)) { message, error in
                guard let message = message else {
                    // pass service error
                    let report = Report(.failedServerOperation(.create, resource: "DirectMessage", isMultiple: false, error: error!), owner: self)
                    log.error(report)
                    completion(error!)
                    return
                }
                
                do {
                    let message = try DirectMessage.create(from: message, conversationID: Int(self.id), in: self.context)
                    self.addToMessages(message)
                    
                    if let newestMessage = self.newestMessage {
                        if message.time! > newestMessage.time! {
                            self.newestMessage = message
                        }
                    } else {
                        self.newestMessage = message
                    }
                    
                    try self.context.save()
                    let report = Report(.successfulCoreDataOperation(.create, resource: "DirectMessage", isMultiple: false), owner: self)
                    log.debug(report)
                    completion(nil)
                } catch {
                    // pass core data error
                    let report = Report(.failedCoreDataOperation(.create, resource: "DirectMessage", isMultiple: false, error: error), owner: self)
                    log.error(report)
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            let report = Report(.failedServerRequest(requestType: "DirectMessageRequest", error: error), owner: self)
            log.error(report)
            completion(error)
        }
    }
    
    func getParticipants(completion: ((Error?) -> Void)?) {
        conversationService.getParticipants(conversationID: Int(id)) { participants, error in
            guard let participants = participants else {
                // pass service error
                let report = Report(.failedServerOperation(.retrieve, resource: "Participant", isMultiple: true, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            let coreParticipants: [Participant] = participants.compactMap {
                do {
                    return try Participant.createOrUpdate(from: $0, conversationID: Int(self.id), in: self.context)
                } catch {
                    let report = Report(.failedCoreDataOperation(.create, resource: "Participant", isMultiple: false, error: error), owner: self)
                    log.error(report)
                    return nil
                }
            }
            
            self.addToParticipants(NSSet(array: coreParticipants))
            
            do {
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.retrieve, resource: "Participant", isMultiple: true), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                let report = Report(.failedCoreDataOperation(.retrieve, resource: "Participant", isMultiple: true, error: error), owner: self)
                log.error(report)
                completion?(error)
            }
        }
    }
    
    func accept(completion: @escaping (Error?) -> Void) {
        conversationService.accept(conversationID: Int(id)) { error in
            guard error == nil else {
                // pass service error
                let report = Report(.failedServerOperation(.update, resource: "ApprovalStatus", isMultiple: false, error: error!), owner: self)
                log.error(report)
                completion(error!)
                return
            }
            
            self.setApprovalStatus(.accepted, completion: completion)
        }
    }
    
    func deny(completion: @escaping (Error?) -> Void) {
        conversationService.deny(conversationID: Int(id)) { error in
            guard error == nil else {
                // pass service error
                let report = Report(.failedServerOperation(.update, resource: "ApprovalStatus", isMultiple: false, error: error!), owner: self)
                log.error(report)
                completion(error!)
                return
            }
            
            self.setApprovalStatus(.denied, completion: completion)
        }
    }
    
    func getTitle(activeUser: User) -> String? {
        if storedParticipants.count > 2 {
            return title
        } else {
            return storedParticipants.first(where: { $0.user!.id != activeUser.id })?.user?.username
        }
    }
    
    func getImage(activeUser: User) -> UIImage? {
        if storedParticipants.count > 2 {
            return nil
        } else {
            return storedParticipants.first(where: { $0.user!.id != activeUser.id })?.user?.storedImage
        }
    }
    
    func getApprovalStatus(activeUser: User) -> ApprovalType? {
        guard let participation = storedParticipants.first(where: { $0.user?.id == activeUser.id }) else {
            return nil
        }
        
        guard let status = participation.approvalStatus, let approval = ApprovalType(rawValue: status) else {
            return nil
        }
        
        return approval
    }
    
    // MARK: - Private Methods
    private func setApprovalStatus(_ status: ApprovalType, completion: (Error?) -> Void) {
        guard let participation = self.storedParticipants.first(where: { $0.user?.id == self.user?.id }) else {
            // pass model validation error
            log.error("\(self.user!.logDescription) is not participating in \(self.logDescription)")
            completion(ConversationError.notParticipating)
            return
        }
        
        do {
            participation.setApprovalStatus(status)
            try self.context.save()
            let report = Report(ReportType.successfulCoreDataOperation(.update, resource: "ApprovalStatus", isMultiple: false), owner: self)
            log.debug(report)
            completion(nil)
        } catch {
            let report = Report(ReportType.failedCoreDataOperation(.update, resource: "ApprovalStatus", isMultiple: false, error: error), owner: self)
            log.error(report)
            completion(error)
        }
    }

}
