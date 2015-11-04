//
//  HikeChartDataSet.swift
//  SwiftCharts
//
//  Created by Nicolas Klein on 29/10/15.
//  Copyright © 2015 Nartex. All rights reserved.
//

import UIKit

public class HikeChartDataSet: NSObject {
    let points: [HikeChartPoint]
    let color: UIColor
    
    required public init(withPoints points: [HikeChartPoint], andColor color: UIColor) {
        self.points = points
        self.color = color
    }
}