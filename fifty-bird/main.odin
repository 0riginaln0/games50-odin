package main

import "core:fmt"
import rl "vendor:raylib"
import "core:math"
import "core:math/rand"
import "core:slice"

WINDOW_WIDTH :: 1024
WINDOW_HEIGHT :: 576

VIRTUAL_WIDTH :: 512
VIRTUAL_HEIGHT :: 288

TITLE :: "FIFTY BIRD?!"

BACKGROUND_SCROLL_SPEED :: 30
GROUND_SCROLL_SPEED :: 60
BACKGROUND_LOOPING_POINT :: 413


GRAVITY :: 980
JUMP_IMPULSE :: -300 // -350

Bird :: struct {
    collider: rl.Rectangle,
    dy: f32,
    jump_requested: bool,
}
bird := Bird{}
bird_init :: proc(bird: ^Bird, x, y, width, height: f32) {
    bird.collider.x = x
    bird.collider.y = y
    bird.collider.width = width
    bird.collider.height = height
    bird.dy = 0
    bird.jump_requested = false
}
bird_draw :: proc(bird: Bird, texture: rl.Texture2D) {
    rl.DrawTexture(texture, i32(bird.collider.x), i32(bird.collider.y), rl.WHITE)
}
bird_update :: proc(bird: ^Bird, dt: f32) {
    bird.dy += GRAVITY * dt

    if bird.jump_requested {
        bird.dy = JUMP_IMPULSE
        bird.jump_requested = false
    }

    bird.collider.y += bird.dy * dt
    if bird.collider.y + bird.collider.height > VIRTUAL_HEIGHT {
        bird.collider.y = VIRTUAL_HEIGHT - bird.collider.height
    }
}

Pipe :: struct {
    collider: rl.Rectangle,
    texture: rl.Texture2D,
}

pipe_init :: proc(pipe: ^Pipe, texture: rl.Texture2D) {
    pipe.texture = texture
    pipe.collider.x = VIRTUAL_WIDTH
    pipe.collider.y = rand.float32_range(VIRTUAL_HEIGHT / 3, VIRTUAL_HEIGHT * 0.87)
    pipe.collider.width = f32(texture.width)
}
pipe_update :: proc(pipe: ^Pipe, pipe_scroll, dt: f32) {
    pipe.collider.x += pipe_scroll * dt
}
pipe_draw :: proc(pipe: Pipe) {
    rl.DrawTexture(pipe.texture, i32(pipe.collider.x), i32(pipe.collider.y), rl.WHITE)
}

pipes_slots: [7]Pipe
pipes_print :: proc(slice: []Pipe) {
    fmt.print("[")
    for i in slice {fmt.print(i, " ")}
    fmt.println("]")
}

main :: proc() {
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, TITLE)
    defer rl.CloseWindow()

    camera := rl.Camera2D { zoom = f32(WINDOW_WIDTH) / VIRTUAL_WIDTH }

    background_texture := rl.LoadTexture("resources/background.png")
    defer rl.UnloadTexture(background_texture)
    background_scroll: f32 = 0

    ground_texture := rl.LoadTexture("resources/ground.png")
    defer rl.UnloadTexture(ground_texture)
    ground_scroll: f32 = 0

    bird_texture := rl.LoadTexture("resources/bird.png")
    defer rl.UnloadTexture(bird_texture)
    bird_init(
        &bird,
        VIRTUAL_WIDTH / 2 - VIRTUAL_WIDTH / 3,
        VIRTUAL_HEIGHT / 2 - f32(bird_texture.height)/2,
        f32(bird_texture.width),
        f32(bird_texture.height),
    )

    pipe_texture := rl.LoadTexture("resources/pipe.png")
    defer rl.UnloadTexture(pipe_texture)
    pipe_scroll: f32 = -60

    pipes := slice.into_dynamic(pipes_slots[:])

    spawn_timer: f32 = 0

    accumulated_time: f32 = 0
    fixed_dt: f32 = 1.0 / 60.0
    rl.SetTargetFPS(rl.GetMonitorRefreshRate(rl.GetCurrentMonitor()))
    for !rl.WindowShouldClose() {
        frame_time := rl.GetFrameTime()
        spawn_timer += frame_time
        accumulated_time += frame_time

        if rl.IsKeyPressed(.SPACE) || rl.IsMouseButtonPressed(.LEFT) {
            bird.jump_requested = true
        }

        // Fixed timestep physics updates
        for accumulated_time >= fixed_dt {
            bird_update(&bird, fixed_dt)

            background_scroll = math.remainder(background_scroll + BACKGROUND_SCROLL_SPEED * fixed_dt, BACKGROUND_LOOPING_POINT)
            ground_scroll = math.remainder(ground_scroll + GROUND_SCROLL_SPEED * fixed_dt, VIRTUAL_WIDTH)

            for &pipe, i in pipes {
                pipe_update(&pipe, pipe_scroll, fixed_dt)
                if pipe.collider.x + pipe.collider.width < 0 {
                    ordered_remove(&pipes, i)
                }
            }

            accumulated_time -= fixed_dt
        }

        if spawn_timer > 4 {
            pipe := Pipe {}
            pipe_init(&pipe, pipe_texture)
            append(&pipes, pipe)
            spawn_timer = 0
        }

        rl.BeginDrawing()
        rl.BeginMode2D(camera)
        rl.ClearBackground(rl.BLACK)

        rl.DrawTexture(
            background_texture,
            i32(-background_scroll)-BACKGROUND_LOOPING_POINT/2, 0,
            rl.WHITE)
        
        for pipe in pipes {
            pipe_draw(pipe)
        }

        rl.DrawTexture(
            ground_texture,
            i32(-ground_scroll)-VIRTUAL_WIDTH/2, VIRTUAL_HEIGHT - ground_texture.height,
            rl.WHITE)
        
        bird_draw(bird, bird_texture)

        rl.DrawFPS(0, 0)
        rl.EndMode2D()
        rl.EndDrawing()
    }
}