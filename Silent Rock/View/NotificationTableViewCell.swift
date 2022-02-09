//
//  NotificationTableViewCell.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 2/9/22.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    static let identifier = "NotificationTableViewCell"
    
    @IBOutlet weak var notificationLabel: UILabel!
    
    @IBAction func acceptButtonTapped(_ sender: Any) {
        print("tapped accept")
    }
    
    @IBAction func rejectButtonTapped(_ sender: Any) {
        print("tapped reject")
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "NotificationTableViewCell", bundle: nil)
    }
    
    public func configure(username: String, date: String) {
        self.notificationLabel.text = username + " added you to their " + date + " trip"
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
