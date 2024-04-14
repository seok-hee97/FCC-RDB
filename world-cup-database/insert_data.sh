#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

clear

echo $($PSQL "TRUNCATE teams, games;")

echo $($PSQL " ALTER SEQUENCE teams_team_id_seq RESTART;")

echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART;")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPP WINNER_GOALS OPP_GOALS

do
  if [[ $YEAR != "year" ]]
  then
    WINNER_SEARCH_RESULT=$($PSQL "SELECT name FROM teams WHERE name='$WINNER';")
    OPP_SEARCH_RESULT=$($PSQL "SELECT name FROM teams WHERE name='$OPP';")

    if [[ -z $WINNER_SEARCH_RESULT ]]
    then
      INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")

      if [[ $INSERT_WINNER = "INSERT 0 1" ]]
      then
        echo "Inserted name $WINNER"
      fi
    fi

    if [[ -z $OPP_SEARCH_RESULT ]]
    then
      OPP_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$OPP');")
      
      if [[ $OPP_WINNER = "INSERT 0 1" ]]
      then
        echo "Inserted name $OPP"
      fi
    fi

    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPP';")

    GAME_INSERT_RESULT=$($PSQL "INSERT INTO games(year, round, opponent_id, winner_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $OPP_ID, $WINNER_ID, $WINNER_GOALS, $OPP_GOALS);")

    if [[ $GAME_INSERT_RESULT = "INSERT 0 1" ]]
    then
      echo "Inserted new match $WINNER vs. $OPP, $YEAR $ROUND"
    fi
  fi
done
