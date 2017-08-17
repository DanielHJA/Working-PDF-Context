//
//  presentationViewController.swift
//  Uiviewswitch
//
//  Created by Daniel Hjärtström on 2016-11-30.
//  Copyright © 2016 Daniel Hjärtström. All rights reserved.
//

import UIKit

enum TypeOfView {

    case initial
    case forward
    case backward

}

class PresentationViewController: UIViewController, UIScrollViewDelegate {

    let questionsArray = Singleton.sharedInstance.questions
    var displayedView: UIView?
    let animationManager: AnimationManager = AnimationManager()
    var canChangeView: Bool = true
    var scrollview: UIScrollView?
    var index: Int = 0 {
    
        didSet {
        
            self.navigationItem.title = "Question \(index+1)"
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        scrollview = UIScrollView(frame: self.view.frame)
        scrollview?.delegate = self
        scrollview?.maximumZoomScale = 5.0
        self.view.addSubview(scrollview!)
        
        let view = returnViewOfType(type: .initial)
        
        scrollview?.addSubview(view)
        displayedView = view
        
        let leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeToNavigate(gesture:)))
            leftSwipeRecognizer.direction = .left
        let rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeToNavigate(gesture:)))
            rightSwipeRecognizer.direction = .right
        
        self.view.addGestureRecognizer(leftSwipeRecognizer)
        self.view.addGestureRecognizer(rightSwipeRecognizer)
        
    }
    
    func didSwipeToNavigate(gesture: UISwipeGestureRecognizer) {
    
        if (gesture.direction == .left){
        
            navigateForward()
            
        }
        
        if (gesture.direction == .right){
            
            navigateBack()
            
        }
        
    }
    
    func returnViewOfType(type: TypeOfView) -> UIView {
        
        let frame: CGRect
        let question = questionsArray[index]
        
        switch type {
        
        case .initial:
            
            //frame = CGRect(x: 25, y: 60, width: self.view.frame.width - 50, height: self.view.frame.height - 200)
            frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
        case .forward:
            
           // frame = CGRect(x: self.view.frame.width, y: 60, width: self.view.frame.width - 50, height: self.view.frame.height - 200)
            frame = CGRect(x: self.view.frame.width, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
        case .backward://Fix constraints
            
        //    frame = CGRect(x: -self.view.frame.width, y: 60, width: self.view.frame.width - 50, height: self.view.frame.height - 200)
            frame = CGRect(x: -self.view.frame.width, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
        }
        
        let view = PDFPageContent(pdfDocument: Singleton.sharedInstance.document!, page: index, password: nil)//PDFContextView(frame: frame)
        
        return view//PresentationView(frame: frame, question: question, index: index)
    }
    
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        navigateBack()
    }
    
    func navigateBack(){
    
        if canChangeView {
            
            index -= 1
            
            if self.navigationItem.rightBarButtonItem?.isEnabled == false  {
                
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                
            }
            
            if index > -1 {
                
                // navigationHandler(viewType: .backward, viewToRemoveEndPosition: self.view.frame.width + (self.displayedView?.frame.width)!, viewToAddEndPosition: self.displayedView!.frame.width / 2 + 25)
                
                navigationHandler(viewType: .backward, viewToRemoveEndPosition: self.view.frame.width + (self.displayedView?.frame.width)!, viewToAddEndPosition: (self.displayedView?.frame.size.width)! / 2)
            }
                
            else {
                
                unwind()
                
            }
        }
    }
    
    @IBAction func forward(_ sender: UIBarButtonItem) {
        navigateForward()
    }
    
    func navigateForward() {
    
        self.scrollview?.zoomScale = 1.0
        
        if canChangeView {
            
            index += 1
            
            if index == questionsArray.count - 1 {
                
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                
            }
            
            if index < questionsArray.count {
                
                // navigationHandler(viewType: .forward, viewToRemoveEndPosition: -self.view.frame.width, viewToAddEndPosition: self.displayedView!.frame.width / 2 + 25)
                
                navigationHandler(viewType: .forward, viewToRemoveEndPosition: -self.view.frame.width, viewToAddEndPosition: (self.displayedView?.frame.size.width)! / 2)
            }
        }
    }
    
    func navigationHandler(viewType: TypeOfView, viewToRemoveEndPosition: CGFloat, viewToAddEndPosition: CGFloat) {
    
        self.canChangeView = false
        
        let view = returnViewOfType(type: viewType)
        self.scrollview!.addSubview(view)
        
        animationManager.animate(view: self.displayedView!, time: 0.4, animateTo: viewToRemoveEndPosition) {
         
            self.displayedView?.removeFromSuperview()
            self.displayedView = view
            
            self.animationManager.animateWithSpring(view: self.displayedView!, time: 1, animateTo: viewToAddEndPosition)
            
            self.canChangeView = true
        }
    }

    @IBAction func goBack(_ sender: UILongPressGestureRecognizer) {
        unwind()
    }
    
    func unwind() {
        self.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.displayedView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}
