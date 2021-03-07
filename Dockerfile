
# Stage 1 - build the app

# Start from golang base image
FROM golang:alpine as builder


# Set necessary environmet variables
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux

LABEL tag="Rent-it App"

# Intall Git to fetch various app's dependencies
RUN apk update && apk add --no-cache git

WORKDIR /app

COPY go.mod go.sum ./

# Download all dependencies
RUN go mod download

# Copy the project's source to the working dir:
COPY . .

# Build the Golang app (app.go)
RUN go build -a -installsuffix cgo -o rentapp .

# Stage 2 - build the docker image to use
FROM alpine:latest
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the binary bankapp + the env
COPY --from=builder /app/rentapp .
COPY --from=builder /app/.env .

# Expose the port 8080
EXPOSE 8080

# Run/start the app
CMD ["./rentapp"]
