#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "Enter your username:"
read USER_NAME

USER_NAME_EXISTS=$($PSQL "SELECT username FROM user_data WHERE username='$USER_NAME';");
if [[ -z $USER_NAME_EXISTS ]]
  then
    echo -e "Welcome, $USER_NAME! It looks like this is your first time here."
    ADDED_USER_NAME=$($PSQL "INSERT INTO user_data(username) VALUES('$USER_NAME');") 
else
  USER_DATA=$($PSQL "SELECT games_played, best_game FROM user_data WHERE username='$USER_NAME'")
  echo $USER_DATA | while IFS='|' read GAMES_PLAYED BEST_GAME
  do
    echo -e "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

RANDOM_NUMBER=$(($RANDOM % 1000 + 1))
echo $RANDOM_NUMBER

echo -e "Guess the secret number between 1 and 1000:"
read GUESS
GUESSES=1

while [[ $GUESS -ne $RANDOM_NUMBER ]]
  do
    ((GUESSES=$GUESSES + 1))
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
      then
        echo "That is not an integer, guess again:"
    elif [[ $GUESS -gt $RANDOM_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
    elif [[ $GUESS -lt $RANDOM_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
    fi
    read GUESS
  done

echo "You guessed it in $GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"

# update db
BEST_GAME=$($PSQL "SELECT best_game FROM user_data WHERE username='$USER_NAME';")
if [[ -z $BEST_GAME ]]
  then
    ((BEST_GAME=$GUESSES))
elif [[ $BEST_GAME -gt $GUESSES ]]
  then
    ((BEST_GAME=$GUESSES))
fi
UPDATED_USER_DATA=$($PSQL "UPDATE user_data SET best_game=$BEST_GAME, games_played=games_played + 1 WHERE username='$USER_NAME';")
