package main

import "core:fmt"
import rl "vendor:raylib"

WINDOW_WIDTH  :: 1024
WINDOW_HEIGHT :: 576

VIRTUAL_WIDTH  :: 512
VIRTUAL_HEIGHT :: 288

TITLE :: "FIFTY BIRD?!"



main :: proc() {
    fmt.println("Hello, World!")
    // rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, TITLE)
    defer rl.CloseWindow()

    camera := rl.Camera2D { zoom = WINDOW_WIDTH / VIRTUAL_WIDTH }

    background_texture := rl.LoadTexture("resources/background.png")
    defer rl.UnloadTexture(background_texture)
    scrolling_back := 0.0
    
    ground_texture := rl.LoadTexture("resources/ground.png")
    defer rl.UnloadTexture(ground_texture)
    scrolling_ground := 0.0

    dt: f32 = 0
    rl.SetTargetFPS(rl.GetMonitorRefreshRate(rl.GetCurrentMonitor()))
    for !rl.WindowShouldClose() {
        dt = rl.GetFrameTime()
        scrolling_back -= 0.1
        scrolling_ground -= 0.4
        if i32(scrolling_back) <= -background_texture.width do scrolling_back = 0
        if i32(scrolling_ground) <= -ground_texture.width do scrolling_ground = 0

        rl.BeginDrawing()
        // rl.BeginMode2D(camera)

        rl.DrawTextureV(background_texture, {f32(scrolling_back), 0}, rl.WHITE)
        // rl.DrawTextureV(background_texture, {f32(background_texture.width) * 2 + f32(scrolling_back), 0}, rl.WHITE)

        rl.DrawTextureV(ground_texture,
            { f32(scrolling_ground), f32(VIRTUAL_HEIGHT - ground_texture.height) }, rl.WHITE)
        rl.DrawTextureV(ground_texture,
            { f32(ground_texture.width) * 2 + f32(scrolling_ground), f32(VIRTUAL_HEIGHT - ground_texture.height) }, rl.WHITE)
        
        // rl.EndMode2D()
        rl.EndDrawing()
    }

}

//ярославский проспект 67, 2 подъезд.