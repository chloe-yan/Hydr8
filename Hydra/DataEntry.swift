//
//  DataEntry.swift
//  Hydra
//
//  Created by Chloe Yan on 2/13/20.
//  Copyright © 2020 Chloe Yan. All rights reserved.
//

import Foundation
import UIKit

struct DataEntry {
    let color: UIColor
    
    /// Ranged from 0.0 to 1.0
    let height: Double
    
    /// To be shown on top of the bar
    let textValue: String
    
    /// To be shown at the bottom of the bar
    let title: String
}
