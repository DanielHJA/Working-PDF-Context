//
//  PresentationView.swift
//  Uiviewswitch
//
//  Created by Daniel Hjärtström on 2016-11-30.
//  Copyright © 2016 Daniel Hjärtström. All rights reserved.
//

import UIKit

class PresentationView: UIView {

    init(frame: CGRect, question: String, index: Int) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.white
        
        UIGraphicsPushContext(Singleton.sharedInstance.pages[index] as! CGContext)
        
        self.setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createLabel(question: String) {
    
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 60))
        label.numberOfLines = 0
        label.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        label.textAlignment = .center
        label.text = question
        label.textColor = UIColor.white
        self.addSubview(label)
    
    }
}
