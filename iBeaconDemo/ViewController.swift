//
//  ViewController.swift
//  iBeaconDemo
//
//  Created by Arai Marina on 2/13/16.
//  Copyright © 2016 Arai Marina. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //UUIDからNSUUIDを作成
    let proximityUUID = NSUUID(UUIDString:"ac4caa7a-3e7b-4442-b803-15b1acaae482")
    var region = CLBeaconRegion()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        guard CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion) else { return }
        guard CLLocationManager.isRangingAvailable() else { return }
        
        region = CLBeaconRegion(proximityUUID: proximityUUID!, identifier:"EstimoteRegion") //ここで落ちたらUUIDがカス
        
        let manager = CLLocationManager()
        manager.delegate = self
        
        /*
        位置情報サービスへの認証状態を取得する
        NotDetermined   --  アプリ起動後、位置情報サービスへのアクセスを許可するかまだ選択されていない状態
        Restricted      --  設定 > 一般 > 機能制限により位置情報サービスの利用が制限中
        Denied          --  ユーザーがこのアプリでの位置情報サービスへのアクセスを許可していない
        Authorized      --  位置情報サービスへのアクセスを許可している
        */
        switch CLLocationManager.authorizationStatus() {
        case .Authorized, .AuthorizedWhenInUse:
            print("許可")
            manager.startMonitoringForRegion(region)
        case .NotDetermined:
            print("きいてみる")

            if(UIDevice.currentDevice().systemVersion as NSString ).intValue >= 8 {
                manager.requestAlwaysAuthorization()
            }else{
                manager.startMonitoringForRegion(region)
            }
        case .Restricted, .Denied:
            print("拒否")
        }
        
    }
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        print("境界判定 スタート")
        manager.requestStateForRegion(region)
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion inRegion: CLRegion) {
        switch state {
        case .Inside:
            print("inside")
            manager.stopMonitoringForRegion(inRegion)
            manager.startRangingBeaconsInRegion(inRegion as! CLBeaconRegion)
        case .Outside:
            print("outside")
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
        manager.stopMonitoringForRegion(region)
        manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
    }
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        manager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
        manager.startMonitoringForRegion(region)
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        print(beacons)
        
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
        if (beacon.proximity == CLProximity.Unknown) {
            print("Unknown Proximity")
            return
        } else if (beacon.proximity == CLProximity.Immediate) {
            print("Immediate")
        } else if (beacon.proximity == CLProximity.Near) {
            print("Near")
        } else if (beacon.proximity == CLProximity.Far) {
            print("Far")
        }
        print("OK")
        print(beacon.proximityUUID.UUIDString)
        print("\(beacon.major)")
        print("\(beacon.minor)")
        print("\(beacon.accuracy)")
        print("\(beacon.rssi)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch CLLocationManager.authorizationStatus() {
        case .Authorized, .AuthorizedWhenInUse:
            
            print("許可")
            manager.startMonitoringForRegion(region)
        case .NotDetermined:
            
            print("きいてみる")
            if(UIDevice.currentDevice().systemVersion as NSString ).intValue >= 8 {
                manager.requestWhenInUseAuthorization()
            }else{
                manager.startMonitoringForRegion(region)
            }
        case .Restricted, .Denied:
            
            print("拒否")
        }
    }
}

