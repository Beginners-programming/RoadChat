//
//  ViewControllerFactory.swift
//  RoadChat
//
//  Created by Niklas Sauer on 19.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

protocol ViewControllerFactory {
    
    // General
    func makeSetupViewController() -> SetupViewController
    func makeHomeTabBarController(activeUser: User) -> HomeTabBarController
    
    // Shared
    func makeLocationViewController(for location: CLLocation) -> LocationViewController
    func makeGeofenceViewController(radius: Double?, min: Double, max: Double, identifier: String) -> GeofenceViewController
    
    // Authentication
    func makeAuthenticationViewController() -> UINavigationController
    func makeLoginViewController() -> LoginViewController
    func makeRegisterViewController() -> RegisterViewController
    
    // Community
    func makeCommunityBoardViewController(activeUser: User) -> CommunityBoardViewController
    func makeCommunityMessagesViewController(for sender: User?, activeUser: User) -> CommunityMessagesViewController
    func makeCreateCommunityMessageViewController() -> CreateCommunityMessageViewController
    func makeCommunityMessageDetailViewController(for message: CommunityMessage, sender: User, activeUser: User) -> CommunityMessageDetailViewController
    
    // Traffic
    func makeTrafficBoardViewController(activeUser: User) -> TrafficBoardViewController
    func makeTrafficMessagesViewController(for sender: User?, activeUser: User) -> TrafficMessagesViewController
    func makeCreateTrafficMessageViewController() -> CreateTrafficMessageViewController
    func makeTrafficMessageDetailViewController(for message: TrafficMessage, sender: User, activeUser: User) -> TrafficMessageDetailViewController
    
    // Chat
    func makeConversationsViewController(for user: User) -> ConversationsViewController
    
    // Settings
    func makeSettingsViewController(for user: User, settings: Settings, privacy: Privacy) -> SettingsViewController
    func makePrivacyViewController(with privacy: Privacy) -> PrivacyViewController
    func makeSecurityViewController(for user: User) -> SecurityViewController
    func makeChangePasswordViewController(for user: User) -> ChangePasswordViewController
    func makeChangeEmailViewController(for user: User) -> ChangeEmailViewController
    
    // User
    func makeProfileViewController(for user: User, activeUser: User) -> ProfileViewController
    func makeProfilePageViewController(for user: User, activeUser: User) -> ProfilePageViewController
    func makeCreateCarViewController(for user: User) -> CreateCarViewController
    func makeCreateProfileViewController(for user: User) -> CreateOrEditProfileViewController
    func makeLogDataViewController() -> LogDataViewController
    
    // Car
    func makeCarsViewController(for user: User, activeUser: User) -> CarsViewController
    func makeCarDetailViewController(for car: Car, activeUser: User) -> CarDetailViewController
    
    // Profile Pages
    func makeAboutViewController(for user: User, activeUser: User) -> AboutViewController

}
