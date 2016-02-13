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

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //webView http://daichi.x0.com/hackday/index.html
    
    //UUIDからNSUUIDを作成
    let proximityUUID = NSUUID(UUIDString:"5f5bbfe6-5644-423a-b3db-58d29a34b315")
    
    //f8bfbb6e-2be5-4052-a8e2-acd921e43647 panda
    //ee9eaf8e-9620-4d74-9e23-1cb5f3e587fb mineruva
    //5f5bbfe6-5644-423a-b3db-58d29a34b315 rikuo
    
    
    var testRegion = CLBeaconRegion()
    
    let manager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        guard CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion) else { return }
        guard CLLocationManager.isRangingAvailable() else { return }
        
        testRegion = CLBeaconRegion(proximityUUID: proximityUUID!, identifier:"EstimoteRegion") //ここで落ちたらUUIDがカス
        testRegion.notifyOnEntry = true
        testRegion.notifyOnExit = true
        testRegion.notifyEntryStateOnDisplay = true
        
        self.manager.delegate = self
        
        /*
        位置情報サービスへの認証状態を取得する
        NotDetermined   --  アプリ起動後、位置情報サービスへのアクセスを許可するかまだ選択されていない状態
        Restricted      --  設定 > 一般 > 機能制限により位置情報サービスの利用が制限中
        Denied          --  ユーザーがこのアプリでの位置情報サービスへのアクセスを許可していない
        Authorized      --  位置情報サービスへのアクセスを許可している
        */
        
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
        //print(beacons)
        
        if beacons.isEmpty { return }
        
        let beacon = beacons[0]
        
        /*
        beaconから取得できるデータ
        proximityUUID   :   regionの識別子
        major           :   識別子１
        minor           :   識別子２
        proximity       :   相対距離
        accuracy        :   精度
        rssi            :   電波強度
        */
        
        switch beacon.proximity {
        case .Immediate:
            print("Immediate")
        case .Near:
            print("Near")
        case .Far:
            print("Far")
        case .Unknown:
            print("Unknown")
        }
        print(beacon.proximityUUID.UUIDString)
        print("\(beacon.major)")
        print("\(beacon.minor)")
        print("\(beacon.accuracy)")
        print("\(beacon.rssi)")
        
        let params = [
            "beacons": [
                [ "uuid": beacon.proximityUUID.UUIDString , "rssi": beacon.rssi ],
                [ "uuid": beacon.proximityUUID.UUIDString , "rssi": beacon.rssi ]
            ]
        ]
        
        let request = NSURL(string: "http://160.16.107.203:4000/api/location").flatMap(NSMutableURLRequest.init)
        
        request?.HTTPMethod = "POST"
        request?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let paramJSON: NSData? = try? JSON(params).rawData()
        
        paramJSON.map { request?.HTTPBody = $0 }
        
        guard let _request = request else { return }
        Alamofire.request(_request).validate().responseJSON { res in
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
            self.manager.startMonitoringForRegion(testRegion)
        case .NotDetermined:
            
            print("きいてみる")
            if(UIDevice.currentDevice().systemVersion as NSString ).intValue >= 8 {
                self.manager.requestAlwaysAuthorization()
            }else{
                self.manager.startMonitoringForRegion(testRegion)
            }
        case .Restricted, .Denied:
            
            print("拒否")
        }
    }
}

