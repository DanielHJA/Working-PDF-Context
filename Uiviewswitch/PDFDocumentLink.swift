//
//  PDFDocumentLink.swift
//  Pods
//
//  Created by Ricardo Nunez on 11/11/16.
//
//

import UIKit

internal class PDFDocumentLink {
    
    let rect: CGRect
    let dictionary: CGPDFDictionaryRef
    var url: URL?
    
    init(rect: CGRect, dictionary: CGPDFDictionaryRef, url: URL?) {

        self.rect = rect
        self.dictionary = dictionary
        self.url = url
    }
}
