//
//  ChartLoadStockProfile.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 10.09.23.
//

import UIKit

class StockProfileManager {
    
    weak var viewController: ChartController? // Referenz zum Haupt-ViewController

    init(controller: ChartController) {
        self.viewController = controller
    }

    func loadStockProfile() {
        let profileFetcher = StockProfileFetcher()
        profileFetcher.fetchProfile(for: viewController?.searchStock ?? "") { [weak self] result in
            switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    self?.viewController?.stockProfileSymbol.text = profile.symbol
                    self?.viewController?.stockProfileCompanyName.text = "   " + profile.companyName
                    self?.viewController?.stockProfileCurrency.text = profile.currency
                    
                    // Bild von URL laden
                    if let url = URL(string: profile.image) {
                        print("profile.image: \(url)")
                        DispatchQueue.global().async {
                            if let data = try? Data(contentsOf: url) {
                                DispatchQueue.main.async {
                                    self?.viewController?.stockProfileImage.image = UIImage(data: data)
                                }
                            }
                        }
                    }
                }
            case .failure(let error):
                print("Failed to fetch profile: \(error)")
            }
        }
    }
}

