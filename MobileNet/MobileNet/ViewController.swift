//
//  ViewController.swift
//  MobileNet
//
//  Created by SATOSHI NAKAJIMA on 7/25/17.
//  Copyright © 2017 SATOSHI NAKAJIMA. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController {
    let model = MobileNetX()
    lazy var visionModel = try? VNCoreMLModel(for: self.model.model)
    var request:VNCoreMLRequest?
    lazy var session:VSCaptureSession = VSCaptureSession(device: MTLCreateSystemDefaultDevice()!, pixelFormat: MTLPixelFormat.a8Unorm, delegate: self)
    var sampleBuffer:CMSampleBuffer?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let visionModel = self.visionModel {
            request = VNCoreMLRequest(model: visionModel) { request, error in
                if let observations = request.results as? [VNClassificationObservation] {
                    // The observations appear to be sorted by confidence already, so we
                    // take the top 5 and map them to an array of (String, Double) tuples.
                    let top5 = observations.prefix(through: 4)
                        .map { ($0.identifier, Double($0.confidence)) }
                    print(top5)
                }
                self.sampleBuffer = nil
            }
            request!.imageCropAndScaleOption = .centerCrop
        }
        session.start()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session.session!)
        previewLayer.frame = self.view.bounds
        self.view.layer.addSublayer(previewLayer)
    }
}

extension ViewController : VSCaptureSessionDelegate {
    func didCaptureOutput(session:VSCaptureSession, texture textureIn:MTLTexture, sampleBuffer:CMSampleBuffer, presentationTime:CMTime) {
        if self.sampleBuffer != nil {
            print("skip")
            return
        }
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
           let request = self.request {
            self.sampleBuffer = sampleBuffer
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
            try? handler.perform([request])
        }
    }
}
