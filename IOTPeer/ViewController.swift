//
//  ViewController.swift
//  IOTPeer
//
//  Created by Dark Bears on 20/03/18.
//  Copyright © 2018 Dark Bear. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnLightOnOff: UIButton!
    @IBOutlet weak var sliderLightBrightness: UISlider!
    
    @IBOutlet weak var segFanSpeed: UISegmentedControl!
    
    @IBOutlet weak var lblTemp: UILabel!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var btnPlus: UIButton!
    
    var acTemperature:Float = 16.0 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewContainer.layer.borderColor = UIColor.black.cgColor
        viewContainer.layer.borderWidth = 0.5
        viewContainer.layer.cornerRadius = 5.0
        
        btnMinus.layer.borderColor = UIColor.black.cgColor
        btnMinus.layer.borderWidth = 0.5
        btnMinus.layer.cornerRadius = 5.0
        
        btnPlus.layer.borderColor = UIColor.black.cgColor
        btnPlus.layer.borderWidth = 0.5
        btnPlus.layer.cornerRadius = 5.0
        
        setTemperatureString()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnOnOffTouched(_ sender: UIButton) {
        lightOnOff(state: !btnLightOnOff.isSelected)
        //changeLightBrightness(lightIntensity: 50)
    }
    
    @IBAction func sliderBrightnessValueChanged(_ sender: UISlider) {
        changeLightBrightness(lightIntensity: Int(sender.value))
    }
    
    @IBAction func segValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            let param = ["entity_id": "climate.57_2_cooling_1", "fan_mode":"Auto Low"] as NSDictionary
            performActionWith(onURL: "http://192.168.100.1:8123/api/services/climate/set_fan_mode", withParameter: param)
        } else {
            let param = ["entity_id": "climate.57_2_cooling_1", "fan_mode":"On Low"] as NSDictionary
            performActionWith(onURL: "http://192.168.100.1:8123/api/services/climate/set_fan_mode", withParameter: param)
        }
    }
    
    @IBAction func btnMinusTouched(_ sender: UIButton) {
        if acTemperature > 16.0 {
            acTemperature = acTemperature - 0.5
        }
        
        setTemperatureString()
        let param = ["entity_id": "climate.57_2_cooling_1", "temperature":"\(acTemperature)"] as NSDictionary
        performActionWith(onURL: "http://192.168.100.1:8123/api/services/climate/set_temperature", withParameter: param)
    }
    
    @IBAction func btnPlusTouched(_ sender: Any) {
        if acTemperature <= 25.5 {
            acTemperature += 0.5
        }
        setTemperatureString()
        let param = ["entity_id": "climate.57_2_cooling_1", "temperature":"\(acTemperature)"] as NSDictionary
        performActionWith(onURL: "http://192.168.100.1:8123/api/services/climate/set_temperature", withParameter: param)
    }
    
    func setTemperatureString() {
        lblTemp.attributedText = getTempretureString(acTemperature, forRoomType: "", fontSize: lblTemp.font.pointSize)
    }
    
    func getTempretureString(_ temperature: Float, forRoomType roomType: String, fontSize: CGFloat) -> NSMutableAttributedString {
        
        let fontS: UIFont = UIFont(name: "Nilland-ExtraBold", size: fontSize)!
        let strTemp = "\(Float(temperature))0c\(roomType)"
        
        let mutableAttributedString = NSMutableAttributedString.init(string: strTemp, attributes: [NSAttributedStringKey.font: fontS.withSize(fontSize)])
        mutableAttributedString.setAttributes([NSAttributedStringKey.font: UIFont(name: "Nilland-ExtraBold", size: fontSize / 2)!, NSAttributedStringKey.baselineOffset:fontSize == 35  ? 10 : 5], range: NSRange(location: 4, length: 2))
        
        return mutableAttributedString
    }
    
    func lightOnOff(state: Bool) -> Void {
        var strURL: String!
        if state {
            strURL = "http://192.168.100.1:8123/api/services/light/turn_on"
            
        } else {
            strURL = "http://192.168.100.1:8123/api/services/light/turn_off"
        }
        var param = ["entity_id": "light.55_1_level"] as NSDictionary
        IOTAPIHelper.postDeviceSteteDataForRAW(onFullURL: strURL, parameters: param, shouldShowHud: true, successClosure: { (response, message) in
            if message == "Successful" {
                DispatchQueue.main.async {
                    self.btnLightOnOff.isSelected = !self.btnLightOnOff.isSelected
                    self.sliderLightBrightness.isEnabled = self.btnLightOnOff.isSelected
                }
            }
        }, failurClosure: { (error) in
            if (error != nil) {
                let alertController = UIAlertController(title: "ALERT", message: "Internal Error!", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
                }))
                self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "ALERT", message: "No Internet Connection!", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
                }))
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
    
    
    func changeLightBrightness(lightIntensity: Int) {
        
        let param = ["entity_id": "light.55_1_level", "brightness_pct":"\(lightIntensity)"] as NSDictionary
        
        IOTAPIHelper.postDeviceSteteDataForRAW(onFullURL: "http://192.168.100.1:8123/api/services/light/turn_on", parameters: param, shouldShowHud: false, successClosure: { (response, message) in
            if message == "Successful" {
                
            }
        }, failurClosure: { (error) in
            if (error != nil) {
                let alertController = UIAlertController(title: "ALERT", message: "Internal Error!", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
                }))
                self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "ALERT", message: "No Internet Connection!", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
                }))
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
    
    func performActionWith(onURL url: String, withParameter param: NSDictionary) {
        IOTAPIHelper.postDeviceSteteDataForRAW(onFullURL: url, parameters: param, shouldShowHud: false, successClosure: { (response, message) in
            if message == "Successful" {
                print("Action was successful for :")
                //print("Entity ID: \(param["entity_id"]!)")
                //print("Source: \(param["source"]!)")
            }
        }, failurClosure: { (error) in
            if (error != nil) {
                print("Error is : "+"\(error!)")
            } else {
                print("Error is : No Internet Connection!")
            }
        })
    }
}

