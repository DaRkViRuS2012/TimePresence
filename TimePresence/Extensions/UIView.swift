//
//  UIView.swift
//  Wardah
//
//  Created by Dania on 6/13/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import UIKit

class ClosureSleeve {
    let closure: ()->()
    
    init (_ closure: @escaping ()->()) {
        self.closure = closure
    }
    
    @objc func invoke () {
        closure()
    }
}

extension UIView {
    /// add **touch up selector** to any **view**
    ///
    /// Usage:
    ///
    ///     view.tapAction{print("View tapped!")}
    ///
    /// - Parameters: 
    ///     - closure: The block to be excuted when tapping.
    func tapAction( _ closure: @escaping ()->()){
        self.isUserInteractionEnabled = true
        let sleeve = ClosureSleeve(closure)
        objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: sleeve, action: #selector(ClosureSleeve.invoke))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
    }
    
    /// Fade the current view in
    func fadeIn() {
        // Move our fade out code from earlier
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0 // Instead of a specific instance of, say, birdTypeLabel, we simply set [thisInstance] (ie, self)'s alpha
        }, completion: nil)
    }
    
    /// Fade the current view out
    func fadeOut() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: nil)
    }
    
    
    // make view rounded 
    func makeRounded(){
    
        self.cornerRadius = self.frame.height / 2
    }
    
    func addShaddow(color:UIColor = .black){
        
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 2
        //self.layer.shadowPath = UIBezierPath(rect: CGRect(x: -3, y: 5, width: self.frame.width, height: self.frame.height)).cgPath
      //  self.layer.shouldRasterize = true
        
    }
    
    
//    /// set corner radius from interface builder
//    @IBInspectable var cornerRadius: CGFloat {
//        get {
//            return layer.cornerRadius
//        }
//        set {
//            layer.cornerRadius = newValue
//            layer.masksToBounds = newValue > 0
//        }
//    }
//    
//    /// set border width from interface builder
//    @IBInspectable var borderWidth: CGFloat {
//        get {
//            return layer.borderWidth
//        }
//        set {
//            layer.borderWidth = newValue
//            layer.masksToBounds = newValue > 0
//        }
//    }
//    
//    /// set border color from interface builder
//    @IBInspectable var borderColor: UIColor {
//        get {
//            return UIColor.init(cgColor: layer.borderColor!)
//        }
//        set {
//            layer.borderColor = newValue.cgColor
//        }
//    }

}

enum AnimationType {
    case animateInFromBottom
    case animateInFromRight
    case animateInFromLeft
    case animateOutToBottom
    case animateOutToRight
    case animateOutToLeft
}

extension UIView {
    
    public static let animDurationLong = 1.0
    public static let animDurationShort = 0.5
    
    private static let animDist: CGFloat = 100.0
    
    func animateIn(mode: AnimationType, delay: CFTimeInterval) {
        var initialTransform: CGAffineTransform = CGAffineTransform.identity
        var finalTransform: CGAffineTransform = CGAffineTransform.identity
        let initialAlpha: CGFloat
        let finalAlpha: CGFloat
        
        switch mode {
        case .animateInFromBottom:
            initialTransform = CGAffineTransform(translationX: 0, y: UIView.animDist)
        case .animateInFromRight:
            initialTransform = CGAffineTransform(translationX: UIView.animDist, y: 0)
        case .animateInFromLeft:
            initialTransform = CGAffineTransform(translationX: -UIView.animDist, y: 0)
        case .animateOutToBottom:
            finalTransform = CGAffineTransform(translationX: 0, y: UIView.animDist)
        case .animateOutToRight:
            finalTransform = CGAffineTransform(translationX: UIView.animDist, y: 0)
        case .animateOutToLeft:
            finalTransform = CGAffineTransform(translationX: -UIView.animDist, y: 0)
        }
        
        switch mode {
        case .animateInFromLeft,
             .animateInFromRight,
             .animateInFromBottom:
            finalTransform = CGAffineTransform.identity
            initialAlpha = 0
            finalAlpha = 1
        case .animateOutToLeft,
             .animateOutToRight,
             .animateOutToBottom:
            initialTransform = CGAffineTransform.identity
            initialAlpha = 1
            finalAlpha = 0
        }
        
        self.alpha = initialAlpha
        self.transform = initialTransform
        UIView.animate(withDuration: 1, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            self.alpha = finalAlpha
            self.transform = finalTransform
        }) { _ in
            
        }
    }
}
