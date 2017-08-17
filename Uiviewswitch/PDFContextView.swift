//
//  PDFContextView.swift
//  Uiviewswitch
//
//  Created by Daniel Hjärtström on 2017-03-16.
//  Copyright © 2017 Daniel Hjärtström. All rights reserved.
//

import UIKit


class PDFContextView: UIView {
    
    var index: Int = 0
    var link: URL?

    override func draw(_ rect: CGRect) {
        
        let page = Singleton.sharedInstance.pages[index]
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.clear(bounds)
        
        context?.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        context?.fill(bounds)
        
        context?.translateBy(x: 0.0, y: bounds.size.height);
        context?.scaleBy(x: 1.0, y: -1.0);
        
        var cropBox = page.getBoxRect(.cropBox)
        cropBox = CGRect(x: cropBox.origin.x, y: cropBox.origin.y, width: ceil(cropBox.width), height: ceil(cropBox.height))
        
        let scaleFactor = min(bounds.size.width/cropBox.size.width, bounds.size.height/cropBox.size.height)
        let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        let scaledInnerRect = cropBox.applying(scale)
        let translate = CGAffineTransform(translationX: ((bounds.size.width - scaledInnerRect.size.width) / 2) - scaledInnerRect.origin.x, y: ((bounds.size.height - scaledInnerRect.size.height) / 2) - scaledInnerRect.origin.y)
        let concat = translate.scaledBy(x: scaleFactor, y: scaleFactor)
        
        context?.concatenate(concat)
        
        let clipRect = cropBox
        context?.addRect(clipRect)
        context?.clip()
        
        context?.drawPDFPage(page)
        
        UIGraphicsEndPDFContext()
        
        getLinksFromPDF()
    }

    
    
    func getLinksFromPDF() {
        
        let page = Singleton.sharedInstance.pages[index]

        let pageDictionary: CGPDFDictionaryRef = page.dictionary!
        var outPutArray: CGPDFArrayRef? //= nil
        
        CGPDFDictionaryGetArray(pageDictionary, "Annots", &outPutArray)

        guard outPutArray != nil else {
            return
        }
        
        let count = CGPDFArrayGetCount(outPutArray!)
        var rectCount: Int = 0
        var rectForLink: CGRect?
        var uriString: String = ""
        var pageRotate: CGPDFInteger = 0;
        var uri: String = ""
        var pageRect: CGRect?
        
        for i in (0..<count) {
        
            var aDictObj: CGPDFObjectRef?
            
            if(!CGPDFArrayGetObject(outPutArray!, i, &aDictObj)) {
                return;
            }
            
            var annotDict: CGPDFDictionaryRef?
            
            if(!CGPDFObjectGetValue(aDictObj!, .dictionary, &annotDict)) {
                return;
            }
            
            var aDict: CGPDFDictionaryRef?
            if(!CGPDFDictionaryGetDictionary(annotDict!, "A", &aDict)) {
                return;
            }
            
            var uriStringRef: CGPDFStringRef?
            if(!CGPDFDictionaryGetString(aDict!, "URI", &uriStringRef)) {
                return;
            }
            
            var rectArray: CGPDFArrayRef?
            if(!CGPDFDictionaryGetArray(annotDict!, "Rect", &rectArray)) {
                return;
            }
            
            rectCount = CGPDFArrayGetCount(rectArray!)
            var coords = [CGPDFReal](repeating: CGPDFReal(), count: 4)

            for k in 0..<rectCount {
                
                var rectObj: CGPDFObjectRef?
                if !CGPDFArrayGetObject(rectArray!, k, &rectObj) {
                    return
                }
                
                var coord: CGFloat? = 0.0
                if !CGPDFObjectGetValue(rectObj!, .real, &coord) {
                    return
                }
                
                coords[k] = coord!
                coord = 0.0
            }
            
            uriString = String(describing: CGPDFStringGetBytePtr(uriStringRef!))
            
            let getPDFStringAsString: CFString = CGPDFStringCopyTextString(uriStringRef!)!
            uri = (getPDFStringAsString as? String)!
            link = URL(string: uri)
            
            //rectForLink = CGRect(x: coords[0], y: coords[1], width: coords[2], height: coords[3])
            
            /********************Size and position*********************/
            
            pageRect = page.getBoxRect(.mediaBox).integral
            
           /* var PDFHeight: CGFloat = (pageRect?.size.height)!
            let PDFWidth: CGFloat = (pageRect?.size.width)!
           
            var iOSWidth: CGFloat = self.frame.size.width
            var iOSHeight: CGFloat = self.frame.size.height
           
            var multiplierWidth = iOSWidth / PDFWidth
            var multiplierheight = iOSHeight / PDFHeight
            
            var multiplierX = coords[0] * multiplierWidth
            var multiplierY = PDFHeight * multiplierheight - coords[1] * multiplierheight
            
            var linkRectWidth = coords[2] * multiplierWidth
            let linkRectHeight = coords[3] * multiplierheight
           
            rectForLink = CGRect(x: multiplierX, y: multiplierY, width: linkRectWidth, height: 10)*/
            
            // CGRectMake(coords[0],coords[3],coords[2]-coords[0],coords[3]-coords[1]);
            
            let PDFHeight: CGFloat = (pageRect?.size.height)!
            let PDFWidth: CGFloat = (pageRect?.size.width)!
            
            let iOSWidth: CGFloat = self.frame.size.width
            let iOSHeight: CGFloat = self.frame.size.height
            
            let multiplierWidth = iOSWidth / PDFWidth
            let multiplierheight = PDFHeight / iOSHeight
            
            rectForLink = CGRect(x: coords[0] * multiplierWidth, y: PDFHeight * 0.82 - coords[3] * 0.82, width: (coords[2] - coords[0]) * multiplierWidth, height: (coords[3]-coords[1]) * multiplierheight)
           /* CGPDFDictionaryGetInteger(pageDictionary, "Rotate", &pageRotate)
            
            pageRect = page.getBoxRect(.mediaBox).integral

            if pageRotate == 90 || pageRotate == 270 {
                let temp: CGFloat = pageRect!.size.width
                pageRect?.size.width = (pageRect?.size.height)!
                pageRect?.size.height = temp
            }
            
            rectForLink?.size.width = (rectForLink?.size.width)! - (rectForLink?.origin.x)! + (rectForLink?.origin.x)! / 6
            rectForLink?.size.height = (rectForLink?.size.height)! - (rectForLink?.origin.y)!
            
            var trans = CGAffineTransform.identity
            trans = trans.translatedBy(x: 0, y: (pageRect?.size.height)! + coords[3] - self.frame.size.height)
            trans = trans.scaledBy(x: 0.5, y: -1.077)
            rectForLink = rectForLink?.applying(trans)
            
            rectForLink?.size.height -= (rectForLink?.size.height)! / 2*/
            
            var button = UIButton(frame: rectForLink!)
            button.backgroundColor = UIColor(red: CGFloat(0.0), green: CGFloat(122.0 / 255.0), blue: CGFloat(1.0), alpha: CGFloat(0.6))
            button.addTarget(self, action: #selector(self.openLink), for: .touchUpInside)
            self.addSubview(button)
        }
    }
    
    func openLink(){
    
        UIApplication.shared.open(link!, options: [:], completionHandler: nil)
        
    }
}
