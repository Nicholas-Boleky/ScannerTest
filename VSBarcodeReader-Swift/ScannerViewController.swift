//
//  BarcodeScanner.swift
//  VSBarcodeReader
//
//  Copyright © 2023 Vision Smarts. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {

    // set by caller
    var symbologies: Int32 = 0
    var batchScan: Bool = false
    var redlineScan: Bool = false
    var frameScan: Bool = false

    // to be returned to caller
    var scannedCodes: [String] = []
    
    var captureSession: AVCaptureSession!
    var videoCaptureDevice: AVCaptureDevice!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var barcodeReader: VSBarcodeReader!
    
    var videoSetupOK = false
    
    var widthHeightRatio : Double = 1.0
    var narrowFrame : Bool = false
    
    var frameNumber = 0
    var frameSampling = 2
    var isScanning = false
    
    var beepSound: SystemSoundID! = 0
    
    @IBOutlet private weak var preview: UIView!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var flipButton: UIButton!
    @IBOutlet private weak var torchButton: UIButton!
    @IBOutlet private weak var resultsLabel : UILabel!
    @IBOutlet private weak var portraitOverlay : UIImageView!
    @IBOutlet private weak var landscapeOverlay : UIImageView!
    @IBOutlet private weak var portraitRedlineOverlay : UIImageView!
    @IBOutlet private weak var landscapeRedlineOverlay : UIImageView!
    @IBOutlet private weak var portraitFrameOverlay : UIImageView!
    @IBOutlet private weak var landscapeFrameOverlay : UIImageView!

    func flipCamera() {
        torchButton.isSelected = false
        setupTorch()
        let devices = AVCaptureDevice.devices(for:.video)
        captureSession.beginConfiguration()
        captureSession.removeInput(captureSession.inputs[0])
        if videoCaptureDevice == devices[0] {
            videoCaptureDevice = devices[1]
        }
        else {
            videoCaptureDevice = devices[0]
        }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            captureSession.commitConfiguration()
            return
        }
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        }
        captureSession.commitConfiguration()
        setupTorch()
    }
    
    @IBAction func flipAction() {
        let devices = AVCaptureDevice.devices(for:.video)
        if captureSession.isRunning && devices.count>1 {
            let blurView = UIVisualEffectView(frame: preview.bounds)
            blurView.effect = UIBlurEffect(style: .light)
            let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
            UIView.transition(with: self.view, duration: 0.5, options: transitionOptions, animations: {
                self.preview.addSubview(blurView)
            }, completion: { _ in
                self.flipCamera()
                blurView.removeFromSuperview()
            })
        }
    }
    
    func setupTorch() {
        if !videoCaptureDevice.isTorchAvailable {
            torchButton.isHidden = true
            torchButton.isSelected = false
            return
        }
        torchButton.isHidden = false
        if torchButton.isSelected {
            if videoCaptureDevice.torchMode != .on  {
                do {
                    try videoCaptureDevice.lockForConfiguration()
                    self.videoCaptureDevice.torchMode = .on
                    self.videoCaptureDevice.unlockForConfiguration()
                } catch { }
            }
        }
        else {
            if videoCaptureDevice.torchMode == .on {
                do {
                    try videoCaptureDevice.lockForConfiguration()
                    self.videoCaptureDevice.torchMode = .off
                    self.videoCaptureDevice.unlockForConfiguration()
                } catch { }
            }
        }
    }
    
    @IBAction func torchAction() {
        torchButton.isSelected = !torchButton.isSelected
        setupTorch()
    }
    
    func modelIdentifier() -> String {
        #if targetEnvironment(simulator)
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        #endif
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        barcodeReader = VSBarcodeReader()
        
        let path = String(format:"%@/%@", Bundle.main.resourcePath!, "/beep.wav")
        let filePath = URL(fileURLWithPath: path, isDirectory: false)
        AudioServicesCreateSystemSoundID(filePath as CFURL, &beepSound)
        
        let model = modelIdentifier()
        if model.starts(with: "iPhone3") || model.starts(with: "iPhone4") {
            frameSampling = 4;
        }

        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.high;
                
        videoCaptureDevice = AVCaptureDevice.default(for: .video)
        guard videoCaptureDevice != nil else { return }
        
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }

        let captureOutput = AVCaptureVideoDataOutput()
        captureOutput.alwaysDiscardsLateVideoFrames = true
        captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInitiated) ) //DispatchQueue.main)
        captureOutput.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey) : kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange];

        if (captureSession.canAddOutput(captureOutput)) {
            captureSession.addOutput(captureOutput)
        } else {
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = preview.layer.bounds // has to be done after views have been sized
        previewLayer.videoGravity = .resize
        preview.layer.addSublayer(previewLayer)

        videoSetupOK = true
    }

    
    override func viewDidLayoutSubviews()
    {
        if (!videoSetupOK) {
            return
        }

        // Only now have the views been sized
        previewLayer.frame = preview.layer.bounds
        
        let numDevices = AVCaptureDevice.devices(for: .video).count
        flipButton.isHidden = numDevices > 1 ? false : true
    }
    
    func setupFailed() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Cannot start the video camera", message: "Please check the  permissions in the settings", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
            self.performSegue(withIdentifier: "stopscan", sender: self) } ) )
            self.present(alertController, animated: true)
        }
        captureSession = nil
    }

    func resetResults() {
        scannedCodes.removeAll()
        resultsLabel.text = ""
        cancelButton.setTitle("Cancel", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !videoSetupOK {
            setupFailed()
            return
        }
        widthHeightRatio = Double(view.frame.size.width) / Double(view.frame.size.height)
        setOrientation( UIDeviceOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue) ?? UIDeviceOrientation.unknown ) // The device and UI orientation may not match in this case, the UI orientation is what matters
        setOverlay(for: self.traitCollection)
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
            isScanning = true
        }
        resetResults()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isScanning = false
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        focusAtCenter()
        updateDisplay()
    }

    func setOverlay(for collection: UITraitCollection) {
        
        portraitOverlay.isHidden = true
        portraitFrameOverlay.isHidden = true
        portraitRedlineOverlay.isHidden = true
        landscapeOverlay.isHidden = true
        landscapeFrameOverlay.isHidden = true
        landscapeRedlineOverlay.isHidden = true
        
        if collection.horizontalSizeClass == .regular || collection.verticalSizeClass == .compact  {
            // landscape or wide screen (iPad)
            narrowFrame = true
            if redlineScan {
                landscapeRedlineOverlay.isHidden = false
            } else if frameScan {
                landscapeFrameOverlay.isHidden = false
            } else {
                landscapeOverlay.isHidden = false
            }
        } else { // iPhone portrait
            narrowFrame = false
            if redlineScan {
                portraitRedlineOverlay.isHidden = false
            } else if frameScan {
                portraitFrameOverlay.isHidden = false
            } else {
                portraitOverlay.isHidden = false
            }
        }
        
    }
    
    func setOrientation(_ orientation: UIDeviceOrientation) {
        if let videoPreviewLayerConnection = previewLayer.connection {
            guard let newVideoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue),
                orientation.isPortrait || orientation.isLandscape else {
                    return
            }
            videoPreviewLayerConnection.videoOrientation = newVideoOrientation
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        setOverlay(for: newCollection)
     }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        widthHeightRatio = Double(size.width) / Double(size.height)
        setOrientation(UIDevice.current.orientation) // the future UI orientation is the current device orientation
    }
    
    private func focusAtCenter() {
       
        guard let device = self.videoCaptureDevice else {
            return
        }
        do {
            try device.lockForConfiguration()
           
            let center = CGPoint(x: 0.5, y: 0.5)
            if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusPointOfInterest = center
                device.focusMode = .continuousAutoFocus
            }
               
            if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposurePointOfInterest = center
                device.exposureMode = .continuousAutoExposure
            }
               
               device.unlockForConfiguration()
           } catch {
           print("Could not lock device for configuration: \(error)")
        }
    }

    // runs on global user-initiated qos queue
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // do not hog CPU on older devices
        frameNumber += 1
        if (frameNumber % frameSampling != 0) { return }
        
        guard let imageBuffer : CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        //NSLog("got image w=%d h=%d bpr=%d", CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer), CVPixelBufferGetBytesPerRow(imageBuffer) )
        self.decodeImageOmnidirectional(imageBuffer)
    }
    
    // runs on global user-initiated qos queue
    func decodeImageOmnidirectional(_ imgBuf: CVImageBuffer) {

        // What is the orientation of the overlay (frame, red line) relative to the capture video?
        let landscapeUI : Bool = (previewLayer.connection?.videoOrientation == .landscapeRight) || (previewLayer.connection?.videoOrientation == .landscapeLeft)
        
        // Active area where scanner will work, expressed in image coordinates (pixel rows along long side)
        // default: entire image
        var topLeft = CGPoint(x:0.0, y:0.0)
        var bottomRight = CGPoint(x:1.0, y:1.0)

        var activePercentage : Double = 1.0
        if frameScan {
            if narrowFrame { // height of narrow frame is 1/8 of view width
                activePercentage = 0.125
            }
            else { // height of tall frame is 1/2 of view width
                activePercentage = 0.5
            }
            activePercentage *= widthHeightRatio
        } else if redlineScan {
            activePercentage = 0.0 // that is how we signal the single-line scanning mode
        }
        
        if (activePercentage != 1.0) {
            if landscapeUI { // the red line or frame is aligned with the rows of pixels
                topLeft = CGPoint(x:0.0, y:0.5-activePercentage/2.0)
                bottomRight = CGPoint(x:1.0, y:0.5+activePercentage/2.0)
            }
            else { // the red line or frame cuts across the rows of pixels
                topLeft = CGPoint(x:0.5-activePercentage/2.0, y:0.0)
                bottomRight = CGPoint(x:0.5+activePercentage/2.0, y:1.0)
            }
        }
        
        var barcode : String? = nil
        // Call the scanner
        // The result array will either be empty or contain one element 
        let barcodeDataArray : Array<VSBarcodeData>! = barcodeReader.read(fromImageBufferMultiple: imgBuf, symbologies: symbologies, inRectFrom:topLeft, to:bottomRight) as? Array<VSBarcodeData>
        
        if (barcodeDataArray.count > 0) {
            let barcodeData : VSBarcodeData! = barcodeDataArray[0]
            let foundSymbology = barcodeData.symbology
                
            // Crude trick to avoid misreads in demo when all symbologies are selected.
            // A real app would only enable useful symbologies,
            // and would be able to validate against expected length, etc.
            if (foundSymbology != symbologies) { // more than one was enabled
                if (foundSymbology == VSSymbologies.kVSCodabar.rawValue) ||
                    (foundSymbology == VSSymbologies.kVSITF.rawValue) ||
                    (foundSymbology == VSSymbologies.kVSCode39.rawValue) {
                    if barcodeData.text.count < 4 {
                        return;
                    }
                }
            }

            barcode = barcodeData.text

            // If QR or DataMatrix, check whether ECI (Extended Channel Interpretation) is present and interpret data accordingly
            if (foundSymbology == VSSymbologies.kVSQRCode.rawValue || foundSymbology == VSSymbologies.kVSDataMatrix.rawValue) {
                let defaultEncoding = (foundSymbology == VSSymbologies.kVSQRCode.rawValue) ? String.Encoding.utf8 : String.Encoding.isoLatin1
                barcode = BarcodeHelper.string(withECIData: barcodeData.data, mode: barcodeData.mode, encoding: defaultEncoding.rawValue)
            }
            
            guard barcode != nil else { return }
            
            DispatchQueue.main.async {
                self.barcodeFound(code: barcode!, with: foundSymbology)
            }
        }

    }
    
    let symbologyAbbrv = [ 0x0001 : "EAN",
                           0x0002 : "EAN8",
                           0x0004 : "UPCE",
                           0x0008 : "ITF",
                           0x0010 : "Code39",
                           0x0020 : "Code128",
                           0x0040 : "Codabar",
                           0x0080 : "Code93",
                           0x0100 : "Std2of5",
                           0x0200 : "Telepen",
                           0x0400 : "GS1_Omnidir",
                           0x0800 : "GS1_Limited",
                           0x1000 : "GS1_Expanded",
                           0x2000 : "EAN+2",
                           0x4000 : "EAN+5",
                           0x8000 : "QR",
                          0x10000 : "DataMatrix" ]
    
    func barcodeFound(code: String, with symbology: Int) {
        if !isScanning { // for frames arriving while view is being dismissed
            return
        }
        let latest = String(format:"%@: %@", symbologyAbbrv[Int(symbology)] ?? "", code)
        if nil == scannedCodes.firstIndex(of: latest) {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            // AudioServicesPlaySystemSound(beepSound)
            scannedCodes.append(latest)
            updateDisplay()
            if !batchScan {
                isScanning = false
                performSegue(withIdentifier: "stopscan", sender: self)
            }
        }
    }

    func ellipsis(_ s:String) -> String {
        if (s.count <= 61) { return s }
        else { return s.prefix(29) + " … " + s.suffix(29) }
    }
    
    func updateDisplay() {
        if (scannedCodes.count == 0) {
            resultsLabel.text = "Scanning..."
        }
        else  {
            cancelButton.setTitle("Done", for: .normal)
            if (scannedCodes.count <= 1) {
                resultsLabel.text = scannedCodes.suffix(20).joined(separator:"\n")
            }
            else {
                resultsLabel.text = scannedCodes.suffix(20).map(ellipsis).joined(separator:"\n")+String(format:"\n(%d scanned)", scannedCodes.count)
            }
        }
    }
    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return .portrait // prevents rotation of UI
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        NSLog("segue: %@ %@ %@", segue.identifier ?? "nil", segue.description, segue.destination)
        if let menuVC = segue.destination as? MenuViewController {
            menuVC.scannedCodes = scannedCodes
        }
    }
}
