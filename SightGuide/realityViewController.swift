import RealityKit
import ARKit
import AVFoundation
import SwiftUI

class RealityViewController: UIViewController, ARSessionDelegate, SCNSceneRendererDelegate {
    
    @IBOutlet var arView: ARView!
    @IBOutlet var distanceLabel: UILabel!
    
    
    var hapticGenerator: UIImpactFeedbackGenerator?
    
    let coachingOverlay = ARCoachingOverlayView()
    let speechSynthesizer = AVSpeechSynthesizer()
    var speechTimer: Timer?
    var lastSpokenClassification: String?
    
    var lastSpeechTime: TimeInterval = 0
    let speechDelay: TimeInterval = 3
    var lastSpokenDistance: Float?
    var distanceUpdateTimer: Timer?
    let significantDistanceChange: Float = 1.0
    let significantTimeDifference: TimeInterval = 1.0
    let scale: Float = 1.0
    var lastHapticTime: TimeInterval = 0
    var isAlternateFrame = false
    var frameCounter = 0
    

    var modelsForClassification: [ARMeshClassification: ModelEntity] = [:]
    
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
            
            let distanceInMeters = distanceInPoints * scale
            
            return distanceInMeters
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        
        let cutoffDistance: Float = 4.0
        meshAnchors.removeAll { distance($0.transform.position, location) > cutoffDistance }
        meshAnchors.sort { distance($0.transform.position, location) < distance($1.transform.position, location) }
        
        DispatchQueue.global().async {
            for anchor in meshAnchors {
                for index in 0..<anchor.geometry.faces.count {
                    let geometricCenterOfFace = anchor.geometry.centerOf(faceWithIndex: index)
                    
                    var centerLocalTransform = matrix_identity_float4x4
                    centerLocalTransform.columns.3 = SIMD4<Float>(geometricCenterOfFace.0, geometricCenterOfFace.1, geometricCenterOfFace.2, 1)
                    let centerWorldPosition = (anchor.transform * centerLocalTransform).position
                    
                    let distanceToFace = distance(centerWorldPosition, location)
                    if distanceToFace <= 0.1 {
                        let classification: ARMeshClassification = anchor.geometry.classificationOf(faceWithIndex: index)
                        completionBlock(centerWorldPosition, classification)
                        return
                    }
                }
            }
            
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
        
        if(classification.description == "unidentified" ){
            lastSpokenClassification = "unidentified"
            if(currentTime - lastSpeechTime > 2.0){
                speakClassification(classification: "unidentified object")
                lastSpeechTime = Date.timeIntervalSinceReferenceDate
            }
            
            return
        }
        guard classification.sfSymbolName != nil else {
            return
        }
        
    
        
        if currentTime - lastSpeechTime >= speechDelay {
            let classificationName = classification.description
            
            if classificationName != lastSpokenClassification {
                print(classificationName)
                speakClassification(classification: classificationName)
                
            } else {
                if currentTime - lastSpeechTime >= 2 {
                    speakClassificationWithDistance(classification: classificationName, distance : distance)
                }
            }
        }
    }
    
    func speakClassification(classification : String){
        let speechString = "\(classification)"
        let speechUtterance = AVSpeechUtterance(string: speechString)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(speechUtterance)
        
        lastSpokenClassification = classification
        lastSpeechTime = Date.timeIntervalSinceReferenceDate
    }
    
    func speakClassificationWithDistance(classification: String, distance : Float){
        let speechString = "\(classification) at \(Int(distance)) meters ahead."
        let speechUtterance = AVSpeechUtterance(string: speechString)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(speechUtterance)
        
        lastSpokenClassification = classification
        lastSpokenDistance = distance
        
        lastSpeechTime = Date.timeIntervalSinceReferenceDate
    }
    
    
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        frameCounter += 1
        
        
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
            
            if frameCounter % 17 == 0 {
                nearbyFaceWithClassification(to: result.worldTransform.position) { _, classification in
                    if let classification = classification {
                        print("Classification: \(classification.description)")
                        self.speakClassificationIfNeeded(classification, distance: distance)
                    }
                }
            }
        }
        
        func model(for classification: ARMeshClassification) -> ModelEntity {
            if let model = modelsForClassification[classification] {
                model.transform = .identity
                return model.clone(recursive: true)
            }
            
            let lineHeight: CGFloat = 0.05
            let font = MeshResource.Font.systemFont(ofSize: lineHeight)
            let textMesh = MeshResource.generateText(classification.description, extrusionDepth: Float(lineHeight * 0.1), font: font)
            let textMaterial = SimpleMaterial(color: classification.color, isMetallic: true)
            let model = ModelEntity(mesh: textMesh, materials: [textMaterial])
            model.position.x -= model.visualBounds(relativeTo: nil).extents.x / 2
         
            modelsForClassification[classification] = model
            return model
        }
        
        func sphere(radius: Float, color: UIColor) -> ModelEntity {
            let sphere = ModelEntity(mesh: .generateSphere(radius: radius), materials: [SimpleMaterial(color: color, isMetallic: false)])
            sphere.position.y = radius
            return sphere
        }
        
        func provideHapticFeedback(_ distance: Float) {
            let intensity = CGFloat(max(0, (1 - distance / 1.2)))
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
