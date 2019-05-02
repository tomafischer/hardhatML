//
//  ViewController.swift
//  hardhat
//
//  Created by Fischer, Thomas Alfons on 4/30/19.
//  Copyright © 2019 Fischer, Thomas Alfons. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var cameraDisplay: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         setUpCamera()
    }

    func setUpCamera(){
        guard let device = AVCaptureDevice.default(for: .video) else {return}
        guard let input = try? AVCaptureDeviceInput(device: device) else {return}
        
        let session = AVCaptureSession()
        session.sessionPreset = .hd1920x1080
        
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        cameraDisplay.layer.addSublayer(previewLayer)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label:"CameraOutput"))
     
        session.addInput(input)
        session.addOutput(output)
        session.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //print("Camputre Output")
        guard let sampleBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Sample Buffer could not be retrieved")
            return }
        scanImage(buffer: sampleBuffer)
        
    }
    func scanImage(buffer: CVPixelBuffer){
        //print("Processing buffer..")
        guard let model = try? VNCoreMLModel(for: HardhatWatch().model ) else {return}
        //guard let model = try? VNCoreMLModel(for: msHardHat().model) else {
            //print("could not load model")
           // return}
        let request = VNCoreMLRequest(model: model){ request, _ in
            guard let results = request.results as? [VNClassificationObservation] else { return}
        
            guard let mostConfidentResult = results.first else { return }
            let confidenceText = "\n \(Int(mostConfidentResult.confidence * 100 ))%"
            
            DispatchQueue.main.async{
                self.resultLabel.text = "\(mostConfidentResult.identifier) - \(confidenceText)"
            }
            
        }
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: buffer, options: [ :])
        do {
            try requestHandler.perform([request])
        } catch {
            print(error)
        }
    }

}

