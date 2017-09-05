//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import SceneKit
import ARKit

final class Plane: SCNNode {
    
    let anchor: ARPlaneAnchor
    private let box: SCNBox
    
    // MARK: - Lifecycle
    
    init(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        
        box = SCNBox(width: CGFloat(anchor.extent.x),
                       height: CGFloat(anchor.extent.z),
                       length: 0,
                       chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = #imageLiteral(resourceName: "grid")
        box.materials = [material]
        
        let planeNode = SCNNode(geometry: box)
        let boxShape = SCNPhysicsShape(geometry: box, options: nil)
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: boxShape)
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2), 1, 0, 0)
        
        super.init()
        addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(withAnchor anchor: ARPlaneAnchor) {
        box.width = CGFloat(anchor.extent.x)
        box.height = CGFloat(anchor.extent.z)
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        let boxShape = SCNPhysicsShape(geometry: box, options: nil)
        childNodes.first?.physicsBody = SCNPhysicsBody(type: .static, shape: boxShape)
    }
}
