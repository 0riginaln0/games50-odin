package main

import "core:fmt"
import rl "vendor:raylib"
import "core:os"
import "core:math/rand"
import "core:math"

/* BORING CONSTANTS */
WINDOW_SIZE :: 700
WINDOW_WIDTH :: WINDOW_SIZE
WINDOW_HEIGHT :: WINDOW_SIZE
CANVAS_SIZE :: 350
TITLE :: "PONG?!"
TARGET_FPS :: 60
FONT_SIZE :: 10

/* GAME STATE */
// TODO: Start,
//       Game,
//       Left scored, Right scored,
//       Left win,    Right win,
//       
// ENet multiplayer (One of two players creates locally dedicated server.)
game_state := "start" // start, game

main :: proc() {
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, TITLE)
    defer rl.CloseWindow()

    camera := rl.Camera2D { zoom = WINDOW_SIZE / CANVAS_SIZE }
    title_text_width := rl.MeasureText(TITLE, FONT_SIZE)

    dt: f32 = 0
    rl.SetTargetFPS(rl.GetMonitorRefreshRate(rl.GetCurrentMonitor()))
    for !rl.WindowShouldClose() {
        dt = rl.GetFrameTime()

        // Process input
        left1  := rl.IsKeyPressed(.A)
        right1 := rl.IsKeyPressed(.D)
        left_up := rl.IsKeyDown(.W)
        left_down := rl.IsKeyDown(.S)
        right_up := rl.IsKeyDown(.UP)
        right_down := rl.IsKeyDown(.DOWN)
        enter_pressed := rl.IsKeyPressed(.ENTER)

        // Update game
        if game_state == "start" {
            if enter_pressed {
                ball_activate(&ball)
                game_state = "game"
                rl.BeginDrawing() // Draw an empty frame 
                rl.EndDrawing()   // because we need Raylib to update frame counter
                continue
            }
            // Render
            rl.ClearBackground(rl.BLACK)
            rl.BeginDrawing()
            rl.BeginMode2D(camera)
            rl.DrawFPS(0, 0)
            rl.DrawText(text = TITLE,
                        posX = (CANVAS_SIZE / 2) - (title_text_width / 2),
                        posY = (FONT_SIZE / 2),
                        fontSize = FONT_SIZE,
                        color = rl.WHITE)
            enter_message := cstring("Press ENTER to start")
            rl.DrawText(text = enter_message,
                        posX = (CANVAS_SIZE / 2) - (rl.MeasureText(enter_message, FONT_SIZE) / 2),
                        posY = (CANVAS_SIZE / 2) - BALL_RADIUS * 2 - FONT_SIZE,
                        fontSize = FONT_SIZE,
                        color = rl.WHITE)
            paddle_draw(left_paddle)
            paddle_draw(right_paddle)
            ball_draw(ball.collider)
            score_draw(score)
            rl.EndMode2D()
            rl.EndDrawing()
        } else if game_state == "game" {
            if enter_pressed {
                paddle_reset(&left_paddle)
                paddle_reset(&right_paddle)
                ball_reset(&ball)
                score_reset(&score)
                game_state = "start"
                rl.BeginDrawing() // Draw an empty frame 
                rl.EndDrawing()   // because we need Raylib to update frame counter
                continue
            }

            paddle_update(&left_paddle, left_up, left_down, dt)
            paddle_update(&right_paddle, right_up, right_down, dt)
            ball_update(&ball, left_paddle, right_paddle, dt)

            if ball.collider.x < 0 {
                score_increase_right(&score)
                ball_reset(&ball)
                paddle_reset(&left_paddle)
                paddle_reset(&right_paddle)
                ball_activate(&ball)
            }
            if ball.collider.x > CANVAS_SIZE {
                score_increase_left(&score)
                ball_reset(&ball)
                paddle_reset(&left_paddle)
                paddle_reset(&right_paddle)
                ball_activate(&ball)
            }

            // Render
            rl.ClearBackground(rl.BLACK)
            rl.BeginDrawing()
            rl.BeginMode2D(camera)

            rl.DrawFPS(0, 0)
            rl.DrawText(text = TITLE,
                        posX = (CANVAS_SIZE / 2) - (title_text_width / 2),
                        posY = (FONT_SIZE / 2),
                        fontSize = FONT_SIZE,
                        color = rl.WHITE)

            paddle_draw(left_paddle)
            paddle_draw(right_paddle)
            ball_draw(ball.collider)
            score_draw(score)

            rl.EndMode2D()
            rl.EndDrawing()
        }
    }
}
