//
//  CurvedProgressBar.swift
//
//  Created by Jodi Humphreys on 29/08/2019.
//  Copyright © 2019 Jhoom Technologies. All rights reserved.
//

import UIKit

class CurvedProgressBar: UIView {
    private struct Constants {
 
        static let shadowOffset: CGFloat = 10 // to make sure there is room for shadow

        static let lineWidth: CGFloat = 2.0
        static var halfOfLineWidth: CGFloat {
            return lineWidth / 2
        }
    }

    private var score: Int = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    private var minimumValue: Int
    private var maximumValue: Int
    
    private var startAngle: CGFloat
    private var endAngle: CGFloat
    private var trackArcWidth: CGFloat
    private var progressArcWidth: CGFloat
    
    private var trackColor: UIColor
    private var progressColor: UIColor
    private var textColor: UIColor
    private var shadowColor: UIColor
    
    private var font: UIFont

    init(frame: CGRect,
         score: Int,
         minimumValue: Int = 0,
         maximumValue: Int = 100,
         trackColor: UIColor = UIColor.darkGray,
         progressColor: UIColor = UIColor.blue,
         textColor: UIColor = UIColor.black,
         shadowColor: UIColor = UIColor(white: 0, alpha: 0.2),
         angleOffset: CGFloat = .pi / 4,
         trackArcWidth: CGFloat = 12,
         progressArcWidth: CGFloat = 13,
         font: UIFont = UIFont.systemFont(ofSize: 15)) {
        
        self.score = score
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.trackColor = trackColor
        self.progressColor = progressColor
        self.textColor = textColor
        self.shadowColor = shadowColor
        self.startAngle = .pi - angleOffset
        self.endAngle = angleOffset
        self.trackArcWidth = trackArcWidth
        self.progressArcWidth = progressArcWidth
        self.font = font

        
        super.init(frame: frame)
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.saveGState()

        context.setShadow(
            offset: CGSize(width: 3, height: 3),
            blur: 3.0,
            color: shadowColor.cgColor
        )

        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radiusDiff = progressArcWidth - trackArcWidth
        let radius: CGFloat = min(bounds.width - Constants.shadowOffset, bounds.height - Constants.shadowOffset)

        let baseMinorRadius = trackArcWidth / 2 - Constants.halfOfLineWidth
        let progressMinorRadius = progressArcWidth / 2 - Constants.halfOfLineWidth

        makeArc(startAngle: startAngle, endAngle: endAngle, color: trackColor, radius: radius - radiusDiff, minorRadius: baseMinorRadius, center: center, addLabels: true, arcWidth: trackArcWidth)

        let angleDifference: CGFloat = 2 * .pi - startAngle + endAngle
        let unitArcLength = angleDifference / CGFloat(maximumValue-minimumValue)
        let outlineEndAngle = unitArcLength * CGFloat(score) + startAngle

        context.restoreGState()

        // no shadow on this one
        makeArc(startAngle: startAngle, endAngle: outlineEndAngle, color: progressColor, radius: radius, minorRadius: progressMinorRadius, center: center, addLabels: false, arcWidth: progressArcWidth)
    }

    func changeScore(score: Int) {
        self.score = score
    }
    
    private func mid(firstPoint: CGPoint, secondPoint: CGPoint) -> CGPoint {
        var midPoint = CGPoint()
        midPoint.x = (firstPoint.x + secondPoint.x) / 2
        midPoint.y = (firstPoint.y + secondPoint.y) / 2
        return midPoint
    }

    private func angle(center: CGPoint, point: CGPoint, radius: CGFloat) -> CGFloat {
        let firstPoint = startingPoint(center: center, radius: radius)
        let vector1 = CGVector(dx: firstPoint.x - center.x, dy: firstPoint.y - center.y)
        let vector2 = CGVector(dx: point.x - center.x, dy: point.y - center.y)

        let angle = atan2(vector2.dy, vector2.dx) - atan2(vector1.dy, vector1.dx)
        return angle
    }

    private func startingPoint(center: CGPoint, radius: CGFloat) -> CGPoint {
        var startingPoint = CGPoint()
        startingPoint.x = center.x + radius
        startingPoint.y = center.y
        return startingPoint
    }

