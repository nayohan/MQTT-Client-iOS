//
//  CocoaMQTT.swift
//  MQTT-TEST
//
//  Created by MALAB on 2020/12/25.
//

import Foundation
import CocoaMQTT

class MQTT: NSObject {
    static let shared = MQTT()
    
    var mqtt: CocoaMQTT?
    let defaultHost = "nuda.iptime.org"
    
    private override init() {
        let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: defaultHost, port: 1883)
        
        mqtt!.username = ""
        mqtt!.password = ""
        mqtt!.willMessage = CocoaMQTTMessage(topic: "/will", string: "dieout")
        mqtt!.keepAlive = 60
    }
}
