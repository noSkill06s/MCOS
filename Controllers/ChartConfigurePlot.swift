//
//  ChartConfigurePlot.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 08.08.23.
//

import CorePlot
import UIKit

func configurePlot(for graphView: CPTGraphHostingView, dataSource: CPTScatterPlotDataSource, delegate: CPTScatterPlotDelegate) {
    // Hauptplot
    let mainPlot = CPTScatterPlot()
    let mainPlotLineStyle = CPTMutableLineStyle()
    mainPlotLineStyle.lineJoin = .round
    mainPlotLineStyle.lineCap = .round
    mainPlotLineStyle.lineWidth = 2
    mainPlotLineStyle.lineColor = CPTColor.white()
    mainPlot.dataLineStyle = mainPlotLineStyle
    mainPlot.curvedInterpolationOption = .catmullCustomAlpha
    mainPlot.interpolation = .linear
    mainPlot.identifier = "main-plot" as NSCoding & NSCopying & NSObjectProtocol
    
    // Zusätzlicher Plot für den letzten Datenpunkt
    let lastPointPlot = CPTScatterPlot()
    let lastPointPlotLineStyle = CPTMutableLineStyle()
    lastPointPlotLineStyle.lineJoin = .round
    lastPointPlotLineStyle.lineCap = .round
    lastPointPlotLineStyle.lineWidth = 4 // Größere Linienbreite
    lastPointPlotLineStyle.lineColor = CPTColor.white() // Rote Farbe für den letzten Punkt
    lastPointPlot.dataLineStyle = lastPointPlotLineStyle
    lastPointPlot.curvedInterpolationOption = .catmullCustomAlpha
    lastPointPlot.interpolation = .linear
    lastPointPlot.identifier = "last-point-plot" as NSCoding & NSCopying & NSObjectProtocol
    
    guard let graph = graphView.hostedGraph else { return }
    
    // Datenquelle und Delegate für beide Plots festlegen
    mainPlot.dataSource = dataSource
    mainPlot.delegate = delegate
    lastPointPlot.dataSource = dataSource
    lastPointPlot.delegate = delegate
    
    // Beide Plots zum Graphen hinzufügen
    graph.add(mainPlot, to: graph.defaultPlotSpace)
    graph.add(lastPointPlot, to: graph.defaultPlotSpace)
}



