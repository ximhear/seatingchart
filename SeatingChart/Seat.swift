//
//  Seat.swift
//  SeatingChart
//
//  Created by gzonelee on 2023/03/04.
//

import SwiftUI

struct Seat: Hashable, Equatable, Identifiable {
    var id: Int
    var path: Path
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(path.description)
        hasher.combine(id)
    }
}
