package helloworld

import (
	"fmt"
	"net/http"
)

// Handler handles hello world requests
func Handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello world\n")
}
