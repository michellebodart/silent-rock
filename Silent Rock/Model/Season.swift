//
//  Season.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 2/3/22.
//

import Foundation
import UIKit

class Season {
    func getSeasons() -> [String] {
        let date = Date().description
        let year = Int(date.prefix(4))!
        let month = Int(date.dropFirst(5).prefix(2))!
        var result = [String]()
        let range = 2010...year-1
        for i in range {
            let season = String(i) + "-" + String(i+1)
            result.append(season)
        }
        if month >= 11 {
            let season = String(year) + "-" + String(year+1)
            result.append(season)
        }
        return result.reversed()
    }
}
