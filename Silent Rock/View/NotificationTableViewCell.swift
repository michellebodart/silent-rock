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
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    @IBAction func acceptButtonTapped(_ sender: Any) {
        print("tapped accept")
    }
    
    @IBAction func rejectButtonTapped(_ sender: Any) {
        print("tapped reject")
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "NotificationTableViewCell", bundle: nil)
    }
    
    public func configure(notificationText: String) {
        self.notificationLabel.text = notificationText
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
