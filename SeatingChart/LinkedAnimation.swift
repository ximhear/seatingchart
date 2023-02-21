//
//  LinkedAnimation.swift
//  SeatingChart
//
//  Created by gzonelee on 2023/02/21.
//

import SwiftUI

struct LinkedAnimation {
    let type: Animation
    let duration: Double
    let action: () -> Void
    
    static func easeInOut(for duration: Double, action: @escaping () -> Void) -> LinkedAnimation {
        return LinkedAnimation(type: .easeIn(duration: duration), duration: duration, action: action)
    }
    
    func link(to animation: LinkedAnimation, reverse: Bool) {
        withAnimation(reverse ? animation.type : type) {
            reverse ? animation.action() : action()
        }
        withAnimation(reverse ? type.delay(animation.duration) : animation.type.delay(duration)) {
            reverse ? action() : animation.action()
        }
    }
}

