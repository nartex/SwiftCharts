//
//  HikeChartExample.swift
//  SwiftCharts
//
//  Created by Nicolas Klein on 02/11/15.
//  Copyright © 2015 ivanschuetz. All rights reserved.
//

import Foundation
import UIKit
import SwiftCharts

class HikeChartExample: UIViewController {
    var superAwsomeHikeChartView : HikeChartView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var dataSets = [HikeChartDataSet]()
        
        dataSets.append(HikeChartDataSet(withPoints: HikeChartPoint.generateRandomPointArray(50), andColor: UIColor(netHex: 0x607D8B)))
        dataSets.append(HikeChartDataSet(withPoints: HikeChartPoint.generateRandomPointArray(40), andColor: UIColor(netHex: 0x9E9E9E)))
        /*
        dataSets.append(HikeChartDataSet(withPoints: HikeChartPoint.generateRandomPointArray(3), andColor: UIColor(netHex: 0x795548)))
        dataSets.append(HikeChartDataSet(withPoints: HikeChartPoint.generateRandomPointArray(4), andColor: UIColor(netHex: 0xFF5722)))
        dataSets.append(HikeChartDataSet(withPoints: HikeChartPoint.generateRandomPointArray(3), andColor: UIColor(netHex: 0xFF9800)))
        dataSets.append(HikeChartDataSet(withPoints: HikeChartPoint.generateRandomPointArray(4), andColor: UIColor(netHex: 0xFFC107)))
        dataSets.append(HikeChartDataSet(withPoints: HikeChartPoint.generateRandomPointArray(3), andColor: UIColor(netHex: 0xFFEB3B)))
        dataSets.append(HikeChartDataSet(withPoints: HikeChartPoint.generateRandomPointArray(4), andColor: UIColor(netHex: 0xCDDC39)))
        dataSets.append(HikeChartDataSet(withPoints: HikeChartPoint.generateRandomPointArray(4), andColor: UIColor(netHex: 0x8BC34A)))
        dataSets.append(HikeChartDataSet(withPoints: HikeChartPoint.generateRandomPointArray(4), andColor: UIColor(netHex: 0x4CAF50)))
        dataSets.append(HikeChartDataSet(withPoints: HikeChartPoint.generateRandomPointArray(4), andColor: UIColor(netHex: 0x009688)))
        dataSets.append(HikeChartDataSet(withPoints: HikeChartPoint.generateRandomPointArray(4), andColor: UIColor(netHex: 0x00BCD4)))
        dataSets.append(HikeChartDataSet(withPoints: HikeChartPoint.generateRandomPointArray(4), andColor: UIColor(netHex: 0x03A9F4)))
        dataSets.append(HikeChartDataSet(withPoints: HikeChartPoint.generateRandomPointArray(4), andColor: UIColor(netHex: 0x2196F3)))
        dataSets.append(HikeChartDataSet(withPoints: HikeChartPoint.generateRandomPointArray(4), andColor: UIColor(netHex: 0x3F51B5)))
        dataSets.append(HikeChartDataSet(withPoints: HikeChartPoint.generateRandomPointArray(4), andColor: UIColor(netHex: 0x673AB7)))
        dataSets.append(HikeChartDataSet(withPoints: HikeChartPoint.generateRandomPointArray(4), andColor: UIColor(netHex: 0x9C27B0)))
        dataSets.append(HikeChartDataSet(withPoints: HikeChartPoint.generateRandomPointArray(4), andColor: UIColor(netHex: 0xE91E63)))
        dataSets.append(HikeChartDataSet(withPoints: HikeChartPoint.generateRandomPointArray(4), andColor: UIColor(netHex: 0xF44336)))
        */
        
        let hikeChartAxisSettings = HikeChartAxisSettings(xAxisTitle: "Distance", yAxisTitle: "Altitude", xAxisShortTitle: "Dist.", yAxisShortTitle: "Alt.", xAxisUnitOfMeasurement: "m", yAxisUnitOfMeasurement: "m")
        
        superAwsomeHikeChartView = HikeChartView(frame: view.frame, dataSets: dataSets, hikeChartAxisSettings: hikeChartAxisSettings)
        
        view.addSubview(superAwsomeHikeChartView!)
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}