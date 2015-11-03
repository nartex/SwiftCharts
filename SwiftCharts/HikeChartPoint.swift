//
//  HikeChartPoint.swift
//  SwiftCharts
//
//  Created by Nicolas Klein on 29/10/15.
//  Copyright © 2015 Nartex. All rights reserved.
//

import UIKit

public class HikeChartPoint: NSObject {
    private static let xs : [Int] = [150, 175, 200, 225, 250]
    private static let yOffsetMax : Int = 10
    
    private static let yMin : Int = 700
    private static let yMax : Int = 1500
    
    private static let yBase : Int = 800
    
    let x: NSNumber?
    let y: NSNumber?
    
    var chartPoint: ChartPoint?
    
    let labelSettings = ChartLabelSettings(font: HikeChartSettings.labelFont)
    
    required public init(withX x: NSNumber, andY y: NSNumber){
        self.x = x
        self.y = y
        super.init()
        
        self.chartPoint = ChartPoint(x: ChartAxisValueDouble(Double(x), labelSettings: labelSettings), y: ChartAxisValueDouble(Double(y)))
    }
    
    public static func generateRandomPointArray(numberOfPoint: Int) -> [HikeChartPoint] {
        var outputArray = [HikeChartPoint]()
        var lastValue: HikeChartPoint?
        var yOffset: Int? = randomInt(min: 0, max: yOffsetMax * 2)
        var xOffset: Int?
        
        outputArray.append(HikeChartPoint(withX: 0, andY: yBase))
        
        for position in 1...numberOfPoint - 1 {
            lastValue = outputArray[position - 1]
            yOffset = randomInt(min: 0, max: yOffsetMax * 2) - yOffsetMax
            while yOffset == 0 {
                yOffset = randomInt(min: 0, max: yOffsetMax * 2) - yOffsetMax
            }
            
            if lastValue!.y!.intValue + (yOffset! as NSNumber).intValue > Int32(yMax - yOffsetMax) {
                yOffset = abs(yOffset!) * -1
            } else if lastValue!.y!.intValue + (yOffset! as NSNumber).intValue < Int32(yMin + yOffsetMax) {
                yOffset = abs(yOffset!)
            }
            
            xOffset = xs[randomInt(min: 0, max: xs.count - 1)]
            
            outputArray.append(HikeChartPoint(
                withX: outputArray[position - 1].x!.floatValue + (xOffset! as NSNumber).floatValue,
                andY: outputArray[position - 1].y!.floatValue + (yOffset! as NSNumber).floatValue
                ))
        }
        return outputArray
    }
    
    private static func randomInt(min min: Int, max: Int) -> Int {
        if max < min { return min }
        return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
    }
}
