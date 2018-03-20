//
//  IOTAPIHelper.swift
//  IOTPeer
//
//  Created by Dark Bears on 20/03/18.
//  Copyright © 2018 Dark Bear. All rights reserved.
//

import UIKit
import SystemConfiguration
import MBProgressHUD
import AFNetworking

var HUD: MBProgressHUD?
let APPDELEGATE: AppDelegate = UIApplication.shared.delegate as! AppDelegate;


class IOTAPIHelper: NSObject {
    
    class func getDeviceStete(_ onUrl: String, parameters: NSDictionary, shouldShowHud showHUD: Bool, successClosure: @escaping (AnyObject?, String) -> (), failureClosure: @escaping (AnyObject?)->()) {
        if Reachability.isConnectedToNetwork() {
            if(showHUD) { Common.showHUD() }
            print("onUrl ", onUrl)
            
            let parameterDict = parameters.mutableCopy() as! NSMutableDictionary
            
            print("Parameters Sent: ", parameterDict)
            
            let manager = AFHTTPSessionManager()
            let reqSer = manager.requestSerializer
            reqSer.setValue("welcome", forHTTPHeaderField: "x-ha-access")
            reqSer.setValue("application/json", forHTTPHeaderField: "content-type")
            
            let resSer = manager.responseSerializer
            resSer.acceptableContentTypes =  (NSSet(objects: "application/json") as! Set<String>)
            
            manager.get(onUrl, parameters: parameterDict, progress: nil, success: { (task, response) in
                print("response: ", response as Any)
                Common.hideHUD()
                if let dictData = response as? NSArray {
                    successClosure(dictData, "Successful")
                }
            }, failure: { (task, error) in
                Common.hideHUD()
                failureClosure((error as AnyObject))
            })
        } else {
            failureClosure(nil)
        }
    }
    
    class func postDeviceStete(_ onUrl: String, parameters: NSDictionary, shouldShowHud showHUD: Bool, successClosure: @escaping (AnyObject?, String) -> (), failureClosure: @escaping (AnyObject?)->()) {
        if Reachability.isConnectedToNetwork() {
            if(showHUD) { Common.showHUD() }
            
            print("onUrl ", onUrl)
            
            let parameterDict = parameters.mutableCopy() as! NSMutableDictionary
            
            print("Parameters Sent: ", parameterDict)
            
            let manager = AFHTTPSessionManager()
            let reqSer = manager.requestSerializer
            reqSer.setValue("welcome", forHTTPHeaderField: "x-ha-access")
            reqSer.setValue("application/json", forHTTPHeaderField: "content-type")
            
            let resSer = manager.responseSerializer
            resSer.acceptableContentTypes =  (NSSet(objects: "application/json") as! Set<String>)
            
            manager.post(onUrl, parameters: parameterDict, progress: nil, success: { (task, response) in
                print("response: ", response as Any)
                Common.hideHUD()
                if let dictData = response as? NSArray {
                    successClosure(dictData, "Successful")
                }
            }, failure: { (task, error) in
                Common.hideHUD()
                failureClosure((error as AnyObject))
            })
        } else {
            failureClosure(nil)
        }
    }
    
    class func postDeviceSteteDataForRAW(onFullURL onUrl: String, parameters: NSDictionary, shouldShowHud showHUD: Bool, successClosure: @escaping (AnyObject?, String) -> (), failurClosure: @escaping (AnyObject?)->())    {
        if Reachability.isConnectedToNetwork() {
            if(showHUD) { Common.showHUD() }
            
            var request = URLRequest(url: URL(string: onUrl)!)
            request.httpMethod = "POST"
            request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
            request.setValue("welcome", forHTTPHeaderField: "x-ha-access")
            request.setValue("application/json", forHTTPHeaderField: "content-type")
            URLSession.shared.dataTask(with:request, completionHandler: {(data, response, error) in
                Common.hideHUD()
                if (error != nil) {
                    failurClosure((error as AnyObject))
                } else {
                    let jsonResonse = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
                    if let dictData = jsonResonse as? NSArray {
                        successClosure(dictData, "Successful")
                    }
                }
            }).resume()
            
        } else {
            failurClosure(nil)
        }
    }
}

public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
}

public class Common: NSObject {
    class func showHUD() {
        OperationQueue.main.addOperation {
            HUD = MBProgressHUD.showAdded(to: APPDELEGATE.window!, animated: true)
            HUD?.backgroundView.color = UIColor.black.withAlphaComponent(0.25)
        }
    }
    
    class func hideHUD() {
        OperationQueue.main.addOperation {
            MBProgressHUD.hideAllHUDs(for: APPDELEGATE.window!, animated: true)
        }
    }
}
