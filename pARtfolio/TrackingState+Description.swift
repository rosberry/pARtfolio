//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import ARKit

extension ARCamera.TrackingState {
    
    var fullPresentationString: String {
        if let recommendation = recommendation {
            return presentationString + "\n" + recommendation
        }
        return presentationString
    }
    
    var presentationString: String {
        switch self {
        case .notAvailable:
            return "TRACKING UNAVAILABLE"
        case .normal:
            return "TRACKING NORMAL"
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                return "TRACKING LIMITED\nToo much camera movement"
            case .insufficientFeatures:
                return "TRACKING LIMITED\nNot enough surface detail"
            case .initializing:
                return "Initializing AR Session"
            }
        }
    }
    
    var recommendation: String? {
        switch self {
        case .limited(.excessiveMotion):
            return "Try slowing down your movement."
        case .limited(.insufficientFeatures):
            return "Try pointing at a flat surface."
        default:
            return nil
        }
    }
}
