package main

import rl "vendor:raylib"
import "core:math/rand"
import "core:math"

/* BALL */
BALL_RADIUS :: 7
Horizontal_Direction :: enum { Left = -1, Right = 1 }
Ball :: struct {
    dx, dy: f32,
    collider: rl.Rectangle,
    direction: Horizontal_Direction
}
ball := Ball {
    collider = rl.Rectangle {
        x = CANVAS_SIZE / 2 - BALL_RADIUS,
        y = CANVAS_SIZE / 2 - BALL_RADIUS,
        width = BALL_RADIUS * 2,
        height = BALL_RADIUS * 2,
    }
}

ball_draw :: proc(ball_collider: rl.Rectangle) {
    rl.DrawRectangleRounded(ball_collider, 1, 10, rl.MAROON)
}

ball_reset :: proc(ball: ^Ball) {
    ball.collider.x = CANVAS_SIZE / 2 - BALL_RADIUS
    ball.collider.y = CANVAS_SIZE / 2 - BALL_RADIUS
    ball.dx = 0
    ball.dy = 0
}

ball_activate :: proc(ball: ^Ball) {
    ball_speed := rand.float32_range(70, 100)
    ball.direction = rand.choice_enum(Horizontal_Direction);
    ball.dx = ball_speed * f32(ball.direction)
    ball.dy = rand.float32_range(-30, 30)
}

print_and_return :: proc(x: $T) -> T {
    fmt.println(x)
    return x
}

bounce_off_the_paddle :: proc(ball: ^Ball, paddle: Paddle) {
    switch ball.direction {
    case .Left:
        ball.direction = .Right
    case .Right:
        ball.direction = .Left
    }
    ball.dx *= -1
    speed_increase_factor: f32 = 0.05
    max_ball_speed :: 400.0

    new_speed := math.lerp(abs(ball.dx), max_ball_speed, speed_increase_factor)
    ball.dx = f32(ball.direction) * new_speed

    paddle_center := paddle.collider.y + (paddle.collider.height / 2)
    ball_center := ball.collider.y + (ball.collider.height / 2)
    relative_intersect := (ball_center - paddle_center) / (paddle.collider.height / 2)
    max_dy_adjustment :: 30
    dy_adjustment := relative_intersect * max_dy_adjustment

    switch paddle.direction{
    case .Up:
        dy_adjustment += 15
    case .Down:
        dy_adjustment -= 15
    case .Stationary:
    }

    ball.dy += dy_adjustment
}

ball_update :: proc(ball: ^Ball, left_paddle, right_paddle: Paddle, dt: f32) {
    switch ball.direction {
    case .Left:
        if rl.CheckCollisionRecs(ball.collider, left_paddle.collider) {
            bounce_off_the_paddle(ball, left_paddle)
            rl.PlaySound(paddle_hit_sound)
        }
    case .Right:
        if rl.CheckCollisionRecs(ball.collider, right_paddle.collider) {
            bounce_off_the_paddle(ball, right_paddle)
            rl.PlaySound(paddle_hit_sound)
        }
    }
    // Bounce off the roof and floor
    if ball.collider.y <= 0 || (ball.collider.y + BALL_RADIUS * 2) >= CANVAS_SIZE {
        ball.dy *= -1
        rl.PlaySound(wall_hit_sound)
    }
    ball.collider.x += ball.dx * dt
    ball.collider.y += ball.dy * dt
}