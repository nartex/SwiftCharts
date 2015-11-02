//
//  HikeChartView.swift
//  SwiftChartsObjectiveCIntegrationTest
//
//  Created by Nicolas Klein on 29/10/15.
//  Copyright © 2015 Nartex. All rights reserved.
//

import UIKit
import SwiftCharts

class HikeChartView: UIView {
    
    var dataSets: [HikeChartDataSet]?
    private var chart: Chart?
    var axisColor = UIColor.blackColor()
    
    var xAxisTitle = "Distance"
    var yAxisTitle = "Altitude"
    
    override var frame: CGRect {
        didSet {
            chartInit()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init(frame: CGRect, dataSets: [HikeChartDataSet]) {
        self.dataSets = dataSets
        super.init(frame: frame)
        
        chartInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func chartInit() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let labelSettings = ChartLabelSettings(font: HikeChartSettings.labelFont)
            
            var chartPoints = [ChartPoint]()
            
            for dataSet in self.dataSets! {
                chartPoints.appendContentsOf(dataSet.points.map({$0.chartPoint!}))
            }
            
            let xAllValues = chartPoints.map({Float($0.x.scalar)})
            let xMax = xAllValues.maxElement()
            let xMin = xAllValues.minElement()
            
            let xValues = xMin?.stride(through: xMax!, by: (xMax! - xMin!) / 5).map({ChartAxisValueFloat(CGFloat($0), labelSettings: labelSettings)})
            let yValues = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 5, maxSegmentCount: 8, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: HikeChartSettings.labelSettings)}, addPaddingSegmentIfEdge: true)
            
            let xModel = ChartAxisModel(axisValues: xValues!, lineColor: self.axisColor, axisTitleLabel: ChartAxisLabel(text: self.xAxisTitle, settings: HikeChartSettings.labelSettings))
            let yModel = ChartAxisModel(axisValues: yValues, lineColor: self.axisColor, axisTitleLabel: ChartAxisLabel(text: self.yAxisTitle, settings: HikeChartSettings.labelSettings.defaultVertical()))
            
            let chartFrame = HikeChartSettings.chartFrame(self.bounds)
            
            let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: HikeChartSettings.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
            
            dispatch_async(dispatch_get_main_queue(), {
                let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
                
                // TODO: Make it a loop
                let chartPointsAreaLayer1 = ChartPointsAreaLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: self.dataSets![0].points.map({$0.chartPoint!}), areaColor: self.dataSets![0].color.colorWithAlphaComponent(0.4), animDuration: 4, animDelay: 0, addContainerPoints: true)
                let chartPointsAreaLayer2 = ChartPointsAreaLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: self.dataSets![1].points.map({$0.chartPoint!}), areaColor: self.dataSets![1].color.colorWithAlphaComponent(0.4), animDuration: 4, animDelay: 0, addContainerPoints: true)
                
                let models = self.dataSets!.map({ChartLineModel(chartPoints: $0.points.map({$0.chartPoint!}), lineColor: $0.color, lineWidth: 3, animDuration: 3, animDelay: 0)})
                
                let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: models, pathGenerator: CubicLinePathGenerator(tension1: 0.3, tension2: 0.3))
                
                let trackerLayerSettings = ChartPointsLineTrackerLayerSettings(thumbSize: HikeChartSettings.isPad ? 30 : 20, thumbCornerRadius: HikeChartSettings.isPad ? 16 : 10, thumbBorderWidth: HikeChartSettings.isPad ? 4 : 2, infoViewFont: HikeChartSettings.fontWithSize(HikeChartSettings.isPad ? 26 : 16), infoViewSize: CGSizeMake(HikeChartSettings.isPad ? 400 : 160, HikeChartSettings.isPad ? 70 : 40), infoViewCornerRadius: HikeChartSettings.isPad ? 30 : 15)
                
                let chartPointsTrackerLayer1 = ChartPointsLineTrackerLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: self.dataSets![0].points.map({$0.chartPoint!}), lineColor: UIColor.blackColor(), animDuration: 1, animDelay: 2, settings: trackerLayerSettings)
                let chartPointsTrackerLayer2 = ChartPointsLineTrackerLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: self.dataSets![1].points.map({$0.chartPoint!}), lineColor: UIColor.blackColor(), animDuration: 1, animDelay: 2, settings: trackerLayerSettings)
                
                let settings = ChartGuideLinesLayerSettings(linesColor: UIColor.blackColor(), linesWidth: HikeChartSettings.guidelinesWidth)
                let guidelinesLayer = ChartGuideLinesLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, axis: .Y, settings: settings)
                
                let chart = Chart(frame: chartFrame, layers: [
                    xAxis,
                    yAxis,
                    guidelinesLayer,
                    chartPointsLineLayer,
                    chartPointsAreaLayer1,
                    chartPointsAreaLayer2,
                    chartPointsTrackerLayer1,
                    chartPointsTrackerLayer2
                    ])
                
                for view in self.subviews {
                    view.removeFromSuperview()
                }
                
                self.addSubview(chart.view)
                self.chart = chart
            })
        })
    }
}
