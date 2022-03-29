//
//  LeaderboardTableViewCell.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 2/4/22.
//

import UIKit

class LeaderboardTableViewCell: UITableViewCell {

    static let identifier = "LeaderboardTableViewCell"
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tripsLabel: UILabel!
    
    var playerID: Int? = nil
    
    static func nib() -> UINib {
        return UINib(nibName: "LeaderboardTableViewCell", bundle: nil)
    }
    
    public func configure(id: Int, username: String, trips: Int) {
        self.playerID = id
        self.usernameLabel.text = username
        self.tripsLabel.text = String(trips)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // making it not change color when selected
        super.setSelected(false, animated: animated)

        // Configure the view for the selected state
    }
    
}
