//
//  ARView.swift
//  ARVideoKit
//
//  Created by Ahmed Bekhit on 10/14/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import UIKit
import ARKit

/**
 A class that configures the Augmented Reality View orientations.
 
 - Author: Ahmed Fathi Bekhit
 * [Github](http://github.com/AFathi)
 * [Website](http://ahmedbekhit.com)
 * [Twitter](http://twitter.com/iAFapps)
 * [Email](mailto:me@ahmedbekhit.com)
 */
@available(iOS 11.0, *)
@objc public class ARView: NSObject {
    private weak var parentVC: UIViewController?
    private var inputViewOrientation:[ARInputViewOrientation] = []
    
    /// An array of `ARInputViewOrientation` objects that allow customizing the accepted orientations in a `UIViewController` that contains Augmented Reality scenes.
    public var inputViewOrientations: [ARInputViewOrientation] {
        get{
            return inputViewOrientation
        }
        set{
            if newValue.count == 0 {
                inputViewOrientation = [.portrait]
            } else {
                inputViewOrientation = newValue
            }
        }
    }
    
    private var ivom: ARInputViewOrientationMode = .auto
    /// An object that allow customizing which subviews will rotate in a `UIViewController` that contains Augmented Reality scenes.
    public var inputViewOrientationMode: ARInputViewOrientationMode {
        get{
            return ivom
        }
        set{
            ivom = newValue
        }
    }
    
    
    @objc init?(ARSceneKit: ARSCNView) {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotate), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        //let value = UIInterfaceOrientation.portrait.rawValue
        //UIDevice.current.setValue(value, forKey: "orientation")
        
        //ViewAR.orientation = .portrait
        
        guard let vc = ARSceneKit.parent else {
            return
        }
        
        parentVC = vc
    }
    
    @objc init?(ARSpriteKit: ARSKView) {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotate), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        //let value = UIInterfaceOrientation.portrait.rawValue
        //UIDevice.current.setValue(value, forKey: "orientation")
        
        //ViewAR.orientation = .portrait
        guard let vc = ARSpriteKit.parent else {
            return
        }
        parentVC = vc
    }
    
    @objc init?(SceneKit: SCNView) {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotate), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        //let value = UIInterfaceOrientation.portrait.rawValue
        //UIDevice.current.setValue(value, forKey: "orientation")
        
        //ViewAR.orientation = .portrait
        
        guard let vc = SceneKit.parent else {
            return
        }
        
        parentVC = vc
    }
    
    @objc private func deviceDidRotate() {
        guard var views = parentVC?.view.subviews else {
            return
        }

        switch inputViewOrientationMode {
        case .auto:
            views = views.filter { !$0.isARView && $0.isButton }
        case .all:
            views = views.filter { !$0.isARView }
        case .manual(let subviews):
            views = subviews.filter { !$0.isARView }
        case .disabled:
            views = []
        }

        let rotationAngle: CGFloat
        if !angleEnabled {
            rotationAngle = 0
        } else {
            rotationAngle = getRotationAngle()
        }
        
        for view in views {
            UIView.animate(withDuration: 0.2, animations: {
                view.transform = CGAffineTransform(rotationAngle: rotationAngle)
            })
        }
    }

    private var angleEnabled: Bool {
        inputViewOrientations.contains(where: { $0.rawValue == UIDevice.current.orientation.rawValue })
    }

    private func getRotationAngle() -> CGFloat {
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            return -.pi/2
        case .landscapeRight:
            return .pi/2
        case .faceUp, .faceDown, .portraitUpsideDown:
            return 0
        default:
            return 0
        }
    }
}
