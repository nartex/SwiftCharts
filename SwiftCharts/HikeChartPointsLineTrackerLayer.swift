//
//  HikeChartPointsLineTrackerLayer.swift
//  SwiftCharts
//
//  Created by Nicolas Klein on 02/11/15.
//  Copyright © 2015 ivanschuetz. All rights reserved.
//

import UIKit

protocol HikeChartPointsLineTrackerLayerDelegate {
    func touchesBegan(sender: AnyObject!)
    func touchesMoved(sender: AnyObject!)
    func touchesEnded(sender: AnyObject!)
    func touchesCancelled(sender: AnyObject!)
}

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
        infoViewBackgroundColor: UIColor = UIColor(red: 10/256, green: 10/256, blue: 10/256, alpha: 0.75),
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
    
    var altitudes = [Double?]()
    
    var previousAltitudesCount = 0
    
    let dataSets: [HikeChartDataSet]
    let hikeChartAxisSettings: HikeChartAxisSettings
    
    var delegate: HikeChartPointsLineTrackerLayerDelegate?
    
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
    
    private var thumbs = [UIView]()
    
    private func generateThumb() -> UIView {
        let thumb = UIView()
        thumb.layer.cornerRadius = self.settings.thumbCornerRadius
        thumb.layer.borderWidth = self.settings.thumbBorderWidth
        thumb.layer.backgroundColor = UIColor.clearColor().CGColor
        thumb.layer.borderColor = self.settings.thumbBorderColor.CGColor
        thumb.alpha = 1
        return thumb
    }
    
    private func showThumb(atIndex index: Int) {
        if self.thumbs[index].alpha != 1 {
            UIView.animateWithDuration(0.4,
                animations: { () -> Void in
                    self.thumbs[index].alpha = 1
            })
        }
    }
    
    private func hideThumb(atIndex index: Int) {
        if self.thumbs[index].alpha != 0 {
            UIView.animateWithDuration(0.2,
                animations: { () -> Void in
                    self.thumbs[index].alpha = 0
            })
        }
    }
    
    private func showInfoLabelOverlay(atIndex index: Int) {
        if self.currentInfoLabelOverlaysHeightConstraints[index]?.constant != CGFloat(self.settings.infoViewLabelDefaultHeight) {
            UIView.animateWithDuration(0.3,
                animations: { () -> Void in
                    self.currentInfoLabelOverlaysHeightConstraints[index]?.constant = CGFloat(self.settings.infoViewLabelDefaultHeight)
                    self.currentInfoLabelOverlays[index].alpha = 1
            })
        }
    }
    
    private func hideInfoLabelOverlay(atIndex index: Int) {
        if self.currentInfoLabelOverlaysHeightConstraints[index]?.constant != 0 {
            UIView.animateWithDuration(0.3,
                animations: { () -> Void in
                    self.currentInfoLabelOverlaysHeightConstraints[index]?.constant = 0
                    self.currentInfoLabelOverlays[index].alpha = 0
            })
        }
    }
    
    private var intersections = [CGPoint?]()
    private var currentInfoLabelOverlays = [UILabel]()
    private var currentInfoLabelOverlaysHeightConstraints = [NSLayoutConstraint?]()
    private let currentDistanceLabelOverlay: UILabel
    
    private var currentPositionInfoOverlay: UIView?
    private var currentPositionInfoOverlayPosition: NSLayoutConstraint?
    
    private var view: TrackerView?
    
    private var chartFrameWidth: CGFloat?
    private var leftAxisWidth: CGFloat?
    
    private func numberOfIntersection() -> Int {
        var count = 0
        for intersection in intersections {
            if intersection != nil {
                count++
            }
        }
        return count
    }
    
    internal init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], lineColor: UIColor, animDuration: Float, animDelay: Float, settings: HikeChartPointsLineTrackerLayerSettings, dataSets: [HikeChartDataSet], hikeChartAxisSettings: HikeChartAxisSettings) {
        self.lineColor = lineColor
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.settings = settings
        self.dataSets = dataSets
        self.hikeChartAxisSettings = hikeChartAxisSettings
        
        self.currentDistanceLabelOverlay = UILabel(frame: CGRect(x: settings.infoViewLabelDefaultMargin, y: settings.infoViewLabelDefaultMargin, width: settings.infoViewLabelDefaultWidth, height: settings.infoViewLabelDefaultHeight))
        self.currentDistanceLabelOverlay.textColor = UIColor.whiteColor()
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints)
        
        for dataSet in dataSets {
            thumbs.append(generateThumb())
            currentInfoLabelOverlays.append(generateInfoLabelOverlay(dataSet.color))
            altitudes.append(nil)
            intersections.append(nil)
            currentInfoLabelOverlaysHeightConstraints.append(nil)
        }
    }
    
    private func generateInfoLabelOverlay(color: UIColor) -> UILabel {
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        
        let label = UILabel(frame: CGRect(x: settings.infoViewLabelDefaultMargin, y: settings.infoViewLabelDefaultMargin + (((currentInfoLabelOverlays.count) + 1) * settings.infoViewLabelDefaultHeight), width: settings.infoViewLabelDefaultWidth, height: settings.infoViewLabelDefaultHeight))
        
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        label.textColor = UIColor(hue: hue, saturation: saturation * 0.75, brightness: brightness, alpha: alpha)
        label.shadowColor = UIColor.blackColor()
        label.shadowOffset = CGSize(width: 0.0, height: 1.5)
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
        
        currentPositionInfoOverlay.layer.backgroundColor = settings.infoViewBackgroundColor.CGColor
        currentPositionInfoOverlay.layer.cornerRadius = CGFloat(settings.infoViewLabelDefaultMargin)
        currentPositionInfoOverlay.alpha = 0
        
        currentPositionInfoOverlay.layer.shadowRadius = 3.5
        currentPositionInfoOverlay.layer.shadowOpacity = 0.3
        currentPositionInfoOverlay.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        
        return currentPositionInfoOverlay
    }
    
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
            
            let w: CGFloat = self.settings.thumbSize
            let h: CGFloat = self.settings.thumbSize
            
            let touchlineP1 = CGPointMake(touchPoint.x, 0)
            let touchlineP2 = CGPointMake(touchPoint.x, view.frame.size.height)
            
            var positionInDataSets: Int = 0
            
            for intersectionIndex in 0..<self.intersections.count {
                self.intersections[intersectionIndex] = nil
            }
            
            for i in 0..<(self.chartPointsModels.count - 1) {
                let m1 = self.chartPointsModels[i]
                let m2 = self.chartPointsModels[i + 1]
                if m1.chartPoint.x.scalar <= m2.chartPoint.x.scalar {
                    if let intersection = self.linesIntersection(line1P1: touchlineP1, line1P2: touchlineP2, line2P1: m1.screenLoc, line2P2: m2.screenLoc) {
                        self.intersections[positionInDataSets] = intersection
                        self.altitudes[positionInDataSets] = scalar(self.yAxis, intersection: intersection.y)
                    }
                } else {
                    positionInDataSets++
                }
            }
            
            if self.currentPositionInfoOverlay?.superview == nil {
                view.addSubview(self.currentPositionLineOverlay)
                view.addSubview(self.currentPositionInfoOverlay(view: view))
                
                for thumb in self.thumbs {
                    self.view?.addSubview(thumb)
                }
                
                for infoLabelOverlay in self.currentInfoLabelOverlays {
                    self.currentPositionInfoOverlay?.addSubview(infoLabelOverlay)
                }
                
                self.currentPositionInfoOverlay?.addSubview(self.currentDistanceLabelOverlay)
                
                let baseView = self.view?.superview?.superview as? HikeChartView
                self.leftAxisWidth = baseView?.coordsSpace?.yAxis.rect.width
                self.chartFrameWidth = (baseView?.bounds.size.width)! - self.leftAxisWidth!
                
                self.currentPositionInfoOverlayPosition = NSLayoutConstraint(
                    item: self.currentPositionInfoOverlay!,
                    attribute: .CenterX,
                    relatedBy: .Equal,
                    toItem: self.currentPositionInfoOverlay!.superview,
                    attribute: .Trailing,
                    multiplier: 1,
                    constant: self.computeNewCurrentPositionInfoOverlayPosition(true))
                self.currentPositionInfoOverlay?.superview!.addConstraint(self.currentPositionInfoOverlayPosition!)
                
                self.currentPositionInfoOverlay?.superview!.addConstraint(NSLayoutConstraint(
                    item: self.currentPositionInfoOverlay!,
                    attribute: .Top,
                    relatedBy: .Equal,
                    toItem: self.currentPositionInfoOverlay!.superview,
                    attribute: .Top,
                    multiplier: 1,
                    constant: 20))
                
                self.currentPositionInfoOverlay?.addConstraint(NSLayoutConstraint(
                    item: self.currentPositionInfoOverlay!,
                    attribute: .Leading,
                    relatedBy: .Equal,
                    toItem: self.currentDistanceLabelOverlay,
                    attribute: .Leading,
                    multiplier: 1,
                    constant: -CGFloat(self.settings.infoViewLabelDefaultMargin)))
                
                self.currentPositionInfoOverlay?.addConstraint(NSLayoutConstraint(
                    item: self.currentPositionInfoOverlay!,
                    attribute: .Trailing,
                    relatedBy: .Equal,
                    toItem: self.currentDistanceLabelOverlay,
                    attribute: .Trailing,
                    multiplier: 1,
                    constant: CGFloat(self.settings.infoViewLabelDefaultMargin)))
                
                self.currentPositionInfoOverlay?.addConstraint(NSLayoutConstraint(
                    item: self.currentPositionInfoOverlay!,
                    attribute: .Top,
                    relatedBy: .Equal,
                    toItem: self.currentDistanceLabelOverlay,
                    attribute: .Top,
                    multiplier: 1,
                    constant: -CGFloat(self.settings.infoViewLabelDefaultMargin)))
                
                self.currentPositionInfoOverlay?.addConstraint(NSLayoutConstraint(
                    item: self.currentDistanceLabelOverlay,
                    attribute: .Height,
                    relatedBy: .Equal,
                    toItem: nil,
                    attribute: .NotAnAttribute,
                    multiplier: 1,
                    constant: CGFloat(self.settings.infoViewLabelDefaultHeight)))
                
                self.currentDistanceLabelOverlay.translatesAutoresizingMaskIntoConstraints = false
                self.currentPositionInfoOverlay!.translatesAutoresizingMaskIntoConstraints = false
                
                for currentLabelIndex in 0..<self.currentInfoLabelOverlays.count {
                    let label = self.currentInfoLabelOverlays[currentLabelIndex]
                    var previousLabel: UILabel? = nil
                    if currentLabelIndex > 0 {
                        previousLabel = self.currentInfoLabelOverlays[currentLabelIndex - 1]
                    }
                    
                    if previousLabel != nil {
                        self.currentPositionInfoOverlay?.addConstraint(NSLayoutConstraint(
                            item: label,
                            attribute: .Top,
                            relatedBy: .Equal,
                            toItem: previousLabel,
                            attribute: .Bottom,
                            multiplier: 1,
                            constant: 0))
                    } else {
                        self.currentPositionInfoOverlay?.addConstraint(NSLayoutConstraint(
                            item: label,
                            attribute: .Top,
                            relatedBy: .Equal,
                            toItem: self.currentDistanceLabelOverlay,
                            attribute: .Bottom,
                            multiplier: 1,
                            constant: 0))
                    }
                    
                    if currentLabelIndex == self.currentInfoLabelOverlays.count - 1 {
                        self.currentPositionInfoOverlay?.addConstraint(NSLayoutConstraint(
                            item: self.currentPositionInfoOverlay!,
                            attribute: .Bottom,
                            relatedBy: .Equal,
                            toItem: label,
                            attribute: .Bottom,
                            multiplier: 1,
                            constant: CGFloat(self.settings.infoViewLabelDefaultMargin)))
                    }
                    
                    self.currentPositionInfoOverlay?.addConstraint(NSLayoutConstraint(
                        item: self.currentPositionInfoOverlay!,
                        attribute: .Leading,
                        relatedBy: .Equal,
                        toItem: label,
                        attribute: .Leading,
                        multiplier: 1,
                        constant: -CGFloat(self.settings.infoViewLabelDefaultMargin)))
                    
                    self.currentPositionInfoOverlay?.addConstraint(NSLayoutConstraint(
                        item: self.currentPositionInfoOverlay!,
                        attribute: .Trailing,
                        relatedBy: .Equal,
                        toItem: label,
                        attribute: .Trailing,
                        multiplier: 1,
                        constant: CGFloat(self.settings.infoViewLabelDefaultMargin)))
                    
                    self.currentInfoLabelOverlaysHeightConstraints[currentLabelIndex] = NSLayoutConstraint(
                        item: label,
                        attribute: .Height,
                        relatedBy: .Equal,
                        toItem: nil,
                        attribute: .NotAnAttribute,
                        multiplier: 1,
                        constant: CGFloat(self.settings.infoViewLabelDefaultHeight))
                    
                    self.currentInfoLabelOverlays[currentLabelIndex].addConstraint(self.currentInfoLabelOverlaysHeightConstraints[currentLabelIndex]!)
                    
                    label.translatesAutoresizingMaskIntoConstraints = false
                }
            }
            
            //Make all of this dirty code adapt for any number of intersections
            if self.numberOfIntersection() > 0 {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.currentPositionInfoOverlay!.alpha = 1
                    self.currentPositionLineOverlay.alpha = 1
                })
                
            } else {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.currentPositionInfoOverlay!.alpha = 0
                    self.currentPositionLineOverlay.alpha = 0
                    
                    for thumbIndex in 0..<self.thumbs.count {
                        self.hideThumb(atIndex: thumbIndex)
                    }
                })
                return
            }
            
            var distance: Double?
            
            if self.chartPointsModels.count > 1 {
                distance = scalar(self.xAxis, intersection: touchPoint.x)
            }
            
            for intersectionIndex in 0..<self.intersections.count {
                let intersection = self.intersections[intersectionIndex]
                if intersection != nil {
                    self.showThumb(atIndex: intersectionIndex)
                    self.showInfoLabelOverlay(atIndex: intersectionIndex)
                    self.thumbs[intersectionIndex].frame = CGRectMake(intersection!.x - w/2, intersection!.y - h/2, w, h)
                    self.currentPositionLineOverlay.frame = CGRectMake(intersection!.x, 0, 1, view.frame.size.height)
                } else {
                    self.hideThumb(atIndex: intersectionIndex)
                    self.hideInfoLabelOverlay(atIndex: intersectionIndex)
                }
            }
            
            self.displayInfo(distance!, altitudes: self.altitudes, fingerIsOnTheLeft: touchPoint.x < (self.chartFrameWidth! / 2) + self.leftAxisWidth!)
        }
    }
    
    override func display(chart chart: Chart) {
        let view = TrackerView(frame: chart.bounds,
            updateFunc: {
                [weak self] location in
                self?.updateTrackerLine(touchPoint: location)
            })
        view.delegate = self
        view.userInteractionEnabled = true
        chart.addSubview(view)
        self.view = view
    }
    
    func displayInfo(distance: Double, altitudes: [Double?], fingerIsOnTheLeft: Bool = false) {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.currentPositionInfoOverlayPosition?.constant = self.computeNewCurrentPositionInfoOverlayPosition(fingerIsOnTheLeft)
            self.view?.layoutIfNeeded()
        })
        self.currentDistanceLabelOverlay.text = hikeChartAxisSettings.xAxisShortTitle + " : " + String(Int(distance)) + hikeChartAxisSettings.xAxisUnitOfMeasurement
        
        for dataSetIndex in 0..<altitudes.count {
            if altitudes[dataSetIndex] != nil {
                currentInfoLabelOverlays[dataSetIndex].text = hikeChartAxisSettings.yAxisShortTitle + " : " + String(Int(altitudes[dataSetIndex]!)) + hikeChartAxisSettings.yAxisUnitOfMeasurement
            }
        }
        
        previousAltitudesCount = altitudes.count
    }
    
    func computeNewCurrentPositionInfoOverlayPosition(left: Bool) -> CGFloat {
        let infoOverlayWidth = (currentPositionInfoOverlay?.bounds.size.width)!
        var newPositionCenter = chartFrameWidth! * 0.25
        if !left {
            newPositionCenter = chartFrameWidth! * 0.75
        }
        
        return -((newPositionCenter - (infoOverlayWidth / 2)) + leftAxisWidth!)
    }
}

