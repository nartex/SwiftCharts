//
//  ChartCoordsSpaceLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartCoordsSpaceLayer: ChartLayerBase {
    
    public let xAxis: ChartAxisLayer
    public let yAxis: ChartAxisLayer
    
    // frame where the layer displays chartpoints
    // note that this is not necessarily derived from axis, as axis can be in different positions (x-left/right, y-top/bottom) and be separated from content frame by a specified offset (multiaxis)
    public let innerFrame: CGRect
    
    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect) {
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.innerFrame = innerFrame
    }
}
