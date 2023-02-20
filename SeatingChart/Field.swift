//
//  Field.swift
//  SeatingChart
//
//  Created by gzonelee on 2023/02/20.
//

import SwiftUI

struct Field: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addRect(rect)
            path.move(to: .init(x: rect.midX, y: rect.minY))
            path.addLine(to: .init(x: rect.midX, y: rect.maxY))
            let len = min(rect.width, rect.height)
            let r = len / 4
            path.addEllipse(in: .init(x: rect.midX - r, y: rect.midY - r, width: 2 * r, height: 2 * r))
        }
    }
}

struct Field_Previews: PreviewProvider {
    static var previews: some View {
        Field()
            .stroke(.blue, lineWidth: 2)
            .padding()
    }
}
