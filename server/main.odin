package server

import "core:net"
import "core:fmt"
import "core:log"

main :: proc() {
    server_port := 8080
    sock2, err2 := net.make_bound_udp_socket(net.IP6_Loopback, server_port)
    if err2 != nil {panic("failed to make UDP socket2")}
    defer net.close(sock2)
    net.bind(sock2, {net.IP6_Loopback, server_port})

    for {
        recv_message: [1024]u8
        bytes_read, endpoint, recv_err := net.recv_udp(sock2, recv_message[:])
        if recv_err != nil {panic("Failed to receive packet")}
        if bytes_read > 0 {
            fmt.println("Received message from: ", endpoint)
            fmt.println(string(recv_message[:bytes_read]))
        }
        if string(recv_message[:bytes_read]) == "close" {
            break
        }
    }
}