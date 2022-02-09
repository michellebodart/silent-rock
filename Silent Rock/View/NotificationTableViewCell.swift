//
//  NotificationTableViewCell.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 2/9/22.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    static let identifier = "NotificationTableViewCell"
    
    var tripID: Int? = nil
    var playerID: Int? = nil
    var vc: profileViewController? = nil
    var player: Player = Player()
    
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    @IBAction func acceptButtonTapped(_ sender: Any) {
        print("tapped accept")
        player.acceptRejectPendingTrip(vc: self.vc!, tripID: self.tripID!, playerIDs: [self.playerID], accept: true)
    }
    
    @IBAction func rejectButtonTapped(_ sender: Any) {
        print("tapped reject")
        player.acceptRejectPendingTrip(vc: self.vc!, tripID: self.tripID!, playerIDs: [self.playerID], accept: false)
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "NotificationTableViewCell", bundle: nil)
    }
    
    public func configure(notificationText: String, tripID: Int?, playerID: Int?, vc: profileViewController) {
        self.notificationLabel.text = notificationText
        self.tripID = tripID
        self.playerID = playerID
        self.vc = vc
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
