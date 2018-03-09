//
//  LoginViewController.swift
//  RoadChat
//
//  Created by Malcolm Malam on 07.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit
import Locksmith

class LoginViewController: UIViewController {
    
    // MARK: - Public Properties
    let authenticationManager = AuthenticationManager()
    
    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - Public Methods
    @IBAction func registerButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "showRegisterView", sender: self)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        guard let user = usernameTextField.text, let password = passwordTextField.text else {
            // handle missing fields error
            log.warning("Missing required fields for login.")
            return
        }
        
        let request = LoginRequest(user: user, password: password)
        
        authenticationManager.login(request) { error in
            guard error == nil else {
                log.error("Failed to login user: \(error.debugDescription)")
                self.usernameLabel.textColor = .red
                self.passwordLabel.textColor = .red
                return
            }
            
            log.info("Successful login.")
            self.performSegue(withIdentifier: "showTabBarVC", sender: self)
        }
    }
    
}
