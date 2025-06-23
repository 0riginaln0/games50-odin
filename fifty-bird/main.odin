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
    background_loop_width :: 825
    scrolling_back_view := rl.Rectangle {
        x = 0,
        y = 0,
        width = background_loop_width,
        height = VIRTUAL_HEIGHT
    }
    scb1 := 0
    scb2 := background_loop_width

    ground_texture := rl.LoadTexture("resources/ground.png")
    defer rl.UnloadTexture(ground_texture)
    ground_loop_width :: 512
    scrolling_ground_view := rl.Rectangle {
        x = 0,
        y = 0,
        width = ground_loop_width,
        height = f32(ground_texture.height)
    }
    scg1 := 0
    scg2 := ground_loop_width


    dt: f32 = 0
    rl.SetTargetFPS(rl.GetMonitorRefreshRate(rl.GetCurrentMonitor()))
    for !rl.WindowShouldClose() {
        dt = rl.GetFrameTime()
        scb1 -= 1
        scb2 -= 1
        if scb1 <= -background_loop_width { scb1 = background_loop_width }
        if scb2 <= -background_loop_width { scb2 = background_loop_width }
        scg1 -= 2
        scg2 -= 2
        if scg1 <= -ground_loop_width { scg1 = ground_loop_width }
        if scg2 <= -ground_loop_width { scg2 = ground_loop_width }


        rl.BeginDrawing()
        // rl.BeginMode2D(camera)
        rl.ClearBackground(rl.BLACK)

        rl.DrawTextureRec(
            background_texture,
            scrolling_back_view,
            {f32(scb1), 0},
            rl.WHITE)
        rl.DrawTextureRec(
            background_texture,
            scrolling_back_view,
            {f32(scb2), 0},
            rl.WHITE)


        rl.DrawTextureRec(
            ground_texture,
            scrolling_ground_view,
            {f32(scg1), f32(VIRTUAL_HEIGHT - ground_texture.height)},
            rl.WHITE)
        rl.DrawTextureRec(
            ground_texture,
            scrolling_ground_view,
            {f32(scg2), f32(VIRTUAL_HEIGHT - ground_texture.height*3)},
            rl.WHITE)

        
        // rl.EndMode2D()
        rl.EndDrawing()
    }

}

//ярославский проспект 67, 2 подъезд.