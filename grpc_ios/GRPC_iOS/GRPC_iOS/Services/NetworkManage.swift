//
//  NetworkManage.swift
//  GRPC_iOS
//
//  Created by bairdweng on 2021/5/6.
//

import GRPC
import Logging
import NIO
import NIOTransportServices
import UIKit
class NetworkManage: NSObject, ConnectivityStateDelegate {
    static let manage = NetworkManage()
    var client: GreeterClient!
    override init() {
        super.init()
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let configuration = ClientConnection.Configuration(
            target: .hostAndPort("localhost", 8972),
            eventLoopGroup: group)
        let channel = ClientConnection(configuration: configuration)
        channel.connectivity.delegate = self
        client = GreeterClient(channel: channel)
    }
}

extension NetworkManage {
    func connectivityStateDidChange(from oldState: ConnectivityState, to newState: ConnectivityState) {
        switch newState {
        case .idle:
            print("通道未创建")
        case .connecting:
            print("连接中")
        case .ready:
            print("通道已经准备好")
        case .transientFailure:
            print("通道异常")
        case .shutdown:
            print("通道已经关闭")
        }
    }
}
