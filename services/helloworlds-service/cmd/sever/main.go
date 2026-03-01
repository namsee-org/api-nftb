package main

import (
	"net/http"

	helloworld "helloworlds-service/internal/handler"
)

type server struct{}

func (s server) GetHelloWorld(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Hello, World!"))
}

func main() {
	h := helloworld.Handler(server{})

	http.ListenAndServe(":8080", h)
}
