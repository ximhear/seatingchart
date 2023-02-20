//
//  Sector.swift
//  SeatingChart
//
//  Created by gzonelee on 2023/02/21.
//

import SwiftUI

struct Sector: Shape {
    @Binding var tribunes: [Int: [Tribune]]
    var index: Int
    var tribuneSize: CGSize
    var offset: CGFloat
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let corner = rect.width / 4.0
            path.addRoundedRect(in: rect, cornerSize: .init(width: corner, height: corner), style: .continuous)
            guard !tribunes.keys.contains(where: { $0 == index }) else {
                return
            }
            Task {
                tribunes[index] = computeTribunes(at: rect, with: corner)
            }
        }
    }
    
    private func computeTribunes(at rect: CGRect, with corner: CGFloat) -> [Tribune] {
        computeRectTribunesPaths(at: rect, corner: corner) + computeArcTribunesPaths(at: rect, corner: corner)
    }
    
    private func computeRectTribunesPaths(at rect: CGRect, corner: CGFloat) -> [Tribune] {
        let sw = rect.width - corner * 2
        let sh = rect.height - corner * 2
        let hc = Int(sw / tribuneSize.width)
        let vc = Int(sh / tribuneSize.width)
        let sph = (sw - Double(hc) * tribuneSize.width) / Double(hc)
        let spv = (sh - Double(vc) * tribuneSize.width) / Double(vc)
        var tribunes: [Tribune] = []
        (0..<Int(hc)).forEach { index in
            let x = rect.minX + corner + sph / 2.0 + (tribuneSize.width + sph) * Double(index)
            tribunes.append(makeRectTribuneAt(x: x, y: rect.minY + offset))
            tribunes.append(makeRectTribuneAt(x: x, y: rect.maxY - offset - tribuneSize.height))
        }
        
        (0..<Int(vc)).forEach { index in
            let y = rect.minY + corner + spv / 2.0 + (tribuneSize.width + spv) * Double(index)
            tribunes.append(makeRectTribuneAt(x: rect.minX + offset, y: y, rotated:  true))
            tribunes.append(makeRectTribuneAt(x: rect.maxX - offset - tribuneSize.height, y: y, rotated: true))
        }
        return tribunes
    }
    
    private func computeArcTribunesPaths(at rect: CGRect, corner: CGFloat) -> [Tribune] {
        
        let or = corner - offset
        let ir = corner - offset - tribuneSize.height
        let arcLength = ir * (.pi / 2)
        let theta = asin(tribuneSize.width / 2.0 / ir) * 2.0
        let cnt = Int(arcLength / (ir * theta))
        let spaceAngle = (Double.pi / 2.0 - theta * Double(cnt)) / Double(cnt)
        
        let arcs: [CGFloat: CGPoint] = [
            .pi: .init(x: rect.minX + corner, y: rect.minY + corner),
            3 * .pi / 2 : .init(x: rect.maxX - corner, y: rect.minY + corner),
            0: .init(x: rect.maxX - corner, y: rect.maxY - corner),
            .pi / 2 : .init(x: rect.minX + corner, y: rect.maxY - corner)
        ]
        
        return arcs.reduce(into: [Tribune]()) { partialResult, arc in
            var sa = arc.key + spaceAngle / 2.0
            let center = arc.value
            let arcTribunes = (0..<cnt).map { index in
                let osp = CGPoint(
                    x: center.x + or * cos(sa),
                    y: center.y + or * sin(sa))
                let isp = CGPoint(
                    x: center.x + ir * cos(sa + theta),
                    y: center.y + ir * sin(sa + theta))
                
                
                let arcTribune = ArcTribune(
                    center: center,
                    or: or,
                    osp: osp,
                    ir: ir,
                    isp: isp,
                    sa: sa, ea: sa + theta)
                
                sa += theta + spaceAngle
                return Tribune(path: arcTribune.path(in: .zero))
            }
            partialResult.append(contentsOf: arcTribunes)
        }
    }
    
    private func makeRectTribuneAt(x: CGFloat, y: CGFloat, rotated: Bool = false) -> Tribune {
        Tribune(path: RectTribune().path(in: .init(x: x, y: y, width: rotated ? tribuneSize.height : tribuneSize.width, height: rotated ? tribuneSize.width : tribuneSize.height)))
    }
}

struct Sector_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Sector(tribunes: .constant([:]), index: 0, tribuneSize: .init(width: 30, height: 10), offset: 60)
                .stroke(.green, lineWidth: 3)
        }
        .padding()
    }
}
