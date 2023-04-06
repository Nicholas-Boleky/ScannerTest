//
//  InfoViewController.swift
//  VSBarcodeReader
//
//  Copyright © 2023 Vision Smarts. All rights reserved.
//

import UIKit
import WebKit

class InfoViewController: UIViewController, WKUIDelegate {

    @IBOutlet weak var webViewContainer: UIView!
    var webView: WKWebView!

    override func loadView() {
        super.loadView()
        // to support iOS versions before 11, must create WKWebView in code to avoid NSCoding bug
        // see quinntaylor at https://forums.developer.apple.com/thread/85459
        let webConfiguration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: webConfiguration)
        if let webView = self.webView {
            webView.translatesAutoresizingMaskIntoConstraints = false
            self.webViewContainer.addSubview(webView)
            webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor).isActive = true
            webView.rightAnchor.constraint(equalTo: webViewContainer.rightAnchor).isActive = true
            webView.leftAnchor.constraint(equalTo: webViewContainer.leftAnchor).isActive = true
            webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor).isActive = true
            webView.heightAnchor.constraint(equalTo: webViewContainer.heightAnchor).isActive = true
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let myURL = URL(string: "https://www.visionsmarts.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    @IBAction func shareAction(sender: UIBarButtonItem) {
        let vc = UIActivityViewController(activityItems: [self.webView.url!], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = sender // for iPad
        present(vc, animated: true)
    }
    
}
