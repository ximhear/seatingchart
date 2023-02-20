//
//  SeatingChartView.swift
//  SeatingChart
//
//  Created by gzonelee on 2023/02/20.
//

import SwiftUI

struct SeatingChartView: View {
    @State var fieldRect: CGRect = .zero
    @State private var tribunes: [Int: [Tribune]] = [:]
    var body: some View {
        VStack {
            ZStack {
                Group {
                    Stadium(fieldRect: $fieldRect, tribunes: $tribunes)
                        .stroke(.secondary, lineWidth: 2)
                    ForEach(tribunes.flatMap(\.value), id: \.self) { tribune in
                        tribune.path
                            .stroke(.purple, style: StrokeStyle(lineWidth: 1, lineJoin: .round))
                    }
                    Field().path(in: fieldRect).fill(.green)
                    Field().path(in: fieldRect).stroke(.red, lineWidth: 3)
                }
                .padding()
            }
            .aspectRatio(contentMode: .fit)
            .background(.green.opacity(0.2))
            .padding()
        }
    }
}

struct SeatingChartView_Previews: PreviewProvider {
    static var previews: some View {
        SeatingChartView()
    }
}
