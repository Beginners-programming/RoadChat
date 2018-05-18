//
//  AwaitLoginInterfaceController.swift
//  RoadChatWatch Extension
//
//  Created by Niklas Sauer on 18.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class AwaitLoginInterfaceController: WKInterfaceController, WCSessionDelegate {

    // MARK: - Private Properties
    private var session: WCSession?
    
    // MARK: - Initialization
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let isLoggedIn = message["isLoggedIn"] as? Bool, isLoggedIn else {
            return
        }
        
        self.popToRootController()
    }
    

      
    
}

