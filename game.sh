#!/usr/bin/env bash

# Simple snake game for the terminal.
# Use arrow keys to change direction. Press 'q' to quit.
# Tested on bash 4+.

WIDTH=20
HEIGHT=10

SNAKE_X=(5 4 3)
SNAKE_Y=(5 5 5)
DIR=RIGHT

place_food() {
    while true; do
        FOOD_X=$((RANDOM % (WIDTH-2) + 1))
        FOOD_Y=$((RANDOM % (HEIGHT-2) + 1))
        collide=false
        for ((i=0; i<${#SNAKE_X[@]}; i++)); do
            if [[ ${SNAKE_X[i]} -eq $FOOD_X && ${SNAKE_Y[i]} -eq $FOOD_Y ]]; then
                collide=true
                break
            fi
        done
        $collide || break
    done
}

cleanup() {
    tput cnorm
    stty echo
    clear
}
trap cleanup EXIT

stty -echo
clear
printf '\e[?25l'

place_food

move_snake() {
    local head_x=${SNAKE_X[0]}
    local head_y=${SNAKE_Y[0]}
    case $DIR in
        UP)    head_y=$((head_y-1)) ;;
        DOWN)  head_y=$((head_y+1)) ;;
        LEFT)  head_x=$((head_x-1)) ;;
        RIGHT) head_x=$((head_x+1)) ;;
    esac

    if ((head_x <= 0 || head_x >= WIDTH-1 || head_y <= 0 || head_y >= HEIGHT-1)); then
        return 1
    fi
    for ((i=0; i<${#SNAKE_X[@]}; i++)); do
        if [[ ${SNAKE_X[i]} -eq $head_x && ${SNAKE_Y[i]} -eq $head_y ]]; then
            return 1
        fi
    done

    SNAKE_X=("$head_x" "${SNAKE_X[@]}")
    SNAKE_Y=("$head_y" "${SNAKE_Y[@]}")

    if [[ $head_x -eq $FOOD_X && $head_y -eq $FOOD_Y ]]; then
        place_food
    else
        unset 'SNAKE_X[${#SNAKE_X[@]}-1]'
        unset 'SNAKE_Y[${#SNAKE_Y[@]}-1]'
        SNAKE_X=("${SNAKE_X[@]}")
        SNAKE_Y=("${SNAKE_Y[@]}")
    fi
    return 0
}

draw() {
    tput cup 0 0
    local score=$(( ${#SNAKE_X[@]} - 3 ))
    echo "Score: $score (q to quit)"
    for ((y=0; y<HEIGHT; y++)); do
        line=""
        for ((x=0; x<WIDTH; x++)); do
            if ((y==0 || y==HEIGHT-1 || x==0 || x==WIDTH-1)); then
                line+="#"
            else
                char=" "
                if [[ $x -eq $FOOD_X && $y -eq $FOOD_Y ]]; then
                    char="*"
                fi
                for ((i=0; i<${#SNAKE_X[@]}; i++)); do
                    if [[ ${SNAKE_X[i]} -eq $x && ${SNAKE_Y[i]} -eq $y ]]; then
                        char=$([[ $i -eq 0 ]] && echo "O" || echo "o")
                        break
                    fi
                done
                line+="$char"
            fi
        done
        echo "$line"
    done
}

while true; do
    draw
    if IFS= read -rsn1 -t 0.2 key; then
        if [[ $key == q ]]; then
            break
        elif [[ $key == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key
            case $key in
                "[A") [[ $DIR != DOWN ]] && DIR=UP ;;
                "[B") [[ $DIR != UP ]] && DIR=DOWN ;;
                "[C") [[ $DIR != LEFT ]] && DIR=RIGHT ;;
                "[D") [[ $DIR != RIGHT ]] && DIR=LEFT ;;
            esac
        fi
    fi
    move_snake || break
done
