//
//  HikeChartAxisSettings.swift
//  SwiftCharts
//
//  Created by Nicolas Klein on 04/11/15.
//  Copyright © 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class HikeChartAxisSettings: NSObject {
    let xAxisTitle: String
    let yAxisTitle: String
    let xAxisShortTitle: String
    let yAxisShortTitle: String
    let xAxisUnitOfMeasurement: String
    let yAxisUnitOfMeasurement: String
    
    required public init(xAxisTitle: String, yAxisTitle: String, xAxisShortTitle: String, yAxisShortTitle: String, xAxisUnitOfMeasurement: String, yAxisUnitOfMeasurement: String) {
        
        self.xAxisTitle = xAxisTitle
        self.yAxisTitle = yAxisTitle
        self.xAxisShortTitle = xAxisShortTitle
        self.yAxisShortTitle = yAxisShortTitle
        self.xAxisUnitOfMeasurement = xAxisUnitOfMeasurement
        self.yAxisUnitOfMeasurement = yAxisUnitOfMeasurement
        
        super.init()
    }
}
