import UIKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate {
    
    var sceneView: ARSCNView!
    var hapticGenerator: UIImpactFeedbackGenerator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView = ARSCNView(frame: view.frame)
        sceneView.debugOptions = [.showFeaturePoints, .showWireframe]
        view.addSubview(sceneView)
        sceneView.delegate = self
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        hapticGenerator = UIImpactFeedbackGenerator(style: .light)
        hapticGenerator?.prepare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.sceneReconstruction = .meshWithClassification
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            guard let frame = self.sceneView.session.currentFrame else {
                return
            }
            let cameraTransform = frame.camera.transform
            
            let query = self.sceneView.raycastQuery(from: self.sceneView.center, allowing: .existingPlaneGeometry, alignment: .any)
            guard let raycastQuery = query else {
                return
            }
            let results = self.sceneView.session.raycast(raycastQuery)
            
            guard let result = results.first else {
                return
            }
            let hitTransform = result.worldTransform
            
            let cameraPosition = SCNVector3(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
            let hitPosition = SCNVector3(hitTransform.columns.3.x, hitTransform.columns.3.y, hitTransform.columns.3.z)
            
            let distance = self.calculateDistance(cameraPosition, hitPosition)
            
            print("Distance between camera and hit point: \(distance)")
            self.provideHapticFeedback(distance)
        }
    }

    func calculateDistance(_ point1: SCNVector3, _ point2: SCNVector3) -> Float {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        let dz = point2.z - point1.z
        return sqrt(dx*dx + dy*dy + dz*dz)
    }
    
    func provideHapticFeedback(_ distance: Float) {
        let intensity = CGFloat(max(0, min(1, 1 - distance / 2))) 
        hapticGenerator?.impactOccurred(intensity: intensity)
    }
}

