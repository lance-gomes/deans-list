//
//  ViewController.swift
//  Lance-Test
//
//  Created by Lance Gomes on 2019-09-11.
//  Copyright © 2019 Lance Gomes. All rights reserved.
//

import UIKit
import CoreBluetooth

let arduinoBluetoothService = "7E42664B-96E7-421D-1007-0B3C12C22E29"

class ViewController : UIViewController {
    var centralManager: CBCentralManager!
    var arduinoPeripheral: CBPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    @IBAction func sendByte(_ sender: UIButton) {
        print("received")
    }
    

}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .unknown:
                print("central.state is .unknown")
            case .resetting:
                print("central.state is .resetting")
            case .unsupported:
                print("central.state is .unsupported")
            case .unauthorized:
                print("central.state is .unauthorized")
            case .poweredOff:
                print("central.state is .poweredoff")
            case .poweredOn:
                print("central.state is .poweredon")
                centralManager.scanForPeripherals(withServices: nil)
            @unknown default:
                print("central.state is .unknown")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print(peripheral)
        
    }
}


