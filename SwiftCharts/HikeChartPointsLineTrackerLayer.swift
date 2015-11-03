//
//  HikeChartPointsLineTrackerLayer.swift
//  SwiftCharts
//
//  Created by Nicolas Klein on 02/11/15.
//  Copyright © 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

public struct HikeChartPointsLineTrackerLayerSettings {
    let thumbSize: CGFloat
    let thumbCornerRadius: CGFloat
    let thumbBorderWidth: CGFloat
    let thumbBGColor: UIColor
    let thumbBorderColor: UIColor
    let infoViewFontColor: UIColor
    let infoViewBackgroundColor: UIColor
    let infoViewLabelDefaultHeight: Int
    let infoViewLabelDefaultWidth: Int
    let infoViewLabelDefaultMargin: Int
    
    public init(
        thumbSize: CGFloat,
        thumbCornerRadius: CGFloat,
        thumbBorderWidth: CGFloat = 4,
        thumbBorderColor: UIColor = UIColor.blackColor(),
        thumbBGColor: UIColor = UIColor.whiteColor(),
        infoViewFontColor: UIColor = UIColor.blackColor(),
        infoViewBackgroundColor: UIColor = UIColor.blackColor().colorWithAlphaComponent(0.5),
        infoViewLabelDefaultHeight: Int = 18,
        infoViewLabelDefaultWidth: Int = 110,
        infoViewLabelDefaultMargin: Int = 4
        ) {
            self.thumbSize = thumbSize
            self.thumbCornerRadius = thumbCornerRadius
            self.thumbBorderWidth = thumbBorderWidth
            self.thumbBGColor = thumbBGColor
            self.thumbBorderColor = thumbBorderColor
            self.infoViewFontColor = infoViewFontColor
            self.infoViewBackgroundColor = infoViewBackgroundColor
            self.infoViewLabelDefaultHeight = infoViewLabelDefaultHeight
            self.infoViewLabelDefaultWidth = infoViewLabelDefaultWidth
            self.infoViewLabelDefaultMargin = infoViewLabelDefaultMargin
    }
}

class HikeChartPointsLineTrackerLayer<T: ChartPoint>: ChartPointsLayer<T> {
    
    var altitudes = [Double]()
    
    let dataSets: [HikeChartDataSet]
    
    private let lineColor: UIColor
    private let animDuration: Float
    private let animDelay: Float
    
    private let settings: HikeChartPointsLineTrackerLayerSettings
    
    private lazy var currentPositionLineOverlay: UIView = {
        let currentPositionLineOverlay = UIView()
        currentPositionLineOverlay.backgroundColor = UIColor.grayColor()
        currentPositionLineOverlay.alpha = 0
        return currentPositionLineOverlay
    }()
    
    private lazy var thumb: UIView = {
        let thumb = UIView()
        thumb.layer.cornerRadius = self.settings.thumbCornerRadius
        thumb.layer.borderWidth = self.settings.thumbBorderWidth
        thumb.layer.backgroundColor = UIColor.clearColor().CGColor
        thumb.layer.borderColor = self.settings.thumbBorderColor.CGColor
        thumb.alpha = 0
        return thumb
    }()
    
    private lazy var thumb2: UIView = {
        let thumb = UIView()
        thumb.layer.cornerRadius = self.settings.thumbCornerRadius
        thumb.layer.borderWidth = self.settings.thumbBorderWidth
        thumb.layer.backgroundColor = UIColor.clearColor().CGColor
        thumb.layer.borderColor = self.settings.thumbBorderColor.CGColor
        thumb.alpha = 0
        return thumb
    }()
    
    private var currentInfoLabelOverlays = [UILabel]()
    private let currentDistanceLabelOverlay: UILabel
    
    private var currentPositionInfoOverlay: UIView?
    
    private var view: TrackerView?
    
