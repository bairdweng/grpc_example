package main // 声明 main 包，表明当前是一个可执行程序
import (
	"fmt"

	"com.bwtg.server/grpc"
)

func main() {
	fmt.Println("Hello World!") // 在终端打印 Hello World!
	grpc.Init()
}
