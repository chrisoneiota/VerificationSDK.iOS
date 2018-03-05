//
//  ViewController.swift
//  ROFLApp
//
//  Created by Adam Mitchell on 28/11/2017.
//  Copyright © 2017 MyUNiDAYS. All rights reserved.
//

import UIKit
import UnidaysVerificationSDK

class ViewController: UIViewController {
    
    let scheme = "sampleapp"
    
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var subdomainTextField: UITextField!
    @IBOutlet weak var channelSegmentedControl: UISegmentedControl!
    @IBOutlet weak var codeImageView: UIImageView!
    
    @IBAction func onGetACodeTapped(_ sender: Any) {
        
        let sdk = UnidaysSDK.sharedInstance
        let settings = UnidaysConfig(scheme: scheme, customerSubdomain: self.subdomainTextField.text!)
        try! sdk.setup(settings: settings)
        let channels = [UnidaysChannel.Online, UnidaysChannel.Instore]
        let channel = channels[channelSegmentedControl.selectedSegmentIndex]
        sdk.getCode(channel: channel, success: { (response) in
            self.codeTextField.text = response.code
            if let imageUrl = response.imageUrl as URL? {
                self.download(url: imageUrl)
            } else {
                self.codeImageView.image = nil
            }
            self.errorLabel.text = nil
        }, error: { (error) in
            self.errorLabel.text = error.localizedDescription
            self.codeTextField.text = nil
            self.codeImageView.image = nil
        })
    }
    
    func download(url: URL) {
        let session = URLSession(configuration: .default)
        //creating a dataTask
        let getImageFromUrl = session.dataTask(with: url, completionHandler: { (data, response, error) in
            
            //if there is any error
            if let e = error {
                //displaying the message
                print("Error Occurred: \(e)")
                
            } else {
                //in case of now error, checking wheather the response is nil or not
                if (response as? HTTPURLResponse) != nil {
                    
                    //checking if the response contains an image
                    if let imageData = data {
                        
                        //getting the image
                        let image = UIImage(data: imageData)
                        
                        //displaying the image
                        DispatchQueue.main.async {
                            self.codeImageView.image = image
                        }
                    } else {
                        print("Image file is currupted")
                    }
                } else {
                    print("No response from server")
                }
            }
        })
        
        //starting the download task
        getImageFromUrl.resume()
    }
}
