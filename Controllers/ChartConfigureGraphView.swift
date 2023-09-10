//
//  ChartConfigureGraphView.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 08.08.23.
//

import CorePlot
import UIKit

func configureGraphView(for graphView: CPTGraphHostingView, plotData: [StockDataPoint], delegate: CPTAxisDelegate) {
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

    // Set plot space
    let xMin = 0.0 // Starten Sie von 0
    let xMax = Double(plotData.count) // Die maximale Zahl ist die Anzahl der Datenpunkte

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
    //gridLineStyle.lineColor = CPTColor.gray()
    //gridLineStyle.lineWidth = 0.5

    if let x = axisSet.xAxis {
        x.majorIntervalLength   = 1.0 // Setzen Sie das Intervall auf 1, da jeder Punkt einen Abstand von 1 hat
        x.minorTicksPerInterval = 0
        x.labelTextStyle = axisTextStyle
        x.minorGridLineStyle = gridLineStyle
        x.axisLineStyle = lineStyle  // Behalten Sie diese Zeile bei, um die Achsenlinie zu behalten
        x.axisConstraints = CPTConstraints(lowerOffset: 0.0)
        x.delegate = delegate

        // Zeilen zum Ausblenden der Achse und Labels
        x.axisLabels = nil      // Labels ausblenden
        x.majorTickLineStyle = nil  // Major Tick-Linien ausblenden
        x.minorTickLineStyle = nil  // Minor Tick-Linien ausblenden

        x.labelingPolicy = .none
        x.labelRotation = CGFloat(Double.pi / 4) // Drehen Sie die Labels für bessere Sichtbarkeit
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
