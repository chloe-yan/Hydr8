//
//  BasicBarChartPresenter.swift
//  Hydra
//
//  Created by Chloe Yan on 2/13/20.
//  Copyright © 2020 Chloe Yan. All rights reserved.
//

import Foundation
import CoreGraphics.CGGeometry

class BasicBarChartPresenter {
    /// the width of each bar
    let barWidth: CGFloat
    
    /// the space between bars
    let space: CGFloat
    
    /// space at the bottom of the bar to show the title
    private let bottomSpace: CGFloat = 40.0
    
    /// space at the top of each bar to show the value
    private let topSpace: CGFloat = 40.0
    
    var dataEntries: [DataEntry] = []
    
    init(barWidth: CGFloat = 40, space: CGFloat = 20) {
        self.barWidth = barWidth
        self.space = space
    }
    
    func computeContentWidth() -> CGFloat {
        return (barWidth + space) * CGFloat(dataEntries.count) + space
    }
    
    func computeBarEntries(viewHeight: CGFloat) -> [BasicBarEntry] {
        var result: [BasicBarEntry] = []
        
        var max = 0.0
        for i in dataEntries {
            if (i.textValue != "") {
                if (Double(i.textValue)! > max) {
                     max = Double(i.textValue)!
                 }
            }
        }

        for (index, entry) in dataEntries.enumerated() {
            var entryHeight = 2.0
            if (entry.textValue != "0" && entry.textValue != "") {
                entryHeight = (135.0/Double(max))*Double(entry.textValue)!
            }
            let xPosition: CGFloat = space + CGFloat(index) * (barWidth + space)
            let yPosition = viewHeight - bottomSpace - CGFloat(entryHeight)
            let origin = CGPoint(x: xPosition, y: yPosition)
            
            let barEntry = BasicBarEntry(origin: origin, barWidth: barWidth, barHeight: CGFloat(entryHeight), space: space, data: entry)
            
            result.append(barEntry)
        }
        return result
    }
}
