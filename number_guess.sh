#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAIN(){
ATTAIN_USERNAME
PROCESS_USERNAME_INPUT
GAME_SETTINGS
PLAY_GAME
}

ATTAIN_USERNAME(){
  echo "Enter your username:"
  read ENTERED_USERNAME 
}

PROCESS_USERNAME_INPUT(){
  if [[ -z $ENTERED_USERNAME ]]; then 
    echo "Please enter a valid username - username cannot be empty"
  elif [[ $ENTERED_USERNAME =~ ^[0-9]+$ ]]; then
    echo "Please enter a valid username - username cannot be a number"
  else
    USERNAME=$($PSQL "SELECT username FROM users WHERE username='$ENTERED_USERNAME';")

    if [[ -z $USERNAME ]]; then
      INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$ENTERED_USERNAME');")
      USERNAME=$($PSQL "SELECT username FROM users WHERE username='$ENTERED_USERNAME';")
      
      WELCOME_MESSAGE="Welcome, $USERNAME! It looks like this is your first time here."
      echo $WELCOME_MESSAGE
    else
      GAMES_PLAYED=$($PSQL "SELECT count(username) FROM games LEFT JOIN users USING(user_id) WHERE username='$USERNAME';")
      BEST_GAME=$($PSQL "SELECT min(score) FROM games LEFT JOIN users USING(user_id) WHERE username='$USERNAME';")

      WELCOME_BACK_MESSAGE="Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
      echo $WELCOME_BACK_MESSAGE
    fi
  fi
}

GAME_SETTINGS(){
  LOWEST_NUMBER=1
  HIGHEST_NUMBER=1000
  RANDOM_NUMBER=$((RANDOM % $HIGHEST_NUMBER + $LOWEST_NUMBER))
}

PLAY_GAME(){
  echo "Guess the secret number between $LOWEST_NUMBER and $HIGHEST_NUMBER:"
  read ENTERED_NUMBER 

  GUESS_COUNT=1
  while [[ $ENTERED_NUMBER != $RANDOM_NUMBER ]]; do
    if [[ $ENTERED_NUMBER =~ [a-zA-Z]+ ]]; then
      echo "That is not an integer, guess again:"
    elif [[ "$ENTERED_NUMBER" -gt "$RANDOM_NUMBER" ]]; then
      echo "It's lower than that, guess again:"
    elif [[ "$ENTERED_NUMBER" -lt "$RANDOM_NUMBER" ]]; then
      echo "It's higher than that, guess again:"
    fi

    read ENTERED_NUMBER
    ((GUESS_COUNT++))
  done

  SELECTED_USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
  INSERT_GAMES_SCORE_RESULT=$($PSQL "INSERT INTO games (user_id, score) VALUES ('$SELECTED_USER_ID', $GUESS_COUNT);")

  FINISHING_MESSAGE="You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
  echo -e \n$FINISHING_MESSAGE
}


MAIN