//
//  BorderButton.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 11/10/21.
//

import UIKit

@IBDesignable
class BorderButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        formatButton()
    }
    
    override func prepareForInterfaceBuilder() {
        formatButton()
    }

    func formatButton() {
        layer.borderWidth = 1.0
        layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        layer.cornerRadius = 8.0
    }
    
}
