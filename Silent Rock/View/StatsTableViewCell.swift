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
    
    var playerId: Int? = nil
    
    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, id: Int) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.id = id
//    }
    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    static func nib() -> UINib {
        return UINib(nibName: "StatsTableViewCell", bundle: nil)
    }
    
    public func configure(date: String, time: String, id: Int) {
        dateLabel.text = date
        timeLabel.text = time
        playerId = id
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
