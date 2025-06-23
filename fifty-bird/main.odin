package main

import "core:fmt"
import rl "vendor:raylib"
import "core:math"

WINDOW_WIDTH  :: 1024
WINDOW_HEIGHT :: 576

VIRTUAL_WIDTH  :: 512
VIRTUAL_HEIGHT :: 288

TITLE :: "FIFTY BIRD?!"

BACKGROUND_SCROLL_SPEED :: 30
GROUND_SCROLL_SPEED :: 60
BACKGROUND_LOOPING_POINT :: 413


main :: proc() {
    fmt.println("Hello, World!")
    // rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, TITLE)
    defer rl.CloseWindow()

    camera := rl.Camera2D { zoom = WINDOW_WIDTH / VIRTUAL_WIDTH }

    background_texture := rl.LoadTexture("resources/background.png")
    defer rl.UnloadTexture(background_texture)
    background_scroll: f32 = 0

    ground_texture := rl.LoadTexture("resources/ground.png")
    defer rl.UnloadTexture(ground_texture)
    ground_scroll: f32 = 0

    dt: f32 = 0
    rl.SetTargetFPS(rl.GetMonitorRefreshRate(rl.GetCurrentMonitor()))
    for !rl.WindowShouldClose() {
        dt = rl.GetFrameTime()

        background_scroll = math.remainder(background_scroll + BACKGROUND_SCROLL_SPEED * dt, BACKGROUND_LOOPING_POINT)
        ground_scroll = math.remainder(ground_scroll + GROUND_SCROLL_SPEED * dt, VIRTUAL_WIDTH)
        
        rl.BeginDrawing()
        rl.BeginMode2D(camera)
        rl.ClearBackground(rl.BLACK)

        rl.DrawTexture(
            background_texture,
            i32(-background_scroll)-BACKGROUND_LOOPING_POINT/2, 0,
            rl.WHITE)
        rl.DrawTexture(
            ground_texture,
            i32(-ground_scroll)-VIRTUAL_WIDTH/2, VIRTUAL_HEIGHT - ground_texture.height,
            rl.WHITE)
        
        rl.DrawFPS(0, 0)
        rl.EndMode2D()
        rl.EndDrawing()
    }

}
