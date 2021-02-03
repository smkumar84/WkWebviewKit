//
//  ViewController.swift
//  webKitSample
//
//  Created by Mahesh on 03/02/21.
//  Copyright © 2021 Mahesh. All rights reserved.
//

import UIKit
import WebKit
import Foundation


class ViewController: UIViewController,UIWebViewDelegate {
    
    
    var jsonString = String()

    
    //Native View
    @IBOutlet weak var companyIDTxtField: UITextField!
    @IBOutlet weak var userIDTxtField: UITextField!
    @IBOutlet weak var accessTokenTxtField: UITextField!
    @IBOutlet weak var iOSSubmit: UIButton!
    @IBOutlet weak var iOSNativeView: UIView!
    
    
    //Webform View
    @IBOutlet weak var webContentView: UIView!
    var webFormView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        nativeViewSetup()
        webViewSetup()
        // Do any additional setup after loading the view.
    }
    
   
    
    func nativeViewSetup(){
        
        // Native View setup
        companyIDTxtField.delegate = self
        userIDTxtField.delegate = self
        accessTokenTxtField.delegate = self
        
        self.iOSNativeView.layer.cornerRadius = 14
        self.iOSNativeView.layer.borderWidth = 2
        self.iOSNativeView.layer.borderColor = UIColor(red: 0.46, green: 0.84, blue: 1.00, alpha: 1.00).cgColor
        iOSSubmit.layer.cornerRadius = 10
        
        
    }
    
    func webViewSetup(){
   
        // Webview setup
        self.webContentView.layer.cornerRadius = 14
        self.webContentView.layer.borderWidth = 2
        self.webContentView.layer.borderColor = UIColor(red: 0.92, green: 0.59, blue: 0.58, alpha: 1.00).cgColor
        
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "sumbitWebToiOS")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        self.webFormView = WKWebView( frame: self.webContentView.bounds, configuration: config)
        
        self.webContentView.addSubview(self.webFormView!)
        
        // Load HTML From Local
        /*
        let url = Bundle.main.url(forResource: "index", withExtension: "html")!
        webFormView.loadFileURL(url, allowingReadAccessTo: url)
        */
        
        // Load HTML Web URL
        let url = URL(string: "https://smkumar84.github.io/index.html")
        
        
        let request = URLRequest(url: url!)
        webFormView.navigationDelegate = self
        webFormView.load(request)
    
    }
    
    @IBAction func submitDataiOStoWeb(_ sender: Any) {

        let alert = UIAlertController(title: "iOS Native --> WebForm", message: "Are your sure want to send data from iOS Native --> WebForm", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Ok", style: .default, handler: { action in
            self.createJsonToPass(companyID: self.companyIDTxtField.text! ,  userID: self.userIDTxtField.text! , accessToken:  self.accessTokenTxtField.text!)
                self.webFormView.evaluateJavaScript("fillTheiOSDatas('\(self.jsonString)')") { (any, error) in
            }
        })
        alert.addAction(ok)
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
            
        })
        alert.addAction(cancel)
        
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
        
        
    }
    
}

extension ViewController{
    func createJsonForJavaScript(for data: [String : Any]) -> String {
        var jsonString : String?
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            jsonString = String(data: jsonData, encoding: .utf8)!
            jsonString = jsonString?.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\\", with: "")
            
        } catch {
            print(error.localizedDescription)
        }
        print(jsonString!)
        return jsonString!
    }
    
    func createJsonToPass(companyID : String , userID : String = "" , accessToken : String = "" ) {
        
        let data = ["companyID": companyID ,"userID": userID , "accessToken": accessToken] as [String : Any]
        self.jsonString = createJsonForJavaScript(for: data)
        
    }
}


//MARK: - Web view delegate methods

extension ViewController : WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("didFinish")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    
    
    
}

//MARK: - Web view method to handle call backs

extension ViewController : WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
        let dict = message.body as? Dictionary<String, String>
        //print(dict)
        let clientData = ClientData((dict?["companyID"])!, (dict?["userID"])!, (dict?["accessToken"])!)
        
        if message.name == "sumbitWebToiOS" {
            self.sumbitWebToiOS(clientData: clientData)
        }
        
    }
    
    
    func sumbitWebToiOS(clientData:ClientData){
        print("sumbitToiOS")
        let alert = UIAlertController(title: "WebForm --> iOS Native", message: "Are your sure want to send data from WebForm --> iOS Native", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Ok", style: .default, handler: { action in
            self.companyIDTxtField.text = clientData.companyID
            self.userIDTxtField.text = clientData.userID
            self.accessTokenTxtField.text = clientData.accessToken
        })
        alert.addAction(ok)
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
            
        })
        alert.addAction(cancel)
        
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
    
    func endCurrentChat(isEnded: Bool){
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension ViewController:UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
}
