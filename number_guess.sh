#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USERNAME_RESULT=$($PSQL "select username from users where username='$USERNAME'")

if [[ -z $USERNAME_RESULT ]]
then
  echo -e "Welcome, $USERNAME! It looks like this is your first time here.\n"
  INSERT_RESULT=$($PSQL "insert into users(username,game_count,best_game) values('$USERNAME',1,214748364)")
  BESTGAME=$($PSQL "select best_game from users where username='$USERNAME'")
else
  GAMECOUNT=$($PSQL "select game_count from users where username='$USERNAME'")
  BESTGAME=$($PSQL "select best_game from users where username='$USERNAME'")
  echo -e "Welcome back, $USERNAME! You have played $GAMECOUNT games, and your best game took $BESTGAME guesses.\n"
  UPDATE_RESULT=$($PSQL "update users set game_count = game_count + 1 where username='$USERNAME'")
fi

NUMBER=$((1 + RANDOM % 1000))
GUESS_COUNT=0
: '
GUESS_GAME() {
  echo "Guess the secret number between 1 and 1000:"
  read USER_GUESS

  if [[ $USER_GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $USER_GUESS < $NUMBER ]]
    then
      echo -e "It's higher than that, guess again:\n"
      (( GUESS_COUNT++ ))
      GUESS_GAME
    fi
    if [[ $USER_GUESS > $NUMBER ]]
    then
      echo -e "It's lower than that, guess again:\n"
      (( GUESS_COUNT++ ))
      GUESS_GAME
    fi
    if [[ $USER_GUESS -eq $NUMBER ]]
    then
      (( GUESS_COUNT++ ))
      if [[ $GUESS_COUNT < $BESTGAME ]]
      then
        BEST_UPDATE_RESULT=$($PSQL "update users set best_game = $GUESS_COUNT where username='$USERNAME'")
      fi
      echo -e "You guessed it in $GUESS_COUNT tries. The secret number was $NUMBER. Nice job!\n"
      return
    fi
  else
    echo -e "That is not an integer, guess again:\n"
    (( GUESS_COUNT++ ))
    GUESS_GAME
  fi
}
'
GUESS_GAME() {
  echo "Guess the secret number between 1 and 1000:"
  
  while true; do
    read USER_GUESS

    if [[ $USER_GUESS =~ ^[0-9]+$ ]]; then
      (( GUESS_COUNT++ ))

      if [[ $USER_GUESS -lt $NUMBER ]]; then
        echo -e "It's higher than that, guess again:\n"
      elif [[ $USER_GUESS -gt $NUMBER ]]; then
        echo -e "It's lower than that, guess again:\n"
      else
        if [[ $GUESS_COUNT -lt $BESTGAME ]]; then
          BEST_UPDATE_RESULT=$($PSQL "update users set best_game = $GUESS_COUNT where username='$USERNAME'")
        fi
        echo -e "You guessed it in $GUESS_COUNT tries. The secret number was $NUMBER. Nice job!"
        break
      fi
    else
      echo -e "That is not an integer, guess again:\n"
      (( GUESS_COUNT++ ))
    fi
  done
}

GUESS_GAME


