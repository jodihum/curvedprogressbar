//
//  ViewController.swift
//  CurvedProgressBar
//
//  Created by Jodi Humphreys on 23/09/2019.
//  Copyright © 2019 Jhoom Technologies. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private struct Constants {
        static let minimumValue: Int = 15
        static let maximumValue: Int = 85
        
        static let trackArcWidth: CGFloat = 17
        static let progressArcWidth: CGFloat = 18
        
        static let angleOffset: CGFloat = 0
        
        static let font = UIFont.systemFont(ofSize: 20)
        
        static let trackColor = UIColor.purple
        static let progressColor = UIColor.green
        static let textColor = UIColor.blue
        static let shadowColor = UIColor(white: 0, alpha: 0.4)
        
    }
    
    var curvedProgressBar: CurvedProgressBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add default bar using default values
        addDefaultProgress(frame: CGRect(x: 80, y: 50, width: 250, height: 400), score: 50)
        
        // add progress bar using custom colors etc
        addProgress(frame: CGRect(x: 57, y: 400, width: 300, height: 300), score: 10)
        
        // change score of existing progress bar
        curvedProgressBar?.changeScore(score: 50)
    
    }
    
    // add progress bar using default values
    func addDefaultProgress(frame: CGRect, score: Int) {
        let defaultProgressView = CurvedProgressBar(frame: frame,
                                                     score: score)
        view.addSubview(defaultProgressView)
        
    }
    
    // add progress bar using custom colors etc
    func addProgress(frame: CGRect, score: Int) {
        curvedProgressBar = CurvedProgressBar(frame: frame,
                                        score: score,
                                        minimumValue: Constants.minimumValue,
                                        maximumValue: Constants.maximumValue,
                                        trackColor: Constants.trackColor,
                                        progressColor: Constants.progressColor,
                                        textColor: Constants.textColor,
                                        shadowColor: Constants.shadowColor,
                                        angleOffset: Constants.angleOffset,
                                        trackArcWidth: Constants.trackArcWidth,
                                        progressArcWidth: Constants.progressArcWidth,
                                        font: Constants.font)
        if let pv = curvedProgressBar {
            view.addSubview(pv)
        }
    }
    



}

