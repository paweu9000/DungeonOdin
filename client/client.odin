package client

import "core:fmt"
import "core:net"
import "core:os"
import "core:mem"
import "core:log"
import "core:time"
import "core:strconv"

main :: proc() {
    counter := 1
    socket, sock_err := net.make_bound_udp_socket(net.IP6_Loopback, 90210)
    if sock_err != nil {panic("failed to make UDP socket2")}
    defer net.close(socket)
    for {
        message := fmt.tprintf("Counter: %v", counter)
        bytes: [12]byte
        copy(bytes[:], message)
        bytes_written, send_err := net.send_udp(socket, bytes[:], {net.IP6_Loopback, 8080})
        if send_err != nil {panic("Failed to send packet")}
        counter += 1
        time.sleep(time.Second * 3)
    }
}