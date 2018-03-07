//
//  PBActivityView.swift
//  PregBuddy
//
//  Created by Bibin P Sebastian on 3/7/18.
//  Copyright © 2018 Bibin P Sebastian. All rights reserved.
//

import UIKit

class PBActivityView{
    
    let imageView = UIImageView(image: UIImage(named:"babyPic"))
    let backGroundView = UIView()
    
    func startAnimating(onView:UIView? = nil) {
        
        if let parentView = onView ?? (UIApplication.shared.delegate as! AppDelegate).window {
            self.backGroundView.backgroundColor = UIColor.white
            self.backGroundView.alpha = 0.4
            self.backGroundView.frame = parentView.frame
            self.imageView.frame = CGRect(x: parentView.center.x - 30, y: parentView.center.y - 30, width: 60, height: 60)
            parentView.addSubview(backGroundView)
            parentView.addSubview(imageView)
            self.setUpAnimation(in: imageView.layer)
        
        }
        
    }
    
    func stopanimating() {
        
        self.backGroundView.removeFromSuperview()
        self.imageView.removeFromSuperview()
        
    }
    
    func setUpAnimation(in layer: CALayer) {
        let duration: CFTimeInterval = 1
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.7, -0.13, 0.22, 0.86)
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")

        scaleAnimation.keyTimes = [0, 0.5, 1]
        scaleAnimation.timingFunctions = [timingFunction, timingFunction]
        scaleAnimation.values = [1, 0.6, 1]
        scaleAnimation.duration = duration
        
        let rotateAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        
        rotateAnimation.keyTimes = [0, 0.5, 1]
        rotateAnimation.timingFunctions = [timingFunction, timingFunction]
        rotateAnimation.values = [0, Double.pi/4, 0]
        rotateAnimation.duration = duration
        
        // Animation
        let animation = CAAnimationGroup()
        
        animation.animations = [rotateAnimation,scaleAnimation]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: "animation")
    }
    
}
