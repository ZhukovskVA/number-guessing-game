#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#script should randomly generate a number that users have to guess
MAIN_FUNC(){
  #users enters ones username (22char max) 'Enter your username:'
  echo -e "\nEnter your username:"
  read USERNAME

  USER_ID=$($PSQL "select user_id from users where username='$USERNAME';")

  if [[ -z $USER_ID ]]
    then
  # if not then 'Welcome, <username>! It looks like this is your first time here.'
  #insert a user into a database
      echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"

      INSERT_USER_RESULT=$($PSQL "insert into users(username) values('$USERNAME');")

      USER_ID=$($PSQL "select user_id from users where username='$USERNAME';")
    
    else
  #if the user exists already then 
  #'Welcome back, <username>! You have played <games_played> games, and your best game took <best_game> guesses.'
      GAMES_PLAYED=$($PSQL "select count(game_id) from games where user_id=$USER_ID;")

      BEST_GAME=$($PSQL "select min(number_of_guesses) from games where user_id=$USER_ID;")
      echo Welcome back, $USERNAME\! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
  fi
  # generate a number
  SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
  #the next line printed 'Guess the secret number between 1 and 1000:'
  echo "Guess the secret number between 1 and 1000:"

  COUNTER=0
  while true
  do
    # an input from the user should be read
    read GUESS 
    #counter for the guesses
    COUNTER=$(( COUNTER + 1 ))
    if [[ $GUESS -eq $SECRET_NUMBER ]]
    then
      break
    else
      if [[ ! $GUESS =~ [0-9] ]]
      then
    #if anything other than integer 'That is not an integer, guess again:'
        echo "That is not an integer, guess again:"
      else
    # check if guess lower or higner than the number
        LOWER=$(( GUESS < SECRET_NUMBER ))
        if [[ $LOWER == 0 ]]
        then
    #until the secret number is guessed 'It's lower than that, guess again:'
          echo "It's lower than that, guess again:"
        else
    #or 'It's higher than that, guess again:'
          echo "It's higher than that, guess again:"
        fi
      fi
    fi
  done
  #insert number of guesses, secret number into a database for this user
  INSERT_GAME_RESULT=$($PSQL "insert into games(user_id,number_of_guesses, secret_number) values($USER_ID,$COUNTER,$SECRET_NUMBER);")
  # when number is guessed 'You guessed it in <number_of_guesses> tries. The secret number was <secret_number>. Nice job!'
  echo "You guessed it in $COUNTER tries. The secret number was $SECRET_NUMBER. Nice job!"
}
MAIN_FUNC