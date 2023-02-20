//
//  Stadium.swift
//  SeatingChart
//
//  Created by gzonelee on 2023/02/20.
//

import SwiftUI

struct Stadium: Shape {
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.addRoundedRect(in: rect, cornerSize: .init(width: 20, height: 20))
        }
    }
}

struct Stadium_Previews: PreviewProvider {
    static var previews: some View {
        Stadium()
            .stroke(lineWidth: 1)
            .padding()
    }
}
