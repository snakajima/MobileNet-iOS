//
//  ViewController.swift
//  MobileNet
//
//  Created by SATOSHI NAKAJIMA on 7/25/17.
//  Copyright © 2017 SATOSHI NAKAJIMA. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    lazy var session:VSCaptureSession = VSCaptureSession(device: MTLCreateSystemDefaultDevice()!, pixelFormat: MTLPixelFormat.a8Unorm, delegate: self)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        session.start()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session.session!)
        previewLayer.frame = self.view.bounds
        self.view.layer.addSublayer(previewLayer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController : VSCaptureSessionDelegate {
    func didCaptureOutput(session:VSCaptureSession, texture textureIn:MTLTexture, sampleBuffer:CMSampleBuffer, presentationTime:CMTime) {
    }
}
