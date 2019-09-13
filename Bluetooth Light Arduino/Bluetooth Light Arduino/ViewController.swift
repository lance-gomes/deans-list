//
//  ViewController.swift
//  Bluetooth Light Arduino
//
//  Created by Christopher Louie on 2019-09-12.
//  Copyright © 2019 Christopher Louie. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    @IBOutlet weak var bluetoothStatusLabel: UILabel!
    
    var centralManager: CBCentralManager!
    var arduinoPeripheral: CBPeripheral?
    var rxCharacteristic: CBCharacteristic?
    var txCharacteristic: CBCharacteristic?
    var characteristicASCIIValue = NSString()
    
    private let hm10ServiceCBUUID = CBUUID(string: "FFE0")
    private let hm10ServiceCBUUIDRx = CBUUID(string: "FFE1")
    private let hm10ServiceCBUUIDTx = CBUUID(string: "FFE1")

    override func viewDidLoad() {
        super.viewDidLoad()
        bluetoothStatusLabel.text = "Searching for bluetooth device..."
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
//    func disconnectFromDevice() {
//        if arduinoPeripheral != nil {
//            centralManager.cancelPeripheralConnection(arduinoPeripheral!)
//        }
//    }
    
    func writeValue(data: String) {
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        if let peripheral = arduinoPeripheral {
            if let txCharacteristic = txCharacteristic {
                peripheral.writeValue(valueString!, for: txCharacteristic, type: .withResponse)
            }
        }
    }
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth enabled")
            bluetoothStatusLabel.text = "Searching for bluetooth device..."
            centralManager.scanForPeripherals(withServices: [hm10ServiceCBUUID], options: nil)
        }
        else {
            print("Not connected to bluetooth")
            bluetoothStatusLabel.text = "Turn on bluetooth to connect to devices."
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        
        // Save the bluetooth peripheral as the arduinoPeripheral object
        arduinoPeripheral = peripheral
        centralManager.connect(arduinoPeripheral!)
        bluetoothStatusLabel.text = "Connecting to \(peripheral.name ?? "HM-10") device."
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected \(peripheral)!")
        bluetoothStatusLabel.text = "Connected to \(peripheral.name ?? "HM-10") device."
        
        // Stop scanning once connected
        centralManager.stopScan()
        print("Scan stopped")
        
        arduinoPeripheral!.delegate = self
        arduinoPeripheral!.discoverServices(nil)
    }
}

extension ViewController: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print("Error discovering peripheral's services: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
        print("Discovered services: \(services)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("Error discovering peripheral's characteristics: \(error!.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        print("Found \(characteristics.count) characteristics!")
        
        for characteristic in characteristics {
            
            if characteristic.uuid.isEqual(hm10ServiceCBUUIDRx) {
                rxCharacteristic = characteristic
                
                peripheral.setNotifyValue(true, for: rxCharacteristic!)
                peripheral.readValue(for: characteristic)
                print("Rx characteristic: \(characteristic.uuid)")
            }
            
            if characteristic.uuid.isEqual(hm10ServiceCBUUIDTx) {
                txCharacteristic = characteristic
                print("Tx characteristic: \(characteristic.uuid)")
            }
            
            print("Characteristic: \(characteristic)")
            peripheral.discoverDescriptors(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        peripheral.discoverDescriptors(for: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic == rxCharacteristic {
            if let ASCIIstring = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue) {
                characteristicASCIIValue = ASCIIstring
                print("Value recieved: \(characteristicASCIIValue as String)")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error discovering services: \(String(describing: error))")
            return
        }
        print("Message was sent to Arduino!")
    }
    
}

