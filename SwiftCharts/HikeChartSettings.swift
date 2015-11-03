//
//  HikeChartSettings.swift
//  SwiftCharts
//
//  Created by Nicolas Klein on 30/10/15.
//  Copyright © 2015 Nartex. All rights reserved.
//

import Foundation
import UIKit
import SwiftCharts

class HikeChartSettings: NSObject {
    
    static let isPad = UIDevice.currentDevice().userInterfaceIdiom == .Pad
    
    static var chartSettings: ChartSettings {
        if isPad {
            return self.iPadChartSettings
        } else {
            return self.iPhoneChartSettings
        }
    }
    
    private static var iPadChartSettings: ChartSettings {
        let chartSettings = ChartSettings()
        chartSettings.leading = 20
        chartSettings.top = 20
        chartSettings.trailing = 20
        chartSettings.bottom = 20
        chartSettings.labelsToAxisSpacingX = 10
        chartSettings.labelsToAxisSpacingY = 10
        chartSettings.axisTitleLabelsToLabelsSpacing = 5
        chartSettings.axisStrokeWidth = 1
        chartSettings.spacingBetweenAxesX = 15
        chartSettings.spacingBetweenAxesY = 15
        return chartSettings
    }
    
    private static var iPhoneChartSettings: ChartSettings {
        let chartSettings = ChartSettings()
        chartSettings.leading = 10
        chartSettings.top = 10
        chartSettings.trailing = 10
        chartSettings.bottom = 10
        chartSettings.labelsToAxisSpacingX = 5
        chartSettings.labelsToAxisSpacingY = 5
        chartSettings.axisTitleLabelsToLabelsSpacing = 4
        chartSettings.axisStrokeWidth = 0.2
        chartSettings.spacingBetweenAxesX = 8
        chartSettings.spacingBetweenAxesY = 8
        return chartSettings
    }
    
    static func chartFrame(containerBounds: CGRect) -> CGRect {
        return CGRectMake(0, 70, containerBounds.size.width, containerBounds.size.height - 70)
    }
    
    static var labelSettings: ChartLabelSettings {
        return ChartLabelSettings(font: HikeChartSettings.labelFont)
    }
    
    static var labelFont: UIFont {
        return HikeChartSettings.fontWithSize(isPad ? 14 : 11)
    }
    
    static func fontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica", size: size) ?? UIFont.systemFontOfSize(size)
    }
    
    static var guidelinesWidth: CGFloat {
        return isPad ? 0.5 : 0.1
    }
}