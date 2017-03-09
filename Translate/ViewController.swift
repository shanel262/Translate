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
        if(textToTranslate.text.contains("<")){
            textToTranslate.text = ""
        }
    }
    
    @IBAction func swapText(_ sender: UIButton) {
        let text = textToTranslate.text
        textToTranslate.text = translatedText.text
        translatedText.text = text
        let comp0Row = pickerView.selectedRow(inComponent: 0)
        let comp1Row = pickerView.selectedRow(inComponent: 1)
        pickerView.selectRow(comp1Row, inComponent: 0, animated: true)
        pickerView.selectRow(comp0Row, inComponent: 1, animated: true)
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
        else if(!textToTranslate.hasText || textToTranslate.text.contains("<")){
            self.translatedText.text = "PLEASE ENTER TEXT TO TRANSLATE"
        }
        else
        {
            let langStr = (translateFrom + "|" + translateTo).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
            let urlStr:String = ("https://api.mymemory.translated.net/get?q="+escapedStr!+"&langpair="+langStr!)
        
            let url = URL(string: urlStr)
        
            let request = URLRequest(url: url!)// Creating Http Request
        
            SwiftLoader.show(title: "Loading...", animated: true)
            
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
                        SwiftLoader.hide()
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(component == 0){
            if(textToTranslate.text.contains("<") || !textToTranslate.hasText){
                if(row == 0){
                    textToTranslate.text = "<Text to Translate>"
                }
                else if(row == 1){
                    textToTranslate.text = "<Texte à traduire>"
                }
                else if(row == 2){
                    textToTranslate.text = "<Text zu übersetzen>"
                }
                else if(row == 3){
                    textToTranslate.text = "<Texto a traducir>"
                }
            }
            
        }
    }
}

