//
//  AnimationManager.swift
//  Uiviewswitch
//
//  Created by Daniel Hjärtström on 2016-11-30.
//  Copyright © 2016 Daniel Hjärtström. All rights reserved.
//

import UIKit

class AnimationManager: NSObject {
    
    func animate(view: UIView, time: Double, animateTo: CGFloat, completion: @escaping ()->()) {
        
        UIView.animate(withDuration: time, animations: {
            
            view.center.x = animateTo
            
        }) { (Bool) in
            
            completion()
            
        }
    }
    
    func animateWithSpring(view: UIView, time: Double, animateTo: CGFloat){
        
        UIView.animate(withDuration: time, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [], animations: {
            
            view.center.x = animateTo
            
            }, completion: { (Bool) in
                
                
        })
    }
}
