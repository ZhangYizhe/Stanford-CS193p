//
//  Pie.swift
//  Memorize
//
//  Created by 张艺哲 on 2020/12/26.
//

import SwiftUI

struct Pie : Shape {
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        var p = Path()
        p.move(to: center)
        
        
        return p
    }
}
