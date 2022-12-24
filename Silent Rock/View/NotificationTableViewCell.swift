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
        player.acceptRejectPendingTrip(vc: self.vc!, tripID: self.tripID!, playerIDs: [self.playerID], accept: true)
        vc?.pendingTrips = (vc?.pendingTrips.filter { ($0["id"] as! Int) != self.tripID})!
        self.resizeTable(vc: self.vc!)
    }
    
    @IBAction func rejectButtonTapped(_ sender: Any) {
        player.acceptRejectPendingTrip(vc: self.vc!, tripID: self.tripID!, playerIDs: [self.playerID], accept: false)
        vc?.pendingTrips = (vc?.pendingTrips.filter { ($0["id"] as! Int) != self.tripID})!
        
        self.resizeTable(vc: self.vc!)
    }
    
    func resizeTable(vc: profileViewController) {
        // resize the table
        let tableHeight: CGFloat
        if vc.pendingTrips.count < 1 {
            tableHeight = CGFloat(vc.notificationCellHeight)
            vc.notificationButton.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
            tableHeight = CGFloat(min(vc.pendingTrips.count * vc.notificationCellHeight, 3*60))
        }
        vc.notificationTable.heightAnchor.constraint(equalToConstant: tableHeight).isActive = false
        vc.notificationTable.heightAnchor.constraint(equalToConstant: tableHeight).isActive = true
        vc.notificationTable.reloadData()
        
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
