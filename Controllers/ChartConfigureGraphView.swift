//
//  ChartConfigureGraphView.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 08.08.23.
//

import CorePlot
import UIKit

func configureGraphView(for graphView: CPTGraphHostingView, plotData: [(date: String, close: Double)], delegate: CPTAxisDelegate) {
    graphView.allowPinchScaling = false
            
    // Configure graph
    let graph = CPTXYGraph(frame: graphView.bounds)
    graph.plotAreaFrame?.masksToBorder = false
    graphView.hostedGraph = graph
    graph.backgroundColor = UIColor.black.cgColor
    graph.paddingBottom = 40.0
    graph.paddingLeft = 50.0 // ursprünglich 40
    graph.paddingTop = 30.0
    graph.paddingRight = 5.0 // ursprünglich 15
    
    // Style for graph title
    let titleStyle = CPTMutableTextStyle()
    titleStyle.color = CPTColor.white()
    titleStyle.fontName = "HelveticaNeue-Bold"
    titleStyle.fontSize = 20.0
    titleStyle.textAlignment = .center
    graph.titleTextStyle = titleStyle

    // Set graph title
    let title = "CorePlot"
    graph.title = title
    graph.titlePlotAreaFrameAnchor = .top
    graph.titleDisplacement = CGPoint(x: 0.0, y: 0.0)

    // Set plot space
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

    let xMin = dateFormatter.date(from: plotData.first?.date ?? "")?.timeIntervalSince1970 ?? 0
    let xMax = dateFormatter.date(from: plotData.last?.date ?? "")?.timeIntervalSince1970 ?? 0

    let yMin = plotData.min(by: { $0.close < $1.close })?.close ?? 0
    let yMax = plotData.max(by: { $0.close < $1.close })?.close ?? 0

    let yRange = yMax - yMin
    let paddingPercentage = 0.05 // 5% Padding

    let yMinAdjusted = yMin - (yRange * paddingPercentage)
    let yMaxAdjusted = yMax + (yRange * paddingPercentage)
    let adjustedRange = yMaxAdjusted - yMinAdjusted
    let majorInterval = adjustedRange / 10.0 // Teilt den Bereich in 10 Intervalle

    guard let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace else { return }
    plotSpace.xRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(xMin), lengthDecimal: CPTDecimalFromDouble(xMax - xMin)) // Set xRange
    plotSpace.yRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(yMinAdjusted), lengthDecimal: CPTDecimalFromDouble(yMaxAdjusted - yMinAdjusted))

    // Configure axes
    let axisSet = graph.axisSet as! CPTXYAxisSet
    
    let axisTextStyle = CPTMutableTextStyle()
    axisTextStyle.color = CPTColor.white()
    axisTextStyle.fontName = "HelveticaNeue-Bold"
    axisTextStyle.fontSize = 10.0
    axisTextStyle.textAlignment = .center
    let lineStyle = CPTMutableLineStyle()
    lineStyle.lineColor = CPTColor.white()
    lineStyle.lineWidth = 5
    let gridLineStyle = CPTMutableLineStyle()
    gridLineStyle.lineColor = CPTColor.gray()
    gridLineStyle.lineWidth = 0.5

    if let x = axisSet.xAxis {
        x.majorIntervalLength   = 1
        x.minorTicksPerInterval = 0
        x.labelTextStyle = axisTextStyle
        x.minorGridLineStyle = gridLineStyle
        x.axisLineStyle = lineStyle
        x.axisConstraints = CPTConstraints(lowerOffset: 0.0)
        x.delegate = delegate

        // Set the x-axis to display dates
        x.labelingPolicy = .none

        // Create custom labels for each data point
        var customLabels = Set<CPTAxisLabel>()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Use the full format to extract the date
        let labelFormatter = DateFormatter()
        labelFormatter.dateFormat = "HH:mm" // Use the short format for the label
        for dataPoint in plotData {
            let date = dateFormatter.date(from: dataPoint.date) ?? Date()
            let calendar = Calendar.current
            if calendar.component(.minute, from: date) == 0 { // Only add label for full hours
                let labelTextStyle = CPTMutableTextStyle()
                labelTextStyle.color = CPTColor.white()
                labelTextStyle.fontSize = 10.0
                let label = CPTAxisLabel(text: labelFormatter.string(from: date), textStyle: labelTextStyle) // Use the short format here
                label.tickLocation = NSNumber(value: date.timeIntervalSince1970)
                label.offset = 3.0
                customLabels.insert(label)
            }
        }
        x.axisLabels = customLabels
    }

    if let y = axisSet.yAxis {
        y.majorIntervalLength = NSNumber(value: majorInterval) // Setzen Sie den berechneten Wert hier
        y.minorTicksPerInterval = 5 // Dieser Wert hängt von dem Bereich Ihrer Schlusskurse ab und sollte entsprechend angepasst werden
        y.minorGridLineStyle = gridLineStyle
        y.labelTextStyle = axisTextStyle
        y.alternatingBandFills = [CPTFill(color: CPTColor.init(componentRed: 255, green: 255, blue: 255, alpha: 0.03)),CPTFill(color: CPTColor.black())]
        y.axisLineStyle = lineStyle
        y.axisConstraints = CPTConstraints(lowerOffset: 0.0)
        y.delegate = delegate
    }
}
