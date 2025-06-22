package main

import rl "vendor:raylib"

/* SCORE */
SCORE_PAD :: 15
score := [2]int{0, 0}

score_draw :: proc(score: [2]int) {
    x := score.x
    y := score.y
    score_left_text := rl.TextFormat("%i", x)
    score_right_text := rl.TextFormat("%i", y)

    score_right_text_width := rl.MeasureText(score_right_text, FONT_SIZE)
    colon_text_width := rl.MeasureText(":", FONT_SIZE)

    rl.DrawText(text = ":",
                posX = (CANVAS_SIZE / 2) - (colon_text_width / 2),
                posY = (FONT_SIZE*2),
                fontSize = FONT_SIZE,
                color = rl.WHITE)
    rl.DrawText(text = score_left_text,
                posX = (CANVAS_SIZE / 2) - (colon_text_width / 2) - SCORE_PAD,
                posY = (FONT_SIZE*2),
                fontSize = FONT_SIZE,
                color = rl.WHITE)
    rl.DrawText(text = score_right_text,
                posX = (CANVAS_SIZE / 2) + colon_text_width + SCORE_PAD - score_right_text_width,
                posY = (FONT_SIZE*2),
                fontSize = FONT_SIZE,
                color = rl.WHITE)
}

score_reset :: proc(score: ^[2]int) {
    score.x = 0
    score.y = 0
}

score_increase_left :: proc(score: ^[2]int) {
    score.x += 1
}

score_increase_right :: proc(score: ^[2]int) {
    score.y += 1
}