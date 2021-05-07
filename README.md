# GRPC

##### 1. 安装protobuf

1. Golang

   ```shell
   go get -u google.golang.org/grpc
   ```

2. protoc-gen-go插件
```shell
go get -u github.com/golang/protobuf/protoc-gen-go
```

3. 加入到环境变量

   1. protoc-gen-go 已经加入到gopath中了。可以输入 go env查看的GOPATH。

   2. 进入$GOPATH/bin中可以看到 protoc-gen-go

   3. 加入环境变量

   ```shell
   vim ~/.zshrc
   export PATH=/Users/bairdweng/go/bin:$PATH
   source ~/.zshrc
   ```


##### 2. 生成proto

```go
syntax = "proto3"; // 版本声明，使用Protocol Buffers v3版本
// 目录，pb是包名
option go_package = "./; pb";

// 定义一个打招呼服务
service Greeter {
    // SayHello 方法
    rpc SayHello (HelloRequest) returns (HelloReply) {}
}

// 包含人名的一个请求消息
message HelloRequest {
    string name = 1;
}

// 包含问候语的响应消息
message HelloReply {
    string message = 1;
}
```

* 执行命令行

  ```shell
  protoc -I  pb/  hello.proto --go_out=plugins=grpc:pb
  ```

* 一定要注意pb是目录，protoc只有在目录下才能生效。

##### 3. swift的支持

1. 安装

   ```shell
   brew install swift-protobuf
   protoc --swift_out=. my.proto
   # 生成hello.grpc.proto，未安装插件将报错，解决方法请参考3.
   pb protoc --swift_out=. --grpc-swift_out=Client=true,Server=false:. hello.proto
   ```

2. podfile

   ```shell
   platform : ios, '10.0'
   source 'https://github.com/CocoaPods/Specs.git'
   target 'GRPC_iOS' do
   	use_frameworks !
   	pod 'gRPC-Swift'
   end
   ```

3. 生成hello.grpc.proto的坑

   1. 由于采用brew install swift-protobuf只安装了protoc-gen-swift

      ```shell
      # 在homebrew中只存在 protoc-gen-swift
      /opt/homebrew/bin
      ```

   2. 下载swift支持的grpc插件 [protoc-gen-grpc-swift](https://github.com/grpc/grpc-swift/releases/tag/1.0.0)

   3. 将可执行文件放置brew的bin目录下 /opt/homebrew/bin即可解决

##### 4. go创建grpc服务器

```go
	// 监听本地的8972端口
	lis, err := net.Listen("tcp", ":8972")
	if err != nil {
		fmt.Printf("failed to listen: %v", err)
		return
	}
	// 创建gRPC服务器
	s := grpc.NewServer()
	// 在gRPC服务端注册服务
	pb.RegisterGreeterServer(s, &server{})
	//在给定的gRPC服务器上注册服务器反射服务
	reflection.Register(s)
	// Serve方法在lis上接受传入连接，为每个连接创建一个ServerTransport和server的goroutine。
	// 该goroutine读取gRPC请求，然后调用已注册的处理程序来响应它们。
	err = s.Serve(lis)
	if err != nil {
		fmt.Printf("failed to serve: %v", err)
		return
	}
```

##### 5. iOS客户端远程调用

```swift
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
```
* 发送消息
```swift
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
```


