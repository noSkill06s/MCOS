//
//  ChartTimeFrameButtonTapped.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 08.08.23.
//

import UIKit

func presentTimeFrameSelector(in controller: UIViewController, selectionHandler: @escaping (TimeFrame) -> Void) {
    let actionSheet = UIAlertController(title: "Select Time Frame", message: nil, preferredStyle: .actionSheet)
    
    let timeFrames: [TimeFrame] = [.oneMinutes, .fiveMinutes, .fifteenMinutes, .thirtyMinutes, .oneHour, .fourHours, .oneDay]
    for timeFrame in timeFrames {
        let actionTitle: String
        switch timeFrame {
        case .oneMinutes: actionTitle = "1 Minute"
        case .fiveMinutes: actionTitle = "5 Minutes"
        case .fifteenMinutes: actionTitle = "15 Minutes"
        case .thirtyMinutes: actionTitle = "30 Minutes"
        case .oneHour: actionTitle = "1 Hour"
        case .fourHours: actionTitle = "4 Hours"
        case .oneDay: actionTitle = "1 Day"
        }
        
        let action = UIAlertAction(title: actionTitle, style: .default) { _ in
            selectionHandler(timeFrame)
        }
        actionSheet.addAction(action)
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    actionSheet.addAction(cancelAction)
    
    controller.present(actionSheet, animated: true, completion: nil)
}
