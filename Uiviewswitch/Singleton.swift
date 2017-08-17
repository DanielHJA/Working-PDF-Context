//
//  Singleton.swift
//  Uiviewswitch
//
//  Created by Daniel Hjärtström on 2016-11-30.
//  Copyright © 2016 Daniel Hjärtström. All rights reserved.
//

import UIKit

class Singleton: NSObject {
    
        static let sharedInstance = Singleton()
        var questions: [String] = []
        var pages: [CGPDFPage] = []
        var document: CGPDFDocument?
    
        private override init(){
    
    }
}

