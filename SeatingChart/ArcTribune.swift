//
//  ArcTribune.swift
//  SeatingChart
//
//  Created by gzonelee on 2023/02/21.
//

import SwiftUI

struct ArcTribune: Shape {
    let center: CGPoint
    let or: CGFloat
    let osp: CGPoint
    let ir: CGFloat
    let isp: CGPoint
    let sa: CGFloat
    let ea: CGFloat
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: osp)
            path.addArc(center: center,
                        radius: or,
                        startAngle: .radians(sa),
                        endAngle: .radians(ea),
                        clockwise: false)
            path.addLine(to: isp)
            path.addArc(center: center,
                        radius: ir,
                        startAngle: .radians(ea),
                        endAngle: .radians(sa),
                        clockwise: true)
            path.closeSubpath()
        }
    }
}
struct ArcTribune_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ArcTribune(center:
                    .init(x: 100, y: 100),
                       or: 50,
                       osp: .init(x: 50, y: 100),
                       ir: 30,
                       isp: .init(x: 100, y: 70),
                       sa: .pi,
                       ea: .pi * 3 / 2)
                .stroke(.red, lineWidth: 3)
        }
    }
}
