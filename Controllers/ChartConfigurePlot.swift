//
//  ChartConfigurePlot.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 08.08.23.
//

import CorePlot
import UIKit

func configurePlot(for graphView: CPTGraphHostingView, dataSource: CPTScatterPlotDataSource, delegate: CPTScatterPlotDelegate) {
    let plot = CPTScatterPlot()
    let plotLineStile = CPTMutableLineStyle()
    plotLineStile.lineJoin = .round
    plotLineStile.lineCap = .round
    plotLineStile.lineWidth = 2
    plotLineStile.lineColor = CPTColor.white()
    plot.dataLineStyle = plotLineStile
    plot.curvedInterpolationOption = .catmullCustomAlpha
    plot.interpolation = .linear
    plot.identifier = "coreplot-graph" as NSCoding & NSCopying & NSObjectProtocol
    guard let graph = graphView.hostedGraph else { return }
    plot.dataSource = dataSource
    plot.delegate = delegate
    graph.add(plot, to: graph.defaultPlotSpace)
}

