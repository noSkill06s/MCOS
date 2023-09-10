//
//  ChartStartPulsingLastPoint.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 10.09.23.
//

import Foundation

class PulsingManager {
    
    weak var viewController: ChartController? // Referenz zum Haupt-ViewController
    
    init(controller: ChartController) {
        self.viewController = controller
    }
    
    @objc func startPulsingLastPoint() {
        guard let viewController = self.viewController else { return }
        
        let stepSize = CGFloat(10.0)
        // Verwenden Sie eine Bedingung, um zwischen den Größen zu wechseln
        if viewController.lastPointSymbolSize.width > 10.0 {
            viewController.lastPointSymbolSize = CGSize(width: viewController.lastPointSymbolSize.width - stepSize, height: viewController.lastPointSymbolSize.height - stepSize)
        } else {
            viewController.lastPointSymbolSize = CGSize(width: viewController.lastPointSymbolSize.width + stepSize, height: viewController.lastPointSymbolSize.height + stepSize)
        }
        
        DispatchQueue.main.async {
            viewController.graphView.hostedGraph?.reloadData()
        }
    }
}
