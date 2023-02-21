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
    @State private var percentage: CGFloat = 0
    
    var body: some View {
        VStack {
            ZStack {
                Group {
                    Stadium(fieldRect: $fieldRect, tribunes: $tribunes)
                        .trim(from: 0, to: percentage)
                        .stroke(.secondary, lineWidth: 2)
                    ForEach(tribunes.flatMap(\.value), id: \.self) { tribune in
                        tribune.path
                            .trim(from: 0, to: percentage)
                            .stroke(.purple, style: StrokeStyle(lineWidth: 1, lineJoin: .round))
                            .background {
                                tribune.path
                                    .trim(from: 0, to: percentage)
                                    .fill(.blue)
                            }
                    }
                    Field().path(in: fieldRect)
                        .trim(from: 0, to: percentage)
                        .fill(.green)
                    Field().path(in: fieldRect)
                        .trim(from: 0, to: percentage)
                        .stroke(.red, lineWidth: 3)
                }
                .padding()
            }
            .aspectRatio(contentMode: .fit)
            .background(.green.opacity(0.2))
            .padding()
            .onChange(of: tribunes) {
                guard $0.keys.count == Constants.sectorCount else {
                    return
                }
                withAnimation(.easeInOut(duration: 1)) {
                    percentage = 1
                }
            }
        }
    }
}

struct SeatingChartView_Previews: PreviewProvider {
    static var previews: some View {
        SeatingChartView()
    }
}
