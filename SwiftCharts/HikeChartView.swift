//
//  HikeChartView.swift
//  SwiftCharts
//
//  Created by Nicolas Klein on 29/10/15.
//  Copyright © 2015 Nartex. All rights reserved.
//

import UIKit

@objc public protocol HikeChartViewDelegate {
    func touchesBegan(sender: HikeChartView)
    func touchesMoved(sender: HikeChartView)
    func touchesEnded(sender: HikeChartView)
    func touchesCancelled(sender: HikeChartView)
}

public class HikeChartView: UIView {
    
    public var delegate: HikeChartViewDelegate?
    
    public var dataSets: [HikeChartDataSet]? {
        didSet{
            reload()
        }
    }
    var chart: Chart?
    var axisColor = UIColor.blackColor()
    
    let hikeChartAxisSettings: HikeChartAxisSettings
    
    var coordsSpace: ChartCoordsSpaceLeftBottomSingleAxis?
    
    var showingEmptyChart = false
    
    override public var frame: CGRect {
        didSet {
            reload()
        }
    }
    
    required public init(frame: CGRect, dataSets: [HikeChartDataSet], hikeChartAxisSettings: HikeChartAxisSettings) {
        self.dataSets = dataSets
        self.hikeChartAxisSettings = hikeChartAxisSettings
        super.init(frame: frame)
        
        self.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        chartInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reload() {
        chartInit()
    }
    
    private func chartInit() {
        showingEmptyChart = false
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let labelSettings = ChartLabelSettings(font: HikeChartSettings.labelFont)
            
            var chartPoints = [ChartPoint]()
            
            for dataSet in self.dataSets! {
                chartPoints.appendContentsOf(dataSet.points.map({$0.chartPoint!}))
            }
            
            var isZero = true
            for c in chartPoints {
                if c.y.scalar != 0 {
                    isZero = false
                    break
                }
            }
            
            self.showingEmptyChart = chartPoints.count <= 2 || isZero
            if self.showingEmptyChart {
                chartPoints = [ChartPoint(x: ChartAxisValue(scalar: 0), y: ChartAxisValue(scalar: 0)), ChartPoint(x: ChartAxisValue(scalar: 1000), y: ChartAxisValue(scalar: 50))]
            }
            
            
            let xAllValues = chartPoints.map({Float($0.x.scalar)})
            let xMax = xAllValues.maxElement()
            let xMin = xAllValues.minElement()
            
            let xValues = xMin?.stride(through: xMax!, by: (xMax! - xMin!) / 5).map({ChartAxisValueFloat(CGFloat($0), labelSettings: labelSettings)})
            let yValues = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 5, maxSegmentCount: 8, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: HikeChartSettings.labelSettings)}, addPaddingSegmentIfEdge: true)
            
            let xModel = ChartAxisModel(axisValues: xValues!, lineColor: self.axisColor, axisTitleLabel: ChartAxisLabel(text: self.hikeChartAxisSettings.xAxisTitle, settings: HikeChartSettings.labelSettings))
            let yModel = ChartAxisModel(axisValues: yValues, lineColor: self.axisColor, axisTitleLabel: ChartAxisLabel(text: self.hikeChartAxisSettings.yAxisTitle, settings: HikeChartSettings.labelSettings.defaultVertical()))
            
            dispatch_async(dispatch_get_main_queue(), {
                let chartFrame = HikeChartSettings.chartFrame(self.bounds)
                self.coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: HikeChartSettings.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
            
                let (xAxis, yAxis, innerFrame) = (self.coordsSpace!.xAxis, self.coordsSpace!.yAxis, self.coordsSpace!.chartInnerFrame)
                
                var layers: [ChartLayer] = [
                    xAxis,
                    yAxis
                ]
                
                for dataSet in self.dataSets! {
                    var chartPointsAreaLayerPoints = [ChartPoint]()
                    chartPointsAreaLayerPoints.appendContentsOf(dataSet.points.map({$0.chartPoint!}))
                    chartPointsAreaLayerPoints.append(ChartPoint(x: dataSet.points.last!.chartPoint!.x, y: yAxis.axisValues[0]))
                    let chartPointsAreaLayer = HikeChartPointsAreaLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPointsAreaLayerPoints, areaColor: self.showingEmptyChart ? UIColor.clearColor() : dataSet.color.colorWithAlphaComponent(0.2), animDuration: 3, animDelay: 0, addContainerPoints: true)
                    layers.append(chartPointsAreaLayer)
                }
                
                let models = self.dataSets!.map({ChartLineModel(chartPoints: $0.points.map({$0.chartPoint!}), lineColor: self.showingEmptyChart ? UIColor.clearColor() : $0.color, lineWidth: 4, animDuration: 1, animDelay: 0)})
                
                layers.append(ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: models, pathGenerator: CubicLinePathGenerator(tension1: 0.3, tension2: 0.3)))
                
                if !self.showingEmptyChart {
                    let trackerLayerSettings = HikeChartPointsLineTrackerLayerSettings(thumbSize: HikeChartSettings.isPad ? 18 : 12, thumbCornerRadius: HikeChartSettings.isPad ? 9 : 6, thumbBorderWidth: HikeChartSettings.isPad ? 4 : 2)
                    
                    let trackerLayer = HikeChartPointsLineTrackerLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, lineColor: UIColor.blackColor(), animDuration: 1, animDelay: 2, settings: trackerLayerSettings, dataSets: self.dataSets!, hikeChartAxisSettings: self.hikeChartAxisSettings)
                    
                    trackerLayer.delegate = self
                    
                    layers.append(trackerLayer)
                }
                
                let settings = ChartGuideLinesLayerSettings(linesColor: UIColor.blackColor(), linesWidth: HikeChartSettings.guidelinesWidth)
                layers.append(ChartGuideLinesLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, axis: .Y, settings: settings))
                
                let chart = Chart(frame: chartFrame, layers: layers)
                
                for view in self.subviews {
                    view.removeFromSuperview()
                }
                
                self.addSubview(chart.view)
                self.chart = chart
            })
        })
    }
}

// MARK: HikeChartViewDelegate

extension HikeChartView: HikeChartPointsLineTrackerLayerDelegate {
    public func touchesBegan(sender: AnyObject!) {
        guard let delegate = delegate else {
            return
        }
        delegate.touchesBegan(self)
    }
    
    public func touchesMoved(sender: AnyObject!) {
        guard let delegate = delegate else {
            return
        }
        delegate.touchesMoved(self)
    }
    
    public func touchesEnded(sender: AnyObject!) {
        guard let delegate = delegate else {
            return
        }
        delegate.touchesEnded(self)
    }
    
    public func touchesCancelled(sender: AnyObject!) {
        guard let delegate = delegate else {
            return
        }
        delegate.touchesCancelled(self)
    }
}
