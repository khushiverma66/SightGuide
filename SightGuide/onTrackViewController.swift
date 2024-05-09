
import Foundation
import AVKit
import UIKit



class onTrackViewController: UIViewController {

    var synthesizer = AVSpeechSynthesizer()
    var isSpeechInProgress: Bool = false
    var isFirstTextDisplayed: Bool = true
    var timer: Timer?
    var feedbackGenerator: UIImpactFeedbackGenerator?
        var isFeedbackInProgress: Bool = false
    
    @IBOutlet weak var tappableButton: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tappableButton.backgroundColor = .black
        tappableButton.layer.masksToBounds = true
        tappableButton.layer.cornerRadius = tappableButton.frame.height / 2
        
        navigationItem.hidesBackButton = true
        
        startHapticPattern()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        displayTextAndSpeak()
        
        animateButtonVisibility()
        startHapticPattern()
        
    }
    
    func animateButtonVisibility() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = 0.42
        animation.autoreverses = true
        animation.repeatCount = .infinity
        
        tappableButton.layer.add(animation, forKey: "opacityAnimation")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop the animation when the view disappears
        tappableButton.layer.removeAnimation(forKey: "opacityAnimation")
        stopHapticPattern()
        stopSpeech()
    }
    
    func startHapticPattern() {
            if !isFeedbackInProgress {
                isFeedbackInProgress = true
                feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
                feedbackGenerator?.prepare()
                timer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(triggerHaptic), userInfo: nil, repeats: true)
            }
        }
        
        @objc func triggerHaptic() {
            feedbackGenerator?.impactOccurred()
        }
        
        func stopHapticPattern() {
            isFeedbackInProgress = false
            timer?.invalidate()
            feedbackGenerator = nil
        }
    
    @IBAction func handleBackSwipe(segue: UIStoryboardSegue) {
        print("going back")
    }
    
    func displayTextAndSpeak() {
        
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.speak(text: "This haptic means that there is no obstacle in the way and you are going in the right direction. Swipe left to continue")
                
            }
        
    }

    func speak(text: String){
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.50
        utterance.volume = 1
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
    func stopSpeech() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
