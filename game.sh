#!/usr/bin/env bash

# Simple terminal game where you move '@' to collect '*' using arrow keys.
# Works in bash-compatible shells on Linux.

WIDTH=20
HEIGHT=10
SCORE=0

# Player initial position at center
PLAYER_X=$((WIDTH/2))
PLAYER_Y=$((HEIGHT/2))

# Random star position function
place_star() {
    STAR_X=$((RANDOM % (WIDTH-2) + 1))
    STAR_Y=$((RANDOM % (HEIGHT-2) + 1))
}

place_star

cleanup() {
    tput cnorm
    stty echo
    clear
}
trap cleanup EXIT

# Hide cursor and disable echo
stty -echo
clear
printf '\e[?25l'

draw() {
    tput cup 0 0
    echo "Score: $SCORE (press q to quit)"
    for ((i=0; i<HEIGHT; i++)); do
        line=""
        for ((j=0; j<WIDTH; j++)); do
            if [[ $i -eq 0 || $i -eq $((HEIGHT-1)) || $j -eq 0 || $j -eq $((WIDTH-1)) ]]; then
                line+="#"
            else
                if [[ $i -eq $PLAYER_Y && $j -eq $PLAYER_X ]]; then
                    line+="@"
                elif [[ $i -eq $STAR_Y && $j -eq $STAR_X ]]; then
                    line+="*"
                else
                    line+=" "
                fi
            fi
        done
        echo "$line"
    done
}

while true; do
    draw
    IFS= read -rsn1 key
    if [[ $key == $'q' ]]; then
        break
    elif [[ $key == $'\x1b' ]]; then
        read -rsn2 key
        case $key in
            "[A") ((PLAYER_Y>1)) && PLAYER_Y=$((PLAYER_Y-1)) ;;
            "[B") ((PLAYER_Y<HEIGHT-2)) && PLAYER_Y=$((PLAYER_Y+1)) ;;
            "[C") ((PLAYER_X<WIDTH-2)) && PLAYER_X=$((PLAYER_X+1)) ;;
            "[D") ((PLAYER_X>1)) && PLAYER_X=$((PLAYER_X-1)) ;;
        esac
    fi

    if [[ $PLAYER_X -eq $STAR_X && $PLAYER_Y -eq $STAR_Y ]]; then
        SCORE=$((SCORE+1))
        place_star
    fi

done

