//
//  Stadium.swift
//  SeatingChart
//
//  Created by gzonelee on 2023/02/20.
//

import SwiftUI

struct Stadium: Shape {
    @Binding var fieldRect: CGRect
    @Binding var tribunes: [Int: [Tribune]]
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            let w = rect.width
            var fr = CGRect.zero
            let diff = w / CGFloat(Constants.sectorCount * 2)
            let tribuneSize = CGSize(width: diff / 3.0,
                                     height: diff / 4.5)
            (0..<Constants.sectorCount).forEach { index in
                let sw = w - diff * Double(index)
                let sh = w / Constants.h2vRatio -  diff * Double(index)
                let ox = (w - sw) / 2.0
                let oy = (w - sh) / 2.0
                let sr = CGRect.init(x: ox, y: oy, width: sw, height: sh)
                fr = sr
                let wo = (tribuneSize.width / CGFloat(Constants.sectorCount * 2)) * Double(index)
                path.addPath(Sector(
                    tribunes: $tribunes,
                    index: index,
                    tribuneSize: .init(width: tribuneSize.width - wo, height: tribuneSize.height), offset: (diff / 2 - tribuneSize.height) / 2.0)
                    .path(in: sr))
            }
            computeFieldRect(fr)
        }
    }
    
    private func computeFieldRect(_ rect: CGRect) {
        Task {
            fieldRect = .init(x: rect.minX + rect.width * 0.25 ,
                              y: rect.minY + rect.height * 0.25,
                              width: rect.width * 0.5,
                              height: rect.height * 0.5)
        }
    }
}

struct Stadium_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Stadium(fieldRect: .constant(.init(x: 0, y: 0, width: 400, height: 400)), tribunes: .constant([:]))
                .stroke(.secondary, lineWidth: 2)
        }
        .aspectRatio(1, contentMode: .fit)
        .padding()
    }
}
