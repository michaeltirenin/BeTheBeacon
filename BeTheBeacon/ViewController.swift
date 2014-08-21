//
//  ViewController.swift
//  BeTheBeacon
//
//  Created by Michael Tirenin on 8/21/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

class ViewController: UIViewController, CBPeripheralManagerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var startButtonOutlet: UIButton!
    
    let myUUID = NSUUID(UUIDString: "15D88457-4163-40D8-A795-F8A65CD8628B")
    let myIdentifier = "com.michaeltirenin.beacons.codefellows"
    
    var beaconData = NSDictionary()
    var beaconRegion = CLBeaconRegion()
    var peripheralManager = CBPeripheralManager()
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.beaconRegion = CLBeaconRegion(proximityUUID: myUUID, identifier: myIdentifier)
        self.beaconData = beaconRegion.peripheralDataWithMeasuredPower(nil)
        
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.startButtonOutlet.titleLabel.text = "Start"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            self.statusLabel.text = "Stoped"
            println("stopped--")

        }
    }
// check on this:
    func peripheralManagerDidUpdateState(peripheral : CBPeripheralManager) {
        
        if peripheral.state == CBPeripheralManagerState.PoweredOn {
            // bluetooth on
            println("broadcasting")
            self.view.backgroundColor = UIColor.greenColor()
            self.statusLabel.text = "Broadcasting ..."
            self.startButtonOutlet.setTitle("Stop", forState: UIControlState.Normal)
            self.peripheralManager.startAdvertising(beaconData)
            
        } else if peripheral.state == CBPeripheralManagerState.PoweredOff {
            // bluetooth is off - stop broadcasting
            println("stopped")
            self.view.backgroundColor = UIColor.redColor()
            self.statusLabel.text = "Stoped"
            self.startButtonOutlet.setTitle("Start", forState: UIControlState.Normal)
            self.peripheralManager.stopAdvertising()
            
        } else if peripheral.state ==  CBPeripheralManagerState.Unsupported {
            // not supported
            println("unsupported")
        }
    }
}

