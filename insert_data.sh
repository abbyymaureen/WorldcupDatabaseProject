#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # get winner_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")

    # if not found
    if [[ -z $WINNER_ID ]]
    then
      # insert winner_name into teams table
      INSERT_WINNING_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
      if [[ $INSERT_WINNING_TEAM == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi
    
      # get new winner_id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    fi

    # get loser_id
    LOSER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

    if [[ -z $LOSER_ID ]]
    then
      # insert loser_name into teams table
      INSERT_LOSER_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
      if [[ $INSERT_LOSER_TEAM == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi

      # get new loser name
      LOSER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    fi

    # insert into games
    INSERT_GAMES=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $LOSER_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
    if [[ $INSERT_GAMES == "INSERT 0 1" ]]
    then
      echo Inserted into games, $YEAR : $ROUND : $WINNER_ID : $LOSER_ID : $WINNER_GOALS : $OPPONENT_GOALS
    fi
  fi
done