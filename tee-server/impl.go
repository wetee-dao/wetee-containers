package main

import (
	"fmt"
	"net/http"
)

type CvmServer struct {
}

func init() {
	TEEServerImpl = CvmServer{}
}

func (CvmServer) start(req *CrossRequest) CrossResponse {

	go func() {
		http.HandleFunc("/",
			func(w http.ResponseWriter, r *http.Request) {
				// 设置响应头类型为JSON
				w.Header().Set("Content-Type", "application/json")

				// 写入响应
				w.Write([]byte("test"))
			},
		)
		fmt.Println("SERVE", "http://0.0.0.0:8994")

		err := http.ListenAndServe(":8994", nil)
		fmt.Println(err)
	}()

	return CrossResponse{pass: true}
}
