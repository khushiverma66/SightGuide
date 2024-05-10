//
//  onTrackViewController.swift
//  SightGuide
//
//  Created by Khushi.
//

import AVKit
import UIKit

/// View controller responsible for guiding users when they are on track.
class onTrackViewController: UIViewController {
    
    // MARK: - Properties
    
    /// Speech synthesizer for providing spoken instructions.
    var synthesizer = AVSpeechSynthesizer()
    
    /// Flag to indicate whether speech synthesis is in progress.
    var isSpeechInProgress: Bool = false
    
    /// Flag to keep track of whether the initial text has been displayed.
    var isFirstTextDisplayed: Bool = true
    
    /// Timer for controlling haptic feedback.
    var timer: Timer?
    
    /// Haptic feedback generator for providing tactile feedback.
    var feedbackGenerator: UIImpactFeedbackGenerator?
    
    /// Flag to indicate whether haptic feedback is currently in progress.
    var isFeedbackInProgress: Bool = false
    
    // MARK: - Outlets
    
    @IBOutlet weak var tappableButton: UIImageView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure tappable button appearance
        tappableButton.backgroundColor = .black
        tappableButton.layer.masksToBounds = true
        tappableButton.layer.cornerRadius = tappableButton.frame.height / 2
        
        // Hide back button in navigation bar
        navigationItem.hidesBackButton = true
        
        // Start haptic feedback pattern
        startHapticPattern()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Display initial text and speak
        speakText()
        
        // Animate tappable button visibility
        animateButtonVisibility()
        
        // Start haptic feedback pattern
        startHapticPattern()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop animation and haptic feedback when the view disappears
        tappableButton.layer.removeAnimation(forKey: "opacityAnimation")
        stopHapticPattern()
        stopSpeech()
    }
    
    // MARK: - Button Animation
    
    /// Animates the visibility of the tappable button.
    func animateButtonVisibility() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = 0.42
        animation.autoreverses = true
        animation.repeatCount = .infinity
        
        tappableButton.layer.add(animation, forKey: "opacityAnimation")
    }
    
    // MARK: - Haptic Feedback
    
    /// Starts the haptic feedback pattern.
    func startHapticPattern() {
        if !isFeedbackInProgress {
            isFeedbackInProgress = true
            feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
            feedbackGenerator?.prepare()
            timer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(triggerHaptic), userInfo: nil, repeats: true)
        }
    }
    
    /// Triggers the haptic feedback.
    @objc func triggerHaptic() {
        feedbackGenerator?.impactOccurred()
    }
    
    /// Stops the haptic feedback pattern.
    func stopHapticPattern() {
        isFeedbackInProgress = false
        timer?.invalidate()
        feedbackGenerator = nil
    }
    
    // MARK: - Speech Synthesis
    
    /// spoken Instructions.
    func speakText() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.speak(text: "This haptic means that there is no obstacle in the way and you are going in the right direction. Swipe left to continue.")
        }
    }
    
    /// Initiates spoken instructions.
    /// - Parameter text: The text to be spoken.
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.50
        utterance.volume = 1
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
    
    /// Stops speech synthesis.
    func stopSpeech() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}

