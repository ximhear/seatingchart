//
//  RectTribune.swift
//  SeatingChart
//
//  Created by gzonelee on 2023/02/21.
//

import SwiftUI

struct RectTribune: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addRect(rect)
            path.closeSubpath()
        }
    }
}

struct RectTribune_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            RectTribune()
                .path(in: .init(x: 0, y: 0, width: 100, height: 100))
                .offsetBy(dx: 30, dy: 30)
                .offset(.init(width: 130, height: 30))
                .stroke(.red, lineWidth: 10)
                .background(.green)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
