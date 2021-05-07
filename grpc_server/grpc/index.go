package grpc

import (
	"context"
	"errors"
	"fmt"
	"net"

	"com.bwtg.server/pb"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

type server struct{}

func (s *server) SayHello(ctx context.Context, in *pb.HelloRequest) (*pb.HelloReply, error) {
	println("响应啦" + in.Name)
	// time.Sleep(5 * time.Second)
	return nil, errors.New("异常返回测试")
	// return &pb.HelloReply{Message: "Hello " + in.Name}, nil
}

func Init() {
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
}
