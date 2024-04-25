//
//  ViewController.swift
//  SightGuide
//
//  Created by Student on 08/04/24.
//
import AVKit
import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var welcomeText: UILabel!
    @IBOutlet weak var SightGuide: UILabel!
    @IBOutlet weak var infoText: UILabel!
    @IBOutlet weak var tapText: UILabel!
    var synthesizer = AVSpeechSynthesizer()
    var isFirstTextDisplayed:Bool = true
    var timer: Timer?
    
    @IBOutlet var holdButton: UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        self.view.addGestureRecognizer(longPress)
        displayTextAndSpeak()
    }

    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            performSegue(withIdentifier: "ShowNextVC", sender: self)
        }
    }
    @IBAction func handleBackSwipe(segue: UIStoryboardSegue) {
        print("going back")
    }
    func displayTextAndSpeak(){
        if isFirstTextDisplayed {
//            welcomeText.text = "Welcome To"
//            SightGuide.text = "Sight Guide"
            speak(text: "welcome to Sight Guide")
            timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(updateText), userInfo: nil, repeats: false)
        } else {
//            infoText.text = "You will now be experiencing how the haptics will work to navigate you"
            speak(text: "You will now be experiencing how the haptics will work to navigate you")
            // Introduce a delay before speaking tapText
                    let delay = 4.0 // Adjust this value as needed (in seconds)
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                        self.tapText.text = "Tap and Hold on screen to continue"
                        self.speak(text: "Tap and Hold on screen to continue")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            synthesizer.stopSpeaking(at: .immediate)
        }
}

                                                                                                                                                                                 
