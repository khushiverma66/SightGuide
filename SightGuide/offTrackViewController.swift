//
//  offTrackViewController.swift
//  SightGuide
//
//  Created by Khushi Verma on 25/04/24.
//


import Foundation
import AVKit
import UIKit


class offTrackViewController: UIViewController {

    var synthesizer = AVSpeechSynthesizer()
    var isFirstTextDisplayed:Bool = true
    var timer: Timer?
    var circles: [UIView] = []
        var currentCircleIndex: Int = 0
    var feedbackGenerator: UIImpactFeedbackGenerator?
        var isFeedbackInProgress: Bool = false
    var currentIntensity: CGFloat = 0.0
        let intensityIncrement: CGFloat = 0.05
        let maximumIntensity: CGFloat = 1.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
//        self.view.addGestureRecognizer(longPress)
        displayTextAndSpeak()
        
        addConcentricCircles()
        
        animateCircles()
        
        navigationItem.hidesBackButton = true
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(triggerHaptic), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            startHapticPattern()
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            stopHapticPattern()
        }

//    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
//        if sender.state == .began {
//            performSegue(withIdentifier: "ShowNextVC", sender: self)
//        }
//    }
    @IBAction func handleBackSwipe(segue: UIStoryboardSegue) {
        print("going back")
    }
    func displayTextAndSpeak() {
        if isFirstTextDisplayed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.speak(text: "This haptic means that there's an obstacle ahead and it'll intensify according to the distance between you and object")
                
                // Delay before speaking the second text
                let delayBeforeSecondText = 6.5
                DispatchQueue.main.asyncAfter(deadline: .now() + delayBeforeSecondText) {
                    self.speak(text: "Swipe left to continue")
                }
                
                // Delay before speaking the third text
                let delayBeforeThirdText = delayBeforeSecondText + 3.0
                DispatchQueue.main.asyncAfter(deadline: .now() + delayBeforeThirdText) {
                    self.speak(text: "Swipe right to go back")
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
    
    func addConcentricCircles() {
        // Define the radii for the circles
        let radii: [CGFloat] = [20, 40, 60, 80, 100, 120] // Adjust the radii as needed
        
        // Define the center point for the circles
        let centerX = view.frame.width / 2
        let centerY = view.frame.height / 2
        
        // Create and add the circles to the view
        for (index, radius) in radii.enumerated() {
            let circleView = UIView(frame: CGRect(x: centerX - radius, y: centerY - radius, width: radius * 2, height: radius * 2))
            circleView.backgroundColor = .clear
            circleView.layer.cornerRadius = radius
            circleView.layer.borderWidth = 1.0
            circleView.layer.borderColor = UIColor.black.cgColor
            
            // Hide all circles initially
            circleView.alpha = 0.0
            
            // Fill the innermost circle
            if index == 0 {
                circleView.backgroundColor = .black
            }
            
            view.addSubview(circleView)
            circles.append(circleView)
        }
    }

        
        func animateCircles() {
            guard currentCircleIndex < circles.count else {
                return // Animation completed
            }
            
            UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
                self.circles[self.currentCircleIndex].alpha = 1.0
            }, completion: { _ in
                self.currentCircleIndex += 1
                self.animateCircles() // Recursively animate next circle
            })
        }
    
    func startHapticPattern() {
            if !isFeedbackInProgress {
                isFeedbackInProgress = true
                feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
                feedbackGenerator?.prepare()
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(triggerHaptic), userInfo: nil, repeats: true)
            }
        }
        
    @objc func triggerHaptic() {
        // Increase the intensity gradually
        currentIntensity += intensityIncrement
        
        // Clamp the intensity to ensure it doesn't exceed the maximum value
        currentIntensity = min(currentIntensity, maximumIntensity)
        
        // Set the intensity of the feedback generator
        feedbackGenerator?.impactOccurred(intensity: currentIntensity)
        
        // Check if the maximum intensity has been reached
        if currentIntensity >= maximumIntensity {
            // Invalidate the timer to stop the haptic feedback
            timer?.invalidate()
            timer = nil
        }
    }
        
        func stopHapticPattern() {
            isFeedbackInProgress = false
            timer?.invalidate()
            feedbackGenerator = nil
        }
}
