//
//  ViewController.swift
//  SightGuide
//
//  Created by Ravneet.
//

import AVKit
import UIKit

/// Main view controller responsible for displaying introductory text and handling user interactions.
class ViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var welcomeText: UILabel!
    @IBOutlet weak var SightGuide: UILabel!
    @IBOutlet weak var infoText: UILabel!
    @IBOutlet weak var tapText: UILabel!
    @IBOutlet var holdButton: UILongPressGestureRecognizer!
    
    // MARK: - Properties
    
    /// Speech synthesizer for providing spoken instructions.
    var synthesizer = AVSpeechSynthesizer()
    
    /// Timer for controlling text display intervals.
    var timer: Timer?
    
    /// Haptic feedback generator for providing tactile feedback.
    var feedbackGenerator: UIImpactFeedbackGenerator?
    
    /// Display link for updating haptic feedback intensity.
    var displayLink: CADisplayLink?
    
    /// Flag to keep track of whether the initial text has been displayed.
    var isFirstTextDisplayed: Bool = true
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        self.view.addGestureRecognizer(longPress)
        speakText()
    }
    
    // MARK: - Actions
    
    /// Handles the long press gesture by triggering haptic feedback, stopping speech synthesis, and navigating to the next view controller.
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator?.prepare()
            displayLink = CADisplayLink(target: self, selector: #selector(updateHapticIntensity))
            displayLink?.add(to: .current, forMode: .default)
            
            synthesizer.stopSpeaking(at: .immediate)
            
            if let storyboard = self.storyboard {
                let nextViewController = storyboard.instantiateViewController(withIdentifier: "onTrackViewController")
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
    
    /// Updates the intensity of haptic feedback based on the duration of the long press gesture.
    @objc func updateHapticIntensity() {
        guard let feedbackGenerator = feedbackGenerator else { return }
        let intensity = min(1.0, CGFloat(displayLink?.timestamp ?? 0.0) / 2.0) // Adjust the divisor to control the intensity change speed
        feedbackGenerator.impactOccurred(intensity: intensity)
    }
    
    // MARK: - Speech Synthesis
    
    /// spoken instructions.
    func speakText() {
        speak(text: "Welcome to Sight Guide. You will now experience how haptics work to navigate you. Tap and hold the screen to continue.")
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
}

