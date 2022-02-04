//
//  LBTableViewCell.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 2/3/22.
//

import UIKit

class StatsTableViewCell: UITableViewCell {
    
    static let identifier = "StatsTableViewCell"
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var playerID: Int? = nil
    
    static func nib() -> UINib {
        return UINib(nibName: "StatsTableViewCell", bundle: nil)
    }
    
    public func configure(date: String, time: String, id: Int) {
        dateLabel.text = date
        timeLabel.text = time
        playerID = id
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
