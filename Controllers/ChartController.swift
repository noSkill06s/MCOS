//
//  ChartController.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 31.07.23.
//

import UIKit

class ChartController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Erstelle eine Instanz von StockDataFetcher und rufe die fetch-Methode auf.
        let fetcher = StockDataFetcher()
        fetcher.fetch { result in
            switch result {
            case .success(let data):
                print("Received data: \(data)")
                // Hier könntest du die Daten verwenden, um dein Diagramm zu aktualisieren.
            case .failure(let error):
                print("An error occurred: \(error)")
                // Hier könntest du eine Fehlermeldung anzeigen.
            }
        }
    }
}

