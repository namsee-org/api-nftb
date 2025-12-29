package main

import (
	"net/http"

	helloworld "api-nftb/internal/hello-world"
)

func main() {
	http.HandleFunc("/data", helloworld.Handler)

	http.ListenAndServe(":8080", nil)
}
