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

    
    static func nib() -> UINib {
        return UINib(nibName: "StatsTableViewCell", bundle: nil)
    }
    
    public func configure(date: String, time: String) {
        dateLabel.text = date
        timeLabel.text = time
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
