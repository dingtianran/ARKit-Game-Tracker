//
//  ViewController.swift
//  ARKitGameTrackr
//
//  Created by Tianran Ding on 15/06/18.
//  Copyright © 2018 Dingtr. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var session: ARSession {
        return sceneView.session
    }
    
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.session.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        sceneView.scene = SCNScene()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func resetTracking() {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 5
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
    }
    
    func drawImagesAndText(string: String) -> SCNMaterial {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let img = renderer.image { ctx in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            
            let attrs = [NSAttributedString.Key.foregroundColor: UIColor.green,
                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 60, weight: UIFont.Weight.bold)]
            
            string.draw(with: CGRect(x: 0, y: 0, width: 512, height: 512), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
        let mat = SCNMaterial()
        mat.diffuse.contents = img
        return mat
    }
    
    func matchedMaterialForName(_ name: String?) -> SCNMaterial? {
        guard let matName = name else { return nil }
        let mat: SCNMaterial
        if matName == "crash" {
            mat = self.drawImagesAndText(string:"""
Crash Bandicoot
Naughty Dog??
2017
""")
        }
        else if matName == "godofwar" {
            mat = self.drawImagesAndText(string: """
God of War
Santa Monica/Sony
2018
""")
        }
        else if matName == "uncharted4" {
            mat = self.drawImagesAndText(string: """
Uncharted 4
Naughty Dog/Sony
2016
""")
        }
        else if matName == "unchartedlegacy" {
            mat = self.drawImagesAndText(string: """
Uncharted: Lost Legacy
Naughty Dog/Sony
2017
""")
        } else {
            mat = self.drawImagesAndText(string: """
??????
???/???
20--
""")
        }
        return mat
    }

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        updateQueue.async {
            // Create a plane to visualize the initial position of the detected image.
            let plane = SCNPlane(width: referenceImage.physicalSize.width,
                                 height: referenceImage.physicalSize.height)
            
            plane.firstMaterial = self.matchedMaterialForName(referenceImage.name)
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.position = SCNVector3Make(planeNode.position.x, planeNode.position.y, planeNode.position.z-0.6*Float(referenceImage.physicalSize.height))
            planeNode.eulerAngles.x = -.pi / 2
            
            // Add the plane visualization to the scene.
            node.addChildNode(planeNode)
        }
    }
}