// MARK: TrackerViewDelegate

extension HikeChartPointsLineTrackerLayer: TrackerViewDelegate {
    private func touchesBegan(sender: TrackerView) {
        guard let delegate = delegate else {
            return
        }
        delegate.touchesBegan(self)
    }
    
    private func touchesMoved(sender: TrackerView) {
        guard let delegate = delegate else {
            return
        }
        delegate.touchesMoved(self)
    }
    
    private func touchesEnded(sender: TrackerView) {
        guard let delegate = delegate else {
            return
        }
        delegate.touchesEnded(self)
    }
    
    private func touchesCancelled(sender: TrackerView) {
        guard let delegate = delegate else {
            return
        }
        delegate.touchesCancelled(self)
    }
    
}

private protocol TrackerViewDelegate {
    func touchesBegan(sender: TrackerView)
    func touchesMoved(sender: TrackerView)
    func touchesEnded(sender: TrackerView)
    func touchesCancelled(sender: TrackerView)
}

private class TrackerView: UIView {
    
    let updateFunc: ((CGPoint) -> ())?
    var delegate: TrackerViewDelegate?
    
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
        
        guard let delegate = delegate else {
            return
        }
        delegate.touchesBegan(self)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let location = touch.locationInView(self)
        
        self.updateFunc?(location)
        
        guard let delegate = delegate else {
            return
        }
        delegate.touchesMoved(self)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let delegate = delegate else {
            return
        }
        delegate.touchesEnded(self)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        guard let delegate = delegate else {
            return
        }
        delegate.touchesCancelled(self)
    }
}
