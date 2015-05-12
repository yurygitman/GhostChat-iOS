//
//  IndividualChatCell.swift
//  GhostChat-iOS
//
//  Created by Saman Rezazadeh Tehrani on 5/12/15.
//  Copyright (c) 2015 yuryg. All rights reserved.
//

import UIKit

class IndividualChatCell: UITableViewCell {
    var content : String?{
        didSet{
            updateUI();
        }
        
    }
    func updateUI(){
        messageText.attributedText = nil
        
        if let message = self.content{
            messageText?.text = message
            
            
        }
        
    }
    
    
    @IBOutlet weak var messageText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
