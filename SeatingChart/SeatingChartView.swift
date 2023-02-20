//
//  SeatingChartView.swift
//  SeatingChart
//
//  Created by gzonelee on 2023/02/20.
//

import SwiftUI

struct SeatingChartView: View {
    @State var fieldRect: CGRect = .zero
    var body: some View {
        ZStack {
           Stadium(fieldRect: $fieldRect)
                .stroke(.secondary, lineWidth: 2)
                .padding()
        }
        .aspectRatio(contentMode: .fit)
        .background(.green.opacity(0.2))
        .padding()
    }
}

struct SeatingChartView_Previews: PreviewProvider {
    static var previews: some View {
        SeatingChartView()
    }
}
