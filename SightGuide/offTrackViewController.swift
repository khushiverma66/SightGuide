//
//  offTrackViewController.swift
//  SightGuide
//
//  Created by Khushi.
//

import AVKit
import UIKit

/// View controller responsible for guiding users when they are off track.
class offTrackViewController: UIViewController {
    
    // MARK: - Properties
    
    /// Speech synthesizer for providing spoken instructions.
    var synthesizer = AVSpeechSynthesizer()
    
    /// Flag to keep track of whether the initial text has been displayed.
    var isFirstTextDisplayed: Bool = true
    
    /// Timer for controlling haptic feedback intensity.
    var timer: Timer?
    
    /// Array to store concentric circles representing proximity to an obstacle.
    var circles: [UIView] = []
    
    /// Index of the current circle being animated.
    var currentCircleIndex: Int = 0
    
    /// Haptic feedback generator for providing tactile feedback.
    var feedbackGenerator: UIImpactFeedbackGenerator?
    
    /// Flag to indicate whether haptic feedback is currently in progress.
    var isFeedbackInProgress: Bool = false
    
    /// Current intensity of haptic feedback.
    var currentIntensity: CGFloat = 0.0
    
    /// Increment value for increasing haptic feedback intensity.
    let intensityIncrement: CGFloat = 0.05
    
    /// Maximum intensity value for haptic feedback.
    let maximumIntensity: CGFloat = 1.0
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speakText()
        addConcentricCircles()
        animateCircles()
        
        // Configure navigation
        navigationItem.hidesBackButton = true
        
        // Start haptic feedback pattern
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(triggerHaptic), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startHapticPattern()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopHapticPattern()
        stopSpeech()
    }
    
    // MARK: - Actions
    
    /// Handles the swipe gesture for going back.
    @IBAction func handleBackSwipe(segue: UIStoryboardSegue) {
        print("Going back")
    }
    
    // MARK: - Speech Synthesis
    
    /// spoken instructions.
    func speakText() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.speak(text: "This haptic means that there's an obstacle ahead and it'll intensify according to the distance between you and the object. Swipe left to continue. Swipe right to go back.")
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
    
    /// Stops the speech synthesis.
    func stopSpeech() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    // MARK: - Concentric Circles Animation
    
    /// Adds concentric circles representing proximity to an obstacle.
    func addConcentricCircles() {
        let radii: [CGFloat] = [20, 40, 60, 80, 100, 120]
        
        let centerX = view.frame.width / 2
        let centerY = view.frame.height / 2
        
        for (index, radius) in radii.enumerated() {
            let circleView = UIView(frame: CGRect(x: centerX - radius, y: centerY - radius, width: radius * 2, height: radius * 2))
            circleView.backgroundColor = .clear
            circleView.layer.cornerRadius = radius
            circleView.layer.borderWidth = 1.0
            circleView.layer.borderColor = UIColor.black.cgColor
            
            circleView.alpha = 0.0
            
            if index == 0 {
                circleView.backgroundColor = .black
            }
            
            view.addSubview(circleView)
            circles.append(circleView)
        }
    }
    
    /// Animates the concentric circles.
    func animateCircles() {
        guard currentCircleIndex < circles.count else {
            return
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
            self.circles[self.currentCircleIndex].alpha = 1.0
        }, completion: { _ in
            self.currentCircleIndex += 1
            self.animateCircles()
        })
    }
    
    // MARK: - Haptic Feedback
    
    /// Starts the haptic feedback pattern.
    func startHapticPattern() {
        if !isFeedbackInProgress {
            isFeedbackInProgress = true
            feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
            feedbackGenerator?.prepare()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(triggerHaptic), userInfo: nil, repeats: true)
        }
    }
    
    /// Triggers the haptic feedback with increasing intensity.
    @objc func triggerHaptic() {
        currentIntensity += intensityIncrement
        currentIntensity = min(currentIntensity, maximumIntensity)
        feedbackGenerator?.impactOccurred(intensity: currentIntensity)
        
        if currentIntensity >= maximumIntensity {
            timer?.invalidate()
            timer = nil
        }
    }
    
    
    /// Stops the haptic feedback pattern.
    func stopHapticPattern() {
        isFeedbackInProgress = false
        timer?.invalidate()
        feedbackGenerator = nil
    }
}

