# Build stage
FROM golang:1.26-alpine AS builder

WORKDIR /app

# Copy go.mod and download dependencies
# Note: go.sum is not copied as it does not exist in the project root yet.
COPY go.mod ./
RUN go mod download

# Copy the source code
COPY . .

# Build the application
# CGO_ENABLED=0 creates a statically linked binary
RUN CGO_ENABLED=0 GOOS=linux go build -o server ./cmd/sever

# Run stage
FROM alpine:latest

WORKDIR /app

# Copy the binary from the builder stage
COPY --from=builder /app/server .

# Expose port 8080
EXPOSE 8080

# Command to run the executable
CMD ["./server"]
