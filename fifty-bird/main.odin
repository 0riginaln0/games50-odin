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
JUMP_IMPULSE :: -200 // -250 -300 -350

score := 0

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

PIPE_HEIGHT :: 288
PIPE_WIDTH :: 70
gap_height:f32 = 90

last_y := -PIPE_HEIGHT + rand.float32_range(0, 80) + 20

Pipe_Pair :: struct {
    upper_pipe: rl.Rectangle,
    lower_pipe: rl.Rectangle,
    texture: rl.Texture2D,
    passed: bool
}
pipe_pairs_slots: [7]Pipe_Pair
pipe_pair_new :: proc(y: f32, pipe_texture: rl.Texture2D) -> Pipe_Pair {
    collider1: rl.Rectangle = {x=VIRTUAL_WIDTH, y = y, width = f32(pipe_texture.width), height = f32(pipe_texture.height)}
    collider2: rl.Rectangle = collider1
    collider2.y += PIPE_HEIGHT + gap_height
    pipe_pair := Pipe_Pair {
        upper_pipe = collider1,
        lower_pipe = collider2,
        texture = pipe_texture,
    }
    return pipe_pair
}
pipe_pair_draw :: proc(pipe_pair: Pipe_Pair) {
    pipe_origin := rl.Vector2{f32(pipe_pair.texture.width/2),f32(pipe_pair.texture.height/2)}
    upper_dest := pipe_pair.upper_pipe; upper_dest.x += pipe_origin.x; upper_dest.y += pipe_origin.y;
    rl.DrawTexturePro(
        pipe_pair.texture,
        rl.Rectangle{0,0,f32(pipe_pair.texture.width),f32(pipe_pair.texture.height)},
        upper_dest,
        rl.Vector2{f32(pipe_pair.texture.width/2),f32(pipe_pair.texture.height/2)},
        180,
        rl.WHITE)
    lower_dest := pipe_pair.lower_pipe; lower_dest.x += pipe_origin.x; lower_dest.y += pipe_origin.y;
    rl.DrawTexturePro(
        pipe_pair.texture,
        rl.Rectangle{0,0,f32(pipe_pair.texture.width),f32(pipe_pair.texture.height)},
        lower_dest,
        rl.Vector2{f32(pipe_pair.texture.width/2),f32(pipe_pair.texture.height/2)},
        0,
        rl.WHITE)
    rl.DrawRectangleRec(pipe_pair.upper_pipe, {0, 210, 0, 100})
    rl.DrawRectangleRec(pipe_pair.lower_pipe, {0, 210, 0, 100})
}
pipe_pair_update :: proc(pipe_pair: ^Pipe_Pair, pipe_scroll: f32, fixed_dt: f32) {
    pipe_pair.upper_pipe.x += pipe_scroll * fixed_dt
    pipe_pair.lower_pipe.x = pipe_pair.upper_pipe.x
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

    pipe_pairs := slice.into_dynamic(pipe_pairs_slots[:])

    spawn_timer: f32 = 0

    accumulated_time: f32 = 0
    fixed_dt: f32 = 1.0 / 60.0
    rl.SetTargetFPS(rl.GetMonitorRefreshRate(rl.GetCurrentMonitor()))
    for !rl.WindowShouldClose() {
        frame_time := rl.GetFrameTime()
        accumulated_time += frame_time

        if rl.IsKeyPressed(.SPACE) || rl.IsMouseButtonPressed(.LEFT) {
            bird.jump_requested = true
        }

        // Fixed timestep physics updates
        for accumulated_time >= fixed_dt {
            bird_update(&bird, fixed_dt)

            background_scroll = math.remainder(background_scroll + BACKGROUND_SCROLL_SPEED * fixed_dt, BACKGROUND_LOOPING_POINT)
            ground_scroll = math.remainder(ground_scroll + GROUND_SCROLL_SPEED * fixed_dt, VIRTUAL_WIDTH)

            for &pipe_pair, i in pipe_pairs {
                pipe_pair_update(&pipe_pair, pipe_scroll, fixed_dt)
                if pipe_pair.upper_pipe.x + PIPE_WIDTH < 0 {
                    ordered_remove(&pipe_pairs, i)
                }
                if pipe_pair.passed == false && pipe_pair.upper_pipe.x + pipe_pair.upper_pipe.width / 2 < VIRTUAL_WIDTH / 2 - VIRTUAL_WIDTH / 3 {
                    pipe_pair.passed = true
                    score += 1
                    fmt.println(score)
                }
            }
            spawn_timer += fixed_dt

            accumulated_time -= fixed_dt
        }

        if spawn_timer > 3 {
            dif:f32 = 0.0
            if last_y < -230 {
                dif = rand.float32_range(-20, 80)
            } else if last_y > -130 {
                dif = rand.float32_range(-50, 50)
            } else {
                dif = rand.float32_range(-80, 20)
            }

            y:f32 = clamp(last_y + dif, -250, -150)
            // fmt.println("new y", y)
            last_y = y
            pipe_pair := pipe_pair_new(y, pipe_texture)
            append(&pipe_pairs, pipe_pair)
            spawn_timer = 0
            gap_height -= 0.5
        }

        rl.BeginDrawing()
        rl.BeginMode2D(camera)
        rl.ClearBackground(rl.BLACK)

        rl.DrawTexture(
            background_texture,
            i32(-background_scroll)-BACKGROUND_LOOPING_POINT/2, 0,
            rl.WHITE)

        
        bird_draw(bird, bird_texture)

        for pipe_pair in pipe_pairs {
            pipe_pair_draw(pipe_pair)
        }


        rl.DrawTexture(
            ground_texture,
            i32(-ground_scroll)-VIRTUAL_WIDTH/2, VIRTUAL_HEIGHT - ground_texture.height,
            rl.WHITE)
        
        rl.DrawFPS(0, 0)
        rl.EndMode2D()
        rl.EndDrawing()
    }
}