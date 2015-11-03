//
//  HikeChartView.swift
//  SwiftCharts
//
//  Created by Nicolas Klein on 29/10/15.
//  Copyright © 2015 Nartex. All rights reserved.
//

import UIKit

public class HikeChartView: UIView {
    
    var dataSets: [HikeChartDataSet]?
    var chart: Chart?
    var axisColor = UIColor.blackColor()
    
    var xAxisTitle = "Distance"
    var yAxisTitle = "Altitude"
    
    var coordsSpace: ChartCoordsSpaceLeftBottomSingleAxis?
    
    override public var frame: CGRect {
        didSet {
            chartInit()
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required public init(frame: CGRect, dataSets: [HikeChartDataSet]) {
        self.dataSets = dataSets
        super.init(frame: frame)
        
        chartInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
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
            
            self.coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: HikeChartSettings.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
            
            dispatch_async(dispatch_get_main_queue(), {
                let (xAxis, yAxis, innerFrame) = (self.coordsSpace!.xAxis, self.coordsSpace!.yAxis, self.coordsSpace!.chartInnerFrame)
                
                // TODO: Make it a loop
                var chartPointsAreaLayer1Points = [ChartPoint]()
                chartPointsAreaLayer1Points.appendContentsOf(self.dataSets![0].points.map({$0.chartPoint!}))
                chartPointsAreaLayer1Points.append(ChartPoint(x: self.dataSets![0].points.last!.chartPoint!.x, y: yAxis.axisValues[0]))
                var chartPointsAreaLayer2Points = [ChartPoint]()
                chartPointsAreaLayer2Points.appendContentsOf(self.dataSets![1].points.map({$0.chartPoint!}))
                chartPointsAreaLayer2Points.append(ChartPoint(x: self.dataSets![1].points.last!.chartPoint!.x, y: yAxis.axisValues[0]))
                
                let chartPointsAreaLayer1 = HikeChartPointsAreaLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPointsAreaLayer1Points, areaColor: self.dataSets![0].color.colorWithAlphaComponent(0.2), animDuration: 4, animDelay: 0, addContainerPoints: true)
                let chartPointsAreaLayer2 = HikeChartPointsAreaLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPointsAreaLayer2Points, areaColor: self.dataSets![1].color.colorWithAlphaComponent(0.2), animDuration: 4, animDelay: 0, addContainerPoints: true)
                
                let models = self.dataSets!.map({ChartLineModel(chartPoints: $0.points.map({$0.chartPoint!}), lineColor: $0.color, lineWidth: 4, animDuration: 2, animDelay: 0)})
                
                let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: models, pathGenerator: CubicLinePathGenerator(tension1: 0.3, tension2: 0.3))
                
                let trackerLayerSettings = HikeChartPointsLineTrackerLayerSettings(thumbSize: HikeChartSettings.isPad ? 18 : 12, thumbCornerRadius: HikeChartSettings.isPad ? 9 : 6, thumbBorderWidth: HikeChartSettings.isPad ? 4 : 2)
                
                let chartPointsTrackerLayer1 = HikeChartPointsLineTrackerLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, lineColor: UIColor.blackColor(), animDuration: 1, animDelay: 2, settings: trackerLayerSettings, dataSets: self.dataSets!)
                //let chartPointsTrackerLayer2 = ChartPointsLineTrackerLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: self.dataSets![1].points.map({$0.chartPoint!}), lineColor: UIColor.blackColor(), animDuration: 1, animDelay: 2, settings: trackerLayerSettings)
                
                let settings = ChartGuideLinesLayerSettings(linesColor: UIColor.blackColor(), linesWidth: HikeChartSettings.guidelinesWidth)
                let guidelinesLayer = ChartGuideLinesLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, axis: .Y, settings: settings)
                
                let chart = Chart(frame: chartFrame, layers: [
                    xAxis,
                    yAxis,
                    guidelinesLayer,
                    chartPointsLineLayer,
                    chartPointsAreaLayer1,
                    chartPointsAreaLayer2,
                    chartPointsTrackerLayer1
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
