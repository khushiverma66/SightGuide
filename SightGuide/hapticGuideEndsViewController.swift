//
//  hapticGuideEndsViewController.swift
//  SightGuide
//
//  Created by Khushi.
//

import AVKit
import UIKit

/// View controller indicating the end of the haptic guide.
class hapticGuideEndsViewController: UIViewController {
    
    // MARK: - Properties
    
    /// Speech synthesizer for providing spoken instructions.
    var synthesizer = AVSpeechSynthesizer()
    
    /// Flag to keep track of whether the initial text has been displayed.
    var isFirstTextDisplayed: Bool = true
    
    /// Timer for controlling text display intervals.
    var timer: Timer?
    
    /// Haptic feedback generator for providing tactile feedback.
    var feedbackGenerator: UIImpactFeedbackGenerator?
    
    /// Display link for updating haptic feedback intensity.
    var displayLink: CADisplayLink?
    
    // MARK: - Outlets
    
    @IBOutlet var holdButton: UILongPressGestureRecognizer!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add long press gesture recognizer
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        self.view.addGestureRecognizer(longPress)
        
        // Display initial text and speak
        speakText()
        
        // Hide back button in navigation bar
        navigationItem.hidesBackButton = true
    }
    
    // MARK: - Actions
    
    /// Handles the long press gesture by triggering haptic feedback and navigating to the next view controller.
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator?.prepare()
            displayLink = CADisplayLink(target: self, selector: #selector(updateHapticIntensity))
            displayLink?.add(to: .current, forMode: .default)
            
            // Stop speech synthesis and navigate to the next view controller
            stopSpeech()
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
    
    // MARK: - Haptic Feedback Intensity Update
    
    /// Updates the intensity of haptic feedback.
    @objc func updateHapticIntensity() {
        guard let feedbackGenerator = feedbackGenerator else { return }
        let intensity = min(1.0, CGFloat(displayLink?.timestamp ?? 0.0) / 2.0) // Adjust the divisor to control the intensity change speed
        feedbackGenerator.impactOccurred(intensity: intensity)
    }
    
    // MARK: - Speech Synthesis
    
    /// spoken instructions.
    func speakText() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.speak(text: "Haptic guide ends. Let's start moving. Tap and hold on the screen to continue")
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

