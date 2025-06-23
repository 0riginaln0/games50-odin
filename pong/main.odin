// TODO: ENet multiplayer (One of two players creates locally dedicated server.)
package main

import "core:fmt"
import rl "vendor:raylib"
import "core:os"
import "core:math/rand"
import "core:math"

/* BORING CONSTANTS */
WINDOW_SIZE :: 700 // 700 910
WINDOW_WIDTH :: WINDOW_SIZE
WINDOW_HEIGHT :: WINDOW_SIZE
CANVAS_SIZE :: 350 // 350 455
TITLE :: "PONG?!"
TARGET_FPS :: 60
FONT_SIZE :: 10

/* GAME STATE */
WINNING_SCORE :: 10
Game_State :: enum { Start, Game, Win }
game_state: Game_State = .Start

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

        left_up := rl.IsKeyDown(.W)
        left_down := rl.IsKeyDown(.S)
        right_up := rl.IsKeyDown(.UP)
        right_down := rl.IsKeyDown(.DOWN)
        enter_pressed := rl.IsKeyPressed(.ENTER)

        switch game_state {
        case .Start:
            if enter_pressed {
                ball_activate(&ball)
                game_state = .Game
                rl.BeginDrawing()
                rl.EndDrawing()
                continue
            }

            rl.ClearBackground(rl.BLACK)
            rl.BeginDrawing()
            rl.BeginMode2D(camera)

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
        case .Game:
            paddle_update(&left_paddle, left_up, left_down, dt)
            paddle_update(&right_paddle, right_up, right_down, dt)
            ball_update(&ball, left_paddle, right_paddle, dt)

            if ball.collider.x + BALL_RADIUS < 0 {
                score_increase_right(&score)
                ball_reset(&ball)
                paddle_reset(&left_paddle)
                paddle_reset(&right_paddle)
                if score.y == WINNING_SCORE {
                    game_state = .Win
                    rl.BeginDrawing()
                    rl.EndDrawing()
                    continue
                }
                ball_activate(&ball)
            }
            if ball.collider.x + BALL_RADIUS > CANVAS_SIZE {
                score_increase_left(&score)
                ball_reset(&ball)
                paddle_reset(&left_paddle)
                paddle_reset(&right_paddle)
                if score.x == WINNING_SCORE {
                    game_state = .Win
                    rl.BeginDrawing()
                    rl.EndDrawing()
                    continue
                }
                ball_activate(&ball)
            }

            rl.ClearBackground(rl.BLACK)
            rl.BeginDrawing()
            rl.BeginMode2D(camera)

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
        case .Win:
            if enter_pressed {
                paddle_reset(&left_paddle)
                paddle_reset(&right_paddle)
                ball_reset(&ball)
                score_reset(&score)
                game_state = .Start
                rl.BeginDrawing()
                rl.EndDrawing()
                continue
            }

            rl.ClearBackground(rl.BLACK)
            rl.BeginDrawing()
            rl.BeginMode2D(camera)

            rl.DrawText(text = TITLE,
                        posX = (CANVAS_SIZE / 2) - (title_text_width / 2),
                        posY = (FONT_SIZE / 2),
                        fontSize = FONT_SIZE,
                        color = rl.WHITE)
            winner_message := cstring("Left player wins!") if score.x == 10 else cstring("Right player wins!") 
            rl.DrawText(text = winner_message,
                        posX = (CANVAS_SIZE / 2) - (rl.MeasureText(winner_message, FONT_SIZE * 2) / 2),
                        posY = (CANVAS_SIZE / 4),
                        fontSize = FONT_SIZE * 2,
                        color = rl.WHITE)
            enter_message := cstring("Press ENTER to start again")
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
        }
    }
}
