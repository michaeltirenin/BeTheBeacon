//
//  ViewController.swift
//  BeTheBeacon
//
//  Created by Michael Tirenin on 8/21/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//
// http://www.codemag.com/Article/1405051
// http://ibeaconmodules.us/blogs/news/14702963-tutorial-swift-based-ibeacon-app-development-with-corelocation-on-apple-ios-7-8

import UIKit
import CoreBluetooth
import CoreLocation

class ViewController: UIViewController, CBPeripheralManagerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var startButtonOutlet: UIButton!
    
    @IBOutlet weak var beaconFoundLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var minorLabel: UILabel!
    @IBOutlet weak var accuracyLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var regionStatusLabel: UILabel!
    
    let myUUID = NSUUID(UUIDString: "15D88457-4163-40D8-A795-F8A65CD8628B") //iPhone
//    let myUUID = NSUUID(UUIDString: "DBD9A703-CA23-4B95-9B63-1E847C1CE61A") //iPad
    let myIdentifier = "com.michaeltirenin.beacons.codefellows"
    
    var beaconData = NSDictionary()
    var beaconRegion = CLBeaconRegion()
    var peripheralManager = CBPeripheralManager()
    
    var beacons = []
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // initialize beacon region
        self.beaconRegion = CLBeaconRegion(proximityUUID: myUUID, identifier: myIdentifier)
        self.beaconData = beaconRegion.peripheralDataWithMeasuredPower(nil)
        
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        self.locationManager.delegate = self
        
//        self.locationManager.startMonitoringForRegion(self.beaconRegion)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.startButtonOutlet.titleLabel.text = "Start"
    }
    
    override func viewDidAppear(animated: Bool) {
        locationManager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    override func viewDidDisappear(animated: Bool) {
        locationManager.stopRangingBeaconsInRegion(beaconRegion)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func startButton(sender: AnyObject) {
        
        if self.peripheralManager.isAdvertising == false {
            
            self.peripheralManager.startAdvertising(self.beaconData)
            self.view.backgroundColor = UIColor.greenColor()
            self.startButtonOutlet.setTitle("Stop", forState: UIControlState.Normal)
            self.statusLabel.text = "Broadcasting ..."
            println("broadcasting--")

        } else if self.peripheralManager.isAdvertising == true {
         
            self.peripheralManager.stopAdvertising()
            self.view.backgroundColor = UIColor.redColor()
            self.startButtonOutlet.setTitle("Start", forState: UIControlState.Normal)
            self.statusLabel.text = "Stopped"
            println("stopped--")

        }
    }
// initial set-up (before button press)
    func peripheralManagerDidUpdateState(peripheral : CBPeripheralManager) {
        
        if peripheral.state == CBPeripheralManagerState.PoweredOn {
            // bluetooth on
            println("broadcasting1")
            self.view.backgroundColor = UIColor.greenColor()
            self.statusLabel.text = "Broadcasting ..."
            self.startButtonOutlet.setTitle("Stop", forState: UIControlState.Normal)
            self.peripheralManager.startAdvertising(beaconData)
            
        } else if peripheral.state == CBPeripheralManagerState.PoweredOff {
            // bluetooth is off - stop broadcasting
            println("stopped1")
            self.view.backgroundColor = UIColor.redColor()
            self.statusLabel.text = "Stoped"
            self.startButtonOutlet.setTitle("Start", forState: UIControlState.Normal)
            self.peripheralManager.stopAdvertising()
            
        } else if peripheral.state ==  CBPeripheralManagerState.Unsupported {
            // not supported
            println("unsupported")
        }
    }
    
    // MARK: Region Monitoring
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        
        // start ranging for iBeacons
//        self.locationManager.startRangingBeaconsInRegion(self.beaconRegion) //already called in ViewWillAppear
        
        self.regionStatusLabel.text = "Entered Region"
        var localNotification = UILocalNotification()
        localNotification.alertBody = "You have entered the region you are monitoring."
        
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.alertAction = "Details"
        UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        
        // stop ranging for iBeacons
//        self.locationManager.stopRangingBeaconsInRegion(self.beaconRegion) // already called in ViewDidDisappear
        
        self.regionStatusLabel.text = "Exited Region"
        var localNotification = UILocalNotification()
        localNotification.alertBody = "You have exited the region you are monitoring."

        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.alertAction = "Details"
        UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)

        self.beaconFoundLabel.text = "No"

    }

    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
    
        if beacons.count > 0 {
            let nearestBeacon: CLBeacon = beacons.last as CLBeacon
        
            self.beaconFoundLabel.text = "Yes"
            self.uuidLabel.text = "\(nearestBeacon.proximityUUID.UUIDString)"
            self.majorLabel.text = "\(nearestBeacon.major.integerValue)"
            self.minorLabel.text = "\(nearestBeacon.minor.integerValue)"
            self.accuracyLabel.text = "\(nearestBeacon.accuracy)"
            self.rssiLabel.text = "\(nearestBeacon.rssi as Int)"
        
            switch nearestBeacon.proximity {
            case CLProximity.Unknown:
                self.distanceLabel.text = "Unknown Proximity"
            case CLProximity.Immediate:
                self.distanceLabel.text = "Immediate"
            case CLProximity.Near:
                self.distanceLabel.text = "Near"
            case CLProximity.Far:
                self.distanceLabel.text = "Far"
            }

        } else {
            self.beaconFoundLabel.text = "None nearby"
        }
        
    }
}

