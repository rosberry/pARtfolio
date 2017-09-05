//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

final class ViewController: UIViewController {
    
    private var planes = [Plane]()
    private var boxNode: SCNNode?
    private var appIndex = 0
    
    private let standardConfiguration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        return configuration
    }()
    
    // MARK: - Subviews
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var messagePanel: UIVisualEffectView!
    @IBOutlet weak var messageLabel: UILabel!
    
    private enum NodeNames {
        static let box = "box_node"
        static let side = "side_node"
        static let bottom = "bottom_node"
        static let apps = "apps_node"
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        sceneView.addGestureRecognizer(tapRecognizer)
        
        messagePanel.layer.cornerRadius = 3
        messagePanel.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        if ARWorldTrackingConfiguration.isSupported {
            resetTracking()
        }
        else {
            // This device does not support 6DOF world tracking.
            let message = "This app requires world tracking. World tracking is only available on iOS devices with A9 processor or newer. " +
            "Please quit the application."
            let alertController = UIAlertController(title: "Unsupported platform", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        sceneView.session.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - Actions
    
    @IBAction func restartButtonAction(_ sender: Any) {
        resetTracking()
    }
    
    // MARK: - Recognizers
    
    @objc private func tap(recognizer: UIGestureRecognizer) {
        let touchPoint = recognizer.location(in: sceneView)
        if let arHitTestResult = sceneView.hitTest(touchPoint, types: .existingPlaneUsingExtent).first {
            addBoxNode(with: arHitTestResult)
        }
        guard let hitTestResult = sceneView.hitTest(touchPoint, options: nil).first else {
            return
        }
        if hitTestResult.node.name == NodeNames.side {
            let rootNode = sceneView.scene.rootNode
            if let planeNode = rootNode.childNode(withName: NodeNames.bottom, recursively: true) {
                planeNode.removeFromParentNode()
            }
            if let appsNode = rootNode.childNode(withName: NodeNames.apps, recursively: true) {
                let cloneAppsNode = appsNode.clone()
                cloneAppsNode.geometry = appsNode.geometry?.copy() as? SCNGeometry
                cloneAppsNode.isHidden = false
                addAppMaterials(to: cloneAppsNode)
                boxNode?.addChildNode(cloneAppsNode)
            }
        }
    }
    
    // MARK: - Private
    
    private func resetTracking() {
        sceneView.session.run(standardConfiguration, options: [.resetTracking, .removeExistingAnchors])
        sceneView.scene = SCNScene()
        boxNode = nil
        planes.removeAll()
    }
    
    private func addBoxNode(with result: ARHitTestResult) {
        guard boxNode == nil else {
            return
        }
        messageLabel.text = "Tap the box"
        guard let boxScene = SCNScene(named: "art.scnassets/Box.scn") else {
            fatalError("Can't find scene with name Box.scn")
        }
        if let boxNode = boxScene.rootNode.childNode(withName: NodeNames.box, recursively: true) {
            boxNode.position = SCNVector3Make(result.worldTransform.columns.3.x,
                                              result.worldTransform.columns.3.y + 0.3,
                                              result.worldTransform.columns.3.z)
            sceneView.scene.rootNode.addChildNode(boxNode)
            self.boxNode = boxNode
        }
        planes.forEach { $0.opacity = 0 }
    }
    
    private func addAppMaterials(to node: SCNNode) {
        let appNodes = node.childNodes.filter { $0.name == "app_node" }
        let images = icons(forIndex: appIndex)
        appIndex += 1
        if appIndex > 2 {
            appIndex = 0
        }
        zip(appNodes, images).forEach { appNode, image in
            let newNode = appNode.clone()
            newNode.geometry = appNode.geometry?.copy() as? SCNGeometry
            let material = SCNMaterial()
            material.diffuse.contents = image
            newNode.geometry?.firstMaterial = material
            appNode.removeFromParentNode()
            node.addChildNode(newNode)
        }
    }
    
    private func icons(forIndex index: Int) -> [UIImage] {
        switch index {
        case 0:
            return [#imageLiteral(resourceName: "icon_font_candy+.png"), #imageLiteral(resourceName: "icon_fusedpng.png"), #imageLiteral(resourceName: "icon_haikujam.png"), #imageLiteral(resourceName: "icon_handwrytten.png"), #imageLiteral(resourceName: "icon_hype_type.png"), #imageLiteral(resourceName: "icon_impuls.png"), #imageLiteral(resourceName: "icon_kost.png"), #imageLiteral(resourceName: "icon_moments.png"), #imageLiteral(resourceName: "icon_mopa.png"), #imageLiteral(resourceName: "icon_obolus.png")]
        case 1:
            return [#imageLiteral(resourceName: "icon_addme.png"), #imageLiteral(resourceName: "icon_ambinode.png"), #imageLiteral(resourceName: "icon_animalface.png"), #imageLiteral(resourceName: "icon_AR.png"), #imageLiteral(resourceName: "icon_beatmix.png"), #imageLiteral(resourceName: "icon_calico_.png"), #imageLiteral(resourceName: "icon_cinepic.png"), #imageLiteral(resourceName: "icon_diy.png"), #imageLiteral(resourceName: "icon_fervor.png"), #imageLiteral(resourceName: "icon_font_candy.png")]
        case 2:
            return [#imageLiteral(resourceName: "icon_randochat.png"), #imageLiteral(resourceName: "icon_splitpic.png"), #imageLiteral(resourceName: "icon_sufler.png"), #imageLiteral(resourceName: "icon_ti.png"), #imageLiteral(resourceName: "icon_tourhero.png"), #imageLiteral(resourceName: "Icon_unonotes.png"), #imageLiteral(resourceName: "icon_vanharen.png"), #imageLiteral(resourceName: "icon_waterbow.png"), #imageLiteral(resourceName: "icon_splitpic_pro.png"), #imageLiteral(resourceName: "icon_beatmix.png")]
        default:
            return []
        }
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        let plane = Plane(anchor: planeAnchor)
        planes.append(plane)
        node.addChildNode(plane)
        if boxNode != nil {
            plane.opacity = 0
        }
        
        DispatchQueue.main.async {
            if self.boxNode == nil {
                self.messageLabel.text = "Tap a surface to place a box"
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        let plane = planes.first { $0.anchor.identifier == anchor.identifier }
        plane?.update(withAnchor: planeAnchor)
    }
}

extension ViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        messageLabel.text = camera.trackingState.fullPresentationString
    }
}
