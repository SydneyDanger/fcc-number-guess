#!/bin/bash

PSQL="psql --username freecodecamp dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

# check if new or returning user
USERNAME_RESULT=$($PSQL "SELECT users.username, games_played, guesses FROM users JOIN games ON users.username=games.username WHERE users.username='$USERNAME' ORDER BY guesses ASC LIMIT 1")
GAME_VALIDATE=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")

if [[ -z $USERNAME_RESULT ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # Add user to database
  NEW_USERNAME_RESULT=$($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME', 0)")
else
  echo "$USERNAME_RESULT" | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# generate random number
NUMBER=$(( 1 + $RANDOM % 1000 ))

# prompt user to guess the number
echo "Guess the secret number between 1 and 1000:"
read USER_GUESS
# guess loop
GUESSES=1
# while USER_GUESS is not equal to NUMBER
while [[ ! $USER_GUESS = $NUMBER ]]
do
  if [[ $USER_GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $USER_GUESS -gt $NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      read USER_GUESS
    elif [[ $USER_GUESS -lt $NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      read USER_GUESS
    fi
  else
    echo "That is not an integer, guess again:"
    read USER_GUESS
  fi
  GUESSES=$((GUESSES+1))
done

echo "You guessed it in $GUESSES tries. The secret number was $NUMBER. Nice job!"

# update users and games databases with game record
UPDATE_USERS_RESULT=$($PSQL "UPDATE users SET games_played=games_played+1 WHERE username='$USERNAME'")
UPDATE_GAMES_RESULT=$($PSQL "INSERT INTO games(username, guesses) VALUES('$USERNAME', $GUESSES)")