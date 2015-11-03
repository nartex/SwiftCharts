//
//  HikeChartDataSet.swift
//  SwiftCharts
//
//  Created by Nicolas Klein on 29/10/15.
//  Copyright © 2015 Nartex. All rights reserved.
//

import UIKit

class HikeChartDataSet: NSObject {
    let label: NSString
    let points: [HikeChartPoint]
    let color: UIColor
    
    required init(withLabel label: NSString, andPoints points: [HikeChartPoint], andColor color: UIColor) {
        self.label = label
        self.points = points
        self.color = color
    }
}