    internal init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], lineColor: UIColor, animDuration: Float, animDelay: Float, settings: HikeChartPointsLineTrackerLayerSettings, dataSets: [HikeChartDataSet]) {
        self.lineColor = lineColor
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.settings = settings
        self.dataSets = dataSets
        
        self.currentDistanceLabelOverlay = UILabel(frame: CGRect(x: settings.infoViewLabelDefaultMargin, y: settings.infoViewLabelDefaultMargin, width: settings.infoViewLabelDefaultWidth, height: settings.infoViewLabelDefaultHeight))
        self.currentDistanceLabelOverlay.textColor = UIColor.whiteColor()
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints)
    }
    
    private func generateInfoLabelOverlay(color: UIColor) -> UILabel {
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        
        let label = UILabel(frame: CGRect(x: settings.infoViewLabelDefaultMargin, y: settings.infoViewLabelDefaultMargin + (((currentInfoLabelOverlays.count) + 1) * settings.infoViewLabelDefaultHeight), width: settings.infoViewLabelDefaultWidth, height: settings.infoViewLabelDefaultHeight))
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        label.textColor = UIColor(hue: hue, saturation: saturation * 0.75, brightness: brightness, alpha: alpha)
        label.alpha = 1
        return label
    }
    
    private func linesIntersection(line1P1 line1P1: CGPoint, line1P2: CGPoint, line2P1: CGPoint, line2P2: CGPoint) -> CGPoint? {
        return self.findLineIntersection(p0X: line1P1.x, p0y: line1P1.y, p1x: line1P2.x, p1y: line1P2.y, p2x: line2P1.x, p2y: line2P1.y, p3x: line2P2.x, p3y: line2P2.y)
    }
    
    // src: http://stackoverflow.com/a/14795484/930450 (modified)
    private func findLineIntersection(p0X p0X: CGFloat , p0y: CGFloat, p1x: CGFloat, p1y: CGFloat, p2x: CGFloat, p2y: CGFloat, p3x: CGFloat, p3y: CGFloat) -> CGPoint? {
        
        var s02x: CGFloat, s02y: CGFloat, s10x: CGFloat, s10y: CGFloat, s32x: CGFloat, s32y: CGFloat, sNumer: CGFloat, tNumer: CGFloat, denom: CGFloat, t: CGFloat;
        
        s10x = p1x - p0X
        s10y = p1y - p0y
        s32x = p3x - p2x
        s32y = p3y - p2y
        
        denom = s10x * s32y - s32x * s10y
        if denom == 0 {
            return nil // Collinear
        }
        let denomPositive: Bool = denom > 0
        
        s02x = p0X - p2x
        s02y = p0y - p2y
        sNumer = s10x * s02y - s10y * s02x
        if (sNumer < 0) == denomPositive {
            return nil // No collision
        }
        
        tNumer = s32x * s02y - s32y * s02x
        if (tNumer < 0) == denomPositive {
            return nil // No collision
        }
        if ((sNumer > denom) == denomPositive) || ((tNumer > denom) == denomPositive) {
            return nil // No collision
        }
        
        // Collision detected
        t = tNumer / denom
        let i_x = p0X + (t * s10x)
        let i_y = p0y + (t * s10y)
        return CGPoint(x: i_x, y: i_y)
    }
    
    private func createCurrentPositionInfoOverlayLabelForDistance(view view: UIView) -> UIView {
        let currentPosW: CGFloat = CGFloat(self.settings.infoViewLabelDefaultWidth)
        let currentPosH: CGFloat = CGFloat(self.settings.infoViewLabelDefaultHeight * 3)
        let currentPosX: CGFloat = (view.frame.size.width - currentPosW) / CGFloat(2)
        let currentPosY: CGFloat = 20
        let currentPositionInfoOverlay = UIView(frame: CGRectMake(currentPosX, currentPosY, currentPosW, currentPosH))
        
        currentPositionInfoOverlay.layer.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.9).CGColor
        currentPositionInfoOverlay.layer.cornerRadius = CGFloat(settings.infoViewLabelDefaultMargin)
        currentPositionInfoOverlay.alpha = 0
        
        currentPositionInfoOverlay.layer.shadowRadius = 3.5
        currentPositionInfoOverlay.layer.shadowOpacity = 0.3
        currentPositionInfoOverlay.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        
        return currentPositionInfoOverlay
    }
    
    /*private func createCurrentPositionInfoOverlay(view view: UIView) -> UILabel {
        let currentPosW: CGFloat = CGFloat(self.settings.infoViewLabelDefaultWidth)
        let currentPosH: CGFloat = CGFloat(self.settings.infoViewLabelDefaultHeight)
        let currentPosX: CGFloat = (view.frame.size.width - currentPosW) / CGFloat(2)
        let currentPosY: CGFloat = 20
        let currentPositionInfoOverlay = UILabel(frame: CGRectMake(currentPosX, currentPosY, currentPosW, currentPosH))
        currentPositionInfoOverlay.textColor = self.settings.infoViewFontColor
        currentPositionInfoOverlay.layer.borderWidth = 1
        currentPositionInfoOverlay.textAlignment = NSTextAlignment.Center
        currentPositionInfoOverlay.layer.backgroundColor = UIColor.whiteColor().CGColor
        currentPositionInfoOverlay.layer.borderColor = UIColor.grayColor().CGColor
        currentPositionInfoOverlay.alpha = 0
        return currentPositionInfoOverlay
    }*/
    
    private func currentPositionInfoOverlay(view view: UIView) -> UIView {
        return self.currentPositionInfoOverlay ?? {
            let currentPositionInfoOverlay = self.createCurrentPositionInfoOverlayLabelForDistance(view: view)
            self.currentPositionInfoOverlay = currentPositionInfoOverlay
            return currentPositionInfoOverlay
            }()
    }
    
    private func updateTrackerLineOnValidState(updateFunc updateFunc: (view: UIView) -> ()) {
        if !self.chartPointsModels.isEmpty {
            if let view = self.view {
                updateFunc(view: view)
            }
        }
    }
    
    private func updateTrackerLine(touchPoint touchPoint: CGPoint) {
        
        self.updateTrackerLineOnValidState{(view) in
            
            let touchlineP1 = CGPointMake(touchPoint.x, 0)
            let touchlineP2 = CGPointMake(touchPoint.x, view.frame.size.height)
            
            var intersections = [CGPoint]()
            var intersectionsDataSetReference = [Int]()
            var positionInDataSets: Int = 0
            
            for i in 0..<(self.chartPointsModels.count - 1) {
                let m1 = self.chartPointsModels[i]
                let m2 = self.chartPointsModels[i + 1]
                if m1.chartPoint.x.scalar <= m2.chartPoint.x.scalar {
                    if let intersection = self.linesIntersection(line1P1: touchlineP1, line1P2: touchlineP2, line2P1: m1.screenLoc, line2P2: m2.screenLoc) {
                        intersections.append(intersection)
                        intersectionsDataSetReference.append(positionInDataSets)
                    }
                } else {
                    positionInDataSets++
                }
            }
            
            // Select point with smallest distance to touch point.
            // If there's only one intersection, returns intersection. If there's no intersection returns nil.
            /*
            
            var intersectionMaybe: CGPoint? = {
            var minDistancePoint: (distance: Float, point: CGPoint?) = (MAXFLOAT, nil)
            for intersection in intersections {
            let distance = hypotf(Float(intersection.x - touchPoint.x), Float(intersection.y - touchPoint.y))
            if distance < minDistancePoint.0 {
            minDistancePoint = (distance, intersection)
            }
            }
            return minDistancePoint.point
            }()
            
            */
            
            var w: CGFloat = self.settings.thumbSize
            var h: CGFloat = self.settings.thumbSize
            
            //Make all of this dirty code adapt for any number of intersections
            if intersections.count > 0 {
                if self.currentPositionInfoOverlay?.superview == nil {
                    view.addSubview(self.currentPositionLineOverlay)
                    view.addSubview(self.currentPositionInfoOverlay(view: view))
                    self.currentPositionInfoOverlay?.addSubview(self.currentDistanceLabelOverlay)
                    view.addSubview(self.thumb)
                    view.addSubview(self.thumb2)
                }
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.currentPositionInfoOverlay!.alpha = 1
                    self.currentPositionLineOverlay.alpha = 1
                })
            }
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.defineInfoOverlayHeightDependingOn(intersections.count)
            })
            
            if intersections.count == 0 {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.thumb.alpha = 0
                    self.thumb2.alpha = 0
                    self.currentPositionInfoOverlay!.alpha = 0
                    self.currentPositionLineOverlay.alpha = 0
                })
                return
            }
            
            if intersections.count == 1 {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.thumb.alpha = 1
                    self.thumb2.alpha = 0
                })
            }
            
            if intersections.count == 2 {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.thumb.alpha = 1
                    self.thumb2.alpha = 1
                })
            }
            
            // Calculate scalar corresponding to intersection screen location along axis
            func scalar(axis: ChartAxisLayer, intersection: CGFloat) -> Double {
                let s1 = axis.axisValues[0].scalar
                let sl1 = axis.screenLocForScalar(s1)
                let s2 = axis.axisValues[1].scalar
                let sl2 = axis.screenLocForScalar(s2)
                
                let factor = (s2 - s1) / Double(sl2 - sl1)
                let sl = Double(intersection - sl1)
                return sl * Double(factor) + Double(s1)
            }
            
            var distance: Double?
            
            if self.chartPointsModels.count > 1 {
                distance = scalar(self.xAxis, intersection: touchPoint.x)
            }
            
            self.altitudes.removeAll()
            var counter = 0
            for intersection: CGPoint in intersections {
                self.currentPositionLineOverlay.frame = CGRectMake(intersection.x, 0, 1, view.frame.size.height)
                
                if counter == 0 {
                    self.thumb.frame = CGRectMake(intersection.x - w/2, intersection.y - h/2, w, h)
                } else if counter == 1 {
                    self.thumb2.frame = CGRectMake(intersection.x - w/2, intersection.y - h/2, w, h)
                }
                
                if self.chartPointsModels.count > 1 {
                    self.altitudes.append(scalar(self.yAxis, intersection: intersection.y))
                }
                
                counter++
            }
            
            let baseView = self.view?.superview?.superview as? HikeChartView
            let leftAxisWidth = baseView?.coordsSpace?.yAxis.rect.width
            let chartFrameWidth = (baseView?.bounds.size.width)! - leftAxisWidth!
            
            self.displayInfo(distance!, altitudes: self.altitudes, altitudesDataSet: intersectionsDataSetReference, fingerIsOnTheLeft: touchPoint.x < (chartFrameWidth / 2) + leftAxisWidth!)
        }
    }
    
    func defineInfoOverlayHeightDependingOn(numberOfIntersetion: Int) {
        currentPositionInfoOverlay?.frame.size.height = CGFloat(settings.infoViewLabelDefaultHeight * (numberOfIntersetion + 1) + (settings.infoViewLabelDefaultMargin * 2))
    }
    
    override func display(chart chart: Chart) {
        let view = TrackerView(frame: chart.bounds,
            updateFunc: {
                [weak self] location in
                self?.updateTrackerLine(touchPoint: location)
            })
        view.userInteractionEnabled = true
        chart.addSubview(view)
        self.view = view
    }
    
    func displayInfo(distance: Double, altitudes: [Double], altitudesDataSet: [Int], fingerIsOnTheLeft: Bool = false) {
        setCurrentPositionInfoOverlay(fingerIsOnTheLeft)
        self.currentDistanceLabelOverlay.text = "Dist. " + String(Int(distance)) + "m"
        
        for altLabel: UILabel in currentInfoLabelOverlays {
            altLabel.removeFromSuperview()
        }
        currentInfoLabelOverlays.removeAll()
        
        var dataSetReference = 0
        for altitude in altitudes {
            currentInfoLabelOverlays.append(generateInfoLabelOverlay(dataSets[dataSetReference].color))
            currentInfoLabelOverlays[dataSetReference].text = "Alt. " + String(Int(altitude)) + "m"
            
            currentPositionInfoOverlay?.addSubview(currentInfoLabelOverlays[dataSetReference])
            dataSetReference++
        }
    }
    
    func setCurrentPositionInfoOverlay(left: Bool) {
        let baseView = self.view?.superview?.superview as? HikeChartView
        let leftAxisWidth = baseView?.coordsSpace?.yAxis.rect.width
        let chartFrameWidth = (baseView?.bounds.size.width)! - leftAxisWidth!
        let infoOverlayWidth = (currentPositionInfoOverlay?.bounds.size.width)!
        var newPositionCenter = chartFrameWidth * 0.25
        if left {
            newPositionCenter = chartFrameWidth * 0.75
        }
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.currentPositionInfoOverlay?.frame.origin.x = (newPositionCenter - (infoOverlayWidth / 2)) + leftAxisWidth!
        })
    }
}

private class TrackerView: UIView {
    
    let updateFunc: ((CGPoint) -> ())?
    
    init(frame: CGRect, updateFunc: (CGPoint) -> ()) {
        self.updateFunc = updateFunc
        
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let location = touch.locationInView(self)
        
        self.updateFunc?(location)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let location = touch.locationInView(self)
        
        self.updateFunc?(location)
    }
}