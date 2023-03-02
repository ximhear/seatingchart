//
//  SeatShape.swift
//  SeatingChart
//
//  Created by gzonelee on 2023/03/03.
//

import SwiftUI

struct SeatShape: Shape {
    let rotation: CGFloat
    func path(in rect: CGRect) -> Path {
        Path { path in
            let vs = rect.height * 0.1
            let cornerSize = CGSize(width: rect.width / 15.0, height: rect.height / 15.0)
            let seatBackHeight = rect.height / 3.0 - vs
            let skewAngle = Double.pi / 3.0
            let skewShift = (rect.height / 2.0 - vs) / tan(skewAngle)
            let squbHeight = rect.height / 2.0 - vs
            let seatWidth = rect.width - skewShift
            let oy = (rect.height / 2.0 - rect.height / 3.0)
            
            let skew = CGAffineTransform(1, 0, -1 / tan(skewAngle), 1, skewShift, vs)
            
            let backRect = CGRect(x: 0, y: 0, width: seatWidth, height: seatBackHeight)
            let squabRect = CGRect(x: 0, y: rect.height / 2.0 , width: seatWidth, height: squbHeight)
            path.addRoundedRect(in: backRect, cornerSize: cornerSize, transform: skew)
            path.addRoundedRect(in: squabRect, cornerSize: cornerSize)
            path.move(to: .init(x: rect.width / 2.0 + oy / tan(skewAngle) - skewShift / 2.0, y: rect.height / 3.0))
            path.addLine(to: .init(x: rect.width / 2.0 - skewShift / 2.0, y: rect.height / 2.0))
            let rotationCenter = CGPoint(x: rect.width / 2.0, y: rect.height / 2.0)
            let t = CGAffineTransform(translationX: -rect.width / 2.0, y: -rect.height / 2.0 )
            let tb = CGAffineTransform(translationX: rect.width / 2.0, y: rect.height / 2.0 )
            path = path.applying(t)
            path = path.applying(CGAffineTransform(rotationAngle: rotation))
            path = path.applying(tb)
        }
    }
}

struct SeatPreview: View {
    let seatSize = 200.0
    @State var rotation: Float = 0.0
    var body: some View {
        VStack {
            ZStack {
                SeatShape(rotation: CGFloat(-rotation)).path(in: .init(x: 0, y: 0, width: seatSize, height: seatSize))
                    .fill(.blue)
                SeatShape(rotation: CGFloat(-rotation)).path(in: .init(x: 0, y: 0, width: seatSize, height: seatSize))
                    .stroke(lineWidth: 2)
            }
            .frame(width: seatSize, height: seatSize)
            .background(.yellow)
            Slider(value: $rotation, in: 0.0...(2 * .pi), step: .pi / 20)
            Text("\(rotation)")
        }
        .padding()
    }
}

struct SeatShape_Previews: PreviewProvider {
    static var previews: some View {
        SeatPreview()
    }
}
