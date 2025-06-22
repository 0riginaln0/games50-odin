package main

import rl "vendor:raylib"

/* PADDLES */
PADDLE_WIDTH  :: 10
PADDLE_HEIGHT :: 70 // 100
PADDLE_SPEED  :: 100
SIDE_PAD :: PADDLE_WIDTH

Vertical_Direction :: enum { Up, Down, Stationary }
Paddle :: struct {
    collider: rl.Rectangle,
    direction: Vertical_Direction,
}
left_paddle := Paddle {
    collider = rl.Rectangle {
        x = SIDE_PAD,
        y = CANVAS_SIZE / 2 - PADDLE_HEIGHT / 2,
        width = PADDLE_WIDTH,
        height = PADDLE_HEIGHT,
    }
}
right_paddle := Paddle {
    collider = rl.Rectangle {
        x = CANVAS_SIZE - SIDE_PAD - PADDLE_WIDTH,
        y = CANVAS_SIZE / 2 - PADDLE_HEIGHT / 2,
        width = PADDLE_WIDTH,
        height = PADDLE_HEIGHT,
    }
}

paddle_draw :: proc(paddle: Paddle) {
    rl.DrawRectangleRounded(paddle.collider,  0.5, 4, rl.RAYWHITE)
}

paddle_reset :: proc(paddle: ^Paddle) {
    paddle.collider.y = CANVAS_SIZE / 2 - PADDLE_HEIGHT / 2
}

paddle_update :: proc(paddle: ^Paddle, up, down: bool, dt: f32) {
    if up && paddle.collider.y >= 0 {
        paddle.collider.y -= PADDLE_SPEED * dt
        paddle.direction = .Up
    } else if down && paddle.collider.y + PADDLE_HEIGHT <= CANVAS_SIZE {
        paddle.collider.y += PADDLE_SPEED * dt
        paddle.direction = .Down
    } else {
        paddle.direction = .Stationary
    }
}