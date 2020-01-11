//
//  DataGenerator.swift
//  Hydra
//
//  Created by Chloe Yan on 1/5/20.
//  Copyright © 2020 Chloe Yan. All rights reserved.
//

import Foundation
 
struct Sale {
    var month: String
    var value: Double
}
 
class DataGenerator {
    
    static var randomizedSale: Double {
        return Double(arc4random_uniform(10000) + 1) / 10
    }
    
    static func data() -> [Sale] {
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        var sales = [Sale]()
 
        for month in months {
            let sale = Sale(month: month, value: randomizedSale)
            sales.append(sale)
        }
        
        return sales
    }
}
