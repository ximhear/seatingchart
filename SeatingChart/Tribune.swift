import Foundation 
import SwiftUI


struct Tribune: Hashable, Equatable {
    var path: Path

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.path.description)
    }
}
