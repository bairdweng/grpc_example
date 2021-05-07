//
//  ViewController.swift
//  GRPC_iOS
//
//  Created by bairdweng on 2021/5/6.
//

import GRPC
import NIO
import NIOTransportServices
import UIKit
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func clickOnTheSendMessage(_ sender: Any) {
        sendMessage()
    }
}

extension ViewController {
    func sendMessage() {
        let manage = NetworkManage.manage
        let client = manage.client
        let req = HelloRequest.with { $0.name = "bairdweng" }
        let call = client!.sayHello(req)
        let callResultEventLoop = call.status.and(call.trailingMetadata).and(call.response)
        callResultEventLoop.whenSuccess { _ in
            print("Got a response.")
        }
        callResultEventLoop.whenFailure { error in
            print("Got an error: \(error)")
        }
    }
}
