
import Foundation
import AVKit
import UIKit


class hapticGuideEndsViewController: UIViewController {

    var synthesizer = AVSpeechSynthesizer()
    var isFirstTextDisplayed:Bool = true
    var timer: Timer?
    var feedbackGenerator: UIImpactFeedbackGenerator?
    var displayLink: CADisplayLink?
    
    
    @IBOutlet var holdButton: UILongPressGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        self.view.addGestureRecognizer(longPress)
        displayTextAndSpeak()
        
        navigationItem.hidesBackButton = true
    }

    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
               case .began:
                   feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
                   feedbackGenerator?.prepare()
                   displayLink = CADisplayLink(target: self, selector: #selector(updateHapticIntensity))
                   displayLink?.add(to: .current, forMode: .default)
            
            synthesizer.stopSpeaking(at:.immediate)
            if let storyboard = self.storyboard {
                        let nextViewController = storyboard.instantiateViewController(withIdentifier: "ARViewController")
                        self.navigationController?.pushViewController(nextViewController, animated: true)
                    }
               case .ended, .cancelled:
                   feedbackGenerator = nil
                   displayLink?.invalidate()
               default:
                   break
               }
        
    }
    @IBAction func handleBackSwipe(segue: UIStoryboardSegue) {
        print("going back")
    }
    
    @objc func updateHapticIntensity() {
            guard let feedbackGenerator = feedbackGenerator else { return }
            let intensity = min(1.0, CGFloat(displayLink?.timestamp ?? 0.0) / 2.0) // Adjust the divisor to control the intensity change speed
            feedbackGenerator.impactOccurred(intensity: intensity)
        }

    
    func displayTextAndSpeak() {
        if isFirstTextDisplayed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.speak(text: "Haptic guide ends. Let's start moving")
            
                let delayBeforeThirdText =  2.0
                DispatchQueue.main.asyncAfter(deadline: .now() + delayBeforeThirdText) {
                    self.speak(text: "Tap and Hold on screen to continue")
                }
                
            }
        }
    }

    
    func speak(text: String){
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.50
        utterance.volume = 1
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
}

