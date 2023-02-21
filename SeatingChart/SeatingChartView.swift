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
    @State var selectedTribune: Tribune?
    @State var zoom = 1.0
    @State var zoomAnchor = UnitPoint.center
    @State var size: CGSize = .zero
    
    var body: some View {
        VStack {
            Text("\(zoomAnchor.x) x \(zoomAnchor.y)")
            Text("\(size.width) x \(size.height)")
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
                                    .fill(selectedTribune == tribune ? .white : .blue)
                            }
                            .onTapGesture(coordinateSpace: .named("stadium")) { tap in
                                let unselected = selectedTribune == tribune
                                let anchor = UnitPoint(x: tap.x / size.width, y: tap.y / size.height)
                                LinkedAnimation.easeInOut(for: 1) {
                                    zoom = unselected ? 1.0 : 12
                                }.link(to: .easeInOut(for: 1, action: {
                                    selectedTribune = unselected ? nil : tribune
                                    zoomAnchor = unselected ? .center : anchor
                                }), reverse: !unselected)
                            }
                    }
                    Field().path(in: fieldRect)
                        .trim(from: 0, to: percentage)
                        .fill(.green)
                    Field().path(in: fieldRect)
                        .trim(from: 0, to: percentage)
                        .stroke(.red, lineWidth: 3)
                }
            }
            .coordinateSpace(name: "stadium")
            .scaleEffect(zoom, anchor: zoomAnchor)
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
            .overlay {
                GeometryReader<Color> { proxy in
                    Task {
                        size = proxy.size
                    }
                    return Color.clear
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
