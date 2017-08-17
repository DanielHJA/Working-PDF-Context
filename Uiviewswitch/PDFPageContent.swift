//
//  PDFPageContent.swift
//  Pods
//
//  Created by Chris Anderson on 3/5/16.
//
//

import UIKit

internal class PDFPageContent: UIView {
   
    private let pdfDocRef: CGPDFDocument
    private let pdfPageRef: CGPDFPage?
    private let pageAngle: Int /// 0, 90, 180, 270
    private var links: [PDFDocumentLink] = []
    private var pageWidth: CGFloat = 0.0
    private var pageHeight: CGFloat = 0.0
    private var pageOffsetX: CGFloat = 0.0
    private var pageOffsetY: CGFloat = 0.0
    private var page: Int = 0
    
    var cropBoxRect: CGRect
    var viewRect: CGRect = CGRect.zero
    
    //MARK: - Init
    init(pdfDocument: CGPDFDocument, page: Int, password: String?) {
        pdfDocRef = pdfDocument
        /// Limit the page
        let pages = pdfDocRef.numberOfPages
        var page = page
        if page < 1 {
            page = 1
        }
        if page > pages {
            page = pages
        }
        
        guard let pdfPageRef = pdfDocument.page(at: page) else { fatalError() }
        self.pdfPageRef = pdfPageRef
        
        cropBoxRect = pdfPageRef.getBoxRect(.cropBox)
        let mediaBoxRect = pdfPageRef.getBoxRect(.mediaBox)
        let effectiveRect = cropBoxRect.intersection(mediaBoxRect)
        
        /// Determine the page angle
        pageAngle = Int(pdfPageRef.rotationAngle)
        
        switch pageAngle {
        case 90, 270:
            self.pageWidth = effectiveRect.size.height / 2
            self.pageHeight = effectiveRect.size.width / 2
            pageOffsetX = effectiveRect.origin.y
            pageOffsetY = effectiveRect.origin.x
        case 0, 180:
            self.pageWidth = effectiveRect.size.width / 2
            self.pageHeight = effectiveRect.size.height / 2
            pageOffsetX = effectiveRect.origin.x
            pageOffsetY = effectiveRect.origin.y
        default:
            break
        }
        
        /// Round the size if needed
        var pageWidth = Int(self.pageWidth)
        var pageHeight = Int(self.pageHeight)
        
        if pageWidth % 2 != 0 {
            pageWidth -= 1
        }
        
        if pageHeight % 2 != 0 {
            pageHeight -= 1
        }
        
        viewRect.size = CGSize(width: CGFloat(pageWidth), height: CGFloat(pageHeight))
        
        /// Finish the init with sizes
        super.init(frame: viewRect)

        autoresizesSubviews = false
        isUserInteractionEnabled = true
        contentMode = .redraw
        autoresizingMask = UIViewAutoresizing()
        backgroundColor = UIColor.clear
        
        buildAnnotationLinksList()
    }
    
