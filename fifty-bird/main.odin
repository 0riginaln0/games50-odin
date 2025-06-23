package main

import "core:fmt"
import rl "vendor:raylib"
import "core:math"

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
    scroll_back_counter1 :f32= 0
    scroll_back_counter2 :f32= background_loop_width

    ground_texture := rl.LoadTexture("resources/ground.png")
    defer rl.UnloadTexture(ground_texture)
    ground_loop_width :: 512
    scrolling_ground_view := rl.Rectangle {
        x = 0,
        y = 0,
        width = ground_loop_width,
        height = f32(ground_texture.height)
    }
    scroll_ground_counter1 :f32= 0
    scroll_ground_counter2 :f32= ground_loop_width

    dt: f32 = 0
    rl.SetTargetFPS(rl.GetMonitorRefreshRate(rl.GetCurrentMonitor()))
    for !rl.WindowShouldClose() {
        dt = rl.GetFrameTime()

        scroll_back_counter1 -= 0.2*300*dt
        scroll_back_counter2 -= 0.2*300*dt
        if scroll_back_counter1 <= -background_loop_width {
            scroll_back_counter1 = background_loop_width + scroll_back_counter2
        }
        if scroll_back_counter2 <= -background_loop_width {
            scroll_back_counter2 = background_loop_width + scroll_back_counter1
        }

        scroll_ground_counter1 -= 0.5*300*dt
        scroll_ground_counter2 -= 0.5*300*dt
        if scroll_ground_counter1 <= -ground_loop_width {
            scroll_ground_counter1 = ground_loop_width + scroll_ground_counter2
        }
        if scroll_ground_counter2 <= -ground_loop_width {
            scroll_ground_counter2 = ground_loop_width + scroll_ground_counter1
        }


        rl.BeginDrawing()
        rl.BeginMode2D(camera)
        rl.ClearBackground(rl.BLACK)

        rl.DrawTextureRec(
            background_texture,
            scrolling_back_view,
            { scroll_back_counter1, 0 },
            rl.WHITE)
        rl.DrawTextureRec(
            background_texture,
            scrolling_back_view,
            { scroll_back_counter2, 0 },
            rl.WHITE)

        rl.DrawTextureRec(
            ground_texture,
            scrolling_ground_view,
            { scroll_ground_counter1, f32(VIRTUAL_HEIGHT - ground_texture.height) },
            rl.WHITE)
        rl.DrawTextureRec(
            ground_texture,
            scrolling_ground_view,
            { scroll_ground_counter2, f32(VIRTUAL_HEIGHT - ground_texture.height) },
            rl.WHITE)

        
        rl.DrawFPS(0, 0)
        rl.EndMode2D()
        rl.EndDrawing()
    }

}

//ярославский проспект 67, 2 подъезд.