#!/bin/bash

board=("." "." "." "." "." "." "." "." ".")
current_player="X"

print_board() {
    echo
    echo " ${board[0]} | ${board[1]} | ${board[2]} "
    echo "---|---|---"
    echo " ${board[3]} | ${board[4]} | ${board[5]} "
    echo "---|---|---"
    echo " ${board[6]} | ${board[7]} | ${board[8]} "
    echo
}

check_winner() {
    for i in 0 1 2; do
    
        # rows
        if [[ ${board[$((i * 3))]} != "." &&
            ${board[$((i * 3))]} == ${board[$((i * 3 + 1))]} &&
            ${board[$((i * 3))]} == ${board[$((i * 3 + 2))]} ]]; then
            echo "Player ${board[$((i * 3))]} wins!"
            print_board
            exit
        fi
        
        # cols
        if [[ ${board[$i]} != "." &&
            ${board[$i]} == ${board[$((i + 3))]} &&
            ${board[$i]} == ${board[$((i + 6))]} ]]; then
            echo "Player ${board[$i]} wins!"
            print_board
            exit
        fi
    done
    
    # diags
    if [[ ${board[0]} != "." &&
        ${board[0]} == ${board[4]} &&
        ${board[0]} == ${board[8]} ]]; then
        echo "Player ${board[0]} wins!"
        print_board
        exit
    fi
    if [[ ${board[2]} != "." &&
        ${board[2]} == ${board[4]} &&
        ${board[2]} == ${board[6]} ]]; then
        echo "Player ${board[2]} wins!"
        print_board
        exit
    fi
    
    # not draw
    for element in "${board[@]}"; do
        if [[ "$element" == "." ]]; then
            return
        fi
    done
    
    # draw
    echo "It's a draw!"
    print_board
    exit

}

save_game() {
    read -p "Choose a file name to save: " loc
    echo "${board[@]}" >$loc
    echo "$current_player" >>$loc
    echo "Game saved."
    exit
}

load_game() {
    read -p "Enter a file name to load: " loc
    if [[ -f $loc ]]; then
        read -a board <$loc
        current_player=$(tail -n 1 $loc)
        echo "Game loaded."
    else
        echo "No saved game found."
        exit
    fi
}

player_move() {
    while true; do
        read -p "Enter your move (1-9) or (save): " move
        if [[ "$move" == "save" ]]; then
            save_game
        fi
        move=$((move - 1))
        if [[ $move -ge 0 &&
            $move -lt 9 &&
            ${board[$move]} == "." ]]; then
            board[$move]=$current_player
            break
        else
            echo "Invalid move. Try again."
        fi
    done
}

computer_move() {
    while true; do
        move=$((RANDOM % 9))
        if [[ ${board[$move]} == "." ]]; then
            board[$move]=$current_player
            echo "Computer chooses position $((move + 1))"
            break
        fi
    done
}

load_attempt() {
    while true; do
        read -p "would you like to load the game? (y/n):" doload
        if [[ "$doload" == "y" ]]; then
            load_game
            break
        elif [[ "$doload" == "n" ]]; then
            break
        else
            echo "Invalid choice. Try again."
        fi
    done
}

swap_player() {
    if [[ $current_player == "X" ]]; then
        current_player="O"
    else
        current_player="X"
    fi
}

vs_computer() {
    load_attempt
    while true; do
        print_board
        if [[ $current_player == "X" ]]; then
            player_move
        else
            computer_move
        fi
        check_winner
        swap_player
    done
}

vs_player() {
    load_attempt
    while true; do
        print_board
        player_move
        check_winner
        swap_player
    done
}

read -p "choose mode: (1)player vs player (2)player vs computer:" mode
if [[ "$mode" == "1" ]]; then
    vs_player
elif [[ "$mode" == "2" ]]; then
    vs_computer
fi