    convenience init(document: CGPDFDocument, page: Int) {
        self.init(pdfDocument: document, page: page, password: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func removeFromSuperview() {
        layer.delegate = nil
        super.removeFromSuperview()
    }
    
    //MARK: - Page Links Discovery
    
    private func highlightPageLinks() {

        guard links.count > 0 else { return }

        for i in (0..<links.count) {
        
            let button = UIButton(frame: links[i].rect)
            button.backgroundColor = UIColor(red: CGFloat(0.0), green: CGFloat(122.0 / 255.0), blue: CGFloat(1.0), alpha: CGFloat(0.5))
            button.addTarget(self, action: #selector(self.openLink), for: .touchUpInside)
            button.tag = i
            self.addSubview(button)
            
            addSubview(button)
        
        }
    }
    
    private func linkFromAnnotation(_ annotation: CGPDFDictionaryRef) -> PDFDocumentLink? {
        
        var annotationRectArray: CGPDFArrayRef? = nil
        
        guard CGPDFDictionaryGetArray(annotation, "Rect", &annotationRectArray) else { return nil }
        var lowerLeftX: CGPDFReal = 0.0
        var lowerLeftY: CGPDFReal = 0.0
        
        var upperRightX: CGPDFReal = 0.0
        var upperRightY: CGPDFReal = 0.0
        
        CGPDFArrayGetNumber(annotationRectArray!, 0, &lowerLeftX)
        CGPDFArrayGetNumber(annotationRectArray!, 1, &lowerLeftY)
        CGPDFArrayGetNumber(annotationRectArray!, 2, &upperRightX)
        CGPDFArrayGetNumber(annotationRectArray!, 3, &upperRightY)
        
        if lowerLeftX > upperRightX {
            let t = lowerLeftX
            lowerLeftX = upperRightX
            upperRightX = t
        }
        
        if lowerLeftY > upperRightY {
            let t = lowerLeftY
            lowerLeftY = upperRightY
            upperRightY = t
        }
        
        lowerLeftX -= pageOffsetX
        lowerLeftY -= pageOffsetY
        upperRightX -= pageOffsetX
        upperRightY -= pageOffsetY
        
        switch pageAngle {
        case 90:
            var swap = lowerLeftY
            lowerLeftY = lowerLeftX
            lowerLeftX = swap
            swap = upperRightY
            upperRightY = upperRightX
            upperRightX = swap
            break
        case 270:
            var swap = lowerLeftY
            lowerLeftY = lowerLeftX
            lowerLeftX = swap
            swap = upperRightY
            upperRightY = upperRightX
            upperRightX = swap
            
            lowerLeftX = 0.0 - lowerLeftX + pageWidth
            upperRightX = 0.0 - upperRightX + pageWidth
            break
        case 0:
            lowerLeftY = 0.0 - lowerLeftY + pageHeight
            upperRightY = 0.0 - upperRightY + pageHeight
            break
        default:
            break
        }
        
        let x = lowerLeftX
        let w = upperRightX - lowerLeftX
        let y = lowerLeftY
        let h = upperRightY - lowerLeftY
        
        let rect = CGRect(x: x, y: y, width: w, height: h * 0.7)
        
        return PDFDocumentLink(rect: rect, dictionary:annotation, url: nil)
    }
    
    private func buildAnnotationLinksList() {
        links = []
        var pageAnnotations: CGPDFArrayRef? = nil
        let pageDictionary: CGPDFDictionaryRef = pdfPageRef!.dictionary!
        
        if CGPDFDictionaryGetArray(pageDictionary, "Annots", &pageAnnotations) {
            for i in 0...CGPDFArrayGetCount(pageAnnotations!) {
                var annotationDictionary: CGPDFDictionaryRef? = nil
                guard CGPDFArrayGetDictionary(pageAnnotations!, i, &annotationDictionary) else { continue }
                    
                var annotationSubtype: UnsafePointer<Int8>? = nil
                guard CGPDFDictionaryGetName(annotationDictionary!, "Subtype", &annotationSubtype) else { continue }
                guard strcmp(annotationSubtype, "Link") == 0 else { continue }
                guard let documentLink: PDFDocumentLink = linkFromAnnotation(annotationDictionary!) else { continue }
                
                var aDictObj: CGPDFObjectRef?
                
                if(!CGPDFArrayGetObject(pageAnnotations!, i, &aDictObj)) {
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

                let getPDFStringAsString: CFString = CGPDFStringCopyTextString(uriStringRef!)!
                let uri = getPDFStringAsString as String
                
                documentLink.url = URL(string: uri)
                
                links.append(documentLink)
            }
        }
        self.highlightPageLinks()
    }

    func openLink(sender: UIButton){
    
        UIApplication.shared.open(links[sender.tag].url!, options: [:], completionHandler: nil)
    
    }

    override func draw(_ rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()
    
        ctx?.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        ctx?.fill((ctx?.boundingBoxOfClipPath)!)
        
        /// Translate for page
        ctx?.translateBy(x: 0.0, y: bounds.size.height)
        ctx?.scaleBy(x: 1.0, y: -1.0)
        ctx?.concatenate((pdfPageRef?.getDrawingTransform(.cropBox, rect: bounds, rotate: 0, preserveAspectRatio: true))!)
        
        /// Render the PDF page into the context
        ctx?.drawPDFPage(pdfPageRef!)
        
        UIGraphicsEndPDFContext()
    
        //self.frame = CGRect(x: (self.superview?.frame.midX)! - self.frame.width / 2, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    deinit {
        layer.contents = nil
        layer.delegate = nil
        layer.removeFromSuperlayer()
    }
}
