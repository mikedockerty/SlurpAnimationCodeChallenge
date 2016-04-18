//
//  BackgroundView.swift
//  Slurp
//
//  Created by Mike Dockerty on 4/17/16.
//  Copyright © 2016 Mike Dockerty. All rights reserved.
//

import UIKit

class BackgroundView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        layer.cornerRadius = 28.0
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
