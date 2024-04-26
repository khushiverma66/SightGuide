//
//  hapticGuideEndsViewController.swift
//  SightGuide
//
//  Created by Khushi Verma on 25/04/24.
//
import Foundation
import AVKit
import UIKit


class hapticGuideEndsViewController: UIViewController {

    var synthesizer = AVSpeechSynthesizer()
    var isFirstTextDisplayed:Bool = true
    var timer: Timer?
    
    
    @IBOutlet var holdButton: UILongPressGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        self.view.addGestureRecognizer(longPress)
        displayTextAndSpeak()
        
        navigationItem.hidesBackButton = true
    }

    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            performSegue(withIdentifier: "ShowNextVC", sender: self)
        }
    }
    @IBAction func handleBackSwipe(segue: UIStoryboardSegue) {
        print("going back")
    }
    
    func displayTextAndSpeak() {
        if isFirstTextDisplayed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.speak(text: "Haptic guide ends")
            
                
                // Delay before speaking the second text
                let delayBeforeSecondText = 2.5
                DispatchQueue.main.asyncAfter(deadline: .now() + delayBeforeSecondText) {
                    self.speak(text: "Let's start moving")
                }
                
                // Delay before speaking the third text
                let delayBeforeThirdText = delayBeforeSecondText + 2.0
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

