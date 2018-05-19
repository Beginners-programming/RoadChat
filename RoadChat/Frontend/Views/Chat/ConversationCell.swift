//
//  ConversationCell.swift
//  RoadChat
//
//  Created by Niklas Sauer on 22.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastChangeLabel: UILabel!
    @IBOutlet weak var newestMessageLabel: UILabel!
    
    // MARK: - Public Methods
    func configure(conversation: Conversation, dateFormatter: DateFormatter) {
        titleLabel.text = conversation.storedTitle
        lastChangeLabel.text = dateFormatter.string(from: conversation.newestMessage?.time ?? conversation.creation!)
        newestMessageLabel.text = conversation.newestMessage?.message ?? "No messages..."
        
        // profile image appearance
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
    }

}
