//
//  SetupViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 18.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController {
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let authenticationManager: AuthenticationManager
    private let credentials: APICredentialStore
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, authenticationManager: AuthenticationManager, credentials: APICredentialStore) {
        self.viewFactory = viewFactory
        self.authenticationManager = authenticationManager
        self.credentials = credentials
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        try? credentials.reset()
    
        authenticationManager.getAuthenticatedUser { user in
            guard let user = user else {
                // show login view
                let loginViewController = self.viewFactory.makeLoginViewController()
                let loginNavigationController = UINavigationController(rootViewController: loginViewController)
                (UIApplication.shared.delegate! as! AppDelegate).show(loginNavigationController)
                return
            }
            
            // show home screen
            let homeTabBarController = self.viewFactory.makeHomeTabBarController(for: user)
            (UIApplication.shared.delegate! as! AppDelegate).show(homeTabBarController)
        }
    }

}
