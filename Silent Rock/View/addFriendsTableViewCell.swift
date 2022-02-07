//
//  addFriendsTableViewCell.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 2/7/22.
//

import UIKit

class addFriendsTableViewCell: UITableViewCell {
    
    static let identifier = "addFriendsTableViewCell"
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    var playerID: Int? = nil
    
    static func nib() -> UINib {
        return UINib(nibName: "addFriendsTableViewCell", bundle: nil)
    }

    public func configure(id: Int, username: String) {
        self.playerID = id
        self.usernameLabel.text = username
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)

        // Configure the view for the selected state
    }
    
}
