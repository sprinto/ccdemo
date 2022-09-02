package main

import (
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

func main() {
	// Create a simple HTTP server for Kubernetes health checks
	router := gin.Default()
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"Status": "OK",
		})
	})
	router.Run()

	for {
		fmt.Println("Hello World!")
		time.Sleep(5 * time.Second)
	}
}
