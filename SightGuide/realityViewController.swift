import RealityKit
import ARKit
import AVFoundation
import SwiftUI

class RealityViewController: UIViewController, ARSessionDelegate, SCNSceneRendererDelegate {
    
    @IBOutlet var arView: ARView!
    var distanceUpdateTimer: Timer?
    
    @IBOutlet var distanceLabel: UILabel!
    var hapticGenerator: UIImpactFeedbackGenerator?
    
    let coachingOverlay = ARCoachingOverlayView()
    
    let speechSynthesizer = AVSpeechSynthesizer()
    var speechTimer: Timer?
    var lastSpokenClassification: String?
    var lastSpeechTime: TimeInterval = 0
    let speechDelay: TimeInterval = 3
    var lastSpokenDistance: Float?
    let significantDistanceChange: Float = 1.0
    let significantTimeDifference: TimeInterval = 1.0 
    let scale: Float = 1.0
    var lastHapticTime: TimeInterval = 0
    
    
    // Cache for 3D text geometries representing the classification values.
    var modelsForClassification: [ARMeshClassification: ModelEntity] = [:]
    
    /// - Tag: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hapticGenerator = UIImpactFeedbackGenerator(style: .heavy)
        hapticGenerator?.prepare()
        
        arView.session.delegate = self
        
        
        setupCoachingOverlay()
        
        arView.environment.sceneUnderstanding.options = []
        
        arView.environment.sceneUnderstanding.options.insert(.occlusion)
        
        arView.environment.sceneUnderstanding.options.insert(.physics)
        
        arView.debugOptions.insert(.showSceneUnderstanding)
        
        arView.renderOptions = [.disablePersonOcclusion, .disableDepthOfField, .disableMotionBlur]
       
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.sceneReconstruction = .meshWithClassification
        
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
        
