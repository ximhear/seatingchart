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
        (0..<hc).forEach { index in
            let x = rect.minX + corner + sph / 2.0 + (tribuneSize.width + sph) * Double(index)
            tribunes.append(makeRectTribuneAt(x: x, y: rect.minY + offset, vertical: false, rotation: 0))
            tribunes.append(makeRectTribuneAt(x: x, y: rect.maxY - offset - tribuneSize.height, vertical: false, rotation: -.pi))
        }
        
        (0..<vc).forEach { index in
            let y = rect.minY + corner + spv / 2.0 + (tribuneSize.width + spv) * Double(index)
            tribunes.append(makeRectTribuneAt(x: rect.minX + offset, y: y, vertical:  true, rotation: -.pi / 2.0))
            tribunes.append(makeRectTribuneAt(x: rect.maxX - offset - tribuneSize.height, y: y, vertical: true, rotation: .pi / 2.0))
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
                return Tribune(path: arcTribune.path(in: .zero), seats: computeSeats(for: arcTribune))
            }
            partialResult.append(contentsOf: arcTribunes)
        }
    }
    
    private func makeRectTribuneAt(x: CGFloat, y: CGFloat, vertical: Bool, rotation: CGFloat) -> Tribune {
        let rect = CGRect(x: x,
                          y: y,
                          width: vertical ? tribuneSize.height : tribuneSize.width,
                          height: vertical ? tribuneSize.width : tribuneSize.height)
        return Tribune(path: RectTribune().path(in: rect),
                       seats: computeSeats(for: rect, at: rotation))
    }
    
    func computeSeats(for tribune: CGRect, at rotation: CGFloat) -> [Seat] {
        let seatSize = tribuneSize.height * 0.1
        let colNumber = Int(tribune.width / seatSize)
        let rowNumber = Int(tribune.height / seatSize)
        let sh = (tribune.width - CGFloat(colNumber) * seatSize) / CGFloat(colNumber)
        let sv = (tribune.height - CGFloat(rowNumber) * seatSize) / CGFloat(rowNumber)
        var seats: [Seat] = []
        (0..<colNumber).forEach { col in
            let x = tribune.minX + sh / 2.0 + (sh + seatSize) * CGFloat(col)
            (0..<rowNumber).forEach { row in
                let y = tribune.minY + sv / 2.0 + (sv + seatSize) * CGFloat(row)
                let sr = CGRect(x: x, y: y, width: seatSize, height: seatSize)
                GZLogFunc(sr)
                seats.append(Seat(id: "\(row) \(col)", path: SeatShape(rotation: rotation).path(in: sr)))
            }
        }
        return seats
    }
    
    func computeSeats(for arcTribune: ArcTribune) -> [Seat] {
        let seatSize = tribuneSize.height * 0.1
        let rowNumber = Int(tribuneSize.height / seatSize)
        let sv = (tribuneSize.height - CGFloat(rowNumber) * seatSize) / CGFloat(rowNumber)
        var seats: [Seat] = []
        (0..<rowNumber).forEach { row in
            let r = arcTribune.or - sv / 2.0 - (sv + seatSize) * CGFloat(row) - seatSize
            let arcLength = (arcTribune.ea - arcTribune.sa) * r
            let theta = asin(seatSize / 2.0 / r) * 2.0
            let cnt = Int(arcLength / (r * theta))
            let spaceAngle: CGFloat = ((arcTribune.ea - arcTribune.sa) - theta * CGFloat(cnt)) / CGFloat(cnt)
            (0..<cnt).forEach { index in
                let sa = arcTribune.sa + spaceAngle / 2.0 + (theta + spaceAngle) * CGFloat(index) + theta / 2.0
                let seatCenter = CGPoint(
                    x: arcTribune.center.x + (r + seatSize / 2.0) * cos(sa),
                    y: arcTribune.center.y + (r + seatSize / 2.0) * sin(sa))
                let seatRect = CGRect(x: seatCenter.x - seatSize / 2.0,
                                      y: seatCenter.y - seatSize / 2.9,
                                      width: seatSize,
                                      height: seatSize)
                seats.append(Seat(id: "\(row) \(index)", path: SeatShape(rotation: sa + .pi / 2.0).path(in: seatRect)))
            }
        }
        return seats
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
