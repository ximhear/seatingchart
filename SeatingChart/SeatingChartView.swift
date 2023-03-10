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
    @GestureState var drag: CGSize = .zero
    @State var offset: CGSize = .zero
    @GestureState var manualZoom = 1.0
    @GestureState var currentRotation: Angle = .radians(0)
    @State var rotation: Angle = .radians(0)
    @State var selectedSeats: [Seat] = []
    @State var seatPercentage: CGFloat = .zero
    @Binding var zoomed: Bool
    @Binding var selectedTicketsNumber: Int
    
    var dragging: some Gesture {
        DragGesture()
            .updating($drag) { value, state, transaction in
                state = value.translation
            }
            .onEnded { value in
                offset = offset + value.translation
            }
    }
    
    var magnification: some Gesture {
        MagnificationGesture()
            .updating($manualZoom) { value, state, transaction in
                state = value
            }
            .onEnded { value in
                zoom *= value
                withAnimation {
                    zoomed = zoom > 1.0
                }
            }
    }
    
    var rotationGesture: some Gesture {
        RotationGesture()
            .updating($currentRotation) { angle, state, transaction in
                state = .radians(angle.radians)
            }
            .onEnded { value in
                rotation += value
            }
    }
    
    var body: some View {
        VStack {
            GeometryReader { proxy in
                ZStack {
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
                                    .fill(selectedTribune == tribune ? .white : .blue.opacity(0.2))
                            }
                    }
                    Field().path(in: fieldRect)
                        .trim(from: 0, to: percentage)
                        .fill(.green)
                    Field().path(in: fieldRect)
                        .trim(from: 0, to: percentage)
                        .stroke(.red, lineWidth: 3)
                    if let selectedTribune {
                        ForEach(selectedTribune.seats) { seat in
                            ZStack {
                                seat.path
                                    .trim(from: 0, to: seatPercentage)
                                    .fill(selectedSeats.contains(seat) ? .green : .blue)
                                seat.path
                                    .trim(from: 0, to: seatPercentage)
                                    .stroke(.black, lineWidth: 0.05)
                            }
                        }
                    }
                }
                .onChange(of: zoomed, perform: { newValue in
                    if !newValue && zoom > 1 {
                        LinkedAnimation.easeInOut(for: 0.7) {
                            zoom = 1.0
                            seatPercentage = 0
                        }
                        .link(to: .easeInOut(for: 0.3, action: {
                            selectedTribune = nil
                            zoomAnchor = .center
                            offset = .zero
                        }), reverse: false)
                        
                    }
                })
                .onTapGesture { tap in
                    GZLogFunc(tap)
                    if let selectedTribune, selectedTribune.path.contains(tap) {
                        findAndSelectSeat(at: tap, in: selectedTribune)
                    }
                    else {
                        findAndSelectTribune(at: tap, with: proxy)
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
//                .rotationEffect(rotation + currentRotation, anchor: zoomAnchor)
                .scaleEffect(zoom * manualZoom, anchor: zoomAnchor)
                .offset(offset + drag)
                .simultaneousGesture(dragging)
                .simultaneousGesture(magnification)
                .simultaneousGesture(rotationGesture)
                .aspectRatio(contentMode: .fit)
                .background(.green.opacity(0.2))
                .onChange(of: tribunes) {
                    guard $0.keys.count == Constants.sectorCount else {
                        return
                    }
                    withAnimation(.easeInOut(duration: 1)) {
                        percentage = 1
                    }
                }
            }
            .padding()
        }
    }
    
    func findAndSelectSeat(at point: CGPoint, in selectedTribune: Tribune) {
        guard let seat = selectedTribune.seats.first(where: { seat in
            seat.path.boundingRect.contains(point)
        }) else {
            return
        }
        withAnimation(.easeInOut) {
            if let index = selectedSeats.firstIndex(of: seat) {
                selectedSeats.remove(at: index)
            }
            else {
                selectedSeats.append(seat)
            }
            selectedTicketsNumber = selectedSeats.count
        }
    }
    
    func findAndSelectTribune(at point: CGPoint, with proxy: GeometryProxy) {
        GZLogFunc(point)
        GZLogFunc(proxy.size)
        let tribune = tribunes.flatMap(\.value)
            .first { tribune in
                tribune.path.boundingRect.contains(point)
            }
        let unselected = tribune == selectedTribune
        let anchor = UnitPoint(x: point.x / proxy.size.width,
                               y: point.y / proxy.size.height)
        seatPercentage = selectedTribune == nil || !unselected ? 0.0 : 1.0
        GZLogFunc(anchor)
        
        GZLogFunc(unselected)
        LinkedAnimation.easeInOut(for: 2.7) {
            zoom = unselected ? 1.0 : 25
            seatPercentage = unselected ? 0.0 : 1.0
            zoomed = !unselected
        }
        .link(to: .easeInOut(for: 0.3, action: {
            selectedTribune = unselected ? nil : tribune
            zoomAnchor = unselected ? .center : anchor
            offset = .zero
        }), reverse: !unselected)
    }
}

struct SeatingChartView_Previews: PreviewProvider {
    static var previews: some View {
        SeatingChartView(zoomed: Binding.constant(false), selectedTicketsNumber: Binding.constant(5))
    }
}

extension CGSize {
    static func +(left: CGSize, right: CGSize) -> CGSize {
        return .init(width: left.width + right.width, height: left.height + right.height)
    }
}
