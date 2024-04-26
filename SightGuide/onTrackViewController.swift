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
        
        animateButtonVisibility()
        
        navigationItem.hidesBackButton = true
        
    }

    func animateButtonVisibility() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.autoreverse, .repeat], animations: {
                self.tappableButton.alpha = 0.0
            }, completion: nil)
        }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if synthesizer.isSpeaking {
                synthesizer.stopSpeaking(at: .immediate)
            }
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
                // Delay before speaking the second text
                let delayBeforeSecondText = 5.5
                DispatchQueue.main.asyncAfter(deadline: .now() + delayBeforeSecondText) {
                    self.speak(text: "Swipe left to continue")
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

