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
    var feedbackGenerator: UIImpactFeedbackGenerator?
    var displayLink: CADisplayLink?
    
    @IBOutlet var holdButton: UILongPressGestureRecognizer!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        self.view.addGestureRecognizer(longPress)
        displayTextAndSpeak()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //stopSpeech()
        
    }
    

    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
               case .began:
                   feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
                   feedbackGenerator?.prepare()
                   displayLink = CADisplayLink(target: self, selector: #selector(updateHapticIntensity))
                   displayLink?.add(to: .current, forMode: .default)
            
                    //performSegue(withIdentifier: "ShowNextVC", sender: self)
            synthesizer.stopSpeaking(at:.immediate)
            
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
    
    @objc func updateHapticIntensity() {
            guard let feedbackGenerator = feedbackGenerator else { return }
            let intensity = min(1.0, CGFloat(displayLink?.timestamp ?? 0.0) / 2.0) // Adjust the divisor to control the intensity change speed
            feedbackGenerator.impactOccurred(intensity: intensity)
        }

    
//    func triggerHapticFeedback() {
//            let generator = UIImpactFeedbackGenerator(style: .medium)
//            generator.prepare()
//            generator.impactOccurred()
//        }
    
    
    
    @IBAction func handleBackSwipe(segue: UIStoryboardSegue) {
        print("going back")
    }
    func displayTextAndSpeak(){
        

            speak(text: "welcome to Sight Guide. You will now be experiencing how the haptics will work to navigate you, Tap and Hold on screen to continue")

        
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
    
//    func stopSpeech() {
//        synthesizer.stopSpeaking(at: .immediate)
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//            synthesizer.stopSpeaking(at: .immediate)
//        }
}

                                                                                                                                                                                 
