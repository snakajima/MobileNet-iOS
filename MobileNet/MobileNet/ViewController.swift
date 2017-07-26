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
    @IBOutlet var viewMain:UIView!
    @IBOutlet var labelFirst:UILabel!
    @IBOutlet var btnStart:UIBarButtonItem!
    @IBOutlet var btnStop:UIBarButtonItem!
    
    // Note: We need to perform the vision request from a background queue, otherwise, the UI won't update (bug?)
    let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
    lazy var session:VSCaptureSession = VSCaptureSession(device: MTLCreateSystemDefaultDevice()!, pixelFormat: MTLPixelFormat.a8Unorm, delegate: self)
    
    var fRunning = false {
        didSet {
            btnStart.isEnabled = !fRunning
            btnStop.isEnabled = fRunning
            if fRunning {
                self.labelFirst.text = "Detecting..."
                session.start()
                let previewLayer = AVCaptureVideoPreviewLayer(session: session.session!)
                previewLayer.frame = viewMain.bounds
                viewMain.layer.addSublayer(previewLayer)
            } else {
                session.stop()
                viewMain.layer.sublayers?.forEach { (layer) in
                    layer.removeFromSuperlayer()
                }
            }
        }
    }
    var request:VNCoreMLRequest?
    var sampleBuffer:CMSampleBuffer?

    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let visionModel = try? VNCoreMLModel(for: MobileNet().model) {
            let request = VNCoreMLRequest(model: visionModel) { request, error in
                if let observations = request.results as? [VNClassificationObservation] {
                    // The observations appear to be sorted by confidence already, so we
                    // take the top 5 and map them to an array of (String, Double) tuples.
                    let top5 = observations[...4]
                        .map { ($0.identifier, Double($0.confidence)) }
                    //print(top5)
                    let (label, _) = top5[0]
                    DispatchQueue.main.async {
                        self.labelFirst.text = label
                    }
                }
                self.sampleBuffer = nil
            }
            request.imageCropAndScaleOption = .centerCrop
            //request.preferBackgroundProcessing = true
            self.request = request
            
            session.queue = queue
            session.cameraPosition = .back
            fRunning = true
        }
    }
    
    @IBAction func stop() {
        fRunning = false
    }
    
    @IBAction func start() {
        fRunning = true
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
            self.sampleBuffer = sampleBuffer // retain the reference count to make the pixelBuffer immutable.
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
            try? handler.perform([request])
        }
    }
}
