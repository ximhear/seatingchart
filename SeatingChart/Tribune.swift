import Foundation 
import SwiftUI


struct Tribune: Hashable, Equatable {
    var path: Path
    var seats: [Seat]

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.path.description)
    }
}
