//
//  CustomSegments.swift
//  Hydra
//
//  Created by Chloe Yan on 2/13/20.
//  Copyright © 2020 Chloe Yan. All rights reserved.
//

import Foundation
import CoreGraphics.CGGeometry

struct CurvedSegment {
    let startPoint: CGPoint
    let endPoint: CGPoint
    let toPoint: CGPoint
    let controlPoint1: CGPoint
    let controlPoint2: CGPoint
}

struct LineSegment {
    let startPoint: CGPoint
    let endPoint: CGPoint
}
