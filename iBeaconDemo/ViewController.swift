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
    
    //UUIDカラNSUUIDを作成
    let proximityUUID = NSUUID(UUIDString:"ac4caa7a-3e7b-4442-b803-15b1acaae482")
    var region  = CLBeaconRegion()
    var manager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        guard CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion) else { return }
        
        
        //CLBeaconRegionを生成
        region = CLBeaconRegion(proximityUUID: proximityUUID!, identifier:"EstimoteRegion") //ここで落ちたらUUIDがカス
        
        //デリゲートの設定
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
            //iBeaconによる領域観測を開始する
            print("観測開始")
            //self.status.text = "Starting Monitor"
            self.manager.startMonitoringForRegion(self.region)
        case .NotDetermined:
            print("許可承認")
            //self.status.text = "Starting Monitor"
            //デバイスに許可を促す
//            self.manager.requestWhenInUseAuthorization()
//            self.manager.startRangingBeaconsInRegion(self.region)

            if(UIDevice.currentDevice().systemVersion as NSString ).intValue >= 8 {
                //iOS8以降は許可をリクエストする関数をCallする
                self.manager.requestAlwaysAuthorization()
            }else{
                self.manager.startMonitoringForRegion(self.region)
            }
        case .Restricted, .Denied:
            //デバイスから拒否状態
            print("Restricted")
            //self.status.text = "Restricted Monitor"
        }
        
    }
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        manager.requestStateForRegion(region)
        //self.status.text = "Scanning..."
        print("Scanning...")
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion inRegion: CLRegion) {
        if (state == .Inside) {
            //領域内にはいったときに距離測定を開始
            manager.startRangingBeaconsInRegion(region)
        }
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("monitoringDidFailForRegion \(error)")
        //self.status.text = "Error :("
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError \(error)")
    }
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
        //self.status.text = "Possible Match"
    }
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        manager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
        manager.startMonitoringForRegion(region)
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        print(beacons)
        
        if(beacons.count == 0) { return }
        //複数あった場合は一番先頭のものを処理する
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
            reset()
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
    
    func reset(){
        print("status:none")
        print("uuid:none")
        print("major:none")
        print("minor:none")
        print("accuracy:none")
        print("rssi:none")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch CLLocationManager.authorizationStatus() {
        case .Authorized, .AuthorizedWhenInUse:
            //iBeaconによる領域観測を開始する
            print("観測開始")
            //self.status.text = "Starting Monitor"
            self.manager.startMonitoringForRegion(self.region)
        case .NotDetermined:
            print("許可承認")
            //self.status.text = "Starting Monitor"
            //デバイスに許可を促す
            //            self.manager.requestWhenInUseAuthorization()
            //            self.manager.startRangingBeaconsInRegion(self.region)
            
            if(UIDevice.currentDevice().systemVersion as NSString ).intValue >= 8 {
                //iOS8以降は許可をリクエストする関数をCallする
                self.manager.requestWhenInUseAuthorization()
            }else{
                self.manager.startMonitoringForRegion(self.region)
            }
        case .Restricted, .Denied:
            //デバイスから拒否状態
            print("Restricted")
            //self.status.text = "Restricted Monitor"
        }
    }
}

