//
//  HikeChartPointsAreaLayer.swift
//  SwiftCharts
//
//  Created by Nicolas Klein on 03/11/15.
//  Copyright © 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class HikeChartPointsAreaLayer<T: ChartPoint>: ChartPointsLayer<T> {
    
    private let areaColor: UIColor
    private let animDuration: Float
    private let animDelay: Float
    private let addContainerPoints: Bool
    
    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], areaColor: UIColor, animDuration: Float, animDelay: Float, addContainerPoints: Bool) {
        self.areaColor = areaColor
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.addContainerPoints = addContainerPoints
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints)
    }
    
    override public func display(chart chart: Chart) {
        var points = self.chartPointScreenLocs
        
        let origin = self.innerFrame.origin
        let xLength = self.innerFrame.width
        
        let bottomY = origin.y + self.innerFrame.height
        
        // TODO: Get the correct x stop point
        
        if self.addContainerPoints {
            //points.append(CGPointMake(origin.x + xLength, bottomY))
            points.append(CGPointMake(origin.x, bottomY))
        }
        
        let areaView = HikeChartAreasView(points: points, frame: chart.bounds, color: self.areaColor, animDuration: self.animDuration, animDelay: self.animDelay)
        chart.addSubview(areaView)
    }
}