    private func makeArc(startAngle: CGFloat, endAngle: CGFloat, color: UIColor, radius: CGFloat, minorRadius: CGFloat, center: CGPoint, addLabels: Bool, arcWidth: CGFloat) {
        // draw the outer arc
        let outlinePath = UIBezierPath(arcCenter: center,
                                       radius: radius / 2 - Constants.halfOfLineWidth,
                                       startAngle: startAngle,
                                       endAngle: endAngle,
                                       clockwise: true)

        let point2 = outlinePath.currentPoint
        let reversePath = outlinePath.reversing()
        let point1 = reversePath.currentPoint

        // for getting points only - don't draw
        let innerArc = UIBezierPath(arcCenter: center,
                                    radius: radius / 2 - arcWidth + Constants.halfOfLineWidth,
                                    startAngle: endAngle,
                                    endAngle: startAngle,
                                    clockwise: false)

        let point4 = innerArc.currentPoint
        let reversePathInnerArc = innerArc.reversing()
        let point3 = reversePathInnerArc.currentPoint

        // draw first end semicircle
        addCircularEdge(to: outlinePath, firstPoint: point2, secondPoint: point3, radius: minorRadius)

        // draw innerArc
        outlinePath.addArc(withCenter: center,
                           radius: radius / 2 - arcWidth + Constants.halfOfLineWidth,
                           startAngle: endAngle,
                           endAngle: startAngle,
                           clockwise: false)

        // draw second end semicircle
        addCircularEdge(to: outlinePath, firstPoint: point4, secondPoint: point1, radius: minorRadius)

        outlinePath.close()

        color.setStroke()
        color.setFill()

        outlinePath.lineWidth = Constants.lineWidth
        outlinePath.stroke()
        outlinePath.fill()

        if addLabels {
            var startPoint  = point1
            startPoint.y += arcWidth
            if endAngle > .pi/6 {
                startPoint = point(from: startAngle, by: .pi / -32, center: center, radius: radius / 2 - arcWidth + Constants.halfOfLineWidth)
            }
            addValueLabel(view: self, value: minimumValue, point: startPoint, color: textColor, shiftLeft: false)

            var endPoint  = point2
            endPoint.y += arcWidth
            if endAngle > .pi/6 {
                 endPoint = point(from: endAngle, by: .pi / 32, center: center, radius: radius / 2 - arcWidth + Constants.halfOfLineWidth)
            }
            addValueLabel(view: self, value: maximumValue, point: endPoint, color: textColor, shiftLeft: true)
        }
    }

    private func addCircularEdge(to path: UIBezierPath, firstPoint: CGPoint, secondPoint: CGPoint, radius: CGFloat) {
        let midpoint = mid(firstPoint: firstPoint, secondPoint: secondPoint)
        let firstCircleStartAngle = angle(center: midpoint, point: firstPoint, radius: radius)
        let firstCircleEndAngle = angle(center: midpoint, point: secondPoint, radius: radius)

        path.addArc(withCenter: midpoint,
                    radius: radius,
                    startAngle: firstCircleStartAngle,
                    endAngle: firstCircleEndAngle,
                    clockwise: true)
    }

    private func point(from startAngle: CGFloat, by angle: CGFloat, center: CGPoint, radius: CGFloat) -> CGPoint {
        let arc = UIBezierPath(arcCenter: center,
                               radius: radius,
                               startAngle: startAngle,
                               endAngle: startAngle + angle,
                               clockwise: false)
        return arc.currentPoint
    }

    private func addValueLabel(view: UIView, value: Int, point: CGPoint, color: UIColor, shiftLeft: Bool) {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "\(value)"
        label.font = font
        label.textColor = color
        label.sizeToFit()

        let width = label.bounds.width
        let height = label.bounds.height
        var newX = point.x
        if shiftLeft {
            newX -= (3 * width / 4)
        }
        let newY = point.y

        let newFrame = CGRect(x: newX, y: newY, width: width, height: height)
        label.frame = newFrame
        view.addSubview(label)
    }
}
