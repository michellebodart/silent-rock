//
//  BorderTable.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 2/7/22.
//

import UIKit

@IBDesignable
class BorderTable: UITableView {
    override func awakeFromNib() {
        super.awakeFromNib()
        formatTable()
    }
    
    override func prepareForInterfaceBuilder() {
        formatTable()
    }
    
    func formatTable() {
        layer.cornerRadius = 8
        layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        layer.borderWidth = 1
    }

}
