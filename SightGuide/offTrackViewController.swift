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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
//        self.view.addGestureRecognizer(longPress)
        displayTextAndSpeak()
        
        addConcentricCircles()
        
        animateCircles()
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
                self.speak(text: "This haptic means that there's an obstacle in front of you and it'll intensify as you'll come near it")
                self.timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.updateText), userInfo: nil, repeats: false)
            }
        }
    }

    @objc func updateText(){
        isFirstTextDisplayed.toggle()
        displayTextAndSpeak()
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
}
