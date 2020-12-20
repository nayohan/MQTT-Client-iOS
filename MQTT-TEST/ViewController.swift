//
//  ViewController.swift
//  MQTT-TEST
//
//  Created by MALAB on 2020/12/20.
//

import UIKit
import CocoaMQTT

class ViewController: UIViewController{

    let defaultHost = "nuda.iptime.org"
    var mqtt: CocoaMQTT?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mqttInit()
    }
    func mqttInit() {
        let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: defaultHost, port: 1883)
        mqtt!.username = ""
        mqtt!.password = ""
        mqtt!.willMessage = CocoaMQTTMessage(topic: "/will", string: "dieout")
        mqtt!.keepAlive = 60
        mqtt!.delegate = self
    }
    
    @IBOutlet var labelReceived: UILabel!
    @IBOutlet var labelLog: UILabel!
    @IBOutlet var TextFieldSend: UITextField!
    
    @IBAction func sendButton(_ sender: Any) {
        print("mqtt is now sending")
        mqtt!.publish("publish-ios", withString: TextFieldSend.text!, qos: .qos2)
    }
    @IBAction func connectButton(_ sender: Any) {
        print("mqtt is connecting...")
        _ = mqtt!.connect()
    }
    @IBAction func disconnectButton(_ sender: Any) {
        print("mqtt is disconnecting...")
        mqtt!.disconnect()
    }
}

extension ViewController: CocoaMQTTDelegate {
    
    // Optional ssl CocoaMQTTDelegate
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        TRACE("trust: \(trust)")
        completionHandler(true)
    }

    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        TRACE("ack: \(ack)")
        mqtt.subscribe("subscribe-ios")
        if ack == .accept {
            print("ack accepted")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        TRACE("new state: \(state)")
        labelLog.text = "new state: \(state)"
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        TRACE("message: \(message.string!.description), id: \(id)")
        labelLog.text = ("message: \(message.string!.description), id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        TRACE("id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        TRACE("message: \(message.string!.description), id: \(id)")
        mqtt.didReceiveMessage = { mqtt, message, id in
            print("Message received in topic \(message.topic) with payload \(message.string!)")
        }
        labelReceived.text = message.string!
        labelLog.text = "Message received in topic \(message.topic) with payload \(message.string!), id: \(id)"
        //NotificationCenter.default.post(name: name, object: self, userInfo: ["message": message.string!, "topic": message.topic])
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        TRACE("subscribed: \(success), failed: \(failed)")
        labelLog.text = "subscribed: \(success), failed: \(failed)"
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        TRACE("topic: \(topics)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        TRACE()
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        TRACE()
    }

    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        TRACE("\(String(describing: err))")
    }
}

extension ViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return viewController != tabBarController.selectedViewController
    }
}

extension ViewController {
    func TRACE(_ message: String = "", fun: String = #function) {
        let names = fun.components(separatedBy: ":")
        var prettyName: String
        if names.count == 2 {
            prettyName = names[0]
        } else {
            prettyName = names[1]
        }
        
        if fun == "mqttDidDisconnect(_:withError:)" {
            prettyName = "didDisconnect"
        }

        print("[TRACE] [\(prettyName)]: \(message)")
    }
}
