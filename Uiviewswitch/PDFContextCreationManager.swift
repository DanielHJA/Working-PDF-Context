//
//  PDFContextCreationManager.swift
//  Uiviewswitch
//
//  Created by Daniel Hjärtström on 2017-03-16.
//  Copyright © 2017 Daniel Hjärtström. All rights reserved.
//

import UIKit
import QuartzCore

class PDFContextCreationManager: NSObject {

    func returnContextForPDF() -> [CGPDFPage] {
    
        let file: URL = Bundle.main.url(forResource: "enoch", withExtension: "pdf")!
        
        let pdf: CGPDFDocument? = CGPDFDocument(file.absoluteURL as CFURL)
        
        let pages: Int = pdf!.numberOfPages

        let data: NSMutableData? = NSMutableData()
    
        var pdfContextArray: [CGPDFPage] = []
        
        for i in (1..<pages+1) {
                    
            let currentPage: CGPDFPage = pdf!.page(at: i)!
       
            pdfContextArray.append(currentPage)
        
        }
        
        return pdfContextArray
    }
    
    
    func returnPDFDocumentRef() -> CGPDFDocument {
        
        let file: URL = Bundle.main.url(forResource: "enoch", withExtension: "pdf")!
        
        let pdf: CGPDFDocument? = CGPDFDocument(file.absoluteURL as CFURL)
        
        return pdf!
    }
}