        navigationItem.hidesBackButton = true
    }
    
    
   
    func calculateDistance(_ point1: SCNVector3, _ point2: SCNVector3) -> Float {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        let dz = point2.z - point1.z
        let distanceInPoints = sqrt(dx*dx + dy*dy + dz*dz)
            
            // Convert distance from points to meters using the scale factor
            let distanceInMeters = distanceInPoints * scale
            
            return distanceInMeters
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Prevent the screen from being dimmed to avoid interrupting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
        
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    func nearbyFaceWithClassification(to location: SIMD3<Float>, completionBlock: @escaping (SIMD3<Float>?, ARMeshClassification?) -> Void) {
        guard let frame = arView.session.currentFrame else {
            completionBlock(nil, nil)
            return
        }
        
        var meshAnchors = frame.anchors.compactMap({ $0 as? ARMeshAnchor })
        
        // Sort the mesh anchors by distance to the given location and filter out
        // any anchors that are too far away (4 meters is a safe upper limit).
        let cutoffDistance: Float = 4.0
        meshAnchors.removeAll { distance($0.transform.position, location) > cutoffDistance }
        meshAnchors.sort { distance($0.transform.position, location) < distance($1.transform.position, location) }
        
        // Perform the search asynchronously in order not to stall rendering.
        DispatchQueue.global().async {
            for anchor in meshAnchors {
                for index in 0..<anchor.geometry.faces.count {
                    // Get the center of the face so that we can compare it to the given location.
                    let geometricCenterOfFace = anchor.geometry.centerOf(faceWithIndex: index)
                    
                    // Convert the face's center to world coordinates.
                    var centerLocalTransform = matrix_identity_float4x4
                    centerLocalTransform.columns.3 = SIMD4<Float>(geometricCenterOfFace.0, geometricCenterOfFace.1, geometricCenterOfFace.2, 1)
                    let centerWorldPosition = (anchor.transform * centerLocalTransform).position
                    
                    // We're interested in a classification that is sufficiently close to the given location––within 5 cm.
                    let distanceToFace = distance(centerWorldPosition, location)
                    if distanceToFace <= 0.1 {
                        // Get the semantic classification of the face and finish the search.
                        let classification: ARMeshClassification = anchor.geometry.classificationOf(faceWithIndex: index)
                        completionBlock(centerWorldPosition, classification)
                        return
                    }
                }
            }
            
            // Let the completion block know that no result was found.
            completionBlock(nil, nil)
        }
    }
    
    
    func speakClassificationIfNeeded(_ classification: ARMeshClassification, distance: Float) {
        let currentTime = Date.timeIntervalSinceReferenceDate
        
        
        if classification.description == "Floor" {
            return
        }
        
        if classification.description == "Ceiling" {
            return
        }
        
//        if(classification.description == "unidentified"){
//            print("ekhwfrbehfrih3ioerfoierggjjygguyuybjhbjbjbhjbjguygygjguguvjvhvfo")
//            if(currentTime - lastSpeechTime > 2.0){
//                nspeak(classification: "unidentified object")
//                lastSpeechTime = Date.timeIntervalSinceReferenceDate
//            }
//            
//            return
//        }
//        
        guard let symbolName = classification.sfSymbolName else {
                return
            }
            
//        DispatchQueue.main.async {
//            // Remove any existing UIImageView from the view hierarchy
//            self.view.subviews.forEach { subview in
//                if let imageView = subview as? UIImageView {
//                    imageView.removeFromSuperview()
//                }
//            }
//
//            let imageView = UIImageView()
//            
//            imageView.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
//            
//            if let symbolImage = UIImage(systemName: symbolName) {
//                imageView.image = symbolImage
//                
//                self.view.addSubview(imageView)
//            } else {
//                print("Failed to create UIImage from SF Symbol")
//            }
//        
//            }
//        
        
        
        
        
    
        
        if currentTime - lastSpeechTime >= speechDelay {
            let classificationName = classification.description
            
            
            if classificationName != lastSpokenClassification {
//                speak(classification: classificationName, distance: distance)
                
                
                print(classificationName)
                nspeak(classification: classificationName)
                
            } else {
                if currentTime - lastSpeechTime >= 2 {
//                    speak(distance: distance)
                   
                    nspeak(classification: classificationName, distance : distance)
                }
                
                // If the classification is the same, check if the distance has changed significantly
//                if let lastDistance = lastSpokenDistance {
//                                let distanceChange = abs(distance - lastDistance)
//                                if distanceChange >= significantDistanceChange {
//                                    // If the distance has changed significantly, speak the updated distance
//                                    speak(distance: distance)
//                                }
//                            }
            }
        }
    }
    
    func nspeak(classification : String){
        let speechString = "\(classification)"
        let speechUtterance = AVSpeechUtterance(string: speechString)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(speechUtterance)
        
        lastSpokenClassification = classification
        lastSpeechTime = Date.timeIntervalSinceReferenceDate
    }
    
    func nspeak(classification: String, distance : Float){
        let speechString = "\(classification) at \(Int(distance)) meters ahead."
        let speechUtterance = AVSpeechUtterance(string: speechString)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(speechUtterance)
        
        // Update the last spoken classification and distance
        lastSpokenClassification = classification
        lastSpokenDistance = distance
        
        // Update the last speech time
        lastSpeechTime = Date.timeIntervalSinceReferenceDate
    }
    
    func speak(classification: String, distance: Float) {
        let speechString = "\(classification) at \(Int(distance)) meters ahead."
        let speechUtterance = AVSpeechUtterance(string: speechString)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(speechUtterance)
        
        // Update the last spoken classification and distance
        lastSpokenClassification = classification
        lastSpokenDistance = distance
        
        // Update the last speech time
        lastSpeechTime = Date.timeIntervalSinceReferenceDate
    }
    
    func speak(distance: Float) {
        let speechString = "\(Int(distance)) meters "
        let speechUtterance = AVSpeechUtterance(string: speechString)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(speechUtterance)
        
        // Update the last spoken distance
        lastSpokenDistance = distance
        
        // Update the last speech time
        lastSpeechTime = Date.timeIntervalSinceReferenceDate
    }
    
    // Delegate method to handle updates to the AR session
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let screenCenter = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        if let result = arView.raycast(from: screenCenter, allowing: .estimatedPlane, alignment: .any).first {
            let cameraTransform = frame.camera.transform
            let cameraPosition = SCNVector3(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
            let hitTransform = result.worldTransform
            let hitPosition = SCNVector3(hitTransform.columns.3.x, hitTransform.columns.3.y, hitTransform.columns.3.z)
            let distance = calculateDistance(cameraPosition, hitPosition)
            print("Distance: \(distance)")
//            distanceLabel.text = "\(distance)"
//            distanceLabel.text = String(format: "%.2f", distance)
            let roundedValue = round(distance * 10) / 10
            provideHapticFeedback(roundedValue)
            
            
            
            nearbyFaceWithClassification(to: result.worldTransform.position) { _, classification in
                if let classification = classification {
                    print("Classification: \(classification.description)")
                    self.speakClassificationIfNeeded(classification, distance: distance)
                }
            }
        }
        
        func model(for classification: ARMeshClassification) -> ModelEntity {
            // Return cached model if available
            if let model = modelsForClassification[classification] {
                model.transform = .identity
                return model.clone(recursive: true)
            }
            
            // Generate 3D text for the classification
            let lineHeight: CGFloat = 0.05
            let font = MeshResource.Font.systemFont(ofSize: lineHeight)
            let textMesh = MeshResource.generateText(classification.description, extrusionDepth: Float(lineHeight * 0.1), font: font)
            let textMaterial = SimpleMaterial(color: classification.color, isMetallic: true)
            let model = ModelEntity(mesh: textMesh, materials: [textMaterial])
            // Move text geometry to the left so that its local origin is in the center
            model.position.x -= model.visualBounds(relativeTo: nil).extents.x / 2
         
            modelsForClassification[classification] = model
            return model
        }
        
        func sphere(radius: Float, color: UIColor) -> ModelEntity {
            let sphere = ModelEntity(mesh: .generateSphere(radius: radius), materials: [SimpleMaterial(color: color, isMetallic: false)])
            // Move sphere up by half its diameter so that it does not intersect with the mesh
            sphere.position.y = radius
            return sphere
        }
        
        func provideHapticFeedback(_ distance: Float) {
            // Reverse the intensity: stronger haptic for shorter distances
//            let intensity = CGFloat(max(0, min(1, 1 - distance / 1.2)))
            let intensity = CGFloat(max(0, (1 - distance / 1.2)))
//            hapticGenerator?.impactOccurred(intensity: intensity)
            if distance > 2 || intensity < 0.2 {
                        let currentTime = Date.timeIntervalSinceReferenceDate
                        if currentTime - lastHapticTime >= 1.0 {
                            lastHapticTime = currentTime
                            hapticGenerator?.impactOccurred(intensity: 1)
                        }
                    }
            else{
                hapticGenerator?.impactOccurred(intensity: intensity)
            }
            
            
        }
    }
}
