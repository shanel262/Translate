//
//  ViewController.swift
//  Translate
//
//  Created by Robert O'Connor on 16/10/2015.
//  Copyright © 2015 WIT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var textToTranslate: UITextView!
    @IBOutlet weak var translatedText: UITextView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var languages = [["English", "French", "German", "Spanish"],["English", "French", "German", "Spanish"]]
    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    
    //var data = NSMutableData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textToTranslate.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_: Set<UITouch>, with: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textToTranslate.text = ""
    }
    
    @IBAction func translate(_ sender: AnyObject) {
        
        let str = textToTranslate.text
        let escapedStr = str?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)

        var translateFrom = ""
        switch pickerView.selectedRow(inComponent: 0) {
        case 0:
            translateFrom = "en"
        case 1:
            translateFrom = "fr"
        case 2:
            translateFrom = "de"
        case 3:
            translateFrom = "es"
        default:
            translateFrom = "fr"
        }
        
        var translateTo = ""
        switch pickerView.selectedRow(inComponent: 1) {
        case 0:
            translateTo = "en"
        case 1:
            translateTo = "fr"
        case 2:
            translateTo = "de"
        case 3:
            translateTo = "es"
        default:
            translateTo = "fr"
        }
        
        if(translateFrom == translateTo){
            self.translatedText.text = "CHOSEN LANGUAGES MUST BE DIFFERENT"
        }
        else
        {
            let langStr = (translateFrom + "|" + translateTo).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
            let urlStr:String = ("https://api.mymemory.translated.net/get?q="+escapedStr!+"&langpair="+langStr!)
        
            let url = URL(string: urlStr)
        
            let request = URLRequest(url: url!)// Creating Http Request
        
            //var data = NSMutableData()var data = NSMutableData()
        
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            indicator.color = UIColor.blue
            indicator.center = view.center
            view.addSubview(indicator)
            indicator.startAnimating()
        
            var result = "<Translation Error>"
        
            let task = defaultSession.dataTask(with: request){
                (data, response, error) in

                if let httpResponse = response as? HTTPURLResponse {
                    if(httpResponse.statusCode == 200){

                        let jsonDict: NSDictionary!=(try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
                    
                        if(jsonDict.value(forKey: "responseStatus") as! NSNumber == 200){
                            let responseData: NSDictionary = jsonDict.object(forKey: "responseData") as! NSDictionary
                        
                            result = responseData.object(forKey: "translatedText") as! String
                        }
                    }
                
                    DispatchQueue.main.sync()
                    {
                        indicator.stopAnimating()
                        self.translatedText.text = result
                    }
                }
            }
            task.resume()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return languages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[component][row]
    }
    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//    }
}

