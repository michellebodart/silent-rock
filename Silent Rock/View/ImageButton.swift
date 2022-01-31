//
//  ImageButton.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 1/31/22.
//

import UIKit

@IBDesignable
class ImageButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        formatButton()
    }
    
    override func prepareForInterfaceBuilder() {
        formatButton()
    }
    
    func formatButton() {
//        self.imageEdgeInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        self.imageView?.contentMode = .scaleAspectFill
        
        // Create a UIImage object use image, the image file format is not limited.
        let backgroundImage:UIImage? = UIImage(named: "home.png")
        
        self.setBackgroundImage(backgroundImage, for: UIControl.State.normal)
    }

}
