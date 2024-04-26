//
//  onTrackViewController.swift
//  SightGuide
//
//  Created by Khushi Verma on 25/04/24.
//

import Foundation
import AVKit
import UIKit


class onTrackViewController: UIViewController {

    var synthesizer = AVSpeechSynthesizer()
    var isFirstTextDisplayed:Bool = true
    var timer: Timer?
    
    
    @IBOutlet weak var tappableButton: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
//        self.view.addGestureRecognizer(longPress)
        
        displayTextAndSpeak()
        
        tappableButton.backgroundColor = .black
        
        tappableButton.layer.masksToBounds = true
        tappableButton.layer.cornerRadius = tappableButton.frame.height / 2
        
        //animateButtonVisibility()
        
        navigationItem.hidesBackButton = true
        
    }
//    override func viewDidAppear(_ animated: Bool) {
//            super.viewDidAppear(animated)
//            
//            animateButtonVisibility() // Call animation when the view appears
//        }
    
//    override func viewWillAppear(_ animated: Bool) {
//            super.viewWillAppear(animated)
//            if synthesizer.isSpeaking {
//                synthesizer.stopSpeaking(at: .immediate)
//            }
//        animateButtonVisibility()
//        }
//    
//    func animateButtonVisibility() {
//        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.autoreverse, .repeat], animations: {
//                self.tappableButton.alpha = 0.0
//            }, completion: nil)
//        }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            displayTextAndSpeak()
        
            
            // Ensure tappableButton frame is properly set before animation
            tappableButton.backgroundColor = .black
            tappableButton.layer.masksToBounds = true
            tappableButton.layer.cornerRadius = tappableButton.frame.height / 2
            
            animateButtonVisibility() // Call animation when the view appears
        }
        
        func animateButtonVisibility() {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 1.0
            animation.toValue = 0.0
            animation.duration = 0.5
            animation.autoreverses = true
            animation.repeatCount = .infinity
            
            tappableButton.layer.add(animation, forKey: "opacityAnimation")
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            // Stop the animation when the view disappears
            tappableButton.layer.removeAnimation(forKey: "opacityAnimation")
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
                self.speak(text: "This haptic means that there is no obstacle in the way and you are going in the right direction")
                self.timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.updateText), userInfo: nil, repeats: false)
            }
        }
        isFirstTextDisplayed = false
    }

    @objc func updateText(){
        //isFirstTextDisplayed.toggle()
        displayTextAndSpeak()
    }
    func speak(text: String){
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.50
        utterance.volume = 1
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
}

