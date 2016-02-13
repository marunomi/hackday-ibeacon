//
//  ViewController.swift
//  iBeaconDemo
//
//  Created by Arai Marina on 2/13/16.
//  Copyright © 2016 Arai Marina. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class ViewController: UIViewController, CLLocationManagerDelegate, UIWebViewDelegate {
    //webView http://daichi.x0.com/hackday/index.html
    
    //f8bfbb6e-2be5-4052-a8e2-acd921e43647 panda
    //ee9eaf8e-9620-4d74-9e23-1cb5f3e587fb mineruva
    //5f5bbfe6-5644-423a-b3db-58d29a34b315 rikuo
    
    let UUIDStrings = [
        "f8bfbb6e-2be5-4052-a8e2-acd921e43647",
        "ee9eaf8e-9620-4d74-9e23-1cb5f3e587fb",
        "5f5bbfe6-5644-423a-b3db-58d29a34b315"
    ]
    
    
    var regions: [CLBeaconRegion] = []
    
    
    let manager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //WebView 
        let myWebView : UIWebView = UIWebView()
        myWebView.delegate = self
        myWebView.frame = self.view.bounds
        self.view.addSubview(myWebView)
        let url: NSURL = NSURL(string: "http://daichi.x0.com/hackday/index.html")!
        let request: NSURLRequest = NSURLRequest(URL: url)
        myWebView.loadRequest(request)
        
        // Do any additional setup after loading the view, typically from a nib.
        
        guard CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion) else { return }
        guard CLLocationManager.isRangingAvailable() else { return }
        
        regions = UUIDStrings.flatMap(NSUUID.init)
                             .enumerate()
                             .map { CLBeaconRegion(proximityUUID: $0.1, identifier: "\($0.0)") }
        
        
        self.manager.delegate = self
        

        
    }
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        print("境界判定 スタート")
        self.manager.requestStateForRegion(region)
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion inRegion: CLRegion) {
        switch state {
        case .Inside:
            print("inside")
            self.manager.stopMonitoringForRegion(inRegion)
            self.manager.startRangingBeaconsInRegion(inRegion as! CLBeaconRegion)
        case .Outside:
            print("outside")
            self.manager.stopRangingBeaconsInRegion(inRegion as! CLBeaconRegion)
            self.manager.startMonitoringForRegion(inRegion)
        case .Unknown:
            print("unknown")
        }
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("monitoringDidFailForRegion \(error.description)")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError \(error.description)")
    }
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        self.manager.stopMonitoringForRegion(region)
        self.manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
    }
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        self.manager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
        self.manager.startMonitoringForRegion(region)
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        
        if beacons.isEmpty { return }
        
        
        /*
        beaconから取得できるデータ
        proximityUUID   :   regionの識別子
        major           :   識別子１
        minor           :   識別子２
        proximity       :   相対距離
        accuracy        :   精度
        rssi            :   電波強度
        */
        
        let params = [
            "beacons": beacons.map { beacon in
                [ "uuid": beacon.proximityUUID.UUIDString, "rrsi": beacon.rssi ]
            }
        ]
        
        print(JSON(params))
        
        Alamofire.request(.POST, "http://160.16.107.203:4000/api/location", parameters: params, encoding: .JSON).validate().responseJSON { res in
            switch res.result {
            case .Success(let value):
                let json = JSON(value)
                print(json)
                
            case .Failure(let error):
                print(error.description)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch CLLocationManager.authorizationStatus() {
        case .Authorized, .AuthorizedWhenInUse:
            
            print("許可")
            regions.forEach { self.manager.startMonitoringForRegion($0) }
        case .NotDetermined:
            
            print("きいてみる")
            if(UIDevice.currentDevice().systemVersion as NSString ).intValue >= 8 {
                self.manager.requestAlwaysAuthorization()
            }else{
                regions.forEach { self.manager.startMonitoringForRegion($0) }
            }
        case .Restricted, .Denied:
            
            print("拒否")
        }
    }
}

