//
//  cameraViewController.swift
//  SightGuide
//
//  Created by Khushi Verma on 25/04/24.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    private let session = AVCaptureSession()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    private func setupCamera() {
        // Setup camera session and preview layer
        guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device) else {
                print("Failed to get camera input")
                return
            }

            if session.canAddInput(input) {
                session.addInput(input)
            }

            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)

            session.startRunning()
    }
}

