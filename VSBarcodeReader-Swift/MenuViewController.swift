//
//  ViewController.swift
//  VSBarcodeReader
//
//  Copyright © 2023 Vision Smarts. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet private weak var resultsLabel : UILabel!
    @IBOutlet private weak var resultsView : UIView!
    
    var scannedCodes: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UIInterfaceOrientationMask.allButUpsideDown
        }
        return UIInterfaceOrientationMask.portrait
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showInfo" { return true }
        if ToggleGroupButton.symbologiesMask()==0 {
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "Please select at least one barcode symbology", message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK",
                                                        style: .cancel,
                                                        handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
            return false
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scannerVC = segue.destination as? ScannerViewController {
            scannerVC.symbologies = ToggleGroupButton.symbologiesMask()
            scannerVC.batchScan = segue.identifier == "batchscan" ? true : false
            scannerVC.frameScan = segue.identifier == "framescan" ? true : false
            scannerVC.redlineScan = segue.identifier == "redlinescan" ? true : false
         }
    }
    
    @IBAction func shareAction() {
        if var text = resultsLabel.text {
            text += "\nscanned with Vision Smarts"
            let vc = UIActivityViewController(activityItems: [text], applicationActivities: [])
            vc.popoverPresentationController?.sourceView = self.resultsView! // for iPad
            present(vc, animated: true)
        }
    }

    @IBAction func closeScanner(unwindSegue: UIStoryboardSegue) {
        resultsLabel.text = scannedCodes.suffix(20).joined(separator:"\n")
    }
    
    @IBAction func closeInfo(unwindSegue: UIStoryboardSegue) {
    }

}

