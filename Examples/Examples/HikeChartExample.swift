//
//  HikeChartExample.swift
//  SwiftCharts
//
//  Created by Nicolas Klein on 02/11/15.
//  Copyright © 2015 ivanschuetz. All rights reserved.
//

import Foundation
import UIKit

class HikeChartExample: UIViewController {
    var superAwsomeHikeChartView : HikeChartView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var hikeDefaultPoints = HikeChartDataSet(withLabel: "default_points", andPoints: HikeChartPoint.generateRandomPointArray(50), andColor: UIColor.redColor())
        var hikeUserPoints = HikeChartDataSet(withLabel: "user_points", andPoints: HikeChartPoint.generateRandomPointArray(30), andColor: UIColor.blueColor())
        
        superAwsomeHikeChartView = HikeChartView(frame: view.frame, dataSets: [hikeDefaultPoints, hikeUserPoints])
        superAwsomeHikeChartView?.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        view.addSubview(superAwsomeHikeChartView!)
    }
}