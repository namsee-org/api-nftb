// Package main is the entry point for the helloworlds service.
package main

import (
	"fmt"
	"log"
	"net/http"
	"time"

	helloworld "helloworlds-service/internal/handler"
)

type server struct{}

func (s server) GetHelloWorld(w http.ResponseWriter, _ *http.Request) {
	if _, err := w.Write([]byte("Hello, World!")); err != nil {
		fmt.Printf("failed to write response: %v\n", err)
	}
}

func main() {
	h := helloworld.Handler(server{})

	srv := &http.Server{
		Addr:         ":8080",
		Handler:      h,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  30 * time.Second,
	}

	log.Fatal(srv.ListenAndServe())
}
